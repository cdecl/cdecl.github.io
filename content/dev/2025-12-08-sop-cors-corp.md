---
title: '웹 개발 필수 개념: SOP, CORS, CORP의 관계 정리'
tags:
  - CORS
  - CORP
  - SOP
  - CDN
  - Security
---
현대 웹 환경에서는 Cross-Origin 리소스 접근을 관리하기 위한 복잡한 보안 메커니즘이 존재합니다. 그 중심에는 **SOP, CORS, CORP** 세 가지 정책이 있습니다.

특히 CDN(Content Delivery Network)을 사용하는 경우, 이 정책들을 정확히 이해하지 못하면 예측하지 못한 로드 오류(CORS/CORP 에러)에 직면하게 됩니다.

---

## 1. 웹 보안의 근간: 출처(Origin)와 SOP

웹 보안의 모든 논의는 **출처(Origin)**의 개념에서 시작됩니다.

### 1-1. 출처(Origin)의 정의

두 URL이 동일한 출처가 되기 위해서는 다음 세 가지 요소가 모두 일치해야 합니다.

1.  **프로토콜 (Scheme)**: `http` 또는 `https`
2.  **호스트 (Host)**: 도메인 이름 (예: `example.com`)
3.  **포트 (Port)**: 포트 번호 (생략 시 기본값 80 또는 443)

### 1-2. 동일 출처 정책 (SOP: Same-Origin Policy)

SOP는 웹 브라우저의 가장 기본적인 보안 정책입니다.

*   **목표**: 한 출처에서 로드된 문서나 스크립트가 다른 출처의 리소스에 임의로 접근하여 정보를 읽는 것을 차단합니다. 이를 통해 CSRF(교차 사이트 요청 위조), 정보 유출 등의 악성 행위를 방지합니다.
*   **기본 원칙**: 기본적으로 **동일 출처 간의 상호작용만 허용**합니다.

---

## 2. SOP의 예외: CORS (Cross-Origin Resource Sharing)

CORS는 SOP가 엄격하게 제한하는 **스크립트 기반의 교차 출처 데이터 통신**을 안전하게 허용하기 위한 표준 메커니즘입니다.

### 2-1. CORS의 역할과 작동 방식

| 구분 | CORS (Cross-Origin Resource Sharing) |
| :--- | :--- |
| **목표** | 스크립트 기반의 교차 출처 데이터 **읽기 허용** (SOP의 예외 부여). |
| **대상** | `Fetch API`, `XMLHttpRequest` 등을 사용한 **동적 API 요청**. |
| **작동 주체** | 서버가 정책을 설정하고, **브라우저가 이를 검증 및 실행**. |
| **핵심 헤더** | `Access-Control-Allow-Origin: <허용 출처>` |

**작동 흐름:**

1.  **브라우저**: 교차 출처 요청 시 `Origin` 헤더에 자신의 출처 정보를 담아 서버에 보냅니다. (복잡한 요청의 경우 Preflight 요청을 먼저 보냅니다.)
2.  **서버**: `Origin` 헤더를 확인하고, 허용 목록에 있으면 응답 헤더에 `Access-Control-Allow-Origin`을 포함하여 브라우저에 보냅니다.
3.  **브라우저**: 응답 헤더를 검증합니다. 허용되지 않은 출처라면, 서버가 응답을 성공적으로 보냈더라도 **브라우저가 스크립트가 해당 응답 데이터에 접근하는 것을 차단**하고 콘솔에 CORS 에러를 띄웁니다.

#### 📝 서버 측 필수 응답 헤더 (CORS)

서버는 상황에 따라 다음 헤더들을 적절히 조합하여 내려주어야 합니다.

| 헤더 이름 | 설명 | 예시 |
| :--- | :--- | :--- |
| **`Access-Control-Allow-Origin`** | 접근을 허용할 출처(Origin)를 지정합니다. `*`은 인증이 필요 없는 경우에만 사용 가능합니다. | `https://example.com` |
| **`Access-Control-Allow-Methods`** | 리소스 접근 시 허용할 HTTP 메서드 목록입니다. (Preflight 응답 시 사용) | `GET, POST, OPTIONS` |
| **`Access-Control-Allow-Headers`** | 실제 요청에서 사용할 수 있는 커스텀 헤더 목록입니다. | `Content-Type, Authorization` |
| **`Access-Control-Allow-Credentials`** | 쿠키(Cookie)나 인증 헤더를 포함한 요청을 허용할지 여부입니다. `true`일 때만 자격 증명 포함 요청이 성공합니다. | `true` |
| **`Access-Control-Expose-Headers`** | 브라우저 스크립트에서 접근할 수 있는 응답 헤더 화이트리스트입니다. 기본적으로 6개 헤더 외에는 읽을 수 없습니다. | `X-My-Custom-Header` |
| **`Access-Control-Max-Age`** | Preflight 요청의 결과를 캐시할 시간(초)입니다. 캐시된 시간 동안은 다시 Preflight를 보내지 않습니다. | `3600` |

