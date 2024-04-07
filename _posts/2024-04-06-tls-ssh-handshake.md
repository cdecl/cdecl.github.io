---
title: TLS와 SSH 프로토콜 기능

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - tls
  - ssh
  - https
---
 
TLS와 SSH 프로토콜의 서버-클라이언트 협상 항목과 기능 비교

{% raw %}


## TLS와 SSH 프로토콜 정의

### 1. TLS(Transport Layer Security) 

TLS 프로토콜은 인터넷 상에서 안전한 통신을 위해 사용되는 암호화 프로토콜 
TLS는 SSL(Secure Sockets Layer) 프로토콜의 후속 버전으로, 웹 브라우저와 웹 서버 사이의 통신을 암호화하여 데이터 보안을 강화하는데 사용 

#### TLS 프로토콜의 주요 기능

- **암호화**: 클라이언트와 서버 간의 통신 내용을 암호화하여 보호
- **인증**: 서버의 신원을 인증하고, 클라이언트 인증도 지원
- **무결성**: 전송 데이터의 변조를 방지

> TLS는 HTTP, SMTP, IMAP 등 다양한 프로토콜의 보안 계층으로 사용되며, 현재 TLS 1.2와 TLS 1.3 버전이 널리 사용되고 있습니다.

### 2. SSH(Secure Shell) 

SSH 프로토콜은 네트워크 상에서 안전한 원격 액세스와 파일 전송을 제공하는 암호화 프로토콜 
SSH는 기존의 Telnet, rlogin 등의 비보안 프로토콜을 대체하여 원격 시스템에 안전하게 접속할 수 있도록 함

#### SSH 프로토콜의 주요 기능 

- **암호화**: 클라이언트와 서버 간의 통신 내용을 암호화하여 보호
- **인증**: 서버의 신원을 인증하고, 클라이언트 인증도 지원
- **무결성**: 전송 데이터의 변조를 방지
- **포트 전달**: 방화벽을 우회하여 안전한 통신 터널을 만듦

> SSH는 주로 Linux/Unix 시스템의 원격 관리, 파일 전송, 터널링 등에 사용되며, SSH-1과 SSH-2 두 가지 주요 버전이 존재  

> 이와 같이 TLS와 SSH 프로토콜은 각자의 고유한 특징을 가지고 있으며, 인터넷 상의 다양한 응용 분야에서 안전한 통신을 제공하는 핵심 기술 중 하나



## TLS와 SSH 프로토콜의 서버-클라이언트 협상 항목과 기능 비교

**TLS**와 **SSH** 프로토콜은 안전한 통신을 위해 서버와 클라이언트 간에 다양한 협상 과정을 거칩니다. 

### 1. 프로토콜 버전 협상
- **TLS**: TLS 1.0, 1.1, 1.2, 1.3 등의 버전 협상
- **SSH**: SSH-1 및 SSH-2 버전 협상

### 2. 암호화 알고리즘 협상
- **TLS**:
  - 대칭키 암호화(AES, ChaCha20 등)
  - MAC(Message Authentication Code) 알고리즘(HMAC-SHA256 등)
- **SSH**:
  - 대칭키 암호화(AES, Blowfish 등)
  - MAC 알고리즘(HMAC-SHA1, HMAC-MD5 등)

### 3. 키 교환 알고리즘 협상
- **TLS**: RSA, ECDHE 등의 키 교환 방식
- **SSH**: Diffie-Hellman, ECDH(Elliptic Curve Diffie-Hellman) 등의 키 교환 방식

### 4. 압축 방식 협상
- **TLS**: DEFLATE, NULL(압축 없음)
- **SSH**: zlib, none(압축 없음)

### 5. 세션 관리
- **TLS**: 새로운 세션 생성 / 기존 세션 재사용 / 세션 ID, 타임아웃 협상
- **SSH**: 없음(초기화 벡터(IV) 사용)

### 6. 인증 방식 협상
- **TLS**: 클라이언트 인증(인증서, 사용자명/비밀번호) / 서버 인증(인증서)
- **SSH**: 비밀번호 인증 / 공개키 인증 / 호스트 기반 인증 / Kerberos 인증

### 7. 확장 기능 협상
- **TLS**: SNI(Server Name Indication), 중간 단계 업데이트 등
- **SSH**: 포트 포워딩, X11 포워딩, 에이전트 전달, 환경변수 전달 등

---

## 협상 항목 및 기능 비교

| 협상 항목 | TLS | SSH |
| --- | --- | --- |
| **프로토콜 버전** | - TLS 1.0, 1.1, 1.2, 1.3 등의 버전 협상 | - SSH-1 및 SSH-2 버전 협상 |
| **암호화 알고리즘** | - 대칭키 암호화(AES, ChaCha20 등) | - 대칭키 암호화(AES, Blowfish 등) |
|  | - MAC(Message Authentication Code) 알고리즘(HMAC-SHA256 등) | - MAC 알고리즘(HMAC-SHA1, HMAC-MD5 등) |
| **키 교환 알고리즘** | - RSA, ECDHE 등의 키 교환 방식 | - Diffie-Hellman, ECDH(Elliptic Curve Diffie-Hellman) 등의 키 교환 방식 |
| **압축 방식** | - DEFLATE, NULL(압축 없음) | - zlib, none(압축 없음) |
| **세션 관리** | - 새로운 세션 생성 | - 없음(초기화 벡터(IV) 사용) |
|  | - 기존 세션 재사용 |  |
|  | - 세션 ID, 타임아웃 협상 |  |
| **인증 방식** | - 클라이언트 인증(인증서, 사용자명/비밀번호) | - 비밀번호 인증 |
|  | - 서버 인증(인증서) | - 공개키 인증 |
|  |  | - 호스트 기반 인증 |
|  |  | - Kerberos 인증 |
| **확장 기능** | - SNI(Server Name Indication), 중간 단계 업데이트 등 | - 포트 포워딩, X11 포워딩 |
|  |  | - 에이전트 전달, 환경변수 전달 |

{% endraw %}
