---
title: Git Repository 복제, Branch 동기화 관리
tags:
  - git
  - git repository mirror
  - git branch
  - git branch all tracking
last_modified_at: '2024-11-25'
---
# Git Repository 복제 및 Branch 관리 가이드



## Git Repository 복제

### Remote → Local 복제  
Git 저장소를 복제하는 방법에는 여러 가지가 있으며, 각각의 방식에 따라 다른 특징이 있습니다.

#### `--mirror` 복제의 특징
- `git clone --mirror`: Remote repository의 모든 참조(`refs`)를 포함하여 Local에 저장
- 기본 `clone`과 달리 작업 디렉토리 없이 저장소의 메타데이터 전체를 복제
- 주로 저장소 백업이나 완전한 미러링에 사용

```sh
# mirror 복제
$ git clone --mirror https://github.com/cdecl/test

$ tree -d
.
└── test.git
    ├── branches
    ├── hooks
    ├── info
    ├── objects
    │   ├── info
    │   └── pack
    └── refs
        ├── heads
        └── tags
```

> 💡 추가 정보:
> - `--mirror`는 모든 refs(브랜치, 태그, 참조)를 포함하여 정확히 복제
> - 대용량 저장소의 경우 네트워크 대역폭과 디스크 공간을 충분히 고려해야 함
> - 개인 프로젝트나 백업 목적에 가장 적합

#### 복제 업데이트 방법
```sh
# 미러 저장소 업데이트
$ git remote update
```

### Local → Remote 복제 
원격 저장소로 전체 저장소를 복제하는 방법입니다.

```sh
$ cd test.git

# 원격 저장소 URL 변경 (옵션)
# git remote set-url origin https://gitlab.com/cdeclare/test 

# 전체 저장소 미러링
$ git push --mirror https://gitlab.com/cdeclare/test
```

> ⚠️ 주의사항:
> 다음과 같은 에러가 발생할 수 있습니다:
> - GitHub pull requests 이력
> - Gitlab protected branches 설정

```sh
# GitHub pull requests 이력
 ! [remote rejected] refs/pull/1/head -> refs/pull/1/head (deny updating a hidden ref)

# Gitlab protected branches 설정
 ! [remote rejected] master -> master (pre-receive hook declined)
```

- [! [remote rejected] errors after mirroring a git repository](https://stackoverflow.com/questions/34265266/remote-rejected-errors-after-mirroring-a-git-repository){:target="_blank"} 

--- 

## Branch 관리 

### Branch 기본 명령어

```sh
# branch 생성
$ git branch dev

# branch 전환
$ git checkout dev 

# branch 삭제
$ git branch -d dev 

# branch 생성 및 전환 
$ git checkout -b dev
Switched to a new branch 'dev'
```

### Remote Branch Tracking 

```sh
# remote branch tracking 
$ git branch -t dev origin/dev

# remote branch tracking + 전환 
$ git checkout -t origin/dev
```

#### Remote branch 전체 tracking 
특정 명령어를 통해 모든 원격 브랜치를 로컬로 추적할 수 있습니다.

```sh
# remote repository (branch) 정보 동기화
# -p, --prune: 원격 브랜치 프루닝
$ git remote update -p 

# 현재 브랜치 및 원격 브랜치 확인
$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/dev9
  remotes/origin/master
  remotes/origin/newb

# 모든 원격 브랜치 로컬 추적
$ git branch -r | grep -v -- "->" | xargs -i git checkout -t {}
Branch 'origin/dev9' set up to track local branch 'master'.
Branch 'origin/master' set up to track local branch 'master'.
Branch 'origin/newb' set up to track local branch 'master'.

# 추적 후 브랜치 상태
$ git branch -a
* master
  origin/dev9
  origin/master
  origin/newb
  remotes/origin/HEAD -> remotes/origin/master
  remotes/origin/dev9
  remotes/origin/master
  remotes/origin/newb
```

> 💡 추적 스크립트 분석:
> - `-r`: 원격 브랜치만 나열
> - `grep -v -- "->"`: 포인터(HEAD) 제외
> - `xargs -i`: 각 브랜치에 대해 명령 실행
> - `git checkout -t`: 원격 브랜치 자동 추적

### Branch Push 관리

```sh
# 특정 branch push
$ git push -u origin dev

# 모든 Branch Push 
$ git push --all 
```

### Remote Branch 삭제 및 동기화

```sh
# remote branch 삭제 
$ git push origin -d newb

# Local → Remote Branch 전체 동기화
$ git push --mirror
```


## 추가 Git Branch 관리 팁

### 브랜치 명명 모범 사례
- 기능 브랜치: `feature/기능명`
- 버그 수정 브랜치: `bugfix/버그설명`
- 릴리즈 브랜치: `release/버전`
- 핫픽스 브랜치: `hotfix/긴급수정사항`

### 브랜치 정보 확인 명령어
```sh
# 로컬 브랜치 목록
git branch

# 원격 브랜치 포함 전체 브랜치 목록
git branch -a

# 각 브랜치의 최근 커밋 확인
git branch -v
```

## 주의사항
- 모든 원격 브랜치를 자동 추적할 때는 주의가 필요합니다.
- 불필요한 브랜치 추적은 로컬 저장소의 복잡성을 증가시킬 수 있습니다.
- 협업 시 팀의 브랜치 관리 정책을 명확히 수립하세요.


