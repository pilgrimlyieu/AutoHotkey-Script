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
    
    j := new Mathpix("", "", base64string, {"post": {"math_inline_delimiters" : ["$", "$"], "math_display_delimiters" : ["$$", "$$"]}, "config": {"default_select": 2}})
    j.show()
return