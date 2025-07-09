---
title: Cline 사용 가이드

toc: true  
toc_sticky: true

categories:
  - devops

tags:
  - cline
  - ai-coding
  - vscode
  - model-context-protocol
  - autonomous-coding
  - developer-tools

---

Cline의 핵심 개념, 역할, 지원 AI 모델, 설치 및 구성 방법, 그리고 유용한 기능들을 상세히 소개합니다.

## Cline이란?

Cline은 Visual Studio Code(VS Code)와 통합된 오픈소스 AI 코딩 어시스턴트로, 복잡한 소프트웨어 개발 작업을 자동화하고 생산성을 극대화합니다. Claude 3.7 Sonnet, DeepSeek, Google Gemini 등 다양한 대형 언어 모델(LLM)을 활용하여 코드 작성, 디버깅, 리팩토링, 터미널 명령 실행 등을 지원합니다. 이 포스트에서는 Cline의 정의, 역할, 지원 AI 모델, 설치 및 구성 방법, 그리고 개발자를 위한 유용한 기능들을 자세히 다룹니다.

## Cline의 핵심 개념

Cline을 이해하기 위한 주요 개념은 다음과 같습니다:

- **Plan/Act 모드**: Cline의 독특한 듀얼 모드 시스템으로, Plan 모드에서는 작업 계획을 수립하고, Act 모드에서는 계획을 실행합니다.
- **Model Context Protocol (MCP)**: Cline의 확장성을 제공하는 JSON 기반 API로, 외부 도구(예: 브라우저, 데이터베이스)와 통합할 수 있습니다. MCP 서버는 프로젝트별 또는 전역으로 설정할 수 있습니다.
  - **프로젝트별 설정 (`.cline/mcp.json`)**: 프로젝트 루트 디렉터리에 위치하며, 해당 프로젝트에만 적용됩니다.
      - 예시
      ```json
      {
        "mcpServers": {
          "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"]
          },
          "github": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {
              "GITHUB_TOKEN": "your_github_token"
            }
          }
        }
      }
      ```
  - **전역 설정 (`~/.../cline_mcp_settings.json`)**: 모든 프로젝트에 공통으로 적용되는 설정을 관리합니다. 프로젝트별 설정이 전역 설정을 덮어씁니다.
    - **경로**: `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json` (macOS 기준)
    - **용도**: Playwright, Obsidian 등 범용적으로 사용하는 도구를 한 번만 설정하여 모든 프로젝트에서 활용할 수 있습니다.
  - **유용한 MCP 서버 5가지**:
    1. **`@modelcontextprotocol/server-filesystem`**: 로컬 파일 시스템에 접근하여 파일을 읽고 쓰는 기능을 제공합니다.
    2. **`@modelcontextprotocol/server-github`**: GitHub API와 연동하여 이슈 조회, 코드 검색, PR 관리 등을 자동화합니다.
    3. **`@playwright/mcp`**: Playwright를 통해 브라우저를 제어하여 웹 스크래핑이나 E2E 테스트를 수행합니다.
    4. **`obsidian-mcp`**: Obsidian 노트와 상호작용하여 지식 베이스를 AI 워크플로우에 통합합니다.
    5. **`@wonderwhy-er/desktop-commander`**: 데스크톱 애플리케이션을 제어하거나 OS 수준의 작업을 자동화합니다.
- **Tailored Prompts**: `.clinerules` 파일을 통해 프로젝트별 코딩 스타일, 기술 스택, 아키텍처 가이드라인을 설정.
- **Token-Based Pricing**: API 사용량에 따라 비용이 청구되며, Cline은 토큰 사용량과 비용을 실시간으로 표시.
- **Zero Trust Security**: 코드와 데이터는 사용자의 장치에 남아 있으며, 외부 API로 전송 시 명시적 승인이 필요.
- **Deep Context Understanding**: 전체 코드베이스를 읽고 문맥을 파악하여 정확한 코드 제안 제공.
- **Multi-File Edits**: 여러 파일을 동시에 읽고 수정 가능, 대규모 리팩토링에 적합.

