---
title: MCP-SuperAssistant 사용법
tags:
  - mcp
  - superassistant
  - ai
  - tools
  - chrome-extension
  - automation
---


## Model Context Pro

**Model Context Pro

## MCP-SuperAssistant란?

**MCP-SuperAssistant**는 MCP를 활용해 AI 플랫폼(ChatGPT, Perplexity, Google Gemini, Grok 등)과 외부 데이터 및 도구를 연결하는 크롬 확장 프로그램입니다. 이 도구는 AI 대화 내에서 MCP 도구 호출을 감지하고, 실행 결과를 자동 또는 수동으로 대화에 삽입하여 워크플로우를 간소화합니다. MCP-SuperAssistant는 다양한 AI 플랫폼과의 호환성과 유연한 설정을 통해 개발자와 비즈니스 사용자의 생산성을 극대화합니다.

### MCP-SuperAssistant의 주요 기능

MCP-SuperAssistant는 다음과 같은 기능을 제공합니다:

- **다양한 AI 플랫폼 지원**: ChatGPT, Perplexity, Google Gemini, Grok, Google AI Studio, OpenRouter, DeepSeek 등에서 MCP 도구 실행 가능
- **MCP 도구 실행 및 결과 삽입**: AI 대화 내 도구 호출을 감지해 실행하고 결과를 대화에 삽입
- **실시간 데이터 연결**: MCP를 통해 콘텐츠 저장소, 비즈니스 앱, 개발 환경 등과 안전하게 연결
- **자동/수동 모드**: 자동 모드(도구 실행 및 결과 제출 자동화)와 수동 모드(사용자 제어) 지원
- **확장성과 모듈성**: 플러그인 기반 아키텍처로 새로운 플랫폼 및 도구 추가 가능, WebSocket 및 SSE 지원
- **보안 및 접근성**: 복잡한 API 키 설정 없이 기존 AI 구독 활용, 최소 설정으로 사용 가능
- **6000+ MCP 서버 지원**: 다양한 MCP 서버와 통합해 AI 워크플로우 강화
- **특징**: 확장 프로그램은 간단한 설치로 즉시 사용 가능하며, 샌드박스 환경에서 실행되어 보안성을 유지합니다.
- **제약사항**: 일부 복잡한 도구 호출은 MCP 서버 설정이 필요하며, AI 모델의 프롬프트 이해도에 따라 결과 정확도가 달라질 수 있습니다.

## 초기 설치 및 세팅, 실행 준비

MCP-SuperAssistant를 사용하려면 크롬 확장 프로그램 설치와 MCP 프록시 서버 설정이 필요합니다. 아래는 단계별 설치 및 실행 준비 과정입니다.

