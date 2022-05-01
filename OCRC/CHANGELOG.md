# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/lang/zh-CN/).

- [1.2.2 [release]](#122-releasehttpsgithubcompilgrimlyieuautohotkey-scriptreleasestagocrc-v122-2022-05-01)
- [1.2.1 [release]](#121-releasehttpsgithubcompilgrimlyieuautohotkey-scriptreleasestagocrc-v121-2022-04-23)
- [1.2.0 [release]](#120-first-released-version-releasehttpsgithubcompilgrimlyieuautohotkey-scriptreleasestagocrc-v120-2022-04-16)
- [1.1.3](#113-2022-04-05)
- [1.1.2](#112-2022-04-04)
- [1.1.1](#111-2022-04-04)
- [1.1.0](#110-2022-04-04)
- [1.0.0](#100-2022-04-03)

## [1.2.2] [[release](https://github.com/pilgrimlyieu/AutoHotkey-Script/releases/tag/OCRC-v1.2.2)] (2022-05-01)

### Changed

- General
  - Change clipboard wait time from 0.001s to 0.1s
  - Rename icon name from "OCRC_icon.ico" to "OCRC.ico"
- Baidu
  - Calculate probability before formatting punctuation and space
- Mathpix
  - Show TextResult only when it is different from InlineResult and it doesn't contain "\begin{xxx}" which LaTeXResult does

## [1.2.1] [[release](https://github.com/pilgrimlyieu/AutoHotkey-Script/releases/tag/OCRC-v1.2.1)] (2022-04-23)

### Added

- General
  - Custom Everything path support (1.2.0)
  - Screenshot maximum time support
  - Screenshot buffer time support
  - Option of auto reload after crucial change

### Fixed

- General
  - [Can not start another OCR immediately after cancel previous OCR](https://github.com/pilgrimlyieu/AutoHotkey-Script/issues/10)
  - [Switch on OCR can not create a corresponding hotkey immediately](https://github.com/pilgrimlyieu/AutoHotkey-Script/issues/11) (Still should reload to update change)
  - [Custom Everything not support](https://github.com/pilgrimlyieu/AutoHotkey-Script/issues/13)
  - [Unknown issue about strange behavior of opening setting](https://github.com/pilgrimlyieu/AutoHotkey-Script/issues/15)

## [1.2.0 First Released Version] [[release](https://github.com/pilgrimlyieu/AutoHotkey-Script/releases/tag/OCRC-v1.2.0)] (2022-04-16)

### Added

- General
  - OCR switch support
  - EncodingBitmap-to-64String quality support
  - Local screenshot support (Default)
  - Third-party screenshot support
  - ~~Everything path support~~

### Changed

- General
  - Change config name from "OCRC_config.privacy.ini" to "OCRC.privacy.ini"
- Mathpix
  - Now show "formula text" only when "inline formula" is different from it
  - Reduce width of result windows

### Fixed

- General
  - "[Empty content will not be written into config](https://github.com/pilgrimlyieu/AutoHotkey-Script/issues/9)" bug

## [1.1.3] (2022-04-05)

### Fixed

- Mathpix
  - "Single line text with formula doesn't return single result" bug

## [1.1.2] (2022-04-04)

### Added

- [README](README.md)(Not completed)

### Fixed

- Baidu
  - "Result is blank while default punctuation is 'raw result'" bug

## [1.1.1] (2022-04-04)

### Added

- Baidu
  - Bing Search support

### Changed

- Baidu
  - Remove extra line breaking of "Intelligent paragraph" and "Merge multiple lines"

### Fixed

- Baidu
  - "Intelligent quotation mark doesn't work" bug

## [1.1.0] (2022-04-04)

### Added

- CHANGELOG
- Push "Esc" to close result window
- Baidu
  - Token expiration check
  - Get token error message

### Changed

- Baidu
  - Change warning level(YELLOW) from 60 to 80
  - Change error level(RED) from 20 to 60
- Mathpix
  - Clear clipboard before clip new formula

### Removed

- Baidu
    - Reget token after get OCR result error

## [1.0.0] (2022-04-03)

### Added

- Baidu OCR
  - Multiple result windows support
  - Custom hotkey
  - Recognizing type choice
    - Basic
    - Accurate
    - Handwriting
    - Web image
  - Function
    - Format
      - Intelligent paragraph
      - Split multiple lines
      - Merge multiple lines
    - Punctuation
      - Intelligent punctuation
      - Raw result
      - Chinese punctuation
      - English punctuation
    - Space
      - Intelligent space
      - Raw result
      - Remove space
    - Search
      - Baidu Search
      - Google Search
      - Google(mirror) Search
      - Baidu Encyclopedia
      - Wikipedia(mirror)
      - Everything
    - Change to Clip
  - Probability
    - Precise mode
    - Rough mode
    - Close mode
    - Bar
- Mathpix
  - Multiple result windows support
  - Custom hotkey
  - Default option
    - Inline style
    - Display style
    - Default select
  - Function
    - Click to Clip
  - Confidence
    - Bar

[1.2.2]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/868ebb3...3cb6aae
[1.2.1]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/b11d711...868ebb3
[1.2.0 First Released Version]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/6fad68c...b11d711
[1.1.3]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/df92b84...6fad68c
[1.1.2]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/980eebe...df92b84
[1.1.1]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/53b2361...980eebe
[1.1.0]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/3aa1fb2...53b2361
[1.0.0]: https://github.com/pilgrimlyieu/AutoHotkey-Script/pull/8