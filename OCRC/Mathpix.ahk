#Include <JSON>
#Include <Common>
#Include <Mathpix>

Global Mathpix_InlineStyles := ["$RAW$", "\(RAW\)"]
Global Mathpix_DisplayStyles := ["$$RAW$$", "\[RAW\]"]
Global Mathpix_InlineStyle := 1
Global Mathpix_DisplayStyle := 1

f7::
	success := GetScreenShot()
	if success
		return
	base64string := Img2Base(True)
    
    j := new Mathpix({"math_inline_delimiters" : ["$", "$"], "math_display_delimiters" : ["$$", "$$"]}, {"app_id": "", "app_key": "", "imgbase64": base64string, "default_select": 2})
    j.show()
return