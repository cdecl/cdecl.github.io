---
title: 'Agent Skill 가이드: AI 에이전트의 전문성을 위한 모듈식 아키텍처'
tags:
  - agent-skill
  - ai-agent
  - claude-code
  - gemini-cli
  - anthropic
  - progressive-disclosure
---

Claude Code나 Gemini CLI를 사용해본 개발자라면 이런 경험을 했을 겁니다: 특정 도메인의 작업을 할 때 에이전트가 너무 일반적으로만 접근한다는 것입니다. 이것이 바로 **Agent Skill**이 필요한 이유입니다.

## 1. Agent Skill이란?

Agent Skill은 **특정 도메인의 전문 지식을 패키징한 재사용 가능한 모듈**입니다. 2025년 Anthropic이 정식으로 도입한 이 기술은 에이전트에게 단순한 명령이 아닌 **진정한 전문성**을 제공합니다.

더 정확히는:
- **구조**: `SKILL.md` 파일과 지침, 스크립트, 참고 자료를 포함하는 폴더
- **작동**: 에이전트가 관련성을 감지하면 자동으로 해당 Skill을 활성화하여 그 분야의 전문가처럼 행동
- **핵심 원리**: 필요한 정보만 필요한 시점에 로드하는 Progressive Disclosure

일반 LLM은 비결정성 특성으로 같은 작업을 반복해도 결과가 달라질 수 있습니다. Agent Skill은 구조화된 절차와 리소스를 제공하여 이를 개선합니다.

***

## 2. Context File과 핵심 차이

컨텍스트 파일 (Context File, CLAUDE.md, GEMINI.md, AGENTS.md)은 프로젝트의 전반적인 성격과 규칙을 정의합니다. 먼저 각각의 역할을 정리해보겠습니다:

### CLAUDE.md / GEMINI.md: 프로젝트 전체의 개성

**목적**: "이 프로젝트에서 넌 이렇게 행동해야 해"
- 프로젝트 시작 시 **항상** 로드됨
- 코딩 규약, 아키텍처 방식, 개인 선호도 정의
- 예: ESM 모듈 사용, camelCase 함수명, 세미콜론 금지

### Agent Skill: 작업별 전문성

**목적**: "이 작업을 할 때는 이 전문성을 사용해"
- 사용자 요청에 따라 **동적으로** 로드됨
- 특정 도메인의 전문 지식과 절차 구조화
- 예: PDF 폼 작성, API 문서 자동 생성, 데이터베이스 마이그레이션

**비유로 이해하기**:

| 관점 | CLAUDE.md | Agent Skill |
|-----|----------|------------|
| 학교 비유 | 학교의 학칙, 교복 규칙 | 수학, 영어, 화학 같은 과목별 교과서 |
| 회사 비유 | 회사 전체 업무 매뉴얼 | 재무팀, 마케팅팀 같은 부서별 절차서 |
| 적용 방식 | 항상 적용 | 필요할 때만 활성화 |

***

## 3. 역할 기반 에이전트(Oh-My-OpenCode) vs Agent Skill

최근 주목받는 **Oh-My-OpenCode**와 Agent Skill은 서로 다른 철학을 따릅니다.

### Oh-My-OpenCode: 다중 에이전트 오케스트레이션

여러 전문화된 에이전트가 **동시에** 작업합니다:

- **Sisyphus**: 메인 에이전트 (Engineering Manager 역할)
- **Frontend Engineer** (Gemini): 프론트엔드 작업
- **Librarian** (Claude Sonnet): 라이브러리 및 문서 탐색
- **Oracle** (GPT-4): 기술 자문

**장점**: 병렬 처리, 모델별 강점 활용, 복잡한 프로젝트에 탁월  
**단점**: 높은 구성 복잡도, 다중 API 구독 필요, 비용 증가

### Agent Skill: 단일 에이전트 + 동적 전문성

하나의 에이전트가 필요에 따라 다양한 전문성을 **순차적으로** 로드합니다:

**장점**: 간단한 설정, 낮은 토큰 사용, 높은 재사용성, 플랫폼 독립적  
**단점**: 병렬 처리 불가, 한 번에 하나의 깊이 있는 Skill만 사용

**선택 기준**:

