---
title: 정규식의 멀티라인 expressions 활용 Guide

toc: true  
toc_sticky: true

categories:
  - dev

tags:
  - regex
  - regular-expression
  - multiline
  - programming
  - text-processing

---

## 정규식의 멀티라인 표현식이란?

정규식(Regular Expression, Regex)은 텍스트 패턴을 검색하거나 조작할 때 강력한 도구로 사용됩니다. 특히 **멀티라인 표현식**은 여러 줄에 걸친 텍스트를 처리할 때 유용하며, 줄바꿈(`\n`)을 포함한 패턴 매칭을 가능하게 합니다. 이번 포스트에서는 멀티라인 표현식의 활용법, **Dotall (Single Line) 모드**, **Multi Line 모드**, **Non-Dotall 모드**의 차이점, 여러 줄을 처리하는 방법, 그리고 특정 패턴(예: `start`로 시작하고 `end`로 끝나는 패턴) 매칭 방법 등을 다룹니다. 또한, `/s`, `/S`, `/w`, `/W`, `.|\n`의 모드별 동작 차이를 설명합니다.

## Dotall, Multi Line, Non-Dotall 모드의 차이점

정규식에서 멀티라인 텍스트를 다룰 때, 세 가지 주요 모드가 사용됩니다: **Dotall 모드**, **Multi Line 모드**, 그리고 **Non-Dotall 모드**. 이들은 점(`.`)과 경계 문자(`^`, `$`)의 동작 방식에서 차이가 있습니다.

### 1. Dotall (Single Line) 모드
- **설명**: Dotall 모드는 점(`.`)이 줄바꿈 문자(`\n`)를 포함한 모든 문자를 매칭하도록 합니다. 기본적으로 점(`.`)은 줄바꿈을 제외한 모든 단일 문자를 의미하지만, Dotall 모드에서는 줄바꿈까지 포함됩니다.
- **활성화 방법**: Python에서는 `re.DOTALL` 플래그(또는 `re.S`)를, JavaScript에서는 `/s` 플래그를 사용합니다.
- **예시** (Python):
  ```python
  import re

  text = "Hello\nWorld"
  pattern = r"Hello.*World"
  
  # Dotall 모드 없이: 매칭 실패
  print(re.search(pattern, text))  # None
  
  # Dotall 모드 활성화: 매칭 성공
  print(re.search(pattern, text, re.DOTALL))  # <re.Match object; span=(0, 11), match='Hello\nWorld'>
  ```
- **사용 사례**: 여러 줄에 걸친 텍스트 블록(예: HTML, 로그 파일)을 한 번에 매칭할 때 유용합니다.

### 2. Multi Line 모드
- **설명**: Multi Line 모드는 `^`와 `$`가 각각 각 줄의 시작과 끝을 나타내도록 합니다. 기본적으로 `^`는 문자열 전체의 시작, `$`는 문자열 전체의 끝을 의미하지만, Multi Line 모드에서는 각 줄에 대해 독립적으로 작동합니다.
- **활성화 방법**: Python에서는 `re.MULTILINE` 플래그(또는 `re.M`)를, JavaScript에서는 `/m` 플래그를 사용합니다.
- **예시** (Python):
  ```python
  import re

  text = "start line1\nstart line2\nend line3"
  pattern = r"^start.*$"
  
  # Multi Line 모드 없이: 첫 번째 줄만 매칭 시도
  print(re.findall(pattern, text))  # []
  
  # Multi Line 모드 활성화: 각 줄에서 패턴 매칭
  print(re.findall(pattern, text, re.MULTILINE))  # ['start line1', 'start line2']
  ```
- **사용 사례**: 로그 파일에서 특정 패턴으로 시작하는 각 줄을 추출하거나, 여러 줄에 걸친 코드에서 특정 주석 패턴을 찾을 때 유용합니다.

