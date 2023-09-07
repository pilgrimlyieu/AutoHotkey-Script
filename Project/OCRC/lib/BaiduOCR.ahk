﻿class Baidu {
    __New(post, configs) {
        this.configs := configs
        if this.__Token() != "success"
            return
        post_data := "image=" UrlEncode(this.configs["image_base64"])
        for key, value in post
            post_data .= "&" key "=" value
        this.json := JSON.parse(Request("https://aip.baidubce.com/rest/2.0/ocr/v1/" this.configs["recognition_type"] "?access_token=" this.configs["token"], "UTF-8", "POST", post_data, Map("Content-Type", "application/x-www-form-urlencoded")))
        if this.json.Has("error_msg")
            return MsgBox(this.json["error_msg"], "BaiduOCR ERROR", "Iconx 0x1000")
        this.__Show()
    }

    __Show() {
        this.ResultGUI := Gui()
        this.ResultGUI.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        this.ResultGUI.Title := "OCRC (BaiduOCR) 「" BaiduOCR_RecognitionTypes[this.configs["recognition_type"]] "」识别结果"
        this.ResultGUI.BackColor := "EBEDF4"
        this.ResultGUI.SetFont(, "Microsoft YaHei")

        this.ResultGUI.AddText("x20 w42 h30", "排版").SetFont("s16")
        this.ResultGUI.AddDropDownList("x+5 w90 vFormatStyle AltSubmit Choose" this.configs["format_style"], ["智能段落", "合并多行", "拆分多行"]).SetFont("s12")
        this.ResultGUI["FormatStyle"].OnEvent("Change", ObjBindMethod(this, "__Format"))
        this.ResultGUI.AddText("x+15 w42 h30", "标点").SetFont("s16")
        this.ResultGUI.AddDropDownList("x+5 w90 vPunctuationStyle AltSubmit Choose" this.configs["punctuation_style"], ["智能标点", "原始结果", "中文标点", "英文标点"]).SetFont("s12")
        this.ResultGUI["PunctuationStyle"].OnEvent("Change", ObjBindMethod(this, "__Punctuation"))
        this.ResultGUI.AddText("x+15 w42 h30", "空格").SetFont("s16")
        this.ResultGUI.AddDropDownList("x+5 w90 vSpaceStyle AltSubmit Choose" this.configs["space_style"], ["智能空格", "原始结果", "去除空格"]).SetFont("s12")
        this.ResultGUI["SpaceStyle"].OnEvent("Change", ObjBindMethod(this, "__Space"))
        this.ResultGUI.AddText("x+15 w42 h30", "翻译").SetFont("s16")
        this.ResultGUI.AddDropDownList("x+5 w90 vTranslateType AltSubmit Choose" this.configs["translate_type"], ["自动检测", "英->中", "中->英", "繁->简", "日->中"]).SetFont("s12")
        this.ResultGUI["TranslateType"].OnEvent("Change", ObjBindMethod(this, "__Translate"))
        this.ResultGUI["TranslateType"].OnEvent("ContextMenu", ObjBindMethod(this, "__Translate"))
        this.ResultGUI.AddText("x+15 w42 h30", "搜索").SetFont("s16")
        this.ResultGUI.AddDropDownList("x+5 w105 vSearchEngine AltSubmit Choose" this.configs["search_engine"], Map2Array(OCRC_Configs["BaiduOCR_SearchEngines"])).SetFont("s12")
        this.ResultGUI["SearchEngine"].OnEvent("Change", ObjBindMethod(this, "__Search"))
        this.ResultGUI["SearchEngine"].OnEvent("ContextMenu", ObjBindMethod(this, "__Search"))

        this.ResultGUI.AddEdit("x20 y50 w760 h400 vResult").SetFont("s18")
        this.ResultGUI["Result"].OnEvent("Change", ObjBindMethod(this, "__Clip"))
        this.__Format(this.ResultGUI["FormatStyle"])
        if this.configs["probability_type"]
            this.__Probability()
        this.__Punctuation(this.ResultGUI["PunctuationStyle"])
        this.__Space(this.ResultGUI["SpaceStyle"])

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

        this.ResultGUI.Show("w800 h" (this.configs["probability_type"] ? 500 : 470))
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
        else {
            for index, value in this.json["words_result"]
                probability_sum += value["probability"]["average"]
            this.probability := Format("{:.2f}", 100 * probability_sum / this.json["words_result_num"])
        }
    }

    __Format(CtrlObj, *) {
        format_style := CtrlObj.Value, result := ""
        if format_style == 1 {
            for index, value in this.json["paragraphs_result"] {
                for idx, vl in value["words_result_idx"]
                    result .= this.json["words_result"][vl + 1]["words"]
                result .= "`n"
            }
            result := SubStr(result, 1, StrLen(result) - 1)
        }
        else if format_style == 2 {
            for index, value in this.json["words_result"]
                result .= value["words"]
        }
        else if format_style == 3 {
            for index, value in this.json["words_result"]
                result .= value["words"] "`n"
            result := SubStr(result, 1, StrLen(result) - 1)
        }

        this.result := result, this.result_temp := result
        this.ResultGUI["Result"].Value := this.result
        this.__Clip(this.ResultGUI["Result"])
    }

    __Punctuation(CtrlObj, *) {
        punctuation_style := CtrlObj.Value, result := this.result
        if punctuation_style == 1 {
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
        else if punctuation_style == 2
            result := HasProp(this, "result_space_temp") ? this.result_space_temp : this.result_temp
        else if punctuation_style == 3 {
            for EP, CP in BaiduOCR_e2cPunctuations
                result := StrReplace(result, EP, CP)
        }
        else if punctuation_style == 4 {
            for CP, EP in BaiduOCR_c2ePunctuations
                result := StrReplace(result, CP, EP)
        }

        this.result := result, this.result_punctuation_temp := result
        this.ResultGUI["Result"].Value := this.result
        this.__Clip(this.ResultGUI["Result"])
    }

    __Space(CtrlObj, *) {
        space_style := CtrlObj.Value, result := this.result
        if space_style == 1 {
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
        else if space_style == 2
            result := HasProp(this, "result_punctuation_temp") ? this.result_punctuation_temp : this.result_temp
        else if space_style == 3
            result := StrReplace(result, A_Space)

        this.result := result, this.result_space_temp := result
        this.ResultGUI["Result"].Value := this.result
        this.__Clip(this.ResultGUI["Result"])
    }

    __Translate(CtrlObj, *) {
        translate_engine := Map2Array(BaiduOCR_TranslateEngines)[this.configs["translate_engine"]], translate_type := CtrlObj.Text, result := this.result
        TranslateGUI := Gui()
        TranslateGUI.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        TranslateGUI.Title := "OCRC (BaiduOCR) 「" translate_engine "（" translate_type "）」翻译结果"
        TranslateGUI.BackColor := "EBEDF4"
        TranslateGUI.SetFont(, "Microsoft YaHei")
        TranslateGUI.AddEdit("x20 y20 w600 h300 vTranslate").SetFont("s18")
        TranslateGUI["Translate"].Value := BaiduOCR_TranslateEngines[translate_engine].Call(result, BaiduOCR_TranslateTypes[translate_type][1], BaiduOCR_TranslateTypes[translate_type][2], {proxy: this.configs["translate_proxy"]})
        TranslateGUI["Translate"].OnEvent("Change", (CtrlObj, *) => A_Clipboard := CtrlObj.Value)
        A_Clipboard := TranslateGUI["Translate"].Value
        TranslateGUI.Show("w640 h340")
    }

    __Search(CtrlObj, *) {
        search_engine := CtrlObj.Text, result := this.result
        if search_engine == "Everything" {
            try Run(OCRC_Configs["BaiduOCR_SearchEngines"]["Everything"] (DirExist(result) ? " -parent `"" : " -search `"") result "`"")
            catch
                MsgBox("Everything 路径错误", "Everything ERROR", "Iconx 0x1000")
        }
        else {
            try Run(StrReplace(OCRC_Configs["BaiduOCR_SearchEngines"][search_engine], "@W", result, 1))
            catch
                MsgBox("搜索引擎「" search_engine "」无效或错误", "SearchEngine ERROR", "Iconx 0x1000")
        }
        if this.configs["close_and_search"]
            this.ResultGUI.Destroy()
    }

    __Clip(CtrlObj, *) => (this.result := CtrlObj.Value, A_Clipboard := this.result)
}