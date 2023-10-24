GetIMELang() {
    DetectHiddenWindows True
    result := SendMessage(0x283, 0x001, 0, , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinGetID("A"), "Uint"))
    DetectHiddenWindows False
    return result
}

ChangeIMELang(code) {
    DetectHiddenWindows True
    SendMessage(0x283, 0x002, code, , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinGetID("A"), "Uint"))
    DetectHiddenWindows False
}

GetIMECompatibility() { ; 1 为兼容模式，0 为不兼容模式（即新版）
    DummyValue := RegRead("HKEY_CURRENT_USER\Software\Microsoft\CTF\TIP\{81D4E9C9-1D3B-41BC-9E6C-4B40BF79E35E}", "DummyValue")
    NoTsf3Override2 := RegRead("HKEY_CURRENT_USER\Software\Microsoft\input\tsf\tsf3override\{81d4e9c9-1d3b-41bc-9e6c-4b40bf79e35e}", "NoTsf3Override2")
    return (DummyValue == 0) && (NoTsf3Override2 == 1)
}

ChangeIMECompatibility(compatibility) {
    RegWrite(!compatibility, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\CTF\TIP\{81D4E9C9-1D3B-41BC-9E6C-4B40BF79E35E}", "DummyValue")
    RegWrite(compatibility, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\input\tsf\tsf3override\{81d4e9c9-1d3b-41bc-9e6c-4b40bf79e35e}", "NoTsf3Override2")
}

IsChinese() => GetIMELang() == 1025
IsEnglish() => (lang := GetIMELang()) == 0 || lang == 1024 ; 微软拼音输入法下英文模式为 1024
Switch2Chinese() => ChangeIMELang(1025)
Switch2English() => ChangeIMELang(GetIMECompatibility() ? 1024 : 0)

IsShuangpin() => RegRead("HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS", "Enable Double Pinyin")