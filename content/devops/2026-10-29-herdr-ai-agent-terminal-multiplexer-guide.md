---
title: "Herdr 완벽 가이드: AI 코딩 에이전트를 위한 터미널 멀티플렉서 (vs tmux, 설치, 플러그인, Agent 통합)"
tags:
  - herdr
  - tmux
  - ai-agent
  - devops
  - terminal
  - cli
  - productivity
---

Claude Code, Codex, Devin, Cursor Agent CLI 등 다양한 AI 코딩 에이전트가 개발 일상의 핵심 도구로 자리 잡으면서, 엔지니어들의 작업 방식에도 큰 변화가 생겼습니다. 이제 개발자는 하나의 터미널에서 코드를 직접 치는 것을 넘어, 여러 개의 에이전트를 동시에 띄워두고 백그라운드에서 병렬로 작업을 지시하는 <strong>멀티 에이전트 지휘관(Coordinator)</strong>의 역할을 맡고 있습니다.

하지만 수십 년간 엔지니어의 필수 도구였던 `tmux`나 `screen` 같은 전통적인 터미널 멀티플렉서는 이러한 에이전트 워크플로우를 소화하기에 한계가 명확합니다. 세션이 끊기지 않게 터미널 프로세스를 유지할 수는 있지만, <strong>"현재 에이전트가 연산 중인지, 사용자 입력을 기다리는 블록 상태인지, 아니면 작업이 끝났는지"</strong>를 전혀 알지 못하기 때문입니다.

이러한 문제를 해결하기 위해 등장한 Rust 기반의 차세대 터미널 런타임/멀티플렉서가 바로 <strong>Herdr(허더)</strong>입니다. 흔히 <strong>"tmux for AI agents"</strong>라고 불리는 Herdr의 기본 철학, tmux와의 구조적 차이, 설치 및 운영 노하우, 그리고 플러그인과 추가 Agent 통합(Integration) 방법까지 상세히 살펴보겠습니다.

---

## 1. Herdr의 기본 개념 및 tmux와의 비교

### Herdr란 무엇인가?

Herdr는 복수의 AI 코딩 에이전트를 안정적으로 실행, 모니터링, 오케스트레이션할 수 있도록 설계된 <strong>에이전트 인식형(Agent-Aware) 터미널 멀티플렉서</strong>입니다.

기존 멀티플렉서가 단순히 화면을 여러 패널(Pane)로 쪼개고 PTY(의사 터미널) 바이트 스트림을 전송하는 수준에 머물렀다면, Herdr는 내부에 <strong>에이전트 생명주기 감지 엔진(Agent Lifecycle Engine)</strong>과 <strong>로컬 소켓 IPC API</strong>를 내장하고 있습니다. 이를 통해 에이전트가 사람의 개입을 기다리고 있을 때 즉각 알림을 보내고, 심지어 에이전트가 다른 에이전트의 패널을 프로그래밍 방식으로 제어할 수 있도록 지원합니다.

```text
[전통적인 Tmux 환경]
+------------------------------------------------------+
| tmux server (블라인드 바이트 스트림 전달)               |
|  - Pane 1: bash (Claude Code 실행 중 - 상태 모름)      |
|  - Pane 2: bash (Codex 실행 중 - 프롬프트 대기 중?)     |
|  - Pane 3: bash (테스트 실행 중 - 끝났는지 모름)        |
+------------------------------------------------------+
 * 엔지니어가 각 창을 일일이 눌러보며 상태를 눈으로 확인해야 함

[Herdr 환경]
+------------------------------------------------------+
| Herdr Server & Daemon (Agent Runtime & Socket API)   |
|  - Pane 1: [Claude Code] ⚡ Working (토큰 생성 중)     |
|  - Pane 2: [Codex]       ⏸️ Blocked (사용자 승인 대기) -> OS 알림 발송 |
|  - Pane 3: [Unit Test]   ✅ Done (성공 종료)           |
+------------------------------------------------------+
 * Socket API를 통해 에이전트가 상호 소통하거나 새 창을 직접 스폰 가능
```

---

### Herdr vs tmux 핵심 비교

| 비교 항목 | tmux | Herdr |
| :--- | :--- | :--- |
| **주요 목적** | 범용 터미널 세션 유지 및 화면 분할 | AI 코딩 에이전트 동시 실행 및 라이프사이클 관리 |
| **구현 언어** | C | Rust (고성능, 메모리 안정성, 크로스플랫폼) |
| **프로세스 영속성** | 지원 (세션 Detach/Attach) | 지원 (세션 Detach/Attach 및 백그라운드 데몬) |
| **에이전트 상태 인지** | **미지원** (텍스트 스트림만 취급) | **지원** (Working, Blocked, Done, Idle 등 감지) |
| **상태 알림 (Notification)**| 벨 소리/단순 시각 알림 수준 | 데스크톱/메신저(Slack/Telegram) 에이전트 상태 연동 |
| **자동화 / API 제어** | `tmux send-keys` 등 셸 명령어 주입 | 일급 CLI 및 JSON Socket IPC API (에이전트가 직접 제어) |
| **작업 공간(Workspace)** | 세션(Session) / 윈도우 / 패널 분할 | Git Worktree 및 프로젝트 기반 워크스페이스 통합 |
| **플러그인 생태계** | TPM (Tmux Plugin Manager, 셸 스크립트) | GitHub 기반 패키지 매니저 (`herdr plugin`) |
| **원격 세션 감독** | SSH 접속 후 tmux attach | `herdr --remote <host>` 원격 오케스트레이션 지원 |

tmux가 리눅스 서버 운영 및 단순 다중 세션 관리에 여전히 훌륭한 범용 도구라면, <strong>Herdr는 "로컬 및 원격에서 다수의 AI 에이전트를 동시에 돌리며 협업하는 개발 환경"에 완벽히 최적화된 특화 도구</strong>입니다.

---

## 2. Herdr의 핵심 아키텍처 및 특징

Herdr가 AI 에이전트 멀티플렉서로서 지니는 차별화된 기능은 다음과 같습니다.

### 1) Agent Lifecycle Awareness (상태 추적)
에이전트의 훅(Hook)과 PTY 출력을 종합하여 현재 패널의 상태를 실시간으로 분류합니다.
- **`Working` (⚡)**: 에이전트가 파일 분석, 코드 수정, 외부 툴을 호출하며 작업 중인 상태
- **`Blocked` (⏸️)**: 도구 실행 승인, 추가 질의 등 사용자의 입력(Input)을 기다리는 상태
- **`Done` (✅)**: 요청된 태스크가 완료된 상태
- **`Idle` (💤)**: 다음 작업을 기다리는 대기 상태

터미널 하단 상태바나 사이드바에서 수십 개의 패널 상태를 한눈에 파악할 수 있으며, `Blocked` 상태로 전환될 때 OS 네이티브 알림을 띄워 컨텍스트 스위칭 비용을 최소화합니다.

### 2) Agent-Native CLI & Local Socket API
Herdr는 터미널 에뮬레이터이자 동시에 로컬 소켓 서버입니다. 외부 셸 스크립트는 물론, **패널 안에서 실행 중인 AI 에이전트 스스로가 Herdr CLI나 JSON 소켓을 호출**하여 다른 에이전트를 제어할 수 있습니다.
- "A 에이전트가 백엔드 API를 수정한 뒤, Herdr API를 호출하여 B 에이전트(프론트엔드 담당)의 패널을 새로 띄우고 테스트를 지시"하는 완전 자율 오케스트레이션이 가능해집니다.

### 3) Git Worktree 및 워크스페이스 관리
동일한 리포지토리에서 여러 에이전트가 동시에 작업할 경우 파일 충돌(Conflict)이 발생하기 쉽습니다. Herdr는 Git Worktree와 긴밀하게 결합되어 있어, 탭이나 워크스페이스를 생성할 때 자동으로 별도 브랜치와 Worktree 디렉토리를 격리 매핑해 줍니다.

---

## 3. Herdr 설치 및 운영 가이드

### 1) 설치 방법

Herdr는 다양한 패키지 매니저와 설치 스크립트를 지원합니다.

#### macOS & Linux (Homebrew 권장)
```bash
brew install herdr
```

#### 공식 원라인 셸 인스톨러 (macOS / Linux)
```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

#### Cargo (Rust 소스 빌드)
최신 릴리스 소스코드를 직접 빌드하려는 경우:
```bash
git clone https://github.com/herdrdev/herdr
cd herdr
cargo build --release
sudo cp target/release/herdr /usr/local/bin/
```

#### Mise / Nix 환경
```bash
# mise 사용 시
mise use -g herdr

# Nix 사용 시
nix profile install github:herdrdev/herdr
```

설치가 완료되면 버전을 확인합니다:
```bash
herdr --version
```

---

### 2) 필수 운영 설정 (`config.toml`)

Herdr는 기본 설정만으로도 즉시 실행되지만, 키바인딩과 상태 감지 주기, 알림 설정을 튜닝하기 위해 설정 파일을 생성하는 것이 좋습니다.

#### 설정 파일 기본 템플릿 생성
```bash
# 기본 설정 디렉토리 생성 및 템플릿 출력
mkdir -p ~/.config/herdr
herdr --default-config > ~/.config/herdr/config.toml
```

#### 핵심 설정 예시 (`~/.config/herdr/config.toml`)
```toml
# 기본 터미널 셸 지정
default_shell = "/bin/zsh"

