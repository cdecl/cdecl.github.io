---
title: Docker Multi-Architecture Build Guide
last_modified_at: 2024-11-15

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

# Docker 이미지 다중 아키텍처(Multi-Architecture) 빌드 가이드

{% raw %}

## Docker build
Docker 이미지를 빌드할 때는 기본적으로 빌드하는 머신의 CPU 아키텍처(Platform)에 맞춰 빌드됩니다. 이는 Docker의 기본 동작이며, 호스트 시스템의 아키텍처와 일치하는 이미지를 생성합니다.

> **아키텍처의 중요성**: 컨테이너는 호스트 OS의 커널을 공유하지만, CPU 아키텍처에 맞는 바이너리가 필요합니다. 예를 들어, ARM64용으로 빌드된 이미지는 AMD64 시스템에서 직접 실행할 수 없습니다.

- `macOS` `arm64` 테스트

```sh
$ uname -a
Darwin glass 20.6.0 Darwin Kernel Version 20.6.0: Wed Jun 23 00:26:27 PDT 2021; \
root:xnu-7195.141.2~5/RELEASE_ARM64_T8101 arm64
```

```dockerfile
# Dockerfile
FROM alpine
RUN uname -a 
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
Docker는 `--platform` 플래그를 통해 타겟 아키텍처를 지정할 수 있습니다. QEMU를 통한 에뮬레이션으로 크로스 플랫폼 빌드가 가능합니다.

지원되는 주요 플랫폼:
- `linux/amd64`: x86_64 아키텍처 (Intel, AMD)
- `linux/arm64`: 64비트 ARM 아키텍처 (Apple Silicon, AWS Graviton)
- `linux/arm/v7`: 32비트 ARM v7 아키텍처 (라즈베리파이 등)
- `linux/386`: 32비트 x86 아키텍처

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

> **주의사항**: 같은 `이미지:태그`에 대해 다른 플랫폼으로 빌드하면 이전 이미지를 덮어쓰게 됩니다. 이는 단일 태그가 하나의 이미지만 참조할 수 있기 때문입니다.

## Multi-architecture docker images build
Docker BuildX는 Docker의 실험적 기능으로, 다중 아키텍처 이미지를 효율적으로 빌드하고 관리할 수 있게 해줍니다.

주요 특징:
- 하나의 매니페스트로 여러 아키텍처 이미지 관리
- 동시에 여러 플랫폼용 이미지 빌드
- 효율적인 캐시 관리와 병렬 빌드 지원
- OCI(Open Container Initiative) 표준 준수

참고 문서: https://docs.docker.com/desktop/multi-arch/

### Builder 환경 확인
BuildX는 여러 빌더 인스턴스를 관리할 수 있으며, 각 빌더는 서로 다른 기능과 설정을 가질 수 있습니다.

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
BuildX 빌더는 이미지 빌드를 위한 독립된 환경을 제공합니다. 커스텀 빌더를 사용하면 특정 요구사항에 맞는 빌드 환경을 구성할 수 있습니다.

빌더 특징:
- 격리된 빌드 환경 제공
- 커스텀 캐시 설정 가능
- 특정 플랫폼에 최적화된 빌드 가능
- 동시 빌드 작업 처리

```sh
# Create a new builder
$ docker buildx create --name cdeclx
cdeclx

# Switch to the new builder
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
BuildX를 사용한 다중 아키텍처 이미지 빌드는 하나의 명령으로 여러 플랫폼용 이미지를 생성할 수 있게 해줍니다.

빌드 옵션:
- `--platform`: 빌드할 대상 플랫폼 지정
- `--push`: 빌드 완료 후 레지스트리에 자동 푸시
- `--load`: 로컬 Docker 데몬에 이미지 로드 (단일 플랫폼만 가능)
- `--cache-from`, `--cache-to`: 원격 캐시 설정

```sh
$ docker buildx build . -t cdecl/alpine --platform=linux/arm64,linux/amd64
WARN[0000] No output specified for docker-container driver. Build result will only remain in the build cache. To push result image into registry use --push or to load image into docker use --load
[+] Building 10.1s (11/11) FINISHED
 => [internal] booting buildkit                                                                                                                 3.9s
 => => pulling image moby/buildkit:buildx-stable-1
...
```

> **중요**: BuildX 빌드 결과를 사용하기 위해서는 `--push` 또는 `--load` 옵션이 필요합니다. 기본적으로는 빌드 캐시에만 저장됩니다.

```sh
# --push 옵션으로 레지스트리에 직접 푸시
$ docker buildx build . -t cdecl/alpine --platform=linux/arm64,linux/amd64 --push
[+] Building 6.2s (11/11) FINISHED
 ...
 => [auth] cdecl/alpine:pull,push token for registry-1.docker.io
```

![](/images/2021-08-31-16-15-41.png)

빌드된 이미지는 Docker Hub나 프라이빗 레지스트리에서 매니페스트 리스트로 관리되며, 클라이언트의 아키텍처에 맞는 이미지가 자동으로 선택되어 다운로드됩니다.

{% endraw %}