| 상황 | 추천 |
|-----|-----|
| 토큰 비용 최소화 | Agent Skill ✓ |
| 단순한 작업 + 높은 정확도 | Agent Skill ✓ |
| 복잡한 프로젝트 (다층 구조) | Oh-My-OpenCode |
| 여러 모델의 강점 필요 | Oh-My-OpenCode |
| 팀 협업 / 공유 가능성 | Agent Skill ✓ |

***

## 4. Agent Skill 정의 방법

### 기본 폴더 구조

```
my-skill/
├── SKILL.md          # ← 필수 (메타데이터 + 지침)
├── scripts/          # ← 선택 (실행 가능한 코드)
│   └── validate.sh
├── references/       # ← 선택 (상세 문서)
│   └── detailed-guide.md
└── assets/           # ← 선택 (템플릿, 아이콘)
    └── templates/
```

### SKILL.md 작성하기

`SKILL.md`는 두 부분으로 구성됩니다:

```markdown
---
name: pdf-form-filler
description: PDF 양식 필드를 자동으로 채우고 서명을 추가합니다. 
             PDF 문서 작성 시 사용하세요.
version: 1.0.0
allowed-tools: "Bash, Read"
---

# PDF 양식 작성

이 Skill을 사용하여 다음을 수행할 수 있습니다:
- PDF의 모든 필드 자동 감지
- 구조화된 데이터로부터 필드 자동 작성
- 서명 추가 및 검증

## 기본 절차

1. **필드 분석**: PDF의 모든 입력 필드 식별
2. **데이터 매핑**: 제공된 데이터를 필드와 매핑
3. **작성 및 검증**: 필드 작성 후 데이터 검증
4. **저장**: 완성된 PDF 저장

## 참고 자료

자세한 PDF 필드 유형은 `references/pdf-fields.md` 참고
```

### Progressive Disclosure: 3단계 로딩

Agent Skill의 핵심은 **필요한 정보만 필요할 때 로드**하는 것입니다:

```
┌─────────────────────────────┐
│ Level 1: 메타데이터 (항상)  │
├─────────────────────────────┤
│ name, description           │
│ → 50-100 토큰               │
│ → Skill 필요 여부 판단      │
└─────────────────────────────┘
         ↓ (필요하면)
┌─────────────────────────────┐
│ Level 2: 핵심 지침 (로드)   │
├─────────────────────────────┤
│ 주요 절차와 가이드          │
│ → 500-1000 토큰             │
│ → 실제 작업 실행            │
└─────────────────────────────┘
         ↓ (상세 필요하면)
┌─────────────────────────────┐
│ Level 3: 참고 자료 (온디맨드)│
├─────────────────────────────┤
│ references/, scripts/       │
│ → 필요시에만 추가 로드      │
└─────────────────────────────┘
```

결과: **기존 방식 대비 토큰 사용 50-80% 감소**

### 모범 사례

1. **메타데이터는 명확하게**
   ```yaml
   # ✓ 좋은 예
   description: PDF 양식의 입력 필드를 자동으로 채우고 검증합니다. 
                사용자가 "양식을 작성해줘"라고 요청할 때 사용됩니다.
   ```

2. **지침은 간결하게 (500줄 이하)**
   ```markdown
   # ✓ 하기
   - SKILL.md: 200줄의 핵심 절차
   - references/: 상세한 부분 문서화
   ```

3. **구체적인 예제 포함**
4. **참고 자료는 평탄한 구조로** (deeply nested 피하기)

***

## 5. Agent Skill 사용 방법

### Claude Code에서 사용하기

**1단계: Skill 디렉토리 생성**
```bash
mkdir -p ~/.claude/skills/explain-code
```

**2단계: SKILL.md 작성**

`~/.claude/skills/explain-code/SKILL.md`:
```markdown
---
name: explain-code
description: 복잡한 코드를 간단하게 설명합니다. 
             사용자가 "이 코드 설명해줄래?"라고 요청할 때 사용됩니다.
---

# 코드 설명 Skill

## 설명 방식

1. **함수 목적**: 함수가 무엇을 하는가
2. **입출력**: 입력값과 반환값
3. **로직**: 단계별 처리 과정
4. **예외**: 처리해야 할 예외 상황
```

**3단계: Claude Code 시작**
```bash
cd your-project
claude
```

**4단계: Skill 자동 활성화 또는 수동 호출**
```
> 이 코드를 설명해줄래?
# Claude가 자동으로 explain-code Skill 활성화

또는

/explain-code
```

### Gemini CLI에서 사용하기

