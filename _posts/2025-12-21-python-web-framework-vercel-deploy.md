---
title: Python Web 프레임워크 (Flask, FastAPI) Vercel로 배포하기

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - vercel
  - flask
  - fastapi
  - deployment
  - serverless
  - supabase
---

Python 기반의 웹 프레임워크인 **Flask**나 **FastAPI**를 개발한 후, 이를 실제 서비스로 배포하는 방법은 여러 가지가 있습니다. (AWS EC2, Docker, Heroku 등)
그 중에서도 **Vercel**은 복잡한 서버 관리 없이 가장 간편하고 빠르게 배포할 수 있는 플랫폼 중 하나입니다. 이번 글에서는 Vercel을 사용하여 Python 웹 애플리케이션을 배포하는 전반적인 과정과 주요 개념들을 정리해 보겠습니다.

## 1. Vercel 서비스 개요 및 기능

**Vercel**은 개발자가 만든 웹 애플리케이션을 쉽고 빠르게 배포할 수 있도록 돕는 클라우드 플랫폼입니다. 초기에는 Next.js와 같은 프론트엔드 프레임워크 배포에 최적화된 서비스로 시작했으나, 현재는 **Serverless Functions** 기능을 통해 Python, Node.js, Go 등의 백엔드 언어도 지원합니다.

### 주요 특징 및 할 수 있는 것들
*   **Serverless Architecture**: 별도의 서버(VM)를 프로비저닝하거나 관리할 필요가 없습니다. 요청이 들어올 때만 코드가 실행되는 서버리스 환경을 제공합니다.
*   **Zero Configuration**: 복잡한 설정 없이 Git 푸시만으로 빌드 및 배포가 자동화됩니다.
*   **Global CDN (Edge Network)**: 전 세계에 분산된 엣지 네트워크를 통해 콘텐츠를 캐싱하고 빠르게 제공합니다.
*   **Automated CI/CD**: Github/Gitlab 등과 연동되어 코드 변경 사항이 발생하면(Push, PR) 자동으로 새로운 버전을 배포하고 URL을 생성합니다.
*   **Preview Deployment**: 프로덕션 배포 전, PR(Pull Request) 단계에서 미리 변경 사항을 확인해 볼 수 있는 프리뷰 URL을 제공합니다.

## 2. Vercel과 Github 소스 저장소의 관계

Vercel은 **Git 중심(Git-centric)**의 배포 워크플로우를 가집니다. 즉, 코드를 Github(또는 Gitlab, Bitbucket)에 올리는 행위 자체가 배포의 시작점이 됩니다.

### 배포를 위해 필요한 사항
1.  **Github Repository**: 배포할 Flask/FastAPI 프로젝트가 Github 리포지토리에 올라가 있어야 합니다.
2.  **requirements.txt**: Python 의존성 패키지 목록이 프로젝트 루트에 었어야 Vercel이 빌드 시 자동으로 라이브러리를 설치합니다.
3.  **WSGI/ASGI 진입점**: Flask는 `app` 객체, FastAPI는 `app` 객체가 정의된 파일이 명확해야 합니다.
4.  **vercel.json (선택 사항)**: Python 프로젝트의 경우, Vercel에게 어떤 파일이 실행 파일인지 알려주기 위해 설정 파일이 필요할 수 있습니다. (최근에는 자동 감지 기능이 좋아졌으나, 명시적인 설정을 권장합니다.)

```json
/* vercel.json 예시 */
{
  "builds": [
    {
      "src": "api/index.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "api/index.py"
    }
  ]
}
```

## 3. Vercel 배포 소스 선택 및 배포 과정

Vercel에 프로젝트를 연결하고 배포하는 과정은 매우 직관적입니다.

### 3.1 Github의 Vercel 어플리케이션 설치 및 권한 부여
Vercel 회원가입 후 'New Project'를 생성할 때 Github 계정을 연동하게 됩니다. 이때 **Vercel Github App**을 설치하게 되는데, 보안을 위해 **모든 리포지토리(All repositories)**에 접근 권한을 줄지, 아니면 **특정 리포지토리(Only select repositories)**만 허용할지 선택할 수 있습니다. 필요한 리포지토리만 선택하여 권한을 부여하는 것이 좋습니다.

