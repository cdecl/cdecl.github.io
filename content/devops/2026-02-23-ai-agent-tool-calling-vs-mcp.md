---
title: "AI Agent 구현의 두 갈래: 일반 Tool Calling vs MCP 비교"
tags:
  - ai
  - agent
  - tool-calling
  - mcp
  - llm
  - json-rpc
  - devops
---

AI 에이전트를 구축할 때, LLM이 외부 도구를 사용하게 만드는 과정은 필수적입니다. 하지만 최근 등장한 **MCP(Model Context Protocol)**와 기존의 **Function/Tool Calling**은 비슷해 보이면서도 구조적으로 큰 차이가 있습니다. 오늘은 이 두 방식의 특징과 실제 구현 관점에서의 차이를 상세히 비교해 보겠습니다.

## 1. 한눈에 보는 비교 요약

| 구분 | 일반 Tool Calling (기존 방식) | MCP (Model Context Protocol) |
| :--- | :--- | :--- |
| **핵심 개념** | 함수 정의와 실행 로직의 수동 연결 | 도구의 정의와 실행이 결합된 표준화된 서버 |
| **실행 주체** | 에이전트 애플리케이션 (Local, Tightly Coupled) | 독립된 MCP 서버 (Remote/Isolated) |
| **통신 규격** | 모델별 전용 API (OpenAI, Anthropic 등) | **JSON-RPC 2.0** 표준 프로토콜 |
| **툴 목록 관리** | 코드에 하드코딩, 앱 재배포 필요 | 서버에서 동적으로 `list_tools()` 조회 |
| **확장성** | 새 툴 추가 시 앱 코드 수정 및 재배포 | MCP 서버만 추가·재시작하면 즉시 연동 |
| **상호운용성** | 모델별 규격 변환 코드 직접 작성 필요 | MCP 지원 클라이언트라면 어떤 모델이든 재사용 |
| **컨텍스트 제공** | 주로 '액션(함수 호출)'에 집중 | 툴 + **리소스(파일, DB)** + **프롬프트 템플릿** 패키지 |
| **보안/격리** | 에이전트 프로세스 내에서 직접 실행 | 실행 로직이 서버에 캡슐화, 권한 경계 명확 |

---

## 2. 일반 Tool Calling: "직접 요리하기" 방식

일반적인 방식에서 에이전트는 요리사(LLM)가 준 레시피(JSON)를 보고 **직접 요리(함수 실행)**를 합니다.  
실행 로직이 에이전트 코드 내부에 깊게 박혀 있는 구조(Tightly Coupled)입니다.

### 동작 흐름

```
사용자 요청
    ↓
에이전트 앱 (툴 스키마 정의 보유)
    ↓ (1) 툴 스키마 + 메시지 전달
LLM API
    ↓ (2) tool_calls JSON 반환
에이전트 앱 (if/else 분기로 직접 실행)
    ↓ (3) 로컬 함수 호출 → 결과 획득
LLM API (결과를 포함해 재호출)
    ↓ (4) 최종 텍스트 응답
사용자
```

### 구현 예시 (Python)

```python
import json

# 1. 툴 정의 (JSON 스키마 — 에이전트 코드에 하드코딩)
tools = [
    {
        "type": "function",
        "function": {
            "name": "adder",
            "description": "두 정수를 더합니다.",
            "parameters": {
                "type": "object",
                "properties": {
                    "a": {"type": "integer"},
                    "b": {"type": "integer"},
                },
                "required": ["a", "b"],
            },
        },
    }
]

# 2. LLM 호출
response = llm_client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    tools=tools,
)

# 3. 직접 매핑 및 실행 (에이전트가 실행 오너십 보유)
if response.choices[0].message.tool_calls:
    tool_call = response.choices[0].message.tool_calls[0]
    name = tool_call.function.name
    args = json.loads(tool_call.function.arguments)

    # 툴이 늘어날수록 if/else 분기가 계속 증가
    if name == "adder":
        result = args["a"] + args["b"]   # 에이전트가 직접 실행!
    elif name == "another_tool":
        result = another_local_func(**args)
    # ...

    # 결과를 메시지에 추가하고 재호출
    messages.append(response.choices[0].message)
    messages.append({
        "role": "tool",
        "tool_call_id": tool_call.id,
        "content": str(result),
    })
    final = llm_client.chat.completions.create(model="gpt-4o", messages=messages)
    print(final.choices[0].message.content)
```

**특징 요약**

- 구현이 직관적이고 별도 인프라가 필요 없어 **프로토타이핑에 적합**
- 툴이 늘어날수록 `if/else` 분기가 길어지고 유지보수 비용 증가
- OpenAI용 코드를 Anthropic/Gemini에 사용하려면 **규격 변환 코드를 직접 작성** 필요
- 에이전트 프로세스가 중단되면 툴 실행도 함께 중단

