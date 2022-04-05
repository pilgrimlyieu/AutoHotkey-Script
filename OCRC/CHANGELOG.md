# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.3] - 2022-04-05

### Fixed

-Mathpix
  - "Single line text with formula doesn't return single result" bug

## [1.1.2] - 2022-04-04

### Added

- [README](README.md)(Not completed)

### Fixed

- Baidu
  - "Result is blank while default punctuation is 'raw result'" bug

## [1.1.1] - 2022-04-04

### Added

- Baidu
  - Bing Search support

### Changed

- Baidu
  - Remove extra line breaking of "Intelligent paragraph" and "Merge multiple lines"

### Fixed

- Baidu
  - "Intelligent quotation mark doesn't work" bug

## [1.1.0] - 2022-04-04

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

## [1.0.0] - 2022-04-03

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

[Unreleased]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/6fad68c...HEAD
[1.1.3]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/df92b84...6fad68c
[1.1.2]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/980eebe...df92b84
[1.1.1]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/53b2361...980eebe
[1.1.0]: https://github.com/pilgrimlyieu/AutoHotkey-Script/compare/3aa1fb2...53b2361
[1.0.0]: https://github.com/pilgrimlyieu/AutoHotkey-Script/pull/8