#Include <Common>
#Include <Baidu>

Global ConfigFile := A_ScriptDir "\OCRC_config.privacy.ini"

Global Baidu_RecogTypes := ["general_basic", "accurate_basic", "handwriting", "webimage"]
Global Baidu_RecogTypesP := {"general_basic": "通用文字（标准）识别", "accurate_basic": "通用文字（高精度）识别", "handwriting": "手写文字识别", "webimage": "网络图片文字识别"}
Global IsChinese := "[\x{4e00}-\x{9fa5}]"
Global IsChineseBefore := "(?:[\x{4e00}-\x{9fa5}]\s?)\K" ; 由于回顾断言的缺陷，用 \K 代替回顾断言
Global IsChineseAfter := "(?=\s?[\x{4e00}-\x{9fa5}])"
Global IsEnglishBefore := "([\w\d]\s?)\K"
Global IsEnglishAfter := "(?=\s?[\w\d])"
Global C2EPuncs := {"，": ",", "。": ".", "？": "?", "！": "!", "、": ",", "：": ":", "；": ";", "“": """", "”": """", "‘": "'", "’": "'", "「": """", "」": """", "『": "'", "』": "'", "（": "(", "）": ")", "【": "[", "】": "]", "《": "", "》": ""}
Global E2CPuncs := {",": "，", ".": "。", "?": "？", "!": "！", ":": "：", ";": "；", "(": "（", ")": "）", "[": "【", "]": "】"}
Global Baidu_SEnginesP := ["https://www.baidu.com/s?wd=", "https://www.google.com/search?q=", "https://google.pem.app/search?q=", "https://baike.baidu.com/item/", "https://zh.wikipedia.iwiki.eu.org/wiki/"]

f7::
	success := GetScreenShot()
	if success
		return
	base64string := Img2Base()
    
    j := new Baidu({"paragraph": "true", "probability": "true"}, {"api_key": "", "secret_key": "", "imgbase64": base64string, "recogtype": "accurate_basic", "probtype": 1, "formatstyle": 1, "puncstyle": 1, "spacestyle": 1, "trantype": 1, "searchengine": 1})
    j.show()
return