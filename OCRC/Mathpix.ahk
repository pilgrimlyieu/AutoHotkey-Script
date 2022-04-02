#Include <JSON>
#Include <Common>
#Include <Mathpix>

f7::
	clipboard := ""
	Send {f8}
	Sleep 500
	WinWaitNotActive Snipper - Snipaste, , 10
	if ErrorLevel {
		Send {Esc}
		return
	}
	ClipWait 1, 1
	if ErrorLevel
		return

	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmapFromClipboard()
	base64string := "data:image/jpg;base64," Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
    
    j := new Mathpix("", "", base64string, {"math_inline_delimiters" : ["$", "$"], "math_display_delimiters" : ["$$", "$$"]})
    j.show()
return