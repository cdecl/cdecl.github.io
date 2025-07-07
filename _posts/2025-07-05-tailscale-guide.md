---
title: Tailscale 가이드 - 안전한 매쉬 VPN 활용법

toc: true  
toc_sticky: true

categories:
  - networking
  - devops

tags:
  - tailscale
  - vpn
  - mesh-vpn
  - security
  - remote-access

---

Tailscale의 핵심 개념, VPN 정의, 동작 방식, 설치 및 구성 방법, 엔드포인트 관리, 포트 제어, 다른 단말 접속, 그리고 보안 설정 방법

## Tailscale이란?

Tailscale은 WireGuard 프로토콜을 기반으로 한 현대적인 매쉬 VPN 솔루션으로, 복잡한 네트워크 설정 없이 장치 간 안전하고 빠른 연결을 제공합니다. 개인, 팀, 또는 기업의 장치를 연결하여 로컬 네트워크, 원격 서버, 모바일 장치를 쉽게 관리할 수 있습니다. 이 포스트에서는 Tailscale의 핵심 개념, VPN 정의와 매쉬 VPN 동작 방식, 설치 및 구성, 엔드포인트 확인, 포트 제어, 다른 단말 접속, 그리고 보안 설정을 자세히 다룹니다.

## Tailscale의 핵심 개념

이해하기 쉬운 Tailscale의 핵심 개념은 다음과 같습니다:

- **Tailnet**: Tailscale의 가상 네트워크로, 사용자의 모든 장치가 속하는 논리적 네트워크. 각 장치는 고유한 Tailscale IP(100.x.y.z) 또는 MagicDNS 이름(예: `my-laptop.tailnet`)을 가짐.
- **MagicDNS**: IP 주소 대신 직관적인 장치 이름(예: `my-pc.tailnet`)으로 연결을 가능하게 하는 기능. 관리 콘솔에서 기본적으로 활성화.
- **Tailscale IP**: tailnet 내 장치에 할당된 고유한 가상 IP 주소(100.x.y.z). 공인 IP나 방화벽 설정 없이 장치 간 연결 가능.
- **WireGuard**: Tailscale의 핵심 프로토콜로, 빠르고 안전한 암호화를 제공. 기존 VPN보다 간단하고 효율적.
- **DERP 서버**: P2P 연결이 불가능할 때 사용하는 릴레이 서버. HTTPS(443) 포트를 통해 동작하며, 데이터는 여전히 암호화됨.
- **제로 트러스트 보안**: 모든 연결은 기본적으로 암호화되며, 접근 제어 목록(ACL)을 통해 권한을 엄격히 관리.
- **태그(Tag)**: 장치나 사용자 그룹을 식별하는 라벨(예: `tag:server`). ACL에서 특정 그룹에 대한 접근 제어에 사용.
- **출구 노드(Exit Node)**: 특정 장치를 통해 tailnet의 인터넷 트래픽을 라우팅하는 기능.
- **서브넷 라우팅**: Tailscale이 설치되지 않은 로컬 네트워크 장치(예: 프린터)에 접근 가능하도록 설정.

### WireGuard 프로토콜
WireGuard는 Tailscale의 핵심 프로토콜로, 현대적이고 경량화된 VPN 프로토콜입니다. 다음은 WireGuard의 주요 특징과 Tailscale에서의 역할입니다:
- **경량화된 설계**: 약 4,000줄의 코드로 구성된 WireGuard는 기존 VPN 프로토콜(OpenVPN, IPsec 등)보다 간단하고 빠르며, 유지보수가 쉬움.
- **고성능 암호화**: ChaCha20, Poly1305, Curve25519와 같은 최신 암호화 기술을 사용하여 보안성과 속도를 동시에 제공.
- **빠른 연결 설정**: WireGuard는 연결 설정 시간이 짧아, Tailscale의 P2P 연결에서 지연 시간을 최소화.
- **크로스 플랫폼 지원**: Linux, Windows, macOS, iOS, Android 등 다양한 플랫폼에서 일관된 성능 제공.
- **Tailscale과의 통합**: Tailscale은 WireGuard를 사용하여 장치 간 직접 연결(P2P)을 구현하며, DERP 서버를 통해 NAT 관통 및 릴레이 연결을 보완.

WireGuard의 단순성과 보안성은 Tailscale의 빠르고 안전한 매쉬 VPN 환경을 가능하게 합니다.

