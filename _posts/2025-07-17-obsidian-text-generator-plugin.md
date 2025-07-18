---
title: Obsidian Text Generator 플러그인 가이드 (selected_text, context)
toc: true
toc_sticky: true

categories:
  - devops 

tags:
  - obsidian
  - text-generator
  - ai
  - gemini
  - productivity
  - markdown
  - selected_text
  - context
---

이 글에서는 Obsidian Text Generator 플러그인의 개념부터 기능, 설정 방법, 명령어, 예약어 사용법, 그리고 유용한 추가 기능까지 상세히 알아보겠습니다.

{% raw %}

### 1. Obsidian Text Generator 플러그인이란?
Obsidian Text Generator 플러그인은 Obsidian에서 AI를 활용해 텍스트를 생성하는 강력한 도구입니다. 노트 작성, 아이디어 생성, 콘텐츠 요약 등 다양한 작업을 자동화하여 생산성을 높여줍니다. 이 플러그인은 사용자가 선택한 텍스트나 노트의 컨텍스트를 기반으로 AI 모델을 통해 문장을 완성하거나 새로운 콘텐츠를 생성합니다.

**주요 특징**:
* **다양한 AI 지원**: OpenAI(GPT-3, GPT-4), Google Gemini, Anthropic Claude, 그리고 LM Studio와 같은 로컬 모델을 지원합니다.[](https://www.obsidianstats.com/plugins/obsidian-textgenerator-plugin)
* **템플릿 엔진**: 반복 작업을 간소화하는 사용자 정의 템플릿을 제공합니다.
* **컨텍스트 인식**: 현재 노트, 선택한 텍스트, 링크된 노트를 활용해 문맥에 맞는 텍스트를 생성합니다.
* **커뮤니티 템플릿**: 다른 사용자의 템플릿을 공유하거나 가져와 다양한 활용 사례를 탐색할 수 있습니다.[](https://github.com/nhaouari/obsidian-textgenerator-plugin)
* **유연한 설정**: Frontmatter를 통해 AI 모델, 토큰 수, 온도 등을 세부적으로 조정 가능합니다.

### 2. 설치 및 Gemini 기반 설정

Text Generator 플러그인은 Obsidian의 커뮤니티 플러그인 마켓에서 설치할 수 있습니다. Google Gemini를 사용한 설정 예시는 다음과 같습니다.

**설치**
1. Obsidian에서 `설정(Settings)` > `커뮤니티 플러그인(Community Plugins)`으로 이동.
2. `Text Generator` 플러그인을 검색 후 설치 및 활성화.
3. Google Gemini API 키를 획득:
   - [Google AI Studio](https://ai.google.dev/gemini-api)에서 Google 계정으로 로그인.
   - "Get API Key"를 클릭해 API 키를 생성하고 복사.
4. 플러그인 설정에서 `LLM Provider`를 `Google Gemini`로 선택하고 API 키를 입력.

**Gemini 설정 예시**
```yaml
---
model: gemini-1.5-flash
max_tokens: 200
temperature: 0.7
---
```
- **설명**:
  - `model`: 사용할 Gemini 모델(예: `gemini-1.5-flash`, `gemini-1.5-pro`)을 지정.
  - `max_tokens`: 생성할 텍스트의 최대 길이.
  - `temperature`: 텍스트의 창의성 정도(0.0~1.0, 낮을수록 보수적).

### 3. 주요 명령어(Commands)와 기능

Text Generator 플러그인은 커맨드 팔레트(Ctrl/Cmd + P)를 통해 다양한 명령어를 제공합니다. 주요 명령어와 기능은 다음과 같습니다.

*   **Generate Text (단축키: `Cmd+J`)**: 선택한 텍스트나 현재 노트의 컨텍스트를 기반으로 AI가 텍스트를 생성합니다. 가장 기본적인 텍스트 생성 명령어입니다.
*   **Generate Text with Prompt**: 사용자 정의 프롬프트를 입력하여 텍스트를 생성합니다. 특정 형식이나 스타일로 결과를 얻고 싶을 때 유용합니다.
*   **Create Template**: 현재 노트의 내용을 기반으로 새로운 Text Generator 템플릿을 생성합니다. 반복적인 작업을 자동화할 때 편리합니다.
*   **Run Template**: 저장된 템플릿을 실행하여 텍스트를 생성합니다.
*   **Search/Generate (Community Prompts)**: 커뮤니티에서 공유된 프롬프트를 검색하고 실행합니다. 다른 사용자의 아이디어를 활용할 수 있습니다.
*   **Increase/Decrease Temperature**: AI 모델의 창의성(무작위성)을 조절합니다. `Temperature` 값이 높을수록 더 창의적이고 예측 불가능한 결과가 나옵니다.
*   **Increase/Decrease max_tokens**: 생성될 텍스트의 최대 길이를 조절합니다. 더 길거나 짧은 결과물이 필요할 때 사용합니다.
*   **Estimate Tokens**: 현재 노트나 선택한 텍스트의 토큰 수를 예측합니다. API 비용을 관리하거나 모델의 입력 제한을 확인할 때 유용합니다.
*   **Consider Note's Frontmatter for Generation**: 파일의 Frontmatter(머리말)에 정의된 설정을 텍스트 생성 시 반영할지 여부를 토글합니다.
*   **Auto-Suggest**: 문장을 입력하는 동안 자동으로 다음 내용을 제안합니다. (실험적 기능)
*   **Stop Generation**: 현재 진행 중인 텍스트 생성을 중단합니다.
*   **Get Models**: 사용 가능한 AI 모델 목록을 가져옵니다.

### 4. Generate Text 예약어: `{{selected_text}}`와 `{{context}}`

Text Generator 플러그인에서 `{{selected_text}}`와 `{{context}}`는 프롬프트에서 사용하는 핵심 예약어입니다.

#### `{{selected_text}}`
- **의미**: 사용자가 노트에서 선택한 텍스트를 입력으로 사용.
- **힌트(프롬프트)**: 명확한 작업 지시와 함께 사용(예: "50자 이내로 완성", "유머러스한 톤으로 확장").
- **영향도**: 선택한 텍스트에 직접적으로 초점을 맞춰 결과를 생성. 텍스트가 없으면 빈 결과나 오류 발생 가능.
- **사용 예**:
  ```markdown
  {{selected_text}}를 3문장으로 확장하세요.
  ```
  - **입력**: "아이디어 회의" 선택.
  - **출력**: "아이디어 회의는 팀의 창의력을 끌어내는 중요한 시간이다. 다양한 관점이 공유되며 새로운 해결책이 도출된다. 이를 통해 프로젝트의 방향성이 명확해진다."

#### `{{context}}`
- **의미**: 현재 노트, 링크된 노트, 또는 설정된 컨텍스트(예: Frontmatter, 태그)를 참조.
- **힌트(프롬프트)**: 노트 전체를 기반으로 요약, 확장, 분석 등을 요청.
- **영향도**: 전체 문서를 기본으로 참조하며, 설정에 따라 링크된 노트나 특정 섹션 포함 가능. 토큰 제한으로 긴 노트는 일부만 처리될 수 있음.
- **사용 예**:
  ```markdown
  {{context}}를 기반으로 다음 문장을 이어가세요: {{selected_text}}
  ```
  - **입력**: 노트에 "프로젝트 계획: 1단계 완료"가 있고, 선택한 텍스트는 "2단계는".
  - **출력**: "2단계는 데이터 분석과 프로토타입 개발에 초점을 맞춘다."

**컨텍스트 미지정 시**: `{{context}}`를 프롬프트에 포함하지 않으면 선택한 텍스트나 직접 입력만 사용되며, 전체 문서는 참조되지 않습니다. 포함 시 기본적으로 현재 노트 전체를 참조합니다.[](https://www.toolify.ai/ai-news/unlocking-the-power-of-ai-in-obsidian-with-the-text-generator-plugin-2834232)

### 5. 추가적인 유용한 기능

Text Generator 플러그인은 다양한 생산성 향상 기능을 제공합니다:
* **커뮤니티 템플릿**: 다른 사용자의 템플릿을 가져오거나 공유하여 새로운 활용 사례를 탐색. 예: 블로그 작성, 코드 스니펫 생성 템플릿.[](https://github.com/nhaouari/obsidian-textgenerator-plugin)
* **Smart Templates**: EJS 문법을 사용해 동적 템플릿을 생성, 변수와 조건문으로 복잡한 콘텐츠 생성 가능.[](https://www.obsidianstats.com/plugins/smart-templates)
* **로컬 모델 지원**: LM Studio, Ollama를 통해 오프라인에서도 AI 사용 가능, API 비용 절감.
* **자동 제안(Auto-Suggest)**: 문장 끝에서 자동으로 후속 문장을 제안, Copilot과 유사한 경험 제공.
* **멀티모달 지원**: Gemini를 통해 텍스트 외에 이미지 분석이나 멀티모달 입력 처리 가능(실험적).[](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/inference)
* **QuickAdd 연동**: QuickAdd 플러그인과 함께 매크로를 설정해 반복 작업 자동화. 예: 특정 노트에서 요약 생성 후 새 노트에 저장.

### 마치며
Obsidian Text Generator 플러그인은 AI를 활용해 노트 작성과 지식 관리를 혁신적으로 개선합니다. Gemini와 같은 강력한 AI 모델과 유연한 템플릿, 컨텍스트 인식 기능을 통해 글쓰기, 아이디어 생성, 요약 등 다양한 작업을 효율적으로 처리할 수 있습니다. 이 플러그인을 활용하여 여러분의 Obsidian 워크플로우를 한 단계 업그레이드해보세요!

{% endraw %}