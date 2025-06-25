---
title: 정규식 탐색 기법 - 전방탐색, 부정형 전방탐색, 후방탐색, 부정형 후방탐색

toc: true  
toc_sticky: true  

categories:
  - dev

tags:  
  - regex
  - regular expression
  - lookahead
  - lookbehind
---

정규식 탐색 기법: 전방탐색과 후방탐색

## 정규식 탐색 기법 요약
- 정규식(Regular Expression)은 텍스트 패턴 매칭에 강력한 도구.  
- **전방탐색(Lookahead)**과 **후방탐색(Lookbehind)**은 특정 조건을 만족하는 패턴을 찾되, 그 조건 자체는 결과에 포함시키지 않는 고급 기법

| 기법                  | 문법                     | 설명                                      |
|-----------------------|--------------------------|-------------------------------------------|
| 전방탐색              | `(?=패턴)`              | 패턴이 앞에 있을 때 매칭                 |
| 부정형 전방탐색       | `(?!패턴)`              | 패턴이 앞에 없을 때 매칭                 |
| 후방탐색              | `(?<=패턴)`             | 패턴이 뒤에 있을 때 매칭                 |
| 부정형 후방탐색       | `(?<!패턴)`             | 패턴이 뒤에 없을 때 매칭                 |

## 왜 전방탐색과 후방탐색이 필요한가?

전방탐색과 후방탐색은 매칭 조건을 설정하지만, 해당 조건은 최종 결과에 포함되지 않습니다. 이는 URL, 로그, 텍스트 파싱에서 특정 패턴의 주변 정보만 필요할 때 유용합니다. 주요 장점:
- **정확성**: 원치 않는 부분을 결과에서 제외.
- **유연성**: 복잡한 패턴 매칭 가능.
- **효율성**: 불필요한 후처리 최소화.

## 샘플 URL 데이터

설명을 위해 다음 URL 데이터를 사용합니다:

```
https://example.com/path/to/page.html
http://api.example.org/v1/users
https://blog.example.net/post/123
ftp://files.example.com/download/file.zip
```

## 1. 전방탐색 (`(?=패턴)`)

### 설명
전방탐색은 특정 패턴이 뒤에 있을 때만 매칭합니다. 예를 들어, `https`로 시작하는 URL에서 프로토콜(`https`)만 추출하되, 뒤에 `://`가 따라오는 경우에만 매칭하려면 전방탐색을 사용합니다.

### 사용 예제
- **예제**: `://`가 뒤에 있는 프로토콜(`http` 또는 `https`) 추출

  ```bash
  \w+(?=\://)
  ```

  - **설명**: `\w+`는 단어 문자(프로토콜)를 매칭하고, `(?=\://)`는 `://`가 뒤에 있는지 확인.
  - **결과**:

    | 샘플 URL                                              | 매칭 결과 |
    |-------------------------------------------------------|-----------|
    | https://example.com/path/to/page.html                  | `https`   |
    | http://api.example.org/v1/users                       | `http`    |
    | https://blog.example.net/post/123                     | `https`   |
    | ftp://files.example.com/download/file.zip             | `ftp`     |

## 2. 부정형 전방탐색 (`(?!패턴)`)

### 설명
부정형 전방탐색은 특정 패턴이 뒤에 **없을 때** 매칭합니다. 예를 들어, `https`가 아닌 프로토콜을 추출하려면 부정형 전방탐색을 사용합니다.

### 사용 예제
- **예제**: `https`가 아닌 프로토콜 추출

  ```bash
  \w+(?!\s*https)
  ```

  - **설명**: `\w+`는 단어 문자를 매칭하고, `(?!https)`는 `https`가 뒤에 없음을 확인.
  - **결과**:

    | 샘플 URL                                              | 매칭 결과 |
    |-------------------------------------------------------|-----------|
    | https://example.com/path/to/page.html                  | -         |
    | http://api.example.org/v1/users                       | `http`    |
    | https://blog.example.net/post/123                     | -         |
    | ftp://files.example.com/download/file.zip             | `ftp`     |

## 3. 후방탐색 (`(?<=패턴)`)

### 설명
후방탐색은 특정 패턴이 앞에 있을 때만 매칭합니다. 예를 들어, `https://`로 시작하는 URL에서 도메인(`example.com`)을 추출하려면 후방탐색을 사용합니다.

### 사용 예제
- **예제**: `https://` 뒤의 도메인 추출

  ```bash
  (?<=https\://)[^/]+
  ```

  - **설명**: `(?<=https\://)`는 `https://`가 앞에 있는지 확인하고, `[^/]+`는 슬래시(/)가 아닌 문자를 매칭.
  - **결과**:

    | 샘플 URL                                              | 매칭 결과          |
    |-------------------------------------------------------|--------------------|
    | https://example.com/path/to/page.html                  | `example.com`      |
    | http://api.example.org/v1/users                       | -                  |
    | https://blog.example.net/post/123                     | `blog.example.net` |
    | ftp://files.example.com/download/file.zip             | -                  |

## 4. 부정형 후방탐색 (`(?<!패턴)`)

### 설명
부정형 후방탐색은 특정 패턴이 앞에 **없을 때** 매칭합니다. 예를 들어, `https://`로 시작하지 않는 URL에서 도메인을 추출하려면 부정형 후방탐색을 사용합니다.

### 사용 예제
- **예제**: `https://`로 시작하지 않는 URL의 도메인 추출

  ```bash
  (?<!https\://)[^/]+(?=\//)
  ```

  - **설명**: `(?<!https\://)`는 `https://`가 앞에 없음을 확인하고, `[^/]+`는 슬래시(/)가 아닌 문자를 매칭하며, `(?=\//)`는 뒤에 `/`가 있음을 확인.
  - **결과**:

    | 샘플 URL                                              | 매칭 결과            |
    |-------------------------------------------------------|----------------------|
    | https://example.com/path/to/page.html                  | -                    |
    | http://api.example.org/v1/users                       | `api.example.org`    |
    | https://blog.example.net/post/123                     | -                    |
    | ftp://files.example.com/download/file.zip             | `files.example.com`  |

## 결론

전방탐색과 후방탐색은 정규식에서 강력한 패턴 매칭을 가능하게 합니다. URL 파싱과 같은 작업에서 조건을 정밀하게 설정하여 원하는 데이터만 추출할 수 있습니다. 위 예제를 바탕으로 정규식 테스트 도구(예: regex101.com)를 활용해 패턴을 연습하고, 프로젝트 요구사항에 맞게 조정하세요.

## 추가 리소스
- [Regex101](https://regex101.com/) - 정규식 테스트 및 디버깅
- [Regular Expressions Info](https://www.regular-expressions.info/) - 정규식 학습 자료
- [MDN Web Docs: Regular Expressions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions) - JavaScript 정규식 가이드

---