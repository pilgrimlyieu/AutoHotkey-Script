; Credit: https://www.autohotkey.com/boards/viewtopic.php?t=118324

#NoTrayIcon

GetScreenOrientation(MonitorNumber := 1) {
    static dmSize := 220
    display := "\\.\DISPLAY" MonitorNumber
    DEVMODE := Buffer(dmSize, 0)
    NumPut("Short", dmSize, DEVMODE, 68)
    DllCall("EnumDisplaySettings", "Str", display, "Int", -1, "Ptr", DEVMODE)
    orientation := NumGet(DEVMODE, 84, "UInt")
    return orientation
}

ChangeScreenOrientation(Orientation := "Landscape", MonitorNumber := 1, Save := 1) {
    static dmSize := 220, DMDO_DEFAULT := 0, DMDO_90 := 1, DMDO_180 := 2, DMDO_270 := 3, CDS_UPDATEREGISTRY := 1, CDS_NONE := 0
    dimension1 := 0
    dimension2 := 0
    DEVMODE := Buffer(dmSize, 0)
    display := "\\.\DISPLAY" MonitorNumber
    NumPut("Short", dmSize, DEVMODE, 68)
    DllCall("EnumDisplaySettings", "Str", display, "Int", -1, "Ptr", DEVMODE)
    n0 := NumGet(DEVMODE, 172, "UInt")
    n1 := NumGet(DEVMODE, 176, "UInt")
    b := n0 < n1
    dimension1 := n%b% | n%!b% << 32
    dimension2 := n%!b% | n%b% << 32

    switch Orientation, false {
        case "Landscape", 0: i := 1, orientation := DMDO_DEFAULT
        case "Portrait", 90: i := 2, orientation := DMDO_90
        case "Landscape (flipped)", 180: i := 1, orientation := DMDO_180
        case "Portrait (flipped)", 270: i := 2, orientation := DMDO_270
        default: i := 1, orientation := DMDO_DEFAULT
    }
    NumPut("Int", orientation, DEVMODE, 84)
    NumPut("Int64", dimension%i%, DEVMODE, 172)
    if (Save == 1) {
        ; Keep screen rotation after rebooting
        DllCall("ChangeDisplaySettingsEx", "Str", display, "Ptr", DEVMODE, "Ptr", 0, "Int", 0, "Int", 0, "UInt", CDS_UPDATEREGISTRY)
    } else {
        ; Only temporarily change it for the current windows session
        DllCall("ChangeDisplaySettingsEx", "Str", display, "Ptr", DEVMODE, "Ptr", 0, "Int", 0, "Int", 0, "UInt", CDS_NONE)
    }
}

#^F12:: {
    monitorNumber := 2
    currentOrientation := GetScreenOrientation(monitorNumber)
    if (currentOrientation == 0) {
        ChangeScreenOrientation("Portrait", monitorNumber)
    } else {
        ChangeScreenOrientation("Landscape", monitorNumber)
    }
}