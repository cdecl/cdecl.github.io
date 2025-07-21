---
title: Obsidian - Smart Connections 플러그인
toc: true
toc_sticky: true

categories:
  - devops 

tags:
  - obsidian
  - smart-connections
  - ai
  - productivity
  - markdown
  - note-taking
  - embeddings
---

이 글에서는 Obsidian Smart Connections 플러그인의 개념부터 기능, 설정 방법, 주요 기능과 예제, 그리고 비슷한 플러그인까지 상세히 알아보겠습니다.

{% raw %}

### 1. Obsidian Smart Connections 플러그인이란?
Smart Connections는 Obsidian에서 AI 임베딩을 활용해 노트 간의 의미적 연결을 찾아주는 강력한 플러그인입니다. 사용자의 노트를 분석하여 관련된 콘텐츠를 실시간으로 추천하거나, 노트를 기반으로 대화형 AI와 상호작용할 수 있게 합니다. 블로그 작성, 연구, 지식 관리 등에서 생산성을 높여주며, 특히 대규모 노트 저장소에서 유용합니다.

**주요 특징**:
* **의미적 검색**: 키워드가 아닌 노트의 의미를 기반으로 관련 노트를 찾아줍니다.
* **로컬 및 클라우드 AI 지원**: Ollama, LM Studio 같은 로컬 모델과 OpenAI, Gemini, Claude 등 100개 이상의 API를 지원합니다.[](https://github.com/brianpetro/obsidian-smart-connections)
* **Smart Chat**: 노트를 기반으로 AI와 대화하며 질문에 답변하거나 콘텐츠를 생성합니다.
* **컨텍스트 인식**: 현재 노트나 선택한 텍스트를 활용해 관련 콘텐츠를 제안합니다.
* **오프라인 지원**: 로컬 임베딩 모델을 사용해 데이터 프라이버시를 보장합니다.[](https://smartconnections.app/)

### 2. 설치 및 설정

Smart Connections 플러그인은 Obsidian의 커뮤니티 플러그인 마켓에서 설치할 수 있습니다. 아래는 기본 설치 및 설정 방법입니다.

**설치**
1. Obsidian에서 `설정(Settings)` > `커뮤니티 플러그인(Community Plugins)`으로 이동.
2. `Smart Connections` 플러그인을 검색 후 설치 및 활성화.
3. 로컬 모델(Ollama 등)을 사용할 경우 별도 설치 없이 즉시 임베딩 생성 시작. 클라우드 모델(OpenAI, Gemini 등)을 사용할 경우:
   - [OpenAI](https://platform.openai.com/api-keys) 또는 [Google AI Studio](https://ai.google.dev/gemini-api)에서 API 키를 획득.
   - 플러그인 설정에서 `LLM Provider`를 선택하고 API 키 입력.
4. 설정에서 제외할 폴더나 파일 지정 가능(민감 정보 보호).[](https://www.reddit.com/r/ObsidianMD/comments/11s0oxb/chat_with_your_notes_now_available_in_the_smart/)

**설정 예시 (OpenAI)**
```yaml
---
model: gpt-3.5-turbo
max_tokens: 500
temperature: 0.8
---
```
- **설명**:
  - `model`: 사용할 AI 모델(예: `gpt-3.5-turbo`, `gemini-1.5-flash`) 지정.
  - `max_tokens`: 생성 텍스트의 최대 길이.
  - `temperature`: 창의성 정도(0.0~1.0, 높을수록 더 창의적).

**비용**:
- **로컬 모델**: 무료, Ollama나 LM Studio 사용 시 추가 비용 없음.
- **클라우드 모델**: OpenAI, Gemini 등 API 사용 시 토큰 기반 과금. 비용은 노트 크기와 사용 빈도에 따라 다름(자세한 가격은 [OpenAI](https://platform.openai.com/pricing) 또는 [Google AI Studio](https://ai.google.dev/pricing) 참조).[](https://learningaloud.com/blog/2024/03/14/obsidian-smart-connections-workflow/)

### 3. 주요 기능과 예제

Smart Connections는 다양한 기능을 제공하며, 커맨드 팔레트(Ctrl/Cmd + P)를 통해 실행 가능합니다. 주요 기능과 사용 예제를 소개합니다.

* **Smart View**
  - **설명**: 현재 노트와 의미적으로 유사한 노트를 실시간으로 표시. 임베딩을 통해 노트 간 관계를 시각화하며, 점수(Score)로 유사도를 나타냄.
  - **예제**:
    - **상황**: "블로그 작성" 노트를 작성 중.
    - **동작**: Smart View 패널에 "콘텐츠 기획", "SEO 전략" 노트가 유사도 점수 0.92, 0.87로 표시.
    - **사용법**: `Open Smart Connections view` 명령어 실행 후 패널에서 관련 노트 클릭.
  - **활용**: 블로그 주제 확장 시 관련 아이디어 발견.[](https://medium.com/%40brickbarnblog/obsidian-ai-plugin-smart-connections-found-some-big-holes-in-my-pkm-22830fa30b2a)

* **Smart Chat**
  - **설명**: 노트를 기반으로 AI와 대화. 특정 노트를 참조하거나 전체 볼트를 검색해 답변 생성.
  - **예제**:
    - **프롬프트**: "내 노트를 기반으로 블로그 포스트 아이디어를 제안해."
    - **입력**: 노트에 "AI와 생산성" 관련 내용 포함.
    - **출력**: "AI 도구를 활용한 워크플로우 최적화에 관한 블로그 포스트를 작성하세요. [[AI와 생산성]] 노트를 참고해 구체적인 사례를 포함할 수 있습니다."
    - **사용법**: `Open Smart Chat` 명령어로 채팅 창 열기.
  - **활용**: 블로그 초안 작성 시 아이디어 브레인스토밍.[](https://forum.obsidian.md/t/introducing-smart-chat-a-game-changer-for-your-obsidian-notes-smart-connections-plugin/56391)

* **Semantic Search**
  - **설명**: 키워드가 아닌 개념 기반 검색. 특정 주제나 질문을 입력하면 관련 노트를 찾아줌.
  - **예제**:
    - **프롬프트**: "블로그 마케팅 전략 관련 노트 찾아줘."
    - **출력**: "[[디지털 마케팅]], [[소셜 미디어 전략]]" 등 관련 노트 목록.
    - **사용법**: `Semantic Search` 명령어로 검색 창 열기.
  - **활용**: 주제별 노트 정리 및 블로그 콘텐츠 기획.[](https://smartconnections.app/story/smart-connections-getting-started/)

* **Context Builder**
  - **설명**: 특정 노트나 블록을 선택해 AI 답변의 컨텍스트로 사용. 프롬프트에 명시적으로 포함 가능.
  - **예제**:
    - **프롬프트**: "[[프로젝트 관리]] 노트를 기반으로 블로그 개요 작성."
    - **출력**: "1. 프로젝트 관리 개요: 정의와 중요성\n2. 효과적인 도구: [[프로젝트 관리]]에서 언급된 Trello, Asana 활용법\n3. 사례 연구..."
    - **사용법**: Smart Chat에서 컨텍스트 트리에서 노트 선택.
  - **활용**: 특정 주제에 초점을 맞춘 블로그 초안 생성.[](https://www.obsidianstats.com/plugins/smart-connections)

* **Multi-modal Support**
  - **설명**: 이미지나 PDF를 컨텍스트로 사용(실험적, Ollama 모델 필요). 블로그에 시각적 자료를 포함할 때 유용.
  - **예제**:
    - **입력**: "이 이미지를 기반으로 블로그 배너 설명 작성."
    - **출력**: "배너는 현대적인 기술 테마로, AI와 노트 연결을 상징하는 푸른 톤의 그래픽 포함."
    - **사용법**: Smart Chat에서 이미지 업로드 후 프롬프트 입력.
  - **활용**: 블로그 시각 자료 설명 생성.[](https://www.obsidianstats.com/plugins/smart-connections)

### 4. 비슷한 플러그인 소개

Smart Connections와 유사한 기능을 제공하는 다른 Obsidian 플러그인을 소개합니다.

* **Obsidian Co-Pilot**
  - **특징**: AI 기반 채팅, 노트 편집, 사용자 정의 프롬프트 지원. OpenAI, Azure, LocalAI 등 다양한 모델과 호환. Smart Connections보다 UI가 세련되고 편집 기능이 강력.[](https://effortlessacademic.com/adding-ai-to-your-obsidian-notes-with-smartconnections-and-copilot/)
  - **비교**:
    - **장점**: 노트 수정 및 커스텀 프롬프트에 특화, Vault Q&A로 볼트 전체 검색 가능.
    - **단점**: 클라우드 모델 사용 시 비용 발생, 로컬 모델 설정이 복잡할 수 있음.
    - **사용 예**: 블로그 초안을 작성한 후 bullet point로 변환하거나, 특정 노트를 요약.
  - **추천 대상**: 편집 및 커스터마이징을 중시하는 사용자.

* **Text Generator**
  - **특징**: 텍스트 생성에 초점, 사용자 정의 템플릿과 컨텍스트 인식 기능 제공. Gemini, Claude 등 지원. Smart Connections보다 텍스트 생성에 특화.[](https://github.com/brianpetro/obsidian-smart-connections)
  - **비교**:
    - **장점**: 템플릿 기반으로 반복 작업 자동화, 멀티모달 지원.
    - **단점**: 의미적 연결 추천은 약함, 주로 텍스트 생성에 초점.
    - **사용 예**: 블로그 포스트 초안을 빠르게 생성하거나 노트 요약.
  - **추천 대상**: 템플릿 기반 콘텐츠 생성을 선호하는 사용자.

* **SystemSculpt**
  - **특징**: 스마트 템플릿, Whisper 음성 입력, 로컬 모델 지원. Smart Connections와 달리 템플릿과 음성 입력에 강점.[](https://www.reddit.com/r/ObsidianMD/comments/1fzmkdk/just_wanted_to_mention_that_the_smart_connections/)
  - **비교**:
    - **장점**: 음성 입력과 템플릿 커스터마이징이 뛰어남, 활발한 개발자 커뮤니티.
    - **단점**: 연결 추천 기능은 Smart Connections보다 약함.
    - **사용 예**: 음성 메모를 블로그 초안으로 변환.
  - **추천 대상**: 멀티모달 입력과 템플릿을 활용하려는 사용자.

### 마치며
Obsidian Smart Connections 플러그인은 AI를 활용해 노트 간 연결을 자동화하고, 블로그 작성 워크플로우를 혁신적으로 개선합니다. Smart View와 Smart Chat을 통해 아이디어를 빠르게 발굴하고, 의미적 검색과 컨텍스트 빌더로 콘텐츠를 체계화할 수 있습니다. 로컬 모델 지원으로 프라이버시를 보장하며, 다양한 AI 모델과의 호환성으로 유연성을 제공합니다.

{% endraw %}