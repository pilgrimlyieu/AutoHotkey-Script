class Mathpix {
    __New(configs) {
        this.configs := configs
        headers := Map(
            "app_id"      , this.configs["app_id"],
            "app_key"     , this.configs["app_key"],
            "Content-type", "application/json",
        )
        post_data := Map(
            "src"                 , this.configs["image_base64"],
            "idiomatic_eqn_arrays", True,
            "formats"             , ["text", "latex_styled"],
            "math_inline_delimiters", this.configs["math_inline_delimiters"],
            "math_display_delimiters", this.configs["math_display_delimiters"],
        )
        this.json := JSON.parse(Request("https://api.mathpix.com/v3/text", "UTF-8", "POST", JSON.stringify(post_data), headers))
        if this.json.Has("error")
            return MsgBox(this.json["error_info"]["message"], "MathpixOCR ERROR: " this.json["error_info"]["id"], "Iconx 0x1000")
        this.__Show()
    }

    __Show() {
        latex_result   := this.json.Has("latex_styled") ? this.json["latex_styled"] : ""
        inline_result  := this.configs["math_inline_delimiters"][1] StrReplace(latex_result, "`n", " ") this.configs["math_inline_delimiters"][2]
        display_result := this.configs["math_display_delimiters"][1] "`n" latex_result "`n" this.configs["math_display_delimiters"][2] "`n"
        text_result    := this.json["text"]

        this.ResultGUI := Gui()
        this.ResultGUI.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        this.ResultGUI.Title := "OCRC (Mathpix OCR) 识别结果"
        this.ResultGUI.BackColor := "EBEDF4"
        this.ResultGUI.SetFont("s18", "Microsoft YaHei")

        Clip(CtrlObj, *) => A_Clipboard := CtrlObj.Value
        this.ResultGUI.AddText("x10 y5 w40 vFocus Right", "引擎").SetFont("s12")
        this.ResultGUI.AddDropDownList("x60 y5 w150 vFormulaOCREngine AltSubmit Choose" this.configs["formulaocr_engine"], Map2Array(Basic_FormulaOCREngines)).SetFont("s12")
        this.ResultGUI["FormulaOCREngine"].OnEvent("Change", (CtrlObj, *) => Basic_FormulaOCREngines[CtrlObj.Text].Call("", this.configs["image_base64"]))
        gui_height_case := 0
        if text_result == inline_result || latex_result ~= "\\begin\{" {
            gui_height_case += 2
            this.ResultGUI.AddText("x10 y40 w100 Right", "LaTeX")
            this.ResultGUI.AddEdit("x120 yp w370 h36 vLaTeXResult ReadOnly -Multi -VScroll", latex_result).OnEvent("Focus", Clip)
            this.ResultGUI.AddText("x10 y+20 w100 Right", "行内公式")
            this.ResultGUI.AddEdit("x120 yp w370 h36 vInlineResult ReadOnly -Multi -VScroll", inline_result).OnEvent("Focus", Clip)
            this.ResultGUI.AddText("x10 y+20 w100 Right", "行间公式")
            this.ResultGUI.AddEdit("x120 yp w370 h36 vDisplayResult ReadOnly -Multi -VScroll", display_result).OnEvent("Focus", Clip)
            Clip(this.ResultGUI[["LaTeXResult", "InlineResult", "DisplayResult"][this.configs["default_select"]]])
        }
        if text_result != inline_result && (!(latex_result ~= "\\begin\{") || text_result ~= "\\begin\{") {
            gui_height_case += 1
            this.ResultGUI.AddText("x10 y+20 w100 Right", "文本公式")
            this.ResultGUI.AddEdit("x120 yp w370 h36 vTextResult ReadOnly -Multi -VScroll", text_result).OnEvent("Focus", Clip)
            if !(latex_result ~= "\\begin\{")
                Clip(this.ResultGUI["TextResult"])
        }

        confidence := Format("{:.2f}", 100 * this.json["confidence"])
        if confidence <= 20
            progress_color := "EC4D3D"
        else if confidence <= 60
            progress_color := "F8CD46"
        else
            progress_color := "63C956"
        this.ResultGUI.AddProgress("x10 y+20 w480 h30 c" progress_color, confidence)
        this.ResultGUI.AddText("x10 yp w500 Center BackgroundTrans", confidence "%")
        this.ResultGUI["Focus"].Focus()
        this.ResultGUI.Show("w500 h" ((gui_height_case >= 2) ? (gui_height_case == 3) ? 315 : 260 : 140))
    }
}