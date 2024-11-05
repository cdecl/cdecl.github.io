---
title: 리눅스의 Init 시스템

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - linux
  - systemd
  - system v init
  - docker
  - init system
  - ubuntu
  - centos
  - service management
---

리눅스의 Init 시스템: System V Init와 Systemd 비교 분석 및 docker 활용 

{% raw %}

## 개요
리눅스 시스템에서 운영체제 부팅 시 초기화를 담당하는 프로그램을 init 시스템이라고 합니다.   
전통적인 System V Init와 현대적인 Systemd를 비교 분석하여, 시스템 초기화 방식의 발전과 실무적 영향을 살펴보겠습니다.

## 1. System V Init의 이해

### 기본 개념과 역할
- Unix System V에서 유래한 전통적인 초기화 시스템
- PID 1 프로세스로 동작하며 시스템의 첫 번째 프로세스
- 런레벨(runlevel) 기반의 시스템 상태 관리

### 주요 특징

#### 1. **런레벨 시스템**
- 런레벨 0: 시스템 종료
- 런레벨 1: 단일 사용자 모드
- 런레벨 3: 멀티유저 모드 (CLI)
- 런레벨 5: 그래픽 사용자 인터페이스 모드
- 런레벨 6: 시스템 재부팅

#### 2. **디렉토리 구조**
- `/etc/init.d/` : 서비스 스크립트 저장
- `/etc/rcN.d/`  : 각 런레벨(N)별 심볼릭 링크
- `/etc/inittab` : 기본 런레벨 및 init 설정

#### 3. **서비스 관리 명령어**

```bash
service httpd start
/etc/init.d/httpd stop
chkconfig httpd on
```

### System V Init 제한사항
- 순차적 실행으로 인한 느린 부팅 속도
- 복잡한 의존성 관리의 어려움
- 동적 서비스 관리의 한계

## 2. Systemd의 등장 배경과 특징

### 등장 배경
1. 현대 시스템의 복잡성 증가
2. 병렬 처리를 통한 성능 개선 필요
3. 더 나은 서비스 의존성 관리 요구
4. 통합된 시스템 관리 도구의 필요성

### 주요 특징
- Systemd는 시스템 초기화뿐만 아니라 서비스 관리, 로그 관리, 시스템 상태 모니터링 등의 종합적인 기능을 제공합니다.
- 부팅 과정에서 병렬 실행을 지원하며, 서비스 간 의존성을 명시하여 보다 빠르고 효율적인 초기화가 가능합니다.
- Unit 파일 구조를 사용하여 각 서비스의 구성과 제어를 쉽게 관리할 수 있습니다.
- Unit의 종류에는 서비스(.service), 타이머(.timer), 장치(.device) 등이 있으며, 이를 통해 다양한 유형의 리소스를 관리합니다.

#### 1. **Unit 시스템**

```ini
[Unit]
Description=My Web Service
After=network.target
Requires=mysql.service

[Service]
Type=simple
ExecStart=/usr/bin/myapp
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 2. **타겟(Target) 시스템**
- 기존 런레벨을 대체하는 유연한 구조
- 다중 타겟 동시 활성화 가능
- 의존성 기반 서비스 그룹화

#### 3. **주요 관리 명령어**

```bash
# 서비스 관리
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# 로그 확인
journalctl -u httpd
journalctl -f

