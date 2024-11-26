---
title: TLS와 SSH 프로토콜 기능
last_modified_at: 2024-11-16

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

TLS 프로토콜은 인터넷 상에서 안전한 통신을 위해 사용되는 암호화 프로토콜입니다.
TLS는 SSL(Secure Sockets Layer) 프로토콜의 후속 버전으로, 웹 브라우저와 웹 서버 사이의 통신을 암호화하여 데이터 보안을 강화하는데 사용됩니다.

#### TLS 프로토콜의 주요 기능

- **암호화**: 클라이언트와 서버 간의 통신 내용을 암호화하여 보호
- **인증**: 서버의 신원을 인증하고, 클라이언트 인증도 지원
- **무결성**: 전송 데이터의 변조를 방지

> TLS는 HTTP, SMTP, IMAP 등 다양한 프로토콜의 보안 계층으로 사용됩니다. TLS 1.0/1.1은 더 이상 권장되지 않으며, 현재는 TLS 1.2와 가장 최신 표준인 TLS 1.3이 널리 사용되고 있습니다. 특히 TLS 1.3은 이전 버전 대비 보안성과 성능이 크게 향상되었습니다.

### 2. SSH(Secure Shell) 

SSH 프로토콜은 네트워크 상에서 안전한 원격 액세스와 파일 전송을 제공하는 암호화 프로토콜입니다.
SSH는 기존의 Telnet, rlogin 등의 비보안 프로토콜을 대체하여 원격 시스템에 안전하게 접속할 수 있도록 합니다.

#### SSH 프로토콜의 주요 기능 

- **암호화**: 클라이언트와 서버 간의 통신 내용을 암호화하여 보호
- **인증**: 서버의 신원을 인증하고, 클라이언트 인증도 지원
- **무결성**: 전송 데이터의 변조를 방지
- **포트 전달**: 방화벽을 우회하여 안전한 통신 터널을 만듦

> SSH는 주로 Linux/Unix 시스템의 원격 관리, 파일 전송, 터널링 등에 사용됩니다. SSH-1은 심각한 보안 취약점이 있어 더 이상 사용되지 않으며, 현재는 SSH-2가 표준 프로토콜로 사용됩니다.

## TLS와 SSH 프로토콜의 서버-클라이언트 협상 항목과 기능 비교

**TLS**와 **SSH** 프로토콜은 안전한 통신을 위해 서버와 클라이언트 간에 다양한 협상 과정을 거칩니다. 

### 1. 프로토콜 버전 협상
- **TLS**: TLS 1.2, TLS 1.3 버전 협상 (TLS 1.0/1.1은 더 이상 권장되지 않음)
- **SSH**: SSH-2 버전 (SSH-1은 보안 취약점으로 더 이상 사용되지 않음)

### 2. 암호화 알고리즘 협상
- **TLS**:
 - 대칭키 암호화: AES-GCM, ChaCha20-Poly1305 (AEAD 암호화 방식)
 - MAC 알고리즘: HMAC-SHA256, HMAC-SHA384
- **SSH**:
 - 대칭키 암호화: AES-CTR, AES-GCM
 - MAC 알고리즘: HMAC-SHA256, HMAC-SHA512
 
> MAC(Message Authentication Code) 알고리즘: 메시지의 무결성을 검증하기 위해 사용되는 암호화 기술

### 3. 키 교환 알고리즘 협상
- **TLS**: 
 - TLS 1.3: ECDHE, DHE (정적 RSA 키 교환 제거됨)
 - TLS 1.2: ECDHE, DHE, RSA
- **SSH**: Diffie-Hellman, ECDH(Elliptic Curve Diffie-Hellman)

### 4. 압축 방식 협상
- **TLS**: DEFLATE, NULL(압축 없음)
- **SSH**: zlib, none(압축 없음)

### 5. 세션 관리
- **TLS**: 
 - 새로운 세션 생성
 - 기존 세션 재사용
 - 세션 ID, 타임아웃 협상
- **SSH**: 없음(초기화 벡터(IV) 사용)

### 6. 인증 방식 협상
- **TLS**: 
 - 클라이언트 인증: 인증서, 사용자명/비밀번호
 - 서버 인증: 인증서
- **SSH**: 
 - 비밀번호 인증
 - 공개키 인증
 - 호스트 기반 인증
 - Kerberos 인증

### 7. 확장 기능 협상
- **TLS**: SNI(Server Name Indication), ALPN(Application-Layer Protocol Negotiation)
- **SSH**: 
 - 포트 포워딩
 - X11 포워딩
 - 에이전트 전달
 - 환경변수 전달

---

## 협상 항목 및 기능 비교

| 협상 항목            | TLS                                                   | SSH                                                             |
| -------------------- | ----------------------------------------------------- | --------------------------------------------------------------- |
| 프로토콜 버전    | • TLS 1.2, 1.3                                        | • SSH-2                                                         |
| 암호화 알고리즘  | • AES-GCM<br>• ChaCha20-Poly1305<br>• HMAC-SHA256/384 | • AES-CTR<br>• AES-GCM<br>• HMAC-SHA256/512                     |
| 키 교환 알고리즘 | • ECDHE<br>• DHE (TLS 1.3)<br>• RSA (TLS 1.2)         | • Diffie-Hellman<br>• ECDH                                      |
| 압축 방식        | • DEFLATE<br>• NULL                                   | • zlib<br>• none                                                |
| 세션 관리        | • 세션 생성<br>• 세션 재사용<br>• 세션 ID/타임아웃    | • IV 사용                                                       |
| 인증 방식        | • 클라이언트 인증서<br>• 서버 인증서                  | • 비밀번호 인증<br>• 공개키 인증<br>• 호스트 기반<br>• Kerberos |
| 확장 기능        | • SNI<br>• ALPN                                       | • 포트 포워딩<br>• X11 포워딩<br>• 에이전트/환경변수 전달       |

{% endraw %}
