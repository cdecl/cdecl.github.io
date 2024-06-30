---
title: Homebrew, Formulae와 Cask의 차이점

toc: true
toc_sticky: true

categories:
  - devops

tags:
  - brew
  - formulae
  - cask
  - macos
---
 
Homebrew는 macOS와 Linux에서 소프트웨어를 쉽게 설치하고 관리할 수 있는 패키지 관리자.

{% raw %}

## Homebrew
- <https://brew.sh/>{:target="_blank"}
- Homebrew는 macOS와 Linux에서 소프트웨어 패키지를 간편하게 설치하고 관리할 수 있는 패키지 관리자   
- Homebrew에는 두 가지 주요 설치 방법인 `Formulae`와 `Cask`가 있습니다. 
- Formulae와 Cask의 차이점과 동일한 애플리케이션이 두 가지 방법으로 제공되는 예시를 설명

### Homebrew 설치

#### macOS
```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ brew --version  # 설치 확인
```

#### Linux
```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
$ eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
$ brew --version  # 설치 확인
```

### Homebrew 주요 명령어

#### Formulae 설치 (CLI 애플리케이션)
```sh
brew install <package-name>
```
예: `wget` 설치
```sh
brew install wget
```

#### Cask 설치 (GUI 애플리케이션)
```sh
brew install --cask <package-name>
```
예: `Google Chrome` 설치
```sh
brew install --cask google-chrome
```

### 소프트웨어 업데이트 및 업그레이드
```sh
brew update       # Homebrew 업데이트
brew upgrade      # 소프트웨어 업그레이드
```

### 소프트웨어 제거
```sh
brew uninstall <package-name>          # Formulae 제거
brew uninstall --cask <package-name>   # Cask 제거
```

### 기타 유용한 명령어
```sh
brew list         # 설치된 소프트웨어 목록 보기
brew info <package-name>  # 소프트웨어 정보 보기
brew cleanup      # 캐시 정리
brew doctor       # 문제 해결
```

---


## Formulae와 Cask의 차이점

### Formulae

- **설치 소프트웨어 유형**: 주로 CLI (Command Line Interface) 애플리케이션
- **설치 방법**: 소스 코드를 다운로드하여 컴파일 후 설치
- **설치 명령어**:
  ```sh
  brew install <package-name>
  ```
- **구성 파일**: Ruby 스크립트 파일로 작성, 설치 과정과 종속성 정의
- **설치 위치**: 일반적으로 `/usr/local/Cellar`
  
### Cask

- **설치 소프트웨어 유형**: 주로 GUI (Graphical User Interface) 애플리케이션, 폰트, 플러그인 등
- **설치 방법**: 애플리케이션의 바이너리를 다운로드하여 설치 (DMG, ZIP, 설치 패키지 파일 등)
- **설치 명령어**:
  ```sh
  brew install --cask <package-name>
  ```
- **구성 파일**: Ruby DSL(Domain Specific Language) 파일로 작성, 다운로드 URL, 체크섬, 설치 스크립트 정의
- **설치 위치**: 일반적으로 `/Applications`

---

> Formulae와 Cask를 모두 제공하는 애플리케이션을 통한 예시

#### Visual Studio Code

`Visual Studio Code`는 Microsoft에서 제공하는 인기 있는 코드 편집기입니다. 이 애플리케이션은 CLI 도구와 GUI 애플리케이션으로 모두 사용할 수 있어 Formulae와 Cask로 모두 제공됩니다.

- **Formulae로 설치**:
  ```sh
  brew install visual-studio-code
  ```
  - 이 명령어는 Visual Studio Code의 CLI 도구만 설치합니다.

- **Cask로 설치**:
  ```sh
  brew install --cask visual-studio-code
  ```
  - 이 명령어는 Visual Studio Code 전체 GUI 애플리케이션을 설치합니다.

#### Java

Java 개발 키트(JDK)는 다양한 버전과 배포본이 존재하며, CLI 도구와 GUI 관리 도구로 모두 사용할 수 있습니다.

- **Formulae로 설치**:
  ```sh
  brew install openjdk
  ```
  - 이 명령어는 OpenJDK를 설치합니다.

- **Cask로 설치**:
  ```sh
  brew install --cask java
  ```
  - 이 명령어는 Oracle JDK를 포함한 Java GUI 관리 도구를 설치합니다.

#### ffmpeg

`ffmpeg`는 비디오와 오디오를 처리하기 위한 강력한 CLI 도구입니다. GUI 프론트엔드가 있는 경우 Cask로도 제공될 수 있습니다.

- **Formulae로 설치**:
  ```sh
  brew install ffmpeg
  ```
  - 이 명령어는 `ffmpeg` 소스 코드를 다운로드하고 컴파일하여 설치합니다.

- **Cask로 설치**:
  ```sh
  brew install --cask ffmpegx
  ```
  - 이 명령어는 `ffmpeg`의 GUI 프론트엔드인 `ffmpegX`를 설치합니다.

---

## 결론
- Homebrew의 Formulae와 Cask는 각각 CLI 애플리케이션과 GUI 애플리케이션을 설치하는 데 적합한 방법을 제공합니다   
- 일부 애플리케이션은 이 두 가지 방법으로 모두 제공되어 사용자가 필요에 따라 적합한 설치 방법을 선택할 수 있음
- 이를 통해 Homebrew는 macOS와 Linux 사용자가 다양한 소프트웨어를 쉽게 설치하고 관리할 수 있도록 도와줍니다.

{% endraw %}

