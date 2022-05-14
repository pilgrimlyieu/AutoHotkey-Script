class Derive extends AnkiCloze {
    PartofSpeech() {
        this.__GetText()
        text := RegexRePlace(Trim(this.text, " `t`r`n"), "(n|v|adj|adv|prep|conj|vt|vi)\.\s?", "$1. ")
        for e, c in {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
            text := RegexReplace(text, (e ~= "[([]") ? ((e ~= "[.?()[\]]" ? "\" e : e) "(?=\s?[\x{4e00}-\x{9fa5}])") : ("(?:[\x{4e00}-\x{9fa5}]\s?)\K" (e ~= "[.?()[\]]" ? "\" e : e)), c)
        SendInput % "{Text}" text
    }
}