### 3.2 Vercel의 소스 선택 및 Import
1.  Vercel 대시보드에서 **Add New > Project**를 클릭합니다.
2.  연동된 Github 계정의 리포지토리 목록이 나타납니다. 배포하려는 Python 프로젝트 옆의 **Import** 버튼을 누릅니다.
3.  **Configure Project** 화면에서 다음을 설정합니다.
    *   **Project Name**: URL에 사용될 프로젝트 이름입니다.
    *   **Root Directory**: 프로젝트가 하위 폴더에 있다면 지정합니다. (보통은 `./`)
    *   **Environment Variables**: DB 접속 정보나 API 키 등 환경 변수를 여기서 설정합니다.
4.  **Deploy** 버튼을 클릭하면 Vercel이 코드를 가져와 빌드 및 배포를 시작합니다.

## 4. Deployment 관리: 버전 확인 및 재배포

Vercel에서 **Deployment**는 불변(Immutable)의 스냅샷입니다. 코드가 변경될 때마다 새로운 URL을 가진 새로운 배포가 생성되므로, 언제든지 특정 시점의 코드로 되돌리거나 비교할 수 있습니다.

### 4.1 Git 리비전 및 소스 확인
Vercel 대시보드의 **Deployments** 탭에서는 모든 배포 이력을 리스트 형태로 볼 수 있습니다.
*   **Commit 연결**: 각 배포 항목에는 연동된 Github의 커밋 메시지와 브랜치명(`main` 등)이 표시됩니다.
*   **Git 아이콘 클릭**: 커밋 ID나 메시지를 클릭하면 Github의 해당 커밋 페이지로 바로 이동하여, 정확히 어떤 코드가 배포되어 있는지 확인할 수 있습니다.
*   **Source 탭**: Vercel 대시보드 내에서도 배포된 파일들의 소스 코드를 직접 열람할 수 있는 기능을 제공합니다.

### 4.2 최신 소스 반영 (업데이트)
Vercel은 **Git-centric** 워크플로우를 따르므로, 소스를 업데이트하는 가장 정석적인 방법은 **Git Push**입니다.
1.  로컬에서 코드를 수정하고 커밋합니다.
2.  `git push origin main` 명령어로 원격 저장소에 푸시합니다.
3.  Vercel이 이를 감지하고 자동으로 **Building -> Deploying** 과정을 시작합니다.
4.  배포가 완료되면 상태가 **Ready**로 바뀌고, 라이브 사이트에 변경 사항이 즉시 적용됩니다.

### 4.3 재배포(Redeploy) 및 롤백
코드는 그대로인데 환경 변수만 바꿨거나, 일시적인 오류로 빌드가 실패했을 때는 어떻게 해야 할까요?

*   **Redeploy (재배포)**:
    *   이미 지나난 커밋이나 실패한 배포를 다시 빌드하고 싶다면, 해당 Deployment의 점 3개 메뉴(...)를 누르고 **Redeploy**를 선택합니다.
    *   **Redeploy without cache**: 의존성 패키지 설치부터 완전히 새로 시작하고 싶다면 이 옵션을 체크하면 됩니다. (환경 변수 변경 적용 시 유용)

*   **Instant Rollback (즉시 롤백)**:
    *   새로 배포한 버전에 치명적인 버그가 발견되었다면? 빌드를 기다릴 필요 없이 즉시 이전 버전으로 되돌릴 수 있습니다.
    *   과거에 성공했던(Stable) Deployment 항목에서 메뉴를 열고 **Instant Rollback**을 클릭합니다.
    *   도메인이 가리키는 대상만 즉시 변경되므로 **초 단위로 복구**가 가능합니다.

## 5. 환경 변수(Environment Variables) 및 .env 관리

API Key, Database URL 등 민감한 정보는 절대로 코드에 직접 작성하거나 Git 저장소에 올려서는 안 됩니다. Vercel은 이러한 환경 변수를 안전하게 관리할 수 있는 메커니즘을 제공합니다.

### 5.1 로컬 개발 환경 (.env)
로컬에서 개발할 때는 프로젝트 루트에 `.env` 파일을 생성하여 변수를 관리합니다.
1.  **python-dotenv 설치**: `pip install python-dotenv`
2.  **.env 파일 작성**:
    ```bash
    DATABASE_URL=postgresql://user:password@localhost:5432/mydb
    API_KEY=my_secret_key
    ```
3.  **코드에서 사용**:
    ```python
    import os
    from dotenv import load_dotenv

    load_dotenv() # .env 파일 로드
    db_url = os.getenv("DATABASE_URL")
    ```
4.  **.gitignore 설정**: `.env` 파일이 Git에 올라가지 않도록 `.gitignore`에 반드시 추가합니다.