## VPN 정의 및 Tailscale 동작 방식

### 1. VPN이란?
VPN(Virtual Private Network)은 공공 네트워크(인터넷)를 통해 장치 간 안전한 전용 네트워크를 형성하는 기술입니다. 데이터를 암호화하여 외부의 무단 접근을 차단하며, 원격으로 사설 네트워크에 접근할 수 있게 합니다.

### 2. Tailscale의 매쉬 VPN
- **동작 방식**: Tailscale은 **매쉬 VPN**(Mesh VPN)을 구현하여 모든 장치가 서로 직접 연결됩니다. 기존 허브-스포크 모델(중앙 서버를 통한 연결)과 달리, **피어-투-피어(P2P)** 연결로 지연 시간을 최소화하고 효율성을 높입니다.
- **WireGuard 기반**: 고성능 암호화 프로토콜 WireGuard를 사용하여 빠르고 안전한 연결.
- **중앙 조정 서버**: Tailscale은 연결 설정을 위해 DERP(Distributed Encrypted Relay Protocol) 서버를 사용하지만, 데이터 전송은 주로 P2P로 이루어짐.
- **제로 트러스트 보안**: 모든 연결은 암호화되며, ACL을 통해 권한 관리.

## Tailscale 설치 및 구성, 엔드포인트 확인 방법

Tailscale은 간단한 설치와 구성으로 빠르게 사용할 수 있습니다. 아래는 설치 및 엔드포인트 확인 방법입니다.

