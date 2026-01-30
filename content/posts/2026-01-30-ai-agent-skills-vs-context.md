---
title: "[AI 엔지니어링] 에이전트의 'Skills' 환상과 56%의 실패율: 왜 우리는 다시 시스템 프롬프트로 돌아가는가?"
tags: ["AI", "Agent", "Vercel", "LLM", "DevOps", "Engineering"]
---

최근 AI 개발자 커뮤니티, 특히 Vercel AI SDK와 Cursor 사용자들 사이에서 매우 흥미로운 화두가 던져졌습니다. Vercel의 소프트웨어 엔지니어 Jude Gao가 발표한 **"[AGENTS.md outperforms skills in our agent evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)"**라는 벤치마크 결과입니다.

많은 개발자가 프로젝트를 진행하며 직감적으로 느끼던 현상—"도구(Skills)를 쥐여주는 것보다, 그냥 문서를 통째로 읽게 시키는 게 훨씬 낫다"—가 실제 데이터로 증명되었습니다. 오늘은 이 벤치마크 데이터와 이를 둘러싼 'Skills vs Context vs Subagents' 아키텍처의 변화를 심도 있게 분석해 봅니다.

***

## 1. 충격적인 데이터: 56%의 무시율 (Ignore Rate)

우리는 흔히 "LLM에게 도구(Tool/Skill/Function Calling)를 주면, 필요할 때마다 똑똑하게 꺼내 쓸 것"이라고 기대합니다. 하지만 Next.js 16 API(당시 미학습 데이터)를 대상으로 한 벤치마크 결과는 이 믿음을 배신했습니다.

### Skills 방식의 현실
*   **56%의 무시율:** 에이전트에게 관련 문서를 도구 형태로 제공했을 때, 모델이 이를 호출하지 않고 자신의 낡은 내부 지식(Internal Weights)으로 대충 답변하거나 환각(Hallucination)을 일으킨 비율이 **절반(56%)**을 넘었습니다.
*   **원인 (LLM의 나태함):** LLM은 기본적으로 '게으른(Lazy)' 성향을 가집니다. 추론 과정에서 토큰과 에너지를 절약하려다 보니, 확실하지 않은 상황에서 도구 호출이라는 복잡한 절차를 건너뛰는 경향이 있습니다.

### 시스템 프롬프트(Context)의 승리
반면, 동일한 문서를 `AGENTS.md`와 같은 파일에 담아 **시스템 프롬프트에 강제로 주입(Context Injection)** 했을 때의 결과는 놀라웠습니다.
*   **정답률 100%:** 단 8KB로 압축된 문서를 시스템 프롬프트로 강제 제공했을 때, 테스트 케이스에서 **완벽한 성능**을 보였습니다. 모델에게 "선택"을 맡기지 않고 "이 지식을 베이스로 하라"고 강제했기 때문입니다.

> [!IMPORTANT]
> '자율성(Agentic)'보다 '확정성(Deterministic)'이 필요한 지식 참조 업무에서는 **강제 컨텍스트 주입**이 정답입니다.

***

## 2. '전지적 시야' vs '터널 시야'

도구를 강제로 사용하게 유도하더라도(이 경우 정답률 79%), 왜 컨텍스트 주입(100%)을 이기지 못할까요? Vercel은 이를 시야의 차이로 설명합니다.

*   **Context 주입 (전지적 시야):** 모델은 문서 전체의 맥락과 뉘앙스, 파일 간의 유기적 관계를 통째로 이해합니다.
*   **Skills 방식 (터널 시야):** 검색된 일부 조각(Chunk)만 모델에게 전달됩니다. 파편화된 정보만으로는 복잡한 설계 규칙을 완벽히 준수하기 어렵습니다.

또한 **속도** 측면에서도 차이가 큽니다.
*   **Skills:** `질문` → `생각` → `도구 호출` → `실행` → `결과 수신` → `최종 답변` (최소 2회 이상의 추론 필요)
*   **Context:** `질문 + 문서` → `최종 답변` (단 1회의 추론으로 종결)

***

