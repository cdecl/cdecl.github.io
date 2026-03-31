---
title: "macOS에서 MLX 환경 설치 및 운영 (Ollama와 비교)"
tags:
  - macos
  - mlx
  - ollama
  - llm
  - qwen
  - devops
---

최근 로컬 환경에서 대규모 언어 모델(LLM)을 구동하기 위한 도구들이 눈부시게 발전하고 있습니다. 특히 Apple Silicon(M칩 시리즈)을 탑재한 macOS에서는 디바이스의 하드웨어 리소스를 얼마나 잘 활용하는지에 따라 추론 속도와 메모리 효율이 크게 달라집니다.

오늘은 Apple에서 직접 개발한 머신러닝 프레임워크인 **MLX**에 대해 알아보고, 가장 대중적인 도구인 **Ollama**와의 비교, 그리고 강력한 성능을 자랑하는 **Qwen3.5 9B** 모델을 기준으로 로컬 환경을 구성하는 방법을 정리해 보겠습니다.

---

## 1. MLX란 무엇인가?

**MLX**는 Apple의 머신러닝 연구 팀(Apple Machine Learning Research)에서 Apple Silicon을 위해 특별히 설계한 배열(Array) 및 머신러닝 프레임워크입니다. 
PyTorch나 JAX와 매우 유사한 Python API를 제공하면서도, Apple의 **통합 메모리(Unified Memory)** 아키텍처를 가장 깊은 수준에서 최적화하여 사용할 수 있도록 만들어졌습니다.

Ollama와의 근본적인 방향성 차이는 다음과 같습니다.

*   **Ollama**: C++ 기반의 `llama.cpp` 엔진을 래핑한 **완성형 애플리케이션 및 플랫폼**입니다. 사용자가 복잡한 설정 없이도 모델을 쉽게 내려받고 즉시 API 서버 형태로 실행하는 데 초점이 맞춰져 있습니다.
*   **MLX**: Apple 생태계를 위한 **Python 라이브러리 및 프레임워크**입니다. 모델 아키텍처를 직접 제어하거나, 파인튜닝(Fine-Tuning), 새로운 구조 실험 등 개발자 및 연구자가 하드웨어 성능을 극대화해서 끌어쓰기 적합합니다. 

## 2. MLX vs Ollama: 성능 및 편의성 비교

### 편의성과 사용자 경험 (UX)
*   **Ollama (승)**: 초기 구동과 편의성 면에서는 단연 Ollama가 압도적입니다. 터미널에서 `ollama run qwen2.5` 명령어 한 줄이면 이미지 다운로드부터 실행까지 알아서 완료됩니다. Docker를 다루듯 직관적인 CLI를 제공합니다.
*   **MLX**: 기본적으로 Python 개발 환경(가상 환경 설정, pip 라이브러리 설치 등)을 다룰 줄 알아야 합니다. 일반 사용자에게는 진입장벽이 있을 수 있으나, Python 스크립트 기반 생태계에 모델을 직접 통합하려는 개발자에게는 오히려 친숙하고 유연합니다.

### 성능 (추론 속도 및 메모리 효율)
*   **MLX (승)**: 순수 Apple Silicon 환경에서 극한의 성능과 최적화를 이끌어내는 데는 MLX가 더 우수합니다. 통합 메모리 대역폭을 네이티브 수준으로 활용하며, 새로운 모델 최적화나 양자화(Quantization), LoRA 어댑터 적용 등에 있어 오버헤드가 적어 처리 속도가 매우 빠릅니다. 
*   **Ollama**: `llama.cpp` 엔진도 Metal API를 딥하게 지원하여 매우 훌륭한 속도를 보여줍니다. 그러나 Apple이 직접 튜닝하는 MLX에 비해서 구조적 한계로 리소스 점유나 토큰 생성 속도에서 근소하게 밀리는 경우가 있습니다.

> **결론**: 가장 쉽고 빠르게 LLM을 띄우고 싶다면 **Ollama**를, Apple Silicon의 퍼포먼스를 끝까지 쥐어짜거나 직접 개발/튜닝을 병행하려면 **MLX**를 추천합니다.

---

## 3. macOS에서 MLX 설치 및 환경 구성

MLX 환경 구성은 Python 기반의 독립된 영역(가상환경)을 만들어 진행하는 것이 가장 안전합니다.

### 1) Python 가상환경 구성 (uv 활용)
가장 빠르고 간편한 파이썬 패키지 매니저인 `uv`를 사용해 환경을 구성하는 것을 권장합니다.
`uv`를 사용하면 가상 환경 생성 및 패키지 설치 속도가 대폭 향상됩니다.

```bash
# 폴더 생성 및 이동
mkdir mlx_env
cd mlx_env

# uv 설치 (macOS 기본 설치 방법)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 파이썬 가상환경 생성 및 활성화
uv venv
source .venv/bin/activate
```

### 2) MLX 라이브러리 설치 (`mlx-lm` vs `mlx-vlm`)
MLX 생태계에는 모델 목적에 따라 크게 두 가지 패키지가 제공됩니다.

