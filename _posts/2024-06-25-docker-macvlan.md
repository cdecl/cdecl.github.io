---
title: Docker 네트워크 - Macvlan 

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - docker
  - docker network
  - macvlan
  - macos
---
 
Docker Macvlan 네트워크 소개, 활용 및 이슈 

{% raw %}

## 1. Docker Macvlan 네트워크?
Macvlan 네트워크는 컨테이너에 독립적인 네트워크 인터페이스를 제공하여 물리적 네트워크와 직접 상호작용 가능  
이는 각 컨테이너가 고유한 MAC 주소를 가지므로 네트워크 수준에서 완전히 독립된 호스트처럼 동작 가능

> 호스트 머신과 같은 네트워크에 docker 컨테이너를 생성 목적  
> Macvlan 네트워크 설정은 물리적 네트워크 환경에 따라 적절한 서브넷과 게이트웨이를 사용 필요 (e.g. DHCP 환경)


### Macvlan 구성 
- **네트워크 성능 향상**: 호스트의 NAT를 거치지 않아 성능이 향상
- **네트워크 격리**: 각 컨테이너가 고유한 MAC 주소를 가져 네트워크 레벨에서 완전히 격리
- **기존 네트워크와의 통합**: 기존 물리적 네트워크 인프라와 쉽게 통합


### Docker 네트워크 유형
1. 브리지 네트워크 (Bridge Network)
  - 기본 네트워크 모드로, Docker가 기본적으로 사용하는 네트워크입니다.
  - 내부 네트워크를 생성하여 컨테이너 간의 통신을 가능하게 합니다.
  - 호스트와 컨테이너 간의 통신은 NAT(Network Address Translation)를 사용합니다.
2. 호스트 네트워크 (Host Network)
  - 컨테이너가 호스트의 네트워크 스택을 공유합니다.
  - 성능이 중요한 애플리케이션에서 사용될 수 있습니다.
  - 컨테이너와 호스트 간의 네트워크 격리가 없습니다.
3. None 네트워크 (None Network)
  - 네트워크 연결이 없는 컨테이너를 생성합니다.
  - 네트워크 격리가 필요한 경우에 유용합니다.

## 2. Macvlan 네트워크 설정

### 설치 요구 사항
Docker가 설치된 시스템, 루트 권한 또는 Docker 관리 권한

### Macvlan 네트워크 설정

#### **물리적 네트워크 인터페이스 확인** : 인터페이스(예: `eth0`)를 확인
  
```bash
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
3: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 16:55:9f:a4:e8:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 198.19.249.146/24 brd 198.19.249.255 scope global dynamic noprefixroute eth0
       valid_lft 171944sec preferred_lft 171944sec
    inet6 fd07:b51a:cc66:0:1455:9fff:fea4:e814/64 scope global noprefixroute
       valid_lft forever preferred_lft forever
    inet6 fe80::1455:9fff:fea4:e814/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:ce:33:77:9e brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:ceff:fe33:779e/64 scope link
       valid_lft forever preferred_lft forever
```

#### **Macvlan 네트워크 생성**
```bash
# 생성 
$ docker network create -d macvlan --subnet=198.19.249.0/24 --gateway=198.19.249.1 -o parent=eth0 macvlan_network
0da5a9be311ca6a6d1145706e9f1f7c1de6e0e6109023a8ab001d4d5545c2488

# 확인 
$ docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
5f6cec24b896   bridge            bridge    local
dd045112300c   host              host      local
0da5a9be311c   macvlan_network   macvlan   local
02db42ae4e83   none              null      local
```

## 3. Macvlan 네트워크 활용

### 컨테이너 생성 및 Macvlan 네트워크 연결
Macvlan 네트워크를 사용하는 컨테이너를 생성

```bash
$ docker run -d --name nginx --network macvlan_network nginx
```

이제 `nginx`는 `macvlan_network`를 통해 네트워크와 상호작용합니다.

### 컨테이너 네트워크 확인
컨테이너의 IP 및 네트워크 정보를 확인

```bash
$ docker inspect nginx

$ docker inspect nginx | jq '.[0].NetworkSettings.Networks'
{
  "macvlan_network": {
    "IPAMConfig": null,
    "Links": null,
    "Aliases": null,
    "MacAddress": "02:42:c6:13:f9:02",
    "DriverOpts": null,
    "NetworkID": "0da5a9be311ca6a6d1145706e9f1f7c1de6e0e6109023a8ab001d4d5545c2488",
    "EndpointID": "39bad26ad54da71238f79713f5a2ebc536f3714d0a7fa446afc8f2566ba55418",
    "Gateway": "198.19.249.1",
    "IPAddress": "198.19.249.2",
    "IPPrefixLen": 24,
    "IPv6Gateway": "",
    "GlobalIPv6Address": "",
    "GlobalIPv6PrefixLen": 0,
    "DNSNames": [
      "nginx",
      "03f76c3ff45a"
    ]
  }
}
```

