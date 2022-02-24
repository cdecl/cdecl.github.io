---
title: Git Repository 복제, Branch 동기화 관리 

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - git
  - git repository mirror
  - git branch
  - git branch all tracking
---

Git Repository 복제 `--mirror` 및 Branch 관리

{% raw %}

## Git Repository 복제

### Remote → Local 복제  
- `git clone --mirror`
- Remote repository `--bare` 포함, 참조 `refs` 까지 모두 Local에 저장  
- [What's the difference between git clone --mirror and git clone --bare](https://stackoverflow.com/questions/3959924/whats-the-difference-between-git-clone-mirror-and-git-clone-bare){:target="_blank"}  
- [How to update a git clone --mirror?](https://stackoverflow.com/questions/6150188/how-to-update-a-git-clone-mirror){:target="_blank"}  
  - `git remote update`

```sh
# mirror
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

### Local → Remote 복제 
- `git push --mirror`

```sh
$ cd test.git

# git remote set-url origin https://gitlab.com/cdeclare/test 
# git push --mirror 
$ git push --mirror https://gitlab.com/cdeclare/test
```

> 아래와 같은 에러는 GitHub pull requests, Gitlab protected branches 있을때 발생

```sh
# GitHub pull requests 이력
 ! [remote rejected] refs/pull/1/head -> refs/pull/1/head (deny updating a hidden ref)

# Gitlab protected branches 설정
 ! [remote rejected] master -> master (pre-receive hook declined)
```

- [! [remote rejected] errors after mirroring a git repository](https://stackoverflow.com/questions/34265266/remote-rejected-errors-after-mirroring-a-git-repository){:target="_blank"} 

--- 

## Branch 관리 

### Branch 기본

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

### Remote branch tracking 

```sh
# remote branch tracking 
$ git branch -t dev origin/dev

# remote branch tracking + 전환 
$ git checkout -t origin/dev
```

#### Remote branch 전체 tracking 
- `git branch -r | grep -v -- "->" | xargs -i git checkout -t {}`

```sh
# remote repository (branch) 정보 동기화
# -p, --prune           prune remotes after fetching
# git remote update -p 
$ git remote update

# -a, --all
# -r, --remotes
$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/dev9
  remotes/origin/master
  remotes/origin/newb

# git remote branch tracking
# git branch -t <branch name>
$ git branch -r | grep -v -- "->" | xargs -i git checkout -t {}
Branch 'origin/dev9' set up to track local branch 'master'.
Branch 'origin/master' set up to track local branch 'master'.
Branch 'origin/newb' set up to track local branch 'master'.

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


### Branch push 

```sh
# branch push
# git checkout dev && git push
$ git push -u origin dev

# 전체 Branch Push 
$ git push --all 
```

### Remote branch 삭제 및 동기화

```sh
# remote branch delete 
$ git push origin -d newb

# Local → Remote Branch 동기화 : Local 기준으로 생성/삭제
$ git push --mirror
```


{% endraw %}