*   **`mlx-lm`**: 텍스트 생성을 위한 대규모 언어 모델(LLM)을 다룰 때 사용합니다. (예: Qwen, Llama, Mistral 등)
*   **`mlx-vlm`**: 텍스트와 이미지를 함께 처리하는 시각-언어 모델(VLM)을 다룰 때 사용합니다. (예: LLaVA, Qwen-VL, Pixtral 등)

오늘은 텍스트 기반 LLM인 Qwen3.5를 다루므로 `mlx-lm`을 설치하겠습니다. 빠른 설치를 위해 앞서 구성한 `uv`를 활용합니다.

```bash
# MLX 언어모델 전용 패키지 설치
uv pip install mlx-lm
```

---

## 4. Qwen3.5 9B 모델 기준 로컬 환경 구성 및 Chat 활용

Qwen3.5 9B 모델은 뛰어난 한국어 이해력과 가벼운 사이즈 대비 높은 벤치마크 점수로 로컬 추론에 매우 적합합니다. Hugging Face에 업로드된 MLX용 양자화(Quantized) 모델을 다운받아 실행하는 방식을 사용합니다.

### 1) 터미널 기반 로컬 Chat 환경 구동
`mlx-lm`에는 터미널에서 바로 모델과 대화할 수 있는 챗봇 스크립트가 내장되어 있습니다. `Qwen3.5-9B-Instruct`의 MLX 4-bit 양자화 모델을 실행해 보겠습니다.

```bash
# 첫 실행 시 Hugging Face 모델(약 5~6GB)을 자동으로 다운로드합니다.
python -m mlx_lm.chat --model mlx-community/Qwen3.5-9B-Instruct-4bit
```
실행이 완료되면 아래와 같이 `Prompt:` 입력창이 뜨며 즉시 대화를 시작할 수 있습니다.

```text
Prompt: 안녕하세요! 당신은 누구인가요?
Qwen: 안녕하세요! 저는 Qwen입니다. 무엇을 도와드릴까요?
```

### 2) API 서버 모드로 실행하기 (OpenAI API 호환)
Python 애플리케이션이나 다른 프론트엔드 UI(Chatbox, LibreChat 등)와 연동하고 싶다면, 모델을 백그라운드 서버로 띄울 수 있습니다. `mlx-lm`은 OpenAI 호환 API 서버 기능을 기본 지원합니다.

```bash
# 서버 구동 (기본 포트 8080)
python -m mlx_lm.server --model mlx-community/Qwen3.5-9B-Instruct-4bit
```

> **`--model` 옵션이 필수인 이유**  
> `mlx_lm.server`는 데몬 형태로 여러 모델을 관리하는 Ollama와 달리, **서버를 띄울 때 단 하나의 특정 모델을 메모리에 올려 서빙하는 구조**입니다. 따라서 `--model` 옵션을 통해 대상 모델(Hugging Face 레포지토리 주소 또는 로컬 경로)을 명시하지 않으면 구동 시 오류가 발생합니다.

위 명령어 입력 시 로컬 웹서버가 구동되며, OpenAI API 형식과 호환되므로 `curl` 명령어나 Python 코드에서 손쉽게 호출할 수 있습니다.

#### 터미널에서 curl로 접속하기
```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
     "messages": [{"role": "user", "content": "MLX 환경의 장점을 세 줄로 요약해줘."}],
     "temperature": 0.7
   }'
```

#### Python 코드로 접속하기 (`openai` 라이브러리 활용)
서버가 OpenAI API 스펙을 따르기 때문에, 파이썬 스크립트에서도 기존 `openai` 라이브러리를 그대로 사용해 접속할 수 있습니다.
먼저 `uv`를 이용해 패키지를 설치합니다.
```bash
uv pip install openai
```

그리고 아래와 같은 파이썬 스크립트(`client.py`)를 작성하여 실행합니다.
```python
from openai import OpenAI

# 클라이언트 생성. base_url을 로컬 mlx 서버 주소로 변경하고 api_key는 임의의 문자열을 넣습니다.
client = OpenAI(
    base_url="http://localhost:8080/v1/",
    api_key="not-needed" 
)

response = client.chat.completions.create(
    model="mlx-community/Qwen3.5-9B-Instruct-4bit", # 서버가 구동 중인 모델명
    messages=[
        {"role": "user", "content": "MLX 환경의 장점을 세 줄로 요약해줘."}
    ],
    temperature=0.7,
)

print(response.choices[0].message.content)
```

이와 같이 구성하면 Ollama 못지않은 API 서빙 환경을, **Apple Silicon에 최적화된 극한의 퍼포먼스**로 운영할 수 있습니다.

---

## 마무리
지금까지 macOS 환경에서 MLX가 갖는 강점을 Ollama와 비교해 보고, Qwen3.5 9B 모델을 활용하여 나만의 고성능 로컬 AI 환경을 구축하는 방법을 확인했습니다. Python 환경과 명령어에 조금만 익숙해진다면, MLX를 통해 M칩이 가진 잠재력을 100% 활용할 수 있을 것입니다.
