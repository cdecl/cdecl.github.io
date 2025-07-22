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

## 외부 연동: Todoist와 연동하기

Obsidian Tasks를 Todoist와 연동하여 양쪽 앱에서 할 일을 동기화할 수 있습니다. 이를 위해 `Todoist Sync Plugin`과 같은 커뮤니티 플러그인을 활용할 수 있습니다.

1.  **Todoist Sync 플러그인 설치:** Obsidian의 `커뮤니티 플러그인` 마켓에서 "Todoist"를 검색하여 설치하고 활성화합니다.
2.  **API 토큰 설정:**
    *   Todoist 웹사이트에 로그인한 후, **설정 > 통합 > 개발자** 메뉴로 이동합니다.
    *   API 토큰을 복사하여 Obsidian의 Todoist Sync 플러그인 설정에 붙여넣습니다.
3.  **동기화 설정:** 플러그인 설정에서 어떤 프로젝트를 동기화할지, 어떤 형식으로 작업을 가져올지 등을 설정합니다.

이제 Obsidian에서 특정 형식으로 작성한 할 일이 Todoist에 자동으로 추가되거나, Todoist에서 생성한 작업이 Obsidian 노트에 나타나게 할 수 있습니다.

**Example: Obsidian에서 Todoist로 작업 보내기**

```markdown
- [ ] #Todoist/Inbox 회의록 정리하기 @중요 📅 2025-07-25
```

위와 같이 작성하면 Todoist의 'Inbox' 프로젝트에 '회의록 정리하기'라는 작업이 '중요' 태그와 함께 7월 25일 마감일로 생성됩니다.

이 연동을 통해 모바일에서는 Todoist로 빠르게 할 일을 캡처하고, PC에서는 Obsidian에서 노트와 함께 할 일을 관리하는 효율적인 워크플로우를 구축할 수 있습니다.

## 추가 팁

- **Create/Edit Task 모달:** `Command + P`를 눌러 "Tasks: Create or edit task"를 실행하면 편리한 UI를 통해 Task를 생성하고 수정할 수 있습니다.

![](/images/2025-07-22-15-19-52.png)

- **사용자 정의 상태:** 플러그인 설정에서 자신만의 상태(Status)를 추가하여 워크플로우에 맞게 커스터마이징할 수 있습니다.

Tasks 플러그인을 활용하여 Obsidian을 더욱 강력한 생산성 도구로 만들어보세요. 흩어져 있던 생각과 할 일을 한 곳에서 체계적으로 관리하며 작업 효율을 높일 수 있습니다.
