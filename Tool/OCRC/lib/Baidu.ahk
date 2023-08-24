class Baidu {
    __New(post, config) {
        this.config := config
        if this.__Token() != "success"
            return
        post_data := "image=" UrlEncode(this.config.imgbase64)
        for key, value in post
            post_data .= "&" key "=" value
        this.json := JSON.parse(Request("https://aip.baidubce.com/rest/2.0/ocr/v1/" this.config.recogtype "?access_token=" this.token, "UTF-8", "POST", post_data, Map("Content-Type", "application/x-www-form-urlencoded")))
        this.__Show()
    }

    __Show() {
        if this.json.error_msg
            return MsgBox(this.json.error_msg, "BaiduOCR ERROR", "Iconx 0x1000")

        id                := "BaiduOCR" this.json.log_id
        format_style      := this.config.formatstyle
        punctuation_style := this.config.puncstyle
        space_style       := this.config.spacestyle
        translation_type  := this.config.trantype
        search_engine     := this.config.searchengine

        this.__Format()
        if this.config.probtype
            this.__Prob()
        this.__Punc()
        this.__Space()

        %id% := Gui(, id).OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
        %id%.Title := "OCRC (BaiduOCR) 「" Baidu_RecogTypesP[this.config.recogtype] "」识别结果"
        %id%.BackColor := "EBEDF4"
        %id%.SetFont(, "Microsoft YaHei")

        ; TODO Add `OnEvent` instead of the function of `__Update`.
        %id%.AddText("x20", "排版").SetFont("s16")
        %id%.AddDropDownList("x+5 w90 vFormatStyle AltSubmit Choose" format_style, ["智能段落", "合并多行", "拆分多行"]).SetFont("s12")
        %id%.AddText("x+15", "标点").SetFont("s16")
        %id%.AddDropDownList("x+5 w90 vPunctuationStyle AltSubmit Choose" punctuation_style, ["智能标点", "原始结果", "中文标点", "英文标点"]).SetFont("s12")
        %id%.AddText("x+15", "空格").SetFont("s16")
        %id%.AddDropDownList("x+5 w90 vSpaceStyle AltSubmit Choose" space_style, ["智能空格", "原始结果", "去除空格"]).SetFont("s12")
        %id%.AddText("x+15", "翻译").SetFont("s16")
        %id%.AddDropDownList("x+5 w90 vTranslationStyle AltSubmit Choose" translation_type, ["自动检测", "英->中", "中->英", "繁->简", "日->中"]).SetFont("s12")
        ; TODO Add Everything judgement(in main program), import arrays from class params.
        %id%.AddText("x+15", "搜索").SetFont("s16")
        %id%.AddDropDownList("x+5 w105 vSearchEngine AltSubmit Choose" search_engine, ["百度搜索", "必应搜索", "谷歌搜索", "百度百科", "Everything"]).SetFont("s12")

        %id%.AddEdit("x20 y50 w760 h400 vResult", "this.result").SetFont("s18")

        if this.config.probtype {
            if this.probability <= 60
                probability_color := "EC4D3D"
            else if this.probability <= 80
                probability_color := "F8CD46"
            else
                probability_color := "63C956"
            %id%.AddProgress("x20 y+10 w760 h30 c" probability_color, this.probability)
            %id%.AddText("yp w800 Center BackgroundTrans", this.probability "%")
        }

        %id%.Show("w800 h" this.config.probtype ? 500 : 470)
    }

    __Token() {
        this.token := IniRead(OCRC_ConfigFilePath, "Baidu_Token", "BaiduOCR")
        this.token_expiration := IniRead(OCRC_ConfigFilePath, "Baidu_TokenExpiration", "BaiduOCR")
        if !(this.token && A_Now < this.token_expiration) {
            return_json := JSON.parse(Request("https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=" this.config.api_key "&client_secret=" this.config.secret_key))
            if return_json.error
                return MsgBox(return_json.error_description, "BaiduOCR ERROR: " return_json.error, "Iconx 0x1000")
            else {
                IniWrite(DateAdd(A_Now, return_json.expires_in, "Seconds"), OCRC_ConfigFilePath, "BaiduOCR", "Baidu_TokenExpiration")
                this.token := return_json.access_token
                IniWrite(this.token, OCRC_ConfigFilePath, "BaiduOCR", "Baidu_Token")
                return "success"
            }
        }
        return "success"
    }

    __Prob() {
        probadd := 0
        if this.config.probtype == 1 {
            for index, value in this.json.words_result
                probadd += value.probability.average * StrLen(value.words)
            this.probability := Format("{:.2f}", 100 * probadd / StrLen(this.result))
        }
        else {
            for index, value in this.json.words_result
                probadd += value.probability.average
            this.probability := Format("{:.2f}", 100 * probadd / this.json.words_result_num)
        }
    }

    __Format(hwnd) {
        if hwnd
            GuiControlGet formatstyle, , %hwnd%
        else
            formatstyle := this.config.formatstyle

        if (formatstyle = 1) {
            for index, value in this.json.paragraphs_result {
                for idx, vl in value.words_result_idx
                    result .= this.json.words_result[vl + 1].words
                result .= "`n"
            }
            result := SubStr(result, 1, StrLen(result) - 1)
        }
        else if (formatstyle = 2) {
            for index, value in this.json.words_result
                result .= value.words
        }
        else if (formatstyle = 3) {
            for index, value in this.json.words_result
                result .= value.words "`n"
            result := SubStr(result, 1, StrLen(result) - 1)
        }

        this.result     := result
        this.resulttemp := result
        if hwnd
            GuiControl Text, % this.mainhwnd, % result
        this.__Clip()
    }

    __Punc(hwnd) {
        if hwnd
            GuiControlGet puncstyle, , %hwnd%
        else
            puncstyle := this.config.puncstyle
        result := this.result

        if (puncstyle = 1) {
            for c, e in Baidu_C2EPuncs
                result := RegExReplace(result, (c ~= "[“‘「『（【《]") ? c Baidu_IsEnglishAfter : Baidu_IsEnglishBefore c, e)
            for e, c in Baidu_E2CPuncs
                result := RegExReplace(result, (e ~= "[([]") ? ((e ~= "[.?()[\]]") ? "\" e : e) Baidu_IsChineseAfter : Baidu_IsChineseBefore ((e ~= "[.?()[\]]") ? "\" e : e), c)
            QPNumP := 1, QPNum := 1
            loop parse, result
            {
                if (A_LoopField = """" and (SubStr(result, A_Index - 1, 1) ~= Baidu_IsChinese or A_Index = 1) and (SubStr(result, A_Index + 1, 1) ~= Baidu_IsChinese or A_Index = StrLen(result)))
                    PTR .= Mod(QPNumP ++, 2) ? "“" : "”"
                else if (A_LoopField = "'" and (SubStr(result, A_Index - 1, 1) ~= Baidu_IsChinese or A_Index = 1) and (SubStr(result, A_Index + 1, 1) ~= Baidu_IsChinese or A_Index = StrLen(result)))
                    PTR .= Mod(QPNum ++, 2) ? "‘" : "’"
                else
                    PTR .= A_LoopField
            }
            result := PTR
        }
        else if (puncstyle = 2)
            result := this.resultspacetemp ? this.resultspacetemp : this.resulttemp
        else if (puncstyle = 3) {
            for EP, CP in Baidu_E2CPuncs
                result := StrReplace(result, EP, CP)
        }
        else if (puncstyle = 4) {
            for CP, EP in Baidu_C2EPuncs
                result := StrReplace(result, CP, EP)
        }

        this.resultpunctemp := result
        this.result         := result
        if hwnd
            GuiControl Text, % this.mainhwnd, % result
        this.__Clip()
    }

    __Space(hwnd) {
        if hwnd
            GuiControlGet spacestyle, , %hwnd%
        else
            spacestyle := this.config.spacestyle
        result := this.result

        if (spacestyle = 1) {
            for c, e in Baidu_C2EPuncs
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
            loop parse, result, "
            {
                if Mod(A_Index, 2)
                    PTR .= A_LoopField """"
                else
                    PTR .= Trim(A_LoopField) """"
            }
            loop parse, PTR, '
            {
                if Mod(A_Index, 2)
                    PTRP .= A_LoopField "'"
                else
                    PTRP .= Trim(A_LoopField) "'"
            }
            result := SubStr(PTRP, 1, StrLen(PTRP) - 2)
        }
        else if (spacestyle = 2)
            result := this.resultpunctemp ? this.resultpunctemp : this.resulttemp
        else if (spacestyle = 3)
            result := StrReplace(result, A_Space)

        this.resultspacetemp := result
        this.result          := result
        if hwnd
            GuiControl Text, % this.mainhwnd, % result
        this.__Clip()
    }

    __Tran(hwnd) {
        ; TODO
        return
    }

    __Search(hwnd) {
        if hwnd
            GuiControlGet search_engine, , %hwnd%
        else
            search_engine := this.config.searchengine
        result := this.result

        if search_engine == 7 {
            if InStr(FileExist(result), "D")
                Run(this.config.everythingpath " -parent `"" result "`"")
            else
                Run(this.config.everythingpath " -search `"" result "`"")
        }
        else
            try Run Baidu_SearchEngines[search_engine] result
    }

    __Clip(hwnd) {
        Clipboard := ""
        if hwnd {
            GuiControlGet result, , %hwnd%
            this.result := result
        }
        Clipboard := this.result
    }
}