```bash
# 설정 수정
echo '{"contextFileName": "GEMINI.md"}' > ~/.gemini/settings.json

# Skill 생성
mkdir -p ~/.gemini/skills/my-skill
# SKILL.md 작성

# 사용
gemini "이 작업을 해줄 수 있어?"
```

### 프로젝트별 Skill

`.claude/skills/project-setup/SKILL.md`:
```markdown
---
name: project-setup
description: 이 프로젝트의 환경 설정 및 초기화
---

# 프로젝트 설정

## 환경 설정
1. nvm use 18.0.0
2. npm install
3. npm run dev
```

***

## 6. Agent Skill 생태계와 npx skills

Agent Skill의 가장 큰 장점은 **개방형 표준**이라는 점입니다. 누구나 Skill을 만들어 배포할 수 있으며, 이를 관리하기 위한 공식/비공식 CLI 도구들이 등장하고 있습니다. 그 중심에 `npx skills` (`ai-agent-skills`)가 있습니다.

### npx skills란?

`npx skills`는 다양한 AI 에이전트(Claude Code, Cursor, Windsurf 등)에 Agent Skill을 설치하고 관리할 수 있는 **유니버설 패키지 매니저**입니다. npm에서 패키지를 설치하듯, 명령 한 줄로 새로운 전문성을 에이전트에 추가할 수 있습니다.

### 주요 명령어

- **Skill 설치**: 
  ```bash
  # 이름으로 설치
  npx skills install pdf-form-filler
  
  # GitHub 저장소에서 직접 설치
  npx skills install owner/repo
  ```
- **설치된 Skill 목록 확인**:
  ```bash
  npx skills list
  ```
- **새로운 Skill 검색**:
  ```bash
  npx skills search "database"
  ```
- **대화형 브라우저 실행**:
  ```bash
  npx skills browse
  ```

이러한 도구를 통해 개발자들은 자신만의 전문 지식을 패키징하여 팀과 공유하거나, 커뮤니티에서 검증된 스킬을 즉시 프로젝트에 도입할 수 있습니다.

### npx add-skill: 대화형 Skill 생성 도구

기존에 이미 만든 Skill을 설치하는 것 외에, `npx add-skill`은 **새로운 Skill을 대화형으로 생성**하는 도구입니다.

**기본 사용법**:
```bash
npx add-skill
```

**대화형 프롬프트**:
```
? Skill 이름을 입력하세요: pdf-form-filler
? Skill 설명: PDF 양식 필드를 자동으로 채웁니다
? 어떤 도구를 사용하시겠습니까? (Bash, Read, Python)
? 참고 자료를 추가하시겠습니까? (Y/n)
? GitHub에 배포하시겠습니까? (y/N)
```

**생성되는 파일 구조**:
```
my-new-skill/
├── SKILL.md           # ← 자동 생성된 메타데이터 + 기본 템플릿
├── README.md          # ← 설치/사용 가이드
├── scripts/
│   ├── setup.sh
│   └── validate.sh    # ← 자동 생성된 검증 스크립트
├── references/
│   └── detailed-guide.md
├── .gitignore
└── package.json       # ← npm 배포용
```

**고급 옵션**:
```bash
# 특정 템플릿으로 생성
npx add-skill --template=data-processing

# 특정 도구 조합
npx add-skill --tools="Node,Bash,Python" --with-tests

# 즉시 설치
npx add-skill --auto-install

# TypeScript 지원
npx add-skill --typescript
```

**생성된 SKILL.md 예시**:
```markdown
---
name: pdf-form-filler
description: PDF 양식 필드를 자동으로 채웁니다. 사용자가 "PDF 양식을 채워줄래?"라고 요청할 때 사용됩니다.
version: 1.0.0
author: your-name
license: MIT
allowed-tools: "Bash, Read, Python"
---

# PDF 양식 작성 Skill

## 목적
구조화된 데이터로부터 PDF 양식을 자동으로 채웁니다.

## 사용 시나리오
- 대량의 PDF 양식을 자동으로 작성해야 할 때
- 반복적인 데이터 입력 자동화
```

### 생성된 Skill 검증

`npx add-skill`이 생성한 Skill을 검증하려면:

```bash
# Skill 유효성 검사
npm run validate

# 메타데이터 검증
npm run validate:metadata

# 에이전트에서 테스트
npx skills install ./my-new-skill
```

### Skill 배포 워크플로우

