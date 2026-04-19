---
title: "macOS에서 Wireshark 활용하기: tcpdump 비교부터 HTTP/SSL 분석까지"
tags:
  - wireshark
  - tcpdump
  - macos
  - network
  - devops
---

네트워크 문제를 디버깅하거나 프로토콜의 동작 방식을 심층적으로 이해하고 싶을 때, 패킷 캡처 도구는 개발자와 엔지니어에게 필수적인 무기입니다. 특히 macOS 환경에서 네트워크 패킷 분석을 위해 가장 널리 쓰이는 양대산맥 도구로 **tcpdump**와 **Wireshark(와이어샤크)**가 있습니다.

이번 글에서는 macOS에서 Wireshark를 활용하는 방법, tcpdump와의 비교, 기본적인 사용법, 그리고 실제 장애 대응이나 보안 검토에 자주 쓰이는 HTTP 및 SSL(TLS) 패킷 분석 방법을 정리해 보겠습니다.

---

## 1. Wireshark의 핵심 특징 및 tcpdump와의 비교

### Wireshark (와이어샤크)란?
Wireshark는 GUI(그래픽 사용자 인터페이스) 기반의 세계에서 가장 널리 사용되는 오픈 소스 네트워크 프로토콜 분석기입니다. 복잡한 네트워크 패킷을 사람이 읽기 편하게 구조화하여 보여주며, 강력한 색상 코드와 검색(필터링) 기능을 제공합니다.

### ⚔️ Wireshark vs tcpdump

두 도구 모두 네트워크 인터페이스를 지나가는 패킷을 가로채고(`pcap` 라이브러리 사용) 복제하여 분석한다는 점은 **가장 큰 유사점**입니다. 하지만 다음과 같은 확연한 **차이점**이 있습니다.

| 비교 항목 | Wireshark | tcpdump |
| :--- | :--- | :--- |
| **인터페이스** | 시각성이 뛰어난 GUI 제공 | 텍스트 기반의 CLI 명령어 환경 |
| **운영 환경** | 데스크톱 환경(개인 PC, Mac)에 적합 | 백엔드 서버, 원격 리눅스 시스템(ssh)에 유리 |
| **프로토콜 해석** | 수많은 프로토콜에 대해 L1 방면부터 L7까지 구조를 트리 형식으로 깊이 있게 분석 | 기본적인 헤더 정보 위주로 한 줄의 짧은 텍스트 파싱을 출력 |
| **필터링 방식** | 캡처 후 분석을 위한 가독성 높은 Display Filter에 매우 강함 | 캡처 시 패킷을 제한하는 BPF(Berkeley Packet Filter) 주로 사용 |
| **리소스 사용량** | 메모리와 CPU 리소스를 비교적 많이 소모함 | 가볍고 오버헤드가 매우 적어 상시 서버 모니터링에 알맞음 |

**💡 실무 팁(Best Practice):**  
실제 운영 환경(예: 클라우드 서버나 헤드리스 환경)에서는 **tcpdump**를 이용해 가볍게 `.pcap` 형식의 패킷 덤프 파일을 캡처하고, 이를 로컬 Mac으로 다운로드한 뒤 **Wireshark**로 열어 시각적으로 정밀 분석하는 방식을 가장 많이 애용합니다.

---

## 2. 인터페이스 선택 및 기본 커맨드(디스플레이 필터)

macOS에서 Wireshark를 실행한 뒤 가장 먼저 해야 할 일은 **패킷을 캡처할 네트워크 인터페이스를 선택**하는 것입니다.

### 📍 인터페이스(Capture Interface) 선택
* `en0` (Wi-Fi): Mac에서 무선 네트워크 트래픽을 관제할 때 일반적으로 선택합니다.
* `lo0` (Loopback): `localhost(127.0.0.1)` 영역의 내부 통신 트래픽(예: 백엔드 노드와 로컬 DB 간 통신)을 확인할 때 사용합니다.
* `en1` ~ `enX` (이더넷 등): 유선 LAN 케이블 기기 접속이나 썬더볼트 독(Dock)을 통한 물리적 연결일 경우 선택합니다.