### Cline의 역할
Cline은 단순한 코드 자동 완성을 넘어, 개발자와 협력하는 **에이전트형 코딩 파트너** 역할을 수행합니다. 주요 역할은 다음과 같습니다:
- **코드 생성 및 수정**: 자연어 요청(예: "React 계산기 앱 작성")을 통해 코드 파일 생성 및 수정.
- **터미널 명령 실행**: 패키지 설치, 테스트 실행, 배포 등 터미널 작업 자동화.
- **외부 도구 통합**: MCP를 통해 브라우저, 데이터베이스, Jira 등과의 상호작용 지원.
- **프로젝트 문맥 이해**: 코드베이스와 기술 스택을 분석하여 문맥에 맞는 솔루션 제공.
- **비용 투명성**: 실시간 토큰 사용량 및 비용 모니터링으로 예산 관리 지원.

## Cline 설치 및 구성, 기본 사용 방법

Cline은 간단한 설치와 구성으로 빠르게 시작할 수 있습니다. 아래는 설치 및 기본 사용 방법입니다.

### 1. 설치 및 구성
- **필수 요구사항**:
  - Visual Studio Code 설치.
  - OpenRouter, Anthropic, OpenAI 등 API 키 준비.

- **설치 단계**:
  1. VS Code에서 Extensions 마켓플레이스로 이동(`Ctrl+Shift+X`).
  2. "Cline" 검색 후 공식 확장 프로그램 설치.
  3. Cline 사이드바 아이콘 클릭 후 설정(⚙) 버튼 선택.
  4. API 제공자 설정:
     - **OpenRouter** (추천): `https://openrouter.ai/api/v1`를 Base URL로 입력, API 키 추가.
     - **로컬 모델**: Ollama 설치 후 `http://localhost:11434`로 설정.
  5. 선호 모델 선택(예: `deepseek/deepseek-chat`).

- **.clinerules 설정**:
  - 프로젝트 루트에 `.clinerules` 폴더 생성.
  - 예시 규칙 파일(`01-coding.md`):

    ```text
    # Coding Standards
    - Use TypeScript for all JavaScript projects.
    - Follow Airbnb style guide.
    - Prefer functional components in React.
    ```
  - Cline은 `.clinerules` 내 모든 Markdown 파일을 자동으로 적용.

### 2. 기본 사용
- **Cline 실행**: VS Code에서 Cline 사이드바 열기(`Ctrl+Shift+P`, `Cline: Open`).
- **자연어 요청**:
  - 예: "TypeScript로 React 계산기 앱 작성".
  - Cline은 계획을 수립한 후 파일 생성, 의존성 설치, 로컬 서버 실행 등을 수행.
- **승인 프로세스**: 파일 쓰기, 명령 실행 시 사용자 승인 요청(자동 승인 설정 가능).
- **모델 전환**: 작업 유형에 따라 모델 변경(예: 계획 → DeepSeek, 구현 → Claude 3.7 Sonnet).

## 지원 AI 모델

Cline은 다양한 AI 모델을 지원하여 작업 유형과 예산에 맞는 선택을 가능하게 합니다. 주요 모델은 다음과 같습니다:

- **Anthropic Claude 3.7 Sonnet**: 코딩, 복잡한 추론, 문맥 이해에 강력. 비용: $3.00/M 입력, $15.00/M 출력.
- **DeepSeek-R1**: 비용 효율적인 오픈소스 모델, 계획 및 간단한 코딩 작업에 적합. 비용: $0.65/M 입력, $2.19/M 출력.
- **Google Gemini 2.0 Flash**: 리팩토링, 코드 정리 작업에 탁월. 무료 API 요청(월 50회) 제공.
- **OpenAI GPT-3.5 Turbo**: 일상적인 코딩 작업에 적합한 중급 모델.
- **로컬 모델**: LM Studio/Ollama를 통해 로컬에서 실행 가능(예: Qwen 2.5 Coder 32B).

**모델 선택 팁**:
- **시작 단계**: Claude 3 Haiku 또는 GPT-3.5로 시작, 필요 시 업그레이드.
- **복잡한 작업**: Claude 3.7 Sonnet 또는 DeepSeek-R1 + Sonnet 조합 사용.
- **비용 최적화**: OpenRouter의 무료 티어 또는 DeepSeek 활용.

## 유용한 기능 리스트

Cline은 개발자 생산성을 높이는 다양한 기능을 제공합니다:

1. **Plan/Act 모드**:
   - Plan 모드: 작업 목표 분석 및 단계별 계획 수립.
   - Act 모드: 계획 실행, 코드 작성, 테스트 수행.