```bash
# 1. Skill 생성
npx add-skill

# 2. 테스트
cd my-new-skill
npm test

# 3. npm에 배포 (공개 또는 private)
npm publish

# 4. Skill 레지스트리에 등록
npx skills publish

# 5. 다른 개발자가 설치 가능
npx skills install my-new-skill
```

***

## 6.5 npx skills vs 다른 패키지 매니저

### npx skills의 역할 이해

`npx skills`는 npm, pip, brew와 같은 **패키지 매니저**의 Skill 버전입니다. 하지만 일반 패키지와는 다르게 동작합니다:

| 비교 | npm | pip | brew | **npx skills** |
|-----|-----|-----|-----|---|
| **설치 대상** | JavaScript 라이브러리 | Python 패키지 | 시스템 소프트웨어 | Agent Skill |
| **저장소** | npmjs.com | pypi.org | brew.sh | GitHub + npm |
| **설치 위치** | node_modules/ | site-packages/ | /usr/local/ | ~/.claude/skills/ (플랫폼별) |
| **실행 방식** | import/require | import | CLI 명령 | 에이전트가 로드 |
| **사용자** | 개발자 | 개발자/데이터과학자 | 모든 사용자 | AI 에이전트 |
| **버전 관리** | semver | semver | 버전 고정 | semver + Skill 메타데이터 |
| **의존성 관리** | 엄격함 | 엄격함 | 느슨함 | Skill별 독립적 |

### npm vs npx skills: 구체적 비교

```bash
# npm: 코드 라이브러리 설치
npm install lodash
→ node_modules/lodash/ 설치
→ JavaScript 코드에서 require('lodash') 사용

# npx skills: 에이전트 전문성 설치
npx skills install pdf-form-filler
→ ~/.claude/skills/pdf-form-filler/ 설치
→ 에이전트가 자동 또는 수동으로 로드
```

### 에이전트 Skill 관리 도구 전체 비교

현재 Agent Skill을 관리하는 여러 도구들이 있으며, 각각의 특징을 이해하는 것이 중요합니다:

| 도구 | 역할 | 설치 | 배포 | 검색 | 프로그래밍 | 특징 |
|-----|-----|-----|-----|-----|----------|------|
| **npx skills** | 패키지 매니저 | ✓ | ✓ | ✓ | CLI | 표준화, 공개/private 모두 지원 |
| **npx add-skill** | Skill 생성기 | ✓ | ✓ | - | CLI | 대화형, 템플릿 기반 빠른 생성 |
| **Claude Code UI** | 로컬 관리 | - | - | - | GUI | 직관적, 프로젝트 종속적 |
| **Cursor Skills** | Cursor 전용 | ✓ | ✓ | ✓ | GUI | Cursor IDE 깊은 통합 |
| **VS Code Extension** | VS Code 통합 | ✓ | ✓ | ✓ | GUI | VS Code 네이티브 UI |
| **Gemini Skills** | Gemini CLI | ✓ | - | - | CLI | Google 생태계 연동 |

### npx skills 사용 워크플로우

```
┌─────────────────────────────────────────────────────────┐
│ npx skills: Skill 생명주기 관리                          │
└─────────────────────────────────────────────────────────┘

1️⃣ 검색
   npx skills search "pdf"
   → npm + GitHub에서 검색
   → 10개의 pdf 관련 Skill 표시

2️⃣ 브라우즈 (선택)
   npx skills browse
   → 웹 브라우저에서 대화형 검색
   → 설명, 리뷰, 버전 정보 표시

3️⃣ 설치
   npx skills install pdf-form-filler
   → ~/.claude/skills/pdf-form-filler/ 다운로드
   → 메타데이터 검증
   → 의존성 확인

4️⃣ 사용 (에이전트에서)
   > "PDF 양식을 채워줄래?"
   → 에이전트가 pdf-form-filler Skill 자동 활성화
   → 또는 /pdf-form-filler 명령 수동 호출

5️⃣ 버전 관리
   npx skills update pdf-form-filler
   → 새 버전 확인 및 설치

6️⃣ 목록 확인
   npx skills list
   → 설치된 모든 Skill 표시 (버전 포함)

7️⃣ 제거 (선택)
   npx skills uninstall pdf-form-filler
   → ~/.claude/skills/pdf-form-filler/ 삭제
```

### npx skills vs npx add-skill: 역할 구분