---

## 3. MCP Calling: "배달 주문하기" 방식

MCP 방식에서 에이전트는 요리사(LLM)의 요청을 보고 **전문 식당(MCP 서버)에 주문(Call)**을 넣습니다.  
에이전트는 내부 로직을 몰라도 표준 규격(JSON-RPC 2.0)만 맞추면 됩니다.

### 동작 흐름

```
사용자 요청
    ↓
에이전트 앱
    ↓ (1) list_tools() — 툴 목록 동적 조회
MCP 서버 (독립 프로세스)
    ↓ 툴 스키마 반환
에이전트 앱
    ↓ (2) 툴 스키마 + 메시지 전달
LLM API
    ↓ (3) tool_calls JSON 반환
에이전트 앱
    ↓ (4) call_tool() — 실행 위임 (JSON-RPC)
MCP 서버 (실행 오너십 보유)
    ↓ 결과 반환
에이전트 앱 → LLM 재호출 → 최종 응답
    ↓
사용자
```

### 구현 예시 (Python — mcp 라이브러리 사용)

```python
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

# 1. MCP 서버와 연결 (독립된 서버 프로세스)
server_params = StdioServerParameters(command="python", args=["mcp_server.py"])

async with stdio_client(server_params) as (read, write):
    async with ClientSession(read, write) as session:
        await session.initialize()

        # 2. 툴 목록을 서버에서 동적으로 가져옴 — 하드코딩 불필요
        tools_result = await session.list_tools()
        mcp_tools = [
            {
                "type": "function",
                "function": {
                    "name": t.name,
                    "description": t.description,
                    "parameters": t.inputSchema,
                },
            }
            for t in tools_result.tools
        ]

        # 3. LLM 호출
        response = llm_client.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            tools=mcp_tools,
        )

        # 4. 실행 위임 — 에이전트는 단순히 중계만 수행
        if response.choices[0].message.tool_calls:
            tool_call = response.choices[0].message.tool_calls[0]

            # MCP 서버로 실행 요청 위임 (실행 Ownership: Server)
            result = await session.call_tool(
                name=tool_call.function.name,
                arguments=json.loads(tool_call.function.arguments),
            )

            messages.append(response.choices[0].message)
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": str(result.content),
            })
            final = llm_client.chat.completions.create(model="gpt-4o", messages=messages)
            print(final.choices[0].message.content)
```

**특징 요약**

- 실행 로직이 MCP 서버에 캡슐화되어 **보안성·격리성** 우수
- `list_tools()`로 툴 목록을 동적으로 수신 — 서버 재시작만으로 신규 툴 적용
- 한 번 만든 MCP 서버를 Claude, GPT, Gemini 등 **여러 모델에서 공용** 사용 가능
- 툴 외에도 **Resources**(파일, DB 데이터)와 **Prompt Templates**를 패키지로 제공

---

## 4. 핵심 차이점 상세 분석

### 실행 오너십 (Ownership)

| 항목 | Tool Calling | MCP |
| :--- | :--- | :--- |
| 실행 주체 | 에이전트 앱 | MCP 서버 |
| 프로세스 격리 | ❌ 동일 프로세스 | ✅ 독립 프로세스 |
| 오너십 위치 | 에이전트 코드 내 하드코딩 | 서버 내 캡슐화 |

에이전트가 중단되어도 MCP 서버는 독립적으로 동작할 수 있습니다.

### 컨텍스트 제공 범위 (Context Sharing)

MCP는 툴(Tool), 리소스(Resource), 프롬프트 템플릿(Prompt)의 세 가지 원시 타입을 통해 모델에게 풍부한 컨텍스트를 전달합니다.

```
MCP 서버가 제공하는 것
├── Tools      — 함수 호출 (기존 Tool Calling과 동일)
├── Resources  — 파일, DB 쿼리 결과 등 정적 컨텍스트
└── Prompts    — 재사용 가능한 프롬프트 템플릿
```

일반 Tool Calling은 주로 **액션(함수 호출)**에만 집중하지만, MCP는 **데이터 컨텍스트까지 패키지**로 제공합니다.

### 상호운용성 (Interoperability)

```
일반 Tool Calling:
OpenAI 툴 스키마 ──→ Anthropic 포맷 변환 코드 직접 작성 필요

MCP:
MCP 서버 ──→ (JSON-RPC 2.0 표준) ──→ 어떤 MCP 클라이언트도 즉시 연동
```

JSON-RPC 2.0을 표준 전송 계층으로 사용하므로, MCP를 지원하는 클라이언트라면  
모델 종류에 관계없이 **동일한 서버**를 재사용할 수 있습니다.

