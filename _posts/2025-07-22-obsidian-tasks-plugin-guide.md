---
title: Obsidian Tasks 플러그인으로 할 일 관리

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - obsidian
  - tasks
  - gtd
  - productivity
---

Obsidian을 단순한 노트 앱을 넘어 강력한 할 일 관리(To-Do) 도구로 만들어주는 Tasks 플러그인에 대해 알아봅니다. 이 플러그인을 활용하면 여러 노트에 흩어져 있는 할 일들을 한 곳에서 모아보고, 마감일, 우선순위, 반복 설정 등 다양한 기능을 통해 체계적으로 관리할 수 있습니다.

## Tasks 플러그인 핵심 기능

Tasks 플러그인은 마크다운 기반의 할 일 관리를 한 단계 업그레이드해줍니다. 기본적인 체크박스 외에 다양한 메타데이터를 추가하여 할 일을 더욱 스마트하게 관리할 수 있습니다.

### 기본 Task 생성

가장 기본적인 할 일은 마크다운의 체크박스 문법을 사용하여 생성합니다.

```markdown
- [ ] 책 읽기
- [ ] 블로그 글 작성하기
- [ ] 운동하기
```

### 상태 표현

Tasks 플러그인은 단순한 '미완료/완료'를 넘어 다양한 상태를 표현할 수 있습니다.

- **완료 (Done):** `x` 또는 `X`를 괄호 안에 넣어 표시합니다.
  - `- [x] 책 읽기 ✅ 2025-07-22`
- **진행 중 (In Progress):** `-`를 괄호 안에 넣어 표시합니다.
  - `- [-] 블로그 글 작성하기`
- **취소됨 (Cancelled):** `~`를 괄호 안에 넣어 표시합니다.
  - `- [~] 약속 취소`

### 속성 추가 (날짜, 우선순위, 반복)

Task에 이모지(Emoji)와 날짜를 조합하여 다양한 속성을 부여할 수 있습니다.

- **마감일 (Due Date):** 📅 `YYYY-MM-DD`
  - `- [ ] 프로젝트 제안서 제출 📅 2025-07-31`
- **예정일 (Scheduled Date):** ⏳ `YYYY-MM-DD`
  - `- [ ] 회의 준비 ⏳ 2025-07-25`
- **시작일 (Start Date):** 🛫 `YYYY-MM-DD`
  - `- [ ] 새로운 기능 개발 시작 🛫 2025-08-01`
- **완료일 (Done Date):** ✅ `YYYY-MM-DD` (완료 시 자동으로 추가됨)
- **우선순위 (Priority):** 🔼 (높음), ⏫ (가장 높음), 🔽 (낮음)
  - `- [ ] 긴급 버그 수정 ⏫ 📅 2025-07-23`
- **반복 설정 (Recurrence):** 🔁 `규칙` (e.g., `every day`, `every week on Sunday`)
  - `- [ ] 주간 보고서 작성 🔁 every Friday 📅 2025-07-25`

## Task 쿼리 사용하기

Tasks 플러그인의 가장 강력한 기능은 `tasks` 코드 블록을 사용하여 여러 노트에 흩어져 있는 할 일들을 동적으로 모아보는 것입니다.

### 기본 쿼리

모든 할 일을 표시합니다.

````markdown
```tasks
not done
```
````

### 고급 쿼리 예시

다양한 필터와 정렬 옵션을 조합하여 원하는 할 일 목록을 만들 수 있습니다.

- **오늘까지 마감인 할 일:**
  ````markdown
  ```tasks
  due before tomorrow
  not done
  ```
  ````

- **'프로젝트A' 태그가 있고 우선순위가 높은 할 일:**
  ````markdown
  ```tasks
  tags include #프로젝트A
  priority is high
  not done
  ```
  ````

- **경로(path)를 기준으로 특정 폴더의 할 일만 보기:**
  ````markdown
  ```tasks
  path includes "프로젝트/2025년"
  not done
  sort by due
  ```
  ````

## 외부 연동: Todoist와 동기화하기

Obsidian을 Todoist와 연동하면 강력한 시너지를 낼 수 있습니다. 모바일에서는 Todoist로 빠르게 할 일을 입력하고, 데스크톱에서는 Obsidian에서 관련 노트와 함께 할 일을 관리하는 워크플로우를 구축할 수 있습니다. 이를 위한 대표적인 커뮤니티 플러그인 두 가지를 비교해 보겠습니다.

