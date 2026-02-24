---
title: "Shell 환경변수 정리: export 유효 범위, 인라인 변수, .env 파일"
tags:
  - devops
  - shell
  - environment
  - env
  - bash
  - zsh
---

셸에서 환경변수(Environment Variable)는 프로세스가 실행될 때 함께 전달되는 `key=value` 형태의 설정값입니다.  
CLI 도구 동작 제어, API 키 전달, 실행 경로(PATH) 설정 등 DevOps 작업의 기본 단위로 쓰입니다.

## 1. 환경변수 정의와 셸에서의 사용 방법

환경변수는 보통 다음 형태를 사용합니다.

```bash
export APP_ENV=production
export API_URL=https://api.example.com
```

확인 방법:

```bash
echo "$APP_ENV"
printenv APP_ENV
env | rg '^APP_ENV='
```

각 명령의 의미:

- `echo "$APP_ENV"`: 현재 셸이 가진 변수 값을 확인 (셸 변수/환경변수 모두 확인 가능)
- `printenv APP_ENV`: 현재 프로세스의 **환경변수**만 확인 (`export` 안 된 셸 변수는 안 보임)
- `env | rg '^APP_ENV='`: 현재 프로세스의 환경변수 목록에서 패턴 필터링

예시:

```bash
APP_ENV=local
echo "$APP_ENV"          # local
printenv APP_ENV         # (출력 없음)
env | rg '^APP_ENV='     # (출력 없음)

export APP_ENV=prod
echo "$APP_ENV"          # prod
printenv APP_ENV         # prod
env | rg '^APP_ENV='     # APP_ENV=prod
```

사용 예시:

```bash
curl -H "Authorization: Bearer $API_TOKEN" "$API_URL/health"
```

## 2. `export`와 변수 유효 범위(현재 셸/자식 프로세스)

핵심 구분은 "셸 변수"와 "환경변수"입니다.

```bash
FOO=bar          # 현재 셸 변수
export FOO       # 자식 프로세스에도 전달되는 환경변수로 승격
```

- `FOO=bar`만 하면 현재 셸 내부에서만 유효
- `export FOO` 후에는 현재 셸 + 이후 실행되는 자식 프로세스에 전달

유효 범위 비교:

```bash
FOO=bar
zsh -c 'echo $FOO'       # (출력 없음) 자식 셸에 전달 안 됨

export FOO
zsh -c 'echo $FOO'       # bar
```

- 현재 터미널 세션에서 설정한 변수는 해당 세션이 종료되면 사라집니다.
- 새 터미널을 열 때마다 필요하면 `~/.zshrc`, `~/.bashrc` 등에 선언해야 합니다.
- 로그인 셸과 인터랙티브 셸 로딩 파일이 다를 수 있으니, 팀 표준 파일을 정해두는 것이 좋습니다.

지속 설정 예시(`zsh`):

```bash
echo 'export APP_ENV=development' >> ~/.zshrc
source ~/.zshrc
```

## 3. 인라인 변수 세팅과 적용 범위

인라인 환경변수는 "해당 명령 1회 실행 범위"에만 적용됩니다.

```bash
APP_ENV=staging LOG_LEVEL=debug ./deploy.sh
```

특징:

- 현재 셸 상태를 오염시키지 않음
- CI/CD에서 스텝 단위 변수 주입에 유용
- 같은 줄의 명령에만 적용되고, 다음 명령에는 기본적으로 유지되지 않음

유효 범위 예시:

```bash
APP_ENV=staging env | rg '^APP_ENV='   # APP_ENV=staging
echo "$APP_ENV"                         # 비어있거나 기존 값

APP_ENV=staging sh -c 'echo $APP_ENV'  # staging (해당 명령의 자식 프로세스까지는 전달)
echo "$APP_ENV"                         # 비어있거나 기존 값
```

비교:

```bash
APP_ENV=staging ./deploy.sh   # 1회성
echo "$APP_ENV"               # 비어있거나 기존 값

export APP_ENV=staging        # 세션 전체 영향
./deploy.sh
echo "$APP_ENV"               # staging
```

## 4. `.env` 파일 이용 방법

`.env`는 환경변수를 파일로 관리하기 위한 관례입니다.

예시(`.env`):

```dotenv
APP_ENV=local
API_URL=http://localhost:8080
API_TOKEN=replace_me
```

로딩 방법 1: 간단 로드

```bash
set -a
source .env
set +a
```

로딩 방법 2: `xargs` 사용

```bash
export $(grep -v '^#' .env | xargs)
```

주의:

- `.env`에는 비밀값이 포함되므로 `.gitignore`에 등록
- 공용 저장소에는 `.env.example`만 커밋
- 값에 공백/특수문자가 있으면 quoting 규칙 문제를 확인

`.gitignore` 예시:

```gitignore
.env
.env.*
!.env.example
```

## 정리

- `export`는 변수를 자식 프로세스까지 전달할 때 사용합니다.
- 인라인 변수(`KEY=VALUE cmd`)는 1회성 실행에 가장 안전합니다.
- `.env`는 로컬/개발 환경 관리에 편리하지만, 비밀값 관리 규칙을 반드시 함께 가져가야 합니다.
