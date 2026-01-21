---
title: 'Git Worktree: 하나의 저장소, 여러 작업 공간'
tags:
  - git
  - worktree
  - productivity
  - version-control
---
Git Worktree란 무엇이며 왜 필요한가? Stash와의 차이점부터 주요 명령어까지, 효율적인 브랜치 관리

## 개요

개발을 하다 보면 현재 작업 중인 브랜치에서 아직 커밋하지 못한 변경 사항이 있는데, 긴급하게 다른 브랜치(예: 배포를 위한 핫픽스)로 전환해야 하는 상황을 자주 마주하게 됩니다. 보통은 `git stash`를 사용하거나 아직 완료되지 않은 코드를 임시 커밋(WIP)하고 브랜치를 전환하지만, 이러한 방식은 번거롭고 컨텍스트 전환에 비용이 듭니다.

**Git Worktree**는 이런 문제를 우아하게 해결해주는 Git의 강력한 기능입니다. 이 글에서는 Git Worktree의 개념과 필요성, 그리고 `git stash`와의 차이점과 사용법에 대해 알아봅니다.

## Git Worktree란?

기본적으로 Git 저장소(Repository)를 clone하면 하나의 작업 디렉토리(Working Directory)가 생성되고, 이 디렉토리는 한 번에 하나의 브랜치만 체크아웃할 수 있습니다.

**Git Worktree**는 하나의 로컬 저장소에 여러 개의 작업 디렉토리를 연결하여, **동시에 여러 브랜치를 체크아웃**할 수 있게 해주는 기능입니다. 즉, 물리적으로 분리된 여러 폴더에서 서로 다른 브랜치를 띄워놓고 작업할 수 있습니다.

### 핵심 개념
- **Main Working Tree**: `git clone` 시 생성되는 기본 작업 공간.
- **Linked Working Tree**: `git worktree add` 명령어로 생성된 추가 작업 공간들.
- 모든 Worktree는 `.git` 디렉토리(저장소 데이터, 객체 데이터베이스)를 공유합니다. 따라서 디스크 공간을 효율적으로 사용하며, 한 Worktree에서의 커밋은 다른 Worktree에서도 즉시 반영됩니다.
- 현재 작업 디렉토리의 변경 사항(Untracked 파일 포함)을 건드리지 않고, 완전히 깨끗한 새 브랜치 환경을 즉시 얻을 수 있습니다.

## 왜 필요한가요? (활용 사례)

Worktree가 유용한 대표적인 상황들은 다음과 같습니다.

1.  **브랜치 전환의 번거로움 해소**: 현재 기능 개발(`feature-A`) 중에 긴급한 버그 수정 요청(`hotfix`)이 들어왔을 때, 하던 작업을 정리할 필요 없이 새로운 Worktree를 만들어 즉시 수정 작업을 시작할 수 있습니다.
2.  **독립적인 테스트 및 빌드**: 하나의 브랜치에서는 서버를 실행해두고, 다른 브랜치에서는 클라이언트 코드를 수정하거나 테스트 코드를 돌려볼 때 유용합니다. 의존성 패키지(node_modules 등)가 브랜치마다 달라서 충돌이 나는 경우, 폴더가 분리되어 있으므로 서로 영향을 주지 않습니다.
4.  **IDE 및 빌드 환경 유지**: 기존 브랜치에서 IDE 창을 열어두고 서버를 띄워둔 상태 그대로, 새 창에서 다른 작업을 할 수 있습니다. `stash`를 사용했다면 IDE가 파일을 다시 로딩하거나 빌드 캐시가 깨지는 등의 문제가 발생할 수 있지만, worktree는 독립된 환경을 보장합니다.

특히 **Full-stack 개발**처럼 프론트엔드와 백엔드를 동시에 수정해야 하거나, 여러 기능/핫픽스를 동시에 다뤄야 할 때 매우 유용합니다. `git worktree add ../new-work <branch>` 명령어로 간단히 시작할 수 있습니다.

