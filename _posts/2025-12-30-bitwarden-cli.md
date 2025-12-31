---
title: Bitwarden Secrets Manager 시작하기 (bws CLI 가이드)

toc: true
toc_sticky: true

categories:
  - devops
  - security

tags:
  - bitwarden
  - secrets-manager
  - bws
  - cli
  - vault
---

애플리케이션 개발에서 API 키, DB 접속 정보 등 민감한 정보를 안전하게 관리하는 것은 매우 중요합니다. 많은 팀이 HashiCorp Vault나 클라우드 제공업체의 전용 Secret Manager를 사용하지만, 더 직관적이고 쉬운 솔루션을 찾는 경우도 많습니다.

**Bitwarden Secrets Manager**는 바로 이 지점을 파고드는 제품입니다. 개발자 친화적인 워크플로우와 쉬운 사용성으로, 애플리케이션의 비밀 정보를 중앙에서 안전하게 관리할 수 있도록 설계되었습니다.

이 글에서는 Bitwarden Secrets Manager의 전용 CLI 도구인 `bws`를 사용하여 비밀 정보를 관리하는 방법을 소개합니다.

## Bitwarden Secrets Manager 핵심 개념

`bws` CLI를 사용하기 전에, Secrets Manager의 네 가지 핵심 개념을 이해해야 합니다.

1.  **Secrets (비밀):** `DATABASE_URL`, `API_KEY`와 같이 애플리케이션에서 사용하는 키-값 형태의 민감한 데이터입니다.
2.  **Projects (프로젝트):** 연관된 비밀들을 그룹화하는 컨테이너입니다. 예를 들어, "My Awesome App - Production" 프로젝트에는 해당 앱의 운영 환경에 필요한 모든 비밀이 포함됩니다.
3.  **Machine Accounts (머신 계정):** 자동화된 스크립트나 CI/CD 파이프라인, 애플리케이션 등 사람이 아닌 주체가 비밀에 접근할 때 사용하는 비-인간(non-human) 계정입니다.
4.  **Access Tokens (접근 토큰):** 머신 계정이 자신에게 할당된 프로젝트의 비밀에 접근하고 해독할 때 사용하는 일종의 "비밀번호"입니다.

## `bws` CLI 설치

Bitwarden Secrets Manager CLI(`bws`)는 GitHub 릴리즈 페이지에서 직접 다운로드하여 설치합니다.