### 통신 방식 (Transport) 및 마샬링 (Marshaling)

#### 데이터 규약: JSON-RPC 2.0

MCP의 모든 메시지는 **JSON-RPC 2.0** 표준 형식을 따릅니다.  
데이터는 **JSON(UTF-8 인코딩)**으로 직렬화(Marshaling)되어 전송됩니다.

```json
// tool_call 발생 시 에이전트 → MCP 서버로 전달되는 실제 메시지
{
  "jsonrpc": "2.0",
  "id": "123",
  "method": "tools/call",
  "params": {
    "name": "adder",
    "arguments": {
      "a": 10,
      "b": 20
    }
  }
}
```

에이전트 코드에서 `session.call_tool()`을 호출하면, MCP 라이브러리가 내부적으로 위와 같은 JSON-RPC 메시지를 만들어 서버로 전송합니다. **개발자는 직접 JSON-RPC를 다루지 않아도** 됩니다.

#### 전송 계층별 차이

두 방식 모두 동일한 JSON-RPC 2.0 메시지를 사용하지만, **메시지를 실어 나르는 통로**와 **구분 방식(Framing)**이 다릅니다.

| 구분 | Stdio 방식 | HTTP/SSE 방식 |
| :--- | :--- | :--- |
| **위치** | 로컬 (같은 컴퓨터 내 프로세스) | 원격 (네트워크) |
| **실행 방식** | 에이전트가 서버를 자식 프로세스로 직접 실행 | 외부 서버 URL로 접속 |
| **메시지 구분자** | `\n` (Newline) — JSON 한 줄로 직렬화 | SSE 스펙 (`data:` 접두사 등) |
| **속도** | **매우 빠름** (네트워크 오버헤드 없음) | 상대적으로 느림 (TCP/HTTP 핸드셰이크) |
| **주요 용도** | 로컬 도구 (파일, 셸, DB 등) | 원격 서비스, 클라우드 배포 |

```
# Stdio wire 예시 — 개행(\n)으로 메시지 경계 구분
{"jsonrpc":"2.0","id":"1","method":"tools/call","params":{"name":"adder","arguments":{"a":10,"b":20}}}\n

# HTTP/SSE wire 예시 — SSE 규격으로 메시지 경계 구분
event: message
data: {"jsonrpc":"2.0","id":"1","method":"tools/call","params":{"name":"adder","arguments":{"a":10,"b":20}}}
```

> **요약**: "마샬링된 JSON-RPC 메시지를 보낸다"는 내용물은 동일합니다.  
> **Stdio**는 옆 프로세스에 개행 구분 텍스트를 던지는 것이고,  
> **HTTP**는 원격 서버에 SSE 규격 스트림으로 보내는 것입니다.  
> 에이전트 코드 입장에서는 두 방식 모두 같은 `session.call_tool()` 인터페이스로 투명하게 사용할 수 있습니다.

이러한 표준 규격 덕분에 **Python** 클라이언트와 **Go** 또는 **TypeScript**로 작성된 MCP 서버가 아무런 수정 없이 통신할 수 있습니다.

---

## 5. 언제 무엇을 선택할까

### 일반 Tool Calling이 적합한 경우

- **1~3개**의 간단한 내부 함수만 필요한 프로토타이핑
- 단일 모델(예: OpenAI만)을 고정해서 사용하는 환경
- 외부 서버 인프라를 운영하기 어려운 가벼운 스크립트

### MCP가 적합한 경우

- **기업/팀 환경**에서 여러 외부 서비스(Slack, GitHub, Jira 등)를 연동할 때
- Claude, GPT, Gemini 등 **여러 모델을 교체·비교**해야 하는 에이전트 플랫폼
- 툴뿐 아니라 **파일이나 DB 데이터**도 컨텍스트로 주입해야 하는 경우
- 보안 경계가 필요한 환경 (툴 실행을 격리된 서버에서 처리)
- 다수의 에이전트가 **동일한 MCP 서버를 공유**해야 하는 마이크로서비스 구조

---

## 6. 참고 자료

- [MCP 공식 스펙 (2025-11-25)](https://modelcontextprotocol.io/specification/2025-11-25)
- [Martin Fowler — Function Calls and LLMs](https://martinfowler.com/articles/function-call-LLM.html)
- [HuggingFace MCP Course — Architectural Components](https://huggingface.co/learn/mcp-course/en/unit1/architectural-components)
- [WorkOS — How MCP Servers Work](https://workos.com/blog/how-mcp-servers-work)
- [JSON-RPC 2.0 in MCP](https://mcpcat.io/guides/understanding-json-rpc-protocol-mcp/)