> "IPAddress": "198.19.249.2" → 호스트 머신과 같은 네트워크워크 생성**

### ⛔️ MacOS 에서의 이슈 (e.g OrbStack)
- <https://github.com/docker/for-mac/issues/3926>{:target="_blank"}
- <https://github.com/moby/libnetwork/issues/2614>{:target="_blank"}
- macOS에서 Docker의 macvlan/ipvlan 네트워크 드라이버가 제대로 작동하지 않음
  - 2019년부터 보고 되었지만 미해결
- 원인:
   - macOS의 네트워크 인터페이스 이름(예: en0)이 Linux 스타일(예: eth0)과 다름
   - Docker Desktop for Mac이 Linux 가상 머신 내에서 실행되어 네이티브 macOS 네트워킹 모드를 지원하지 않음
- 문제점:
   - eth0 인터페이스를 지정하면 작동하는 것처럼 보이지만 실제로는 동작하지 않음
   - 공식 문서에 macOS에서 지원되지 않는다는 내용이 명확하게 표시 안됨
   - 일부는 Linux 서버를 구매하거나 VMware Fusion, VirtualBox 등을 사용하여 Linux VM을 실행하는 방식으로 우회

---

## ⚠️ 도커 호스트 머신과 같은 네트워크 대역의 브릿지 네트워크 드라이버 생성

### 브릿지 네트워크란?
브릿지 네트워크는 Docker가 기본적으로 사용하는 네트워크 모드로, 내부 네트워크를 생성하여 컨테이너 간의 통신을 가능하게 함  
호스트와 컨테이너 간의 통신은 NAT(Network Address Translation)를 사용합니다.

### 브릿지 네트워크 생성
호스트 머신과 같은 네트워크 대역을 사용하는 브릿지 네트워크를 생성하려면 다음 단계를 따릅니다.

#### **브릿지 네트워크 생성**
```bash
docker network create --driver bridge \
  --subnet=198.19.249.0/24 \
  --gateway=198.19.249.1 \
  --opt "com.docker.network.bridge.name"="br0" \
  host_bridge_network
```

> 리눅스 Docker에서는 호스트와 같은 네트워크를 생성하면 아래와 같은 에러 발생  
> Error response from daemon: invalid pool request: Pool overlaps with other one on this address space

> MacOS OrbStack 환경에서는 생성되기는 함  
> IP 충돌 주의 !!

#### **생성된 네트워크 확인**
```bash
docker network ls
```

#### **컨테이너 실행 시 네트워크 지정**
```bash
docker run -it --network host_bridge_network --name my_container ubuntu
```

## ⚠️ Macvlan 드라이버 구성과 차이점

### Macvlan vs Bridge 네트워크

| 특성                   | Macvlan                               | Bridge                             |
| ---------------------- | ------------------------------------- | ---------------------------------- |
| 네트워크 계층          | 데이터 링크 계층 (Layer 2)            | 네트워크 계층 (Layer 3)            |
| IP 할당                | 각 컨테이너에 직접 IP 할당            | 내부 서브넷을 통한 IP 할당         |
| 네트워크 성능          | 높음                                  | 중간                               |
| 설정 복잡성            | 상대적으로 복잡                       | 간단                               |
| 호스트-컨테이너 통신   | 추가 구성 필요할 수 있음              | 용이                               |
| 확장성                 | MAC 주소 제한으로 제약 가능           | 상대적으로 높음                    |
| 보안                   | 네트워크 수준 격리                    | NAT를 통한 내부 네트워크 보안      |
| 외부 접근성            | 직접 접근 가능                        | 포트 매핑 필요                     |
| 기존 네트워크와의 통합 | 용이                                  | 추가 구성 필요                     |
| Docker 기본 모드       | 아니오                                | 예                                 |
| 사용 사례              | 높은 성능, 기존 네트워크 통합 필요 시 | 일반적인 사용, 간단한 구성 필요 시 |

---

## 💡 Conclusion 
Macvlan과 bridge 네트워크의 차이점을 이해하고, 각 네트워크 드라이버의 장단점을 고려하여 적절한 네트워크 설정을 선택     
Macvlan은 특정 상황에서 유용하고, bridge 네트워크의 경우 많은 컨테이너 사용 시 병목 현상, 호스트 네트워크와 IP 충돌 가능성 등 관리가 어려우므로 주위를 요함 

{% endraw %}
