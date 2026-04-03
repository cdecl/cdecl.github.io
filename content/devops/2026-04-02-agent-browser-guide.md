---
title: "agent-browser: AI 에이전트를 위한 브라우저 자동화 CLI"
tags:
  - ai
  - browser-automation
  - playwright
  - rust
  - devops
---

`agent-browser`는 AI 에이전트가 웹 브라우저를 직접 다루도록 만든 CLI 도구입니다. 단순히 클릭과 입력만 하는 자동화 스크립트가 아니라, 페이지 구조를 스냅샷으로 읽고, ref 기반으로 요소를 조작하고, 세션과 상태를 유지하고, 네트워크와 디버그 정보까지 함께 다룰 수 있도록 설계되어 있습니다.

DevOps 관점에서 보면 이 도구의 매력은 분명합니다. 사람이 브라우저에서 하던 반복 작업을 쉘 명령으로 옮길 수 있고, AI 에이전트가 사용할 수 있는 안정적인 웹 조작 인터페이스를 제공합니다. 특히 Playwright를 직접 코드로 짜는 방식보다, 탐색과 검증을 훨씬 빠르게 시도해볼 수 있습니다.

---

## 1. agent-browser란 무엇인가?

agent-browser는 Vercel Labs가 공개한 브라우저 자동화 CLI입니다. README 기준으로는 **빠른 Rust CLI**와 **Node.js 데몬**이 함께 동작하는 구조이며, 내부적으로 Playwright 기반 브라우저를 관리합니다. 네이티브 바이너리를 사용할 수 없을 때는 Node.js 경로로 동작하는 fallback도 제공합니다.

핵심은 AI 친화적인 조작 방식입니다.

* `snapshot`으로 현재 페이지의 접근성 트리를 읽습니다.
* 각 요소는 `@e1`, `@e2` 같은 ref로 식별됩니다.
* 이후 `click @e2`, `fill @e3 "text"`처럼 deterministic하게 조작합니다.
* 필요하면 CSS selector, text selector, role 기반 locator도 함께 사용할 수 있습니다.

즉, 사람처럼 브라우저를 “보면서” 다루는 도구이면서도, 에이전트가 읽고 실행하기 쉬운 형태로 정보가 정리됩니다.

### 동작 원리

1. 사용자가 `open`, `click`, `fill` 같은 명령을 입력합니다.
2. Rust CLI가 명령을 빠르게 해석합니다.
3. Node.js 데몬이 실제 브라우저 인스턴스를 제어합니다.
4. 브라우저 상태, 세션, 쿠키, 네비게이션 히스토리가 유지됩니다.
5. 필요하면 `snapshot`, `get text`, `network requests`, `trace` 같은 명령으로 현재 상태를 다시 관찰합니다.

이 구조 덕분에 단발성 조작뿐 아니라, 여러 단계로 이어지는 웹 작업을 운영 도구처럼 다룰 수 있습니다.

---

## 2. 주요 CLI 명령어

README를 기준으로 실무에서 자주 쓰는 명령을 묶으면 아래처럼 볼 수 있습니다.

### 이동과 기본 조작

* `agent-browser open <url>`: URL로 이동합니다. `goto`, `navigate` 별칭도 있습니다.
* `agent-browser click <sel>`: 요소를 클릭합니다.
* `agent-browser dblclick <sel>`: 더블클릭합니다.
* `agent-browser focus <sel>`: 요소에 포커스를 줍니다.
* `agent-browser type <sel> <text>`: 입력합니다.
* `agent-browser fill <sel> <text>`: 기존 값을 지우고 새로 채웁니다.
* `agent-browser press <key>`: 키를 누릅니다.
* `agent-browser hover <sel>`: 마우스를 올립니다.
* `agent-browser select <sel> <val>`: 셀렉트 박스를 선택합니다.
* `agent-browser check <sel>`, `uncheck <sel>`: 체크박스를 조작합니다.
* `agent-browser scroll <dir> [px]`: 스크롤합니다.
* `agent-browser scrollintoview <sel>`: 요소를 화면으로 가져옵니다.
* `agent-browser drag <src> <tgt>`: 드래그 앤 드롭을 수행합니다.
* `agent-browser upload <sel> <files>`: 파일 업로드를 처리합니다.

예제:

```bash
agent-browser open https://github.com
agent-browser click "#sign-in-button"
agent-browser fill "#email" "test@example.com"
agent-browser press Enter
```

### 정보 조회

