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
205a3b3ef0f4f2060930f597b966da31201aeee918f87badea450281aa840171

$ curl localhost:8000

    * Project           : mvcapp
    * Version           : 0.6 / net5.0
    * Hostname          : 205a3b3ef0f4
    * Sleep(sync)       : 0
    * RemoteAddr        : 10.1.0.1
    * X-Forwarded-For   :
    * Request Count     : 1
    * User-Agent        : curl/7.29.0
```

##### 터널링 

```sh
$ ssh -R 80:localhost:8000 localhost.run

```


{% endraw %}
