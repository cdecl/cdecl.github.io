---
title: "macOS 시스템 최적화의 종결자: Mole 유틸리티와 Agent Skills 활용기"
tags: ["macOS", "Utility", "Mole", "Cleaner", "DevOps", "Agent Skills", "Antigravity"]
---

## 서론

유료 앱들의 핵심 기능을 단 하나의 바이너리로 통합한 강력한 오픈소스 CLI 도구, **Mole**을 소개. 특히 최근 유행하는 AI Agent와 연계하여 시스템 관리를 자동화하는 방법까지 함께 살펴보겠습니다.

## 1. Mole 유틸리티란?

**Mole**([tw93/Mole](https://github.com/tw93/Mole))은 tw93이 개발한 macOS용 올인원 시스템 유틸리티다. Go 언어와 셸 스크립트로 작성되어 매우 가볍고 빠르며, 터미널 환경에서 모든 시스템 최적화 작업을 통합 관리할 수 있다.

### 주요 특징
- **All-in-One**: 청소, 앱 삭제, 최적화, 분석, 실시간 모니터링 기능을 단일 바이너리로 통합.
- **오픈소스**: MIT 라이선스 기반의 무료 도구로, 상업용 앱의 광고나 구독 모델 없이 모든 기능 제공.
- **초경량**: CLI 기반으로 동작하여 시스템 리소스 점유율이 매우 낮음.

## 2. 설치 방법

Homebrew를 통해 간단히 설치 가능하다.

```bash
# Homebrew 설치
brew install mole
```

또는 공식 설치 스크립트 이용:

```bash
curl -fsSL https://raw.githubusercontent.com/tw93/Mole/main/install.sh | bash
```

## 3. 주요 명령어 및 운영 방법

Mole은 목적에 따라 5가지 핵심 명령어를 제공한다.

### 3.1 `mole clean` (시스템 청소)
- **기능**: 캐시, 로그, 임시 파일 및 개발 관련 정크 파일(Xcode, npm 등) 스캔 및 삭제.
- **효과**: 불필요한 파일 제거로 수 GB 이상의 용량 확보.

### 3.2 `mole uninstall` (스마트 앱 제거)
- **기능**: 앱 본체와 함께 라이브러리, 환경설정에 흩어진 잔여 파일 완벽 제거.
- **특징**: 기존 AppCleaner 등의 기능을 CLI로 대체.

### 3.3 `mole optimize` (시스템 최적화)
- **기능**: 시스템 서비스 새로고침 및 캐시 재구축.
- **목적**: 시스템 반응 속도 개선.

### 3.4 `mole analyze` (디스크 분석)
- **기능**: 디스크 점유율 시각화 및 대용량 파일 식별.
- **특징**: DaisyDisk의 CLI 버전 역할.

### 3.5 `mole status` (실시간 모니터링)
- **기능**: CPU, GPU, 메모리, 디스크, 네트워크 상태 실시간 출력.
- **특징**: iStat Menus와 유사한 대시보드 제공.

## 4. Agent Skills와 함께 사용하기

이전 포스팅에서 다룬 **Agent Skills**와 연계하면 Mole의 활용도를 극대화할 수 있다. Antigravity나 Gemini CLI 환경에 전용 스킬을 정의하여 시스템 관리를 자동화한다.

### Mole 전용 스킬 예시 (`mole-manager.md`)
`~/.agent/skills/skills/mole-manager.md` 에 아래 내용을 정의.

```markdown
# Mole System Manager Skill
Mole 유틸리티를 사용하여 macOS 시스템을 진단하고 최적화한다.

## 지침
1. 사용자가 "청소해줘"라고 하면 `mole clean` 실행.
2. 시스템 지연 발생 시 `mole status` 분석 후 `mole optimize` 권장.
3. 앱 삭제 요청 시 `mole uninstall [앱 이름]` 사용.
4. 주기적 `mole analyze`로 대용량 파일 식별.
```

스킬 등록 후, **"@mole-manager 시스템 상태 확인하고 필요한 조치 해줘"** 와 같은 자연어 명령으로 자동화된 관리가 가능해진다.

## 5. 도입 효과

1. **비용 절감**: 다수의 유료 최적화 앱을 하나의 오픈소스 도구로 대체.
2. **개발 환경 최적화**: 개발 도구(npm, docker, xcode) 전용 청소 기능으로 쾌적한 환경 유지.
3. **자동화**: CLI 기반이므로 셸 스크립트나 AI Agent와 즉시 연동 가능.


---
**관련 링크:**
- [Mole GitHub Repository](https://github.com/tw93/Mole)
- [Gemini CLI와 Agent Skills 활용 가이드](file:///Users/cdecl/dev/cdecl.github.io/content/devops/2026-01-25-agent-skills-antigravity-gemini-guide.md)
