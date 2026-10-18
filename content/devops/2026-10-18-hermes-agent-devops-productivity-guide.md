---
title: "Hermes Agent 심화 가이드: /learn을 넘어 DevOps와 개인 생산성을 극대화하는 실전 활용법"
tags:
  - hermes-agent
  - devops
  - ai-agent
  - automation
  - productivity
  - terminal
  - macos
---

이번 글에서는 macOS 및 터미널 환경에서 Hermes Agent를 실전 개인 생산성 에이전트로 운용할 때 반드시 알아두어야 할 **핵심 명령어 생태계**, **DevOps 실전 워크플로우 5선**, 그리고 **엔지니어를 위한 고급 운영 꿀팁**을 체계적으로 정리해 보겠습니다.

---

## 1. /learn과 함께 알아야 할 필수 명령어 생태계

Hermes Agent는 단순한 대화형 인터페이스를 넘어 터미널 세션의 실행 컨텍스트, 메모리, 서브 에이전트 분기, 백그라운드 데몬을 정밀하게 제어할 수 있는 슬래시 명령어들을 제공합니다. 목적별로 분류해 살펴보겠습니다.

| 학습 / 기억 / 재사용 | 품질 & 생산성 | 자동화 / 반복 | 세션 / 컨텍스트 |
| :--- | :--- | :--- | :--- |
| `/learn` | `/init` | `/cron` | `/btw` |
| `/refine` | `/plan` | `/loop` | `/context all` |
| `/journey` | `/review` | `/bg` | `/sessions` |
| `/skills` | `/branch`, `/fork` | `Quick Commands` | `/prompt` |
| `/memory` | `/moa` | | `/bundles` |



---

### A. 학습·기억·재사용 (Knowledge Lifecycle)

에이전트가 시간이 지날수록 똑똑해지려면 새로운 스킬을 등록하는 것만큼이나 **기존 지식을 정제하고 오염된 기억을 격리하는 관리 체계**가 필수적입니다.

#### 1. `/refine` — 스스로 개선점 검토 (강력 추천 ⭐)
누적된 작업 이력과 피드백을 바탕으로 등록된 메모리나 스킬의 개선점을 에이전트가 자체적으로 검토하도록 지시합니다.

```bash
/refine
/refine focus on recurring debugging workflows
/refine evaluate docker build optimization skills
```

- **핵심 역할:** `/learn`이 일회성 경험을 '스킬 초안'으로 굳히는 작업이라면, `/refine`은 실전에서 여러 번 쓰이며 쌓인 엣지 케이스와 오류 로그를 반영해 지식의 완성도를 높이는 **지속적 리팩터링 도구**입니다.

#### 2. `/journey` — 학습 이력 시각화 및 관리
지금까지 에이전트가 축적해 온 스킬 생성, 수정, 메모리 등록 히스토리를 그래프/목록 형태로 시각화합니다.

```bash
/journey
/journey list
/journey edit <node>
```

- **활용 팁:** 오래되어 변경된 사내 배포 URL이나 더 이상 쓰지 않는 구버전 CLI 플래그가 메모리에 남아 환각을 유발할 때, 불필요한 노드를 정리(Prune)하기에 최적입니다.

#### 3. `/skills` — 스킬 탐색·설치·관리
로컬(`~/.hermes/skills/`) 및 워크스페이스에 설치된 스킬을 검색하고 제어합니다.

```bash
/skills list
/skills browse
/skills search <keyword>
/reload-skills
```

- **활용 팁:** 새로운 자동화 워크플로우를 처음부터 직접 작성하기 전에 `/skills search k8s` 등으로 기존 생태계에 공개된 스킬이 있는지 먼저 탐색해 보세요. 외부 스킬 파일을 직접 복사해 넣었거나 수정한 뒤에는 `/reload-skills`로 즉시 재색인합니다.

#### 4. `/memory` — 기억 쓰기 승인 관리
에이전트가 장기 기억(Long-term memory)에 저장하려는 내용을 사람이 직접 승인할 수 있는 게이트키퍼 기능입니다.

```bash
/memory
/memory pending
/memory approval on
```

