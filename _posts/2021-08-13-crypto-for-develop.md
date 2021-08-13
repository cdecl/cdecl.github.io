---
title: 암호화 지식 (개발자)

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - crypto
  - aes
---


암호화 알고리즘 사용을 위한 기본 지식 

## 블록 알고리즘 고려사항 
- 대칭형 vs 비대칭형
- 알고리즘 종류
- 알고리즘 운영 모드
- 패딩종류
- 인코딩 (텍스트 암호화의 경우)


### 대칭형 vs 비대칭형 
- 대칭형 : 암호화 할때 사용하는 키와 복호화 할때 사용하는 키가 동일한 암호화 기법
- 비대칭형 : 암호화 키와 복호화 키가 다르다, 대칭형 암호에 비해 현저하게 느리다는 문제점 (예,공개키 기반)

### 대칭형 블록 알고리즘 
블록 단위로 암호화 하는 대칭키 암호 시스템

### 대칭형 블록 알고리즘 종류 

#### DES 
가장 오래되고, 세계적으로 가장 널리 사용되는 고전적 암호화 알고리즘이다. 파일이나 패킷을 암호화할 때 많이 사용된다. 하지만, 64비트 입력 블록과 56비트 짧은 비밀키를 사용하기 때문에, 더 이상 안전하지 않다고 간주하고 있다. 그러나, 국가 기밀을 다룰 정도로 극히 중요한 보안이 아니라면, 여전히 가장 널리 사용되는 알고리즘이다.

> `56비트` 
 
#### 3-DES
DES를 3번 반복해서 암호화한다. 보안성이 향상되고, 그 만큼 성능은 떨어진다.

> 2키를 사용하는 경우 `112비트`, 3키를 사용하는 경우 `168비트`의 키 길이
 
#### AES
미국 NIST에서 공모해서 표준화한 새로운 알고리즘이다. 128비트 입력 블록을 도입함으로써, 보안성을 향상했으며, 최근에 세계적으로 널리 사용되는 알고리즘이다.

> `128/192/256비트` 

#### SEED  
KISA 주관으로 ETRI와 함께 국내에서 만들어진 알고리즘이다.   
128비트 입력 블록을 사용하고 있고, 국제 표준에 부합하는 알고리즘이다.

> `128비트` 

## 대칭형 블록 알고리즘 운영 모드 

#### ECB(Electronic codebook)
평문을 일정 크기의 블록으로 나누어서 처리, 각 블록은 동일한 키로 암호

#### CBC(Cipher-block chaining)
평문 블록과 바로 직전의 암호블록을 XOR한 것. 첫번째 암호 블록을 위해 초기 벡터 IV 값 사용

#### 기타
- PCBC(Propagating cipher-block chaining)
- CFB(Cipher feedback)
- OFB(Output feedback)
- CTR(Counter)


## 대칭형 블록 알고리즘 : 패딩(Padding) 종류
- NO_PADDING : 패딩 없음
- ZEROS_PADDING : NULL(0) 으로 패딩 
- PKCS_PADDING : 패딩되는 바이트의 수의 같은 값으로 모두 패딩
- ONE_AND_ZEROS_PADDING :  ONE_AND_ZEROS_PADDING to use 0x80 instead 0x01 as padding

> DEFAULT_PADDING : DEFAULT_PADDING means PKCS_PADDING 

