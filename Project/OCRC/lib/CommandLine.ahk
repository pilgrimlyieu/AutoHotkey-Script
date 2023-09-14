global Cli_Commands := Map(
    "-s", ,
    "--snip", ,
    "-f", ,
    "--file", ,
    "-d", ,
    "--dir", ,
    "-S", ,
    "--set", ,
    "-D", ,
    "--debug", ,
)
global Cli_TextOCROptions := Map(
    "-S", ,
    "--show", ,
    "-l", ,
    "--lang", ,
    "-t", ,
    "--type", ,
    "-c", ,
    "--conf", ,
    "-f", ,
    "--format", ,
    "-p", ,
    "--punc", ,
    "-s", ,
    "--space", ,
    "-o", ,
    "--output", ,
)
global Cli_FormulaOCROptions := Map(
    "-S", ,
    "--show", ,
    "-i", ,
    "--inline", ,
    "-d", ,
    "--display", ,
    "-s", ,
    "--select", ,
    "-o", ,
    "--output", ,
)
global Cli_DefaultCommand := "--snip"

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