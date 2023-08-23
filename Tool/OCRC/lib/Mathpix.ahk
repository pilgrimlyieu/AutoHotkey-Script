class Mathpix {
    __New(post := "", config := "") {
        headers := Map(
            "app_id"      , config["app_id"],
            "app_key"     , config["app_key"],
            "Content-type", "application/json",
        )
        post_data := Map(
            "src"                 , config["imgbase64"],
            "idiomatic_eqn_arrays", True,
            "formats"             , ["text", "latex_styled"],
        )
        for key, value in post
            post_data[key] := value
        this.post   := post
        this.default_select := this.config["default_select"]
        this.json   := JSON.parse(Request("https://api.mathpix.com/v3/text", "UTF-8", "POST", JSON.stringify(post_data), headers))
        this.__Show()
    }

    __Show() {
        if this.json.error
            return MsgBox(this.json.error_info.message, "MathpixOCR ERROR: " this.json.error_info.id, "Iconx 0x1000")

        id             := "Mathpix" this.json.request_id
        confidence     := Format("{:.2f}", 100 * this.json.confidence)
        latex_result   := this.json.latex_styled
        inline_result  := this.post.math_inline_delimiters[1] latex_result this.post.math_inline_delimiters[2]
        display_result := this.post.math_display_delimiters[1] "`n" latex_result "`n" this.post.math_display_delimiters[2] "`n"
        text_result    := StrReplace(StrReplace(this.json.text, "\n", "`n"), "\\", "\")

        %id% := Gui(, id).OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        %id%.Title := "OCRC (MathpixOCR) 识别结果"
        %id%.BackColor := "EBEDF4"
        %id%.SetFont("s18", "Microsoft YaHei")

        Clip(CtrlObj, Info := "") => A_Clipboard := CtrlObj.Value
        FocusSelect(CtrlObj) => (ControlFocus(CtrlObj.Hwnd), Clip(CtrlObj))
        gui_height_case := 0
        if text_result == inline_result || latex_result ~= "\\begin\{" {
            gui_height_case += 2
            %id%.AddText("x10 y20 w100 Right", "LaTeX")
            %id%.AddEdit("x120 yp w370 h36 vLaTeXResult ReadOnly -Multi -VScroll", latex_result).OnEvent("Focus", Clip)
            %id%.AddText("x10 y+20 w100 Right", "行内公式")
            %id%.AddEdit("x120 yp w370 h36 vInlineResult ReadOnly -Multi -VScroll", inline_result).OnEvent("Focus", Clip)
            %id%.AddText("x10 y+20 w100 Right", "行间公式")
            %id%.AddEdit("x120 yp w370 h36 vDisplayResult ReadOnly -Multi -VScroll", display_result).OnEvent("Focus", Clip)
            FocusSelect(%id%[["LaTeXResult", "InlineResult", "DisplayResult"][this.default_select]])
        }
        if text_result != inline_result && (!(latex_result ~= "\\begin\{") || text_result ~= "\\begin\{") {
            gui_height_case += 1
            %id%.AddText("x10 y+20 w100 Right", "文本公式")
            %id%.AddEdit("x120 yp w370 h36 vTextResult ReadOnly -Multi -VScroll", text_result).OnEvent("Focus", Clip)
            if text_result != inline_result && !(latex_result ~= "\\begin\{")
                FocusSelect(%id%["TextResult"])
        }

        if confidence <= 20
            progress_color := "EC4D3D"
        else if confidence <= 60
            progress_color := "F8CD46"
        else
            progress_color := "63C956"
        %id%.AddProgress("x10 y+20 w480 h30 c" progress_color, confidence)
        %id%.AddText("yp w500 Center BackgroundTrans", confidence "%")

        %id%.Show("w500 h" (gui_height_case >= 2) ? (gui_height_case == 3) ? 295 : 240 : 120)

        GroupAdd("Mathpix", "ahk_id " %id%.Hwnd)
    }
}