> 💡 **DevOps 운영 팁: 메모리 승인 게이트 활성화**  
> 인프라를 다루는 에이전트에게 비인가 메모리 쓰기를 허용해 두면 일시적인 장애 현상이나 임시 트러블슈팅 우회로(workaround)를 '상시 표준 규칙'으로 오인해 기억해 버릴 수 있습니다. 프로덕션 환경에서는 `/memory approval on`을 켜두어 검증된 운영 지식만 장기 저장소에 안착시키는 것이 안전합니다.

---

### B. 작업 품질과 개발 생산성 (Engineering Quality)

단순 일괄 실행 대신, 안전한 계획 수립과 관점의 분리를 통해 파괴적 실수를 방지하는 그룹입니다.

#### 5. `/init` — 프로젝트 규칙 자동 정리
현재 작업 디렉토리의 구조, 빌드 시스템, 의존성을 스캔하여 에이전트 지침서인 `AGENTS.md`를 자동 생성하거나 갱신합니다.

```bash
/init
/init Focus on build, test, and deployment conventions
```

- **역할:** 리포지토리별로 파편화된 컨벤션(예: `pnpm` vs `npm`, `pytest` 옵션, 브랜치 네이밍 규칙 등)을 에이전트의 기본 행동 양식으로 고정합니다.

#### 6. `/plan` — 실행 전에 계획만 작성
실제 파일 쓰기나 터미널 명령어 실행을 보류하고, 마크다운 형식으로 단계별 구현 계획과 영향도 분석서만 도출합니다.

```bash
/plan Refactor this Terraform module and add state migration plan
/plan Optimize Dockerfile multi-stage build without breaking dev cache
```

- **활용 팁:** 인프라 변경(IaC), 대규모 리팩터링, DB 스키마 마이그레이션처럼 되돌리기 힘든 작업을 맡길 때 필수 관문으로 사용합니다.

#### 7. `/review` — 독립적인 코드 리뷰
현재 세션에서 코드를 작성한 관점과 완전히 분리된 별도의 검토 프롬프트/서브 에이전트로 변경 사항(diff)을 감사(Audit)합니다.

```bash
/review Check edge cases, security, and test coverage
/review Audit IAM policy changes for least-privilege violations
```

- **효과:** 작업 에이전트 특유의 확증 편향(자신이 짠 코드의 예외 상황을 간과하는 문제)을 방지하고 보안 누락을 사전에 차단합니다.

#### 8. `/branch` 또는 `/fork` — 실험용 대화 분기
현재까지의 대화 맥락과 파일 상태를 유지한 채, 새로운 실험을 위한 가지(Branch)를 칩니다.

```bash
/branch
/fork --here alternative-approach
```

- **활용 팁:** "A方案(라이브러리 업그레이드)과 B方案(자체 패치 구현)" 중 어떤 경로가 적합할지 기존 세션을 오염시키지 않고 나란히 검증할 수 있습니다.

#### 9. `/moa` — 여러 관점으로 결과 비교 (Mixture of Agents)
여러 에이전트 프리셋이 동일한 요청을 병렬로 분석하고 종합 의견을 제시합니다.

```bash
/moa Design a robust fallback strategy for Kubernetes ingress rate limits
```

- **활용 팁:** 아키텍처 트레이드오프 분석이나 고가용성 설계 등 정답이 하나가 아닌 고난도 엔지니어링 의사결정에 적합합니다.

---

### C. 반복 업무와 자동화 (Automation & Background)

터미널을 붙잡고 앉아 있지 않아도 에이전트가 정해진 시간이나 상태 조건에 따라 자율적으로 일하도록 위임합니다.