# tmux 스타일 프리픽스 키 설정 (기본값: Ctrl-a 또는 Ctrl-b 중 선호 설정)
prefix_key = "Ctrl-b"

[notifications]
# 에이전트가 사용자 입력을 기다릴 때(Blocked) 데스크톱 알림 띄우기
notify_on_blocked = true
# 태스크 완료 시(Done) 알림
notify_on_done = true
# 알림 사운드 재생 여부
sound = true

[ui]
# 상태바 위치 ("top" 또는 "bottom")
status_bar_position = "bottom"
# 에이전트 상태 아이콘 테마 ("nerdfont", "emoji", "ascii")
icon_theme = "nerdfont"
# 패널 테두리 스타일
border_style = "rounded"

[server]
# 백그라운드 세션 소켓 경로
socket_path = "~/.local/share/herdr/herdr.sock"
# 비활성 세션 유지 시간 (초)
session_timeout = 86400
```

#### 무중단 설정 리로드 (Zero-Downtime Reload)
설정 파일을 수정한 후 실행 중인 에이전트 프로세스나 패널을 종료할 필요가 없습니다. 다음 명령어로 즉시 반영됩니다:
```bash
herdr server reload-config
```

---

### 3) 기본 운영 명령어

Herdr는 tmux와 유사한 클라이언트-서버 모델을 따릅니다.

| 작업 내용 | 명령어 | 비고 |
| :--- | :--- | :--- |
| **새 세션 시작** | `herdr` 또는 `herdr new -s <세션명>` | 기본 터미널 클라이언트 진입 |
| **세션 백그라운드 분리** | `Ctrl-b` 누른 후 `d` (Detach) | 터미널 창을 닫아도 에이전트는 계속 동작 |
| **세션 목록 확인** | `herdr list` | 활성 세션 및 포함된 패널 수 조회 |
| **세션 재연결** | `herdr attach -s <세션명>` | 백그라운드 세션 복귀 |
| **서버 데몬 상태 점검**| `herdr server status` | 백그라운드 데몬 및 소켓 상태 확인 |
| **원격 세션 접속** | `herdr --remote dev-server.internal` | SSH를 경유한 원격 인스턴스 세션 제어 |

---

## 4. 플러그인 생태계 확인 및 설치 관리

Herdr는 커뮤니티 플러그인 아키텍처를 기본 탑재하고 있습니다. GitHub 리포지토리(`herdr-plugin` 토픽)를 기반으로 배포되며, 전용 CLI 명령어를 통해 간편하게 확장할 수 있습니다.

### 1) 플러그인 관리 CLI 기본 사용법

#### 플러그인 설치
GitHub의 `<소유자>/<저장소>` 형식으로 바로 설치할 수 있습니다:
```bash
# 기본 플러그인 설치 문법
herdr plugin install <owner>/<repo>

# 필수 추천: 플러그인 관리자 (TUI 팝업 매니저) 설치
herdr plugin install speardragon/herdr-plugin-manager

# 멀티 에이전트 프로젝트 보드 플러그인 설치
herdr plugin install eliasstravik/herdr-projects

# 에이전트 코드 리뷰/Diff 전용 패널 플러그인 설치
herdr plugin install persiyanov/herdr-reviewr

# 텔레그램 알림 플러그인 설치 (서브디렉토리 지정 예시)
herdr plugin install ogulcancelik/herdr-plugin-examples/agent-telegram-notify
```

#### 로컬 개발 플러그인 연결 (Symlink)
자신만의 플러그인을 개발하거나 커스텀 셸 스크립트를 테스트할 때는 `link` 명령을 사용합니다:
```bash
herdr plugin link ~/dev/my-custom-herdr-plugin
```

#### 플러그인 목록 조회, 업데이트 및 제거
```bash
# 설치된 플러그인 목록 확인
herdr plugin list

# 전체 플러그인 최신 버전으로 일괄 업데이트
herdr plugin update

# 특정 플러그인의 액션(Action) 목록 확인
herdr plugin action list --plugin herdr-plugin-manager

# 플러그인 제거
herdr plugin uninstall speardragon/herdr-plugin-manager
```

---

### 2) 주목할 만한 추천 핵심 플러그인 및 설정

#### 1. `herdr-plugin-manager` (`speardragon/herdr-plugin-manager`)
tmux의 TPM처럼, Herdr 내부에서 대화형 TUI 팝업을 띄워 설치된 플러그인을 활성화/비활성화하고 새로운 플러그인을 검색·설치할 수 있는 공식 준거 매니저입니다.

- **설치 명령어**:
  ```bash
  herdr plugin install speardragon/herdr-plugin-manager
  ```
- **단축키 연동 설정 (`~/.config/herdr/config.toml`)**:
  설치 후 `prefix + p` 키를 눌러 언제든 플러그인 매니저 창을 띄울 수 있도록 키바인딩을 등록합니다:
  ```toml
  [[keys.command]]
  key = "prefix+p"
  type = "plugin_action"
  command = "herdr-plugin-manager.open"
  description = "Open Herdr Plugin Manager Popup"
  ```

#### 2. `herdr-projects` (`eliasstravik/herdr-projects`)
대규모 멀티 에이전트 협업을 위한 **미션 컨트롤 대시보드**입니다. 중앙 Coordinator 보드를 제공하여 각 패널에서 돌아가는 에이전트들의 작업 진척도를 간반 보드 형태로 시각화합니다.
- **설치 명령어**:
  ```bash
  herdr plugin install eliasstravik/herdr-projects
  ```

#### 3. `herdr-reviewr` (`persiyanov/herdr-reviewr`)
여러 에이전트가 수정한 코드 변경사항(Git Diff)을 전용 패널에서 실시간으로 확인하고, 라인별 리뷰 코멘트를 에이전트의 터미널 입력으로 곧바로 되돌려주는 코드 리뷰 보조 플러그인입니다.
- **설치 명령어**:
  ```bash
  herdr plugin install persiyanov/herdr-reviewr
  ```

#### 4. `agent-slack-notify` / `agent-telegram-notify`
긴 빌드나 대규모 리팩토링 작업을 에이전트에 맡겨두고 자리를 비웠을 때, 에이전트가 `Blocked`(승인 요청)나 `Done`(완료) 상태가 되면 모바일 메신저로 즉시 핑을 전송해 줍니다.
- **설치 예시 (텔레그램)**:
  ```bash
  herdr plugin install ogulcancelik/herdr-plugin-examples/agent-telegram-notify
  ```

---

## 5. 추가 Agent 확인 및 통합(Integration) 가이드

Herdr의 가장 강력한 특징은 다양한 AI 코딩 에이전트와의 <strong>네이티브 통합(Integrations)</strong>입니다. 에이전트가 Herdr의 상태 추적 메커니즘과 연동되도록 훅(Hook)과 환경을 자동으로 구성해 줍니다.

### 1) 지원 에이전트 상태 점검 (`integration status`)

현재 시스템에 설치된 에이전트와 Herdr 간의 연동 상태를 확인하려면 다음 명령을 실행합니다:

```bash
herdr integration status
```

출력 결과에는 PATH에 등록된 CLI 도구들과 통합 스크립트 설치 여부가 표시됩니다:
```text
Agent Integration Status:
--------------------------------------------------
Claude Code (claude)       : [Installed & Active]
Codex CLI (codex)          : [Installed & Active]
Antigravity CLI            : [Installed & Active]
GitHub Copilot CLI         : [Not Integrated] - Run: herdr integration install copilot
Devin CLI (devin)          : [Available]
Cursor Agent CLI (cursor)  : [Installed & Active]
OpenCode (opencode)        : [Available]
Hermes Agent (hermes)      : [Available]
...
```

---

### 2) 공식 지원 Agent 목록

Herdr는 최신 주요 AI 코딩 에이전트들을 폭넓게 지원합니다:

| 에이전트 이름 | 통합 식별자 (`<name>`) | 주요 연동 특징 |
| :--- | :--- | :--- |
| **Claude Code** | `claude` | 세션 ID 바인딩, 입력 대기/응답 생성 상태 훅 자동 연결 |
| **Codex** | `codex` | `features.hooks` 자동 활성화 및 상태 스크립트 주입 |
| **Antigravity CLI** | `antigravity-cli` | 서브에이전트 스폰 및 세션 상태 양방향 연동 |
| **Cursor Agent CLI**| `cursor` | 커서 백엔드 세션 감지 및 완료 상태 전달 |
| **GitHub Copilot** | `copilot` | CLI 명령 실행 및 권한 승인 대기 상태 추적 |
| **Devin CLI** | `devin` | 원격 작업 세션 모니터링 연동 |
| **Hermes Agent** | `hermes` | DevOps 자동화 태스크 라이프사이클 추적 |
| **OpenCode** | `opencode` | 오픈소스 모델 기반 코딩 에이전트 상태 연동 |
| **Pi / OMP / Grok** | `pi`, `omp`, `grok` | 각 에이전트별 터미널 타이틀 및 상태 프로토콜 연동 |

---

### 3) 에이전트 통합 설치 및 동작 원리

새로운 에이전트를 Herdr와 연동하려면 `herdr integration install` 명령어를 사용합니다.

```bash
# Hermes Agent 연동 설치
herdr integration install hermes

# Claude Code 연동 설치
herdr integration install claude

# Codex 연동 설치
herdr integration install codex

