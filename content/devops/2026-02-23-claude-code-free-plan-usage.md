---
title: "Claude Code 무료 플랜 활용 가이드 (Ollama, free-claude-code)"
tags:
  - claude
  - claude-code
  - ollama
  - openrouter
  - nvidia-nim
  - lm-studio
  - ai-agent
  - devops
---

Claude Code를 쓰고 싶은데 유료 API 비용이 부담될 때, 실무에서는 보통 두 가지 경로를 사용합니다.

1. `Ollama` 기반 로컬 모델 연결
2. `free-claude-code` 같은 호환 레이어를 통해 `NVIDIA NIM`, `OpenRouter`, `LM Studio` 백엔드 연결

이 글은 각 방식의 배경, 설치/설정 방법, 그리고 운영 시 주의점을 정리합니다.

## 왜 "무료 플랜" 구성이 필요한가

- 코드 에이전트는 반복 호출이 많아 토큰 비용이 빠르게 증가합니다.
- 개인 프로젝트나 학습 단계에서는 응답 품질보다 비용 상한이 더 중요할 수 있습니다.
- 팀 환경에서는 "무조건 최신 고가 모델"보다 "저비용 + 재현 가능한 워크플로"가 더 실용적입니다.

핵심은, Claude Code UX를 유지하면서 백엔드를 교체하는 것입니다.

### 방법 1) Ollama 이용

#### 개념

Ollama는 로컬에서 오픈 모델을 구동하는 런타임입니다.  
즉, Anthropic의 Claude 모델을 직접 무료로 쓰는 방식이 아니라, Claude Code와 유사한 개발 플로우를 로컬 LLM으로 대체하는 접근입니다.

#### 준비

- 충분한 로컬 리소스(메모리/VRAM)
- Ollama 설치
- 코드 작업에 맞는 모델 선택 (`qwen`, `llama`, `deepseek-coder` 계열 등)

#### 설치

```bash
# macOS (Homebrew)
brew install ollama

# Linux는 공식 설치 스크립트 또는 패키지 매니저로 설치
```

#### 가장 쉬운 연동 (공식)

```bash
ollama launch claude
```

위 명령은 Claude Code 연동에 필요한 설정 과정을 대화형으로 진행합니다.

#### 수동 환경 설정 예시

```bash
# .bashrc or.zshrc 파일에 등록, 수동 등록 
export ANTHROPIC_BASE_URL=http://localhost:11434
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_MODEL=qwen3-coder
```

실행 예시:

```bash
claude --model "$ANTHROPIC_MODEL"
```

#### 모델 선택 팁

- 코드 작업에서는 tool-use 성능과 긴 컨텍스트(예: 64K 이상)를 우선 확인
- 작은 모델은 저비용/저지연에 유리하지만, 복잡한 리팩터링 정확도는 낮아질 수 있음
- 팀 표준 모델 1개 + 빠른 보조 모델 1개로 운영하면 품질/비용 균형을 잡기 쉽습니다

#### Ollama의 Claude 지원 요약

Ollama v0.14.0 이상은 Anthropic Messages API를 구현해 Claude Code와 다른 Anthropic 클라이언트가 로컬 Ollama 모델을 그대로 사용할 수 있도록 합니다. 이 통합으로 스트리밍, 시스템 프롬프트, 툴 콜링, 확장된 `thinking` 토큰, 멀티모달 입력, 서브에이전트 오케스트레이션 등이 Claude 환경과 동일하게 작동하며, 기본 엔드포인트(`http://localhost:11434`)를 통해 Anthropic SDK와의 호환성도 유지됩니다. `ollama launch claude` 명령은 이 환경 변수/모델 설정을 자동으로 구성하는 단계를 감쌉니다.

#### `cloud` 태그 모델 사용법

Ollama의 cloud 모델은 로컬 GPU가 부족해도 큰 모델을 사용할 수 있는 방식입니다.

1. Ollama 계정 로그인

```bash
ollama signin
```

2. Claude Code에서 cloud 모델 지정 실행

```bash
claude --model glm-4.7:cloud
```

3. 필요 시 `ollama launch`에서 cloud 모델 직접 지정

```bash
ollama launch claude --model glm-4.7:cloud
```

메모:

