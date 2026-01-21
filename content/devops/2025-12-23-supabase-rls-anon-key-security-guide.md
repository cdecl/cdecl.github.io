---
title: 'Supabase RLS와 anon 키: RLS Disabled in Public, 백엔드 개발자를 위한 보안 가이드'
tags:
  - Supabase
  - PostgreSQL
  - Security
  - RLS
  - Backend
---
Supabase는 편리한 기능과 자동화된 API 덕분에 많은 개발자에게 사랑받고 있지만, 간혹 대시보드에 나타나는 "RLS Disabled" 경고는 백엔드 개발자들을 혼란에 빠뜨리곤 합니다. "나는 백엔드에서만 안전하게 통신하는데, 이게 왜 문제지?"라고 생각했다면 이 글이 명쾌한 해답을 드릴 것입니다. 이 글에서는 RLS와 anon 키의 관계를 명확히 이해하고, 백엔드 중심 프로젝트에서 RLS를 어떻게 활용해야 하는지에 대한 모범 사례를 제시합니다.

## 1. 문제 상황: "RLS Disabled in Public" 경고의 의미

Supabase 대시보드에서 `public.users` 또는 `public.notes`와 같은 테이블에 대해 **RLS Disabled** 경고를 마주하는 것은 생각보다 흔한 일입니다. 이 경고의 진짜 의미는 무엇일까요?

- **원인**: Supabase는 `public` 스키마에 생성된 테이블을 PostgREST를 통해 외부에서 접근 가능한 API URL로 자동 노출합니다.
- **진단**: 경고의 핵심은 "외부로 향하는 API 문은 열려 있는데, 정작 테이블 자체에는 아무런 보안 정책(RLS)이 없어 누구나 데이터를 열람하거나 조작할 수 있는 위험한 상태"라는 뜻입니다.

백엔드 서버에서만 DB에 접근한다고 해서 이 경고를 무시해서는 안 됩니다. 우리가 사용하지 않는 '앞문'이 활짝 열려있는 것과 같기 때문입니다.

## 2. 핵심 개념: 용어 정리

이 문제를 제대로 이해하려면 세 가지 핵심 개념을 알아야 합니다.

### ① anon 키 (Anonymous Key)

- **정체**: 프론트엔드(클라이언트) 환경에서 데이터베이스에 직접 접속하기 위해 설계된 **공개용** 키입니다.
- **위험성**: 이름처럼 익명 사용자를 위한 키이므로, 웹사이트의 소스 코드나 브라우저의 네트워크 탭을 통해 누구나 쉽게 획득할 수 있습니다. 만약 RLS가 비활성화되어 있다면, 이 `anon` 키 하나만으로 해커는 당신의 모든 데이터를 조회, 수정, 삭제할 수 있습니다.

### ② RLS (Row Level Security)

- **정체**: PostgreSQL 데이터베이스의 각 행(Row) 단위로 정교한 접근 권한을 제어하는 강력한 보안 엔진입니다.
- **역할**: "이 요청을 보낸 사용자가 이 데이터 행의 주인인가?" 혹은 "이 사용자가 이 데이터를 읽거나 쓸 자격이 있는가?"를 데이터베이스 수준에서 직접 검사하여 인가되지 않은 접근을 원천 차단합니다.

### ③ service_role 키 (Service Role Key)

- **정체**: 백엔드 서버 환경에서 사용하는 **관리자용 마스터 키**입니다. 절대로 외부에 노출되어서는 안 됩니다.
- **특징**: 이 키의 가장 중요한 특징은 **RLS를 우회(Bypass)**한다는 점입니다. 즉, RLS 정책이 아무리 촘촘하게 설정되어 있어도 `service_role` 키를 사용한 요청은 모든 데이터에 제약 없이 접근할 수 있습니다.

## 3. RLS, 왜 필요한가? (백엔드 개발자의 오해)

백엔드 개발자들 사이에서 가장 흔한 질문은 다음과 같습니다.

> **Q: "저는 백엔드 서버에서 `service_role` 키나 DB connection string으로만 안전하게 통신하는데, 굳이 RLS를 켤 필요가 있나요?"**

**A: 네, 반드시 켜야 합니다.**

백엔드와 DB 사이의 통신 채널이 안전한 것과 별개로, Supabase는 기본적으로 `anon` 키를 통한 **'사용하지 않는 정문'**을 열어두고 있습니다. RLS를 활성화하는 것은 바로 이 정문을 잠그고, 오직 우리가 통제하는 백엔드라는 '뒷문'으로만 출입하도록 강제하는 행위입니다.

## 4. 백엔드 중심 운영을 위한 RLS 보안 전략 (Best Practice)

