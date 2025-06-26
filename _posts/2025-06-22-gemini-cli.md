---
title: Gemini CLI 툴 소개

toc: true  
toc_sticky: true

categories:
  - dev

tags:
  - gemini
  - cli
  - ai
  - vscode
  - assistant
---

Gemini CLI 툴: VSCode 플러그인과의 차이, 활용법, 실전 시나리오

{% raw %}

## Gemini CLI 이란?

**Gemini CLI**는 Google의 생성형 AI 모델인 Gemini를 터미널 환경에서 직접 사용할 수 있도록 지원하는 커맨드라인 도구입니다. 이 도구를 활용하여 코드 생성, 요약, 번역, 문서화 등 다양한 AI 기능을 명령어 한 줄로 빠르게 수행할 수 있습니다. 특히, 별도의 통합 개발 환경(IDE) 없이도 쉘 스크립트, 자동화, 지속적 통합(CI)과 같은 다양한 환경에서 AI 기능을 활용할 수 있다는 점이 큰 특징입니다. Gemini CLI는 또한 \*\*mcp(Model Context Protocol)\*\*를 지원하여 다양한 파일, 노트, 외부 시스템과의 연동을 가능하게 하며, 워크플로우 자동화 및 데이터 파이프라인 구축에 매우 유용합니다.

## Gemini CLI vs VSCode Gemini Assistant 차이점

Gemini CLI와 VSCode Gemini Assistant는 모두 Gemini AI 모델을 활용하지만, 실행 환경과 주요 사용 목적에서 차이를 보입니다.

| 구분 | Gemini CLI | VSCode Gemini Assistant |
|---|---|---|
| **실행 환경** | 터미널/커맨드라인 | VSCode(에디터 내) |
| **주요 사용 목적** | 자동화, 배치, 스크립트, 빠른 질의 | 코드 작성, 리팩토링, 문서화, 대화형 AI |
| **인터페이스** | 텍스트 기반, 파이프/리다이렉트 활용 | GUI, 코드 인라인, 채팅 패널 |
| **확장성** | 쉘/스크립트와 연동, CI/CD에 통합 용이 | VSCode 내 확장 기능 |
| **설치/사용** | npm, pip 등으로 설치, 어디서나 사용 | VSCode 마켓플레이스에서 설치 |

## 설치 및 기본 사용법 (인터랙티브, CLI 모드)

Gemini CLI는 npm, pip 등 다양한 패키지 매니저를 통해 설치할 수 있습니다.

```bash
# npm
npm install -g @google/gemini-cli
# 또는 pip
pip install gemini-cli
```

**기본 사용법 및 주요 옵션 예시:**

  * **기본 프롬프트 사용:**
    ```bash
    gemini -p "파이썬으로 퀵소트 구현해줘"
    ```
  * **stdin 파이프와 --prompt 옵션 결합:**
    ```bash
    echo "이 코드 설명해줘" | gemini --prompt "설명해줘"
    ```
  * **특정 모델 지정:**
    ```bash
    gemini -m gemini-2.5-pro "최신 모델로 답변해줘"
    ```
  * **디버그 모드 및 체크포인팅 활성화:**
    ```bash
    gemini -d -c "코드 리팩토링"
    ```
  * **모든 파일 컨텍스트 포함:**
    ```bash
    gemini --all_files "이 프로젝트의 구조를 요약해줘"
    ```
  * **샌드박스 환경에서 실행:**
    ```bash
    gemini --sandbox "이 코드가 안전한지 확인해줘"
    ```
  * **인터랙티브 모드 (대화형 프롬프트):**
    ```bash
    gemini
    # 또는
    gemini -p "대화 시작" --debug
    ```
    프롬프트 입력 없이 `gemini`만 실행하면 여러 줄 대화형 입력이 가능하며, 이전 대화 맥락을 유지하며 AI와 상호작용할 수 있습니다.
  * **버전 및 도움말 확인:**
    ```bash
    gemini --version
    gemini --help
    ```

Gemini CLI는 API 키 등록, 프롬프트 템플릿, 출력 포맷(json, markdown 등) 등 다양한 옵션을 지원하며, 최신 버전에서는 멀티라인 입력, 파일 직접 지정, 파이프라인 연동 등 CLI 친화적인 기능이 강화되었습니다.

**설치 명령어 예시:**

다음은 `gemini --help` 명령어의 각 인수에 대한 설명 표입니다.

