---
title: 'OpenCode: AI 코딩 에이전트 가이드'
tags:
  - opencode
  - ai-agent
  - oh-my-opencode
  - lsp
  - sisyphus
---
OpenCode는 터미널 기반의 오픈소스 AI 코딩 에이전트로, 개발 생산성 향상을 목표로 합니다. LSP(Language Server Pro

## OpenCode 핵심 기능

### LSP (Language Server Protocol)

#### LSP 서버란?

#### LSP 자동 로드
OpenCode는 프로젝트를 열 때 `.lsproj` 파일이나 언어별 설정 파일을 자동으로 스캔하여 해당 프로젝트에 적합한 LSP 서버를 감지하고 설치 및 실행합니다. 예를 들어, TypeScript 프로젝트에서는 자동으로 TypeScript Language Server를 활성화합니다. 이 기능 덕분에 개발자는 별도의 수동 설정 없이 즉시 언어 서비스를 활용할 수 있으며, 에이전트는 LSP 서버와 통신하며 코드 분석, 편집, 리팩토링 등을 지원합니다.

### 기타 주요 기능
- **AST 기반 검색**: 코드의 문법적 구조를 표현하는 AST(Abstract Syntax Tree)를 분석하여 클래스, 함수, 변수 등을 정밀하게 탐색합니다. 이는 단순 텍스트 검색보다 훨씬 정확하고 강력한 코드 검색을 가능하게 합니다.
- **/undo 및 /redo**: 에이전트가 수정한 내용을 파일 또는 브랜치 단위로 쉽게 되돌리거나 재적용할 수 있습니다. 이를 통해 개발자는 실수에 대한 걱정 없이 에이전트의 변경 사항을 실험해볼 수 있습니다.
- **멀티 세션 관리**: 여러 프로젝트를 각각 독립된 세션으로 동시에 관리할 수 있어, 다양한 프로젝트 간의 컨텍스트 스위칭이 매우 간편합니다.

## 다른 CLI 도구와의 비교

OpenCode는 프라이버시, 오픈소스, 그리고 75개 이상의 LLM(Large Language Model) 지원을 강점으로 내세웁니다. 특히 Claude Code와 비교했을 때 모델 선택의 유연성이 뛰어납니다.

| 툴 | 모델 지원 | 강점 | 약점 |
|----|-----------|------|------|
| OpenCode  | 75+ | LSP/AST, /undo | 초기 설정 |
| Claude Code  | Claude | 서브 에이전트 | 모델 고정 |
| Codex CLI  | OpenAI | 속도 | 툴 미완성 |

## `oh-my-opencode`와 Sisyphus: AI 개발 팀의 구성

`oh-my-opencode`는 OpenCode의 확장 플러그인으로, 여러 전문 에이전트(하위 에이전트(SubAgent))로 구성된 팀을 오케스트레이션하여 복잡한 개발 작업을 수행합니다. 이 오케스트레이션의 중심에는 **Sisyphus**라는 메인 에이전트가 있습니다.

### `oh-my-opencode`의 역할
`oh-my-opencode`는 전문화된 에이전트 팀을 백그라운드에서 병렬로 실행하고, 컨텍스트를 자동으로 관리합니다. `AGENTS.md` 파일 주입, 토큰 사용량 모니터링 및 압축 등을 통해 에이전트들이 효율적으로 협업할 수 있는 환경을 제공합니다. 또한, Claude Code와 호환되는 레이어를 제공하여 유연성을 높였습니다.

### Oh My OpenCode(OMO)의 핵심 실행 모드: Sisyphus, Prometheus, Atlas

2026년 기준, Oh My OpenCode(OMO) 플러그인에서 제공하는 Sisyphus, Prometheus, Atlas는 서로 다른 목적을 가진 전문화된 AI 에이전트(모드)입니다. 주요 차이점은 다음과 같습니다.

1. **Sisyphus (시시포스): 메인 실행 에이전트**
   - **역할**: 실제 작업을 수행하고 끝까지 완수하는 '실행가'입니다.
   - **특징**: 사용자가 명령을 내리면 계획 수립부터 코드 작성, 테스트, 오류 수정까지의 과정을 스스로 반복(Loop)하며 최종 결과물을 만들어냅니다.
   - **작동 방식**: 프롬프트에 `ultrawork` 또는 `ulw` 키워드를 포함하면 활성화되며, 에러가 발생해도 중단 없이 해결책을 찾아 다시 시도하는 끈질긴 실행력이 핵심입니다.

2. **Prometheus (프로메테우스): 전략적 플래너**
   - **역할**: 복잡한 작업을 시작하기 전 세부 계획을 수립하는 '설계자'입니다.
   - **특징**: 사용자와의 인터뷰를 통해 프로젝트의 제약 사항, 선호하는 패턴 등을 파악하여 전략적인 작업 분해(Decomposition)를 수행합니다.
   - **작동 방식**: 프롬프트에서 `Tab` 키를 눌러 모드를 전환할 수 있습니다. 생성된 작업 계획은 `.sisyphus/plans/` 폴더에 저장되며, 이후 `/start-work` 명령으로 Sisyphus가 이를 실행하게 합니다.

3. **Atlas (아틀라스): 인프라 및 Git 관리**
   - **역할**: 주로 코드베이스의 구조를 관리하고 Git 관련 작업을 처리하는 '기반 관리자'입니다.
   - **특징**: Git 명령의 오류(stderr)를 캡처하여 도움말 텍스트 유출을 방지하거나, 코드의 구조적 의미를 파악하는 작업을 돕는 **마스터 오케스트레이터**입니다.
   - **차이점**: Sisyphus나 Prometheus에 비해 전면에 드러나기보다 백그라운드에서 프로젝트의 형상 관리와 환경 안정성을 보조하는 역할을 수행합니다.

#### 요약 비교

| 구분 | Sisyphus (시시포스) | Prometheus (프로메테우스) | Atlas (아틀라스) |
|---|---|---|---|
| **핵심 키워드** | 실행, 무한 루프, 완주 | 설계, 계획 수립, 인터뷰 | Git, 코드베이스 관리, 인프라 |
| **주요 모델** | Claude 3.5 Opus 등 고성능 | 추론/논리 특화 모델 | 성능보다는 정확도 위주 |
| **활용 시점** | 실제 코드를 고치고 실행할 때 | 작업 전 구체적 로드맵이 필요할 때 | Git 관리 및 인프라적 제어가 필요할 때 |

### 모델 에이전트 연동 (Auth)
`oh-my-opencode`는 `auth` 명령을 통해 다양한 LLM 제공업체(Claude, ChatGPT, Gemini 등)와의 연동을 지원합니다. 설치 후 다음 명령을 사용하여 각 제공업체의 인증을 구성할 수 있습니다.

```bash
opencode auth login
```
이 과정을 통해 에이전트가 각 LLM 서비스에 안전하게 접근하고 작업을 수행할 수 있도록 설정됩니다.

### subagent 협의 과정

`oh-my-opencode`는 Sisyphus 오케스트레이터의 지휘 아래, 7개 이상의 전문 에이전트 팀을 운영합니다. `oh-my-opencode.json` 파일을 통해 각 에이전트가 사용할 모델이나 권한을 세밀하게 설정할 수 있습니다.

| 에이전트 | 역할 | 최적 모델 예 | 호출 예 |
|----------|------|--------------|---------|
| @sisyphus | 오케스트레이터, 작업 계획 및 분배 | Claude 3 Opus | 자동 (사용자 직접 호출 불필요) |
| @oracle | 아키텍처 설계 및 코드 디버깅 | GPT-4 | `@oracle` 버그 수정해줘 |
| @librarian | 문서 및 코드 리서치 | Claude 3 Sonnet | `@librarian` API 문서 찾아줘 |
| @explore | 코드베이스 탐색 및 이해 | Grok Code | `@explore` utils/ 디렉토리 분석해줘 |
| @frontend-ui-ux-engineer | UI/UX 프로토타이핑 및 개발 | Gemini 1.5 Pro | 자동 (UI 관련 태스크 시) |
| @document-writer | 기술 문서 및 주석 작성 | Gemini 1.5 Flash | 자동 |
| @multimodal-looker | 이미지, PDF 등 시각 자료 분석 | Gemini 1.5 Flash | `@multimodal` diagram.png 설명해줘 |

Sisyphus는 전체 작업의 계획을 수립하고, 각 작업에 적합한 하위 에이전트에게 태스크를 분배하며, 이들의 실행을 조율하는 오케스트레이터입니다. 하위 에이전트들은 백그라운드에서 병렬로 작업을 실행하고, Sisyphus는 이 결과를 통합하고 검토합니다. 만약 추가 작업(TODO)이 발생하면, 다시 적절한 에이전트에게 분배하여 작업이 완료될 때까지 이 과정을 반복합니다.

## oh-my-opencode 기능: 명령어, 에이전트, 도구



### 슬래시 명령어 목록
기본 명령어에 더해 `oh-my-opencode`는 확장된 명령어들을 제공합니다. `~/.opencode/commands/*.md` 파일을 통해 새로운 명령어를 추가하여 무한히 확장할 수 있습니다.

| 명령어 | 기능 | 확장 여부 |
|--------|------|-----------|
| /init | 프로젝트 분석 및 `AGENTS.md` 생성 | 기본 |
| /undo | 마지막 변경 사항 취소 | 기본 |
| /redo | 취소된 변경 사항 재적용 | 기본 |
| /review | 코드 리뷰 (LSP/ESLint 연동 강화) | 확장 강화 |
| /share | 현재 세션 공유 링크 생성 | 기본 |
| /model | 사용 중인 AI 모델 변경 | 기본 |
| /clear | 대화 기록 지우기 | 기본 |
| /tasks | 백그라운드에서 실행 중인 태스크 목록 표시 | 확장 |
| /ralph-loop "작업" | 지정된 작업을 무한 반복 실행 (최대 100회, `/cancel-ralph`로 중지) | oh-my |
| /cancel-ralph | `ralph-loop`로 실행 중인 작업 중지 | oh-my |
| /summarize-diff | 변경된 내용 요약 | 커스텀 예 |
| /suggest-tests | 코드에 대한 테스트 케이스 제안 | 커스텀 예 |

### 도구 및 LSP
20개 이상의 내장 도구와 LSP 기능은 TUI 팔레트나 `call_omo_agent` 함수를 통해 호출할 수 있으며, 실시간 코드 분석과 조작을 지원합니다.

| 카테고리 | 주요 도구 | 기능 |
|----------|-----------|------|
| LSP (11개) | `lsp_hover`, `lsp_definition`, `lsp_references`, `lsp_rename`, `lsp_diagnostics` | 호버 정보, 정의 이동, 참조 찾기, 이름 변경, 실시간 진단 |
| AST-Grep (2개) | `search`, `replace` | 25개 이상 언어에 대한 구조적 코드 검색 및 치환 |
| Session (4개) | `session_list`, `read`, `search`, `info` | 세션 목록 확인, 읽기, 검색 등 세션 관리 |
| 기타 | 코드 변경 모니터, `context_window_monitor` | 실시간 파일 변경 추적 및 컨텍스트 관리 |

### Hook 시스템
20개 이상의 Hook은 에이전트의 동작을 특정 상황에 맞춰 자동화하여 개발 워크플로우의 일관성과 코드 품질을 유지합니다.

- **todo-continuation-enforcer**: TODO 리스트에 작업이 남아있으면 에이전트가 멈추지 않고 계속 실행하도록 강제합니다.
- **comment-checker**: 코드 내 불필요한 주석을 검사하고 제거합니다.
- **session-recovery**: 예기치 않게 세션이 종료되었을 때 복구를 돕습니다.
- **기타**: `notification`, `context-monitor` 등 다양한 자동화 Hook이 있습니다.









```

8000개 ESLint 경고 수정 ulw

```



### `@mention` 호출: 특정 전문가 호출하기
`@` 멘션은 `oracle`, `librarian` 등 특정 전문성을 가진 subagent를 직접 호출할 때 사용됩니다. 이는 자동화된 흐름에 더해, 사용자가 특정 작업을 명시적으로 지시하거나 우선순위를 부여하고 싶을 때 유용합니다.

- **`@oracle`**: 아키텍처 설계를 요청합니다.
- **`@librarian`**: 문서 검색을 지시합니다.

한 번 호출된 하위 에이전트의 컨텍스트는 세션 내에서 유지됩니다. Sisyphus는 이전에 호출된 에이전트를 기억하고, 필요에 따라 자동으로 재위임하여 작업의 연속성을 보장합니다. 따라서 매번 동일한 에이전트를 멘션할 필요는 없습니다.



| 방식 | 사용 시기 | 특징 |
|---|---|---|

| `@mention` | 특정 전문성이 필요한 질문/작업 | 해당 전문가를 직접 호출하며, 자동화된 흐름을 보강하는 역할 |



## 더 알아보기 (공식 링크 및 설치)

### OpenCode (Crush)

**참고**: OpenCode 프로젝트는 현재 아카이브되었으며, **Crush**라는 이름으로 개발이 계속되고 있습니다.

- **GitHub**: [https://github.com/opencode-ai/opencode](https://github.com/opencode-ai/opencode)

#### 설치 방법
- **Homebrew (macOS/Linux):**
  ```bash
  brew install opencode
  ```
- **Go Install:**
  ```bash
  go install github.com/opencode-ai/opencode@latest
  ```
- **설치 스크립트:**
  ```bash
  /bin/bash -c "$(curl -fsSL https://get.opencode.so)"
  ```

### oh-my-opencode

- **GitHub**: [https://github.com/code-yeongyu/oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)

#### 설치 방법
`bunx`나 `npx`를 사용하는 것이 권장되지만, `npm`으로 직접 설치할 수도 있습니다.

- **bunx (권장):**
  ```bash
  bunx oh-my-opencode install
  ```
- **npx (권장):**
  ```bash
  npx oh-my-opencode install
  ```
- **npm:**
  ```bash
  npm i -g oh-my-opencode
  ```
  
설치 과정에서 Claude, ChatGPT, Gemini 등 사용하고자 하는 LLM 구독 관련 설정을 진행하게 됩니다.

#### 사용 팁

- **커스터마이징**: 프로젝트 루트의 `.opencode/` 디렉토리 내에 `agents/`, `commands/`, `skills/`, `hooks/` 디렉토리를 생성하여 자신만의 에이전트, 명령어, 스킬, 훅을 추가할 수 있습니다.
- **모드 설정**: `opencode.json` 파일의 `modes` 설정을 통해 특정 작업을 제한할 수 있습니다. 예를 들어, `review` 모드를 만들어 읽기 전용으로 에이전트를 실행하는 것이 가능합니다.

