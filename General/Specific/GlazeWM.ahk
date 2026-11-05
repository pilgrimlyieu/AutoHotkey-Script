#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
Persistent
DetectHiddenWindows true

; Workarounds for GlazeWM (hide_method: cloak) with Electron apps such as QQNT:
; 1. Electron popups (notifications, tray menus) leave the taskbar via ITaskbarList::DeleteTab instead of
;    WS_EX_TOOLWINDOW, so GlazeWM manages them: window rules move/center them and they steal focus.
;    Mark them as tool windows so GlazeWM ignores them. DeleteTab raises no window event and its timing
;    relative to create/show varies, so keep re-checking for a moment.
; 2. If an app hides a window while GlazeWM has it cloaked on an inactive workspace, GlazeWM keeps managing it.
;    Back on that workspace it re-adds the taskbar tab and re-shows the window while it's still cloaked (a hidden
;    window can't be uncloaked), leaving an invisible ghost in the taskbar that later pops up centered.
;    Release such windows from GlazeWM, and uncloak them once the app shows them again.

Processes := [
    "QQ.exe"
]
MarkDelays := [
    20,
    150,
    500,
    1000
] ; Roughly covers an Electron window's create -> DeleteTab -> show sequence

ProcessNames := Map(), Released := Map()
SetTimer(() => ProcessNames.Clear(), 600000)
DllCall("SetWinEventHook", "UInt", 0x8000, "UInt", 0x8003, "Ptr", 0, "Ptr", CallbackCreate(OnWinEvent, , 7), "UInt", 0, "UInt", 0, "UInt", 0x2)

for hwnd, id in GlazeWindows()
    if IsTarget(hwnd) && !DllCall("IsWindowVisible", "Ptr", hwnd)
        Release(hwnd, id)
for name in Processes
    for hwnd in WinGetList("ahk_exe " name)
        MarkLater(hwnd)

OnWinEvent(hWinEventHook, event, hwnd, idObject, idChild, *) {
    static desktop := DllCall("GetDesktopWindow", "Ptr")
    if idObject || idChild || DllCall("GetAncestor", "Ptr", hwnd, "UInt", 1, "Ptr") != desktop || !IsTarget(hwnd)
        return
    switch event {
        case 0x8000: MarkLater(hwnd)                    ; EVENT_OBJECT_CREATE
        case 0x8002: SetTimer(OnShow.Bind(hwnd), -1)    ; EVENT_OBJECT_SHOW
        case 0x8003: SetTimer(OnHide.Bind(hwnd), -1)    ; EVENT_OBJECT_HIDE
    }
}

OnShow(hwnd) {
    MarkLater(hwnd)
    if !(Cloaked(hwnd) & 2)
        return
    if !Released.Has(hwnd) && (id := GlazeWindows().Get(hwnd, ""))
        Release(hwnd, id)
    Uncloak(hwnd)
}

OnHide(hwnd) {
    if DllCall("IsWindowVisible", "Ptr", hwnd) || !(Cloaked(hwnd) & 2)
        return
    if id := GlazeWindows().Get(hwnd, "")
        Release(hwnd, id)
}

; Returns true once the window is known to be a popup, i.e. there is nothing left to wait for
MarkLater(hwnd, i := 1) {
    if MarkPopup(hwnd) || i > MarkDelays.Length
        return
    SetTimer(MarkLater.Bind(hwnd, i + 1), -MarkDelays[i])
}