1.  **[공식 GitHub 릴리즈 페이지](https://github.com/bitwarden/sdk/releases)** 로 이동합니다.
2.  자신의 운영체제(macOS, Linux, Windows)에 맞는 최신 버전의 `bws` 실행 파일을 다운로드합니다.
3.  다운로드한 파일의 압축을 풀고, 터미널 어디에서든 실행할 수 있도록 시스템의 `PATH`에 등록된 디렉토리(예: `/usr/local/bin` 또는 `C:\Windows\System32`)로 파일을 옮깁니다.

    ```bash
    # 예시 (macOS/Linux)
    mv ./bws /usr/local/bin/
    ```

## 기본 사용법: 인증 및 구성

`bws`는 사용자 계정으로 로그인하는 `bw` (Bitwarden Password Manager CLI)와 달리, 머신 계정의 **접근 토큰(Access Token)**을 사용하여 인증합니다.

### BWS_ACCESS_TOKEN 획득 방법

`BWS_ACCESS_TOKEN`은 Bitwarden Secrets Manager 웹 볼트에서 생성할 수 있습니다. 이 토큰은 머신 계정이 Secrets Manager에 접근할 수 있는 권한을 부여하므로, 매우 민감한 정보로 취급해야 합니다.

1.  **Bitwarden Secrets Manager 웹 볼트 접속:**
    조직의 Secrets Manager 웹 인터페이스에 로그인합니다.
2.  **머신 계정 생성:**
    좌측 메뉴에서 "Machine Accounts"로 이동하여 새로운 머신 계정을 생성합니다. 이때, 해당 머신 계정에 Secrets Manager의 어떤 "Projects"에 접근할 권한을 부여할지 설정해야 합니다.
3.  **접근 토큰(Access Token) 생성:**
    생성된 머신 계정을 클릭하면 "Access Tokens" 섹션이 나타납니다. 여기서 "Create Access Token" 버튼을 클릭하여 새로운 토큰을 생성합니다. 생성된 토큰은 **단 한 번만 표시**되므로, 안전한 곳에 즉시 복사하여 보관해야 합니다.
    -   토큰은 `0.uKV...` 와 같은 형식으로 시작합니다.

### 1. 인증 (Authentication)

가장 일반적인 방법은 접근 토큰을 환경 변수로 설정하는 것입니다.

```bash
export BWS_ACCESS_TOKEN="0.uKV...oA.d7....=="
```

이렇게 하면 `bws` 명령을 실행할 때마다 토큰을 입력할 필요가 없습니다.

### 2. 서버 구성 (Configuration)

Bitwarden의 클라우드 서버(US/EU)가 아닌 자체 호스팅 서버를 사용하는 경우, 다음과 같이 API와 Identity URL을 구성할 수 있습니다.

```bash
bws config set --api-url https://your.api.url --identity-url https://your.identity.url
```

## 핵심 명령어: 비밀 정보 관리

### 1. 프로젝트 및 비밀 목록 조회 (`list`)

-   **프로젝트 목록 보기:**
    자신(머신 계정)이 접근할 수 있는 모든 프로젝트를 나열합니다.
    ```bash
    bws project list
    ```

-   **특정 프로젝트의 비밀 목록 보기:**
    ```bash
    # 모든 접근 가능한 비밀 목록을 조회 (JSON 형식)
    bws secret list
    ```
    이 명령어는 머신 계정이 접근 가능한 모든 프로젝트의 모든 비밀을 JSON 형태로 출력합니다.

    **참고**: 특정 프로젝트의 비밀만 보려면 `bws project list`로 프로젝트 ID를 확인한 뒤, 그 ID를 사용하여 `jq`로 `bws secret list`의 결과를 필터링할 수 있습니다.
    ```bash
    # 예시: "My Awesome App" 프로젝트의 비밀만 필터링
    PROJECT_ID=$(bws project list | jq -r '.[] | select(.name == "My Awesome App") | .id')
    bws secret list | jq --arg PROJECT_ID "$PROJECT_ID" '[.[] | select(.projectId == $PROJECT_ID)]'
    ```

### 2. 비밀 정보 조회 (`get`)

비밀의 ID를 사용하여 특정 비밀의 값을 가져옵니다.

```bash
# 특정 비밀 ID를 사용하여 직접 조회 (예시 ID 사용)
bws secret get 00000000-0000-0000-0000-000000000000
```
결과는 기본적으로 JSON 형식으로 반환됩니다.

**참고**: 비밀의 ID를 모르는 경우, `bws secret list`와 `jq`를 조합하여 찾을 수 있습니다.
```bash
# 예시: "My Awesome App" 프로젝트의 "DATABASE_URL" 비밀 ID 찾기
PROJECT_ID=$(bws project list | jq -r '.[] | select(.name == "My Awesome App") | .id')
SECRET_ID=$(bws secret list | jq -r --arg PROJECT_ID "$PROJECT_ID" '.[] | select(.projectId == $PROJECT_ID and .key == "DATABASE_URL") | .id')
echo "Found SECRET_ID: $SECRET_ID"
bws secret get $SECRET_ID
```

### 3. 비밀 정보 저장 (`create`)

새로운 비밀을 생성합니다. 어떤 프로젝트에 속할지를 지정해야 합니다.

```bash
# "My Awesome App" 프로젝트에 API_KEY 비밀 생성
bws secret create API_KEY "sk_live_12345..." $PROJECT_ID --notes "Stripe Live API Key"
```

**주의사항: `bws secret create` 실행 시 404 오류가 발생하는 경우**

`bws secret create` 명령 실행 시 `404 Not Found` 오류가 발생한다면 다음 세 가지를 확인해야 합니다.

1.  **올바른 Project ID 사용 확인:**
    `create` 명령어의 마지막 인자는 반드시 **Project ID**여야 합니다. 웹 UI에서 값을 복사할 때, 형태가 비슷한 "Secret ID"나 "Organization ID"를 실수로 사용하는 경우가 많으니, Project ID가 맞는지 다시 한번 확인해야 합니다.

2.  **머신 계정의 프로젝트 접근 권한 확인:**
    현재 사용 중인 `BWS_ACCESS_TOKEN`에 연결된 머신 계정이 대상 프로젝트에 접근할 수 있는 권한을 가지고 있는지 확인해야 합니다. Secrets Manager 웹 볼트의 "Machine Accounts" 메뉴에서 권한을 할당할 수 있습니다.

3.  **접근 가능한 리소스가 없는 경우 (알려진 이슈):**
    머신 계정이 접근할 수 있는 Secret이나 Project가 하나도 없는 상태에서 `bws secret list` 같은 명령이 `404` 오류를 반환하는 이슈가 보고된 바 있습니다. 만약 완전히 비어있는 상태에서 `create` 명령도 실패한다면, 웹 볼트에서 먼저 수동으로 Secret을 하나 생성하여 이 상태를 벗어나는 것이 해결책이 될 수 있습니다.

## 활용 사례: 대화형 비밀 관리 스크립트

`bws` CLI와 `jq`, 그리고 셸 스크립트의 `select` 문법을 조합하면, 특정 프로젝트의 비밀을 손쉽게 관리할 수 있는 대화형(interactive) 도구를 만들 수 있습니다.

아래 스크립트(`manage-secrets.sh`)는 실행 시 프로젝트를 선택하고, 해당 프로젝트 내의 비밀에 대한 생성, 조회, 수정, 삭제 등의 작업을 수행합니다.

```bash
#!/bin/bash

# BWS_ACCESS_TOKEN이 설정되어 있는지 확인
if [ -z "$BWS_ACCESS_TOKEN" ]; then
  echo "Error: BWS_ACCESS_TOKEN environment variable is not set."
  exit 1
fi

# 1. 프로젝트 선택
echo "Accessible project list:"
# `bws project list`로 프로젝트 목록을 가져와 `jq`로 이름만 추출
projects=($(bws project list | jq -r '.[].name'))

if [ ${#projects[@]} -eq 0 ]; then
  echo "No accessible projects found."
  exit 1
fi

echo "Select the project to work on:"
select project_name in "${projects[@]}" "Exit"; do
  # 종료
  if [ "$project_name" == "Exit" ]; then
    exit 0
  elif [ -n "$project_name" ]; then
    break
  else
    echo "Invalid selection."
  fi
done

# 선택된 프로젝트의 ID를 가져옴
PROJECT_ID=$(bws project list | jq -r ".[] | select(.name == \"$project_name\") | .id")
echo "Selected project: $project_name (ID: $PROJECT_ID)"
echo "-------------------------------------"


# 2. 메인 메뉴
PS3="Select an operation to perform: "
options=("List Secrets" "Get Specific Secret" "Create New Secret" "Edit Secret Value" "Delete Secret" "Exit")
select opt in "${options[@]}"; do
  case $opt in
    "List Secrets")
      # 비밀 목록 조회
      echo "Secrets list for [$project_name] project:"
      bws secret list | jq --arg pid "$PROJECT_ID" '.[] | select(.projectId == $pid)'
      ;;
    "Get Specific Secret")
      # 특정 비밀 조회
      read -p "Enter KEY of the secret to retrieve: " secret_key
      SECRET_ID=$(bws secret list | jq -r --arg pid "$PROJECT_ID" --arg key "$secret_key" '.[] | select(.projectId == $pid and .key == $key) | .id')
      if [ -z "$SECRET_ID" ]; then
        echo "Error: Secret with that KEY not found."
      else
        bws secret get "$SECRET_ID" | jq '.value'
      fi
      ;;
    "Create New Secret")
      # 새로운 비밀 생성
      read -p "Enter KEY for the new secret: " new_key
      read -p "Input type for VALUE (1: Direct Input, 2: From File Path): " input_type
      if [ "$input_type" == "2" ]; then
        read -p "Enter file path for the VALUE: " file_path
        if [ -f "$file_path" ]; then
          new_value=$(cat "$file_path")
        else
          echo "Error: File not found."
          continue
        fi
      else
        read -sp "Enter VALUE for the new secret: " new_value
        echo
      fi
      bws secret create "$new_key" "$new_value" "$PROJECT_ID"
      echo "'$new_key' secret has been created."
      ;;
    "Edit Secret Value")
       # 비밀 값 수정
       read -p "Enter KEY of the secret to edit: " secret_key
       SECRET_ID=$(bws secret list | jq -r --arg pid "$PROJECT_ID" --arg key "$secret_key" '.[] | select(.projectId == $pid and .key == $key) | .id')
       if [ -z "$SECRET_ID" ]; then
         echo "Error: Secret with that KEY not found."
       else
         read -p "Input type for new VALUE (1: Direct Input, 2: From File Path): " input_type
         if [ "$input_type" == "2" ]; then
           read -p "Enter file path for the new VALUE: " file_path
           if [ -f "$file_path" ]; then
             new_value=$(cat "$file_path")
           else
             echo "Error: File not found."
             continue
           fi
         else
           read -sp "Enter new VALUE: " new_value
           echo
         fi
         bws secret edit --value "$new_value" "$SECRET_ID"
         echo "Value of '$secret_key' secret has been updated."
       fi
      ;;
    "Delete Secret")
      # 비밀 삭제
      read -p "Enter KEY of the secret to delete: " secret_key
      SECRET_ID=$(bws secret list | jq -r --arg pid "$PROJECT_ID" --arg key "$secret_key" '.[] | select(.projectId == $pid and .key == $key) | .id')
      if [ -z "$SECRET_ID" ]; then
        echo "Error: Secret with that KEY not found."
      else
        bws secret delete "$SECRET_ID"
        echo "'$secret_key' secret has been deleted."
      fi
      ;;
    "Exit")
      # 종료
      break
      ;;
    *) echo "Invalid selection.";;
  esac
  # 각 작업 후 다시 메인 메뉴를 보여주기 위함
  REPLY=
  echo "-------------------------------------"
done
```

### 스크립트 설명

1.  **프로젝트 선택:**
    -   `bws project list`로 접근 가능한 모든 프로젝트 목록을 JSON으로 받아옵니다.
    -   `jq -r '.[].name'`을 통해 각 프로젝트의 이름만 추출하여 `projects` 배열에 저장합니다.
    -   `select` 문을 사용하여 사용자에게 프로젝트 목록을 보여주고, 선택된 프로젝트의 이름(`project_name`)을 받아옵니다.
    -   다시 `bws project list`와 `jq`를 사용하여 선택된 이름에 해당하는 `PROJECT_ID`를 조회합니다.

2.  **메인 메뉴 및 작업 수행:**
    -   사용자가 수행할 작업을 선택할 수 있도록 `select` 문으로 메뉴를 제공합니다.
    -   **목록 조회:** `bws secret list`의 전체 결과에서 선택된 `PROJECT_ID`와 일치하는 비밀들만 `jq`로 필터링하여 보여줍니다.
    -   **특정 비밀 조회:** 사용자로부터 `KEY`를 입력받아, 해당하는 비밀의 `ID`를 `jq`로 찾은 뒤 `bws secret get`을 호출합니다.
    -   **생성/수정:** `VALUE`를 입력받을 때, **직접 입력(Direct Input)** 또는 **파일 경로(From File Path)**를 선택할 수 있도록 하여, 여러 줄로 된 비밀 값(예: 인증서, 비공개 키)도 쉽게 처리할 수 있습니다.
    -   **삭제:** 삭제할 비밀의 `KEY`를 입력받아, 해당하는 `ID`를 찾아 `bws secret delete`를 실행합니다.

이 스크립트를 약간만 수정하면, 특정 프레임워크에 맞는 설정 파일을 동적으로 생성하거나, 여러 비밀을 한 번에 업데이트하는 등 다양한 자동화 작업을 수행할 수 있습니다.

## 결론

**Bitwarden Secrets Manager**와 `bws` CLI는 복잡성을 줄이고 개발자 경험에 집중한 현대적인 비밀 관리 솔루션입니다. 개인/팀용 Password Manager와 완벽히 분리된 M2M(Machine-to-Machine) 워크플로우를 제공하므로, 더 이상 애플리케이션 비밀 관리를 위해 Password Manager를 "응용"할 필요가 없습니다.

보안과 자동화, 두 마리 토끼를 모두 잡고 싶다면 Bitwarden Secrets Manager는 매우 훌륭한 선택지가 될 것입니다.