### 🔧 Wireshark 디스플레이 필터 및 tcpdump 호환 명령어 비교
Wireshark 상단 필터 박스에 입력하는 **Display Filter**와 서버 환경에서 자주 쓰는 **tcpdump BPF 명령어**를 1:1로 비교하면 연계하여 활용하기 더욱 수월합니다.

| 분류 | 목적 패턴 | Wireshark 필터 (Display Filter) | tcpdump 명령어 (BPF) |
| :--- | :--- | :--- | :--- |
| **IP 필터** | **(Any)** 출발/목적지 무관 | `ip.addr == 192.168.0.1` | `tcpdump host 192.168.0.1` |
| **IP 필터** | **(Src)** 출발지 특정 | `ip.src == 10.0.0.5` | `tcpdump src 10.0.0.5` |
| **IP 필터** | **(Dst)** 목적지 특정 | `ip.dst == 8.8.8.8` | `tcpdump dst 8.8.8.8` |
| **포트 필터** | **(Port)** 단일 포트 통신 지정 | `tcp.port == 80` | `tcpdump tcp port 80` |
| **플래그 조건** | **(SYN)** 연결 시도(SYN)만 캡처 | `tcp.flags.syn == 1 && tcp.flags.ack == 0` | `tcpdump "tcp[tcpflags] & (tcp-syn) != 0"` |
| **논리 연산자** | 특정 IP + 단일 포트 조합 (AND) | `ip.addr == 192.168.0.1 && tcp.port == 443` | `tcpdump host 192.168.0.1 and tcp port 443` |

---

## 3. 프로토콜 분석 실습: HTTP 패킷 내용 확인하기

보안이 적용되지 않은 일반 웹 트래픽(`HTTP`, 포트 80)은 Wireshark를 통해 주고받은 메시지 내용(Payload)을 아무런 제약 없이 그대로 들여다볼 수 있습니다. API 헤더 누락 여부나 바디의 포맷을 디버깅할 때 활용할 수 있습니다.

### 🔍 HTTP 분석 예제 흐름
1. Wireshark에서 `en0`(Wi-Fi) 캡처를 시작합니다.
2. 터미널(또는 브라우저)에서 SSL이 없는 HTTP 예제 사이트에 요청을 보냅니다.
   ```bash
   curl http://example.com
   ```
3. Wireshark 필터 입력창에 `http`라고 입력하고 엔터를 칩니다.
4. 패킷 목록에서 클라이언트가 서버로 보낸 `GET / HTTP/1.1` 패킷을 클릭합니다.
5. 화면 하단의 세부 정보 트리(Packet Details)에서 **[Hypertext Transfer Protocol]** 탭을 확장(▶)합니다.
   * `Host: example.com`
   * `User-Agent: curl/8.4.0`
   * `Accept: */*`  
   위와 같이 HTTP 요청 헤더에 담긴 내용이 평문(Plain Text)으로 명확히 보입니다.
6. 이어지는 서버의 **`HTTP/1.1 200 OK`** 응답 패킷을 클릭하여 확인합니다.
   * 가장 아래의 **[Line-based text data]** 부분을 펼치면 응답받은 HTML 코드 전체(`<!doctype html>...`) 본문 내용을 날것 그대로 확인할 수 있습니다.

> **💡 팁:** 특정 HTTP 통신 전체의 대화 흐름을 한 창에서 깔끔하게 보고 싶다면, 해당 패킷에서 **`[우클릭] -> Follow -> HTTP Stream`**을 선택하세요. 클라이언트 요청과 서버 응답이 색상별로 구분된 별도의 대화 창이 나타납니다.

---

## 4. 프로토콜 분석 실습: 환경변수와 로그를 활용하여 SSL(TLS) 패킷 복호화하기

HTTPS 환경의 보편화로 네트워크 패킷의 페이로드(내용물)는 암호화(Application Data)되어 전송됩니다. 이제는 서버의 개인키(Private Key)를 직접 쥐고 있더라도, 최신 브라우저들이 사용하는 상위 암호화 기법(PFS; Perfect Forward Secrecy 등)으로 인해 실시간 복호화가 매우 까다롭습니다.

