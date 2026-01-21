---
title: Mackup으로 macOS 애플리케이션 설정 동기화하기
tags:
  - macos
  - mackup
  - backup
  - productivity
  - dotfiles
---
새로운 Mac을 설정하거나 여러 대의 Mac을 사용할 때마다 애플리케이션 설정을 일일이 다시 구성하는 것은 번거로운 일입니다. Mackup은 이러한 애플리케이션 설정 파일(dotfiles)을 iCloud, Dropbox, Google Drive 등과 같은 클라우드 스토리지에 백업하고, 필요할 때 손쉽게 복원하여 여러 기기 간의 설정을 동기화해주는 강력한 유틸리티입니다.

이 글에서는 Mackup의 기본 개념부터 설치, 사용법, 그리고 고급 설정까지 자세히 다룹니다.

## Mackup이란 무엇이며 왜 필요한가?

Mackup은 'Mac'과 'Backup'의 합성어로, 이름에서 알 수 있듯이 macOS 환경의 설정을 백업하고 동기화하는 데 특화된 도구입니다. 많은 애플리케이션들은 홈 디렉토리에 `.zshrc`, `.vimrc`, `.gitconfig`와 같이 점(.)으로 시작하는 설정 파일(dotfiles)을 저장합니다. 새로운 기기를 설정할 때 이 파일들을 수동으로 옮기는 것은 매우 귀찮은 작업입니다.

Mackup은 이 과정을 자동화하여 다음과 같은 이점을 제공합니다.

- **자동 동기화**: 클라우드 스토리지를 통해 여러 Mac의 애플리케이션 설정을 항상 최신 상태로 유지합니다.
- **간편한 마이그레이션**: 새 Mac을 설정할 때 단 몇 개의 명령어로 기존 환경을 그대로 복원할 수 있습니다.
- **중앙 관리**: 모든 설정 파일을 하나의 폴더(예: Dropbox/Mackup)에서 관리하므로 버전 관리(Git)도 용이합니다.

## 설치 및 기능

### 설치

macOS에서는 Homebrew를 통해 간단하게 설치할 수 있습니다.

```bash
brew install mackup
```

Homebrew를 사용하지 않는다면 `pip`으로도 설치가 가능합니다. 

```bash
pip install --upgrade mackup
```

### 주요 기능

- **`mackup backup`**: 로컬 설정 파일을 클라우드 스토리지로 백업합니다.
- **`mackup restore`**: 클라우드 스토리지의 설정 파일을 로컬 환경으로 복원합니다.
- **`mackup list`**: Mackup이 지원하는 애플리케이션 목록을 보여줍니다.
- **`mackup uninstall`**: Mackup으로 관리되던 모든 설정을 원래 상태로 되돌립니다.

## 백업 및 복원

### 백업하기

처음 Mackup을 실행할 때, `backup` 명령어를 사용해 현재 시스템의 설정 파일들을 백업합니다.

```bash
mackup backup
```

이 명령을 실행하면, Mackup은 지원하는 애플리케이션의 설정 파일들을 찾아 설정된 클라우드 스토리지의 `Mackup` 폴더로 복사합니다. [2, 5]

### 복원하기

새로운 Mac에 기존 설정을 적용하고 싶을 때는 `restore` 명령어를 사용합니다.

```bash
mackup restore
```

이 명령은 클라우드 스토리지에 백업된 설정 파일들을 홈 디렉토리의 적절한 위치로 복사하여 기존 환경을 그대로 재현해 줍니다. 

## 특정 애플리케이션 설정 포함하기

Mackup의 가장 강력한 기능 중 하나는 사용자가 직접 동기화 대상을 지정할 수 있다는 점입니다. 홈 디렉토리에 `.mackup.cfg` 파일을 생성하여 이 모든 것을 제어할 수 있습니다. 

### 스토리지 엔진 및 디렉토리 설정

기본적으로 Mackup은 `dropbox`, `google_drive`, `icloud` 등 다양한 클라우드 스토리지 엔진을 지원합니다. 또한 `file_system` 엔진을 사용하면 로컬 폴더(예: Git으로 관리되는 dotfiles 저장소)에 설정을 백업할 수 있습니다. `.mackup.cfg` 파일에 원하는 엔진과 디렉토리를 지정하여 사용합니다.
각 엔진을 사용하려면 해당 클라우드 서비스의 데스크톱 클라이언트가 설치되어 실행 중이어야 합니다. 예를 들어, `dropbox` 엔진을 사용하려면 Dropbox 데스크톱 앱이, `google_drive`를 사용하려면 Google Drive 앱이 설치되어 있어야 합니다. `icloud`는 macOS에 내장되어 있으므로 iCloud Drive가 활성화되어 있으면 됩니다.
 
**iCloud 예시:**
```ini
[storage]
engine = icloud
directory = Mackup
```

**Google Drive 예시:**
```ini
[storage]
engine = google_drive
directory = Mackup
```

**Git 저장소 (로컬 파일 시스템) 예시:**

`file_system` 엔진을 사용하면 로컬의 특정 경로를 백업 위치로 지정할 수 있어 Git과 함께 사용하기 좋습니다.

```ini
[storage]
engine = file_system
path = path/to/your/dotfiles/repo
```

`file_system` 엔진을 사용하여 백업된 폴더에 Git 저장소를 초기화하고 원격으로 푸시하는 스크립트 예시입니다. 이 스크립트는 백업 폴더가 Git으로 관리되지 않을 때 유용합니다.

