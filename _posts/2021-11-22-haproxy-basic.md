---
title: HAProxy Basic

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - haproxy
  - reverse proxy
  - load balancing 
---

네트워크 `L4`, `L7` 기능 `Reverse proxy` 및 `Load balancing`, `HA` 기능을 제공하는 최적화된 `S/W`

{% raw %}


## HAProxy Basic
공식 블로그인 만큼 가장 잘 정리된 링크로 상세 설명 대체

#### Basic Configuration 
- <https://www.haproxy.com/blog/haproxy-configuration-basics-load-balance-your-servers/>{:target="_blank"}
- 최소 설정 및 기본 항목에 대한 설명 

##### 설치 및 적용 `centos 7`

```sh
# install 
$ sudo yum install haproxy 
# start
$ sudo systemctl start haproxy 
# status
$ sudo systemctl status haproxy
● haproxy.service - HAProxy Load Balancer
   Loaded: loaded (/usr/lib/systemd/system/haproxy.service; disabled; vendor preset: disabled)
   Active: active (running) since 화 2021-11-23 13:55:48 KST; 5s ago
 Main PID: 227598 (haproxy-systemd)
    Tasks: 3
   Memory: 1.9M
   CGroup: /system.slice/haproxy.service
           ├─227598 /usr/sbin/haproxy-systemd-wrapper -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
           ├─227599 /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -Ds
           └─227600 /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -Ds
...
```

##### 버전 확인, 지원 모듈, 지원 polling 시스템 확인 
- `epoll` 사용

```sh
$ haproxy -vv
HA-Proxy version 1.5.18 2016/05/10
Copyright 2000-2016 Willy Tarreau <willy@haproxy.org>

Build options :
  TARGET  = linux2628
  CPU     = generic
  CC      = gcc
  CFLAGS  = -O2 -g -fno-strict-aliasing -DTCP_USER_TIMEOUT=18
  OPTIONS = USE_LINUX_TPROXY=1 USE_GETADDRINFO=1 USE_ZLIB=1 USE_REGPARM=1 USE_OPENSSL=1 USE_PCRE=1

Default settings :
  maxconn = 2000, bufsize = 16384, maxrewrite = 8192, maxpollevents = 200

Encrypted password support via crypt(3): yes
Built with zlib version : 1.2.7
Compression algorithms supported : identity, deflate, gzip
Built with OpenSSL version : OpenSSL 1.0.2k-fips  26 Jan 2017
Running on OpenSSL version : OpenSSL 1.0.2k-fips  26 Jan 2017
OpenSSL library supports TLS extensions : yes
OpenSSL library supports SNI : yes
OpenSSL library supports prefer-server-ciphers : yes
Built with PCRE version : 8.32 2012-11-30
PCRE library supports JIT : no (USE_PCRE_JIT not set)
Built with transparent proxy support using: IP_TRANSPARENT IPV6_TRANSPARENT IP_FREEBIND

Available polling systems :
      epoll : pref=300,  test result OK
       poll : pref=200,  test result OK
     select : pref=150,  test result OK
Total: 3 (3 usable), will use epoll.
```

##### 기본설정 : /etc/haproxy/haproxy.cfg 
- `global` : 전역 설정 
- `defaults` : 디폴트 설정 
- `frontend` : `client`로 부터 접속 정보, 5000 Port 대기
- `backend` : 요청을 수행하는 서버로 전달, 3대의 서버로 전달
- `listen` : `frontend` + `backend` 한꺼번에 정리할 수 있는 섹션, Stats Monitoring UI 설정 

```config
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats
    bind :8404
    stats enable
    stats uri /monitor
    stats refresh 5s

frontend  front_main
    bind :5000 
    option      forwardfor
    default_backend   app

backend app
    balance     roundrobin
    server  app1 192.168.28.15:30010 check
    server  app2 192.168.28.16:30010 check
    server  app3 192.168.28.17:30010 check
```

---
### SSL 인터페이스
- <https://serverfault.com/questions/738045/haproxy-to-terminate-ssl-also-send-ssl-to-backend-server>{:target="_blank"}

##### Frontend SSL Bind 

```config 
...
frontend  front_main
    bind :5443  ssl crt /cert/path/domain_keypem.pem
    option      forwardfor
    default_backend   app
...
```

##### Backend SSL 호출

```config 
...
backend app
    balance     roundrobin
    mode http 
    server  app1 192.168.28.15:30443 ssl verify none
    server  app2 192.168.28.16:30443 ssl verify none
...
```

---

#### Four Essential Sections
- <https://www.haproxy.com/blog/the-four-essential-sections-of-an-haproxy-configuration/>{:target="_blank"}
- 4개의 기본 섹션 구조 설명 

```config
global
    # global settings here

defaults
    # defaults here

frontend
    # a frontend that accepts requests from clients

backend
    # servers that fulfill the requests
```

---

#### 기타 
- SSL 설정 : <https://www.haproxy.com/blog/haproxy-ssl-termination/>{:target="_blank"}
- 통계 Web UI : <https://www.haproxy.com/blog/exploring-the-haproxy-stats-page/>{:target="_blank"}

![](/images/2021-11-23-14-46-19.png)

---

#### 튜닝 : Tuning your Linux kernel and HAProxy instance for high loads
- <https://medium.com/@pawilon/tuning-your-linux-kernel-and-haproxy-instance-for-high-loads-1a2105ea553e>{:target="_blank"}
- haproxy 설정 및 linux kernel tweaks 설정

{% endraw %}