| 실행 모드 | 주요 명령어 | 담당 역할 및 DevOps 활용 예시 | 특징 및 사용자 상호작용 |
| :--- | :--- | :--- | :--- |
| **대화형 세션**<br>*(User Focus)* | 일반 질의 | 코드 작성, 인터랙티브 디버깅, 단발성 프롬프트 질의 | 포그라운드에서 사용자와 실시간 대화 및 확인 |
| **비동기 백그라운드**<br>*(Background)* | `/bg` | 대규모 모노레포 분석, 취약점 점검, 플래키 테스트 추적 | 별도 세션으로 격리되어 메인 대화 세션을 블로킹하지 않음 |
| **주기적 데몬 / 폴링**<br>*(Daemon & Loop)* | `/cron`<br>`/loop` | 쿠버네티스 롤아웃 상태 감시, 매일 아침 인프라 리포트 생성 | 지정된 주기나 종료 조건 충족 시까지 자율 반복 후 결과 알림 |


#### 10. `/cron` — 정기 작업 자동 실행
주기적인 점검이나 정보 수집 작업을 cron 문법 또는 자연어로 스케줄링합니다.

```bash
/cron add "every day at 9am" "Summarize AI news"
/cron add "*/30 * * * *" "Check staging cluster pod restart counts and alert if abnormal"
/cron list
```

#### 11. `/loop` — 조건을 만족할 때까지 반복
특정 조건이 충족될 때까지 지정된 간격으로 상태를 검사합니다.

```bash
/loop 5m Check whether the deployment is healthy
/loop 1m --times 10 --until "terraform apply finishes" Check status
/loop status
/loop stop
```

> ⚠️ **주의:** 운영 시스템 모니터링 시에는 예상치 못한 루프 누수를 방지하기 위해 `--times`나 `--until` 조건을 함께 지정하는 것이 안전합니다.

#### 12. `/bg` — 오래 걸리는 작업을 백그라운드로 격리
대화 세션의 블로킹을 막고 별도 비동기 프로세스로 작업을 수행시킵니다.

```bash
/bg Analyze this monorepo and identify flaky integration tests
/bg Run security vulnerability scanner against all container images
```

#### 13. Quick Commands — 나만의 단축 명령어
`~/.hermes/config.yaml`에 자주 쓰는 셸 명령이나 에이전트 워크플로우를 짧은 슬래시 명령어로 바인딩합니다.

```yaml
# ~/.hermes/config.yaml
quick_commands:
  gitstatus:
    type: exec
    command: git status --short
  kpods:
    type: exec
    command: kubectl get pods -A | grep -v -E "Running|Completed"
  inbox:
    type: alias
    target: /gmail unread
```

설정 후에는 대화창에서 `/gitstatus`나 `/kpods`만 쳐도 즉시 실행됩니다.

---

### D. 대화와 컨텍스트 효율화

에이전트가 둔해지거나 엉뚱한 답을 내놓는 주원인은 대부분 **컨텍스트 오염** 때문입니다.

| 명령어 | 활용 팁 & DevOps 시나리오 |
| :--- | :--- |
| `/btw` | **사이드 질문:** 메인 작업 흐름을 끊지 않고 "이 CLI 플래그가 macOS BSD 호환이었나?" 같은 단발성 질문을 격리 처리 |
| `/context all` | **토큰 누수 점검:** 현재 로드된 스킬, 툴 정의, 대화 히스토리 중 어떤 항목이 컨텍스트를 과도하게 잡아먹고 있는지 확인 |
| `/sessions` | 작업 세션 목록을 검색하여 어제 디버깅하던 특정 이슈 세션으로 즉시 복귀 |
| `/save` | 중요한 트러블슈팅 세션을 저장하여 향후 사후 분석(Post-mortem) 문서로 활용 |
| `/prompt` | 터미널 입력창 대신 `$EDITOR`(Neovim, VS Code 등)를 열어 수십 줄의 상세 요구사항을 편하게 작성 |
| `/suggestions` | 에이전트가 작업 중 제안한 자동화 힌트나 개선 사항을 일괄 검토 후 수락 |
| `/bundles` | 자주 함께 쓰이는 도메인별 스킬(예: `k8s-devops`, `frontend-qa`)을 패키지로 한 번에 로드 |
| `/reload-mcp` | MCP(Model Context Protocol) 서버 설정이나 도구 스키마를 무중단으로 리로드 |
| `/tools` | 현재 활성화된 툴 및 함수 목록과 세부 파라미터 확인 |

---