| 옵션 | 단축 옵션 | 설명 | 타입 | 기본값 |
|---|---|---|---|---|
| `--model` | `-m` | 사용할 Gemini 모델을 지정합니다. | 문자열 | "gemini-2.5-pro" |
| `--prompt` | `-p` | 입력되는 내용(stdin 포함)에 추가될 프롬프트를 지정합니다. | 문자열 | |
| `--sandbox` | `-s` | 샌드박스 환경에서 실행할지 여부를 지정합니다. | 불리언 | |
| `--sandbox-image` | | 샌드박스 이미지 URI를 지정합니다. | 문자열 | |
| `--debug` | `-d` | 디버그 모드로 실행할지 여부를 지정합니다. | 불리언 | false |
| `--all_files` | `-a` | 모든 파일을 컨텍스트에 포함할지 여부를 지정합니다. | 불리언 | false |
| `--show_memory_usage` | | 상태 표시줄에 메모리 사용량을 표시할지 여부를 지정합니다. | 불리언 | false |
| `--yolo` | `-y` | 모든 작업을 자동으로 수락하는 YOLO 모드입니다. | 불리언 | false |
| `--telemetry` | | 텔레메트리 전송을 활성화할지 여부를 제어합니다.  | 불리언 | |
| `--telemetry-target` | | 텔레메트리 대상을 설정합니다. | 문자열 | "local", "gcp" 중 선택 |
| `--telemetry-otlp-endpoint` | | 텔레메트리를 위한 OTLP 엔드포인트를 설정합니다.재정의합니다. | 문자열 | |
| `--telemetry-log-prompts` | | 텔레메트리를 위한 사용자 프롬프트 로깅을 활성화하거나 비활성화합니다. 설정 파일을 재정의합니다. | 불리언 | |
| `--checkpointing` | `-c` | 파일 편집 체크포인팅을 활성화합니다. | 불리언 | false |
| `--version` | `-v` | 버전 정보를 표시합니다. | 불리언 | |
| `--help` | `-h` | 도움말을 표시합니다. | 불리언 | |



## 각각의 사용에 있어서 효율적인 시나리오 예제

  * **Gemini CLI의 효율적 사용 포인트:**
      * 반복 작업 자동화, 대량 파일 처리, 배치 작업에 적합합니다.
      * Git Hook, CI 파이프라인, 쉘 스크립트와 결합하여 AI를 활용할 수 있습니다.
      * 에디터 없이 빠르게 결과만 받고 싶을 때 유용합니다.
  * **VSCode Gemini Assistant의 효율적 사용 포인트:**
      * 코드 작성, 리팩토링, 설명 등 개발 생산성 향상에 기여합니다.
      * 코드 인라인 제안, 대화형 질의, 문서 자동화 등 GUI 친화적인 작업에 적합합니다.
      * 코드 컨텍스트를 직접 활용하는 복잡한 작업에 효율적입니다.

**CLI 환경에서의 활용 시나리오 및 유용한 기준 리스트:**

| 시나리오 | 명령어 예시 | 유용성 포인트 |
|---|---|---|
| 코드 자동 생성 | `gemini -p "Go로 HTTP 서버 샘플 코드"` | 빠른 샘플/템플릿 생성 |
| 코드 설명/리팩토링 | `cat main.py | gemini -p "설명해줘/리팩토링 해줘"` | 대량 파일 일괄 처리 |
| 문서 요약/번역 | `cat README.md | gemini -p "한글로 요약"` | 문서 자동화, 번역 |
| CI/CD 파이프라인 내 자동화 | `gemini -p "테스트 코드 생성" > test.py` | 자동화 스크립트와 결합 |
| Git Hook에서 커밋 메시지 생성 | `git diff | gemini -p "좋은 커밋 메시지 추천"` | 커밋 품질 향상 |

## 결론

Gemini CLI는 터미널 환경에서 AI의 강력함을 최대한 활용할 수 있는 도구입니다. 반복적이고 자동화가 필요한 작업, 대량 파일 처리, CI/CD 등에서는 CLI가, 코드 컨텍스트와 GUI가 중요한 작업에서는 VSCode 플러그인이 각각 강점을 가집니다. 두 도구를 상황에 맞게 병행 활용하면 개발 생산성을 극대화할 수 있습니다.

## 추가 리소스

  * [Gemini CLI 공식 문서](https://github.com/google/gemini-cli)
  * [VSCode Gemini Assistant](https://marketplace.visualstudio.com/items?itemName=google.gemini-assistant)
  * [Google Gemini 공식 소개](https://deepmind.google/technologies/gemini/)

{% endraw %}