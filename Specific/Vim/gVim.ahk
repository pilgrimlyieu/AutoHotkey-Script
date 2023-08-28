ListJoin(list, string) {
    for index, content in list
        str .= string . content
    return SubStr(str, StrLen(string) + 1)
}

MonitorGetWorkArea( , , , &WorkAreaInfoRight, &WorkAreaInfoBottom)
SetWorkingDir(A_Args[1])
A_Args.RemoveAt(1)

if A_Args.Length == 1
    Run("gvim `"" A_Args[1] "`"", , , &process_id)
else if A_Args.Length > 1
    Run("gvim -d `"" ListJoin(A_Args, "`" `"") "`"", , , &process_id)
else
    Run("gvim", , , &process_id)
ProcessSetPriority("High", process_id)
WinWait("ahk_pid " process_id, , 10)
WinSetStyle(-0xC40000, "ahk_pid " process_id)
WinMove(0, 0, WorkAreaInfoRight, WorkAreaInfoBottom, "ahk_pid " process_id)
WinActivate("ahk_pid " process_id)