### 2-2. 상세 프로세스: 클라이언트와 서버의 대화

CORS는 마치 "입국 심사"와 유사한 과정을 거칩니다.

**1) Simple Request (단순 요청)**

안전한 메서드(GET, HEAD, POST)와 안전한 헤더(Accept, User-Agent 등)만 사용하는 경우입니다.

```text
[Browser]                                    [Server]
    |                                            |
    | --- GET /api/data -----------------------> |
    |     (Origin: https://my-app.com)           |
    |                                            |
    | <---------------------- 200 OK ----------- |
    |     (Access-Control-Allow-Origin:          |
    |      https://my-app.com)                   |
    |                                            |
    V                                            V
[JS App]
  (성공!) 브라우저가 헤더 확인 후
  데이터 전달
```

**2) Preflight Request (예비 요청)**

PUT, DELETE 등 데이터를 변경할 수 있는 요청이나 커스텀 헤더(`Authorization` 등)를 사용할 때 발생합니다. 브라우저는 본 요청을 보내기 전에 **"간 보기(Preflight)"** 요청을 먼저 보냅니다.

```text
[Browser]                                    [Server]
    |                                            |
    | --- OPTIONS /api/update -----------------> |
    |     (Origin: ..., Method: PUT)             |
    |     "나 좀 이따 PUT 보낼 건데 괜찮?"          |
    |                                            |
    | <----------------- 204 No Content -------- |
    |     (Allow-Methods: PUT)                   |
    |     "ㅇㅇ PUT 써도 됨"                      |
    |                                            |
    | --- PUT /api/update ---------------------> |
    |                                            |
    | <---------------------- 200 OK ----------- |
```

---

## 3. 새로운 방어막: CORP (Cross-Origin Resource Policy)

CORP는 CORS와 달리, 스크립트 기반 요청뿐만 아니라 **HTML 태그를 통한 리소스 포함(Embedding)**까지 제어하여, 민감한 리소스가 다른 출처의 메모리에 로드되는 것 자체를 방지하는 강력한 보안 정책입니다.

### 3-1. CORP의 역할 및 도입 배경

| 구분 | CORP (Cross-Origin Resource Policy) |
| :--- | :--- |
| **목표** | 리소스의 **메모리 로드 자체를 차단**하여 Spectre와 같은 사이드 채널 공격으로부터 정보를 보호. |
| **대상** | `<script>`, `<img>`, `<link>` 등 **포함(Embedding) 가능한 모든 정적 리소스**. |
| **작동 주체** | 서버가 정책을 설정하고, **브라우저가 이를 검증 및 실행**. |
| **핵심 헤더** | `Cross-Origin-Resource-Policy: <정책>` |

#### 📝 서버 측 필수 응답 헤더 (CORP)

CORP는 단 하나의 헤더로 제어되지만, 정책의 의미가 매우 중요합니다.

| 정책 값 (Value) | 설명 | 사용 예시 |
| :--- | :--- | :--- |
| **`same-origin`** | **가장 강력한 제한**. 동일한 출처(같은 Scheme, Host, Port)에서만 리소스를 로드할 수 있습니다. | 뱅킹 데이터, 개인정보 JSON |
| **`same-site`** | 동일한 상위 도메인(Site) 내에서는 로드 허용. 서브도메인 간 공유가 필요할 때 사용합니다. | `login.naver.com` ↔ `mail.naver.com` |
| **`cross-origin`** | **모든 출처 허용**. CDN이나 공개 이미지처럼 어디서든 로드되어도 되는 리소스에 사용합니다. | CDN 호스팅 이미지, 공개 JS 라이브러리 |

### 3-2. CORP vs. CORS: 명확한 차이

| 구분 | CORP (Cross-Origin Resource Policy) | CORS (Cross-Origin Resource Sharing) |
| :--- | :--- | :--- |
| **제어 대상** | 리소스의 **로드(Load) 및 포함(Embedding) 자체** | 스크립트의 **응답 데이터 접근(Read)** |
| **보안 목적** | 메모리 기반의 정보 유출 방지 | SOP의 제약을 해제하여 API 통신 허용 |