* `agent-browser get text <sel>`: 텍스트를 가져옵니다.
* `agent-browser get html <sel>`: innerHTML을 가져옵니다.
* `agent-browser get value <sel>`: input value를 가져옵니다.
* `agent-browser get attr <sel> <attr>`: attribute 값을 읽습니다.
* `agent-browser get title`: 페이지 제목을 가져옵니다.
* `agent-browser get url`: 현재 URL을 확인합니다.
* `agent-browser get count <sel>`: 일치하는 요소 개수를 셉니다.
* `agent-browser get box <sel>`: bounding box를 가져옵니다.

예제:

```bash
agent-browser get title
agent-browser get url
agent-browser get text "h1"
```

### 탐색과 대기

* `agent-browser snapshot`: 접근성 트리를 출력합니다.
* `agent-browser find role <role> <action>`: ARIA role 기반으로 찾습니다.
* `agent-browser find text <text> <action>`: 텍스트 기반으로 찾습니다.
* `agent-browser find label <label> <action>`: label 기반으로 찾습니다.
* `agent-browser find placeholder <ph> <action>`: placeholder 기반으로 찾습니다.
* `agent-browser find testid <id> <action>`: `data-testid` 기반으로 찾습니다.
* `agent-browser wait <selector>`: 요소가 보일 때까지 기다립니다.
* `agent-browser wait --text "Welcome"`: 텍스트가 나타날 때까지 기다립니다.
* `agent-browser wait --url "**/dash"`: URL 패턴을 기다립니다.
* `agent-browser wait --load networkidle`: 로드 상태를 기다립니다.
* `agent-browser wait --fn "window.ready === true"`: JS 조건을 기다립니다.

예제:

```bash
agent-browser snapshot -i
agent-browser find role button click --name "Submit"
agent-browser wait --load networkidle
```

### 세션, 상태, 디버그

* `agent-browser session`: 현재 세션을 확인합니다.
* `agent-browser session list`: 활성 세션 목록을 봅니다.
* `agent-browser cookies`: 쿠키를 읽습니다.
* `agent-browser storage local`: localStorage를 읽습니다.
* `agent-browser state save <path>`: 상태를 저장합니다.
* `agent-browser state load <path>`: 상태를 불러옵니다.
* `agent-browser trace start`, `trace stop`: Playwright trace처럼 기록합니다.
* `agent-browser console`: 콘솔 메시지를 봅니다.
* `agent-browser errors`: 페이지 에러를 확인합니다.
* `agent-browser inspect`: DevTools를 엽니다.
* `agent-browser screenshot [path]`: 스크린샷을 저장합니다.
* `agent-browser pdf <path>`: PDF로 저장합니다.
* `agent-browser close`: 브라우저를 닫습니다.

예제:

```bash
agent-browser session list
agent-browser trace start
agent-browser screenshot result.png
```

### 운영에 유용한 옵션

* `--session <name>`: 세션을 분리합니다.
* `--profile <path>`: 브라우저 프로필을 영속화합니다.
* `--headers <json>`: 특정 origin에 헤더를 주입합니다.
* `--json`: 머신이 읽기 쉬운 JSON 출력입니다.
* `--headed`: 브라우저 창을 실제로 띄웁니다.
* `--cdp <port>`: 기존 Chrome에 CDP로 연결합니다.
* `--allowed-domains`: 허용 도메인을 제한합니다.
* `--confirm-actions`: 위험한 액션에 승인을 요구합니다.

예제:

```bash
agent-browser --session dev open https://example.com
agent-browser --headed snapshot -i
agent-browser --allowed-domains "example.com,*.example.com" open https://example.com
```

---

## 3. 간단한 사이트 네비게이션과 데이터 가져오기

가장 기본적인 흐름은 다음과 같습니다.

### 1) 사이트 열기

```bash
agent-browser open https://example.com
```

### 2) 현재 페이지 구조 확인

```bash
agent-browser snapshot -i
```

`-i`는 interactive 요소만 보여주기 때문에 버튼, 링크, 입력칸을 빠르게 찾을 수 있습니다.

### 3) ref 기반으로 조작

스냅샷에서 `@e1`, `@e2` 같은 ref를 확인한 뒤 바로 씁니다.

```bash
agent-browser click @e2
agent-browser fill @e3 "test@example.com"
agent-browser press Enter
```

### 4) 데이터 추출

화면이 바뀌면 다시 읽습니다.

```bash
agent-browser get text @e1
agent-browser get html @e4
agent-browser get url
```

### 5) 필요하면 스크린샷과 종료

```bash
agent-browser screenshot result.png
agent-browser close
```

실제 운영에서는 이 패턴이 가장 자주 쓰입니다.