MarkPopup(hwnd) {
    try {
        ; A captionless Electron window kept off the taskbar is a popup. The cloak check rules out windows whose
        ; DeleteTab was done by GlazeWM itself, i.e. the ones it already manages on an inactive workspace.
        if WinGetClass(hwnd) != "Chrome_WidgetWin_1" || (WinGetStyle(hwnd) & 0xC00000) = 0xC00000
            || !DllCall("GetProp", "Ptr", hwnd, "Str", "ITaskList_Deleted", "Ptr")
            return false
        if Cloaked(hwnd)
            return true
        if WinGetExStyle(hwnd) & 0x08000000 ; Already kept off the taskbar by the app itself
            return true
        if WinGetExStyle(hwnd) & 0x80 ; WS_EX_TOOLWINDOW, marked already
            return true
        WinSetExStyle("+0x80", hwnd)
        Log("Marked popup", hwnd)
        ; A popup shown before its app called DeleteTab may have been managed in the meantime
        if DllCall("IsWindowVisible", "Ptr", hwnd) && (id := GlazeWindows().Get(hwnd, ""))
            Release(hwnd, id), Released.Delete(hwnd)
        return true
    }
    return false
}

Release(hwnd, id) {
    RunWait(A_ComSpec " /c glazewm command --id " id " ignore", , "Hide")
    Released[hwnd] := true
    ; Undo GlazeWM's DeleteTab, so a regular window gets its taskbar button back when shown again
    try {
        if (WinGetStyle(hwnd) & 0xC00000) = 0xC00000
            TaskbarList(4, hwnd) ; AddTab
    }
    Log("Released", hwnd)
}

Uncloak(hwnd, tries := 20) {
    if Cloaked(hwnd) & 2 {
        ; The shell creates the window's view shortly after it's shown, until then SetCloak fails
        if !SetCloak(hwnd, false)
            return --tries && SetTimer(Uncloak.Bind(hwnd, tries), -50)
        Log("Uncloaked", hwnd)
    }
    if Released.Has(hwnd)
        Released.Delete(hwnd)
}

IsTarget(hwnd) {
    DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", &pid := 0)
    if !ProcessNames.Has(pid)
        try
            ProcessNames[pid] := ProcessGetName(pid)
        catch
            ProcessNames[pid] := ""
    for name in Processes
        if ProcessNames[pid] = name
            return true
    return false
}

GlazeWindows() {
    windows := Map(), tmp := Format("{}\glazewm-windows-{}-{}.json", A_Temp, A_TickCount, Random(1000, 9999))
    try {
        RunWait(Format('{} /c glazewm query windows > "{}"', A_ComSpec, tmp), , "Hide")
        for chunk in StrSplit(FileRead(tmp, "UTF-8"), '{"type":"window",')
            if RegExMatch(chunk, '^"id":"([^"]+)".*?"handle":(\d+),', &m)
                windows[Integer(m[2])] := m[1]
    }
    try FileDelete(tmp)
    return windows
}

Cloaked(hwnd) {
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked := 0, "UInt", 4) ; DWMWA_CLOAKED
    return cloaked
}

SetCloak(hwnd, cloak) {
    ; Undocumented IApplicationView::SetCloak, as used by GlazeWM itself
    try {
        shell := ComObject("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
        iid := Buffer(16), DllCall("ole32\CLSIDFromString", "Str", "{1841C6D7-4F9D-42C0-AF41-8747538F10E5}", "Ptr", iid)
        ComCall(3, shell, "Ptr", iid, "Ptr", iid, "Ptr*", &collection := 0) ; QueryService(IApplicationViewCollection)
        collection := ComValue(13, collection)
        ComCall(6, collection, "Ptr", hwnd, "Ptr*", &view := 0) ; GetViewForHwnd
        view := ComValue(13, view)
        ComCall(12, view, "UInt", 1, "Int", cloak ? 2 : 0) ; SetCloak
        return true
    }
    return false
}

TaskbarList(method, hwnd) {
    taskbar := ComObject("{56FDF344-FD6D-11d0-958A-006097C9A090}", "{56FDF342-FD6D-11d0-958A-006097C9A090}")
    ComCall(3, taskbar) ; HrInit
    ComCall(method, taskbar, "Ptr", hwnd)
}

Log(action, hwnd) {
    try FileAppend(Format("{} {} {} `"{}`"`n", FormatTime(, "yyyy-MM-dd HH:mm:ss"), action, hwnd, WinGetTitle(hwnd)), A_ScriptDir "\GlazeWM.log", "UTF-8")
}
