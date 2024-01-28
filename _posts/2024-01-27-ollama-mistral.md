---
title: ollama, ollama-webui, mistral  

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - ollama
  - mistral
  - llm
---
 
ollama, ollama-webui, mistral 설치 및 테스트 

{% raw %}

## Ollama 

> OLLAMA는 Open Large Language Model for AI Applications의 약자로, Google AI에서 개발한 대규모 언어 모델 (LLM)입니다. 
> OLLAMA는 텍스트 생성, 번역, 질문 응답 등 다양한 AI 애플리케이션 개발을 위해 사용할 수 있는 강력한 도구

- 다양한 기능: OLLAMA는 텍스트 생성, 번역, 질문 응답, 요약, 코드 생성 등 다양한 기능을 제공합니다.
- 강력한 성능: OLLAMA는 Google AI의 최첨단 기술을 기반으로 개발되어 강력한 성능을 제공합니다.
- 쉬운 사용: OLLAMA는 Python API를 제공하여 쉽게 사용할 수 있습니다.
- 다양한 모델: OLLAMA는 다양한 크기와 기능을 가진 모델을 제공하여 사용자의 필요에 맞게 선택할 수 있습니다.

### Ollama 설치 
- 다운로드 : <https://ollama.ai/download>{:target="_blank"}
- 설치 및 활용 가능한 모델 : <https://ollama.ai/library>{:target="_blank"}

```sh
$ ollama
Usage:
  ollama [flags]
  ollama [command]

Available Commands:
  serve       Start ollama
  create      Create a model from a Modelfile
  show        Show information for a model
  run         Run a model
  pull        Pull a model from a registry
  push        Push a model to a registry
  list        List models
  cp          Copy a model
  rm          Remove a model
  help        Help about any command

Flags:
  -h, --help      help for ollama
  -v, --version   Show version information

Use "ollama [command] --help" for more information about a command.
```

### mistral 모델 설치
- <https://ollama.ai/library/mistral>{:target="_blank"}


> Mistral은 최근에 개발된 대형 언어 모델 중 하나입니다. 
이 모델은 7.3 billion 개의 파라미터를 가지고 있으며, 자연어 처리 분야에서 매우 높은 성능을 보입니다. 
Mistral은 다양한 자연어 처리 작업에서 사용될 수 있습니다. 
예를 들어, 이 모델은 텍스트 생성, 기계 번역, 질문 응답, 감성 분석 등의 작업에 사용될 수 있습니다.


#### ollama CLI 툴을 통해 다운로드 및 실행  

```sh
$ ollama pull mistral
pulling manifest
pulling e8a35b5937a5... 100% ▕████████████████████████████████████████████████████████████████████████████▏ 4.1 GB
pulling 43070e2d4e53... 100% ▕████████████████████████████████████████████████████████████████████████████▏  11 KB
pulling e6836092461f... 100% ▕████████████████████████████████████████████████████████████████████████████▏   42 B
pulling ed11eda7790d... 100% ▕████████████████████████████████████████████████████████████████████████████▏   30 B
pulling f9b1e3196ecf... 100% ▕████████████████████████████████████████████████████████████████████████████▏  483 B
verifying sha256 digest
writing manifest
removing any unused layers
success

$ ollama list
NAME          	ID          	SIZE  	MODIFIED
mistral:latest	61e88e884507	4.1 GB	11 minutes ago

# 로컬 API 실행 확인 
$ curl http://localhost:11434
Ollama is running%
```

#### 실행(`run`) 및 CLI 질의 테스트
 
> !! 로컬 랩탑에서 질의하면 아주 느리게 실행 됨

