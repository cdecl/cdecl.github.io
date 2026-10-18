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

Hermes Agent는 단순한 질의응답 챗봇을 넘어, 터미널 세션의 실행 컨텍스트, 메모리, 서브 에이전트 분기, 백그라운드 데몬을 정밀하게 제어할 수 있는 다양한 슬래시 명령어를 제공합니다.

### 📊 필수 명령어 요약 (Summary Table)

| 분류 | 명령어 | 핵심 기능 설명 | 대표 실행 예시 |
| :--- | :--- | :--- | :--- |
| **A. 학습·기억·재사용** | `/learn` | 세션에서 성공한 작업을 재사용 가능한 `SKILL.md`로 자동 변환·저장 | `/learn Turn this into a reusable skill` |
| | `/refine` | 누적된 스킬과 메모리의 오류·개선점을 스스로 재검토하여 지식 정제 | `/refine focus on recurring debugging` |
| | `/journey` | 스킬 및 메모리 축적 히스토리를 시각화하고 불필요한 노드 정리 | `/journey list`, `/journey edit <node>` |
| | `/skills` | 설치된 스킬 탐색, 브라우징, 검색 및 핫 리로드 | `/skills search k8s`, `/reload-skills` |
| | `/memory` | 에이전트의 장기 기억 쓰기 승인 게이트를 켜서 지식 오염 방지 | `/memory approval on`, `/memory pending` |
| **B. 품질 & 생산성** | `/init` | 리포지토리 분석 후 프로젝트 지침서(`AGENTS.md`) 자동 생성 및 갱신 | `/init Focus on build, test, deploy` |
| | `/plan` | 실제 코드 수정 전 마크다운 구현 계획 및 영향도 분석을 선행 수립 | `/plan Refactor Terraform modules` |
| | `/review` | 독립적인 서브 에이전트로 변경 사항(diff)을 감사하고 보안 검증 | `/review Check edge cases & security` |
| | `/branch` (`/fork`) | 기존 세션 맥락을 보존하면서 대안적 구현 방식을 실험 분기 | `/fork --here alternative-approach` |
| | `/moa` | Mixture of Agents로 여러 관점의 트레이드오프를 병렬 비교 | `/moa Design rate-limit fallback` |
| **C. 반복 & 자동화** | `/cron` | 주기적인 인프라 점검 및 정보 수집 작업을 정기 예약 실행 | `/cron add "every day at 9am" "..."` |
| | `/loop` | 종료 조건 만족 시까지 일정 주기로 인프라/배포 상태를 반복 폴링 | `/loop 5m Check deployment health` |
| | `/bg` | 대규모 모노레포 분석, 취약점 점검을 백그라운드로 비동기 위임 | `/bg Analyze flaky integration tests` |
| | `Quick Commands` | `~/.hermes/config.yaml`에 자주 쓰는 셸 단축 명령어 등록 | `/gitstatus`, `/kpods` |
| **D. 세션 & 컨텍스트** | `/btw` | 메인 작업 흐름을 끊지 않고 단발성 사이드 질문 격리 처리 | `/btw is this flag supported on macOS?` |
| | `/context all` | 토큰을 과도하게 차지하는 스킬·도구·히스토리 점검 및 최적화 | `/context all` |
| | `/sessions` / `/save` | 이전 작업 세션 복귀 및 중요 트러블슈팅 세션 영구 보관 | `/sessions`, `/save incident-postmortem` |
| | `/prompt` | `$EDITOR`(Neovim, VS Code)를 열어 장문 요구사항을 편하게 작성 | `/prompt` |
| | `/bundles` / `/tools` | 도메인별 스킬 일괄 로드 및 활성화된 도구 목록 확인 | `/bundles`, `/tools` |

---

### A. 학습·기억·재사용 (Knowledge Lifecycle)

에이전트가 시간이 지날수록 똑똑해지려면 새로운 스킬을 등록하는 것만큼이나 **기존 지식을 정제하고 오염된 기억을 격리하는 관리 체계**가 필수적입니다.

- **`/refine` (스스로 개선점 검토 ⭐):** 누적된 작업 이력과 피드백을 바탕으로 등록된 메모리나 스킬의 개선점을 에이전트가 자체 재검토합니다. 일회성 `/learn` 스킬을 지속해서 다듬는 리팩터링 도구입니다.
  ```bash
  /refine focus on recurring debugging workflows
  ```
- **`/journey` (학습 이력 시각화):** 지금까지 에이전트가 축적한 스킬 및 메모리 히스토리를 그래프로 조회하고, 변경된 URL이나 구버전 CLI 플래그 등 낡은 지식 노드를 정리(Prune)합니다.
  ```bash
  /journey list
  /journey edit <node>
  ```
- **`/skills` (스킬 탐색·관리):** 로컬 및 워크스페이스에 설치된 스킬을 검색하고 제어합니다. 스킬 파일 수정 후에는 핫 리로드로 즉시 재색인합니다.
  ```bash
  /skills search k8s
  /reload-skills
  ```
- **`/memory` (기억 쓰기 승인 관리):** 에이전트가 장기 기억에 저장하려는 내용을 인간이 직접 승인하는 게이트키퍼입니다. 임시 트러블슈팅 우회책이 상시 규칙으로 굳어지는 지식 오염을 방지합니다.
  ```bash
  /memory approval on
  /memory pending
  ```

---

### B. 작업 품질과 개발 생산성 (Engineering Quality)

단순 일괄 실행 대신, 안전한 계획 수립과 관점의 분리를 통해 파괴적 실수를 방지합니다.

