﻿/************************************************************************
 * @description Optical Character Recognition Commander
 * @file OCRC.ahk
 * @author PilgrimLyieu
 * @date 2023/08/24
 * @version 2.1.0-develop
 ***********************************************************************/

;@Ahk2Exe-SetMainIcon icon\OCRC.ico

#Include <Constants>
#Include <Common>
#Include <Setting>
#Include <BaiduOCR>
#Include <MathpixOCR>
#Include <BingOCR>

if !FileExist("ahk-json.dll")
    FileInstall("lib\ahk-json.dll", "ahk-json.dll")
if !FileExist(OCRC_ConfigFilePath)
    CreateConfig()

GlobalConstants()

A_IconTip := "OCRC"
A_TrayMenu.Delete()
A_TrayMenu.Add("设置", (*) => SettingGUI())
A_TrayMenu.Add("重启", (*) => Reload())
A_TrayMenu.Add("退出", (*) => ExitApp())
A_TrayMenu.ClickCount := 1
A_TrayMenu.Default    := "设置"

global Basic_TextOCRHotkey_temp := OCRC_Configs["Basic"]["Basic_TextOCRHotkey"], Basic_FormulaOCRHotkey_temp := OCRC_Configs["Basic"]["Basic_FormulaOCRHotkey"]
if OCRC_Configs["Basic"]["Basic_TextOCROnOff"]
    Hotkey(OCRC_Configs["Basic"]["Basic_TextOCRHotkey"], Basic_TextOCRTypes[Map2Array(Basic_TextOCRTypes)[OCRC_Configs["Basic"]["Basic_TextOCRType"]]], "On")
if OCRC_Configs["Basic"]["Basic_FormulaOCROnOff"]
    Hotkey(OCRC_Configs["Basic"]["Basic_FormulaOCRHotkey"], Basic_FormulaOCRTypes[Map2Array(Basic_FormulaOCRTypes)[OCRC_Configs["Basic"]["Basic_FormulaOCRType"]]], "On")

TextOCR_BaiduOCR(ThisHotkey) {
    GlobalConstants()
    if base64string := PrepareOCR(False)
        BaiduOCR := Baidu(
            Map(
                "paragraph",     "true",
                "probability",   OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"] ? "true" : "false",
                "language_type", Map2Array(OCRC_Configs["BaiduOCR_LanguageTypes"], 0)[OCRC_Configs["BaiduOCR"]["BaiduOCR_LanguageType"]]
            ),
            Map(
                "api_key",           OCRC_Configs["BaiduOCR"]["BaiduOCR_APIKey"],
                "secret_key",        OCRC_Configs["BaiduOCR"]["BaiduOCR_SecretKey"],
                "token",             OCRC_Configs["BaiduOCR"]["BaiduOCR_Token"],
                "token_expiration",  OCRC_Configs["BaiduOCR"]["BaiduOCR_TokenExpiration"],
                "image_base64",      base64string,
                "recognition_type",  Map2Array(BaiduOCR_RecognitionTypes)[OCRC_Configs["BaiduOCR"]["BaiduOCR_RecognitionType"]],
                "probability_type",  OCRC_Configs["BaiduOCR"]["BaiduOCR_ProbabilityType"],
                "format_style",      OCRC_Configs["BaiduOCR"]["BaiduOCR_FormatStyle"],
                "punctuation_style", OCRC_Configs["BaiduOCR"]["BaiduOCR_PunctuationStyle"],
                "space_style",       OCRC_Configs["BaiduOCR"]["BaiduOCR_SpaceStyle"],
                "translate_engine",  OCRC_Configs["BaiduOCR"]["BaiduOCR_TranslateEngine"],
                "translate_proxy",   OCRC_Configs["Advance"]["Advance_GoogleTranslateProxy"],
                "translate_type",    OCRC_Configs["BaiduOCR"]["BaiduOCR_TranslateType"],
                "search_engine",     OCRC_Configs["BaiduOCR"]["BaiduOCR_SearchEngine"],
                "close_and_search",  OCRC_Configs["BaiduOCR"]["BaiduOCR_CloseAndSearch"],
            )
        )
}

FormulaOCR_MathpixOCR(ThisHotkey) {
    GlobalConstants()
    if base64string := PrepareOCR(True)
        MathpixOCR := Mathpix(
            Map(
                "math_inline_delimiters",  LaTeX_InlineStyles[OCRC_Configs["LaTeX"]["LaTeX_InlineStyle"]],
                "math_display_delimiters", LaTeX_DisplayStyles[OCRC_Configs["LaTeX"]["LaTeX_DisplayStyle"]],
                "default_select",          OCRC_Configs["LaTeX"]["LaTeX_DefaultSelect"],
            ),
            Map(
                "app_id",       OCRC_Configs["MathpixOCR"]["MathpixOCR_AppID"],
                "app_key",      OCRC_Configs["MathpixOCR"]["MathpixOCR_AppKey"],
                "image_base64", base64string,
            )
        )
}

FormulaOCR_BingOCR(ThisHotkey) {
    GlobalConstants()
    if base64string := PrepareOCR(False)
        BingOCR := Bing(
            Map(
                "image_base64", base64string,
                "math_inline_delimiters",  LaTeX_InlineStyles[OCRC_Configs["LaTeX"]["LaTeX_InlineStyle"]],
                "math_display_delimiters", LaTeX_DisplayStyles[OCRC_Configs["LaTeX"]["LaTeX_DisplayStyle"]],
                "default_select",          OCRC_Configs["LaTeX"]["LaTeX_DefaultSelect"],
            )
        )
}

!a::SettingGUI()