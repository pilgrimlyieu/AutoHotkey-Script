class Bing {
    __New(configs) {
        this.configs := configs
        headers := Map("Content-type", "application/json")
        post_data := Map(
            "data", configs["image_base64"],
            "inputForm", "Image",
            "clientInfo", Map("mkt", "zh-cn")
        )
        this.json := JSON.parse(Request("https://www.bing.com/cameraexp/api/v1/getlatex", "UTF-8", "POST", JSON.stringify(post_data), headers))
        if this.json["isError"]
            return MsgBox(this.json["errorMessage"], "BingOCR ERROR", "Iconx 0x1000")
        if this.configs["show"]
            this.__Show()
    }

    __Show() {
        latex_result := this.json["latex"]
        inline_result  := this.configs["math_inline_delimiters"][1] StrReplace(latex_result, "`n", " ") this.configs["math_inline_delimiters"][2]
        display_result := this.configs["math_display_delimiters"][1] "`n" latex_result "`n" this.configs["math_display_delimiters"][2] "`n"

        this.ResultGUI := Gui()
        this.ResultGUI.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        this.ResultGUI.Title := "OCRC (Bing OCR) 识别结果"
        this.ResultGUI.BackColor := "EBEDF4"
        this.ResultGUI.SetFont("s18", "Microsoft YaHei")

        Clip(CtrlObj, *) => A_Clipboard := CtrlObj.Value
        this.ResultGUI.AddText("x10 y5 w40 vFocus Right", "引擎").SetFont("s12")
        this.ResultGUI.AddDropDownList("x60 y5 w150 vFormulaOCREngine AltSubmit Choose" this.configs["formulaocr_engine"], Map2Array(Basic_FormulaOCREngines)).SetFont("s12")
        this.ResultGUI["FormulaOCREngine"].OnEvent("Change", (CtrlObj, *) => Basic_FormulaOCREngines[CtrlObj.Text].Call("", this.configs["image_base64"]))
        this.ResultGUI.AddText("x10 y40 w100 Right", "LaTeX")
        this.ResultGUI.AddEdit("x120 yp w370 h36 vLaTeXResult ReadOnly -Multi -VScroll", latex_result).OnEvent("Focus", Clip)
        this.ResultGUI.AddText("x10 y+20 w100 Right", "行内公式")
        this.ResultGUI.AddEdit("x120 yp w370 h36 vInlineResult ReadOnly -Multi -VScroll", inline_result).OnEvent("Focus", Clip)
        this.ResultGUI.AddText("x10 y+20 w100 Right", "行间公式")
        this.ResultGUI.AddEdit("x120 yp w370 h36 vDisplayResult ReadOnly -Multi -VScroll", display_result).OnEvent("Focus", Clip)
        Clip(this.ResultGUI[["LaTeXResult", "InlineResult", "DisplayResult"][this.configs["default_select"]]])
        this.ResultGUI["Focus"].Focus()
        this.ResultGUI.Show("w500 h205")
    }
}