# Antigravity CLI 연동 설치
herdr integration install antigravity-cli
```

#### 통합 설치 시 에이전트별 내부 동작 방식
Herdr는 에이전트의 구조에 따라 최적의 공식 통합 인터페이스를 자동으로 구성합니다:
1. **플러그인 방식 (Hermes 등)**: 에이전트 전용 플러그인 디렉토리(`~/.hermes/plugins/herdr-agent-state/`)에 공식 상태 모듈을 배포하고, 설정 파일의 `plugins.enabled` 항목을 자동으로 패치합니다.
2. **훅 스크립트 방식 (Codex 등)**: 에이전트 설정 파일(`~/.config/codex/config.toml`)의 `[features] hooks = true`를 켜고 상태 전달 래퍼 스크립트를 연결합니다.
3. **IPC 소켓 통신**: 에이전트가 동작할 때(도구 호출, 사용자 입력 대기, 작업 완료 등) 백그라운드에서 Herdr 로컬 소켓으로 JSON 상태 메시지를 자동 전송합니다:
   ```json
   {
     "pane_id": "%3",
     "agent": "hermes",
     "state": "blocked",
     "reason": "awaiting_user_confirmation"
   }
   ```
4. Herdr 서버는 이 이벤트를 수신하여 즉각 UI 상태바를 갱신하고 알림을 발생시킵니다.

통합을 제거하고 기본 상태로 되돌리고 싶다면 언제든지 다음 명령을 실행할 수 있습니다:
```bash
herdr integration uninstall <name>
```

---

### 4) 실전 예제: Hermes Agent 공식 통합 설치 및 세팅

DevOps 자동화 및 시스템 운영 도구로 널리 쓰이는 **Hermes Agent**(`hermes`)를 Herdr 환경에 연동하는 공식 세팅 과정입니다.

#### Step 1: Hermes 공식 통합 모듈 설치
터미널에서 다음 명령을 실행하여 Herdr 전용 Hermes 통합 모듈을 설치합니다:
```bash
herdr integration install hermes
```

설치 명령이 실행되면 Herdr는 백그라운드에서 다음 작업을 자동으로 완료합니다:
1. `~/.hermes/plugins/herdr-agent-state/` 디렉토리에 상태 추적 전용 네이티브 플러그인 설치
2. `~/.hermes/config.yaml` 파일의 `plugins.enabled` 리스트에 `- herdr-agent-state` 자동 등록

설치 후 정상 연동 여부를 확인합니다:
```bash
herdr integration status
```
```text
Agent Integration Status:
--------------------------------------------------
Hermes Agent (hermes)      : [Installed & Active]
...
```

#### Step 2: Hermes 환경 설정 확인 (`~/.hermes/config.yaml`)
`~/.hermes/config.yaml` 파일을 열어 공식 플러그인(`herdr-agent-state`)이 활성화 목록에 정상 등록되었는지 확인합니다:

```yaml
# ~/.hermes/config.yaml

plugins:
  enabled:
    - herdr-agent-state    # Herdr 통합 설치 시 자동으로 주입되는 공식 플러그인
```

만약 커스텀 설정을 유지하고 계신다면, 위와 같이 `plugins.enabled` 하위에 `- herdr-agent-state`가 포함되어 있는지만 점검하시면 됩니다.

> [!TIP]
> **왜 셸 스크립트 훅(`hooks`) 대신 네이티브 플러그인(`herdr-agent-state`)인가?**
> 외부 셸 스크립트를 실행하는 서브프로세스 방식과 달리, 공식 `herdr-agent-state` 플러그인은 Hermes의 이벤트 루프에 직접 결합되어 동작합니다. 덕분에 프로세스 생성 오버헤드가 없으며, 실시간 세션 복원 ID(Resumable Session ID), LLM 토큰 생성 상태, 프롬프트 입력 대기(`Blocked`) 상태를 Herdr 소켓으로 오차 없이 전달합니다.

#### Step 3: Herdr 세션에서 Hermes 실행 및 모니터링
이제 Herdr 내부 패널에서 Hermes를 실행하면 모든 라이프사이클이 실시간으로 추적됩니다:

```bash
# Herdr 세션 진입
herdr new -s hermes-ops

# Hermes 실행
hermes
```

- **태스크 진행 중**: 상태바에 `[hermes] ⚡ Working` 아이콘 표시.
- **도구 실행 승인 대기**: `/plan` 수립 후 위험한 셸 명령(예: `kubectl delete` 또는 `terraform apply`) 승인을 요청할 때 자동으로 `⏸️ Blocked` 상태로 전환되며, 시스템 데스크톱 알림이 발생합니다.
- **백그라운드 위임**: `/bg`로 대규모 분석 작업을 던져두면 작업이 끝나는 즉시 `✅ Done` 상태로 갱신됩니다.

---

## 6. Herdr CLI 핵심 명령어 치트시트 (Cheatsheet & Quick Reference)

Herdr의 가장 강력한 무기는 모든 UI 조작(탭 생성, 화면 분할, 텍스트 전송, 프로세스 모니터링)을 터미널 CLI와 JSON 소켓 API를 통해 100% 자동화할 수 있다는 점입니다. 

중앙 코디네이터 에이전트나 셸 스크립트에서 호출할 수 있는 핵심 제어 명령어를 카테고리별로 정리한 치트시트입니다.

### 1) 탭 & 워크스페이스 제어 (`herdr tab`)

| 목적 | 명령어 예제 | 설명 |
| :--- | :--- | :--- |
| **탭 목록 조회** | `herdr tab list [--workspace <id>]` | 활성 탭 목록 및 각 탭의 기본 패널 ID 출력 |
| **새 탭 생성** | `herdr tab create --label "Dev" --cwd ~/project` | 작업 디렉터리 및 라벨 지정 탭 생성 |
| **백그라운드 탭 생성** | `herdr tab create --label "Build" --no-focus` | 현재 화면 전환 없이 백그라운드 탭 기동 |
| **탭 포커스 이동** | `herdr tab focus <tab_id>` | 지정한 탭으로 화면 전환 |
| **탭 이름 변경** | `herdr tab rename <tab_id> "Refactor"` | 탭 라벨 즉시 변경 |
| **탭 닫기** | `herdr tab close <tab_id>` | 탭 및 내부 모든 패널 일괄 종료 |

```bash
# 실전 팁: 신규 탭 생성 후 반환된 패널 ID 추출 (JSON 파싱)
PANE_ID=$(herdr tab create --label "Backend" --cwd ~/repo/server --focus | jq -r '.pane_id // .panes[0].id')
```

---

### 2) 패널 레이아웃 & 분할 제어 (`herdr pane`)

| 목적 | 명령어 예제 | 설명 |
| :--- | :--- | :--- |
| **패널 목록 조회** | `herdr pane list` | 세션 내 모든 패널의 ID, 상태, 실행 프로세스 확인 |
| **패널 상세 및 상태 조회** | `herdr pane get <pane_id>` | 에이전트 상태(`working`, `blocked` 등) 및 버퍼 확인 |
| **우측 패널 분할 (가로)** | `herdr pane split <pane_id> --direction right` | 대상 패널 우측으로 새 패널 분할 생성 |
| **하단 패널 분할 (세로)** | `herdr pane split <pane_id> --direction down` | 대상 패널 하단으로 새 패널 분할 생성 |
| **작업 디렉터리 지정 분할** | `herdr pane split <pane_id> --cwd ../wt-test` | 특정 Git Worktree 경로를 지정하여 분할 |
| **패널 포커스 이동** | `herdr pane focus <pane_id>` | 특정 패널로 커서 및 입력 포커스 전환 |
| **패널 종료 (자원 회수)** | `herdr pane close <pane_id>` | 해당 패널 프로세스 종료 및 패널 제거 |

```bash
# 실전 팁: 좌우 분할 후 우측 패널 ID 획득
RIGHT_PANE=$(herdr pane split $PANE_ID --direction right --cwd ~/repo/frontend | jq -r '.id')
```

---

### 3) 에이전트 실행 & 상호작용 I/O 제어

| 목적 | 명령어 예제 | 설명 |
| :--- | :--- | :--- |
| **프로세스/에이전트 실행** | `herdr pane run <pane_id> "claude"` | 패널 내부에서 특정 CLI 명령어 또는 에이전트 기동 |
| **텍스트 / 프롬프트 주입** | `herdr pane send-text <pane_id> "npm test\n"` | 패널로 문자열 및 개행(`\n`) 주입 (명령 실행) |
| **인터럽트 시그널 전송** | `herdr pane send-text <pane_id> $'\x03'` | 교착 상태 에이전트에 `Ctrl+C` 인터럽트 전송 |
| **특정 출력 대기 (Sync)** | `herdr pane wait-output <pane_id> "<pattern>"` | 지정한 정규식이나 마커가 출력될 때까지 동기 대기 |
| **최근 버퍼 라인 스캔** | `herdr pane get <pane_id> \| jq -r '.last_line'` | 마지막 터미널 출력 한 줄 파싱 |

```bash
# 실전 팁: 에이전트 실행 -> 지침 전달 -> 완료 마커 대기
herdr pane run $RIGHT_PANE "codex"
herdr pane send-text $RIGHT_PANE "Run unit tests and emit [DONE] when complete.\n"
herdr pane wait-output $RIGHT_PANE "\[DONE\]" --lines 100
```

---

### 4) 원격 머신 관리 (`herdr machine`)

| 목적 | 명령어 예제 | 설명 |
| :--- | :--- | :--- |
| **등록된 원격 머신 목록** | `herdr machine list` | SSH 연결 프로필 목록 및 온라인 연결 상태 확인 |
| **원격 SSH 머신 추가** | `herdr machine add deploy@gpu-host --label "GPU-1"` | 원격 호스트 등록 |
| **원격 머신 프로필 활성화** | `herdr machine enable <profile_id>` | 지정 호스트 자동 연결 활성화 |
| **원격 머신 프로필 비활성화** | `herdr machine disable <profile_id>` | 일시적 비활성화 |
| **원격 머신 프로필 삭제** | `herdr machine remove <profile_id>` | 등록 해제 |

```bash
# 실전 팁: 하단 패널 분할 후 원격 GPU 서버 즉시 접속
REMOTE_PANE=$(herdr pane split $PANE_ID --direction down | jq -r '.id')
herdr pane run $REMOTE_PANE "ssh gpu-node-1"
```

---

### 5) 세션, 서버 및 플러그인 유틸리티

| 목적 | 명령어 예제 | 설명 |
| :--- | :--- | :--- |
| **세션 목록 확인** | `herdr list` | 현재 구동 중인 세션명 및 패널 개수 출력 |
| **백그라운드 세션 복귀** | `herdr attach -s <session_name>` | Detached 상태의 세션 재연결 |
| **서버 데몬 상태 점검** | `herdr server status` | 백그라운드 PTY 데몬 헬스체크 |
| **설정 무중단 리로드** | `herdr server reload-config` | `config.toml` 수정사항 즉시 반영 |
| **에이전트 통합 상태 확인** | `herdr integration status` | 지원 에이전트 연동 여부 점검 |
| **새 에이전트 통합 설치** | `herdr integration install hermes` | 에이전트 전용 훅/플러그인 자동 주입 |

---

### 6) 실전 콤보 레시피 (Quick Automation Recipes)

#### Recipe 1. 독립 Worktree 기반 "구현 + 테스트" 2분할 환경 즉시 셋업
```bash
# 탭 생성과 동시에 좌우 패널로 분할하여 Claude Code와 Codex 동시 가동
TAB=$(herdr tab create --label "Dev-TDD" --focus)
P1=$(echo $TAB | jq -r '.pane_id // .panes[0].id')
P2=$(herdr pane split $P1 --direction right | jq -r '.id')
herdr pane run $P1 "claude"
herdr pane run $P2 "codex"
```

#### Recipe 2. 대화형 차단(Blocked) 자동 감지 및 승인 주입 워치독 루프
```bash
# 패널 상태가 blocked일 때 자동으로 y 입력 전송
while true; do
  STATE=$(herdr pane get $PANE_ID | jq -r '.agent_state')
  if [ "$STATE" = "blocked" ]; then
    echo "Detected prompt! Auto-approving..."
    herdr pane send-text $PANE_ID "y\n"
    break
  fi
  sleep 2
