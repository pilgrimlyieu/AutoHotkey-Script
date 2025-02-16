preventStartLaunch(args) {
    if args.Length >= 1 && args[1] = "LAUNCH_FROM_START"
        ExitApp
}

ShellRunAsUser(filePath, arguments := "", directory := "", verb := "", show := 1) {
    ; Credit: https://www.autohotkey.com/boards/viewtopic.php?p=489732&sid=e81995f98f01b1ae06f612c21b372e67#p489732
    static VT_UI4 := 0x13, SWC_DESKTOP := 0x8
    ShellWindows := ComObject("Shell.Application").Windows
    Shell := ShellWindows.Item(ComValue(VT_UI4, SWC_DESKTOP)).Document.Application
    Shell.ShellExecute(filePath, arguments, directory, verb, show)
}