2. **Model Context Protocol (MCP)**:
   - 커스텀 도구 생성(예: Jira 티켓 조회, AWS EC2 관리).
   - 예시: `add a tool that pulls the latest npm docs`.
3. **체크포인트 시스템**:
   - 작업마다 워크스페이스 스냅샷 저장, 롤백 가능.
   - 예: `Restore Workspace Only`로 다른 버전 테스트.
4. **실시간 비용 추적**:
   - 토큰 사용량 및 비용을 UI에서 실시간 확인.
   - 예: 작업 비용이 $0.50 초과 시 경고.
5. **컨텍스트 윈도우 프로그레스 바**:
   - 모델의 컨텍스트 한계 시각화, 작업 분할 권장.
6. **멀티 파일 편집**:
   - 대규모 리팩토링 시 여러 파일 동시 수정.
7. **터미널 통합**:
   - `npm install`, `git commit` 등 명령 자동 실행.
8. **자연어 이해**:
   - "React 앱에 다크 모드 추가" 같은 요청 처리.
9. **커스텀 규칙 관리**:
   - `.clinerules`로 프로젝트별 가이드라인 설정.
10. **브라우저 상호작용**:
    - 로컬 서버 실행 후 브라우저로 테스트 확인.

## Cline과 Gemini Code Assist 비교

Cline과 Google의 Gemini Code Assist는 모두 개발 생산성을 높이는 AI 코딩 도우미이지만, 철학과 기능에서 차이가 있습니다.

- **Gemini Code Assist란?**
  Google Cloud에서 제공하는 AI 기반 코딩 어시스턴트로, VS Code 및 JetBrains IDEs에서 확장 프로그램 형태로 작동합니다. Gemini 모델을 기반으로 코드 완성, 버그 수정, 테스트 케이스 생성 등 개발 워크플로우에 직접 통합되어 개발자의 생산성을 높이는 데 중점을 둡니다.

- **주요 차이점 요약**

| 기능/특징 | Cline | Gemini Code Assist |
| :--- | :--- | :--- |
| **핵심 철학** | **에이전트 기반 자동화**: 복잡한 작업을 계획(Plan)하고 실행(Act)하는 자율 에이전트 | **개발자 워크플로우 통합**: 코드 완성, 인라인 채팅 등 IDE에 통합된 보조 도구 |
| **주요 기능** | MCP를 통한 외부 도구 통합, 멀티 파일 편집, 터미널 제어 | 전체 코드 블록 완성, 스마트 액션, 채팅 기반 질의응답 |
| **컨텍스트 범위** | 프로젝트 전체 코드베이스, `.clinerules`로 커스텀 규칙 적용 | 열린 파일 및 코드 일부, 더 넓은 컨텍스트를 위한 채팅 기능 |
| **확장성** | **MCP(Model Context Protocol)**로 외부 도구와 자유롭게 연동 가능 | IDE 확장 기능에 의존하며, 외부 도구 연동은 제한적 |
| **대상 사용자** | 복잡한 작업을 자동화하고 싶은 개발자, DevOps 엔지니어 | 일상적인 코딩 생산성 향상을 원하는 모든 개발자 |
| **가격 정책** | API 토큰 기반 사용량 과금 (Pay-as-you-go) | Google Cloud 구독 기반 (주로 엔터프라이즈 대상) |

## 결론

Cline은 **Plan/Act 모드**, **MCP**, **다양한 AI 모델 지원**을 통해 개발자의 생산성을 혁신적으로 향상시킵니다. **설치 및 구성**은 간단하며, **체크포인트 시스템**과 **비용 투명성**으로 안전하고 효율적인 작업이 가능합니다. **유용한 기능**들은 코드 작성부터 외부 도구 통합까지 모든 개발 단계에서 강력한 지원을 제공합니다. Cline을 처음 사용하는 개발자는 소규모 프로젝트로 시작하여 `.clinerules`와 모델 조합을 최적화해 보세요.


## 추가 리소스

* [Cline 공식 사이트](https://cline.bot/)
* [Cline 문서](https://docs.cline.bot/)
* [Cline GitHub 저장소](https://github.com/cline/cline)
* [Cline Discord 커뮤니티](https://discord.com/invite/cline)
