---
title: Gemini CLI의 MCP(Model Context Pro
tags:
  - gemini
  - cli
  - mcp
  - ai
  - tools
  - automation
---
Gemini CLI의 MCP(Model Context Pro



## Model Context Pro

**Model Context Pro

## Gemini CLI와 MCP 지원 개요

**Gemini CLI**는 Google의 생성형 AI 모델인 Gemini를 터미널에서 활용할 수 있는 오픈소스 도구로, MCP를 통해 내장 및 외부 도구와의 통합을 지원합니다. MCP를 활용하면 Gemini CLI는 파일 시스템 작업, 웹 검색, 버전 관리 시스템(Git 등)과의 연동, 또는 사용자 정의 API와의 상호작용과 같은 다양한 기능을 수행할 수 있습니다. Gemini CLI는 MCP를 통해 모델의 컨텍스트를 확장하여 복잡한 작업을 처리하거나, 외부 시스템과의 실시간 데이터 교환을 가능하게 합니다.

### 내장 빌트인 Tools 지원 현황 및 기능 요약

Gemini CLI에는 다음과 같은 주요 MCP built-in tools가 내장되어 있습니다:

| Tool 이름         | 주요 기능 및 설명                                   |
|-------------------|----------------------------------------------------|
| `filesystem`      | 로컬 파일/디렉토리 탐색, 읽기, 쓰기, 검색           |
| `obsidian`        | Obsidian vault 내 노트 검색, 읽기, 태그 관리 등      |
| `webpage`         | 웹페이지 내용 요약, 추출, 분석                      |
| `github`          | GitHub 저장소 코드/이슈/PR 등 검색 및 요약          |
| `python`          | 파이썬 코드 실행, 결과 분석                         |
| `terminal`        | 쉘 명령 실행, 결과를 AI 컨텍스트로 활용              |

- **특징**: 내장 도구는 별도의 설정 없이 즉시 사용 가능하며, Gemini CLI의 샌드박스 환경에서 실행되어 보안성을 유지합니다.
- **제약사항**: 내장 도구는 기본적인 파일 시스템 및 웹 작업에 최적화되어 있으며, 복잡한 외부 시스템과의 연동은 외부 MCP 서버 설정이 필요합니다.[](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)

### 외부 Tools를 사용하기 위한 설정 및 사용 방법

Gemini CLI는 MCP 서버를 통해 외부 도구를 통합할 수 있으며, 이를 통해 사용자 정의 API, 데이터베이스, 또는 특화된 워크플로우와 연결할 수 있습니다. 외부 도구를 사용하기 위한 설정 및 사용 방법은 다음과 같습니다:

#### **MCP 서버 설정**:
   - MCP 서버는 Gemini CLI와 외부 시스템 간의 브릿지 역할을 하며, 로컬 또는 원격 서버로 실행 가능합니다.
   - 설정은 `~/.gemini/settings.json` 파일의 `mcpServers` 항목에 MCP 서버 정보를 추가하여 수행됩니다. 예시 구성은 다음과 같습니다:

     ```json
     {
       "mcpServers": {
         "github": {
           "command": "npx",
           "args": ["-y", "@modelcontextpro
           "env": {
             "GITHUB_PERSONAL_ACCESS_TOKEN": "your_personal_access_token"
           }
         },
         "custom-api": {
           "command": "node",
           "args": ["path/to/custom_mcp_server.js"],
           "env": {
             "API_KEY": "your_api_key"
           }
         }
       }
     }
     ```

   - **설명**:
     - `command`: MCP 서버를 실행하는 명령어 (예: `npx`, `node`, `python` 등).
     - `args`: 서버 실행에 필요한 인수.
     - `env`: 서버 실행에 필요한 환경 변수 (예: API 키, 토큰 등).
     - 예시에서는 GitHub MCP 서버와 사용자 정의 API 서버를 설정한 경우입니다.[](https://developers.google.com/gemini-code-assist/docs/use-agentic-chat-pair-programmer)

#### **외부 도구 사용**:
   - MCP 서버가 등록되면, Gemini CLI는 서버가 제공하는 도구를 자동으로 탐지하여 사용 가능합니다.
   - 예시 명령어:
     ```bash
     gemini -p "GitHub 리포지토리의 최근 이슈 목록 가져와"
     ```
     이 경우, GitHub MCP 서버를 통해 최신 이슈를 조회하고 결과를 반환합니다.
   - MCP 서버는 도구의 스키마를 표준화된 형식으로 제공하므로, Gemini CLI는 이를 기반으로 적절한 도구를 선택해 실행합니다.[](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)

#### **보안 및 신뢰 설정**:
   - MCP 서버는 사용자가 신뢰하는 소스에서 실행되어야 하며, Gemini CLI는 기본적으로 실행 전 확인 대화상자를 표시합니다.
   - YOLO 모드(`--yolo`)를 사용하면 확인 없이 모든 작업을 자동 승인할 수 있지만, 신뢰할 수 있는 서버에서만 사용해야 합니다.

#### **고급 활용**:
   - **동적 도구 탐지**: MCP 서버는 실행 중 도구 목록을 동적으로 제공하며, `gemini /mcp desc` 명령어로 사용 가능한 도구와 스키마를 확인할 수 있습니다.
   - **자동 정리**: 유효하지 않은 도구를 제공하는 MCP 서버는 자동으로 연결이 종료됩니다.
   - **타임아웃 관리**: 서버 응답 시간에 따라 타임아웃을 설정하여 안정성을 유지합니다 (`--timeout` 옵션).[](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)

## 실전 시나리오 및 활용 예제

| 시나리오 | 명령어 예시 | MCP 도구 사용 | 유용성 포인트 |
|---|---|---|---|
| GitHub 이슈 관리 | `gemini -p "최근 7일간 GitHub 이슈 요약"` | GitHub MCP 서버 | 이슈 관리 자동화 |
| API 데이터 조회 | `gemini -p "Salesforce에서 최근 고객 데이터 가져와"` | Custom API MCP 서버 | CRM 통합 |
| 파일 시스템 작업 | `gemini -p "디렉토리의 모든 PDF를 요약해"` | 내장 파일 읽기 도구 | 대량 문서 처리 |
| 웹 검색 통합 | `gemini -p "최신 AI 트렌드 검색해줘"` | 내장 웹 fetch 도구 | 실시간 데이터 수집 |

- **예시 워크플로우**:
  - GitHub MCP 서버를 설정한 후, Gemini CLI를 사용해 리포지토리의 최근 풀 리퀘스트를 조회하고 요약:
    ```bash
    gemini -p "내 GitHub 리포지토리의 최근 5개 풀 리퀘스트 요약해줘"
    ```
  - 사용자 정의 MCP 서버로 Salesforce API와 연동하여 고객 데이터를 조회:
    ```bash
    gemini -p "Salesforce에서 지난주 신규 고객 목록 가져와" --mcp-server custom-api
    ```

## 결론

Gemini CLI의 MCP 지원은 AI와 외부 시스템 간의 강력한 통합을 가능하게 하며, 내장 도구와 외부 MCP 서버를 통해 다양한 작업을 자동화하고 확장할 수 있습니다. 내장 도구는 간단한 파일 및 웹 작업에 즉시 사용 가능하며, 외부 MCP 서버를 설정하면 GitHub, Salesforce, 또는 사용자 정의 API와 같은 복잡한 시스템과의 연동이 가능합니다. 이를 통해 개발자는 터미널에서 AI를 활용한 효율적인 워크플로우를 구축할 수 있습니다.

## 추가 리소스

  * [Gemini CLI 공식 문서](https://github.com/google-gemini/gemini-cli)
  * [MCP 서버 설정 가이드](https://github.com/google-gemini/gemini-cli/blob/main/docs/tools/mcp-server.md)
  * [Google Gemini 공식 소개](https://deepmind.google/technologies/gemini/)