### 1. 크롬 확장 프로그램 설치
1. **크롬 웹 스토어에서 설치**:
   - [크롬 웹 스토어](https://chromewebstore.google.com/detail/mcp-superassistant/kngiafgkdnlkgmefdafaibkibegkcaef?hl=en)로 이동합니다.
   - "Chrome에 추가"를 클릭해 확장 프로그램을 설치합니다.
   - 설치 후 브라우저 확장 바에 MCP-SuperAssistant 아이콘이 표시됩니다.
2. **확장 프로그램 활성화 확인**:
   - 크롬의 `chrome://extensions/` 페이지에서 MCP-SuperAssistant가 활성화되어 있는지 확인합니다.

### 2. MCP 프록시 서버 설정
MCP-SuperAssistant는 로컬 프록시 서버를 통해 MCP 서버와 통신합니다. 설정 방법은 다음과 같습니다:

#### 1. **프록시 서버 실행**:
- 터미널 또는 명령 프롬프트를 열고 다음 명령어를 실행하여 MCP SuperAssistant Proxy를 실행합니다:
```bash
npx @srbhptl39/mcp-superassistant-proxy@latest --config ./mcpconfig.json
```

- 이 명령은 `mcpconfig.json` 파일을 참조하여 프록시 서버를 시작하며, 기본적으로 `http://localhost:3006`에서 실행됩니다.[](https://www.npmjs.com/package/%40srbhptl39/mcp-superassistant-proxy)

#### 2. **mcpconfig.json 예시**:
- `mcpconfig.json` 파일을 생성하고 연결할 MCP 서버 정보를 입력합니다. 예시 구성은 다음과 같습니다:
```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@suekou/mcp-notion-server"],
      "env": {
        "NOTION_API_TOKEN": "<your_notion_token_here>"
      }
    },
    "gmail": {
      "url": "https://mcp.composio.dev/gmail/xxxx"
    },
    "youtube-subtitle-downloader": {
      "command": "bun",
      "args": ["run", "/path/to/mcp-youtube/src/index.ts"]
    },
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@wonderwhy-er/desktop-commander"]
    }
  }
}
```

- **설명**:
  - `mcpServers`: 각 서버는 고유한 키(예: `notion`, `gmail`)로 정의됩니다.
  - `command` 및 `args`: stdio 기반 서버의 실행 명령어와 인수(예: `npx`, `bun`).
  - `url`: SSE 기반 서버의 URL.
  - `env`: API 키와 같은 환경 변수.
  - 예시에는 Notion, Gmail, YouTube 자막 다운로더, 데스크톱 명령 서버를 포함했습니다.[](https://socket.dev/npm/package/%40srbhptl39/mcp-superassistant-proxy)

#### 3. **mcpconfig.json 구성**: obsidian, filesystem

     ```json
    {
      "mcpServers": {
        "obsidian-mcp": {
          "command": "npx",
          "args": [
            "-y",
            "obsidian-mcp",
            "/Users/cdecl/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-me"
          ]
        },
        "filesystem": {
          "command": "npx",
          "args": [
            "-y",
            "@modelcontextpro
            "/Users/cdecl/Downloads"
          ]
        }
      }
    }
    ```

#### 4. **프록시 서버 실행 확인**:
- 명령어 실행 후 서버가 `http://localhost:3006`에서 정상적으로 작동하는지 확인합니다. MCP-SuperAssistant 사이드바에서 "Connected" 상태를 확인할 수 있습니다.

### 3. AI 플랫폼에서 확장 프로그램 연결
1. **지원되는 AI 플랫폼 접속**:
   - ChatGPT, Perplexity, Google Gemini, Grok 등 지원되는 AI 플랫폼에 접속합니다.
   - 화면 오른쪽에 MCP-SuperAssistant 사이드바가 표시됩니다.
2. **서버 상태 연결**:
   - 사이드바에서 서버 상태 표시기(기본적으로 "Disconnected")를 클릭합니다.
   - 프록시 서버가 실행 중인 경우, 기본 URL(`http://localhost:3006`)로 자동 연결되거나, 필요 시 URL을 입력합니다.
   - 상태 표시기가 "Connected"로 변경되면 연결 성공입니다.

### 4. 추가 설정 팁
- **검색 모드 비활성화**: ChatGPT, Perplexity 등에서 검색 모드를 끄면 도구 호출 프롬프트 경험이 향상됩니다.
- **Reasoning 모드 활성화**: Grok, ChatGPT 등에서 Reasoning 모드를 켜면 AI가 컨텍스트를 더 잘 이해합니다.
- **최신 모델 사용**: GPT-4o, Gemini 1.5 등 최신 모델은 도구 호출을 더 정확히 처리합니다.
- **문제 해결**:
  - 확장 프로그램이 작동하지 않을 경우: `chrome://extensions/`에서 활성화 확인, 네트워크 연결 확인.
  - 사이드바가 표시되지 않을 경우: 브라우저 새로고침 또는 확장 프로그램 재시작.
  - 프록시 서버 연결 실패 시: `mcpconfig.json` 파일의 형식을 확인하고, 터미널에서 `npx` 명령이 올바르게 실행되는지 점검하세요.

- **자동 모드**:
  - 자동 실행 (Auto Execute): MCP SuperAssistant가 도구 호출을 감지하면 자동으로 도구를 실행합니다.
  - 자동 삽입 (Auto Insert): 도구 실행 결과가 자동으로 대화에 삽입됩니다.
  - 자동 제출 (Auto Submit): 결과가 AI에 자동으로 제출되어 추가 처리됩니다. 때때로 MCP가 실행을 완료하는 데 시간이 필요하기 때문에 자동 제출에 약간의 대기 시간을 설정해야 할 수도 있습니다.

- **Push Content 모드**
  - Push Content Mode는 MCP SuperAssistant의 기능 중 하나로, 페이지 콘텐츠를 오버레이 대신 챗으로 푸시하는 옵션을 제공합니다. 즉, AI가 현재 페이지의 콘텐츠를 분석하고 활용할 수 있도록 해당 콘텐츠를 AI 챗 인터페이스로 직접 보낼 수 있습니다.
    
        


## AI 모델에서 MCP 인식 과정 및 MCP (Tools) 호출 예시

MCP-SuperAssistant는 AI 대화에서 자연어 기반의 도구 호출 요청을 감지하고 실행하며, 결과를 대화에 삽입합니다.  
아래는 특정 사이트의 내용을 요약하여 로컬 경로에 Markdown 파일로 저장하는 시뮬레이션을 포함한 과정과 예시입니다.  
도구 호출은 XML 태그나 특정 형식 대신 **자연어 프롬프트**로 처리됩니다.

### 1. MCP 인식 및 도구 호출 과정
1. **AI 대화에서 자연어 요청**:
   - 사용자가 AI에 자연어로 요청(예: "xAI 웹사이트의 최신 소식을 요약해서 내 문서 폴더에 Markdown 파일로 저장해")을 입력합니다.
   - AI 모델(예: GPT-4o, Gemini 1.5)은 MCP-SuperAssistant가 이해할 수 있는 내부 도구 호출로 요청을 변환하거나, MCP-SuperAssistant가 자연어 요청을 직접 해석하여 적절한 MCP 도구를 매핑합니다.
2. **확장 프로그램이 요청 감지**:
   - MCP-SuperAssistant의 사이드바가 대화 내 자연어 요청을 감지하고, 이를 기반으로 적합한 MCP 도구(예: 웹 요약 및 파일 저장)를 선택합니다.
3. **MCP 서버로 요청 전송**:
   - 감지된 요청은 WebSocket 또는 SSE를 통해 MCP 서버로 전송됩니다.
4. **결과 반환 및 삽입**:
   - MCP 서버가 웹사이트 내용을 요약하고 지정된 경로에 파일을 저장한 후, 결과를 AI 대화에 삽입합니다(자동 또는 수동 모드).

### 2. Tools 호출 프롬프트 예시 (자연어 기반, 특정 사이트 요약 및 파일 저장 시뮬레이션)

| 시나리오 | 자연어 프롬프트 예시 | 내부 MCP 도구 매핑 | 유용성 포인트 |
|----------|---------------------|--------------------|---------------|
| 웹사이트 요약 및 저장 | "xAI 웹사이트의 최신 소식을 요약해서 ~/Documents/xai_summary.md에 저장해" | 웹 요약 및 파일 저장 도구 | 웹 데이터 자동 요약 및 로컬 저장 |
| 뉴스 기사 요약 및 저장 | "BBC 뉴스의 최신 AI 기사를 요약해서 ~/Documents/bbc_ai_summary.md에 저장해" | 웹 요약 및 파일 저장 도구 (AI 필터 적용) | 최신 뉴스 추출 및 정리 |
| 블로그 포스트 요약 및 저장 | "Hacker News의 상위 포스트를 요약해서 ~/Documents/hn_summary.md에 저장해" | 웹 요약 및 파일 저장 도구 (상위 1개 제한) | 소셜 미디어 콘텐츠 정리 |

- **예시 워크플로우** (xAI 웹사이트 요약 및 저장):
  ```plaintext
  사용자: "xAI 웹사이트의 최신 소식을 요약해서 ~/Documents/xai_summary.md에 저장해"
  AI: (내부적으로 요청을 해석하여 MCP 도구 호출로 변환)
  MCP-SuperAssistant:
    1. MCP 서버가 https://x.ai에 접속하여 최신 소식 페이지를 크롤링
    2. 내용을 요약 (예: "xAI는 Grok 3를 통해 AI 워크플로우 혁신 중, 최신 API 업데이트 발표")
    3. 요약된 내용을 ~/Documents/xai_summary.md에 Markdown 형식으로 저장
    4. 대화에 "요약이 ~/Documents/xai_summary.md에 저장되었습니다" 메시지 삽입
  ```

- **저장된 Markdown 파일 예시** (`~/Documents/xai_summary.md`):
  ```markdown
  # xAI 웹사이트 요약 (2025-06-27)

  **출처**: https://x.ai

  **요약**:
  xAI는 Grok 3를 통해 AI와 인간의 상호작용을 혁신하고 있으며, 최신 API 업데이트를 통해 개발자 생산성을 향상시키고 있다. SuperGrok 플랜은 높은 사용 한도를 제공하며, 다양한 AI 플랫폼과의 통합을 지원한다.
  ```

- **자연어 호출을 위한 팁**:
  - **명확한 요청**: 자연어 프롬프트는 구체적이어야 합니다(예: "요약해서 파일로 저장해" 대신 "xAI 웹사이트의 최신 소식을 요약해서 ~/Documents/xai_summary.md에 저장해").
  - **고급 모델 사용**: GPT-4o, Gemini 1.5와 같은 최신 모델은 자연어 요청을 더 정확히 해석하여 적절한 도구 호출로 변환합니다.
  - **Reasoning 모드 활성화**: AI 플랫폼에서 Reasoning 모드를 켜면 자연어 요청의 의도를 더 잘 파악합니다.
  - **확장 프로그램 설정**: MCP-SuperAssistant의 사이드바에서 "자연어 처리" 옵션을 활성화하여 일반 텍스트 요청을 도구 호출로 매핑하도록 설정할 수 있습니다(지원되는 경우).

## 결론

MCP-SuperAssistant는 AI 플랫폼과 외부 데이터 및 도구를 연결하는 강력한 크롬 확장 프로그램으로, MCP를 통해 실시간 데이터 통합과 워크플로우 자동화를 지원합니다. 자연어 프롬프트를 활용하면 사용자는 복잡한 형식 없이도 직관적으로 도구를 호출할 수 있으며, `npx`를 사용한 프록시 서버 실행과 `mcpconfig.json` 설정으로 다양한 MCP 서버와 쉽게 통합할 수 있습니다. 웹사이트 내용을 요약하여 로컬 파일로 저장하는 기능은 정보 수집과 문서화 작업을 효율적으로 만들어줍니다.

## 추가 리소스

* [MCP-SuperAssistant GitHub 저장소](https://github.com/srbhptl39/MCP-SuperAssistant)
* [크롬 웹 스토어 - MCP-SuperAssistant](https://chromewebstore.google.com/detail/mcp-superassistant/kngiafgkdnlkgmefdafaibkibegkcaef?hl=en)
* [Model Context Pro

