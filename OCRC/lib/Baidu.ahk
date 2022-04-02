#Include <JSON>
#Include <Common>

Baidu_GetToken(BD_Key, BD_Secret) {
	BD_access_Token := ReadIni(ConfigFile, "Baidu_Token", "BaiduOCR")
	if BD_access_Token
		return BD_access_Token
	BD_Url := "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials"
	BD_Url := BD_Url "&client_id=" BD_Key "&client_secret=" BD_Secret
	BD_Json := JSON.Load(URLDownloadToVar(BD_Url))
	BD_access_Token := BD_Json.access_token
	if BD_access_Token {
		WriteIni(ConfigFile, BD_access_Token, "Baidu_Token", "BaiduOCR")
		return BD_access_Token
	}
}

Baidu_GetOCR(imgBase64, BD_access_Token, txttype) {
	BD_Url := "https://aip.baidubce.com/rest/2.0/ocr/v1/" txttype "?access_token=" BD_access_Token
	postdata := "image=" UrlEncode(imgBase64) "&paragraph=true&probability=true"
	BD_ReturnTxt := URLDownloadToVar(BD_Url, "UTF-8", "POST", postdata, {"Content-Type":"application/x-www-form-urlencoded"})
	BD_Json := JSON.Load(BD_ReturnTxt)
	if BD_Json.error_msg {
		MsgBox 4112, BaiduOCR ERROR, % BD_Json.error_msg
		Baidu_GetToken(Baidu_API_Key, Baidu_Secret_Key)
		return
	}
	return BD_Json
}

Baidu_Bitmap(base64, BD_access_Token) {
	if ReadIni(ConfigFile, "Baidu_RecogType", "BaiduOCR")
		txttype := Baidu_RecogTypes[ReadIni(ConfigFile, "Baidu_RecogType", "BaiduOCR")]
	else
		txttype := "general_basic"
	return Baidu_GetOCR(base64, BD_access_Token, txttype)
}