## 2. DevOps 엔지니어를 위한 실전 활용 패턴 5선

명령어를 단편적으로 사용하는 것보다, 실제 개발·인프라 라이프사이클에 맞춰 조합할 때 시너지가 극대화됩니다.

| 단계 | 워크플로우 단계 | 핵심 명령어 | 주요 역할 및 안전장치 |
| :---: | :--- | :--- | :--- |
| **1단계** | **프로젝트 초기화** | `/init` | 리포지토리 환경 분석 후 `AGENTS.md`에 빌드/테스트 규칙 고정 |
| **2단계** | **인프라/코드 변경** | `/plan` $\to$ 구현 $\to$ `/review` | 사전 계획 수립 후 구현, 독립 에이전트를 통한 코드 감사 |
| **3단계** | **절차 지식 자산화** | `/learn` $\to$ `/refine` | 성공한 트러블슈팅/배포 절차를 `SKILL.md`로 변환 및 지속 정제 |
| **4단계** | **상시 자동화 이관** | `/cron` & `/loop` | 인프라 상태 수집 및 헬스 체크를 안전한 읽기 전용 데몬으로 예약 |


### 패턴 1. 작업을 수행하면서 동시에 학습시키기 (Zero-to-Skill)
- **적합 대상:** 처음 수행하는 쿠버네티스 롤아웃, 장애 원인 파악, 외부 결제 API 연동
- **흐름:**
  1. Hermes에게 터미널 명령을 실행하게 하며 실제 작업을 수행시킵니다.
  2. 성공 경로와 실패 시 롤백 명령어가 정확히 검증되었는지 확인합니다.
  3. 작업이 끝나자마자 `/learn`을 호출하여 재사용 가능한 워크플로우로 승격시킵니다.
  ```text
  /learn Turn the deployment workflow we just completed into a reusable skill. 
  Include preflight checks, rollback steps, and verification commands.
  ```

### 패턴 2. 코드 수정 → 독립 리뷰 → 테스트 (안전제일 파이프라인)
- **적합 대상:** 프로덕션 테라폼 모듈 리팩터링, CI 워크플로우 수정, C++/Python 백엔드 로직 변경
- **흐름:**
  1. 구현에 앞서 `/plan`을 먼저 지시합니다:
     ```text
     /plan Refactor the deployment CLI and preserve existing behavior
     ```
  2. 계획을 검토하고 승인하여 구현을 마치면, 바로 커밋하지 않고 `/review`를 호출합니다:
     ```text
     /review Check backward compatibility, edge cases, and missing regression tests
     ```
  3. **핵심 원칙:** *작성한 에이전트에게 스스로 검토시키지 말고, 리뷰 모드로 분리하라.*

### 패턴 3. 저장소별 프로젝트 지식 격리
- **적합 대상:** 마이크로서비스 모노레포, 여러 고객사 인프라 저장소를 번갈아 관리할 때
- **흐름:**
  1. 저장소 루트에서 `/init Document the build, test, and release workflow` 실행
  2. 공통 도구 사용법은 개인 스킬(`~/.hermes/skills/`)로 격리하고, 저장소별 특수 절차는 저장소 내 `AGENTS.md`에 기록
  3. 이를 통해 불필요한 프로젝트 지식이 글로벌 프롬프트에 섞여 오염되는 것을 방지

### 패턴 4. 반복 확인 작업을 예약 데몬으로 전환
- **적합 대상:** 카나리 배포 모니터링, 외부 API 헬스 체크, 일일 보안 알림
- **흐름:**
  ```text
  /cron add "every day at 9am" "Check my configured feeds, summarize new items, and report only changes"
  ```
  - **DevOps 팁:** 인프라 파괴 위험이 있는 쓰기(Write) 작업은 절대 크론에 맡기지 말고, **읽기 전용(Read-only) 상태 수집 및 요약 작업부터 자동화**하는 것이 안전합니다.