### 3. Non-Dotall 모드
- **설명**: Non-Dotall 모드는 기본 정규식 동작으로, 점(`.`)이 줄바꿈 문자(`\n`)를 제외한 모든 단일 문자를 매칭합니다. 이 모드에서는 줄바꿈을 포함하려면 명시적으로 `\n`을 패턴에 포함하거나 다른 방법을 사용해야 합니다.
- **특징**: Dotall 모드가 활성화되지 않은 상태로, 점(`.`)은 한 줄 내에서만 작동하며, 멀티라인 텍스트를 처리하려면 줄바꿈을 별도로 처리해야 합니다.
- **예시** (Python):
  ```python
  import re

  text = "Hello\nWorld"
  pattern = r"Hello.*World"
  
  # Non-Dotall 모드: 매칭 실패 (줄바꿈 때문에)
  print(re.search(pattern, text))  # None
  
  # Non-Dotall에서 줄바꿈 명시적 처리
  pattern = r"Hello[\s\S]*World"
  print(re.search(pattern, text))  # <re.Match object; span=(0, 11), match='Hello\nWorld'>
  ```
- **사용 사례**: 줄바꿈을 포함하지 않는 패턴을 엄격히 매칭하거나, 줄바꿈을 명시적으로 제어하고 싶을 때 사용됩니다.

### `/s`, `/S`, `/w`, `/W`, `.|\n`의 모드별 차이점
정규식에서 특정 문자 클래스와 패턴은 모드에 따라 다르게 동작합니다. 아래는 주요 패턴의 동작을 비교합니다:

| 패턴     | 설명                                                                 | Dotall 모드 동작                              | Multi Line 모드 동작                          | Non-Dotall 모드 동작                          |
|----------|----------------------------------------------------------------------|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| `/s`     | 공백 문자(스페이스, 탭, 줄바꿈 등)를 매칭                            | 줄바꿈(`\n`) 포함                             | 줄바꿈(`\n`) 포함                             | 줄바꿈(`\n`) 포함                             |
| `/S`     | 공백 문자가 아닌 모든 문자를 매칭                                     | 줄바꿈(`\n`) 포함                             | 줄바꿈(`\n`) 포함                             | 줄바꿈(`\n`) 포함                             |
| `/w`     | 단어 문자(알파벳, 숫자, 언더스코어: `[a-zA-Z0-9_]`)를 매칭           | 모드에 무관                                  | 모드에 무관                                  | 모드에 무관                                  |
| `/W`     | 단어 문자가 아닌 모든 문자를 매칭                                     | 모드에 무관                                  | 모드에 무관                                  | 모드에 무관                                  |
| `.|\n`   | 점(`.`) 또는 줄바꿈(`\n`)을 명시적으로 매칭                          | 불필요 (`.`)가 이미 `\n` 포함                | 줄바꿈(`\n`) 명시적 매칭 필요                | 줄바꿈(`\n`) 명시적 매칭 필요                |

- **설명**:
  - `/s`와 `/S`는 공백 문자와 비공백 문자를 매칭하며, 모든 모드에서 줄바꿈(`\n`)을 포함합니다.
  - `/w`와 `/W`는 단어 문자와 비단어 문자를 매칭하며, 모드에 영향을 받지 않습니다.
  - `.|\n`은 Non-Dotall 모드에서 줄바꿈을 포함하려는 대안으로 사용되며, Dotall 모드에서는 불필요합니다.
- **예시** (Python, Non-Dotall에서 `.|\n` 사용):
  ```python
  import re
  text = "Hello\nWorld"
  pattern = r"Hello(.|\n)*World"
  match = re.search(pattern, text)
  print(match.group())  # Hello\nWorld
  ```

### 차이점 요약

| 모드            | 점(`.`) 동작                     | `^`와 `$` 동작                     | 플래그 (Python)       | 플래그 (JavaScript) |
|-----------------|-------------------------------|-----------------------------------|-----------------------|---------------------|
| Dotall (Single Line) | 줄바꿈(`\n`) 포함 모든 문자 매칭 | 문자열 전체의 시작/끝            | `re.DOTALL` (`re.S`) | `/s`                |
| Multi Line      | 줄바꿈(`\n`) 제외                | 각 줄의 시작/끝                  | `re.MULTILINE` (`re.M`) | `/m`                |
| Non-Dotall      | 줄바꿈(`\n`) 제외                | 문자열 전체의 시작/끝            | 없음                  | 없음                |

