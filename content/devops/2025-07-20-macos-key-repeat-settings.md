---
title: macOS에서 키를 길게 눌렀을 때 동작 변경하기
tags:
  - macos
  - defaults
  - terminal
  - key-repeat
  - ApplePressAndHoldEnabled
---
macOS에서 키를 길게 눌렀을 때 기본적으로 악센트 메뉴(예: "a"를 길게 누르면 à, á, â 등이 표시)가 나타나지만, 이를 키 반복(Windows와 유사한 문자 반복 입력)으로 변경할 수 있습니다. 

## 개요 
이 문서에서는 터미널 명령어(`defaults`)를 사용해 `ApplePressAndHoldEnabled` 설정을 변경하는 방법과 관련된 동작 방식, 설정 확인, 삭제, 주의사항을 설명합니다.  

`ApplePressAndHoldEnabled` 설정은 키를 길게 눌렀을 때의 동작을 제어합니다:

- **`true` (기본값)**: 키를 길게 누르면 악센트 메뉴가 표시됩니다. 예를 들어, "e" 키를 길게 누르면 é, è, ê 등의 선택 메뉴가 나타납니다.
- **`false`**: 키를 길게 누르면 해당 문자가 반복적으로 입력됩니다(예: "eeeee"). 이는 Windows의 키보드 동작과 유사합니다.

이 설정은 시스템 전반 또는 특정 응용 프로그램에 적용할 수 있습니다.

### 명령어 사용법

터미널에서 `defaults` 명령어를 사용하여 설정을 변경할 수 있습니다. 변경 후 일부 앱은 재시작이 필요할 수 있습니다.

### 시스템 전체 설정

- **악센트 메뉴 활성화 (기본값)**:
  ```bash
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true
  ```

- **키 반복 활성화**:
  ```bash
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  ```

### 특정 응용 프로그램 설정

특정 앱(예: 터미널, JetBrains IDE)에만 설정을 적용하려면 앱의 번들 ID를 사용합니다. 예를 들어:

- **터미널에서 키 반복 활성화**:
  ```bash
  defaults write com.apple.terminal ApplePressAndHoldEnabled -bool false
  ```

- **JetBrains IDE (예: IntelliJ IDEA)**:
  JetBrains IDE의 번들 ID는 앱마다 다릅니다(예: `com.jetbrains.intellij`). 번들 ID는 앱의 `Info.plist` 파일에서 확인하거나, 아래 명령어로 앱 목록을 확인할 수 있습니다:
  ```bash
  ls /Applications | grep -i jetbrains
  ```
  이후, 예를 들어:
  ```bash
  defaults write com.jetbrains.intellij ApplePressAndHoldEnabled -bool false
  ```

### 설정 적용

변경 사항을 적용하려면:
1. 터미널에서 명령어를 실행한 후, 영향을 받는 앱을 재시작합니다.
2. 또는 시스템을 로그아웃/로그인하거나 재부팅합니다.

## 설정 확인 및 삭제

### 현재 설정 확인

시스템 전체 설정 확인:
```bash
defaults read NSGlobalDomain ApplePressAndHoldEnabled
```
- 출력: `1` (true, 악센트 메뉴) 또는 `0` (false, 키 반복).

특정 앱 설정 확인 (예: 터미널):
```bash
defaults read com.apple.terminal ApplePressAndHoldEnabled
```

### 설정 삭제 (기본값 복원)

시스템 전체 설정 삭제:
```bash
defaults delete NSGlobalDomain ApplePressAndHoldEnabled
```

특정 앱 설정 삭제:
```bash
defaults delete com.apple.terminal ApplePressAndHoldEnabled
```

삭제 후 macOS는 기본값(`true`, 악센트 메뉴)으로 복원됩니다.

## 추가 설정: 키 반복 속도 조정

키 반복 동작을 세밀히 조정하려면 **시스템 환경설정** 또는 터미널에서 키 반복 속도와 지연 시간을 변경할 수 있습니다.

### 시스템 환경설정

1. **시스템 설정** > **키보드**로 이동.
2. **키 반복(Key Repeat)**: 슬라이더를 조정하여 반복 속도를 설정 (오른쪽으로 갈수록 빠름).
3. **반복 지연(Delay Until Repeat)**: 슬라이더를 조정하여 반복 시작 전 지연 시간 설정 (오른쪽으로 갈수록 짧음).

### 터미널 명령어

- **키 반복 속도**:
  ```bash
  defaults write NSGlobalDomain KeyRepeat -int 2
  ```
  - 값이 낮을수록 반복 속도가 빠릅니다 (기본값: 약 6).

- **반복 지연**:
  ```bash
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  ```
  - 값이 낮을수록 지연 시간이 짧습니다 (기본값: 약 25).

- **적용**:
  ```bash
  killall Finder
  ```
  또는 로그아웃/로그인.

## 주의사항

- **재시작 필요**: `ApplePressAndHoldEnabled` 또는 `KeyRepeat` 설정 변경 후, 앱이나 시스템을 재시작해야 변경 사항이 적용됩니다.
- **응용 프로그램별 설정 우선순위**: 특정 앱에 설정된 값은 시스템 전체 설정(`NSGlobalDomain`)보다 우선합니다.
- **macOS 버전 호환성**: 일부 구형 macOS 버전(예: El Capitan, Sierra)에서는 특정 앱의 동작이 다를 수 있습니다.
- **일관성 문제**: macOS는 `~/Library/Preferences/.GlobalPreferences.plist` 파일에서 설정을 덮어쓸 수 있으므로, 설정이 예상대로 작동하지 않으면 파일을 확인하세요:
  ```bash
  plutil -p ~/Library/Preferences/.GlobalPreferences.plist | grep ApplePressAndHoldEnabled
  ```
- **백업**: 설정 변경 전 `~/Library/Preferences` 폴더를 백업하세요.
- **특정 앱 예외**: JetBrains IDE 등 일부 앱은 자체 키보드 설정을 가질 수 있으므로, 앱 내 설정도 확인하세요.

## 참고

- macOS 버전에 따라 메뉴 이름이나 동작이 약간 다를 수 있습니다(예: macOS Ventura 이상에서는 **시스템 설정** 사용).
- JetBrains IDE의 번들 ID는 [JetBrains 공식 문서](https://www.jetbrains.com) 또는 앱의 `Info.plist` 파일에서 확인 가능.
- 문제 발생 시, macOS 버전을 확인하고 터미널에서 `defaults read`로 현재 설정을 점검하세요.
