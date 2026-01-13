---
title: "OpenCode: AI 코딩 에이전트 가이드"

toc: true
toc_sticky: true

categories:
  - devops 
  
tags:
  - opencode
  - ai-agent
  - oh-my-opencode
  - lsp
  - sisyphus
---

OpenCode는 터미널 기반의 오픈소스 AI 코딩 에이전트로, 개발 생산성 향상을 목표로 합니다. LSP(Language Server Protocol) 자동 로드, AST(Abstract Syntax Tree) 기반 검색과 같은 고급 기능을 통해 강력한 코드 이해와 조작 능력을 제공합니다. 이 글에서는 OpenCode의 핵심 기능과 확장 플러그인인 `oh-my-opencode`에 대해 자세히 알아봅니다.

## OpenCode 핵심 기능

### LSP (Language Server Protocol)

#### LSP 서버란?
LSP(Language Server Protocol) 서버는 IDE나 텍스트 에디터와는 별개의 프로세스로 실행되는 서버입니다. JSON-RPC 통신을 통해 코드 자동 완성, 실시간 오류 진단, 정의 및 참조 이동 등 다양한 언어 관련 서비스를 제공합니다. LSP의 가장 큰 장점은 언어 서버 하나를 개발하면 여러 에디터와 도구에서 동일한 언어 지원을 재사용할 수 있다는 점입니다. OpenCode에서 에이전트는 LSP 서버와 통신하여 코드의 구조를 이해하고, 이를 바탕으로 정확한 코드 조작을 수행합니다.

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

### Sisyphus의 오케스트레이션
Sisyphus는 전체 작업의 계획을 수립하고, 각 작업에 적합한 하위 에이전트에게 태스크를 분배하며, 이들의 실행을 조율하는 오케스트레이터입니다. 마치 그리스 신화의 시시포스처럼, 주어진 작업이 완료될 때까지 "돌을 굴리는" 역할을 수행하며, TODO 리스트가 빌 때까지 멈추지 않고 작업을 지속합니다. `oh-my-opencode.json` 파일을 통해 사용할 모델을 지정할 수도 있습니다.

### 모델 에이전트 연동 (Auth)
`oh-my-opencode`는 `auth` 명령을 통해 다양한 LLM 제공업체(Claude, ChatGPT, Gemini 등)와의 연동을 지원합니다. 설치 후 다음 명령을 사용하여 각 제공업체의 인증을 구성할 수 있습니다.

```bash
opencode auth login
```
이 과정을 통해 에이전트가 각 LLM 서비스에 안전하게 접근하고 작업을 수행할 수 있도록 설정됩니다.

### 하위 에이전트의 종류와 특징
하위 에이전트는 각자 전문 분야를 가진 에이전트들로, `@` 멘션을 통해 호출될 수 있습니다. 이들은 LSP, AST와 같은 도구를 공유하며 협업합니다.

- **oracle**: 아키텍처 설계, 코드 리뷰 등 높은 수준의 추론이 필요한 작업을 담당합니다. (예: GPT-5.2)
- **librarian**: 문서, 코드베이스 등 방대한 자료를 탐색하고 정보를 요약합니다. (예: Claude/Gemini)
- **explore**: 대규모 코드베이스에서 특정 패턴이나 구현을 검색하는 데 특화되어 있습니다. (예: Grok/Gemini)
- **frontend-ui-ux-engineer**: UI 프로토타이핑 및 구현을 담당합니다. (예: Gemini 3 Pro)
- **document-writer**: 기술 문서나 보고서를 작성합니다.

### subagent 협의 과정
1.  사용자가 Sisyphus에게 작업을 지시합니다. (예: "ultrawork 기능 구현")
2. Sisyphus는 작업을 분석하여 계획을 세우고, 각 단계에 맞는 하위 에이전트에게 태스크를 분배합니다. (예: `@oracle`에게 설계 요청, `@librarian`에게 관련 문서 탐색 요청)
3. 하위 에이전트들은 백그라운드에서 병렬로 작업을 실행합니다. 이때 컨텍스트가 자동으로 주입되어 효율적인 협업이 이루어집니다.
4. Sisyphus는 하위 에이전트들의 작업 결과를 통합하고 검토합니다. 만약 추가 작업(TODO)이 발생하면, 다시 적절한 에이전트에게 분배하여 작업이 완료될 때까지 이 과정을 반복합니다.

## `ultrawork`와 `@mention`: Sisyphus 활용하기

`oh-my-opencode`의 강력한 오케스트레이션 기능을 활용하는 두 가지 주요 방법은 `ultrawork` 키워드와 `@mention` 호출입니다.

### `ultrawork` 키워드: 풀 파워 모드 활성화
`ultrawork` 또는 `ulw`는 `oh-my-opencode`의 모든 기능을 즉시 활성화하는 "마법의 트리거"입니다. 프롬프트에 이 키워드를 포함하면, Sisyphus가 자동으로 작업을 분석하고 subagent 팀을 동원하여 복잡한 개발 태스크를 끝까지 완수합니다.

**`ultrawork` 사용 예시:**
```
로그인 기능 구현해줘 ultrawork
8000개 ESLint 경고 수정 ulw
프로젝트 리팩토링 계획 세워줘 ultrawork
```

`ultrawork`는 복잡하고 여러 단계가 필요한 작업에 적합하며, Sisyphus가 최적의 에이전트를 자동으로 선택하고 지속적으로 실행을 관리합니다. 단, `ultrawork` 키워드는 **매번 호출**해야 하며, 한 번의 호출이 다음 작업으로 이어지지는 않습니다.

### `@mention` 호출: 특정 전문가 호출하기
`@` 멘션은 `oracle`, `librarian` 등 특정 전문성을 가진 subagent를 직접 호출할 때 사용됩니다. 이는 자동화된 흐름에 더해, 사용자가 특정 작업을 명시적으로 지시하거나 우선순위를 부여하고 싶을 때 유용합니다.

- **`@oracle`**: 아키텍처 설계를 요청합니다.
- **`@librarian`**: 문서 검색을 지시합니다.

한 번 호출된 하위 에이전트의 컨텍스트는 세션 내에서 유지됩니다. Sisyphus는 이전에 호출된 에이전트를 기억하고, 필요에 따라 자동으로 재위임하여 작업의 연속성을 보장합니다. 따라서 매번 동일한 에이전트를 멘션할 필요는 없습니다.

### `ultrawork` vs `@mention`

| 방식 | 사용 시기 | 특징 |
|---|---|---|
| `ultrawork` | 복잡한 멀티스텝 작업 | Sisyphus가 자동으로 팀 전체를 동원하고, 끝까지 지속 실행 |
| `@mention` | 특정 전문성이 필요한 질문/작업 | 해당 전문가를 직접 호출하며, 자동화된 흐름을 보강하는 역할 |

결론적으로, `ultrawork`는 복잡한 작업을 AI 개발 팀에게 맡기는 것과 같고, `@mention`은 팀의 특정 전문가에게 직접 질문하는 것과 같습니다. 이 두 가지 방식을 조합하여 OpenCode의 잠재력을 최대한 활용할 수 있습니다.

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
`bunx` 또는 `npx`를 사용하여 대화형 설치 프로그램을 실행합니다.

- **bunx:**
  ```bash
  bunx oh-my-opencode install
  ```
- **npx:**
  ```bash
  npx oh-my-opencode install
  ```
설치 과정에서 Claude, ChatGPT, Gemini 구독 관련 설정을 진행하게 됩니다.