### 1. 설치 및 구성
- **계정 생성**:
  1. [tailscale.com](https://tailscale.com)에 접속.
  2. **Get Started** 클릭 후 Google, Microsoft, GitHub 등 SSO 계정으로 로그인.
  3. 개인용 무료 플랜(최대 3명 사용자, 100대 장치) 선택.
- **클라이언트 설치**:
  - **Windows/macOS**: [다운로드 페이지](https://tailscale.com/download)에서 설치 파일 실행 후 로그인.
  - **Linux (Ubuntu)**:
    ```bash
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update && sudo apt install tailscale
    sudo tailscale up
    ```
  - **iOS/Android**: App Store/Google Play에서 “Tailscale” 설치 후 로그인.
- **네트워크 설정**:
  - 로그인 후 장치가 tailnet에 자동 추가.
  - **MagicDNS** 활성화: 관리 콘솔([login.tailscale.com](https://login.tailscale.com))의 **DNS** 탭에서 확인. 장치 이름(예: `my-pc.tailnet`)으로 연결 가능.
  - **인증 키 사용**: 서버의 경우 관리 콘솔의 **Keys** 탭에서 인증 키 생성 후:
    ```bash
    sudo tailscale up --authkey=<your-auth-key>
    ```

### 2. 엔드포인트 확인 방법
- **관리 콘솔**:
  - [login.tailscale.com](https://login.tailscale.com)의 **Machines** 탭에서 장치 목록, Tailscale IP(100.x.y.z), MagicDNS 이름 확인.
- **명령어**:
  - `tailscale status`: 연결된 장치 목록과 상태 표시.
  - `tailscale netcheck`: 네트워크 연결 상태 및 엔드포인트 정보 확인.
  - `tailscale ping <장치 이름>`: 특정 장치와의 연결 테스트(예: `tailscale ping my-laptop.tailnet`).
- **예시 출력** (tailscale status):
  ```bash
  100.64.1.2 my-laptop user@domain.com Linux   online
  100.64.1.3 my-server user@domain.com Linux   online
  ```

## 포트 제어 및 관리

Tailscale은 모든 포트를 암호화된 터널로 연결하지만, 특정 포트를 제어할 수 있습니다.

### 1. 기본 포트 설정
- **UDP 41641**: Tailscale의 기본 포트로, P2P 연결에 사용. 방화벽에서 열어야 함.
- **HTTPS 443**: DERP 서버를 통한 릴레이 연결에 사용.

### 2. 접근 제어(ACL)로 포트 관리
- **관리 콘솔** ([login.tailscale.com](https://login.tailscale.com))의 **Access Controls** 탭에서 ACL 설정.
- **예시** (SSH 포트 22만 허용):
  ```json
  {
    "acls": [
      {"action": "accept", "src": ["user@example.com"], "dst": ["tag:server:22"]}
    ]
  }
  ```
- **설정 방법**:
  1. 장치에 태그 추가(예: `tag:server`).
  2. ACL 파일에 특정 포트 허용 규칙 작성.
  3. 관리 콘솔에서 저장 및 적용.

### 3. 방화벽 설정
- 로컬 방화벽에서 Tailscale 트래픽 허용:
  - **Linux (ufw)**:
    ```bash
    sudo ufw allow 41641/udp
    sudo ufw allow 22/tcp
    ```
  - **Windows**: Windows Defender 방화벽에서 Tailscale 실행 파일 예외 추가.

## 다른 단말에서의 접속 방법

Tailscale은 다양한 단말에서 간편하게 접속할 수 있도록 설계되었습니다.

### 1. 접속 방법
- **동일 tailnet 내 장치**:
  - Tailscale IP 또는 MagicDNS 이름 사용.
  - 예: SSH 접속:
    ```bash
    ssh user@my-server.tailnet
    ```
  - 파일 공유: SCP 또는 SMB로 Tailscale IP 사용.
- **모바일 장치**:
  - iOS/Android 앱 설치 후 로그인.
  - 앱에서 장치 목록 확인 후 접속(예: SSH 클라이언트로 `my-server.tailnet` 연결).
- **서브넷 라우터**:
  - Tailscale이 설치되지 않은 장치(예: 프린터) 접근:
    1. 한 장치에서 서브넷 라우팅 활성화:
       ```bash
       sudo tailscale up --advertise-routes=192.168.1.0/24
       ```
    2. 관리 콘솔의 **Routes** 탭에서 승인.
    3. 다른 단말에서 로컬 IP(예: `192.168.1.100`)로 접근.

### 2. 출구 노드 사용
- 특정 장치를 통해 인터넷 트래픽 라우팅:
  1. 관리 콘솔에서 출구 노드 지정.
  2. 클라이언트에서:
     ```bash
     sudo tailscale up --exit-node=my-server.tailnet
     ```

## 기타 보안 사항

Tailscale은 기본적으로 높은 보안을 제공하지만, 추가 설정으로 보안을 강화할 수 있습니다.

### 1. Tailnet Lock
- **기능**: 새 장치 추가 시 기존 장치의 승인 요구.
- **설정**: 관리 콘솔의 **Security** 탭에서 활성화.
- **사용 사례**: 팀 환경에서 무단 장치 추가 방지.

### 2. SSO 및 2FA
- SSO 제공자(Google, Microsoft 등)에서 2FA(2단계 인증)를 활성화하여 계정 보안 강화.
- 관리 콘솔의 **Users** 탭에서 사용자별 인증 관리.

### 3. ACL로 세부 권한 관리
- 특정 사용자 또는 태그에 대한 접근 제한.
- 예: 개발자만 서버의 특정 포트에 접근:
  ```json
  {
    "ac这一次
  {
    "acls": [
      {"action": "accept", "src": ["tag:dev"], "dst": ["tag:server:8080"]}
    ]
  }
  ```

### 4. 로그 및 모니터링
- 관리 콘솔의 **Logs** 탭에서 연결 기록 확인.
- 이상 행위 감지 시 즉시 ACL 수정 또는 장치 차단.

### 5. 정기 업데이트
- `tailscale update`로 최신 버전 유지.
- 취약점 패치 및 성능 개선 적용.

## 결론

Tailscale은 WireGuard 기반의 매쉬 VPN으로, **핵심 개념**(Tailnet, MagicDNS, WireGuard 등)을 통해 간단하고 안전한 네트워크를 제공합니다. **설치 및 구성**은 직관적이며, **엔드포인트 확인**과 **포트 제어**를 통해 세밀한 관리 가능. **다른 단말 접속**은 MagicDNS와 서브넷 라우팅으로 간편하며, **보안 설정**(Tailnet Lock, ACL, 2FA 등)으로 데이터를 보호할 수 있습니다. Tailscale을 처음 사용하는 사용자는 기본 설정과 ACL을 단계적으로 적용하며 자신만의 안전한 네트워크를 구축해 보세요.

## 추가 리소스

* [Tailscale 공식 사이트](https://tailscale.com/)
* [Tailscale 문서](https://tailscale.com/docs)
* [Tailscale 지원](https://tailscale.com/contact/support)
* [Reddit Tailscale 커뮤니티](https://www.reddit.com/r/Tailscale)