`anon` 키를 사용할 계획이 없는 백엔드 중심 프로젝트라면, 보안 설정은 매우 간단하고 명확합니다.

### 단계 1: RLS 활성화 (앞문 잠그기)
가장 먼저 할 일은 사용하지 않을 `anon` 키의 접근 경로를 원천 차단하는 것입니다. 별도의 정책(Policy)을 만들 필요조차 없습니다. RLS만 활성화하면, 기본적으로 'DENY ALL'(모든 요청 거부) 정책이 적용되어 모든 익명 요청이 자동으로 차단됩니다.

```sql
-- RLS를 활성화할 대상 테이블 지정
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- 테이블에 강제로 RLS 적용 (이미 활성화된 경우에도 확인차 실행)
ALTER TABLE public.users FORCE ROW LEVEL SECURITY;
ALTER TABLE public.notes FORCE ROW LEVEL SECURITY;
```

이 두 줄의 SQL만으로 `anon` 키를 사용한 모든 API 요청은 실패하게 됩니다.

### 단계 2: 백엔드는 기존 방식 그대로 운영
백엔드 서버에서는 기존처럼 `service_role` 키 또는 데이터베이스 비밀 연결 문자열을 그대로 사용하면 됩니다. 이 키들은 RLS를 우회하므로, RLS 활성화 여부와 관계없이 기존 백엔드 로직과 성능에 **아무런 영향도 주지 않습니다.**

### 단계 3: 심층 방어 (Defense in Depth)
RLS를 켜두면 얘기치 못한 상황에서 최후의 방어선 역할을 합니다. 예를 들어, 백엔드 서버가 해킹당하거나 코드 로직에 실수가 생겨 의도치 않은 데이터 변경이 발생하려 할 때, 데이터베이스 수준에 설정된 RLS가 2차적인 방어벽이 되어줄 수 있습니다.

## 5. 프론트엔드 운영을 위한 RLS 정책 수립 (anon 키 활용)

백엔드만 사용하는 경우와 달리, 프론트엔드에서 Supabase를 직접 호출하려면 `anon` 키에 대한 접근을 허용해야 합니다. 이는 RLS를 끄는 것이 아니라, **어떤 조건에서 `anon` 키의 요청을 허용할지**에 대한 구체적인 정책(Policy)을 정의하는 것을 의미합니다.

### 5.1. RLS 정책의 기본 구조: `USING`과 `WITH CHECK`

RLS 정책은 크게 `USING` 절과 `WITH CHECK` 절로 구성됩니다.

- **`USING` (읽기 접근 제어)**: `SELECT` 쿼리가 실행될 때 적용됩니다. 이 조건이 `true`를 반환하는 행(Row)만 사용자에게 보입니다.
- **`WITH CHECK` (쓰기 접근 제어)**: `INSERT` 또는 `UPDATE` 쿼리가 실행될 때 적용됩니다. 이 조건이 `true`를 반환해야만 데이터의 삽입 또는 수정이 허용됩니다. `DELETE`는 `USING` 절의 규칙을 따릅니다.

### 5.2. 정책 예시 1: 인증된 사용자는 자신의 데이터만 관리

가장 흔한 시나리오입니다. 예를 들어 `profiles` 테이블이 있고, 사용자는 자신의 프로필만 보고 수정할 수 있어야 합니다.

```sql
-- 이 정책은 'profiles' 테이블에 적용됩니다.
CREATE POLICY "Users can manage their own profile."
-- 어떤 작업에 대해? SELECT, INSERT, UPDATE, DELETE 모두
ON public.profiles FOR ALL
-- 누가 접근할 때? 인증된 모든 사용자 (anon 역할 아님)
TO authenticated
-- 읽기 조건: 행의 id가 현재 로그인한 사용자의 id와 같아야 함
USING ( auth.uid() = id )
-- 쓰기 조건: 삽입/수정하려는 행의 id가 현재 로그인한 사용자의 id와 같아야 함
WITH CHECK ( auth.uid() = id );
```

`auth.uid()`는 Supabase가 제공하는 헬퍼 함수로, 요청을 보낸 사용자의 고유 ID(UUID)를 반환합니다. 이 정책 덕분에 사용자는 `anon` 키로 API를 호출하더라도 데이터베이스 수준에서 자신의 데이터에만 안전하게 접근할 수 있습니다.

### 5.3. 정책 예시 2: 공개 데이터와 개인 데이터 혼합

블로그 게시물을 생각해보겠습니다. 모든 게시물(`posts`)은 누구나 읽을 수 있지만, 작성은 인증된 사용자만 가능하고, 수정/삭제는 작성자 본인만 가능해야 합니다.

