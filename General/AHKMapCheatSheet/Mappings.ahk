#NoTrayIcon

global WorkingDir     := "G:/Project/Scripts/AutoHotkey/"
global Mappings_Helps := Map(
    "Fn"                 , "Basic/Remap/Fn",
    "WinDrag"            , "Basic/Window/WinDrag/WinDrag",
    "Tips"               , "General/Tips/Run",
    "Anki_ChineseKeyWord", "Specific/Anki/ChineseKeyWord",
    "Anki_Derive"        , "Specific/Anki/Derive",
    "Anki_Cloze"         , "Specific/Anki/Cloze",
    "Vark"               , "Tool/Vark/Vark",
    "Vanki"              , "Tool/Vark/Vanki",
)

global Alias := []
global text  := "Helps:"
for key in Mappings_Helps
    Alias.Push(key)
for index, key in Alias
    text .= "`r" index ": " key

#F1::{
number := InputBox(text, "Helps", "T5 H" String(100 + 20 * Alias.Length))
if number.Result = "OK"
    try
        Run "D:/Program Files/Snipaste/Snipaste.exe paste --files " WorkingDir Mappings_Helps[Alias[Integer(number.Value)]] ".png"
}