---
title: localhost.run과 ngrok - 로컬 서비스의 외부 노출 도구

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - localhost.run
  - ngrok
  - tunnel
  - ssh
  - reverse
---

로컬(localhost) 서비스를 터널링을 통해 외부에서 접근 가능하도록 만들어주는 도구들을 소개합니다.

{% raw %}

> 개발 단계에서 로컬에서 실행 중인 서비스를 외부에 임시로 공개해야 할 때 유용합니다. 
> (보안 및 안정성 문제로 실제 프로덕션 환경에서는 사용하지 않는 것을 권장합니다)

주요 사용 사례:
- 외부 API의 웹훅(webhook) 테스트
- 클라이언트에게 개발 중인 기능 데모
- 모바일 기기에서 로컬 개발 서버 접근
- 협업 시 로컬 개발 환경 공유

## localhost.run
- <https://localhost.run/>{:target="_blank"}
- SSH 리버스 터널링을 활용하여 로컬 서비스를 외부에 노출
- 별도의 프로그램 설치가 필요 없고 SSH 클라이언트만 있으면 사용 가능
- 무료로 사용 가능하며 커스텀 도메인 지원


### 테스트용 서비스 실행 
아래 예제에서는 간단한 웹 애플리케이션 컨테이너를 실행하여 테스트합니다.

```sh
# Docker를 사용하여 테스트용 웹 서버 실행 (8000번 포트)
$ docker run -d -p 8000:80 cdecl/mvcapp
829885fb866f5820e50265c6d9433dcd7366be05beb56f177a40065eeb6b1cf6

# 로컬 접근 테스트
$ curl localhost:8000

    * Project           : mvcapp
    * Version           : 0.6 / net5.0
    * Hostname          : 829885fb866f
    * Sleep(sync)       : 0
    * RemoteAddr        : 172.17.0.1
    * X-Forwarded-For   :
    * Request Count     : 1
    * User-Agent        : curl/7.64.1
```

### 터널링 설정
- 기본 문법: `ssh -R 서비스포트:로컬주소:로컬포트 localhost.run`
- 서비스포트 옵션:
  - `80`: HTTP 프로토콜용
  - `443`: HTTPS 프로토콜용
- 무료 사용자는 임시 서브도메인이 자동 할당됨

```sh
# SSH 리버스 터널 설정 (로컬의 8000번 포트를 외부 80번 포트로 매핑)
$ ssh -R 80:localhost:8000 localhost.run

===============================================================================
Welcome to localhost.run!

Follow your favourite reverse tunnel at [https://twitter.com/localhost_run].

**You need a SSH key to access this service.**
If you get a permission denied follow Gitlab's most excellent howto:
https://docs.gitlab.com/ee/ssh/
*Only rsa and ed25519 keys are supported*

To set up and manage custom domains go to https://admin.localhost.run/

More details on custom domains (and how to enable subdomains of your custom
domain) at https://localhost.run/docs/custom-domains

To explore using localhost.run visit the documentation site:
https://localhost.run/docs/

===============================================================================


** your connection id is c1e917e2-6ed0-4b5f-8b55-e032d229e326, please mention it if you send me a message about an issue. **

6d2ca825416732.lhr.domains tunneled with tls termination, https://6d2ca825416732.lhr.domains
```

### 외부 접근 테스트

```sh
# 할당된 도메인으로 접근 테스트
$ curl https://6d2ca825416732.lhr.domains/

    * Project           : mvcapp
    * Version           : 0.6 / net5.0
    * Hostname          : 829885fb866f
    * Sleep(sync)       : 0
    * RemoteAddr        : 172.17.0.1
    * X-Forwarded-For   : 1.227.62.113
    * Request Count     : 4
    * User-Agent        : curl/7.64.1
```

---

## Ngrok
- <https://ngrok.com/>{:target="_blank"}
- 다양한 프로토콜 지원:
  - HTTP/HTTPS
  - TCP
  - TLS
- 직관적인 UI와 풍부한 기능 제공
- 무료/유료 플랜 제공
  - 무료: 기본 기능과 임시 URL 제공
  - 유료: 고정 도메인, 더 긴 세션 시간, 추가 기능 제공

### 설치 방법
- <https://ngrok.com/download>{:target="_blank"}에서 다운로드
- 설치 옵션:
  1. 직접 바이너리 다운로드
  2. 패키지 매니저를 통한 설치:
     - macOS: `brew install ngrok`
     - Windows: `choco install ngrok`
     - Linux: `snap install ngrok`

### 터널링 설정
주요 특징:
- 실시간 요청 모니터링을 위한 웹 인터페이스 제공 (`http://127.0.0.1:4040`)
- 무료 계정의 세션 제한:
  - 기본 2시간 후 만료
  - 계정 생성 및 토큰 설정으로 제한 해제 가능

```sh
# 인증 토큰 설정 (선택사항)
$ ngrok authtoken <your_auth_token>

# HTTP 터널 생성
$ ngrok http 8000
ngrok by @inconshreveable                                               (Ctrl+C to quit)

Session Status                online
Session Expires               1 hour, 59 minutes
Version                       2.3.40
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://e6fc-1-227-62-113.ngrok.io -> http://localhost:8000
Forwarding                    https://e6fc-1-227-62-113.ngrok.io -> http://localhost:8000

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

### 외부 접근 테스트

```sh
$ curl http://e6fc-1-227-62-113.ngrok.io

    * Project           : mvcapp
    * Version           : 0.6 / net5.0
    * Hostname          : 829885fb866f
    * Sleep(sync)       : 0
    * RemoteAddr        : 172.17.0.1
    * X-Forwarded-For   : 1.227.62.113
    * Request Count     : 5
    * User-Agent        : curl/7.64.1
```

### 추가 팁
- ngrok 무료 버전 제한사항:
  - 세션당 2시간 제한
  - 임시 URL만 사용 가능
  - 동시 연결 수 제한
- 보안 관련 주의사항:
  - 개발 환경에서만 사용
  - 중요한 데이터가 있는 서비스는 노출 주의
  - 가능하면 Basic Auth 등 추가 보안 설정 권장

{% endraw %}