# 타겟 관리
systemctl isolate multi-user.target
systemctl get-default
```

## 3. 핵심 차이점 분석

### 아키텍처 비교

| 특징        | System V Init  | Systemd       |
| ----------- | -------------- | ------------- |
| 실행 방식   | 순차적         | 병렬          |
| 설정 방식   | Shell 스크립트 | Unit 파일     |
| 의존성 관리 | 번호 기반 순서 | 선언적 의존성 |
| 상태 관리   | 런레벨         | 타겟          |
| 로깅        | syslog         | journald      |

### 성능 차이

1. **부팅 속도**
 - System V Init: 순차적 실행으로 느림
 - Systemd: 병렬 실행으로 최대 2-3배 빠름

2. **리소스 사용**
 - System V Init: 경량화
 - Systemd: 추가 기능으로 인한 더 많은 리소스 사용

## 4. 운영자/개발자 고려사항
- 구성 관리의 변화
  - Systemd의 Unit 파일은 서비스 관리 및 설정이 체계적이므로 학습 및 사용법 숙지가 필요합니다.
  - Systemd는 타겟 기반 관리와 의존성 트리 구조를 가지고 있어, 종속성과 의존성을 설정하고 모니터링하는 데 더 유연하며, 이를 통해 복잡한 서비스를 안정적으로 관리할 있습니다.
- 부팅 및 서비스 관리의 효율성
  - 부팅 시간 단축, 의존성 설정, 동시 실행 지원은 운영 및 시스템 초기화 효율성을 크게 개선시킵니다.
  - 단일 명령으로 전체 서비스를 제어하거나 로그를 분석할 수 있어, journalctl 같은 Systemd의 추가 도구를 익히면 편리합니다.
- 장기적인 지원 및 호환성 문제
  - 대부분의 리눅스 배포판이 Systemd를 기본 init 시스템으로 채택했지만, 일부 배포판에서는 여전히 System V Init 또는 대체 init 시스템을 사용하기도 합니다.
  - 일부 레거시 스크립트와의 호환성 문제가 발생할 수 있으므로, Systemd와 호환되도록 스크립트를 수정해야 할 수도 있습니다.


### 시스템 관리
- **서비스 설정**
  - System V Init: `/etc/init.d/` 스크립트 수정
  - Systemd: Unit 파일 작성 및 관리

- **문제 해결**
  - System V Init:
  ```bash
  tail -f /var/log/messages
  ```

  - Systemd:
    ```bash
    journalctl -xeu service-name
    ```

### 마이그레이션 고려사항
- 기존 Init 스크립트의 Systemd Unit 변환
- 의존성 관계 재정의
- 로깅 시스템 변경 대응



## 5. Docker 환경에서의 활용

Docker는 보통 단일 프로세스 실행을 목표로 설계되었기 때문에, init 시스템을 사용하는 대신 애플리케이션이 바로 실행됩니다. 하지만 컨테이너 내 여러 서비스 관리를 위해 `systemd`가 필요할 때 추가적인 설정을 통해 사용할 수 있습니다.

### 1. Docker에서 `System V Init` 방식 사용

일반적인 Docker 컨테이너는 단일 프로세스 원칙에 따라 동작합니다. `System V Init` 방식으로 단일 프로세스만 실행하는 예제를 보겠습니다.

#### 예제: System V Init 방식으로 Nginx 실행

컨테이너 내에서 단일 프로세스를 실행하는 방식입니다. `System V Init` 구조는 사용하지 않고 `nginx`만 단일 프로세스로 실행합니다.

**○ Dockerfile**
```dockerfile
# Nginx가 설치된 이미지를 베이스로 사용
FROM nginx:alpine

# Nginx를 단일 프로세스로 실행
CMD ["nginx", "-g", "daemon off;"]
```

**○ 실행**
```bash
docker build -t myapp .
docker run -d myapp
```

### 2. Docker에서 `Systemd` 사용 설정

Docker 컨테이너에서 `systemd`를 사용하려면, cgroup 설정과 권한을 조정해야 합니다. 아래는 `Ubuntu`를 베이스로 하여 `systemd`를 사용하는 방법을 보여줍니다.

#### 예제: Systemd 사용하여 다중 서비스 실행

여기서는 `systemd`가 필요할 때 사용할 수 있는 구성입니다. `Ubuntu 20.04` 베이스 이미지에 `systemd`를 설치하고 설정합니다.

**○ Dockerfile**
```dockerfile
# Ubuntu 이미지를 베이스로 사용
FROM ubuntu:20.04

# systemd 설치
RUN apt-get update && apt-get install -y systemd

# systemd가 cgroup을 사용할 수 있도록 VOLUME 설정
VOLUME [ "/sys/fs/cgroup" ]

# 컨테이너 시작 시 systemd 실행
CMD ["/lib/systemd/systemd"]
```

**○ 실행 방법**

`systemd`는 높은 권한이 필요하므로 `--privileged` 옵션을 사용하여 실행합니다. 또한 `/sys/fs/cgroup`을 마운트하여 `systemd`가 cgroup에 접근할 수 있도록 설정해야 합니다.

```bash
docker build -t myapp_systemd .
docker run --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d myapp_systemd
```

컨테이너가 실행된 후 `systemd`의 `systemctl` 명령을 통해 서비스를 제어할 수 있습니다.

**○ 예시**: Apache 웹 서버 서비스 실행

```bash
# 컨테이너 접속
docker exec -it <container_id> /bin/bash

# Apache 설치 및 서비스 실행
apt-get update && apt-get install -y apache2
systemctl start apache2
systemctl enable apache2

