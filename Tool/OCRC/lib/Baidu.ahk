class Baidu {
    __New(post := "", config := "") {
        Clipboard   := ""
        this.config := config
        this.__Token()
        postdata := "image=" UrlEncode(this.config.imgbase64)
        for key, value in post
            postdata .= "&" key "=" value
        this.json := JSON.Load(URLDownloadToVar("https://aip.baidubce.com/rest/2.0/ocr/v1/" this.config.recogtype "?access_token=" this.token, "UTF-8", "POST", postdata, {"Content-Type":"application/x-www-form-urlencoded"}))
        this.__Show()
    }

    __Show() {
        if this.json.error_msg {
            MsgBox 4112, BaiduOCR ERROR, % this.json.error_msg
            return
        }

        id           := "baidu" this.json.log_id
        formatstyle  := this.config.formatstyle
        puncstyle    := this.config.puncstyle
        spacestyle   := this.config.spacestyle
        trantype     := this.config.trantype
        searchengine := this.config.searchengine

        this.__Format()
        if this.config.probtype
            this.__Prob()
        this.__Punc()
        this.__Space()

        Gui %id%:New,   % "+Label" this.__Class ".Gui"
        Gui %id%:+MinimizeBox
        Gui %id%:Color, EBEDF4
        Gui %id%:Font,  s16, Microsoft YaHei

        Gui %id%:Add,  Text, x20, 排版
        Gui %id%:Font, s12
        Gui %id%:Add,  DropDownList, x+5 w90 hwndformathwnd AltSubmit Choose%formatstyle%, 智能段落|合并多行|拆分多行
        this.formathwnd := formathwnd
        this.__Update(formathwnd, "__Format")

        Gui %id%:Font, s16
        Gui %id%:Add,  Text, x+15, 标点
        Gui %id%:Font, s12
        Gui %id%:Add,  DropDownList, x+5 w90 hwndpunchwnd AltSubmit Choose%puncstyle%, 智能标点|原始结果|中文标点|英文标点
        this.punchwnd := punchwnd
        this.__Update(punchwnd, "__Punc")

        Gui %id%:Font, s16
        Gui %id%:Add,  Text, x+15, 空格
        Gui %id%:Font, s12
        Gui %id%:Add,  DropDownList, x+5 w90 hwndspacehwnd AltSubmit Choose%spacestyle%, 智能空格|原始结果|去除空格
        this.spacehwnd := spacehwnd
        this.__Update(spacehwnd, "__Space")

        Gui %id%:Font, s16
        Gui %id%:Add,  Text, x+15, 翻译
        Gui %id%:Font, s12
        Gui %id%:Add,  DropDownList, x+5 w90 hwndtranhwnd AltSubmit Choose%trantype%, 自动检测|英->中|中->英|繁->简|日->中
        this.tranhwnd := tranhwnd
        this.__Update(tranhwnd, "__Tran")

        Gui %id%:Font, s16
        Gui %id%:Add,  Text, x+15, 搜索
        Gui %id%:Font, s12
        if (this.config.everything and this.config.everythingpath)
            Gui %id%:Add, DropDownList, x+5 w105 hwndsearchhwnd AltSubmit Choose%searchengine%, 百度搜索|必应搜索|谷歌搜索|谷歌镜像|百度百科|维基镜像|Everything
        else {
            searchengine := (searchengine = 7) ? 1 : searchengine
            Gui %id%:Add, DropDownList, x+5 w105 hwndsearchhwnd AltSubmit Choose%searchengine%, 百度搜索|必应搜索|谷歌搜索|谷歌镜像|百度百科|维基镜像
        }
        this.searchhwnd := searchhwnd
        this.__Update(searchhwnd, "__Search")

        Gui %id%:Font, s18
        Gui %id%:Add,  Edit, x20 y50 w760 h400 hwndmainhwnd, % this.result
        this.mainhwnd := mainhwnd
        this.__Update(mainhwnd, "__Clip")

        if this.config.probtype {
            if (this.probability <= 60)
                progresscolor := "EC4D3D"
            else if (this.probability <= 80)
                progresscolor := "F8CD46"
            else
                progresscolor := "63C956"
            Gui %id%:Add, Progress, x20 y+10 w760 h30 c%progresscolor%,   % this.probability
            Gui %id%:Add, Text,     yp w800 +Center BackgroundTrans +0x1, % this.probability "%"
        }
        guiheight := this.config.probtype ? 500 : 470
        Gui %id%:Show, w800 h%guiheight%, % "OCRC (BaiduOCR) 「" Baidu_RecogTypesP[this.config.recogtype] "」识别结果"
    }

    __Update(hwnd, func) {
        bindfunc := ObjBindMethod(this, func)
        GuiControl +g, %hwnd%, %bindfunc%
    }

    __Token() {
        this.token            := ReadIni(ConfigFile, "Baidu_Token", "BaiduOCR")
        this.token_expiration := ReadIni(ConfigFile, "Baidu_TokenExpiration", "BaiduOCR")
        if !(this.token and A_Now < this.token_expiration) {
            returnjson := JSON.Load(URLDownloadToVar("https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=" this.config.api_key "&client_secret=" this.config.secret_key))
            if returnjson.error
                MsgBox 4112, % "BaiduOCR " returnjson.error, % returnjson.error_description
            else {
                expiration += returnjson.expires_in, seconds
                IniWrite %expiration%, %ConfigFile%, BaiduOCR, Baidu_TokenExpiration
            }
            this.token := returnjson.access_token
            IniWrite % this.token, %ConfigFile%, BaiduOCR, Baidu_Token
        }
    }

    __Prob() {
        if (this.config.probtype = 1) {
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

    __Format(hwnd := "") {
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

    __Punc(hwnd := "") {
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

    __Space(hwnd := "") {
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

    __Tran(hwnd := "") {
        ; TODO
        return
    }

    __Search(hwnd := "") {
        if hwnd
            GuiControlGet searchengine, , %hwnd%
        else
            searchengine := this.config.searchengine
        result := this.result

        if (searchengine = 7) {
            if (!(result ~= "[*?""<>|]") and result ~= "[C-G]:(?:[\\/].+)+")
                Run % this.config.everythingpath " -path """ result """"
            else if result
                Run % this.config.everythingpath " -search """ result """"
            else
                Run % this.config.everythingpath " -home """
        }
        else {
            Run % Baidu_SearchEngines[searchengine] result
            if (searchengine = 4)
                MsgBox 4144, 警告, 请勿在镜像站输入隐私信息！
        }
    }

    __Clip(hwnd := "") {
        Clipboard := ""
        if hwnd {
            GuiControlGet result, , %hwnd%
            this.result := result
        }
        Clipboard := this.result
    }

    GuiEscape() {
        Gui Destroy
    }
}
