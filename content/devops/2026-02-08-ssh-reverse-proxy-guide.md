---
title: "SSH 리버스 프록시(Reverse Proxy) 네트워크 구성: 설정, 주의 사항, 운영 팁"
tags:
  - devops
  - ssh
  - reverse-proxy
  - networking
  - tunneling
  - security
  - bastion
  - firewall
---

작성일: 2026-02-08

SSH 리버스 프록시는 **외부에서 내부로 직접 접근할 수 없는 환경**에서 유용한 연결 방식입니다. 내부 서버가 외부 서버로 **역방향 터널을 먼저 열어두고**, 외부 사용자가 그 터널을 통해 내부 서비스에 접근하는 구조입니다. DevOps 환경에서 운영할 때 필요한 구성, 주의 사항, 네트워크 프록시 관점을 정리합니다.

---

## 1. 개념 정리: SSH 리버스 프록시

- 일반 SSH 포워딩(로컬 포워딩): **로컬 -> 원격**
- 리버스 포워딩(Reverse): **원격 -> 로컬(내부)**

리버스 포워딩은 내부 서버가 먼저 외부(중계) 서버에 접속하고, 외부에서 그 연결을 통해 내부 서비스에 접근하는 방식입니다.

---

## 2. 기본 네트워크 구성

### 구성 예시

- 내부 서버: `internal01` (NAT 뒤, 외부 직접 접근 불가)
- 외부 중계 서버: `bastion` (공인 IP 보유)
- 접속자: `operator`

```
operator -> bastion:2222 -> internal01:22
```

### 구성 예시 (다양한 패턴)

1. 내부 SSH 접근만 필요할 때

```
operator -> bastion:2222 -> internal01:22
```

```bash
# internal01에서 bastion으로 터널 생성
ssh -N -R 2222:localhost:22 user@bastion
```

2. 내부 웹 서비스(HTTP/HTTPS) 노출

```
operator -> bastion:8080 -> internal01:80
operator -> bastion:8443 -> internal01:443
```

```bash
# 내부 웹 포트 2개를 각각 리버스 포워딩
ssh -N -R 8080:localhost:80 -R 8443:localhost:443 user@bastion
```

3. 여러 내부 서버를 한 bastion으로 수집

```
operator -> bastion:2222 -> internal01:22
operator -> bastion:2223 -> internal02:22
operator -> bastion:2224 -> internal03:22
```

```bash
# 각 내부 서버에서 서로 다른 포트로 터널 생성
ssh -N -R 2222:localhost:22 user@bastion   # internal01
ssh -N -R 2223:localhost:22 user@bastion   # internal02
ssh -N -R 2224:localhost:22 user@bastion   # internal03
```

4. 내부 특정 서비스만 제한적으로 공개

```
operator -> bastion:9300 -> internal01:9300
```

```bash
# 내부 서비스 포트만 외부에 노출
ssh -N -R 9300:localhost:9300 user@bastion
```

5. bastion 내부에서만 접근 가능한 로컬 바인딩

```
bastion:127.0.0.1:2222 -> internal01:22
```

```bash
# bastion 로컬에만 바인딩(기본 동작)
ssh -N -R 2222:localhost:22 user@bastion
```

6. 점프 호스트 체인 (내부에서 다시 내부로)

```
operator -> bastion -> internal01:22 -> internal-db:5432
```

```bash
# internal01에서 DB로 로컬 포워딩을 만들고
ssh -N -L 15432:internal-db:5432 internal01

# internal01의 로컬 포트를 bastion으로 리버스 포워딩
ssh -N -R 15432:localhost:15432 user@bastion
```

### 내부 서버에서 터널 생성

```bash
ssh -N -R 2222:localhost:22 user@bastion
```

- `-R 2222:localhost:22`
  - bastion의 2222 포트를 내부 서버의 22번으로 연결
- `-N`
  - 쉘 없이 터널만 유지

### 외부 접속자 입장

```bash
ssh -p 2222 internal_user@bastion
```

이렇게 하면 bastion의 2222 포트가 내부 서버의 22로 연결됩니다.

---

## 3. 실무 설정 포인트

### 3.1 `sshd_config`에서 리버스 포워딩 허용

bastion 서버의 `/etc/ssh/sshd_config`에 다음 설정이 필요할 수 있습니다.

```
AllowTcpForwarding yes
GatewayPorts no
```

- `AllowTcpForwarding yes`: 포워딩 허용
- `GatewayPorts no`: 기본적으로 127.0.0.1에만 바인딩
- 위 항목은 **기본값이지만 보통 주석 처리**되어 있습니다. 즉, 명시적으로 설정하지 않아도 기본 동작은 유지되지만, 운영 환경에서는 의도를 분명히 하기 위해 주석을 해제해 **명시적으로 선언**하는 경우가 많습니다.

외부 클라이언트가 bastion의 퍼블릭 IP로 접속할 수 있어야 한다면:

```
GatewayPorts yes
```

단, 보안 리스크가 커지므로 접근 제어가 반드시 필요합니다.

---

### 3.2 시스템 서비스로 터널 유지

운영에서는 `autossh` 또는 systemd를 이용해 터널을 지속적으로 유지합니다.

```bash
autossh -M 0 -N -R 2222:localhost:22 user@bastion
```

- `-M 0`: 모니터링 포트 비활성화 (단순 keepalive)
- `ServerAliveInterval`, `ServerAliveCountMax` 옵션 권장

---

## 4. 주의 사항 (운영 리스크)

1. **포트 충돌**
   - bastion에 동일한 리버스 포워딩 포트가 여러 개 잡히면 충돌

2. **보안 범위 확장**
   - `GatewayPorts yes`는 외부 전체에 포트를 노출
   - 반드시 방화벽/ACL/IP 제한 필요

3. **인증 강화 필요**
   - 비밀번호 인증 비활성화
   - 키 기반 인증 + 제한된 계정 사용

4. **로그 추적성**
   - bastion 로그와 내부 서버 로그를 함께 보관해야 실제 접속 추적 가능

---

## 5. 네트워크 프록시 관점 정리

SSH 리버스 포워딩은 **L4 TCP 터널**입니다.

- HTTP 프록시처럼 헤더를 이해하거나 수정하지 않음
- SSL/TLS 종료 지점이 SSH 터널 밖에 있음
- 따라서 **L7 로깅/보안 검사**는 별도 구성 필요
- 터널 내부의 TCP 핸드셰이크(SYN, SYN-ACK, ACK)는 **SSH 세션 내부에서 캡슐화**되어 흐르므로, bastion은 패킷 내용을 해석하지 않고 **바이트 스트림만 중계**합니다.

필요 시:

- bastion에서 Nginx/HAProxy를 추가 배치해 L7 프록시 적용
- SSH는 터널만 유지하고 실제 트래픽은 L7 레이어에서 관측

---

## 6. 운영 팁

- 터널 포트는 **고정된 포트 정책**으로 관리 (예: 팀/서버별 포트 범위 할당)
- `~/.ssh/config`에 전용 Host 블록을 만들어 관리
- 무조건 `localhost`로 바인딩하고, 필요할 때만 `GatewayPorts yes`
- 헬스체크 스크립트를 통해 터널 유실 감지 후 자동 재연결

---

## 정리

SSH 리버스 프록시는 **외부에서 직접 접근할 수 없는 내부 환경을 열어주는 강력한 도구**입니다. 하지만 잘못 구성하면 **외부에 불필요한 포트가 노출**되고, 보안 사고로 이어질 수 있습니다. DevOps 환경에서는 반드시 포워딩 범위, 인증 정책, 로그 관리까지 포함해 설계해야 합니다.