# 서비스 상태 확인
systemctl status apache2
```

### 3. 권장 사항

Docker는 단일 애플리케이션을 경량화된 컨테이너에서 실행하도록 설계되었으므로, init 시스템 사용은 필수적이지 않으며 권장되지 않습니다. `systemd`가 필요한 경우에만 사용하고, 일반적으로는 다음 권장 사항을 따릅니다.

1. **컨테이너는 단일 프로세스 원칙을 준수**  
   컨테이너는 단일 프로세스를 실행하도록 설계되었으므로, 여러 서비스를 실행할 경우 별도의 컨테이너를 사용하는 것이 좋습니다.

2. **경량화된 init 시스템 사용**  
   여러 프로세스를 관리할 필요가 있다면 `systemd` 대신 `Tini`와 같은 경량화된 init 시스템을 사용하는 것이 좋습니다.

3. **필요한 경우에만 systemd 도입**  
   `systemd`가 필요한 경우라면, cgroup과 권한 설정을 통해 설정할 수 있습니다. 하지만 가능한 한 가벼운 구성을 유지하는 것이 컨테이너 환경에 유리합니다.


## 기타 
리눅스 배포판에서 `systemd`는 `SysV init`를 대체하는 init 시스템으로 널리 도입되었습니다. 주요 리눅스 배포판에서의 도입 현황은 다음과 같습니다.

#### 1. CentOS
- **CentOS 7부터 systemd 기본 도입**: CentOS는 `7` 버전부터 `systemd`를 기본 init 시스템으로 채택했습니다.
- **CentOS 6 및 이전 버전**: `SysV init`을 사용했으며, 이후 CentOS 7에서 `systemd`로 전환되었습니다.
- **현재 상황**: CentOS 7 이후 배포판들은 모두 `systemd` 기반이며, 후속인 `CentOS Stream`도 이를 유지하고 있습니다.

#### 2. Ubuntu
- **Ubuntu 15.04부터 systemd 기본 도입**: `Ubuntu 15.04 (Vivid Vervet)`에서 `systemd`가 기본 init 시스템으로 도입되었습니다.
- **이전 버전**: Ubuntu는 14.10까지 `Upstart`라는 init 시스템을 사용했으며, 이후 `systemd`로 전환되었습니다.
- **현재 상황**: 최신 Ubuntu 버전들은 모두 `systemd`를 기본 init 시스템으로 사용하고 있습니다. `Ubuntu Server`와 `Desktop` 모두 동일합니다.

#### 3. Red Hat Enterprise Linux (RHEL)
- **RHEL 7부터 systemd 기본 도입**: Red Hat은 `RHEL 7`에서 `systemd`를 도입하여 주요 서비스 관리 방식을 `SysV init`에서 전환했습니다.
- **이전 버전**: `RHEL 6` 이하에서는 `SysV init`를 기본으로 사용했으며, `systemd`는 전혀 포함되지 않았습니다.
- **현재 상황**: `RHEL 7` 이후 모든 버전에서 `systemd`가 기본 init 시스템으로 사용되고 있습니다. 최신 `RHEL 9` 버전까지 이를 유지하고 있습니다.

#### 4. Fedora
- **Fedora 15부터 systemd 기본 도입**: Fedora는 2011년 Fedora 15에서 `systemd`를 기본 init 시스템으로 가장 먼저 도입한 배포판 중 하나입니다.
- **현재 상황**: 최신 버전까지 `systemd`를 사용하고 있으며, Red Hat 배포판들의 테스트베드 역할을 하는 Fedora는 `systemd` 기능 개선을 지속적으로 반영하고 있습니다.

#### 5. Debian
- **Debian 8 (Jessie)부터 systemd 기본 도입**: Debian은 `8.0 (Jessie)` 버전부터 `systemd`를 기본 init 시스템으로 채택했습니다.
- **이전 버전**: `SysV init`을 사용했으며, `systemd` 도입 시기에 논란이 있었으나 기본 init 시스템으로 결정되었습니다.
- **현재 상황**: Debian의 최신 버전인 `Debian 11 (Bullseye)`에서도 `systemd`가 기본으로 사용되고 있습니다.

#### 6. openSUSE 및 SUSE Linux Enterprise (SLE)
- **openSUSE 12.1부터 systemd 도입**: openSUSE는 `12.1`부터 기본 init 시스템으로 `systemd`를 채택했습니다.
- **SUSE Linux Enterprise**: `SUSE Linux Enterprise 12`부터 `systemd`를 도입했으며, 이로 인해 엔터프라이즈 환경에서도 더 효율적인 서비스 관리가 가능해졌습니다.
- **현재 상황**: openSUSE와 SLE의 최신 버전까지 `systemd`를 사용하고 있습니다.


> 현재 대부분의 주요 리눅스 배포판에서 `systemd`가 기본 init 시스템으로 채택되어 있습니다. 이로 인해 프로세스 관리와 서비스 제어가 통합되었고, 다양한 기능이 추가되어 현대적인 리눅스 시스템에서 중요한 역할을 하고 있습니다.


## 결론
Systemd는 현대 리눅스 시스템의 요구사항을 잘 반영한 init 시스템으로, 대부분의 주요 배포판에서 채택하고 있습니다. 하지만 컨테이너와 같은 특수한 환경에서는 상황에 맞는 적절한 초기화 방식을 선택하는 것이 중요합니다. 시스템 관리자와 개발자는 각 환경에 맞는 init 시스템의 특징을 이해하고, 이를 효과적으로 활용할 수 있어야 합니다.

{% endraw %}
 