## 여러 줄을 표현하는 방법

멀티라인 텍스트를 처리할 때, 정규식에서 여러 줄을 표현하는 주요 방법은 다음과 같습니다:

1. **Dotall 모드 활용**:
   - 점(`.`)을 사용해 줄바꿈을 포함한 모든 텍스트 블록을 매칭.
   - 예: `.*`로 여러 줄을 한 번에 캡처.
   - Python 예시:
     ```python
     import re
     text = "Line 1\nLine 2\nLine 3"
     pattern = r".*"
     matches = re.findall(pattern, text, re.DOTALL)
     print(matches)  # ['Line 1\nLine 2\nLine 3']
     ```

2. **줄바꿈 문자(`\n`) 명시적 사용**:
   - 줄바꿈을 명시적으로 패턴에 포함(예: `.*\n.*`).
   - 예: 두 줄에 걸친 패턴 매칭.
     ```python
     import re
     text = "Line 1\nLine 2\nLine 3"
     pattern = r".*\n.*"
     matches = re.findall(pattern, text)
     print(matches)  # ['Line 1\nLine 2']
     ```

3. **Multi Line 모드와 `^`, `$` 활용**:
   - 각 줄을 개별적으로 처리.
   - 예: 각 줄의 시작이 특정 단어로 시작하는 경우.
     ```python
     import re
     text = "apple\nbanana\ncherry"
     pattern = r"^\w+"
     matches = re.findall(pattern, text, re.MULTILINE)
     print(matches)  # ['apple', 'banana', 'cherry']
     ```

4. **Non-Dotall 모드에서 `.|\n` 활용**:
   - 점(`.`)이 줄바꿈을 포함하지 않으므로, `.|\n`를 사용해 줄바꿈을 명시적으로 포함.
   - 예: 여러 줄에 걸친 텍스트를 Non-Dotall 모드로 매칭.
     ```python
     import re
     text = "Line 1\nLine 2\nLine 3"
     pattern = r"Line(.|\n)*3"
     matches = re.findall(pattern, text)
     print(matches)  # ['\n']
     ```

## `start`로 시작하고 `end`로 끝나는 멀티라인 패턴

특정 문자열(예: `start`로 시작하고 `end`로 끝나는 패턴)을 멀티라인에서 매칭하려면 Dotall 모드 또는 Non-Dotall 모드에서 `[\s\S]`를 활용합니다. 또한 특정 문자를 포함하거나 포함하지 않는 조건을 추가할 수 있습니다.

### 1. 기본 패턴: `start`로 시작하고 `end`로 끝나는 텍스트
- **Dotall 모드 패턴**: `start.*?end` (비탐욕적 매칭).
- **Non-Dotall 모드 패턴**: `start[\s\S]*?end`.
- **예시** (Python, Non-Dotall):
  ```python
  import re
  text = "start middle content\nmore content\nend other text"
  pattern = r"start[\s\S]*?end"
  match = re.search(pattern, text)
  print(match.group())  # start middle content\nmore content\nend
  ```

### 2. 특정 문자 포함
- **요구사항**: `start`와 `end` 사이에 특정 문자(예: `keyword`)를 포함하며, 여러 블록을 매칭.
- **패턴**: Non-Dotall 모드에서는 `start(?:(?!end)[\s\S])*?keyword[\s\S]*?end`.
- **예시** (Python, Non-Dotall):
  ```python
  import re
  text = """start first block\nkeyword here\nend
  some text
  start second block\nno keyword\nend
  start third block\nkeyword again\nend"""
  pattern = r"start(?:(?!end)[\s\S])*?keyword[\s\S]*?end"
  matches = re.findall(pattern, text)
  for match in matches:
      print(match)
  ```
  **출력**:
  ```
  start first block
  keyword here
  end
  start third block
  keyword again
  end
  ```