- cloud 모델은 보통 로컬 `pull` 없이 바로 사용 가능합니다.
- 모델명 suffix는 모델마다 다를 수 있으므로 (`:cloud`, `-cloud`), `https://ollama.com/search?c=cloud`에서 실제 이름을 확인하세요.

#### 장단점

- 장점: 완전 로컬, 비용 예측 용이, 개인정보 통제에 유리
- 단점: 모델 품질/툴콜 안정성 편차, 로컬 머신 자원 소모

### 방법 2) free-claude-code 이용 (NVIDIA NIM / OpenRouter / LM Studio)

#### 개념

`free-claude-code` 류 도구는 "Claude Code가 기대하는 인터페이스"와 "다른 LLM 제공자 API" 사이를 중계하는 래퍼입니다.

- Claude Code 클라이언트는 기존처럼 사용
- 실제 모델 추론은 NIM/OpenRouter/LM Studio로 전달

#### 설치

- Claude Code 설정에 필요한 `free-claude-code` 캐시를 로컬에 clone
- `.env.example`를 `.env`로 복사해 기본 변수들을 채운 뒤 `uv`/`pip` 의존성을 설치
- backend(providers)별 API 키/엔드포인트를 `.env`에 기록

```bash
git clone https://github.com/Alishahryar1/free-claude-code.git
cd free-claude-code
cp .env.example .env
# fill ANTHROPIC_BASE_URL, API keys, MODEL overrides in .env
pip install --upgrade pip
pip install -r requirements.txt
```

#### 공통 설정 흐름

1. 초기 설정: `free-claude-code setup`
2. 서버 실행: `free-claude-code` (기본 `http://localhost:8082`)
3. Claude Code가 로컬 프록시를 보도록 환경변수 지정

```bash
export ANTHROPIC_AUTH_TOKEN=freecc
export ANTHROPIC_BASE_URL=http://localhost:8082
```

모델을 즉시 지정하려면:

```bash
export ANTHROPIC_AUTH_TOKEN=freecc:open_router/openai/gpt-4o-mini
```

참고: 토큰 뒤에 `:0.3`처럼 temperature를 붙여서 실행 시점 제어도 가능합니다.

#### Provider별 환경변수 예시

각 공급자별로 필요한 기본 환경변수를 아래처럼 설정해두면, `free-claude-code` 프록시가 해당 API로 요청을 포워딩합니다.

#### OpenRouter

```bash
export MODEL=open_router/openai/gpt-4o-mini
export OPENROUTER_API_KEY=<your_key>
```

OpenRouter를 쓰려면 위처럼 `MODEL` 접두사를 `open_router/`로 두고, 오픈라우터 API 키를 함께 전달하면 됩니다.

#### Quick start 체크리스트 (README 기준)

1. 레포를 클론하고 `.env.example`을 `.env`로 복사한 다음 환경에 맞게 값들을 채우고 요구되는 `pip`/`uv` 의존성을 설치합니다.
2. `ANTHROPIC_BASE_URL`을 `http://localhost:8082`로, `ANTHROPIC_AUTH_TOKEN`을 `freecc`로 설정한 뒤 `:provider/model`을 추가해 특정 모델로 고정합니다.
3. `uv run uvicorn server:app --host 0.0.0.0 --port 8082`로 프록시 서버를 띄웁니다.
4. 같은 환경변수로 `claude` 또는 VSCode 확장판을 실행해 Claude Code를 기동합니다.
5. `claude-pick` 별칭을 이용해 `.env`를 바꾸지 않고도 제공자/모델 조합을 탐색합니다.

이 체크리스트는 README의 Clone & Configure 섹션 내용을 옮긴 것으로, 각 명령을 순서대로 실행해 설정을 끝내면 Claude Code가 로컬 `free-claude-code` 프록시를 통해 Anthropic 호환 모델을 이용합니다.

#### NVIDIA NIM (recommended — 40 req/min free)

```bash
export MODEL=nvidia_nim/stepfun-ai/step-3.5-flash
export NVIDIA_NIM_API_KEY=nvapi-your-key-here
export NIM_BASE_URL=https://api.stepfun.ai
```

NVIDIA NIM은 `nvidia_nim/` 접두사를 쓰고, `NIM_BASE_URL`로 엔드포인트를 설정하면 정해진 요청 속도로 무료 금액을 사용할 수 있습니다.

#### LM Studio