```
┌─────────────────────┐
│ npx add-skill       │
│ (생성 도구)         │
└─────────────────────┘
        ↓
  새 Skill 만들기
  ├─ SKILL.md 자동 생성
  ├─ 템플릿 제공
  └─ 테스트 스크립트 포함
        ↓
┌─────────────────────────────────┐
│ npm publish (선택)              │
│ Skill 배포 (npmjs.com)          │
└─────────────────────────────────┘
        ↓
┌─────────────────────┐
│ npx skills          │
│ (배포 도구)         │
└─────────────────────┘
        ↓
  Skill 공유 및 재사용
  ├─ 검색 및 설치
  ├─ 버전 관리
  └─ 팀 배포
```

**구체적 흐름**:
```bash
# 1. 새 Skill 생성 (npx add-skill)
npx add-skill
# → my-new-skill/ 디렉토리 생성
# → SKILL.md, package.json, scripts/ 자동 생성

# 2. 로컬 테스트
cd my-new-skill
npm test
npx skills install ./my-new-skill

# 3. npm에 배포 (선택)
npm publish

# 4. npx skills에 등록 (선택)
npx skills publish my-new-skill
# → 이제 다른 사람이 설치 가능

# 5. 다른 사람이 설치 (npx skills)
npx skills install my-new-skill
# → npm + GitHub에서 자동으로 찾아 설치
```

### npx skills가 공개/private Skill을 구분하는 방법

```
공개 Skill (누구나 설치 가능):
1. npmjs.com에 public으로 배포
2. npx skills publish my-skill
3. GitHub public 저장소
→ npx skills search, install 가능

Private Skill (팀만 사용):
1. npm private 레지스트리 사용
2. GitHub private 저장소
3. 팀원에게 수동으로 공유
→ npx skills install owner/repo (GitHub URL)
→ npx skills install @company/my-skill (scoped package)
```

### 선택 기준

**npx skills 추천**:
- ✓ 팀 전체에 배포할 때
- ✓ 커뮤니티와 공유할 때
- ✓ 여러 프로젝트에서 재사용할 때
- ✓ 버전 관리가 필요할 때

**Claude Code UI 추천**:
- ✓ 단일 프로젝트 Skill만 필요할 때
- ✓ 빠른 로컬 테스트
- ✓ GUI 기반 관리 선호

**npx add-skill 추천**:
- ✓ 새로운 Skill을 빠르게 생성할 때
- ✓ 템플릿이 필요할 때
- ✓ 자동화된 검증이 필요할 때

***

## 7. AI 에이전트 도구 생태계 전체 비교

Agent Skill은 에이전트 강화의 한 방법이지만, 더 넓은 생태계 속에서 이해할 필요가 있습니다.

### 에이전트 확장 방식 비교

| 방식 | 도구 | 복잡도 | 토큰 | 재사용성 | 학습곡선 | 추천 대상 |
|-----|-----|-------|------|---------|---------|----------|
| **Context File** | CLAUDE.md | 낮음 | 높음 | 낮음 | 매우 쉬움 | 프로젝트 규약, 시작점 |
| **Agent Skill** | SKILL.md | 중간 | 낮음 | 높음 | 쉬움 | 도메인별 전문성 |
| **Custom Tools** | MCP + Node/Python | 높음 | 매우 높음 | 높음 | 어려움 | 복잡한 통합 (DB, API) |
| **System Prompts** | Claude API | 낮음 | 높음 | 중간 | 쉬움 | API 기반 개발 |
| **Plugins/Extensions** | VS Code, Cursor | 매우 높음 | 매우 높음 | 매우 높음 | 매우 어려움 | 에디터 깊은 통합 |

### 도구별 사용 시나리오

**Context File (CLAUDE.md)**
```markdown
언제: 모든 프로젝트 시작
내용: 코딩 규약, 아키텍처 스타일, 금지 사항

예: "Python 프로젝트에서는 항상 Type Hint 사용"
로드: 항상 (매번 100-200 토큰)
```

**Agent Skill**
```markdown
언제: 특정 작업이 필요할 때
내용: 도메인별 절차, 제약사항, 참고 자료

예: "Python ORM 마이그레이션 Skill"
로드: 필요시만 (처음 100-300 토큰, 이후 필요시)
```

**MCP Tools**
```markdown
언제: 외부 시스템 연결이 필요할 때
내용: 데이터베이스, API, 파일시스템 액세스

예: "PostgreSQL 쿼리 실행 도구"
로드: 필요시만 (고토큰 비용)
```