### 5.2 Vercel 프로덕션 환경 변수 설정
배포된 환경에서는 파일이 아닌 Vercel 대시보드를 통해 변수를 주입합니다.
1.  Vercel 프로젝트 대시보드의 **Settings > Environment Variables** 로 이동합니다.
2.  Key와 Value를 입력하고 추가합니다.
3.  **Environments 선택**: Production, Preview, Development 중 어디에 적용할지 선택할 수 있습니다.
4.  설정 후에는 **Redeploy**를 해야 변경된 변수가 적용됩니다.

### 5.3 Vercel CLI로 환경 변수 동기화
Vercel에 설정된 환경 변수를 로컬 개발 환경으로 가져올 수도 있습니다.
```bash
# Vercel에 로그인 및 프로젝트 연결
vercel login
vercel link

# Development 환경 변수를 .env.local 파일로 다운로드
vercel env pull .env
```
이렇게 하면 팀원들과 비밀키를 메신저로 주고받을 필요 없이 안전하게 동기화할 수 있습니다.

### 5.4 Vercel 시스템 환경 변수 및 확인 방법
Vercel은 사용자가 정의한 변수 외에도 배포 환경에 대한 정보를 담은 **시스템 환경 변수(System Environment Variables)**를 자동으로 주입합니다.
*   `VERCEL_ENV`: 현재 환경 (production, preview, development)
*   `VERCEL_URL`: 배포된 URL (프로토콜 제외)
*   `VERCEL_REGION`: 배포된 리전 (예: icn1)
*   `CI`: CI 환경 여부 (boolean)

**환경 변수 확인 예제 코드 (FastAPI)**
```python
from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/debug-env")
def read_env():
    return {
        "ver_env": os.getenv("VERCEL_ENV"),
        "ver_url": os.getenv("VERCEL_URL"),
        "db_url_exists": os.getenv("DATABASE_URL") is not None 
        # 보안상 전체 값 노출보다는 존재 여부만 확인하는 것이 좋습니다.
    }
```
위와 같이 간단한 엔드포인트를 만들어 배포 후 접속해보면 변수가 제대로 주입되었는지 확인할 수 있습니다.

## 6. DBMS 연결하기 (Supabase 활용)

Vercel은 훌륭한 컴퓨팅 환경(Serverless Functions)을 제공하지만, 영구적인 데이터를 저장하는 데이터베이스는 직접 호스팅하지 않는 경우가 많습니다. (최근 Vercel Storage가 출시되었으나, 관계형 DB로는 **Supabase**나 **Neon**과 같은 외부 서비스를 많이 사용합니다.)

### Supabase 연결 절차
1.  **Supabase 프로젝트 생성**: Supabase에서 새 프로젝트를 생성하고 PostgreSQL 데이터베이스를 할당받습니다.
2.  **Connection String 확인**: 프로젝트 설정에서 `postgresql://...` 로 시작하는 접속 정보를 복사합니다.
3.  **Vercel 환경변수 설정**:
    *   Vercel 프로젝트 설정의 **Environment Variables** 메뉴로 이동합니다.
    *   `DATABASE_URL` 등의 키(Key) 이름으로 복사한 접속 정보를 값(Value)으로 등록합니다.
4.  **Python 코드 적용**: Python 코드(SQLAlchemy 등)에서 `os.environ.get("DATABASE_URL")`을 사용하여 DB에 접속하도록 코드를 작성합니다.

> **Tip**: Vercel은 'Integrations' 마켓플레이스를 통해 Supabase를 클릭 몇 번으로 연동하고 환경변수를 자동으로 주입해주는 기능도 제공합니다.

### Supabase 연결 시 URL 파라미터 트러블슈팅

Vercel과 같은 Serverless 환경에서 Supabase에 연결할 때, 단순 문자열 복사만으로는 연결 에러가 발생할 수 있습니다. 다음 체크리스트를 확인하세요.