### 1. Todoist Sync Plugin (단방향: Todoist → Obsidian)

이 플러그인은 주로 **Todoist의 작업을 Obsidian으로 가져오는 단방향 동기화**에 초점을 맞춥니다.

*   **작동 방식:** Todoist API를 사용하여 필터링된 작업 목록(예: '오늘 마감', '프로젝트 A')을 Obsidian 노트에 마크다운 형식으로 렌더링합니다. `todoist` 코드 블록을 사용합니다.
*   **설정:**
    1.  `커뮤니티 플러그인`에서 "Todoist Sync"를 설치하고 활성화합니다.
    2.  Todoist 설정에서 API 토큰을 발급받아 플러그인 설정에 입력합니다.
*   **사용 예시:**
    ````markdown
    ```todoist
    {
      "name": "오늘 할 일",
      "filter": "today | overdue"
    }
    ```
    ````
    위와 같이 작성하면 오늘 마감이거나 기한이 지난 Todoist 작업 목록이 해당 위치에 표시됩니다.
*   **장점:** Obsidian에서 노트를 작성하면서 Todoist 작업 목록을 함께 확인하고 싶을 때 유용합니다. Obsidian 내에서 Todoist 작업을 완료 처리하는 것도 가능합니다.

### 2. Ultimate Todoist Sync (양방향)

이름처럼 더 강력한 **양방향(Two-way) 동기화** 기능을 제공하는 플러그인입니다.

*   **작동 방식:**
    *   **Todoist → Obsidian (가져오기):** Todoist에서 생성/수정한 작업이 설정된 규칙에 따라 Obsidian의 특정 노트로 동기화됩니다.
    *   **Obsidian → Todoist (내보내기):** Obsidian의 동기화된 노트에서 작업을 수정/완료하면, 변경사항이 다시 Todoist에 반영됩니다.
*   **설정:**
    1.  `커뮤니티 플러그인`에서 "Ultimate Todoist Sync"를 설치하고 활성화합니다.
    2.  마찬가지로 Todoist API 토큰을 플러그인 설정에 입력합니다.
    3.  동기화할 Todoist 프로젝트나 필터, 그리고 동기화 내용을 저장할 Obsidian 노트를 지정하는 등 조금 더 상세한 설정이 필요합니다.
*   **장점:** 두 앱의 데이터를 항상 최신 상태로 유지할 수 있어, 양쪽 앱을 모두 활발하게 사용하는 사용자에게 적합합니다.

### 어떤 플러그인을 선택할까?

| 기능 | Todoist Sync Plugin | Ultimate Todoist Sync |
| --- | --- | --- |
| **동기화 방향** | 단방향 (Todoist → Obsidian) | 양방향 (Obsidian ↔ Todoist) |
| **주요 용도** | Todoist 작업을 Obsidian에서 보기 | 양쪽 앱의 할 일을 완전히 동기화하기 |
| **설정 복잡도** | 간단함 | 다소 복잡함 |
| **추천 사용자** | Todoist를 메인으로 사용하며 Obsidian에서 작업을 확인하고 싶을 때 | Obsidian과 Todoist를 모두 적극적으로 사용하는 경우 |

자신의 작업 스타일에 맞는 플러그인을 선택하여 두 앱의 장점을 최대한 활용하는 효율적인 할 일 관리 시스템을 만들어 보세요.

## 추가 팁

- **Create/Edit Task 모달:** `Command + P`를 눌러 "Tasks: Create or edit task"를 실행하면 편리한 UI를 통해 Task를 생성하고 수정할 수 있습니다.

![](/images/2025-07-22-15-19-52.png)

- **사용자 정의 상태:** 플러그인 설정에서 자신만의 상태(Status)를 추가하여 워크플로우에 맞게 커스터마이징할 수 있습니다.

Tasks 플러그인을 활용하여 Obsidian을 더욱 강력한 생산성 도구로 만들어보세요. 흩어져 있던 생각과 할 일을 한 곳에서 체계적으로 관리하며 작업 효율을 높일 수 있습니다.