```sh 
$ ollama run mistral
>>> github 에 대해서 한글로 간단히 설명해줘
 GitHub (깃허브)는 소스코드를 저장하고 공유할 수 있는 온라인 플atform입니다. 개발자들이 프로젝트를 만들어서 원활한 협업을 위해 사용됩니다. GitHub에서는 소스코드를 저장하고, 버전 관리, 코드 검토, �erkdown 문서
작성 등 다양한 기능을 제공합니다.

GitHub Repository (깃허브 레포지토리)는 GitHub에서 생성되어 저장되는 프로젝트입니다. 개발자들은 GitHub Repository에 원본 소스코드를 업로드하여 다른 개발자들과 공유할 수 있습니다. 이를 통해 협력하면
소스코드의 변경 사항을 추적하고, Merge Requests(병합 요청)으로 코드 리뷰와 코드 통합을 수행할 수 있습니다.

GitHub에서는 Open Source Project (오픈소스 프로젝트)도 많이 존재하며, 이를 통해 개발자들은 다른 개발자의 코드를 참고하고, 협력하며, 공부할 수 있습니다.

GitHub는 Git을 사용하여 소스코드를 버전 관리합니다. Git은 분산형 Source Control System(분산형 소스코드 제어 시스템)입니다. 이렇게 되면, 개발자들은 원격 저장소에서 최신 상태의 소스코드를  clone(복사)하여
로컬에서 작업할 수 있으며, 필요한 경우 Git Commands(git 명령어)를 이용해 소스코드를 push(전송)하거나 pull(받기)하여 GitHub Repository와 동기화할 수 있습니다.

이러한 기능들로 GitHub는 개발자들에게 협업, 소스코드 관리, 코드 검토, Open Source Project 참여 등을 용이하게 만들어줍니다.

I hope this explanation in Korean helps clarify what GitHub is! Let me know if you have any questions or need further clarification on
anything. :)
```

#### WEB API를 통한 실행 테스트
- `http://localhost:11434`
  
```sh
$$ curl -X POST http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt":"Here is a story about llamas eating grass"
 }'

{"model":"mistral","created_at":"2024-01-28T06:09:43.443079Z","response":" Title","done":false}
{"model":"mistral","created_at":"2024-01-28T06:09:43.539221Z","response":":","done":false}
{"model":"mistral","created_at":"2024-01-28T06:09:43.645788Z","response":" The","done":false}
{"model":"mistral","created_at":"2024-01-28T06:09:43.749525Z","response":" L","done":false}
{"model":"mistral","created_at":"2024-01-28T06:09:43.840547Z","response":"lam","done":false}
 ...
 ```

---

### ollama-webui 
- <https://github.com/ollama-webui/ollama-webui>{:target="_blank"}

> ChatGPT-Style Web UI Client for Ollama 🦙

#### docker-compose 실행 

```sh
$ git clone https://github.com/ollama-webui/ollama-webu
$ cd ollama-webui

$ docker-compose up -d
[+] Running 4/4
 ✔ ollama 3 layers [⣿⣿⣿]      0B/0B      Pulled  38.3s
   ✔ ce9ebea987c2 Pull complete                                               6.6s
   ✔ 659507d470de Pull complete                                               8.3s
   ✔ cbd982cdf9cb Pull complete                                              28.6s
[+] Running 3/3
 ✔ Network ollama-webui_default  Created                                      0.0s
 ✔ Container ollama              Started                                      0.1s
 ✔ Container ollama-webui        Started                                      0.0s
```

- ollama와 ollama-webui를 docker로 실행 
  - 서비스 포트 확인 : 3000

```yaml
version: '3.8'

services:
  ollama:
    volumes:
      - ollama:/root/.ollama
    container_name: ollama
    pull_policy: always
    tty: true
    restart: unless-stopped
    image: ollama/ollama:latest

  ollama-webui:
    build:
      context: .
      args:
        OLLAMA_API_BASE_URL: '/ollama/api'
      dockerfile: Dockerfile
    image: ghcr.io/ollama-webui/ollama-webui:main
    container_name: ollama-webui
    volumes:
      - ollama-webui:/app/backend/data
    depends_on:
      - ollama
    ports:
      - ${OLLAMA_WEBUI_PORT-3000}:8080
    environment:
      - 'OLLAMA_API_BASE_URL=http://ollama:11434/api'
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped

volumes:
  ollama: {}
  ollama-webui: {}
```

- Web UI 확인 : `http://localhost:3000/`

![](/images/2024-01-28-15-25-15.png)

{% endraw %}
