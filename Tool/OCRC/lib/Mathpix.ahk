class Mathpix {
    __New(config, header) {
        headers := Map(
            "app_id"      , header["app_id"],
            "app_key"     , header["app_key"],
            "Content-type", "application/json",
        )
        post_data := Map(
            "src"                 , header["image_base64"],
            "idiomatic_eqn_arrays", True,
            "formats"             , ["text", "latex_styled"],
        )
        for key, value in config
            post_data[key] := value
        this.config := config
        this.json := JSON.parse(Request("https://api.mathpix.com/v3/text", "UTF-8", "POST", JSON.stringify(post_data), headers))
        this.__Show()
    }

    __Show() {
        ; static latex_result, inline_result, display_result, text_result
        if this.json.Has("error")
            return MsgBox(this.json["error_info"]["message"], "MathpixOCR ERROR: " this.json["error_info"]["id"], "Iconx 0x1000")

        latex_result   := this.json.Has("latex_styled") ? this.json["latex_styled"] : ""
        inline_result  := this.config["math_inline_delimiters"][1] latex_result this.config["math_inline_delimiters"][2]
        display_result := this.config["math_display_delimiters"][1] "`n" latex_result "`n" this.config["math_display_delimiters"][2] "`n"
        text_result    := StrReplace(StrReplace(this.json["text"], "\n", "`n"), "\\", "\")

        this.id        := this.json["request_id"]
        this.__Results := Map()
        this.__Results[this.id] := Gui(, this.id)
        this.__Results[this.id].OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        this.__Results[this.id].Title := "OCRC (MathpixOCR) 识别结果"
        this.__Results[this.id].BackColor := "EBEDF4"
        this.__Results[this.id].SetFont("s18", "Microsoft YaHei")

        Clip(CtrlObj, *) => A_Clipboard := CtrlObj.Value
        FocusSelect(CtrlObj) => (CtrlObj.Focus(), Clip(CtrlObj))
        gui_height_case := 0
        if text_result == inline_result || latex_result ~= "\\begin\{" {
            gui_height_case += 2
            this.__Results[this.id].AddText("x10 y20 w100 Right", "LaTeX")
            this.__Results[this.id].AddEdit("x120 yp w370 h36 vLaTeXResult ReadOnly -Multi -VScroll", latex_result).OnEvent("Focus", Clip)
            this.__Results[this.id].AddText("x10 y+20 w100 Right", "行内公式")
            this.__Results[this.id].AddEdit("x120 yp w370 h36 vInlineResult ReadOnly -Multi -VScroll", inline_result).OnEvent("Focus", Clip)
            this.__Results[this.id].AddText("x10 y+20 w100 Right", "行间公式")
            this.__Results[this.id].AddEdit("x120 yp w370 h36 vDisplayResult ReadOnly -Multi -VScroll", display_result).OnEvent("Focus", Clip)
            FocusSelect(this.__Results[this.id][["LaTeXResult", "InlineResult", "DisplayResult"][this.config["default_select"]]])
        }
        if text_result != inline_result && (!(latex_result ~= "\\begin\{") || text_result ~= "\\begin\{") {
            gui_height_case += 1
            this.__Results[this.id].AddText("x10 y+20 w100 Right", "文本公式")
            this.__Results[this.id].AddEdit("x120 yp w370 h36 vTextResult ReadOnly -Multi -VScroll", text_result).OnEvent("Focus", Clip)
            if text_result != inline_result && !(latex_result ~= "\\begin\{")
                FocusSelect(this.__Results[this.id]["TextResult"])
        }

        confidence := Format("{:.2f}", 100 * this.json["confidence"])
        if confidence <= 20
            progress_color := "EC4D3D"
        else if confidence <= 60
            progress_color := "F8CD46"
        else
            progress_color := "63C956"
        this.__Results[this.id].AddProgress("x10 y+20 w480 h30 c" progress_color, confidence)
        this.__Results[this.id].AddText("x10 yp w500 Center BackgroundTrans", confidence "%")

        this.__Results[this.id].Show("w500 h" ((gui_height_case >= 2) ? (gui_height_case == 3) ? 295 : 240 : 120))
    }
}