done
```

---

## 7. Hermes & Herdr 멀티 에이전트 심층 오케스트레이션 시나리오 (Deep Multi-Agent Orchestration)

개별 에이전트의 단순 실행을 넘어, 중앙 코디네이터인 **Hermes Agent**와 에이전트 런타임인 **Herdr**가 결합하면 진정한 의미의 **자율 멀티 에이전트 협업 파이프라인**이 완성됩니다.

중앙 코디네이터 에이전트는 사용자의 고수준 목표를 접수한 뒤, Herdr CLI와 IPC 소켓을 호출하여 화면 분할(Pane Split), 독립 작업공간(Git Worktree) 할당, 원격 SSH 노드 연결, 비동기 상태 추적(OSC 7501)을 프로그래밍 방식으로 조율합니다.

```text
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      Hermes Multi-Agent Coordinator                             │
│       - Workflow Planning & Dependency Graph                                    │
│       - Pane Topology Management (Split / Tabs / Worktrees / SSH)               │
│       - OSC 7501 Heartbeat & Deadlock Intervention                              │
└───────┬─────────────────────────┬─────────────────────────┬─────────────────────┘
        │ Task Dispatch & Sync    │ Feedback Handoff        │ State Polling
        ▼                         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐      ┌─────────────────────────────┐
│ Implementer Pane │ ───> │ Reviewer / QA    │      │ Remote Compute Host (SSH)   │
│ [Claude Code]    │ <─── │ [Codex / Pi]     │      │ [GPU Training / Build Node] │
└──────────────────┘      └──────────────────┘      └─────────────────────────────┘
```

다음은 현업에서 즉시 활용할 수 있는 **7가지 핵심 심층 오케스트레이션 시나리오**와 프롬프트 규격입니다.

---

### 시나리오 1. 병렬 기능 구현 및 테스트 주도 동기화 (Implementer-Tester Worktree Pipeline)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 2개 패널 분할 (좌: 메인 구현 에이전트 `Claude Code`, 우: TDD 테스트 엔지니어 `Codex`)
- **격리 및 동기화 메커니즘:** 동일 코드베이스에서 작업 충돌(Race Condition)을 방지하기 위해 Git Worktree로 `feature/auth-impl`과 `feature/auth-test` 디렉터리를 각각 분리 할당합니다. Hermes는 구현 에이전트의 인터페이스 스펙 변경을 감지하고, 테스트 패널에 스펙 업데이트 이벤트를 실시간 주입하여 테스트 스위트를 동기화합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  sequenceDiagram
      autonumber
      participant H as Hermes Coordinator
      participant HD as Herdr Daemon
      participant C as Claude Code (Impl)
      participant T as Codex (QA/Test)

      H->>HD: Git Worktree 생성 & 탭/패널 분할 (좌/우)
      H->>C: 기능 구현 지침 및 API 인터페이스 정의 발송
      H->>T: TDD 테스트 케이스 및 모의 객체 작성 지침 발송
      C-->>HD: OSC 7501 "working" -> API 초안 커밋
      HD-->>H: 인터페이스 생성 감지 (wait-output)
      H->>T: 구현 브랜치 diff 전달 및 테스트 실행 명령 주입
      T-->>HD: 테스트 실패/성공 리포트 생성
      HD-->>H: 결과 수집 후 상호 피드백 루프 조정
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: MULTI-AGENT ORCHESTRATION CONTROLLER]
당신은 Herdr 런타임 위에서 서브에이전트 군단을 총괄 지휘하는 Hermes Coordinator입니다.
직접 코드를 작성하지 마십시오. 오직 터미널 토폴로지 구성, 작업 분할, 의존성 동기화, 결과 합의만 수행합니다.

[TOPOLOGY OBJECTIVE]
- 동일 프로젝트의 기능 구현(Implementer)과 검증(Tester)을 병렬로 분리한다.
- 충돌 방지를 위해 반드시 독립 Git Worktree를 개별 패널의 작업 디렉터리(`--cwd`)로 격리한다.

[ORCHESTRATION PROTOCOL]
1. `herdr tab create`로 "Feature-Pipeline" 탭을 생성하고 기본 패널 ID를 획득한다.
2. Git worktree를 각각 생성한다:
   - `git worktree add ../wt-impl -b feat-impl`
   - `git worktree add ../wt-test -b feat-test`
3. 기본 패널(wt-impl)에서 Implementer 에이전트를 가동한다.
4. `herdr pane split --direction right --cwd ../wt-test`로 우측 패널을 생성하고 Tester 에이전트를 가동한다.
5. Implementer가 인터페이스 명세를 출력하면 `herdr pane wait-output`으로 감지하고, Tester 패널에 `herdr pane send-text`로 API 계약(Contract)을 전송한다.
6. 양쪽 에이전트의 OSC 7501 상태가 모두 `done` 또는 `idle`로 전환될 때까지 모니터링한 후 통합 테스트를 격발한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "JWT 기반 리프레시 토큰 로테이션 모듈을 구현해줘. 구현 속도와 안정성을 위해 Claude Code 패널과 Codex 테스트 패널을 분리하여 Git worktree 기반으로 병렬 개발을 오케스트레이션해."
- **Hermes → Implementer 에이전트 (Pane 1):**
  > "[TASK: CORE IMPLEMENTATION] `src/auth/jwt.rs`에 토큰 발급 및 로테이션 로직을 작성하세요. 구현 완료 후 터미널에 `[CONTRACT_EXPORT_READY]` 마커와 함께 인터페이스 시그니처를 출력하십시오."
- **Hermes → Tester 에이전트 (Pane 2):**
  > "[TASK: TDD & VALIDATION] 우측 패널의 인터페이스 시그니처가 확정되는 즉시 `tests/auth_jwt_test.rs`에 동시성 토큰 무효화 검증 테스트를 작성하고 `cargo test`를 실행하십시오."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 독립 작업공간 준비 (Git Worktree)
git worktree add ../wt-impl -b feat-jwt-impl
git worktree add ../wt-test -b feat-jwt-test

# 2. 전용 탭 생성 및 좌측 패널(Implementer) 세팅
TAB_JSON=$(herdr tab create --cwd ../wt-impl --label "JWT-Dual-Pipeline" --focus)
PANE_IMPL=$(echo $TAB_JSON | jq -r '.pane_id // .panes[0].id')

# 3. 우측 패널(Tester) 분할 생성
PANE_TEST=$(herdr pane split $PANE_IMPL --direction right --cwd ../wt-test | jq -r '.id')

# 4. 각 패널에 전용 에이전트 실행
herdr pane run $PANE_IMPL "claude"
herdr pane run $PANE_TEST "codex"

# 5. 서브에이전트에 작업 지침 주입
herdr pane send-text $PANE_IMPL "JWT 리프레시 토큰 로직을 구현하고 [CONTRACT_EXPORT_READY]를 출력하세요.\n"
herdr pane send-text $PANE_TEST "TDD 테스트 환경을 초기화하고 인터페이스 알림을 대기하세요.\n"

# 6. 명세 출력 대기 및 테스트 트리거
herdr pane wait-output $PANE_IMPL "\[CONTRACT_EXPORT_READY\]" --lines 100
herdr pane send-text $PANE_TEST "cargo test --test auth_jwt_test\n"
```

---

### 시나리오 2. 적대적 레드-블루 보안 공방 루프 (Red-Blue Adversarial Security & Patching Cycle)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 2개 패널 순환 구조 (좌: 침투/취약점 감사 에이전트 `Red-Team`, 우: 보안 패치 개발자 `Blue-Team`)
- **격리 및 동기화 메커니즘:** 단방향 실행이 아닌 **상호 피드백 루프(Loop)**를 유지합니다. Red-Team 에이전트가 API 퍼징(Fuzzing) 및 인젝션 취약점을 찾아내면 Hermes가 해당 PoC(개념 증명 스크립트)를 추출하여 Blue-Team 패널에 입력하고, 패치 완료 신호가 오면 다시 Red-Team을 깨워 재검증(Regression Test)을 명령합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  flowchart LR
      subgraph Herdr_Workspace ["Herdr Multi-Pane Workspace"]
          R["Red-Team Pane\n(Vulnerability Fuzzer)"]
          B["Blue-Team Pane\n(Defensive Patcher)"]
      end
      H{"Hermes Coordinator\n(Loop Controller)"}

      H -->|1. Attack Task| R
      R -->|2. Exploit Found & PoC| H
      H -->|3. Patch Request & PoC| B
      B -->|4. Fix Applied & Done| H
      H -->|5. Re-Test Trigger| R
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: ADVERSARIAL MULTI-AGENT LOOP CONTROLLER]
당신은 보안 감사 Red Team 에이전트와 보안 완화 Blue Team 에이전트 간의 적대적 공방 루프를 제어하는 Hermes Coordinator입니다.

[COORDINATION RULES]
1. Red Team 패널에는 취약점 탐색 스크립트(OWASP Top 10, Auth Bypass 등)를 실행하도록 지시한다.
2. 취약점 탐색 결과에 `[VULNERABILITY_FOUND]` 패턴이 감지되면:
   - 해당 패널의 스크린 로그를 스냅샷하여 취약점 페이로드 및 호출 엔드포인트를 추출한다.
   - Blue Team 패널로 전환하여 재현 PoC 테스트 작성 및 소스코드 핫픽스를 지시한다.
3. Blue Team의 OSC 7501 상태가 `done`으로 전환되면:
   - Red Team 패널에 해당 페이로드로 재침투를 명령(`herdr pane send-text`)하여 패치 유효성을 검증한다.
4. 더 이상 취약점이 발견되지 않는 무결성 상태(`[AUDIT_CLEAN]`)가 확인될 때까지 이 루프를 최대 3회 반복 조율한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "GraphQL 라우터의 인가 우회(BOLA) 취약점을 점검하고, 취약점 발견 시 블루팀 에이전트와 연계하여 완전한 패치와 단위 테스트까지 자동 루프로 완성해줘."
- **Hermes → Red-Team 에이전트 (Pane 1):**
  > "[EXPLOIT AUDIT PHASE] GraphQL 스키마를 점검하고 사용자 세션 토큰 변조 공격을 수행하세요. 취약점 발견 시 `[VULNERABILITY_FOUND]` 태그와 함께 curl 재현 커맨드를 출력하십시오."
- **Hermes → Blue-Team 에이전트 (Pane 2):**
  > "[SECURITY REMEDIATION PHASE] 전달된 PoC 요청이 차단되도록 `middleware/auth.ts`의 리졸버 인가 검증 로직을 보강하고 방어 단위 테스트를 통과시키세요."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 보안 감사 전용 레이아웃 분할
PANE_RED=$(herdr tab create --label "Security-Audit" | jq -r '.pane_id // .panes[0].id')
PANE_BLUE=$(herdr pane split $PANE_RED --direction right | jq -r '.id')

# 2. 에이전트 기동 및 침투 테스트 명령
herdr pane run $PANE_RED "opencode --profile security-auditor"
herdr pane run $PANE_BLUE "claude"

herdr pane send-text $PANE_RED "Run BOLA penetration test on /graphql and emit [VULNERABILITY_FOUND] if exploitable.\n"

# 3. 취약점 발견 감지 및 버퍼 추출
herdr pane wait-output $PANE_RED "\[VULNERABILITY_FOUND\]"
EXPLOIT_LOG=$(herdr pane get $PANE_RED | jq -r '.last_output_lines')

# 4. 블루팀 패널로 취약점 전달 및 패치 명령
herdr pane send-text $PANE_BLUE "Fix this vulnerability based on log:\n$EXPLOIT_LOG\nEmit [PATCH_COMPLETE] when done.\n"

# 5. 블루팀 완료 대기 후 레드팀 재검증 루프 격발
herdr pane wait-output $PANE_BLUE "\[PATCH_COMPLETE\]"
herdr pane send-text $PANE_RED "Re-run the exploit script to confirm zero-day remediation.\n"
```

---

### 시나리오 3. 하이브리드 인프라 분산 오케스트레이션 (Local-Remote Heterogeneous Pipeline)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 이기종 머신 협업 (로컬 Pane: 클라이언트/API 게이트웨이 에이전트, 원격 SSH Machine: GPU 기반 대규모 모델 컴파일 및 서빙 에이전트)
- **격리 및 동기화 메커니즘:** 로컬 개발 머신의 리소스 한계를 극복하기 위해 Herdr의 `machine` 관리 기능을 활용합니다. Hermes는 사전 등록된 고성능 원격 서버(`gpu-node-01`)에 SSH 패널을 열어 모델 빌드/미세조정을 명령하고, 로컬 패널에서는 API 인터페이스 클라이언트를 동기화하여 엔드투엔드 서비스 통합을 조율합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  sequenceDiagram
      autonumber
      participant H as Hermes Coordinator
      participant HD as Herdr Daemon
      participant L as Local Pane (Web Gateway)
      participant R as Remote SSH (GPU Cluster)

      H->>HD: herdr machine list 확인 및 가용 GPU 노드 선정
      H->>HD: 로컬 탭 생성 및 원격 머신 SSH 세션 연결
      H->>R: 원격 vLLM 가속 양자화 및 빌드 스크립트 실행
      H->>L: 로컬 프론트엔드 연동 클라이언트 개발 지시
      R-->>HD: 빌드 완료 및 헬스체크 통과 신호 방출 (OSC 7501)
      HD-->>H: 원격 포트 개방 감지
      H->>L: 원격 엔드포인트 URL 주입 및 통신 통합 테스트 지시
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: HYBRID CLOUD & MULTI-MACHINE COORDINATOR]
당신은 로컬 환경과 원격 고성능 인프라를 가로질러 작업 부하를 최적으로 분산하는 Hermes Coordinator입니다.

[INFRASTRUCTURE ALLOCATION STRATEGY]
- 모델 컴파일, 대규모 테스트, GPU 연산 등 무거운 부하는 Herdr에 등록된 원격 Machine 프로필로 라우팅한다.
- UI/웹 프론트엔드 및 비즈니스 로직 연동은 로컬 머신의 패널에서 처리한다.

[EXECUTION INSTRUCTIONS]
1. `herdr machine list`를 조회하여 온라인 상태인 최적의 원격 호스트(`profile_id`)를 확인한다.
2. 새 탭을 생성하고 원격 호스트 연결 패널과 로컬 작업 패널을 상하 분할(`direction down`)로 구성한다.
3. 원격 머신 패널에 CUDA 가속 컴파일 태스크를 할당하고 완료 상태를 백그라운드 폴링한다.
4. 원격 태스크 완료 시 반환된 엔드포인트 정보를 로컬 패널 에이전트에 파라미터로 주입하여 연동 테스트를 완성한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "원격 GPU 서버에서 DeepSeek 기반 모델을 양자화 서빙하도록 빌드하고, 로컬 머신에는 해당 모델과 통신하는 대시보드 API 백엔드를 구축해서 둘을 연결해줘."
- **Hermes → Remote Worker 에이전트 (Remote Pane):**
  > "[REMOTE COMPUTE WORKER] GPU 가속 환경에서 모델 가중치를 FP8로 양자화하고 포트 8000번에 vLLM 엔드포인트를 구동한 뒤 `[SERVER_HEALTH_OK]`를 방출하십시오."
- **Hermes → Local Gateway 에이전트 (Local Pane):**
  > "[LOCAL GATEWAY DEVELOPER] 원격 호스트의 8000번 포트 명세를 수신 대기하고, `FastAPI` 기반 프록시 게이트웨이 및 클라이언트 스트리밍 라우트를 구현하십시오."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 등록된 원격 머신 가용 상태 확인
herdr machine list

# 2. 분산 워크스페이스 탭 생성 (로컬 클라이언트용)
TAB_INFO=$(herdr tab create --label "Hybrid-Distributed-Cluster" --cwd ~/projects/gateway)
LOCAL_PANE=$(echo $TAB_INFO | jq -r '.pane_id // .panes[0].id')

# 3. 원격 GPU 서버 SSH 패널을 하단으로 분할 배치
REMOTE_PANE=$(herdr pane split $LOCAL_PANE --direction down | jq -r '.id')
herdr pane run $REMOTE_PANE "ssh gpu-cluster-node"

# 4. 원격 패널에 모델 서빙 빌드 명령 전달
herdr pane send-text $REMOTE_PANE "python3 -m vllm.entrypoints.openai.api_server --model deepseek-ai/DeepSeek-Coder --port 8000\n"

# 5. 로컬 패널에 에이전트 실행 및 대기 지시
herdr pane run $LOCAL_PANE "claude"
herdr pane send-text $LOCAL_PANE "원격 GPU 노드의 헬스체크 통과 신호를 대기 중입니다...\n"

# 6. 원격 서버 정상 기동 감지 후 로컬 에이전트에 엔드포인트 주입
herdr pane wait-output $REMOTE_PANE "Application startup complete."
herdr pane send-text $LOCAL_PANE "원격 서버가 가동되었습니다. http://gpu-cluster-node:8000 에 연동되는 게이트웨이를 구현하세요.\n"
```

---

### 시나리오 4. OSC 7501 기반 워치독 및 자율 장애 복구 (Watchdog & Deadlock Recovery)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 1명의 감독자(Hermes Watchdog) + N명의 워커 에이전트 (배치 프로세서, 마이그레이션 워커 등)
- **격리 및 동기화 메커니즘:** 에이전트가 패키지 설치 시 `[y/N]` 대기, 권한 오류 프롬프트, 무한 루프, 또는 네트워크 교착 상태에 빠지면 사람이 직접 개입해야 하는 병목이 발생합니다. Hermes는 Herdr의 **OSC 7501 결정론적 상태 프로토콜**을 통해 각 패널의 상태(`working`, `blocked`, `idle`)를 비동기로 감지합니다. `blocked` 상태가 감지되면 버퍼 내용을 파싱하여 자동 승인 키를 주입하거나, 무한 루프 시 강제 인터럽트(`\x03`)를 전송해 안전하게 복구합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  stateDiagram-v2
      [*] --> Working: 작업 명령 하달
      Working --> Blocked: 대화형 입력 대기 (OSC 7501 감지)
      Working --> Idle: 작업 정상 완료
      
      state Blocked {
          [*] --> InspectBuffer: herdr pane get & 출력 파싱
          InspectBuffer --> AutoApprove: [y/N] 프롬프트 확인 -> send-text "y\n"
          InspectBuffer --> KillStall: 무한 루프 감지 -> send-text "\x03"
      }
      
      Blocked --> Working: 워치독 개입 및 세션 정상화
      Idle --> [*]
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: SUPERVISORY WATCHDOG & RECOVERY CONTROLLER]
당신은 백그라운드에서 동작 중인 서브에이전트들의 교착 상태(Deadlock) 및 대기 상태(Block)를 감시하고 자율 복구하는 Supervisory Agent입니다.

[DETECTION & INTERVENTION POLICY]
1. Herdr 백그라운드 소켓을 주기적으로 모니터링하여 패널의 OSC 7501 상태를 추적한다.
2. 특정 패널이 `blocked` 상태로 진입한 경우:
   - `herdr pane get <pane_id>`를 호출하여 마지막 터미널 출력 20줄을 스캔한다.
   - 프롬프트가 `Are you sure? (y/n)`, `Proceed? [Y/n]`, 또는 `Overwrite file?` 계열인 경우, 위험도를 자율 평가한 후 `herdr pane send-text <pane_id> "y\n"`을 전송하여 차단을 해제한다.
   - 만약 프로세스가 60초 이상 동일한 에러 출력을 반복하며 루프에 빠진 경우, `herdr pane send-text <pane_id> "\x03"`(SIGINT)를 주입하여 프로세스를 중단시키고 대안 스크립트를 재실행한다.
3. 모든 워치독 복구 내역을 타임스탬프와 함께 로깅하여 리포트를 생성한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "레거시 모노레포의 의존성 업그레이드 마이그레이션을 백그라운드로 실행해줘. 중간에 패키지 매니저의 대화형 프롬프트나 에러 루프가 발생하면 워치독으로 자동 개입해서 끝까지 완료해."
- **Hermes → Worker 에이전트 (Execution Pane):**
  > "[MIGRATION TASK] 모든 `package.json` 의존성을 최신 메이저 버전으로 일괄 업그레이드하고 `npm audit fix --force`를 수행하십시오."
- **Hermes Watchdog 자율 개입 로그 (Internal Action):**
  > "[WATCHDOG INTERVENTION] Pane 2 OSC 7501 status is `blocked`. Detected prompt `npm warn deprecated ... Continue? (y/N)`. Safe dependency resolution verified. Dispatching `y\n` to unblock."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 마이그레이션 전용 패널 생성 및 실행
PANE_WORKER=$(herdr pane split --direction right | jq -r '.id')
herdr pane run $PANE_WORKER "npm install --legacy-peer-deps"

# 2. 상태 감시 루프 (CLI/소켓 기반 상태 폴링)
PANE_STATUS=$(herdr pane get $PANE_WORKER | jq -r '.agent_state')

# 3. 차단 상태 감지 시 안전한 자동 승인 입력 주입
if [ "$PANE_STATUS" = "blocked" ]; then
    LAST_LINE=$(herdr pane get $PANE_WORKER | jq -r '.last_line')
    echo "Detected block condition: $LAST_LINE"
    
    # y/n 프롬프트에 자동 개입 승인
    herdr pane send-text $PANE_WORKER "y\n"
fi

# 4. 루프 발생 시 인터럽트(Ctrl+C) 주입 및 대체 명령 실행 (\x03: Ctrl+C)
herdr pane send-text $PANE_WORKER $'\x03'
herdr pane send-text $PANE_WORKER "npm install --force\n"
```

---

### 시나리오 5. 3중 에이전트 분기-취합 합의 오케스트레이션 (Tri-Agent Fan-Out / Fan-In Consensus)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 3-Way 병렬 그리드 레이아웃 (Pane 1: `Claude Code`, Pane 2: `Codex`, Pane 3: `Pi/OpenCode`)
- **격리 및 동기화 메커니즘:** 고위험 아키텍처 결정이나 난이도 높은 성능 튜닝 시 단일 에이전트의 환각이나 편향을 방지하기 위해 **Fan-Out / Fan-In 합의 패턴**을 적용합니다. Hermes는 단일 탭을 3분할하고 동일한 설계 요구사항을 3개 에이전트에 동시 브로드캐스팅합니다. 각 에이전트가 산출한 아키텍처 초안과 벤치마크 데이터를 수집(Fan-In)한 뒤, 가중 합의 알고리즘으로 최적안을 도출하여 메인 브랜치에 반영합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  flowchart TD
      U["User: High-Concurrency Engine Architecture"] --> H["Hermes Coordinator"]
      
      subgraph FanOut ["Fan-Out Phase (Parallel 3-Pane Grid)"]
          H -->|Spec Broadcast| P1["Pane 1: Claude Code\n(Actor Model Proposal)"]
          H -->|Spec Broadcast| P2["Pane 2: Codex\n(Event-Loop Proposal)"]
          H -->|Spec Broadcast| P3["Pane 3: Pi\n(Worker Thread Pool)"]
      end
      
      subgraph FanIn ["Fan-In Phase (Consensus & Synthesis)"]
          P1 -->|Proposal 1 & Bench| H
          P2 -->|Proposal 2 & Bench| H
          P3 -->|Proposal 3 & Bench| H
          H -->|Synthesize & Merge| M["Final Synthesized Architecture\nMerged into Main Branch"]
      end
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: CONSENSUS ARBITRATOR & FAN-OUT/FAN-IN ORCHESTRATOR]
당신은 독립된 복수의 AI 에이전트 모델로부터 설계안을 병렬로 도출하고 이를 종합 평가하여 최적안을 선정하는 Hermes Arbitrator입니다.

[CONSENSUS FRAMEWORK]
1. 단일 워크스페이스에 3개 패널 그리드(좌측 1개, 우측 상하 2개)를 생성한다.
2. 각 패널에 상이한 모델 성향의 코딩 에이전트를 배치한다.
3. 동일한 설계 과제 프롬프트를 전 패널에 동시에 브로드캐스팅한다.
4. 각 에이전트의 산출물에서 다음 4가지 지표를 추출하여 평가 매트릭스를 구성한다:
   - 복잡도 (Cyclomatic Complexity)
   - 동시성 처리 성능 (Throughput / Latency)
   - 메모리 안전성 (Memory Overhead)
   - 유지보수성 (Maintainability)
5. 최고 점수를 획득한 방안 또는 각 방안의 장점을 결합한 통합 하이브리드 아키텍처를 작성하여 최종 적용을 실행한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "초당 5만 건의 실시간 주식 틱 데이터를 유실 없이 처리하는 인메모리 버퍼 엔진을 설계해야 해. 3개 에이전트를 동시에 띄워 서로 다른 아키텍처 모델을 제안받고, 장단점을 수렴 합의하여 최종 코드를 작성해줘."
- **Hermes → 병렬 브로드캐스트 프롬프트 (Panes 1, 2, 3):**
  > "[PARALLEL DESIGN PROPOSAL] 요구 조건: 50,000 TPS, P99 지연 시간 5ms 미만 인메모리 링 버퍼. 당신만의 아키텍처 설계와 러프한 프로토타입 벤치마크 코드를 작성하고 마지막에 `[PROPOSAL_COMPLETE]`를 출력하십시오."
- **Hermes 취합 및 최종 반영 프롬프트:**
  > "[FINAL MERGE & SYNTHESIS] 3개 패널의 설계안(Actor, Ring Buffer, Disrupter Pattern)을 검토했습니다. Pane 3의 무잠금(Lock-free) 링버퍼와 Pane 1의 백프레셔(Backpressure) 제어 메커니즘을 융합한 최적 솔루션을 `src/engine/mod.rs`에 최종 머지합니다."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 3개 분할 그리드 레이아웃 구축
TAB_DATA=$(herdr tab create --label "Architecture-Consensus")
P1=$(echo $TAB_DATA | jq -r '.pane_id // .panes[0].id')
P2=$(herdr pane split $P1 --direction right | jq -r '.id')
P3=$(herdr pane split $P2 --direction down | jq -r '.id')

# 2. 3개 독립 에이전트 기동
herdr pane run $P1 "claude"
herdr pane run $P2 "codex"
herdr pane run $P3 "opencode --model pi"

# 3. 동일 설계 과제 일괄 전송
TASK_SPEC="Design high-concurrency ring buffer (50k TPS). Output architecture and emit [PROPOSAL_COMPLETE].\n"
herdr pane send-text $P1 "$TASK_SPEC"
herdr pane send-text $P2 "$TASK_SPEC"
herdr pane send-text $P3 "$TASK_SPEC"

# 4. 3개 에이전트의 산출 완료 신호 동시 대기 (Sync Barrier)
herdr pane wait-output $P1 "\[PROPOSAL_COMPLETE\]"
herdr pane wait-output $P2 "\[PROPOSAL_COMPLETE\]"
herdr pane wait-output $P3 "\[PROPOSAL_COMPLETE\]"

# 5. 각 제안서 버퍼 회수 및 판정
PROP1=$(herdr pane get $P1 | jq -r '.last_output_lines')
PROP2=$(herdr pane get $P2 | jq -r '.last_output_lines')
PROP3=$(herdr pane get $P3 | jq -r '.last_output_lines')

# 6. 최적안 확정 후 메인 패널(P1)에 최종 병합 지시 및 나머지 패널 정리
herdr pane send-text $P1 "Synthesizing Proposals. Implement the selected lock-free ringbuffer in src/engine/.\n"
herdr pane close $P2
herdr pane close $P3
```

