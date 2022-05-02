class Mathpix {
    __New(post := "", config := "") {
        clipboard := ""
        headers := {"app_id": config.app_id
                  , "app_key": config.app_key
                  , "Content-type": "application/json"}
        postdata := {"src": config.imgbase64
                  , "idiomatic_eqn_arrays": True
                  , "formats": ["text", "latex_styled"]}
        for key, value in post
            postdata[key] := value
        this.UpdateClip := ObjBindMethod(this, "__Clip")
        this.post := post
        this.config := config
        this.json := Json.Load(URLDownloadToVar("https://api.mathpix.com/v3/text", "UTF-8", "POST", JSON.Dump(postdata), headers))
        this.__Show()
    }

    __Show() {
        static latex_result, inline_result, display_result, result

        if this.json.error {
            MsgBox 4112, % "MathpixOCR " this.json.error_info.id, % this.json.error_info.message
            return
        }

        id := this.json.request_id
        confidence := Format("{:.2f}", 100 * this.json.confidence)
        latex_result := this.json.latex_styled
        inline_result := this.post.math_inline_delimiters[1] latex_result this.post.math_inline_delimiters[2]
        display_result := this.post.math_display_delimiters[1] "`n" latex_result "`n" this.post.math_display_delimiters[2] "`n"
        result := StrReplace(StrReplace(this.json.text, "\n", "`n"), "\\", "\")

        Gui %id%:New, % "+HwndMRW +Label" this.__Class ".Gui"
        Gui %id%:+MinimizeBox
        Gui %id%:Color, EBEDF4
        Gui %id%:Font, s18, Microsoft YaHei

        if (result = inline_result or latex_result ~= "\\begin\{") {
            Gui %id%:Add, Text, x10 y20 w100 +Right, LaTeX
            Gui %id%:Add, Edit, x120 yp w370 h36 vlatex_result ReadOnly -Multi -VScroll, %latex_result%
            Gui %id%:Add, Text, x10 y+20 w100 +Right, 行内公式
            Gui %id%:Add, Edit, x120 yp w370 h36 vinline_result ReadOnly -Multi -VScroll, %inline_result%
            Gui %id%:Add, Text, x10 y+20 w100 +Right, 行间公式
            Gui %id%:Add, Edit, x120 yp w370 h36 vdisplay_result ReadOnly -Multi -VScroll, %display_result%
            this.__FocusSelect("Edit" this.config.default_select)
        }
        if (result != inline_result and (!(latex_result ~= "\\begin\{") or result ~= "\\begin\{")) {
            Gui %id%:Add, Text, x10 y+20 w100 +Right, 文本公式
            Gui %id%:Add, Edit, x120 yp w370 h36 vresult ReadOnly -Multi -VScroll, %result%
            if (result != inline_result and !(latex_result ~= "\\begin\{"))
                this.__FocusSelect("Edit1")
        }

        if (confidence <= 20)
            progresscolor := "EC4D3D"
        else if (confidence <= 60)
            progresscolor := "F8CD46"
        else
            progresscolor := "63C956"
        Gui %id%:Add, Progress, x10 y+20 w480 h30 c%progresscolor%, %confidence%
        Gui %id%:Add, Text, yp w500 +Center BackgroundTrans +0x1, %confidence%`%

        guiheight := (result = inline_result or latex_result ~= "\\begin\{") ? (result != inline_result and (!(latex_result ~= "\\begin\{") or result ~= "\\begin\{")) ? 295 : 240 : 120
        Gui %id%:Show, w500 h%guiheight%, % "OCRC (MathpixOCR) 识别结果"

        GroupAdd Mathpix, ahk_id %MRW%
        OnMessage(0x201, this.UpdateClip)
    }

    __FocusSelect(control) {
        GuiControlGet hwndvar, Hwnd, %control%
        GuiControlGet clipvar, , %control%
        ControlFocus , , ahk_id %hwndvar%
        clipboard := clipvar
    }

    __Clip(wParam, lParam, msg, hwnd) {
        if !WinExist("ahk_group Mathpix") {
            OnMessage(0x201, this.UpdateClip, 0)
            return
        }
        GuiControlGet focusvar, FocusV
        if focusvar in result,latex_result,inline_result,display_result
        {
            GuiControlGet clipvar, , %hwnd%
            if clipvar {
                clipboard := ""
                clipboard := clipvar
            }
        }
    }

    GuiEscape() {
        Gui Destroy
    }
}