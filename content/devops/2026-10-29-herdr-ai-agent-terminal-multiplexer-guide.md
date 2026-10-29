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

## 6. 요약 및 권장 사항

AI 코딩 에이전트의 등장은 단순 자동완성을 넘어 <strong>"터미널 환경에서 여러 프로세스를 자율적으로 상호작용시키는 시대"</strong>를 열었습니다.

- **`tmux`**: 단일 인스턴스 서버 유지, 전통적인 셸 작업, 리눅스 인프라 기본 환경에 여전히 훌륭합니다.
- **`Herdr`**: AI 에이전트를 매일 2개 이상 상시 실행하며, 상태 감지·알림·Worktree 분할·플러그인 확장이 필요한 현대 DevOps 및 소프트웨어 엔지니어에게 최적의 선택입니다.

아직 tmux만을 사용하며 백그라운드 에이전트들의 진행 상황을 일일이 확인하느라 번거로웠다면, `brew install herdr`로 에이전트 중심의 터미널 런타임을 구축해 보시길 권장합니다.