### 3. 특정 문자 포함하지 않음
- **요구사항**: `start`와 `end` 사이에 특정 문자(예: `forbidden`)를 포함하지 않으며, 여러 블록을 매칭.
- **패턴**: Non-Dotall 모드에서는 `start(?:(?!end)[\s\S])*?(?![\s\S]*forbidden)[\s\S]*?end`.
- **예시** (Python, Non-Dotall):
  ```python
  import re
  text = """start first block\nkeyword here\nend
  some text
  start second block\nno keyword\nend
  start third block\nkeyword again\nend
  start fourth block\nforbidden content\nend"""
  pattern = r"start(?:(?!end)[\s\S])*?(?![\s\S]*forbidden)[\s\S]*?end"
  matches = re.findall(pattern, text)
  for match in matches:
      print(match)
  ```
  **출력**:
  ```
  start first block
  keyword here
  end
  start second block
  no keyword
  end
  start third block
  keyword again
  end
  ```

## 기타 활용 사례

정규식의 멀티라인 표현식은 다양한 시나리오에서 활용됩니다. 아래는 몇 가지 실용적인 예시입니다:

1. **로그 파일 분석**:
   - 로그 파일에서 특정 에러 메시지가 포함된 블록을 추출.
   - 예: `ERROR(.|\n)*?\n`로 에러 메시지와 관련된 블록을 Non-Dotall 모드로 추출.
     ```python
     import re
     text = "INFO: System started\nERROR: Connection failed\nDetails: Timeout\nINFO: System running"
     pattern = r"ERROR(.|\n)*?\n"
     matches = re.findall(pattern, text)
     print(matches)  # ['\n', '\n']
     ```

2. **코드 주석 추출**:
   - 여러 줄 주석(예: `/* ... */`)을 Non-Dotall 모드로 추출.
   - 예 (JavaScript):
     ```javascript
     const text = "code\n/* comment\nmultiline */\nmore code";
     const pattern = /\/\*(.|\n)*?\*\//;
     const matches = text.match(pattern);
     console.log(matches[0]); // /* comment\nmultiline */
     ```

3. **HTML 태그 내용 추출**:
   - 특정 태그(예: `<div>...</div>`)의 내용을 멀티라인에서 추출.
   - 예 (Python, Non-Dotall):
     ```python
     import re
     text = "<div>\n  Content Line 1\n  Content Line 2\n</div>"
     pattern = r"<div>(.|\n)*?</div>"
     match = re.search(pattern, text)
     print(match.group())  # <div>\n  Content Line 1\n  Content Line 2\n</div>
     ```

## 결론

정규식의 멀티라인 표현식은 텍스트 데이터를 다룰 때 강력한 도구입니다. **Dotall 모드**는 줄바꿈을 포함한 전체 텍스트 블록을 처리하는 데 유용하며, **Multi Line 모드**는 각 줄의 시작과 끝을 독립적으로 다룰 때 적합합니다. **Non-Dotall 모드**는 줄바꿈을 명시적으로 처리해야 하며, `[\s\S]`과 같은 패턴을 사용해 유연성을 제공합니다. `/s`, `/S`, `/w`, `/W`는 모드에 따라 일관된 동작을 보이며, `.|\n`은 Non-Dotall 모드에서 줄바꿈을 포함하는 대안입니다. `start`와 `end`로 둘러싸인 패턴을 매칭하거나 특정 문자를 포함/제외하는 패턴을 활용하면 복잡한 텍스트 처리 작업을 효율적으로 수행할 수 있습니다.

## 추가 리소스

* [Regular Expressions 101](https://regex101.com/) - 정규식 테스트 및 디버깅 도구
* [Python re 모듈 문서](https://docs.python.org/3/library/re.html)
* [JavaScript RegExp MDN 문서](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp)