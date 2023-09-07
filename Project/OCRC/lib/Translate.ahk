GoogleTranslate(text, from := "auto", to := "zh-CN", configs := {}) {
    result := ""
    try for index, sentence in JSON.parse(Request("https://translate.google.com/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=" from "&tl=" to "&q=" UrlEncode(text), , , , , configs.proxy))["sentences"]
        result .= sentence["trans"]
    if !result
        try for index, sentence in JSON.parse(Request("https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=" from "&tl=" to "&q=" UrlEncode(text), , , , , configs.proxy))[1]
            result .= sentence[1]
    return result
}

TencentAuthorization(string_post_data, SecretID, SecretKey) {
    CanonicalRequest := "POST`n/`n`ncontent-type:application/json`nhost:tmt.tencentcloudapi.com`nx-tc-action:texttranslate`n`ncontent-type;host;x-tc-action`n" SHA256(string_post_data)
    StringToSign := "TC3-HMAC-SHA256`n" DateDiff(A_NowUTC, 19700101000000, "Seconds") "`n" FormatTime(A_NowUTC, "yyyy-MM-dd") "/tmt/tc3_request`n" SHA256(CanonicalRequest)
    SecretDate := SHA256HMAC(FormatTime(A_NowUTC, "yyyy-MM-dd"), "TC3" SecretKey)
    SecretService := SHA256HMAC("tmt", SecretDate)
    SecretSigning := SHA256HMAC("tc3_request", SecretService)
    Signature := SHA256HMAC(StringToSign, SecretSigning)
    return "TC3-HMAC-SHA256 Credential=" SecretID "/" FormatTime(A_NowUTC, "yyyy-MM-dd") "/tmt/tc3_request, SignedHeaders=content-type;host;x-tc-action, Signature=" Signature
}

TencentTranslate(text, from := "auto", to := "zh", configs := {}) {
    post_data := Map(
        "SourceText", text,
        "Source", from,
        "Target", to,
        "ProjectId", 0,
    )
    string_post_data := JSON.stringify(post_data)
    headers := Map(
        "HOST", "tmt.tencentcloudapi.com",
        "Content-type", "application/json",
        "X-TC-Action", "TextTranslate",
        "X-TC-Version", "2018-03-21",
        "X-TC-Region", "ap-guangzhou",
        "X-TC-Timestamp", DateDiff(A_NowUTC, 19700101000000, "Seconds"),
        "Authorization", TencentAuthorization(string_post_data, configs.secretid, configs.secretkey),
    )
    result := JSON.parse(Request("https://tmt.tencentcloudapi.com", "UTF-8", "POST", string_post_data, headers))
    try return result["Response"]["TargetText"]
    catch
        MsgBox(result["Error"]["Message"], "TencentTranslate Error" result["Error"]["Code"], "Iconx 0x1000")
}