### 3-3. 상세 프로세스: 브라우저의 입국 심사

CORP는 서버가 브라우저에게 **"나를 아무데나 태우지 마!"**라고 신분증을 보여주는 것과 같습니다. 브라우저는 이 신분증을 보고 로드 여부를 결정합니다.

```text
[Attacker.com]        [Browser]                  [Bank Server]
      |                   |                            |
      | -- <img src> ---> |                            |
      |                   |                            |
      |                   | --- GET /user_info.png --> |
      |                   |                            |
      |                   | <------- 200 OK ---------- |
      |                   | (CORP: same-origin)        |
      |                   |                            |
      X                   | (차단!)                     |
(로드 실패)            [메모리 파기]
                     "잠깐, 출처가 다른데
                      same-origin이네? 버렷!"
```

*   **Client (브라우저)**: 응답을 받았을 때, `Cross-Origin-Resource-Policy` 헤더를 확인합니다. 현재 페이지의 출처(Origin)와 리소스의 CORP 정책이 맞지 않으면, **응답 내용을 메모리에 올리지 않고 즉시 파기**합니다. (렌더링 자체가 안 됨)
*   **Server**: 리소스가 어디서 로드되어도 되는지(`cross-origin`), 같은 출처에서만 로드되어야 하는지(`same-origin`), 혹은 같은 사이트(`same-site`)인지 헤더로 명시합니다.

---

## 4. CDN 환경에서 발생하는 이슈 정리

CDN은 메인 웹사이트와 **다른 출처(Cross-Origin)**인 경우가 대부분이기 때문에, 이 두 정책에 모두 영향을 받습니다.

| 리소스 위치 | 로드 방법 | 발생 가능한 충돌 | 해결책 |
| :--- | :--- | :--- | :--- |
| **CDN** (정적 파일) | `<script>`, `<link>`, `<img>` 태그 (Embedding) | **CORP 충돌** <br> (`same-origin` 설정 시 로드 차단) | CDN 응답 헤더에 `Cross-Origin-Resource-Policy: cross-origin` 설정. |
| **CDN** (동적 데이터) | Fetch/XHR 스크립트 (Data Reading) | **CORS 충돌** <br> (스크립트의 응답 접근 차단) | CDN/원본 서버 응답 헤더에 `Access-Control-Allow-Origin: <사이트 출처>` 설정. |

> **💡 핵심: CDN과 same-origin의 역설**
>
> CDN에 호스팅 된 리소스에 `Cross-Origin-Resource-Policy: same-origin`을 설정하면, 브라우저는 해당 리소스가 **오직 CDN 도메인에서만 사용될 수 있다고 해석**합니다.
>
> 따라서 메인 웹사이트(다른 출처)에서 로드하려고 할 때, 이 `same-origin` 정책 때문에 로드가 차단되어 오히려 문제가 발생합니다. **CDN 리소스는 Cross-Origin 로드를 허용하는 `cross-origin`으로 설정해야 정상적으로 작동합니다.**

---

## 5. 핵심 용어 정리

| 용어 | 정의 | 역할 |
| :--- | :--- | :--- |
| **출처 (Origin)** | 프로토콜, 호스트, 포트 3가지가 결합된 URL의 일부. | 웹 보안의 기본 단위. |
| **SOP (Same-Origin Policy)** | 동일 출처에서 로드된 문서만 다른 출처의 리소스에 스크립트를 통해 접근하도록 허용하는 브라우저의 보안 정책 (기본적으로 교차 출처 스크립트 접근 차단). | 기본적인 보안 경계를 설정. |
| **CORP (Cross-Origin Resource Policy)** | 서버 응답 헤더를 통해 리소스를 포함(embedding)하거나 읽을 수 있는 출처를 명시적으로 제한하는 정책. (주로 사이드 채널 공격 방어 목적). | 리소스의 교차 출처 로드/사용 가능 여부를 제어. |
| **CORS (Cross-Origin Resource Sharing)** | SOP의 제약을 우회하여 스크립트 기반의 교차 출처 데이터 요청(XMLHttpRequest, Fetch API 등)을 안전하게 허용하기 위한 메커니즘. | SOP의 예외를 만들어 교차 출처 통신을 가능하게 함. |
| **CDN (Content Delivery Network)** | 지리적으로 분산된 서버 네트워크를 통해 콘텐츠를 빠르게 제공하는 서비스. | 웹사이트의 정적 파일을 교차 출처 환경에서 제공하게 만듦. |