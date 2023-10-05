class Baidu {
    __New(post, configs) {
        this.post := post, this.configs := configs
        if this.__Token() != "success"
            return
        post_data := "image=" UrlEncode(this.configs["image_base64"])
        for key, value in post
            post_data .= "&" key "=" value
        this.json := JSON.parse(Request("https://aip.baidubce.com/rest/2.0/ocr/v1/" this.configs["recognition_type"] "?access_token=" this.configs["token"], "UTF-8", "POST", post_data, Map("Content-Type", "application/x-www-form-urlencoded")))
        if this.json.Has("error_msg")
            return MsgBox(this.json["error_msg"], "BaiduOCR ERROR", "Iconx 0x1000")
        if this.configs["show"]
            this.__Show()
    }

    __Process(clip) {
        this.__Format(this.configs["format_style"])
        this.__Probability()
        this.__Punctuation(this.configs["punctuation_style"])
        this.__Space(this.configs["space_style"])
        if clip
            A_Clipboard := this.result
        return this.result
    }

    __Show() {
        this.ResultGUI := Gui()
        this.ResultGUI.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        this.ResultGUI.Title := "OCRC (Baidu OCR) 「" BaiduOCR_RecognitionTypes[this.configs["recognition_type"]] "」识别结果"
        this.ResultGUI.BackColor := "EBEDF4"
        this.ResultGUI.SetFont(, "Microsoft YaHei")

        this.ResultGUI.AddText("x20 w42 h30", "引擎").SetFont("s12")
        this.ResultGUI.AddDropDownList("x+0 w120 vTextOCREngine AltSubmit Choose" this.configs["textocr_engine"], Map2Array(Basic_TextOCREngines)).SetFont("s12")
        this.ResultGUI["TextOCREngine"].OnEvent("Change", (CtrlObj, *) => Basic_TextOCREngines[CtrlObj.Text].Call("", this.configs["image_base64"]))
        this.ResultGUI.AddText("x20 y+15 w42 h30", "语言").SetFont("s12")
        this.ResultGUI.AddDropDownList("x+0 w120 vLanguageType AltSubmit Choose" this.configs["language_type"], Map2Array(OCRC_Configs["BaiduOCR_LanguageTypes"])).SetFont("s12")
        this.ResultGUI["LanguageType"].OnEvent("Change", (CtrlObj, *) => (
            post := this.post, configs := this.configs,
            post["language_type"] := OCRC_Configs["BaiduOCR_LanguageTypes"][CtrlObj.Text], configs["language_type"] := CtrlObj.Value,
            BaiduOCR_lang := Baidu(post, configs)
        ))
        this.ResultGUI.AddText("x+15 y5 w42 h30", "排版").SetFont("s12")
        this.ResultGUI.AddDropDownList("x+0 w90 vFormatStyle AltSubmit Choose" this.configs["format_style"], ["智能段落", "合并多行", "拆分多行"]).SetFont("s12")
        this.ResultGUI["FormatStyle"].OnEvent("Change", ObjBindMethod(this, "__TextProcess", ObjBindMethod(this, "__Format"), this.ResultGUI["FormatStyle"]))
        this.ResultGUI.AddText("x197 y+15 w42 h30", "标点").SetFont("s12")
        this.ResultGUI.AddDropDownList("x+0 w90 vPunctuationStyle AltSubmit Choose" this.configs["punctuation_style"], ["智能标点", "中文标点", "英文标点"]).SetFont("s12")
        this.ResultGUI["PunctuationStyle"].OnEvent("Change", ObjBindMethod(this, "__TextProcess", ObjBindMethod(this, "__Punctuation"), this.ResultGUI["PunctuationStyle"]))
        this.ResultGUI.AddText("x+15 y5 w42 h30", "空格").SetFont("s12")
        this.ResultGUI.AddDropDownList("x+0 w90 vSpaceStyle AltSubmit Choose" this.configs["space_style"], ["智能空格", "去除空格"]).SetFont("s12")
        this.ResultGUI["SpaceStyle"].OnEvent("Change", ObjBindMethod(this, "__TextProcess", ObjBindMethod(this, "__Space"), this.ResultGUI["SpaceStyle"]))
        this.ResultGUI.AddText("x+15 y5 w55 h15", "原始语言").SetFont("s10")
        this.ResultGUI.AddDropDownList("x+0 w65 vTranslateFrom AltSubmit Choose" this.configs["translate_from"], TLs := Map2Array(TL := OCRC_Configs["TextOCR_TranslateLanguages"])).SetFont("s8")
        this.ResultGUI.AddText("x492 y+0 w55 h15", "目标语言").SetFont("s10")
        this.ResultGUI.AddDropDownList("x+0 w65 vTranslateTo AltSubmit Choose" this.configs["translate_to"], TL.Has("自动检测") ? (TLs.RemoveAt(IndexOf("自动检测", TLs)), TLs) : TLs).SetFont("s8")
        this.ResultGUI.AddButton("x492 y+0 w120 h20 vTranslate", "翻译").SetFont("s10")
        this.ResultGUI["Translate"].OnEvent("Click", ObjBindMethod(this, "__Translate"))
        this.ResultGUI.AddText("x+15 y5 w42 h30", "搜索").SetFont("s12")
        this.ResultGUI.AddDropDownList("x+0 w105 vSearchEngine AltSubmit Choose" this.configs["search_engine"], Map2Array(OCRC_Configs["TextOCR_SearchEngines"])).SetFont("s12")
        this.ResultGUI["SearchEngine"].OnEvent("Change", ObjBindMethod(this, "__Search"))
        this.ResultGUI["SearchEngine"].OnEvent("ContextMenu", ObjBindMethod(this, "__Search"))
        this.ResultGUI.AddButton("x627 y+12 w148 h28 vSave", "保存").SetFont("s12")
        this.ResultGUI["Save"].OnEvent("Click", ObjBindMethod(this, "__Save"))

        this.ResultGUI.AddEdit("x20 y70 w760 h400 vResult").SetFont("s18")
        this.ResultGUI["Result"].OnEvent("Change", ObjBindMethod(this, "__Clip"))
        this.ResultGUI["Result"].Value := this.__Process(True)

        if this.configs["probability_type"] {
            if this.probability <= 60
                probability_color := "EC4D3D"
            else if this.probability <= 80
                probability_color := "F8CD46"
            else
                probability_color := "63C956"
            this.ResultGUI.AddProgress("x20 y+10 w760 h30 c" probability_color, this.probability)
            this.ResultGUI.AddText("x20 yp w800 h30 Center BackgroundTrans", this.probability "%").SetFont("s18")
        }

        this.ResultGUI.Show("w800 h" (this.configs["probability_type"] ? 520 : 490))
    }

    __Token() {
        if !(this.configs["token"] && A_Now < this.configs["token_expiration"]) {
            return_json := JSON.parse(Request("https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=" this.configs["api_key"] "&client_secret=" this.configs["secret_key"]))
            if return_json.Has("error")
                return MsgBox(return_json["error_description"], "BaiduOCR ERROR: " return_json["error"], "Iconx 0x1000")
            else {
                IniWrite(DateAdd(A_Now, return_json["expires_in"], "Seconds"), OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_TokenExpiration")
                this.configs["token"] := return_json["access_token"]
                IniWrite(this.configs["token"], OCRC_ConfigFilePath, "BaiduOCR", "BaiduOCR_Token")
                return "success"
            }
        }
        return "success"
    }

    __Probability() {
        probability_sum := 0
        if !this.result
            return this.probability := 0
        if this.configs["probability_type"] == 1 {
            for index, value in this.json["words_result"]
                probability_sum += value["probability"]["average"] * StrLen(value["words"])
            this.probability := Format("{:.2f}", 100 * probability_sum / StrLen(this.result))
        }
        else if this.configs["probability_type"] == -1 {
            for index, value in this.json["words_result"]
                probability_sum += value["probability"]["average"]
            this.probability := Format("{:.2f}", 100 * probability_sum / this.json["words_result_num"])
        }
    }

    __TextProcess(Function, CtrlObj, *) {
        this.result := Function(CtrlObj.Value)
        this.ResultGUI["Result"].Value := this.result
        this.__Clip(this.ResultGUI["Result"])
    }

    __Format(option) {
        result := ""
        if option == 1 {
            if this.configs["recognition_type"] == "handwriting" || this.configs["recognition_type"] == "webimage" {
                for index, value in this.json["words_result"]
                    result .= value["words"] (index != this.json["words_result"].Length ? SubStr(value["words"], -1, 1) ~= "[\x{4e00}-\x{9fa5}a-zA-Z\s0-9，、—“‘「『【；《]" && SubStr(this.json["words_result"][index + 1]["words"], 1, 1) ~= "[\x{4e00}-\x{9fa5}a-zA-Z\s0-9]" ? "" : "`n" : "")
            }
            else {
                for index, value in this.json["paragraphs_result"] {
                    for idx, vl in value["words_result_idx"]
                        result .= this.json["words_result"][vl + 1]["words"]
                    result .= "`n"
                }
                result := SubStr(result, 1, StrLen(result) - 1)
            }
        }
        else if option == 2 {
            for index, value in this.json["words_result"]
                result .= value["words"]
        }
        else if option == 3 {
            for index, value in this.json["words_result"]
                result .= value["words"] "`n"
            result := SubStr(result, 1, StrLen(result) - 1)
        }
        return this.result := result
    }

    __Punctuation(option) {
        result := this.result
        if option == 1 {
            for c, e in BaiduOCR_c2ePunctuations
                result := RegExReplace(result, (c ~= "[“‘「『（【《]") ? c BaiduOCR_IsEnglishAfter : BaiduOCR_IsEnglishBefore c, e)
            for e, c in BaiduOCR_e2cPunctuations
                result := RegExReplace(result, (e ~= "[([]") ? ((e ~= "[.?()[\]]") ? "\" e : e) BaiduOCR_IsChineseAfter : BaiduOCR_IsChineseBefore ((e ~= "[.?()[\]]") ? "\" e : e), c)
            QPNumP := 1, QPNum := 1, PTR := ""
            loop parse result {
                if A_LoopField = "`"" && (SubStr(result, A_Index - 1, 1) ~= BaiduOCR_IsChinese || A_Index = 1) && (SubStr(result, A_Index + 1, 1) ~= BaiduOCR_IsChinese || A_Index = StrLen(result))
                    PTR .= Mod(QPNumP++, 2) ? "“" : "”"
                else if A_LoopField = "'" && (SubStr(result, A_Index - 1, 1) ~= BaiduOCR_IsChinese || A_Index = 1) && (SubStr(result, A_Index + 1, 1) ~= BaiduOCR_IsChinese || A_Index = StrLen(result))
                    PTR .= Mod(QPNum++, 2) ? "‘" : "’"
                else
                    PTR .= A_LoopField
            }
            result := PTR
        }
        else if option == 2 {
            for EP, CP in BaiduOCR_e2cPunctuations
                result := StrReplace(result, EP, CP)
        }
        else if option == 3 {
            for CP, EP in BaiduOCR_c2ePunctuations
                result := StrReplace(result, CP, EP)
        }
        return this.result := result
    }

    __Space(option) {
        result := this.result
        if option == 1 {
            for c, e in BaiduOCR_c2ePunctuations
                result := RegExReplace(result, " ?(" c ") ?", "$1")
            result := RegExReplace(result, "(?:[\x{4e00}-\x{9fa5}a-zA-Z])\K ?(\d[\d.:]*) ?(?=[\x{4e00}-\x{9fa5}a-zA-Z])", " $1 ")
            result := RegExReplace(result, "(?:[\x{4e00}-\x{9fa5}a-zA-Z])\K ?(\d[\d.:]*) ?(?![\x{4e00}-\x{9fa5}a-zA-Z])", " $1")
            result := RegExReplace(result, "(?<![\x{4e00}-\x{9fa5}a-zA-Z]) ?(\d[\d.:]*) ?(?=[\x{4e00}-\x{9fa5}a-zA-Z])", "$1 ")
            result := RegExReplace(result, "(?:[\x{4e00}-\x{9fa5}])\K ?([a-zA-Z][a-zA-Z-_]*) ?(?=[\x{4e00}-\x{9fa5}])", " $1 ")
            result := RegExReplace(result, "(?:[\x{4e00}-\x{9fa5}])\K ?([a-zA-Z][a-zA-Z-_]*) ?(?![\x{4e00}-\x{9fa5}])", " $1")
            result := RegExReplace(result, "(?<![\x{4e00}-\x{9fa5}]) ?([a-zA-Z][a-zA-Z-_]*) ?(?=[\x{4e00}-\x{9fa5}])", "$1 ")
            result := RegExReplace(result, "(?:[\w\d])\K ?([,.?!:;]) ?(?=[\w\d\x{4e00}-\x{9fa5}])", "$1 ")
            result := RegExReplace(result, "(?:[\w\d])?\K([([]) ?(?=[\w\d])?", "$1")
            result := RegExReplace(result, "(?:[\w\d])?\K ?([)\]])(?=[\w\d])?", "$1")
            result := RegExReplace(result, "(?:\d)\K ?([.:]) ?(?=\d)", "$1")
            PTR := "", PTRP := ""
            loop parse result, "`""
                PTR .= (Mod(A_Index, 2) ? A_LoopField : Trim(A_LoopField)) "`""
            loop parse PTR, "'"
                PTRP .= (Mod(A_Index, 2) ? A_LoopField : Trim(A_LoopField)) "'"
            result := SubStr(PTRP, 1, StrLen(PTRP) - 2)
        }
        else if option == 2
            result := StrReplace(result, A_Space)
        return this.result := result
    }

    __Translate(*) {
        result := this.result
        TranslateGUI := Gui()
        TranslateGUI.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        TranslateGUI.Title := "OCRC (BaiduOCR) 「谷歌翻译（" this.ResultGUI["TranslateFrom"].Text "->" this.ResultGUI["TranslateTo"].Text "）」翻译结果"
        TranslateGUI.BackColor := "EBEDF4"
        TranslateGUI.SetFont(, "Microsoft YaHei")
        TranslateGUI.AddText("vFocus")
        TranslateGUI["Focus"].Focus()
        TranslateGUI["Focus"].Visible := False
        TranslateGUI.AddEdit("x20 y20 w600 h300 vTranslate").SetFont("s18")
        TranslateGUI["Translate"].Value := GoogleTranslate(result, Index2Value(TL := OCRC_Configs["TextOCR_TranslateLanguages"], this.ResultGUI["TranslateFrom"].Value), Index2Value(TL, this.ResultGUI["TranslateTo"].Value), {proxy: this.configs["translate_proxy"]})
        TranslateGUI["Translate"].OnEvent("Change", (CtrlObj, *) => A_Clipboard := CtrlObj.Value)
        A_Clipboard := TranslateGUI["Translate"].Value
        TranslateGUI.Show("w640 h340")
    }

    __Search(CtrlObj, *) {
        search_engine := CtrlObj.Text, result := this.result
        if search_engine == "Everything" {
            try Run(OCRC_Configs["TextOCR_SearchEngines"]["Everything"] (DirExist(result) ? " -parent `"" : " -search `"") result "`"")
            catch
                MsgBox("Everything 路径错误", "Everything ERROR", "Iconx 0x1000")
        }
        else {
            try Run(StrReplace(OCRC_Configs["TextOCR_SearchEngines"][search_engine], "@W", result, 1))
            catch
                MsgBox("搜索引擎「" search_engine "」无效或错误", "SearchEngine ERROR", "Iconx 0x1000")
        }
        if this.configs["close_and_search"]
            this.ResultGUI.Destroy()
    }

    __Save(*) {
        if FileExist(txt := FileSelect(, , "保存识别结果")) && (overwrite := this.configs["always_overwrite"] || MsgBox("文件已存在，是否覆盖？", "OverwriteFile", "Icon? Default2 0x1000 YesNo") == "Yes")
            try FileDelete(txt)
            catch
                return MsgBox("覆盖失败", "Overwrite ERROR", "Iconx 0x1000")
        if txt && (overwrite == 1 || overwrite == "Yes")
            FileAppend(this.result, txt ".txt")
    }

    __Clip(CtrlObj, *) => (this.result := CtrlObj.Value, A_Clipboard := this.result)
}