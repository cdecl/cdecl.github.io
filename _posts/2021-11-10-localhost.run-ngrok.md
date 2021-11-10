---
title: localhost.run, ngrok

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

로컬(localhost) 서비스를 터널을 통해 외부에 노출 시켜주는 도구 

{% raw %}


## localhost.run
- <https://localhost.run/>{:target="_blank"}
- `ssh` reverse 터널을 통해 로컬 서비스를 노출 
- 별도의 툴 설치가 필요 없으면 ssh 명령어를 통해 설정


### 실행 

##### 서비스 실행 

```sh
$ docker run -d -p 8000:80 cdecl/mvcapp
829885fb866f5820e50265c6d9433dcd7366be05beb56f177a40065eeb6b1cf6

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

##### 터널링 
- `ssh -R 서비스포트:로컬주소:로컬포트 localhost.run`
  - 서비스포트 : `80` / `443`

```sh
# ssh reverse 모드로 실행 
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

```sh
# 실행 
$ https://6d2ca825416732.lhr.domains/

    * Project           : mvcapp
    * Version           : 0.6 / net5.0
    * Hostname          : 829885fb866f
    * Sleep(sync)       : 0
    * RemoteAddr        : 172.17.0.1
    * X-Forwarded-For   : 1.227.62.113
    * Request Count     : 4
    * User-Agent        : curl/7.64.1
```


## Ngrok
- <https://ngrok.com/>{:target="_blank"}
- `http`, `https` 를 지원하는 터널링 도구 


### 실행 

##### 설치 
- <https://ngrok.com/download>{:target="_blank"}  
  - `platform` 에 맞는 바이너리 다운로드 
  - `brew`, `choco` 등 패키지 매니저 지원 

##### 터널링 
- Session Expires 시간이 기본 2시간 
  - 해당 제한을 없애기 위해서는 로그인 후 `token` 생성 및 등록  
  - `ngrok authtoken <your_auth_token>`
- Request를 확인할 수 있는 Web I/F 제공 
  - `Web Interface                 http://127.0.0.1:4040`

```sh
$ ngrok http 8000
ngrok by @inconshreveable                                                                                           (Ctrl+C to quit)

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

{% endraw %}
