; https://www.autohotkey.com/boards/viewtopic.php?t=100602

#Include <Native>

class JSON {
    static __New() {
        Native.LoadModule("ahk-json.dll", ["JSON"])
        this.DefineProp("true", {value: 1})
        this.DefineProp("false", {value: 0})
        this.DefineProp("null", {value: ""})
    }
    static parse(str) => 1
    static stringify(obj, space := 0) => 1
}