```sql
-- 1. 모든 사용자가 게시물을 읽을 수 있도록 허용하는 정책 (SELECT)
CREATE POLICY "Public can read all posts."
ON public.posts FOR SELECT
TO public
USING ( true ); -- 'true'는 항상 참이므로 모든 행을 볼 수 있음

-- 2. 인증된 사용자만 게시물을 작성할 수 있도록 허용하는 정책 (INSERT)
CREATE POLICY "Authenticated users can create posts."
ON public.posts FOR INSERT
TO authenticated
WITH CHECK ( true ); -- 인증만 되었다면 누구나 작성 가능

-- 3. 작성자 본인만 게시물을 수정할 수 있도록 허용하는 정책 (UPDATE)
CREATE POLICY "Owners can update their own posts."
ON public.posts FOR UPDATE
TO authenticated
USING ( auth.uid() = user_id ) -- 수정할 행을 찾는 조건
WITH CHECK ( auth.uid() = user_id ); -- 수정할 내용이 제약조건을 만족하는지 확인

-- 4. 작성자 본인만 게시물을 삭제할 수 있도록 허용하는 정책 (DELETE)
CREATE POLICY "Owners can delete their own posts."
ON public.posts FOR DELETE
TO authenticated
USING ( auth.uid() = user_id ); -- 삭제할 행을 찾는 조건
```
이처럼 작업(`SELECT`, `INSERT`, `UPDATE`, `DELETE`)과 역할(`public`, `authenticated`)에 따라 여러 정책을 조합하여 매우 세분화된 규칙을 만들 수 있습니다.

## 6. 좋은 RLS 정책을 설계하는 기준

효과적이고 안전한 RLS 정책을 만들려면 다음 기준을 따르는 것이 좋습니다. 이는 `anon` 키에 부여할 권한을 어떻게 잘게 나눌 것인가에 대한 기준, 즉 'anon 키 분해 기준'이 됩니다.

1.  **기본적으로 거부 (Default Deny)**
    가장 중요한 원칙입니다. `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`를 실행하는 순간 모든 접근이 차단됩니다. 그 상태에서 꼭 필요한 권한만 정책을 통해 하나씩 허용해야 합니다.

2.  **최소 권한의 원칙 (Principle of Least Privilege)**
    사용자에게 꼭 필요한 최소한의 권한만 부여합니다. 예를 들어, 단순히 게시물을 읽기만 하면 되는 익명 사용자(`public`)에게 `UPDATE`나 `DELETE` 권한을 줄 이유가 없습니다.

3.  **역할과 행동에 따라 정책 분리**
    위의 게시물 예시처럼, 하나의 큰 정책을 만드는 대신 `SELECT`용, `INSERT`용, `UPDATE`용 정책을 명확하게 분리하는 것이 좋습니다. 이렇게 하면 정책을 이해하고 디버깅하기 쉬워집니다.

4.  **`USING`과 `WITH CHECK`를 명확히 이해하고 사용**
    - 조회(View) 권한은 `USING`으로 제어합니다.
    - 생성/수정(Mutation) 권한은 `WITH CHECK`로 제어하여 데이터 무결성을 보장해야 합니다. `CHECK` 조건을 누락하면 사용자가 다른 사람의 `user_id`로 데이터를 삽입하는 등의 문제가 발생할 수 있습니다.

## 7. 새로운 요약 및 결론

Supabase의 RLS는 단순히 `anon` 키를 차단하는 수단이 아니라, 프론트엔드와 직접 통신할 때 **어떤 데이터를, 누구에게, 어떻게 허용할지**를 정의하는 강력한 규칙 엔진입니다.

| 구분 | 프론트엔드 (Client-Side) | 백엔드 (Server-Side) |
| :--- | :--- | :--- |
| **인증 수단** | `anon` 키 (공개) | `service_role` 키 (비밀) |
| **RLS 영향** | **강제 적용** (보안의 핵심) | **우회** (성능/로직에 영향 없음) |
| **보안 주체**| **데이터베이스(RLS)** + 프론트 로직 | 백엔드 애플리케이션 로직 |
| **RLS 목적**| 세분화된 데이터 접근 규칙 정의 | `anon` 키를 통한 비인가 접근 전면 차단 |

**최종 결론**: RLS는 백엔드만 사용하든, 프론트엔드와 함께 사용하든 **반드시 활성화해야 하는 필수 보안 기능**입니다. 백엔드 중심이라면 모든 접근을 차단하는 방화벽으로, 프론트엔드 중심이라면 데이터 접근 규칙을 정의하는 설계도로서 RLS를 적극 활용해야 합니다.