따라서 현대의 SSL/TLS 패킷 복호화는 주로 브라우저나 HTTP 클라이언트 툴이 세션 협상 과정에서 만들어내는 **대칭키(Pre-Master Secret)**를 **환경 변수를 통해 특정한 로그 파일에 따로 빼돌려 저장**한 뒤, 이를 Wireshark에 제공하는 방식을 사용합니다.

### 🔐 SSLKEYLOGFILE 환경변수 적용 및 확인 가이드

**1. 대칭키 추출용 로그 파일 설정 (`SSLKEYLOGFILE` 환경변수 주입)**
운영체제의 환경변수(`SSLKEYLOGFILE`)로 특정 시스템 경로를 선언하면, curl이나 Chrome 같은 클라이언트 애플리케이션은 해당 경로의 물리적 파일에 난수화된 키 값을 자동으로 지속 기록합니다.

```bash
# 로그 파일이 저장될 물리적 파일 경로 지정 (환경변수로 주입)
export SSLKEYLOGFILE="${HOME}/Desktop/sslkey.log"

# 터미널에서 곧바로 curl 명령어로 복호화 키를 추출해볼 수 있음
curl -I https://example.com

# 또는 동일한 터미널 창(환경변수가 적용된 창)에서 Chrome 브라우저를 실행
# (※ 이미 실행된 프로세스가 있다면 완전히 종료(Quit) 후 올려야 환경변수가 상속됩니다)
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome
```
*(위 작업 직후 설정했던 `~/Desktop/sslkey.log` 파일을 열어보면, 클라이언트가 교환한 `CLIENT_RANDOM ...` 형태의 세션 암호키가 줄 단위로 쭉 남겨져 있는 것을 육안으로 확인할 수 있습니다.)*

**2. Wireshark에 로그(키 파일) 맵핑 등록하기 (TLS 해독 원리)**
패킷을 잡아냈더라도 내부 페이로드는 여전히 TLS 알고리즘으로 꽁꽁 싸매진 형태(`Application Data`)입니다. 이 암호를 풀려면 Wireshark 내부의 TLS 캡슐 파서(Parser)에게 우리가 추출해놓은 대칭키 로그의 위치를 직접 알려주어야 합니다. 와이어샤크는 캡처된 패킷의 `Client Hello` 단계에서 발생하는 랜덤 식별자와, 우리가 연결해 준 `sslkey.log` 파일 안의 `CLIENT_RANDOM` 값을 실시간으로 대조(Mapping)하여 짝이 맞는 세션의 데이터를 즉시 복호화해 냅니다.
* 메뉴 경로: `Wireshark` 상단 메뉴 -> `Preferences(설정)` -> `Protocols` 탭 확장 -> **`TLS`** (버전에 따라 `SSL`) 선택
* 우측 패널의 **(Pre)-Master-Secret log filename** 항목 `Browse...` 버튼을 클릭하여 앞서 생성된 `~/Desktop/sslkey.log` 파일을 지정 후 저장합니다.

**3. 트래픽 복호화 결과 확인**
1. 설정이 끝나면 기존 Wireshark 패킷 리스트에 새롭게 복호화 엔진 분석이 적용됩니다.
2. 이전에 내용물이 감춰져 `Application Data`로만 표시되던 헤더 뒷단의 페이로드들이 **`Decrypted HTTP2`** (또는 `HTTP`) 통신으로 풀려나옵니다.
3. 세부 정보 탭을 살펴보면 평문 텍스트가 그대로 노출되어, 실제 어떤 JSON이나 HTML 바디가 암호화되어 오갔는지 명확하게 들여다볼 수 있습니다.

> 이같은 별도 환경변수 로깅-복호화 기법은 모바일 시뮬레이터 구동 분석, 외부 써드파티 API(OAuth 등) 에러 분석, 서버 대 서버 암호화 통신 트러블슈팅 등에서 진가를 발휘하는 강력한 무기입니다.

---

### 마치며

Wireshark는 GUI를 통해 패킷 구조를 L2(데이터 링크 계층)부터 L7(응용 계층)까지 깊이 있게 분해해서 가시화하는 강력한 네트워크 현미경과 같습니다. CLI에 특화된 tcpdump와 적절하게 조합하고 SSL 세션 해독 기능까지 숙달한다면, 거의 모든 계층의 네트워크 트러블슈팅 원인을 명확하게 식별해내실 수 있을 것입니다.