- **`/init` (프로젝트 규칙 자동 정리):** 현재 디렉토리 구조와 빌드/테스트 스크립트를 스캔하여 프로젝트 전용 지침서인 `AGENTS.md`를 자동 생성합니다.
  ```bash
  /init Focus on build, test, and deployment conventions
  ```
- **`/plan` (실행 전 계획 선행):** 파일 수정이나 명령 실행을 보류하고, 마크다운 형식으로 단계별 구현 계획과 영향도 분석서만 도출합니다. IaC나 DB 마이그레이션 필수 관문입니다.
  ```bash
  /plan Refactor this Terraform module and add state migration plan
  ```
- **`/review` (독립적인 코드 리뷰):** 코드를 작성한 에이전트의 확증 편향을 배제하고, 별도의 검토 에이전트로 변경 사항(diff)의 보안·예외 처리를 독립 감사합니다.
  ```bash
  /review Check edge cases, security, and test coverage
  ```
- **`/branch` / `/fork` (실험용 대화 분기):** 기존 작업 맥락을 유지한 채 새로운 구현 방식이나 라이브러리 교체를 실험할 수 있도록 대화를 분기합니다.
  ```bash
  /fork --here alternative-approach
  ```
- **`/moa` (Mixture of Agents 다각도 비교):** 여러 모델/에이전트 프리셋으로 동일한 요청을 병렬 처리하여 최적의 아키텍처 트레이드오프를 도출합니다.
  ```bash
  /moa Design a robust fallback strategy for Kubernetes ingress rate limits
  ```

---

### C. 반복 업무와 자동화 (Automation & Background)

터미널을 계속 주시하지 않아도 정해진 시간이나 상태 조건에 따라 비동기로 안전하게 작업을 위임합니다.

| 실행 모드 | 주요 명령어 | 담당 역할 및 DevOps 활용 예시 | 특징 및 사용자 상호작용 |
| :--- | :--- | :--- | :--- |
| **대화형 세션** | 일반 질의 | 코드 작성, 인터랙티브 디버깅, 단발성 프롬프트 질의 | 포그라운드 실시간 대화 및 즉시 확인 |
| **비동기 백그라운드** | `/bg` | 대규모 모노레포 분석, 취약점 점검, 플래키 테스트 추적 | 별도 세션 격리로 메인 세션 블로킹 없음 |
| **주기적 데몬 / 폴링** | `/cron`<br>`/loop` | 쿠버네티스 롤아웃 상태 감시, 매일 아침 인프라 리포트 생성 | 지정 주기/조건 충족 시까지 자율 반복 후 알림 |

- **`/cron` (정기 작업 자동 예약):** 매일 반복되는 뉴스 요약이나 정기 인프라 점검을 자연어 또는 cron 표현식으로 스케줄링합니다.
  ```bash
  /cron add "every day at 9am" "Check staging pods restart count and alert if abnormal"
  ```
- **`/loop` (조건 충족 시까지 반복):** 특정 조건이 달성될 때까지 주기적으로 상태를 폴링합니다. (루프 누수 방지를 위해 `--times`나 `--until` 권장)
  ```bash
  /loop 1m --times 10 --until "terraform apply finishes" Check status
  ```
- **`/bg` (오래 걸리는 작업 백그라운드 위임):** 긴 시간이 소요되는 대규모 저장소 풀스캔, 의존성 취약점 점검을 백그라운드로 넘기고 현재 터미널에서는 다른 작업을 계속합니다.
  ```bash
  /bg Analyze this monorepo and identify flaky integration tests
  ```
- **`Quick Commands` (나만의 셸 단축 명령어):** `~/.hermes/config.yaml`에 자주 쓰는 터미널 명령어와 에이전트 작업을 바인딩하여 짧은 슬래시 명령어로 즉시 호출합니다.
  ```yaml
  # ~/.hermes/config.yaml
  quick_commands:
    gitstatus:
      type: exec
      command: git status --short
    kpods:
      type: exec
      command: kubectl get pods -A | grep -v -E "Running|Completed"
  ```

---

### D. 대화와 컨텍스트 효율화

에이전트의 답변 품질 저하와 환각은 대부분 **컨텍스트 오염**에서 비롯됩니다. 아래 명령어들로 세션과 토큰을 최적화할 수 있습니다.

| 명령어 | 핵심 설명 및 활용 팁 |
| :--- | :--- |
| `/btw` | **사이드 질문:** 메인 작업 흐름을 끊지 않고 단발성 질문(예: BSD 플래그 호환 여부)을 별도로 질의 |
| `/context all` | **토큰 누수 점검:** 로드된 스킬, 툴 정의, 대화 히스토리 중 컨텍스트를 과도하게 점유하는 항목 확인 |
| `/sessions` | 이전 작업 세션 목록을 검색하고 특정 트러블슈팅 세션으로 즉시 복귀 |
| `/save` | 중요한 장애 복구 세션을 저장하여 향후 사후 분석(Post-mortem) 문서로 활용 |
| `/prompt` | 터미널 대신 `$EDITOR`(Neovim, VS Code)를 열어 장문의 복잡한 요구사항 작성 |
| `/suggestions` | 에이전트가 작업 중 제안한 자동화 힌트나 개선 사항을 일괄 검토 후 수락 |
| `/bundles` | 자주 함께 쓰이는 도메인별 스킬(예: `k8s-devops`, `frontend-qa`)을 한 번에 로드 |
| `/reload-mcp` | MCP(Model Context Protocol) 서버 설정 및 도구 스키마를 무중단 재로드 |
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