* 페이지를 연다
* 구조를 읽는다
* ref로 클릭한다
* 텍스트를 가져온다
* 필요하면 스냅샷을 다시 찍는다

검색 결과 확인, 관리자 화면 검증, 로그인 플로우 점검 같은 작업에 잘 맞습니다.

---

## 4. Playwright 함수와 비교

agent-browser는 내부적으로 Playwright 계열의 브라우저 자동화를 활용하지만, 사용자는 CLI로 접근합니다. 그래서 같은 동작도 체감은 꽤 다릅니다.

| agent-browser | Playwright | 설명 |
|---|---|---|
| `open https://site.com` | `page.goto('https://site.com')` | 페이지 이동 |
| `click "#submit"` | `page.locator('#submit').click()` | CSS selector 클릭 |
| `fill "#email" "a@b.com"` | `page.locator('#email').fill('a@b.com')` | 입력 값 채우기 |
| `find role button click --name "Submit"` | `page.getByRole('button', { name: 'Submit' }).click()` | 접근성 기반 탐색 |
| `find text "Sign In" click` | `page.getByText('Sign In').click()` | 텍스트 기반 탐색 |
| `wait --load networkidle` | `page.waitForLoadState('networkidle')` | 로드 상태 대기 |
| `get text @e1` | `locator.textContent()` | 텍스트 조회 |
| `snapshot` | `page.accessibility.snapshot()`에 가까운 개념 | 페이지 구조 확인 |
| `screenshot page.png` | `page.screenshot({ path: 'page.png' })` | 스크린샷 저장 |

### 차이점 정리

* **Playwright**
  * 코드로 정밀하게 제어하기 좋습니다.
  * 테스트 코드와 CI에 붙이기 좋습니다.
  * 반복문, 분기, 예외 처리 같은 복잡한 로직을 자유롭게 넣을 수 있습니다.

* **agent-browser**
  * CLI 중심이라 빠르게 시도하기 좋습니다.
  * AI 에이전트가 바로 읽고 실행하기 쉽습니다.
  * `snapshot`과 `@e1` ref 흐름이 안정적입니다.
  * 세션, 네트워크, 디버깅, 보안 옵션이 함께 들어 있습니다.

### 어떤 상황에 더 적합한가

* **Playwright**: 제품 테스트 코드, CI 자동화, 세밀한 회귀 테스트
* **agent-browser**: 운영 점검, 에이전트 기반 웹 탐색, 빠른 수동 검증, 쉘에서의 즉석 자동화

실무적으로는 둘 중 하나만 고르기보다, 테스트는 Playwright로 두고 사람과 AI가 빠르게 다루는 운영 자동화는 agent-browser로 분리하는 식이 잘 맞습니다.

---

## 5. tip

* 시작은 `snapshot -i`가 가장 편합니다. 상호작용 요소만 먼저 보면 판단이 빨라집니다.
* 가능하면 `@e1` 같은 ref를 우선 쓰세요. selector보다 안정적인 경우가 많습니다.
* 데이터는 `get text`, `get html`, `get url`처럼 목적별로 분리해서 가져오는 편이 좋습니다.
* 로그인 반복이 많다면 `--session-name` 또는 `--profile`을 써서 상태를 유지하세요.
* 디버깅은 `--headed`, `inspect`, `trace`를 같이 쓰면 훨씬 수월합니다.
* 외부 사이트를 다룰 때는 `--allowed-domains`와 `--confirm-actions` 같은 보안 옵션을 함께 고려하는 편이 안전합니다.
* 여러 단계를 한 번에 실행해야 하면 `batch`를 검토해 보세요. 프로세스 시작 비용을 줄일 수 있습니다.

---

## 6. 맺음말

agent-browser는 단순한 브라우저 자동화 도구가 아니라, AI 에이전트와 운영자가 함께 쓸 수 있는 웹 조작 인터페이스에 가깝습니다.  
Playwright처럼 정밀한 코딩 자동화와는 결이 다르지만, CLI 기반의 빠른 실험, 세션 유지, ref 기반 상호작용, 디버깅 기능까지 갖춰서 실무 친화성이 높습니다.

특히 DevOps 관점에서는 “반복적인 웹 운영 작업을 얼마나 안전하고 빠르게 자동화할 수 있느냐”가 중요한데, agent-browser는 그 지점을 꽤 잘 공략하고 있습니다.

## 참고 자료

* [vercel-labs/agent-browser GitHub](https://github.com/vercel-labs/agent-browser)
* [Playwright Locators 문서](https://playwright.dev/docs/locators)
* [Playwright Locator API](https://playwright.dev/docs/api/class-locator)