1.  **URL 파라미터 정리 (Sanitize Database URL)**
    *   **문제 원인**: Connection String의 `?` 뒤에 붙는 쿼리 파라미터들은 데이터베이스 드라이버(Driver)가 해석합니다. 하지만 `supa=value`는 PostgreSQL 표준 파라미터가 아닌, Supabase 플랫폼 내부 관리용(Connection Pooling 등) **커스텀 파라미터**입니다.
    *   **드라이버 반응**: `asyncpg`나 `SQLAlchemy` 같은 표준 드라이버는 자신이 알지 못하는 `supa` 파라미터를 만나면 처리를 못하고 `"Unknown connection parameter"` 또는 `"Invalid argument"` 에러를 내뱉으며 연결을 거부합니다.
    *   **해결 방법**: URL을 코드에 사용하기 전에 코드를 통해 `supa` 등 불필요한 파라미터를 반드시 제거(Sanitize)해야 합니다. 단, `pgbouncer=true`나 `prepared_statement_cache_size=0` 같은 **드라이버 호환성 파라미터**는 남겨두어야 합니다.

2.  **테이블 생성 시점 변경 (Move Table Creation to Startup)**
    *   일반적인 서버 환경과 달리, Vercel(Serverless)에서는 코드를 import하는 시점에 DB 연결을 시도하거나 테이블을 생성(`Base.metadata.create_all`)하면 콜드 스타트 시간 지연이나 타임아웃 오류가 발생할 수 있습니다.
    *   반드시 **애플리케이션 시작 이벤트**(`@app.on_event("startup")` 또는 `lifespan`) 내에서 테이블 생성 로직이 실행되도록 변경해야 합니다.
    *   예시:
        ```python
        @app.on_event("startup")
        async def on_startup():
            # 여기서 DB 연결 및 테이블 생성
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
        ```

## 7. 서비스 Expose, 도메인, SSL

배포가 완료되면 어떻게 외부에서 접속할 수 있을까요?

### 기본 도메인 제공
배포 성공 시 Vercel은 기본적으로 `프로젝트명.vercel.app` 형태의 도메인을 무료로 제공합니다. (예: `my-flask-app.vercel.app`) 이 주소를 통해 즉시 서비스에 접속할 수 있습니다.

**※ 프로젝트명이 중복되는 경우:**
만약 이미 다른 사용자가 해당 프로젝트명(서브도메인)을 선점했다면, Vercel은 자동으로 프로젝트명 뒤에 **임의의 단어나 계정명**을 붙여 중복되지 않는 URL을 생성합니다. (예: `my-flask-app-gamma.vercel.app` 또는 `my-flask-app-cdecl.vercel.app`) 원한다면 설정에서 도메인 주소를 변경할 수도 있습니다.

### 커스텀 도메인 (Custom Domain)
본인이 소유한 도메인(예: `example.com`)을 연결할 수 있습니다.
*   Vercel 대시보드의 **Settings > Domains**에서 도메인을 추가합니다.
*   도메인 등록 업체(가비아, GoDaddy, AWS Route53 등)의 DNS 설정에서 Vercel이 안내하는 **A 레코드** 또는 **CNAME 레코드**를 입력하면 연결됩니다.

### SSL/HTTPS 자동 적용
Vercel의 가장 큰 장점 중 하나는 **SSL 인증서를 자동으로 발급하고 갱신**해준다는 점입니다. `.vercel.app` 기본 도메인은 물론, 연결한 커스텀 도메인에 대해서도 Let's Encrypt 기반의 HTTPS 인증서가 자동으로 적용되어 보안 접속이 가능해집니다. 별도의 인증서 구매나 서버 설정이 필요 없습니다.

## 8. 현재 기준 무료 플랜(Hobby) 및 가격 체계

Vercel은 개인 개발자를 위한 매우 혜자로운 무료 플랜을 제공합니다. (2025년 12월 기준)

### Hobby Plan (무료)
*   **대상**: 개인적, 비상업적(Non-commercial) 용도의 프로젝트
*   **Bandwidth**: 월 100GB
*   **Serverless Function Execution**: 월 100GB-hours (메모리 * 실행시간)
*   **Build Minutes**: 월 6,000분
*   **Domain**: 개수 제한 없이 커스텀 도메인 연결 가능
*   **제한 사항**: Serverless Function의 실행 시간이 기본적으로 짧게 제한될 수 있으며(보통 10초~60초), 상업적 용도로 사용하는 것은 약관상 금지되어 있습니다.

### Pro Plan (유료)
*   **대상**: 팀 단위 협업이나 상업적 서비스
*   **가격**: 사용자당 월 $20 (기본)
*   **추가 기능**: 더 높은 대역폭 및 리소스 제한, 향상된 지원, 팀 협업 기능, 비밀번호 보호 등 보안 기능 제공.

개인 포트폴리오나 토이 프로젝트, 간단한 블로그 등을 운영하기에는 **Hobby 플랜**만으로도 차고 넘치는 기능을 제공합니다.