## 3. Context Injection vs Subagent: 무엇이 다른가?

최근에는 Skills의 대안으로 **Subagent(하위 에이전트)** 방식도 활발히 논의됩니다.

| 비교 항목 | Context Injection (단일 천재) | Subagent (전문가 팀) |
| :--- | :--- | :--- |
| **비유** | 매뉴얼을 전부 암기한 한 명의 천재 | 코딩, QA, 문서화 전문가로 구성된 팀 |
| **핵심 강점** | **통합적 사고:** A파일 규칙과 B파일 규칙의 모순을 찾아냄. | **격리된 전문성:** 맥락 오염(Context Pollution) 방지 및 전문 업무 수행. |
| **비용/속도** | 저렴하고 빠름 (1회 호출) | 비싸고 느림 (N회 호출 + 통신 비용) |
| **적합한 업무** | 지식 조회, 규칙 준수, 간단한 코드 리뷰 | 복잡한 워크플로우 실행, TDD, 단계별 과제 수행 |

***

## 4. 결론: 2026년의 AI 아키텍처 제언

Vercel의 데이터와 현업의 경험을 종합해 볼 때, 우리는 **"무조건적인 에이전트화"**를 경계해야 합니다.

### 현대적 AI 개발을 위한 3계명
1.  **지식(Knowledge)은 Context로 해결하라:** 프로젝트의 규칙, 컨벤션, 핵심 문서는 Skills로 만들지 말고 시스템 프롬프트(`AGENTS.md`, `.cursorrules`)에 넣어라. LLM의 거대한 Context Window를 믿는 것이 가장 효율적이다.
2.  **행동(Action)만 Skill로 남겨라:** 계산기, API 호출, DB 쓰기 작업 등 LLM이 직접 할 수 없는 '기능'만 도구로 제공하라.
3.  **복잡도는 Subagent로 분리하라:** Context가 너무 비대해져서 모델이 헷갈리기 시작하거나(Context Pollution), 작업 단계가 너무 복잡할 때만 Subagent 패턴을 도입하라.

**요약하자면:**
> "모델에게 **선택권(Skill)**을 주면 게으름을 피우지만, **맥락(Context)**을 주면 천재가 되고, **역할(Subagent)**을 나누면 전문가가 된다."

***

## 부록: AI 도구별 에이전트 규칙 파일(System Prompt) 현황

각 도구는 시스템 프롬프트에 컨텍스트를 주입하기 위해 고유한 규칙 파일 명칭을 사용합니다. 이를 통해 지식을 '강제 주입'하여 정답률을 높일 수 있습니다.

| 도구/환경 | 규칙 파일 명칭 | 특징 및 비고 |
| :--- | :--- | :--- |
| **Cursor** | `.cursorrules` / `.cursor/rules/*.md` | 최신 버전은 폴더 방식(`.cursor/rules/`)을 통한 세밀한 규칙 관리 지원. |
| **Windsurf** | `.windsurfrules` | 프로젝트 루트에서 전역적인 코딩 컨벤션 강제. |
| **Cline / Roo Code** | `.clinerules` | 에이전트의 자율 행동 및 MCP 도구 사용 가이드라인 정의. |
| **Claude** | `CLAUDE.md` | 프로젝트 루트에서 가이드라인, 코딩 스타일, 자주 사용하는 명령어 정의. |
| **Gemini** | `~/.gemini/GEMINI.md` | 사용자 정보 및 전역적인 컨텍스트(Memory)를 관리하는 핵심 파일. |
| **Antigravity** | `brain/task.md` | **Brain** 아키텍처의 핵심. 현재 작업 상태와 구현 계획을 담은 동적 컨텍스트. |
| **GitHub Copilot** | `.github/copilot-instructions.md` | 코파일럿의 답변 스타일 및 특정 프레임워크 사용 지침 설정. |
| **Vercel AI SDK** | `AGENTS.md` | 벤치마크에서 성능이 증명된 방식. 대규모 문서를 요약 및 인덱싱하여 주입. |

---
**출처:** [Vercel Blog - AGENTS.md outperforms skills in our agent evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)