```bash
#!/bin/bash

# Mackup의 file_system 엔진으로 백업된 폴더에 Git 저장소를 초기화하고 푸시하는 스크립트입니다.

# --- 설정 ---
BACKUP_DIR="/path/to/your/backup/folder" # 백업 디렉토리 경로
REMOTE_URL="git@github.com:your_user/your_repo.git" # 원격 Git 저장소 URL
BRANCH_NAME="main" # 브랜치 이름

# --- 스크립트 로직 ---
if [ -z "$BACKUP_DIR" ] || [ -z "$REMOTE_URL" ]; then
  echo "오류: BACKUP_DIR 또는 REMOTE_URL이 설정되지 않았습니다. 스크립트를 편집하십시오."
  exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
  echo "오류: 백업 디렉토리 '$BACKUP_DIR'가 존재하지 않습니다."
  exit 1
fi

cd "$BACKUP_DIR" || { echo "디렉토리 변경 실패: $BACKUP_DIR"; exit 1; }

if [ ! -d ".git" ]; then
  git init
  git branch -M "$BRANCH_NAME"
fi

git add .
git commit -m "Initial backup commit" || echo "커밋할 변경사항이 없습니다."

if ! git remote get-url origin &>/dev/null; then
  git remote add origin "$REMOTE_URL"
else
  git remote set-url origin "$REMOTE_URL"
fi

git push -u origin "$BRANCH_NAME"

echo "Git 작업 완료: $BACKUP_DIR"
```
### 동기화할 앱과 제외할 앱 지정하기

`applications_to_sync`와 `applications_to_ignore` 섹션을 사용하여 동기화 대상을 세밀하게 제어할 수 있습니다. 

```ini
[applications_to_sync]
iterm2
visual-studio-code

[applications_to_ignore]
filezilla
spotify
```

만약 `applications_to_sync`를 지정하지 않으면, Mackup은 지원하는 모든 앱을 동기화 대상으로 간주합니다. 

### 지원하는 애플리케이션 목록 확인하기

Mackup이 어떤 애플리케이션을 지원하는지 확인하고 싶다면 `list` 명령어를 사용합니다.

```bash
mackup list
```

이 명령어는 Mackup이 동기화할 수 있는 모든 애플리케이션의 목록을 출력합니다. 이 목록을 참고하여 `.mackup.cfg` 파일에 동기화하거나 제외할 앱을 지정할 수 있습니다.

## 사용자 정의 애플리케이션 및 디렉토리 추가

Mackup이 공식적으로 지원하지 않는 애플리케이션이나 사용자 정의 디렉토리도 직접 추가하여 관리할 수 있습니다. 홈 디렉토리에 `.mackup` 폴더를 만들고, 그 안에 `my-custom-app.cfg`와 같은 설정 파일을 만들어주면 됩니다.

예를 들어, 특정 설정 파일 `~/.my-app-config`를 백업하고 싶다면, `.mackup/my-app.cfg` 파일을 다음과 같이 작성합니다.

```ini
[application]
name = My Custom App

[configuration_files]
.my-app-config
```

**사용자 정의 디렉토리 추가 예시:**

만약 `~/my-custom-directory`와 같은 전체 디렉토리를 백업하고 싶다면, `.mackup/my-custom-dir.cfg` 파일을 다음과 같이 작성합니다.

```ini
[application]
name = My Custom Directory

[configuration_files]
my-custom-directory/
```
Mackup은 `configuration_files` 섹션에 나열된 항목이 디렉토리인 경우, 해당 디렉토리의 모든 내용을 백업합니다.

## 기타 유용한 기능

### Copy 모드와 Link 모드

Mackup은 `copy`와 `link` 두 가지 모드로 작동합니다. 
- **Copy 모드 (기본)**: `backup`과 `restore` 명령어로 설정 파일을 복사합니다. 가장 안전하고 권장되는 방식입니다.
- **Link 모드**: 설정 파일을 클라우드 스토리지로 옮긴 후, 원래 위치에 심볼릭 링크를 생성합니다. 이를 통해 여러 기기에서 실시간으로 설정을 동기화할 수 있었지만, 최신 macOS(Sonoma 이상)에서는 시스템 무결성 보호(SIP)로 인해 환경설정 파일에 대한 심볼릭 링크가 제대로 동작하지 않는 문제가 있어 현재는 권장되지 않습니다. 

## 결론

Mackup은 여러 대의 Mac을 사용하거나 새로운 Mac으로 마이그레이션할 때 개발 환경 및 애플리케이션 설정을 일관성 있게 유지해주는 필수 도구입니다. 간단한 명령 몇 줄로 번거로운 설정 과정을 자동화하고, `.mackup.cfg` 파일을 통해 자신만의 동기화 규칙을 만들어보세요. 더 이상 새로운 기기 앞에서 시간을 낭비하지 않아도 될 것입니다.

<!--
[PROMPT_SUGGESTION]Mackup을 Git과 연동하여 버전 관리하는 방법을 알려줘.[/PROMPT_SUGGESTION]
[PROMPT_SUGGESTION]Homebrew Bundle 기능을 사용하여 설치된 애플리케이션 목록을 백업하는 방법을 설명해줘.[/PROMPT_SUGGESTION]
-->
