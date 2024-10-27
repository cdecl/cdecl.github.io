---
title: Git 커밋 메시지 수정

toc: true
toc_sticky: true

categories:
  - dev

tags:
tags:
  - git
  - git rebase
  - git rebase
  - git commit 수정
  - git reword
  - git edit
  - git commit --amend
  - force push
---
 
Git 커밋 메시지 수정

{% raw %}

## Git 커밋 메시지 수정 가이드

Git을 사용하다 보면 커밋 메시지를 수정해야 할 경우가 자주 발생합니다.   
이 글에서는 가장 기본적인 방법부터 고급 기술까지 모든 커밋 메시지 수정 방법을 다루겠습니다.

## 기본적인 커밋 메시지 수정 방법

### 1. 가장 최근 커밋 메시지 수정
가장 최근의 커밋 메시지를 수정하는 것은 매우 간단합니다.

```bash
git commit --amend
```

또는 에디터를 열지 않고 직접 메시지를 입력할 수우도 있습니다:

```bash
git commit --amend -m "새로운 커밋 메시지"
```

### 2. 커밋 내용과 메시지 함께 수정
파일 변경사항을 포함하여 최근 커밋을 수정할 수 있습니다:

```bash
# 파일 수정 후
git add 수정된_파일
git commit --amend
```

### 3. 커밋 날짜 업데이트
커밋의 날짜를 현재 시간으로 업데이트하면서 수정:

```bash
git commit --amend --date="now"
```

## rebase를 이용한 고급 수정 방법

### reword와 edit 명령어 비교

| 기능             | reword    | edit           |
| ---------------- | --------- | -------------- |
| 커밋 메시지 수정 | ✅         | ✅              |
| 커밋 내용 수정   | ❌         | ✅              |
| 실행 복잡도      | 낮음      | 높음           |
| 작업 중단 여부   | 자동 진행 | 수동 진행 필요 |

### reword 사용법
reword는 커밋 메시지만 수정할 때 사용합니다.

```bash
# 1. 대화형 rebase 시작
git rebase -i HEAD~3  # 최근 3개의 커밋 수정

# 2. 에디터에서 수정할 커밋의 'pick'을 'reword'로 변경
pick 1a2b3c4 첫 번째 커밋
reword 2d3e4f5 두 번째 커밋
pick 3g4h5i6 세 번째 커밋

# 3. 저장 후 종료하면 새 에디터가 열림
# 4. 새 커밋 메시지 입력
# 5. 저장 후 종료
```

### edit 사용법
edit은 커밋 메시지와 내용을 모두 수정할 때 사용합니다.

```bash
# 1. 대화형 rebase 시작
git rebase -i HEAD~3

# 2. 에디터에서 'pick'을 'edit'으로 변경
pick 1a2b3c4 첫 번째 커밋
edit 2d3e4f5 두 번째 커밋
pick 3g4h5i6 세 번째 커밋

# 3. rebase가 해당 커밋에서 중지됨
# 4. 파일 수정
git add 수정된_파일
git commit --amend

# 5. rebase 계속 진행
git rebase --continue
```

## 사용 예제

### 1. 최근 커밋 수정하기
```bash
# 메시지만 수정
git commit --amend -m "새로운 메시지"

# 파일 내용도 함께 수정
git add 수정된_파일
git commit --amend
```

### 2. 이전 커밋 수정하기
```bash
# reword로 메시지만 수정
git rebase -i HEAD~3
# 에디터에서 'reword' 선택

# edit으로 내용까지 수정
git rebase -i HEAD~3
# 에디터에서 'edit' 선택
git add 수정할_파일
git commit --amend
git rebase --continue
```

### 3. 여러 커밋 한 번에 수정하기
```bash
git rebase -i HEAD~5
# 여러 커밋의 'pick'을 'reword'나 'edit'으로 변경
```

## 주의사항

### 1. 공유된 브랜치 작업 시 주의점
- 이미 push한 커밋 수정 시 force push 필요
- 팀 브랜치는 신중하게 수정
- force push 시 --force-with-lease 권장

```bash
git push --force-with-lease origin branch-name
```

### 2. 안전한 작업을 위한 팁
```bash
# 작업 전 백업 브랜치 생성
git checkout -b backup/feature-branch

# 문제 발생 시 rebase 취소
git rebase --abort

# 충돌 발생 시
git add .
git rebase --continue
```

### 3. 커밋 수정 시 고려사항
- 의미 있는 커밋 메시지 작성
- 하나의 커밋은 하나의 논리적 변경사항만 포함
- 커밋 메시지는 명확하고 상세하게 작성
- 팀의 커밋 메시지 컨벤션 준수

## 결론

Git은 커밋 수정을 위한 다양한 도구를 제공합니다:
- 간단한 수정은 `--amend` 사용
- 복잡한 수정은 `rebase` 활용
- reword는 메시지만, edit은 전체 수정 시 사용
- 공유 브랜치 작업 시 항상 신중하게 접근

이러한 도구들을 적절히 활용하면 깔끔한 커밋 히스토리를 유지할 수 있습니다. 하지만 항상 팀과의 협업을 고려하여 신중하게 사용해야 합니다.

## 참고 자료
- Git 공식 문서: [https://git-scm.com/book/ko/v2](https://git-scm.com/book/ko/v2)
- Git Rebase 문서: [https://git-scm.com/docs/git-rebase](https://git-scm.com/docs/git-rebase)

{% endraw %}
 