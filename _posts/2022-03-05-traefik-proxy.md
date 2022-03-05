---
title: Traefik Proxy

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - traefik
  - proxy
  - reverse proxy
  - docker
---

Docker 기반 서비스 자동 감지 및 요청을 처리하는 Reverse proxy 

{% raw %}

## Traefik Proxy
- <https://doc.traefik.io/traefik/>{:target="_blank"}
- docker.sock 을 통해 Rule 기반 서비스를 찾고 요청을 처리함 
- Docker 이외에 Kubernetes, Docker Swarm, AWS, Mesos, Marathon 등을 지원 

### Quick Start
- <https://doc.traefik.io/traefik/getting-started/quick-start/>{:target="_blank"}

#### docker-compose.yml
- `reverse-proxy` : traefik reverse proxy 서비스
  - Docker Out of Docker (DooD) 같은 형태로 서비스 감지 
  - 서비스와 같은 Docker network 내에 있어야 호출이 가능 
- `whoami` : Client 호출정보를 보여주는 간단한 서비스 
  - `labels` 을 통해 `whoami` 서비스 Rule 등록 
  - Host 기반 Rule 적용 : `"traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"`
    - `traefik.http.routers.<router_name>.rule=`
    - [Docker Routers 규칙](https://doc.traefik.io/traefik/routing/providers/docker/#routers){:target="_blank"}
    - [Rule 종류](https://doc.traefik.io/traefik/routing/routers/#rule){:target="_blank"}
  - 서비스에 Port 가 노출 되어야 함 : Expose port (or Publish port)

```yaml
version: '3'

services:
  reverse-proxy:
    # The official v2 Traefik docker image
    image: traefik:v2.6
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.insecure=true --providers.docker
    ports:
      # The HTTP port
      - "80:80"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock

  whoami:
    # A container that exposes an API to show its IP address
    image: traefik/whoami
    labels:
      - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
```

```sh
# reverse-proxy 서비스 시작 
$ docker-compose up -d reverse-proxy

# whoami 서비스 시작
$ docker-compose up -d whoami

$ docker ps 
CONTAINER ID   IMAGE            COMMAND     CREATED          STATUS         PORTS   NAMES
e457ff5e01cb   traefik/whoami   "/whoami"   59 minutes ago   Up 59 minutes  80/tcp  traefik_whoami_1
```

#### Dashboard Router 확인

![](/images/2022-03-06-05-35-01.png)

#### Test

```sh
$ curl -H Host:whoami.localhost localhost
Hostname: e457ff5e01cb
IP: 127.0.0.1
IP: 172.18.0.4
RemoteAddr: 172.18.0.3:56928
GET / HTTP/1.1
Host: whoami.localhost
User-Agent: curl/7.77.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 172.18.0.1
X-Forwarded-Host: whoami.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: 4c17ac309109
X-Real-Ip: 172.18.0.1
```

---

### Yaml 파일 분리 
- Docker network 생성 후, 서비스 시작 

```sh
$ docker network create traefik_network

$ docker network ls
NETWORK ID     NAME                    DRIVER    SCOPE
f27ea9f9e602   bridge                  bridge    local
efde6948625c   host                    host      local
1ad7a260c513   none                    null      local
fdd561c514ee   traefik_network         bridge    local
```

#### reverse-proxy 

```yaml
version: '3'

services:
  reverse-proxy:
    # The official v2 Traefik docker image
    image: traefik:v2.6
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.insecure=true --providers.docker
    ports:
      # The HTTP port
      - "80:80"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  default:
    external:
      name: traefik_network
```

#### whoami
- replicas 적용 테스트 

```yaml
version: '3'

services:
  whoami:
    # A container that exposes an API to show its IP address
    image: traefik/whoami
    labels:
      - "traefik.http.routers.whoami.rule=Host(`whoami.localhost`)"
    deploy:
      replicas: 4

networks:
  default:
    external:
      name: traefik_network
```


```sh
$ docker ps
CONTAINER ID   IMAGE            COMMAND     CREATED        STATUS        PORTS    NAMES
95c2a5aea831   traefik/whoami   "/whoami"   4 seconds ago  Up 3 seconds  80/tcp   traefik_whoami_3
406e1342044e   traefik/whoami   "/whoami"   4 seconds ago  Up 3 seconds  80/tcp   traefik_whoami_4
790f19b04598   traefik/whoami   "/whoami"   4 seconds ago  Up 3 seconds  80/tcp   traefik_whoami_2
9d764c51212e   traefik/whoami   "/whoami"   4 seconds ago  Up 3 seconds  80/tcp   traefik_whoami_1

$ curl -s -H Host:whoami.localhost localhost | grep Hostname
Hostname: 790f19b04598
$ curl -s -H Host:whoami.localhost localhost | grep Hostname
Hostname: 95c2a5aea831
$ curl -s -H Host:whoami.localhost localhost | grep Hostname
Hostname: 9d764c51212e
$ curl -s -H Host:whoami.localhost localhost | grep Hostname
Hostname: 406e1342044e
```

#### Dashboard 서비스 확인

![](/images/2022-03-06-06-10-23.png)


{% endraw %}