**System Prompt (Claude API)**
```markdown
언제: 프로그래밍 API 사용
내용: 역할 정의, 응답 포맷, 제약사항

예: "이 API는 코드 리뷰 봇으로 동작합니다"
로드: 매번 요청 (최적화 필수)
```

### Claude Code vs Cursor vs Windsurf: Agent Skill 지원 비교

| 기능 | Claude Code | Cursor | Windsurf |
|-----|-----------|--------|----------|
| **Agent Skill 기본 지원** | ✓ (2025 Q1) | ✓ (2024 Q4) | ✓ (베타) |
| **SKILL.md 인식** | ✓ | ✓ | ✓ |
| **자동 활성화** | ✓ | ✓ (수동 주로) | ✓ |
| **UI 관리 인터페이스** | ✓ | ✓ | - |
| **npx skills 연동** | ✓ | ✓ | 부분 |
| **다중 Skill 동시 사용** | - | ✓ (제한) | - |
| **프로젝트별 Skill** | ✓ | ✓ | ✓ |
| **팀 공유 기능** | ✓ (GitHub) | ✓ (GitHub) | - |
| **Skill 버전 관리** | ✓ | - | - |
| **디버깅 지원** | ✓ | 부분 | - |

**각 에디터 추천**:

**Claude Code**
- 최고의 Agent Skill 지원 (Anthropic 공식)
- Progressive Disclosure 완벽 구현
- 토큰 효율성 최고
- 추천: 도메인 전문성이 중요한 작업

**Cursor**
- Agent Skill + 코드 편집의 균형
- 다중 Skill 부분 지원
- 약간의 토큰 오버헤드
- 추천: 대화형 개발 + 전문성 필요

**Windsurf**
- 아직 불안정 (베타 상태)
- 최고 토큰 효율성 추구
- 향후 최고 지원 가능성
- 추천: 최신 기술 선호, 대규모 프로젝트

### 도구 조합 전략

**최소 비용 (토큰 효율성 우선)**
```
1순위: Claude Code (SKILL.md 활용)
2순위: Cursor (필요시만)
❌ Windsurf: 베타 불안정
```

**최고 생산성 (비용 보조)**
```
메인: Cursor (실시간 개발)
특화: Claude Code (깊이 있는 작업)
참고: Windsurf (최신 기능 테스트)
```

**엔터프라이즈 (팀 협업)**
```
코어: Claude Code (표준화)
Skill 배포: npx skills + GitHub
팀: GitHub 공유 폴더
학습: Skill 카탈로그 관리
```

***

## 8. Agent Skill 사용의 주요 이점

### 7.1 토큰 효율성 (Context Window 최적화)

Progressive Disclosure 덕분에 **대폭적인 토큰 절감**이 가능합니다:

실제 비교 사례:
- Claude Code: 260.8K 입력 토큰 (auto-compaction 포함)
- Gemini CLI: 432K 입력 토큰
- **40% 효율 개선**, 비용 차이 30% (Claude $4.80 vs Gemini $7.06)

### 7.2 재사용성과 공유

**한 번 만든 Skill, 어디든 사용 가능**:

```
my-pdf-skill/

사용처:
✓ Claude Code (데스크톱)
✓ Claude.ai (웹)
✓ Claude API (프로그래밍)
✓ Gemini CLI (호환 설정)
✓ GitHub Copilot (예정)
✓ VS Code (예정)
```

**팀 간 공유**:
```bash
company-repo/skills/
├── pdf-processing/
├── database-queries/
└── deployment/

# 팀원들이 복사하여 사용
cp -r company-repo/skills/* ~/.claude/skills/
```

### 7.3 일관성 있는 에이전트 행동

Skill을 사용하면 같은 절차를 반복하므로 더 **예측 가능한 결과**를 얻습니다:

```markdown
# 절차 (항상 일관되게 따름)
1. 테이블 구조 확인
2. 쿼리 검증 (읽기 전용 여부)
3. 실행 전 미리보기 제공
4. 결과 요약
```

- 프롬프트만: 첫 번째 결과 A, 두 번째 결과 B (비일관성)
- Skill 사용: 매번 일관된 결과 A (일관성)

### 7.4 도메인 전문성의 체계화

