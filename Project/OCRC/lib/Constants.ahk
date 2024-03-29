global OCRC_ConfigFilePath       := "OCRC.ini"
global OCRC_Configs              := Map()

global Basic_TextOCREngines        := Map(
    "百度 OCR", TextOCR_BaiduOCR,
)
global Basic_FormulaOCREngines     := Map(
    "Mathpix OCR", FormulaOCR_MathpixOCR,
    "Bing OCR", FormulaOCR_BingOCR,
)
global Basic_Base64HaveFront       := Map(
    "百度 OCR", False,
    "Mathpix OCR", True,
    "Bing OCR", False,
)

global FormulaOCR_InlineStyles        := [
    ["$", "$"],
    ["\(", "\)"],
]
global FormulaOCR_DisplayStyles       := [
    ["$$", "$$"],
    ["\[", "\]"],
]

global BaiduOCR_RecognitionTypes := Map(
    "general_basic",  "通用文字（标准）识别",
    "accurate_basic", "通用文字（高精度）识别",
    "handwriting",    "手写文字识别",
    "webimage",       "网络图片文字识别",
)
global BaiduOCR_IsChinese        := "[\x{4e00}-\x{9fa5}]"
global BaiduOCR_IsChineseBefore  := "(?:[\x{4e00}-\x{9fa5}]\s?)\K"
global BaiduOCR_IsChineseAfter   := "(?=\s?[\x{4e00}-\x{9fa5}])"
global BaiduOCR_IsEnglishBefore  := "([\w\d]\s?)\K"
global BaiduOCR_IsEnglishAfter   := "(?=\s?[\w\d])"
global BaiduOCR_c2ePunctuations  := Map(
    "，", ",",
    "。", ".",
    "？", "?",
    "！", "!",
    "、", ",",
    "：", ":",
    "；", ";",
    "“",  "`"",
    "”",  "`"",
    "‘",  "'",
    "’",  "'",
    "「", "`"",
    "」", "`"",
    "『", "'",
    "』", "'",
    "（", "(",
    "）", ")",
    "【", "[",
    "】", "]",
    "《", "",
    "》", "",
)
global BaiduOCR_e2cPunctuations  := Map(
    ",", "，",
    ".", "。",
    "?", "？",
    "!", "！",
    ":", "：",
    ";", "；",
    "(", "（",
    ")", "）",
    "[", "【",
    "]", "】",
)