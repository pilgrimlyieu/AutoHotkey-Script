#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

Path2WSL(path) {
    return "/mnt/" StrLower(SubStr(path, 1, 1)) StrReplace(SubStr(path, 3), "\", "/")
}

Profiles := Map(
    "Bash",       "Git Bash",
    "Ubuntu",     "Ubuntu",
    "PowerShell", "PowerShell",
    "CMD",        "Command Prompt",
)

RunWT(profile := "PowerShell") {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    if (profile == "Ubuntu") {
        starting := DirExist(selected) ? Path2WSL(selected) : "~/Space"
    } else {
        starting := DirExist(selected) ? StrReplace(selected, "\", "/") : "~"
    }
    Run(Format("wt --window 0 new-tab --profile `"{1}`" --startingDirectory `"{2}`"", Profiles[profile], starting))
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#t::RunWT()
#+t::RunWT("Ubuntu")