Skill을 통해 특정 도메인의 **최적 절차를 코드화**할 수 있습니다. 에이전트는 항상 이를 따르므로:
- 편향되지 않은 분석
- 위험 요소 고려
- 체계적인 평가

### 7.5 버전 관리

```bash
skills/pdf-processing/
├── SKILL.md (v1.2.0)
└── references/changelog.md

# 특정 버전 사용
git checkout skills/pdf-processing@v1.1.0

# 변경 추적
git log skills/pdf-processing/SKILL.md
```

### 7.6 문서와 실행의 통합

```markdown
---
name: database-migration
---

# 데이터베이스 마이그레이션

## 단계
1. 백업 생성
2. 마이그레이션 실행
3. 검증

→ 이 마크다운이 **문서**이면서 동시에 **에이전트의 실행 지침**
→ 문서 vs 코드 불일치 문제 해결
```

***

## 8. 실전 예제: API 문서 생성 Skill

```markdown
---
name: api-doc-generator
description: Node.js/Express API를 자동으로 문서화합니다. 
             새로운 엔드포인트 추가 시 또는 "API 문서 생성"요청 시 사용됩니다.
version: 2.0.0
allowed-tools: "Bash, Read, Python"
---

# API 문서 생성 Skill

## 목적
Express 라우터를 분석하여 OpenAPI/Swagger 호환 문서를 자동 생성합니다.

## 프로세스

### 1단계: 라우터 파일 분석
- Express 라우터에서 모든 엔드포인트 추출
- HTTP 메서드 식별

### 2단계: 엔드포인트 정보 추출
각 엔드포인트에서:
- 경로
- 요청 파라미터 (query, body)
- 응답 형식
- 설명

### 3단계: OpenAPI 스키마 생성
```json
{
  "openapi": "3.0.0",
  "paths": {
    "/api/users": {
      "get": {
        "summary": "사용자 목록 조회",
        "responses": {
          "200": {"description": "성공"}
        }
      }
    }
  }
}
```

## 예제

**입력 코드**:
```typescript
router.get('/users', authenticate, async (req, res) => {
  const { page = 1, limit = 10 } = req.query;
  // ...
});
```

**생성되는 문서**:
```yaml
GET /api/users:
  description: 사용자 목록 조회 (인증 필수)
  parameters:
    - name: page
      type: integer
      default: 1
  responses:
    200:
      description: 성공
```

## 참고 자료
자세한 OpenAPI 스펙은 `references/openapi-spec.md` 참고
```

***

## 9. Agent Skill의 한계와 주의점

### 한계

1. **병렬 처리 불가**: 한 번에 하나의 Skill만 깊이 있게 사용
2. **복잡한 실행 로직**: 매우 복잡하면 MCP Tools 권장
3. **초기 학습곡선**: SKILL.md 작성에 시간 필요

### 주의점

```markdown
❌ 하지 말 것:
- 모든 정보를 SKILL.md에 넣기 (Progressive Disclosure 무시)
- 깊은 폴더 구조 (skills/pdf/form/field/types/)
- 너무 많은 Skill (100개 이상은 오버헤드)
- 민감한 정보 포함 (API 키, 암호)
```

***

## 10. 결론

Agent Skill은 AI 에이전트를 **일반인에서 도메인 전문가로 변신**시키는 강력한 도구입니다:

| 측면 | 효과 |
|-----|-----|
| **토큰 비용** | 50-80% 감소 |
| **실행 일관성** | 비결정성 완화 |
| **재사용성** | 팀 전체, 프로젝트 간 공유 |
| **유지보수** | 문서와 코드 통합 |
| **확장성** | 새 도메인 추가 용이 |

### 시작하기

1. **간단한 예제부터**: PDF 편집, 코드 설명 같은 단순 작업
2. **Progressive Disclosure 이해**: Level 1-3 로딩 구조 파악
3. **메타데이터 정교하기**: description이 Skill 활성화의 핵심
4. **점진적 확장**: 1-2개의 Skill로 시작 → 필요에 따라 추가

Agent Skill을 통해 에이전트가 단순한 채팅 도구에서 도메인 전문가로 거듭나는 경험을 해보세요!

## 11. 추가 리소스

- [Anthropic Agent Skills 공식 문서](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Claude Code Skills 가이드](https://code.claude.com/docs/en/skills)
- [VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Agent Skills Framework 백서](https://www.linkedin.com/pulse/agent-skills-framework-technical-whitepaper-ai-akkshay-sharma-rx9fc)
