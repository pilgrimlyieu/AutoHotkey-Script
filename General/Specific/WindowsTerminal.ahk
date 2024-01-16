#NoTrayIcon

#Include ..\..\Library\Clipboard.ahk

Profiles := Map(
    "Bash",       "Git Bash",
    "Ubuntu",     "Ubuntu-22.04",
    "PowerShell", "PowerShell",
    "CMD",        "Command Prompt",
)

RunWT(profile := "Bash") {
    ClipList := GetSelectedPath(), ClipSaved := ClipList.saved, selected := ClipList.path
    Run(Format("wt --window 0 new-tab --profile `"{1}`" --startingDirectory `"{2}`"", Profiles[profile], (profile == "Ubuntu") ? "~/Space" : DirExist(selected) ? selected : "~"))
    A_Clipboard := ClipSaved, ClipSaved := ""
}

#t::RunWT()
#+t::RunWT("Ubuntu")