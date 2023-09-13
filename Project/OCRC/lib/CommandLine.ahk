global OCRC_ShortCommands := Map(
    "-s", ,
    "-f", ,
    "-d", ,
    "-S", ,
    "-D", ,
)
global OCRC_LongCommands := Map(
    "--snip", ,
    "--file", ,
    "--dir", ,
    "--set", ,
    "--debug", ,
)
global Cli_DefaultCommand := ""

Cli_Snip(args) {
    static SubCommands := Map(
        "t", ,
        "text", ,
        "m", ,
        "math", ,
        "f", ,
        "formula", ,
    )
    static DefaultSubCommand := "text"
}

Cli_File(args) {

}

Cli_Directory(args) {

}

Cli_Set(args) {
    static SubCommands := Map(
        "g", ,
        "global", ,
        "l", ,
        "local", ,
    )
    static DefaultSubCommand := "local"
}

Cli_Debug(args) {
    static SubCommands := Map(
        "k", ,
        "keys", ,
        "v", ,
        "vars", ,
        "l", ,
        "line", ,
        "c", ,
        "check", ,
    )
}