---

### 시나리오 6. 계층형 동적 워커 풀 및 작업 수명주기 오케스트레이션 (Hierarchical Architect & Dynamic Ephemeral Worker Pool)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 1개 총괄 테크 리드 패널(`Architect`) + 동적으로 생성 및 소멸되는 N개의 임시 작업 패널(`Ephemeral Worker Panes`)
- **격리 및 동기화 메커니즘:** 고정된 정적 레이아웃 대신, 시스템 리소스(RAM, CPU, API 토큰)를 보호하면서 대규모 작업을 순차/병렬 처리하기 위한 **동적 워커 풀(Dynamic Worker Pool)** 패턴입니다. Hermes 또는 테크 리드 에이전트가 요구사항을 원자 단위 서브태스크 큐로 분해한 뒤, 최대 동시 실행 수(예: Max Concurrency 2)를 유지하며 Herdr CLI로 패널을 동적으로 분할 생성(`herdr pane split`)합니다. 작업이 완료되어 OSC 7501 `done` 상태가 확인되면 산출물을 수집하고 즉시 패널을 소멸(`herdr pane close`)시켜 터미널 워크스페이스를 정돈합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  sequenceDiagram
      autonumber
      participant H as Hermes Coordinator
      participant HD as Herdr Daemon
      participant A as Tech Lead Architect
      participant Q as Subtask Queue
      participant W as Ephemeral Worker (Pool)

      H->>HD: 아키텍트 전용 패널 생성
      H->>A: 모놀리스 모듈 분해 계획 수립 지시
      A->>Q: 독립 단위 서브태스크(Task A, B, C) 등록
      loop Task Queue가 비어있을 때까지 (동시성 N 유지)
          H->>HD: herdr pane split으로 임시 워커 패널 스폰
          H->>W: 서브태스크 지침 및 컨텍스트 주입
          W-->>HD: 작업 실행 및 단위 테스트 통과 (OSC 7501 done)
          HD-->>H: 작업 완료 감지
          H->>A: 워커 산출물 전달 및 메인 브랜치 병합 검증
          H->>HD: herdr pane close로 완료된 워커 패널 정리
      end
      A-->>H: 모든 모듈 마이그레이션 및 통합 완료 리포트
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: EPHEMERAL WORKER POOL CONTROLLER]
당신은 시스템 자원 소모를 최소화하면서 대량의 모듈 마이그레이션을 조율하는 동적 워커 풀 관리자입니다.

[CONCURRENCY & LIFECYCLE CONSTRAINTS]
- 활성 임시 워커 패널(Worker Pane)은 동시에 최대 2개까지만 유지한다.
- 각 서브태스크 완료 즉시 해당 패널을 반드시 `close`하여 세션과 프로세스를 정리(Ephemeral Lifecycle)한다.
- 서브에이전트 실패 또는 타임아웃 발생 시 1회 재시도 후 아키텍트 패널로 오류 컨텍스트를 에스컬레이션한다.

[EXECUTION PROTOCOL]
1. `herdr tab create --label "Dynamic-Worker-Pool"`로 관리 탭을 열고 아키텍트 에이전트를 가동한다.
2. 아키텍트가 산출한 작업 큐(JSON 배열)를 파싱한다.
3. 큐에서 태스크를 인출하여 `herdr pane split --direction right`로 작업 패널을 동적 생성한다.
4. 임시 패널에 워커 에이전트를 기동하고 작업을 주입한다.
5. `herdr pane wait-output` 또는 OSC 7501 상태 감지로 `[SUBTASK_COMPLETED]`를 확인한다.
6. 결과를 아키텍트 패널에 기록한 후 `herdr pane close <worker_pane_id>`로 패널을 즉시 회수한다.
7. 대기 중인 다음 태스크를 순차적으로 스폰한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "레거시 JavaScript 파일 12개를 TypeScript strict 모드로 점진 변환해야 해. 한 번에 모든 에이전트를 띄우지 말고, 최대 2개의 임시 패널만 유지하면서 파일 단위 변환-검증-패널 종료를 반복하는 동적 워커 풀로 처리해줘."
- **Hermes → Architect 에이전트 (Pane 1):**
  > "[TASK DECOMPOSITION] 대상 파일들의 의존성 트리를 분석하고, 순환 참조가 없는 안전한 변환 순서대로 태스크 큐(`tasks.json`)를 작성하십시오."
- **Hermes → Ephemeral Worker 에이전트 (Dynamic Pane):**
  > "[ISOLATED TASK EXECUTION] `src/legacy/parser.js`를 TypeScript `src/core/parser.ts`로 변환하고 strict null check를 통과시키세요. `tsc --noEmit` 검증 통과 시 `[SUBTASK_COMPLETED]`를 방출하십시오."
- **Hermes 자원 회수 로그:**
  > "[LIFECYCLE MANAGEMENT] Task #4 on Pane 3 completed successfully. Collected diff stats. Issuing `herdr pane close 3` to reclaim system resources. Spawning Task #5 in a fresh pane."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 아키텍트 탭 및 메인 패널 생성
TAB_INFO=$(herdr tab create --label "Dynamic-Pool" --focus)
ARCHITECT_PANE=$(echo $TAB_INFO | jq -r '.pane_id // .panes[0].id')

# 아키텍트 기동
herdr pane run $ARCHITECT_PANE "claude --profile architect"
herdr pane send-text $ARCHITECT_PANE "Generate tasks.json listing modular subtasks.\n"
herdr pane wait-output $ARCHITECT_PANE "\[TASKS_READY\]"

# 2. 동적 워커 스폰 및 순차 정리 루프 (Bash 제어)
TASKS=("auth_module" "payment_module" "inventory_module")

for TASK in "${TASKS[@]}"; do
    echo "=== Spawning Ephemeral Worker for $TASK ==="
    
    # 아키텍트 패널 우측에 임시 패널 동적 생성
    WORKER_PANE=$(herdr pane split $ARCHITECT_PANE --direction right --cwd "./modules/$TASK" | jq -r '.id')
    
    # 임시 워커 에이전트 실행 및 태스크 주입
    herdr pane run $WORKER_PANE "codex"
    herdr pane send-text $WORKER_PANE "Migrate this module to TypeScript strict. Emit [SUBTASK_COMPLETED] when tsc passes.\n"
    
    # 완료 신호 대기 (OSC 7501 / 텍스트 마커)
    herdr pane wait-output $WORKER_PANE "\[SUBTASK_COMPLETED\]" --lines 100
    
    # 아키텍트에 진행 완료 통보
    herdr pane send-text $ARCHITECT_PANE "Task $TASK finished by worker $WORKER_PANE.\n"
    
    # 작업 완료 즉시 임시 패널 닫기 (자원 회수)
    echo "Reclaiming resources: closing pane $WORKER_PANE"
    herdr pane close $WORKER_PANE
