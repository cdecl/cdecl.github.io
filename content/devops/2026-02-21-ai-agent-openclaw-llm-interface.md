---
title: "AI 에이전트(OpenClaw 등)의 LLM 인터페이스 구현 및 툴 콜링 기술 개요"
tags:
  - ai
  - agent
  - openclaw
  - llm
  - tool-calling
  - devops
---

OpenClaw, Claude 데스크톱 앱, 혹은 로컬 기반의 여러 AI 에이전트들은 내부적으로 LLM(대형 언어 모델)과 어떻게 소통하고, 로컬 환경의 도구(Tool)들을 사용할까요? 이 글에서는 에이전트가 LLM과 인터페이스를 맺는 기술적 구현 내용과 핵심 요소들을 살펴봅니다.

## 1. 지침 파일(`agent.md` 등) 적용 방법

AI 에이전트의 페르소나, 역할, 기본 규칙을 정의하기 위해 주로 `.md` 형태의 지침 파일을 사용합니다. (예: `agent.md`, `system_prompt.txt`, `SOUL.md` 등)

**기술적 구현:**
이러한 지침 파일은 LLM에 전달되는 **시스템 프롬프트(System Prompt)**로 로드됩니다. 에이전트 프로그램이 실행될 때 혹은 세션이 시작될 때 파일 시스템에서 문서를 읽어 LLM의 `system` 역할(role) 메시지에 주입합니다.

**구현 샘플 (Python/가상코드):**
```python
def load_agent_instructions(filepath="agent.md"):
    with open(filepath, "r", encoding="utf-8") as f:
         return f.read()

# LLM API 호출 시
system_instruction = load_agent_instructions()
messages = [
    {"role": "system", "content": system_instruction},
    {"role": "user", "content": "오늘의 주요 시스템 로그를 요약해줘."}
]
response = llm_client.chat.completions.create(
    model="gpt-4o",
    messages=messages
)
```

## 2. 스킬(`skills`) 파일 적용 방법

단순한 지침을 넘어, 특정 작업(예: "웹 크롤링", "데이터베이스 조회")을 수행하기 위한 리소스나 스크립트 모음을 `skills` 디렉토리로 구성할 수 있습니다.

**기술적 구현:**
스킬 파일들은 로컬 시스템에 저장되어 있으며, 사용자의 요청이 들어올 때 일종의 RAG(Retrieval-Augmented Generation) 방식이나 직접 컨텍스트화되어 동적으로 프롬프트에 삽입됩니다.

- **스킬 메타데이터 인덱싱**: 에이전트는 사용 가능한 스킬 목록과 설명을 미리 읽어 LLM에게 "너는 현재 이러한 스킬들을 알고 있다"고 프롬프트 상단에 알려줍니다. (프롬프트 주입)
- **동적 파일 읽기**: LLM이 특정 스킬의 세부 내용이 필요하다고 판단하면, 로컬 파일 시스템을 읽는 툴(view_file 등)을 통해 해당 스킬의 `.md`나 관련 스크립트 내용을 읽어들여 적용합니다.

## 3. 툴 콜링(Tool Calling)의 판단 및 실행 방법

에이전트 시스템에서 가장 중요한 부분은 "언제 외부 도구를 부를 것인가" 그리고 "어떻게 실행할 것인가"입니다.

### 3.1 Tool Calling 판단 방법
대부분의 현대적인 에이전트는 LLM 자체의 능력(Function Calling 기능)을 활용합니다. 개발자는 LLM API에 **가용한 툴의 명세서(Schema)**를 JSON 형태로 설명(Description), 파라미터(Parameters) 등과 함께 전달합니다.
LLM은 사용자의 요청을 분석하다가 자신의 내부 지식만으로 답변할 수 없는 작업(예: 로컬 파일 검색, 터미널 명령 실행, 웹 크롤링 등)이라 판단하면, 일반 텍스트 답변이 아닌 **Tool Call 객체**를 반환합니다.

### 3.2 Tool 호출 및 실행 흐름
1. **Tool 정의 전달**: 에이전트 시스템이 LLM에 툴 스키마(이름, 설명, 파라미터 타입)를 전달.
2. **LLM의 판단 (Tool Call 반환)**: LLM이 툴 호출에 필요한 인자(Arguments)를 채워 `tool_calls` 객체로 시스템에 반환.
3. **도구 실행 (시스템/로컬 환경)**: 에이전트 시스템이 해당 응답을 파싱하여, 실제 로컬 환경에서 지정된 함수나 쉘 명령어를 단독으로 실행합니다. (이때 사용자의 승인을 받거나, 샌드박스 환경에서 실행하여 보안을 확보합니다.)
4. **결과 반환**: 명령어나 함수의 실행 결과(stdout, stderr, 혹은 오류 메시지)를 확보하여 다시 LLM 시스템으로 전달되는 메시지 목록에 추가합니다.
5. **최종 응답 생성**: LLM이 해당 결과를 읽고 분석하여 사용자에게 최종적으로 유의미한 텍스트 결과를 보고합니다.

**구현 샘플 (툴 실행 주기):**
```python
import json
import subprocess

# 1. Tool 정의
tools = [
    {
        "type": "function",
        "function": {
            "name": "run_shell_command",
            "description": "운영체제 쉘 명령어를 실행합니다.",
            "parameters": {
                "type": "object",
                "properties": {
                    "command": {
                        "type": "string",
                        "description": "실행할 터미널 커맨드"
                    }
                },
                "required": ["command"]
            }
        }
    }
]

# 2. LLM 호출 및 판단
response = llm_client.chat.completions.create(
    model="gpt-4o",
    messages=messages,
    tools=tools
)

# 3. LLM이 Tool Call을 요구한 경우
if response.choices[0].message.tool_calls:
    for tool_call in response.choices[0].message.tool_calls:
        if tool_call.function.name == "run_shell_command":
            # 전달받은 파라미터 파싱
            args = json.loads(tool_call.function.arguments)
            cmd = args["command"]
            
            # 4. 로컬 도구 실제 실행
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            output = result.stdout if result.returncode == 0 else result.stderr
            
            # 5. 결과를 다시 메시지 히스토리에 추가하여 LLM 재호출
            messages.append(response.choices[0].message) # 어시스턴트의 Tool Call 기록을 추가
            messages.append({
                "role": "tool",
                "tool_call_id": tool_call.id,
                "content": output
            })
            
            final_response = llm_client.chat.completions.create(
                model="gpt-4o",
                messages=messages
            )
            print(final_response.choices[0].message.content)
```

## 마무리

OpenClaw나 다양한 코딩 에이전트는 결론적으로 **LLM의 Function Calling 메커니즘**과 **로컬 시스템 간의 인터페이스 다리(Bridge)** 역할을 합니다. 단편적인 프롬프팅 기술을 넘어서, `agent.md`로 기본 캐릭터와 지침을 설정하고, 구조화된 `skills` 파일로 전문 기능 영역을 확장하며, 동적인 툴 콜링(Tool Calling) 방식을 통해 물리적인 시스템 자원을 자유롭고 유연하게 제어하는 것이 최신 독립형 AI 에이전트 아키텍처의 핵심입니다.
