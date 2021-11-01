---
title: Docker in Docker / Docker out of Docker

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - docker
  - dind
  - dood
---

Docker 내부에서 Docker 실행 

{% raw %}

## Docker in Docker : `DinD`
- Docker 내부에서 Docker 를 실행 하기 위해서는 추가적인 호스트 머신의 권한을 획득 해야함 
  - `--privileged` : Give extended privileges to this container
  - 호스트 머신의 커널 기능 및 장치에 접근 가능하게 됨

### `--privileged` 의 문제점 
- 안전하지 않은 컨테이너로 인한 호스트 머신의 커널이나 장치를 활용하여 취약점에 노출되게 됨 
- <http://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/>{:target="_blank"}

> 서비스 환경에서의 여러가지 약점은 가지고 있지만, Workflow 등의 내부 Devops 툴로서의 유용하다고 판단

### Docker in Docker 실행 
- alpine 이미지 활용 테스트 

```sh
$ docker run -it --rm --privileged --name=dind alpine
```

- Docker 설치 및 실행 
  
```sh
# 설치
$ apk add docker
fetch http://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
(1/13) Installing ca-certificates (20191127-r5)
...
(13/13) Installing docker (20.10.7-r2)
Executing docker-20.10.7-r2.pre-install
Executing busybox-1.33.1-r3.trigger
Executing ca-certificates-20191127-r5.trigger
OK: 253 MiB in 27 packages

# 실행
$ dockerd 2> /dev/null &

$ ps -ef
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh
  125 root      0:00 dockerd
  133 root      0:00 containerd --config /var/run/docker/containerd/containerd.toml --log-le
  260 root      0:00 ps -ef
```

- Docker in Docker 테스트 

```sh
$ cat /etc/*-release
3.14.2
NAME="Alpine Linux"
ID=alpine
VERSION_ID=3.14.2
PRETTY_NAME="Alpine Linux v3.14"
HOME_URL="https://alpinelinux.org/"
BUG_REPORT_URL="https://bugs.alpinelinux.org/"

$ docker run --rm ubuntu cat /etc/*-release
cat: /etc/alpine-release: No such file or directory
NAME="Ubuntu"
VERSION="20.04.3 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.3 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal

$ docker run --rm centos cat /etc/*-release
cat: /etc/alpine-release: No such file or directory
NAME="CentOS Linux"
VERSION="8"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="8"
PLATFORM_ID="platform:el8"
PRETTY_NAME="CentOS Linux 8"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:8"
HOME_URL="https://centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"
CENTOS_MANTISBT_PROJECT="CentOS-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
```

## Docker out of Docker : `DooD`
- `--privileged` 사용의 피하기위한 방법
- CLI 명령 API인 `docker.sock` 을 활용, 볼륨을 통해 호스트 머신의 명령을 전달하여 호스트 머신에서 실행 하는 방법
  - `/var/run/docker.sock`

### `/var/run/docker.sock`
- docker daemon 에서 인터페이스용으로 노출한 unix domain socket
  
### Docker ouf of Docker 실행

```sh
# volume 으로 docker.sock 을 연결 
$ docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock --name=dood alpine
```

- Docker 설치 및 실행 
  
```sh
# 설치
$ apk add docker
fetch http://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
(1/13) Installing ca-certificates (20191127-r5)
...
(13/13) Installing docker (20.10.7-r2)
Executing docker-20.10.7-r2.pre-install
Executing busybox-1.33.1-r3.trigger
Executing ca-certificates-20191127-r5.trigger
OK: 253 MiB in 27 packages

# 호스트머신에서 명령을 실행 하므로 자신의 컨테이너가 보임 
$ docker ps
CONTAINER ID   IMAGE     COMMAND     CREATED         STATUS         PORTS     NAMES
1a391d12768c   alpine    "/bin/sh"   2 minutes ago   Up 2 minutes             dood


$ docker run -d --rm --name=ubuntu ubuntu sleep 10
d14cfc9ff9cd2b4faecfed5af9e1e1b6dd4a7d1497bed4a6d34faaad64a442f9

# 자신의 컨테이너와 동일한 환경에서의 별도 docker 실행 확인
$ docker ps
CONTAINER ID   IMAGE     COMMAND      CREATED         STATUS         PORTS     NAMES
d14cfc9ff9cd   ubuntu    "sleep 10"   3 seconds ago   Up 2 seconds             ubuntu
1a391d12768c   alpine    "/bin/sh"    6 minutes ago   Up 6 minutes             dood
```


{% endraw %}