## Stash vs. Worktree

비슷한 상황에서 사용되는 `git stash`와 비교해보면 차이점이 명확합니다.

| 기능 | Git Stash | Git Worktree |
| :--- | :--- | :--- |
| **Untracked 파일** | `-u` 옵션 필요, 실수로 누락 시 오류 발생 가능 | 현재 디렉토리 그대로 유지, 새 작업 공간은 깨끗한 상태 |
| **병렬 작업** | 한번에 하나만 가능 (Push/Pop 반복으로 컨텍스트 손실) | 여러 디렉토리에서 동시 작업 가능 (IDE 여러 개 실행 등) |
| **리스크** | Stash 목록 관리의 어려움 (무엇을 저장했는지 잊음) | 최소화 (공유 .git으로 일관성 유지) |
| **디스크 공간** | 거의 차지하지 않음 | 체크아웃된 파일만큼 추가 사용 |

**정리하자면:**
- **단순하고 짧은 작업 전환**에는 `stash`가 빠르고 간편합니다.
- **긴 호흡의 병렬 작업**, **Untracked 파일을 포함한 복잡한 상태 유지**, **환경 격리**가 필요할 때는 `worktree`가 압도적으로 유리합니다.

## 주요 명령어 사용법

### 1. Worktree 생성 (Add)

새로운 작업 디렉토리를 생성하고 특정 브랜치를 체크아웃합니다.

```bash
# 기본 사용법: git worktree add <경로> <브랜치명>
$ git worktree add ../project-hotfix hotfix/login-bug
```

이렇게 하면 상위 폴더의 `project-hotfix`라는 디렉토리에 `hotfix/login-bug` 브랜치가 체크아웃됩니다. 기존 저장소와는 별개로 완전히 독립된 파일 시스템 공간을 가집니다.

> **Tip**: 기존 브랜치가 없다면 `-b` 옵션으로 새 브랜치를 생성하며 Worktree를 만들 수 있습니다.
> ```bash
> $ git worktree add -b feature/new-ui ../project-ui
> ```

### 2. Worktree 목록 확인 (List)

현재 연결된 모든 Worktree의 목록을 확인합니다.

```bash
$ git worktree list
```

출력 예시:
```text
/Users/user/dev/project       (main)
/Users/user/dev/project-ui    (feature/new-ui)
```

### 3. Worktree 삭제 (Remove)

작업이 끝난 Worktree는 디렉토리를 그냥 지우는 것보다 git 명령어로 정리하는 것이 깔끔합니다 (Git 내부의 메타데이터도 함께 정리됨).

```bash
$ git worktree remove ../project-ui
```

### 4. 정리 (Prune)

만약 Worktree 디렉토리를 파일 탐색기나 `rm` 명령어로 강제 삭제했다면, Git은 해당 Worktree가 유효하지 않다고 판단하지만 목록에는 남아있을 수 있습니다. 이때 `prune`을 사용합니다.

```bash
$ git worktree prune
```

## 유의사항

- **중복 체크아웃 불가**: 하나의 브랜치는 동시에 여러 Worktree에서 체크아웃될 수 없습니다. 이미 `main` 브랜치가 열려있다면 다른 Worktree에서 `main`을 열 수 없습니다.
- **디렉토리 관리**: Worktree 디렉토리는 보통 메인 프로젝트 폴더의 형제(sibling) 폴더로 두는 것이 관리에 용이합니다. 하위 폴더로 둘 경우 `.gitignore` 설정이 꼬일 수 있으므로 주의해야 합니다.

---

Git Worktree는 멀티태스킹이 필수적인 현대 개발 환경에서 매우 강력한 도구입니다. 상황에 맞게 Stash와 Worktree를 적절히 섞어 사용한다면 개발 생산성을 크게 높일 수 있을 것입니다.