### 패턴 5. 학습한 지식의 정기적인 '건강검진'
- **적합 대상:** 수십 개의 스킬과 메모리가 누적된 장기 운용 환경
- **흐름:**
  1. `/journey`로 스킬 간 의존성과 오래된 노드 시각화
  2. `/skills list`로 중복되거나 폐기된 스킬 확인
  3. `/refine`으로 자주 쓰는 스킬의 에러 처리 로직 현대화

---

## 3. macOS & 터미널 환경을 위한 고급 운영 꿀팁

### 팁 1. `tmux` / `zellij` 백그라운드 세션과의 조화
Hermes의 `/bg`나 `/loop` 명령은 매우 강력하지만, 로컬 터미널 탭을 실수로 닫아버리면 상위 셸 프로세스가 종료될 위험이 있습니다.
- macOS 터미널에서 상시 운용할 때는 `tmux` 세션 안에서 Hermes를 실행하세요:
  ```bash
  tmux new -s hermes-ops
  hermes
  # Ctrl+B, D 로 백그라운드 분리(Detach) 후 언제든 tmux attach -t hermes-ops 로 복귀
  ```

### 팁 2. macOS 네이티브 알림 및 클립보드 연동
장시간 걸리는 백그라운드 작업(`/bg`)이나 배포 감시(`/loop`)가 끝났을 때 알림을 받도록 Quick Commands에 등록해 두면 편리합니다:

```yaml
# ~/.hermes/config.yaml
quick_commands:
  notify-done:
    type: exec
    command: osascript -e 'display notification "Hermes 작업이 완료되었습니다!" with title "Hermes Agent"'
  clip:
    type: exec
    command: pbpaste
```

### 팁 3. 복잡한 프롬프트는 `$EDITOR` 활용 (`/prompt`)
터미널 인라인 입력기에서는 여러 줄의 YAML 설정이나 복잡한 요구사항을 작성하다 오타가 나기 쉽습니다. 터미널 환경변수에 에디터를 지정해 두면 `/prompt` 실행 시 네이티브 에디터가 열립니다:

```bash
export EDITOR="nvim" # 또는 "code --wait"
```
에디터에서 편안하게 문서를 작성하고 저장 후 닫으면, 작성한 전문이 Hermes의 프롬프트로 전송됩니다.

---

## 4. 지금 바로 확인해 볼 기본 명령어 & 참고 자료

Hermes Agent는 빠른 릴리스 주기 속에 버전별 기능 차이가 있을 수 있으므로, 로컬 환경에서 지원 현황을 먼저 점검해 보세요:

```bash
# 로컬 CLI 버전 및 전체 도움말 확인
hermes --version
hermes --help

# 대화형 세션 내부에서 지원 현황 점검
/help
/skills
/commands
```

### 공식 레퍼런스
- 📖 [Slash Commands Reference](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/slash-commands.md) — 전체 슬래시 명령어 명세
- 🛠️ [Skills 및 /learn 가이드](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md) — 스킬 아키텍처 및 제작법
- 🧠 [Memory 및 Learning Journey](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/memory.md) — 장기 기억 및 이력 관리
- ⏰ [Cron 자동화 가이드](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/cron.md) — 스케줄러 설정 가이드

---

## 5. 마치며: 내가 추천하는 'DevOps 골든 스타터 팩'

모든 명령어를 한 번에 도입할 필요는 없습니다. 개인적으로 가장 높은 생산성 향상을 체감할 수 있는 5가지 조합을 권장합니다:

$$\mathbf{Core\ Stack} = \text{/learn} + \text{/refine} + \text{/init} + \text{/review} + \text{/cron}$$

1. **`/init`** 으로 프로젝트 컨벤션을 고정하고,
2. **`/review`** 로 안전장치를 마련한 뒤 작업하며,
3. 성공한 워크플로우를 **`/learn`** 으로 스킬화하고,
4. 누적된 스킬을 **`/refine`** 으로 정제하며,
5. 일상적인 헬스 체크를 **`/cron`** 으로 위임하는 루틴입니다.

이 조합이 안착되면 Hermes Agent는 일회성 질문에 답하는 챗봇이 아니라, **사용할수록 내 시스템과 인프라를 가장 잘 아는 전담 DevOps 파트너**로 자리잡게 될 것입니다.