```bash
export MODEL=lmstudio/qwen2.5-coder:14b
export LM_STUDIO_BASE_URL=http://127.0.0.1:1234/v1
```

LM Studio를 백엔드로 쓰려면 `lmstudio/` 접두사와 로컬 서버 주소를 지정하고, 필요한 경우 프록시에서 API 키를 점검하세요.

#### free-claude-code 기능

- `uvicorn server:app` 프록시를 통해 트래픽을 중개하며 Claude 특화 "사소한 요청"을 걸러내고 `reasoning_content`/`` thinking 태그를 Claude Code에 맞게 다시 포맷합니다.
- `MODEL={prefix}/{provider model}` 형식으로 모델 전환을 강제하고, 접두사 오류는 프로바이더 호출 전에 검증 에러로 잡힙니다.
- 리포에는 Discord/Telegram 봇, 음성 노트 업로드 처리, 프록시의 동시성 제한 같은 헬퍼가 포함되어 있어 레이트 리밋을 관리할 수 있습니다.

실행 예시:

```bash
# 서버 실행
free-claude-code
```

연결 테스트:

```bash
curl -s http://localhost:8082/health
```

#### Claude Code 쪽 적용 포인트

- `ANTHROPIC_BASE_URL`을 `http://localhost:8082`로 지정
- `ANTHROPIC_AUTH_TOKEN=freecc[:model]` 패턴으로 모델 라우팅
- 스트리밍 모드 사용 시 timeout 값을 늘려 긴 코드 생성 중 끊김을 방지
- `.env` 또는 셸 프로파일에 설정값을 저장하고, 팀 내 표준 이름을 통일

예시(`.env`):

```dotenv
ANTHROPIC_BASE_URL=http://localhost:8082
ANTHROPIC_AUTH_TOKEN=freecc:open_router/openai/gpt-4o-mini
MODEL=open_router/openai/gpt-4o-mini
OPENROUTER_API_KEY=...
```

## 참고 문서

- `free-claude-code` README: https://github.com/Alishahryar1/free-claude-code?tab=readme-ov-file
- Ollama Claude Code integration: https://docs.ollama.com/integrations/claude-code
- Ollama docs: https://ollama.com/docs
- Claude Code CLI: https://www.anthropic.com/claude/docs/claude-code

## 운영 팁

- OpenRouter는 모델별 단가/지연이 다르므로 작업 유형(리팩터링/테스트 생성/문서화)별 모델을 분리하면 비용을 줄일 수 있습니다.
- NIM은 기업 환경에서 성능/보안 정책을 맞추기 쉽습니다.
- LM Studio는 완전 로컬 테스트에 좋지만 대형 코드베이스 작업에서는 모델 크기와 컨텍스트 한계를 먼저 확인해야 합니다.

## 무엇을 선택할까

- 개인 로컬 실험: `Ollama` 또는 `LM Studio`
- 다양한 상용/오픈 모델 빠른 비교: `OpenRouter`
- 팀/기업 정책 중심 운영: `NVIDIA NIM`

결론적으로, "Claude Code 무료 플랜"은 공식 무료 Claude 자체를 의미하기보다, Claude Code 사용 경험을 유지한 채 백엔드를 비용 효율적으로 대체하는 아키텍처 전략에 가깝습니다.

## 트러블슈팅

- `401/403` 오류: API 키 누락, provider 불일치, 잘못된 권한 스코프 확인
- `404 model not found`: `MODEL` 접두사(`open_router/`, `nvidia_nim/`, `lmstudio/`) 오타 확인
- `connection refused`: 로컬 서버(Ollama/LM Studio/래퍼) 미실행 또는 포트 오타
- `claude`에서 모델 선택이 꼬일 때: `claude-pick` 별칭으로 모델 재선택 후 재시도
- 응답 지연/타임아웃: 모델 크기 축소, 컨텍스트 길이 조정, timeout 상향

## 주의사항

- 각 서비스의 이용약관/요금/레이트리밋은 수시로 바뀌므로 배포 전 최신 문서를 다시 확인하세요.
- 코드/비밀값이 외부 API로 전송될 수 있으므로, 저장소 필터링(`.env`, 키, 고객 데이터) 정책을 먼저 적용하세요.
- 팀 공용 환경에서는 "허용 모델 목록 + 최대 토큰 + 일일 예산"을 강제하는 가드레일을 두는 것이 안전합니다.
