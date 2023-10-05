/************************************************************************
 * @description Optical Character Recognition Commander
 * @file OCRC.ahk
 * @author PilgrimLyieu
 * @date 2023/10/05
 * @version 2.2.2
 ***********************************************************************/

;@Ahk2Exe-SetMainIcon icon\OCRC.ico

#ErrorStdOut UTF-8

if !FileExist("ahk-json.dll")
    FileInstall("lib\ahk-json.dll", "ahk-json.dll")

#Include <Constants>
#Include <Common>
#Include <Setting>
#Include <BaiduOCR>
#Include <MathpixOCR>
#Include <BingOCR>

if !FileExist(OCRC_ConfigFilePath)
    CreateConfig()

GlobalConstants()

A_IconTip := "OCRC"
A_TrayMenu.Delete()
A_TrayMenu.Add("OCRC 设置", SettingGUI)
A_TrayMenu.Add("OCR 引擎设置", OCREnginesGUI)
A_TrayMenu.Add("导入图片", FileTextOCR)
A_TrayMenu.Add("导入文件夹", DirectoryTextOCR)
A_TrayMenu.Add("重启", (*) => Reload())
A_TrayMenu.Add("退出", (*) => ExitApp())
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default    := "OCRC 设置"

global Basic_TextOCRHotkey_temp := OCRC_Configs["Basic"]["Basic_TextOCRHotkey"], Basic_FormulaOCRHotkey_temp := OCRC_Configs["Basic"]["Basic_FormulaOCRHotkey"]
if OCRC_Configs["Basic"]["Basic_TextOCROnOff"]
    Hotkey(OCRC_Configs["Basic"]["Basic_TextOCRHotkey"], Basic_TextOCREngines[Map2Array(Basic_TextOCREngines)[OCRC_Configs["Basic"]["Basic_TextOCREngine"]]], "On")
if OCRC_Configs["Basic"]["Basic_FormulaOCROnOff"]
    Hotkey(OCRC_Configs["Basic"]["Basic_FormulaOCRHotkey"], Basic_FormulaOCREngines[Map2Array(Basic_FormulaOCREngines)[OCRC_Configs["Basic"]["Basic_FormulaOCREngine"]]], "On")

TextOCR_BaiduOCR(ThisHotkey, image := 0, show := 1) {
    GlobalConstants()
    if image || base64string := PrepareOCR(False)
        return BaiduOCR := Baidu(
            Map(
                "paragraph",     "true",
                "probability",   OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"] ? "true" : "false",
                "language_type", Map2Array(OCRC_Configs["BaiduOCR_LanguageTypes"], 0)[OCRC_Configs["BaiduOCR"]["BaiduOCR_LanguageType"]]
            ),
            Map(
                "textocr_engine",    1,
                "show",              show,
                "api_key",           OCRC_Configs["BaiduOCR"]["BaiduOCR_APIKey"],
                "secret_key",        OCRC_Configs["BaiduOCR"]["BaiduOCR_SecretKey"],
                "token",             OCRC_Configs["BaiduOCR"]["BaiduOCR_Token"],
                "token_expiration",  OCRC_Configs["BaiduOCR"]["BaiduOCR_TokenExpiration"],
                "image_base64",      image || base64string,
                "language_type",     OCRC_Configs["BaiduOCR"]["BaiduOCR_LanguageType"],
                "recognition_type",  Map2Array(BaiduOCR_RecognitionTypes)[OCRC_Configs["BaiduOCR"]["BaiduOCR_RecognitionType"]],
                "probability_type",  OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"],
                "format_style",      OCRC_Configs["TextOCR"]["TextOCR_FormatStyle"],
                "punctuation_style", OCRC_Configs["TextOCR"]["TextOCR_PunctuationStyle"],
                "space_style",       OCRC_Configs["TextOCR"]["TextOCR_SpaceStyle"],
                "translate_proxy",   OCRC_Configs["Advance"]["Advance_GoogleTranslateProxy"],
                "translate_from",    OCRC_Configs["TextOCR"]["TextOCR_TranslateFrom"],
                "translate_to",      OCRC_Configs["TextOCR"]["TextOCR_TranslateTo"],
                "search_engine",     OCRC_Configs["TextOCR"]["TextOCR_SearchEngine"],
                "close_and_search",  OCRC_Configs["TextOCR"]["TextOCR_CloseAndSearch"],
                "always_overwrite",  OCRC_Configs["TextOCR"]["TextOCR_AlwaysOverwrite"],
            )
        )
}

FormulaOCR_BingOCR(ThisHotkey, image := 0, show := 1) {
    GlobalConstants()
    if image || base64string := PrepareOCR(False)
        return BingOCR := Bing(
            Map(
                "formulaocr_engine",       1,
                "show",                    show,
                "image_base64",            (image ~= "^data:image/jpg;base64,") ? SubStr(image, 23) : image || base64string,
                "math_inline_delimiters",  FormulaOCR_InlineStyles[OCRC_Configs["FormulaOCR"]["FormulaOCR_InlineStyle"]],
                "math_display_delimiters", FormulaOCR_DisplayStyles[OCRC_Configs["FormulaOCR"]["FormulaOCR_DisplayStyle"]],
                "default_select",          OCRC_Configs["FormulaOCR"]["FormulaOCR_DefaultSelect"],
            )
        )
}

FormulaOCR_MathpixOCR(ThisHotkey, image := 0, show := 1) {
    GlobalConstants()
    if image || base64string := PrepareOCR(True)
        return MathpixOCR := Mathpix(
            Map(
                "formulaocr_engine",       2,
                "show",                    show,
                "app_id",                  OCRC_Configs["MathpixOCR"]["MathpixOCR_AppID"],
                "app_key",                 OCRC_Configs["MathpixOCR"]["MathpixOCR_AppKey"],
                "image_base64",            (image ~= "^data:image/jpg;base64,") ? image : image ? "data:image/jpg;base64," image : base64string,
                "math_inline_delimiters",  FormulaOCR_InlineStyles[OCRC_Configs["FormulaOCR"]["FormulaOCR_InlineStyle"]],
                "math_display_delimiters", FormulaOCR_DisplayStyles[OCRC_Configs["FormulaOCR"]["FormulaOCR_DisplayStyle"]],
                "default_select",          OCRC_Configs["FormulaOCR"]["FormulaOCR_DefaultSelect"],
            )
        )
}