---
title: Docker build multi-architecture

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - docker
  - docker build
  - docker buildx
  - buildx 
  - multi architecture
  - amd64
  - arm64
---

{% raw %}

Docker image multi architecture (Platform) 대응 

## Docker build
Docker build 시, build 하는 머신의 Platform 에 맞춰 기본으로 빌드 됨 

- `macOS` `arm64`

```sh
$ uname -a
Darwin glass 20.6.0 Darwin Kernel Version 20.6.0: Wed Jun 23 00:26:27 PDT 2021; \
root:xnu-7195.141.2~5/RELEASE_ARM64_T8101 arm64
```

```dockerfile
# Dockerfile
FROM alpine
uname -a 
```

```sh
# no-cache, plain output
$ docker build . -t cdecl/alpine --no-cache --progress=plain
...
#5 [2/2] RUN uname -a
#5 sha256:bb35af1757e6b002e99344411e8e8fc700e8760f29f48b4de0f0bb7276ead75d
#5 0.238 Linux buildkitsandbox 5.10.25-linuxkit #1 SMP PREEMPT Tue Mar 23 09:24:45 UTC 2021 aarch64 Linux
#5 DONE 0.2s
...

$ docker image inspect cdecl/alpine -f '{{.Architecture}}'
arm64
```

### Platform 변경하여 이미지 빌드 
- `amd64` (x86_64) 빌드 : `--platform=linux/amd64`

```sh
# amd64 로 플랫폼 지정 빌드 
$ docker build . -t cdecl/alpine --platform=linux/amd64 --no-cache --progress=plain
...
#6 [2/2] RUN uname -a
#6 sha256:21c96dec48d15465f32e8d9fa806cfc57b42464b19c34d1ff4a662e263406f79
#6 0.260 Linux buildkitsandbox 5.10.25-linuxkit #1 SMP PREEMPT Tue Mar 23 09:24:45 UTC 2021 x86_64 Linux
#6 DONE 0.3s
...

$ docker image inspect cdecl/alpine -f '{{.Architecture}}'
amd64
```

> `이미지:태그`는 마지막 빌드한 Platform 환경으로 결정  

## Multi-architecture docker images build
- <https://docs.docker.com/desktop/multi-arch/>{:target="_blank"}
- 같은 `이미지:태그`에 Multi-architecture 이미지 적용  
- `docker buildx` 명령 사용 

### Builder 환경 확인
- `docker buildx ls`  

```sh
# command to list the existing builder
$ docker buildx ls
NAME/NODE       DRIVER/ENDPOINT STATUS  PLATFORMS
desktop-linux   docker
  desktop-linux desktop-linux   running linux/arm64, linux/amd64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
default *       docker
  default       default         running linux/arm64, linux/amd64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

### Custom Builder 만들기 
- Create and use : `docker buildx create --name cdeclx --use`
- `docker buildx build` 를 위한 Container 환경 구성 : `moby/buildkit:buildx-stable-1`

```sh
# Create a new builder
$ docker buildx create --name cdeclx
cdeclx

# Switch to the new builder : cdeclx 빌더 사용
$ docker buildx use cdeclx

# builder 확인 
$ docker buildx ls
NAME/NODE       DRIVER/ENDPOINT             STATUS  PLATFORMS
cdeclx *        docker-container
  cdeclx0       unix:///var/run/docker.sock running linux/arm64, linux/amd64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/mips64le, linux/mips64, linux/arm/v7, linux/arm/v6
desktop-linux   docker
  desktop-linux desktop-linux               running linux/arm64, linux/amd64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
default         docker
  default       default                     running linux/arm64, linux/amd64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```

### Multi-architecture image build 
- `docker buildx build` 명령어 사용 
  - `--platform=<platform>` : `--platform=linux/arm64,linux/amd64`
  - `bootstrap` 준비과정 생략 가능 : `docker buildx inspect --bootstrap`

```sh
$ docker buildx build . -t cdecl/alpine --platform=linux/arm64,linux/amd64
WARN[0000] No output specified for docker-container driver. Build result will only remain in the build cache. To push result image into registry use --push or to load image into docker use --load
[+] Building 10.1s (11/11) FINISHED
 => [internal] booting buildkit                                                                                                                 3.9s
 => => pulling image moby/buildkit:buildx-stable-1
...
```

> WARN[0000] 도커 컨테이너 드라이버에 대해 지정된 출력이 없습니다. 빌드 결과는 빌드 캐시에만 남습니다.  
> 결과 이미지를 레지스트리에 푸시하려면 –push를 사용하거나 이미지를 도커에 로드하려면 –load를 사용하세요.

```sh
# --push
$ docker buildx build . -t cdecl/alpine --platform=linux/arm64,linux/amd64 --push
[+] Building 6.2s (11/11) FINISHED
 ...
 => [auth] cdecl/alpine:pull,push token for registry-1.docker.io
```

![](/images/2021-08-31-16-15-41.png)

{% endraw %}
