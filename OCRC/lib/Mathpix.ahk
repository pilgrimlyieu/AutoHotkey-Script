#Include <JSON>
#Include <Common>

class Mathpix
{
	__New(app_id, app_key, imgbase64, setting := "") {
		clipboard := ""
		headers := {"app_id": app_id
				, "app_key": app_key
				, "Content-type": "application/json"}
		postdata := {"src": imgbase64
				, "idiomatic_eqn_arrays": True
				, "formats": ["text", "latex_styled"]}
		for key, value in setting.post
			postdata[key] := value
		; msgbox % URLDownloadToVar("https://api.mathpix.com/v3/text", "UTF-8", "POST", JSON.Dump(postdata), headers)
		this.setting := setting
		this.json := Json.Load(URLDownloadToVar("https://api.mathpix.com/v3/text", "UTF-8", "POST", JSON.Dump(postdata), headers))
	}

	Show() {
		static latex_result, inline_result, display_result, result

		if this.json.error {
			MsgBox 4112, % "MathpixOCR " this.json.error_info.id, % this.json.error_info.message
			return
		}

		id := this.json.request_id ; 用于标识窗口
		confidence := Format("{:.2f}", 100 * this.json.confidence) ; 置信度
		latex_result := this.json.latex_styled ; 纯 LaTeX 结果
		inline_result := this.setting.post.math_inline_delimiters[1] latex_result this.setting.post.math_inline_delimiters[2]
		display_result := this.setting.post.math_display_delimiters[1] "`n" latex_result "`n" this.setting.post.math_display_delimiters[2] "`n"
		result := StrReplace(StrReplace(this.json.text, "\n", "`n"), "\\", "\")

		Gui %id%:New
		Gui %id%:+LabelMathpix +MinimizeBox +HwndMRW
		Gui %id%:Color, EBEDF4
		Gui %id%:Font, s18, Microsoft YaHei
		if latex_result {
			Gui %id%:Add, Text, x10 y20 w100 +Right, LaTeX
			Gui %id%:Add, Edit, x120 yp w420 h36 vlatex_result ReadOnly -Multi -VScroll, %latex_result%
			Gui %id%:Add, Text, x10 y+20 w100 +Right, 行内公式
			Gui %id%:Add, Edit, x120 yp w420 h36 vinline_result ReadOnly -Multi -VScroll, %inline_result%
			Gui %id%:Add, Text, x10 y+20 w100 +Right, 行间公式
			Gui %id%:Add, Edit, x120 yp w420 h36 vdisplay_result ReadOnly -Multi -VScroll, %display_result%
		}
		else {
			Gui %id%:Add, Text, x10 y20 w100 +Right, 识别结果
			Gui %id%:Add, Edit, x120 yp w420 h36 vresult ReadOnly -Multi -VScroll, %result%
		}
		if (confidence <= 20)
			progresscolor := "EC4D3D"
		else if (confidence <= 60)
			progresscolor := "F8CD46"
		else
			progresscolor := "63C956"
		Gui %id%:Add, Progress, x10 y+20 w580 h30 c%progresscolor%, %confidence%
		Gui %id%:Add, Text, yp w600 +Center BackgroundTrans +0x1, %confidence%`%
		if latex_result and this.setting.config.default_select
			Mathpix_FocusSelect("Edit" this.setting.config.default_select)
		else
			Mathpix_FocusSelect("Edit1")
		guiheight := latex_result ? 240 : 120
		Gui %id%:Show, w600 h%guiheight%, % "OCRC (MathpixOCR) 识别结果"
		GroupAdd Mathpix, ahk_id %MRW%
		OnMessage(0x201, "Mathpix_UpdateClip")
	}
}