done

echo "All pipeline tasks fulfilled."
```

---

### 시나리오 7. 자율 장애 대응 및 카나리 검증 힐링 루프 (Autonomous Incident Triage, Patch & Canary Healing Loop)

#### (1) 오케스트레이션 시나리오 개요
- **협업 토폴로지:** 3개 패널 분할 (좌측: SRE 로그 트라이아지 에이전트, 우상단: 핫픽스 개발 에이전트, 우하단: 카나리 트래픽 시뮬레이터 & APM 메트릭 감시 에이전트)
- **격리 및 동기화 메커니즘:** 프로덕션 환경의 실시간 장애 발생 시 신속한 복구와 안정성을 동시에 보장하기 위한 **자가 치유(Self-Healing) 및 서킷 브레이커** 오케스트레이션입니다. SRE 에이전트가 에러 로그와 스택 트레이스를 분석하여 재현 시나리오를 구성하면, 개발 에이전트가 패치 코드를 작성합니다. 패치 즉시 본 서버에 배포하는 대신 카나리 샌드박스 환경에 반영하고, 시뮬레이터 패널이 스트레스 트래픽을 주입하며 P99 지연 시간 및 HTTP 5xx 에러율을 측정합니다. 지표가 안정 임계치를 만족하면 배포를 자동 승인하고, 악화될 경우 즉각 롤백 신호를 주입합니다.
- **오케스트레이션 흐름:**
  ```mermaid
  flowchart TD
      subgraph IncidentRoom ["Herdr Multi-Pane Incident Room"]
          SRE["Pane 1: SRE Triage\n(Log Ingestion & RCA)"]
          DEV["Pane 2: Hotfix Patcher\n(Root-Cause Fix & Unit Test)"]
          SIM["Pane 3: Canary Simulator\n(Chaos Load & APM Telemetry)"]
      end

      ALERT["Production Alert: 502 Surge"] -->|Trigger| SRE
      SRE -->|1. Root Cause & Repro Curl| DEV
      DEV -->|2. Patch Applied to Canary| SIM
      SIM -->|3. Synthetic Traffic Injection| SIM
      SIM -->|4. Telemetry Evaluation| DECISION{"Telemetry Check\nError Rate < 0.01%?"}

      DECISION -->|YES: Healthy| DEPLOY["Approve Full Production Rollout"]
      DECISION -->|NO: Degraded| ROLLBACK["Automated Canary Rollback\n& Escalate to Human"]
  ```

#### (2) Hermes 코디네이터 프롬프트
```markdown
[ROLE: AUTONOMOUS INCIDENT RESPONSE & SRE ORCHESTRATOR]
당신은 프로덕션 시스템 이상 징후를 감지하고 트라이아지-패치-카나리 검증-배포 전 과정을 자동 제어하는 Incident Commander입니다.

[INCIDENT SLA & RECOVERY POLICIES]
- 프로덕션 영향도를 최소화하기 위해 카나리 인스턴스에서 반드시 합성 트래픽(Synthetic Traffic) 검증을 거친다.
- 5xx 에러율이 0.05%를 초과하거나 응답 지연이 200ms를 초과할 경우 즉시 롤백 시그널(`[CIRCUIT_BREAKER_TRIPPED]`)을 전송한다.
- 장애 원인 분석서(Post-Mortem)를 자동으로 작성하여 리포트로 저장한다.

[ORCHESTRATION WORKFLOW]
1. `herdr tab create --label "SEV-1-Incident-WarRoom"`으로 인시던트 워룸을 생성한다.
2. 좌측 패널(SRE)에 최근 프로덕션 로그 스트림을 파이프하고 RCA(원인 분석)를 지시한다.
3. 우측 상단 패널(DEV)을 생성하여 Git 핫픽스 브랜치를 체크아웃하고 패치 작성을 대기시킨다.
4. 우측 하단 패널(SIM)을 생성하여 카나리 인스턴스 및 부하 생성 도구(k6 또는 hey)를 준비한다.
5. SRE가 원인 분석 태그(`[RCA_ESTABLISHED]`)를 출력하면 분석 결과와 재현 curl을 DEV 패널에 전달한다.
6. DEV 패치 완료 후 SIM 패널을 구동하여 1,000건의 트래픽을 인젝션하고 메트릭을 판정한다.
7. 판정 결과에 따라 프로덕션 롤아웃 승인 또는 자동 롤백을 단행한다.
```

#### (3) 예제 프롬프트
- **사용자 → Hermes 코디네이터:**
  > "결제 게이트웨이 웹훅 처리에서 간헐적 Null Pointer Exception으로 502 에러가 치솟고 있어. SRE 패널, 핫픽스 개발 패널, 카나리 부하 검증 패널을 연계해서 자동 원인 분석과 패치, 카나리 스트레스 검증까지 완결해줘."
- **Hermes → SRE Triage 에이전트 (Pane 1):**
  > "[INCIDENT TRIAGE] 결제 웹훅 로그 버퍼를 역추적하여 NPE 발생 페이로드 패턴을 특정하고, 재현 가능한 최소 curl 명령을 `[RCA_ESTABLISHED]` 태그와 함께 출력하십시오."
- **Hermes → Hotfix Developer (Pane 2):**
  > "[HOTFIX REMEDIATION] 전달된 NPE 페이로드에 대한 방어 로직과 옵셔널 체이닝 검증을 `src/billing/webhook.ts`에 적용하고 단위 테스트를 패스시키십시오."
- **Hermes → Canary Telemetry Agent (Pane 3):**
  > "[CANARY STRESS VERIFICATION] 핫픽스가 배포된 카나리 엔드포인트(`http://localhost:8081`)로 초당 100 RPS의 복합 트래픽을 30초간 주입하고 5xx 에러율을 측정하십시오."

#### (4) Herdr CLI 자동화 명령어
```bash
# 1. 인시던트 워룸 3분할 레이아웃 생성
TAB_META=$(herdr tab create --label "Incident-SEV1" --focus)
PANE_SRE=$(echo $TAB_META | jq -r '.pane_id // .panes[0].id')
PANE_DEV=$(herdr pane split $PANE_SRE --direction right | jq -r '.id')
PANE_SIM=$(herdr pane split $PANE_DEV --direction down | jq -r '.id')

# 2. 에이전트 및 역할별 환경 기동
herdr pane run $PANE_SRE "tail -f /var/log/app/payment-error.log | opencode --profile sre-triage"
herdr pane run $PANE_DEV "claude"
herdr pane run $PANE_SIM "bash"

# 3. SRE 패널의 근본 원인 분석(RCA) 대기
herdr pane wait-output $PANE_SRE "\[RCA_ESTABLISHED\]" --lines 50
RCA_REPORT=$(herdr pane get $PANE_SRE | jq -r '.last_output_lines')

# 4. 개발 패널로 원인 전달 및 패치 지시
herdr pane send-text $PANE_DEV "Apply defensive patch for this RCA:\n$RCA_REPORT\nEmit [HOTFIX_READY] when compiled.\n"

# 5. 패치 완료 대기 및 카나리 인스턴스 빌드 반영
herdr pane wait-output $PANE_DEV "\[HOTFIX_READY\]"
herdr pane send-text $PANE_SIM "docker compose restart payment-canary\n"
herdr pane wait-output $PANE_SIM "payment-canary restarted"

# 6. 합성 부하 주입 및 메트릭 평가 (k6 / hey)
herdr pane send-text $PANE_SIM "hey -n 1000 -c 20 -m POST -D payload.json http://localhost:8081/webhook/callback\n"
herdr pane wait-output $PANE_SIM "Status code distribution:"

# 7. 에러율 판정 후 조건부 배포/롤백
METRIC_OUT=$(herdr pane get $PANE_SIM | jq -r '.last_output_lines')
if echo "$METRIC_OUT" | grep -q "\[502\]"; then
    echo "Canary verification failed! Rolling back..."
    herdr pane send-text $PANE_DEV "Rollback hotfix commit immediately.\n"
else
    echo "Canary verification passed! Proceeding to blue-green production promotion."
    herdr pane send-text $PANE_DEV "git push origin hotfix-release && ./deploy-prod.sh\n"
fi
```

---

## 8. 요약 및 권장 사항

AI 코딩 에이전트의 등장은 단순 자동완성을 넘어 <strong>"터미널 환경에서 여러 프로세스를 자율적으로 상호작용시키는 시대"</strong>를 열었습니다.

- **`tmux`**: 단일 인스턴스 서버 유지, 전통적인 셸 작업, 리눅스 인프라 기본 환경에 여전히 훌륭합니다.
- **`Herdr`**: AI 에이전트를 매일 2개 이상 상시 실행하며, 상태 감지·알림·Worktree 분할·플러그인 확장이 필요한 현대 DevOps 및 소프트웨어 엔지니어에게 최적의 선택입니다.

아직 tmux만을 사용하며 백그라운드 에이전트들의 진행 상황을 일일이 확인하느라 번거로웠다면, `brew install herdr`로 에이전트 중심의 터미널 런타임을 구축해 보시길 권장합니다.
