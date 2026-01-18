---
title: 사례로 보는 Git 트러블 슈팅

toc: true
toc_sticky: true

categories:
  - dev

tags:
  - git
  - troubleshooting
  - checkout
  - stash
  - branch
  - reset
  - revert
---

Git은 강력하지만, 복잡한 상황에서는 개발자를 당황하게 만드는 경우가 많습니다. "앗, 방금 뭘 한 거지?" 싶은 순간은 누구에게나 찾아옵니다. 이 글에서는 `checkout`, `stash`, `branch` 등 핵심 명령어를 중심으로, 실제 현업에서 자주 겪는 20가지 트러블 슈팅 사례와 해결 방안을 구체적으로 정리했습니다.

---

## Part 1: `checkout` 관련 문제 - "코드가 뒤섞였어요!"

`checkout`은 브랜치를 바꾸거나 특정 버전으로 돌아갈 때 사용하지만, 이 과정에서 많은 실수가 발생합니다.

#### 사례 1: 다른 브랜치로 이동하려는데, 작업하던 내용이 있어서 막힐 때

-   **문제 상황:** `feature/new-login` 브랜치에서 작업하던 중, 급하게 `hotfix/bug-report` 브랜치로 이동해야 합니다. `git checkout hotfix/bug-report`를 입력하니 "error: Your local changes to the following files would be overwritten by checkout..." 메시지가 나옵니다.
-   **해결 방안:** 아직 커밋하기 애매한 작업 내용을 임시 저장 공간(`stash`)에 저장합니다.
    ```bash
    # 현재 작업 내용을 스택에 임시 저장
    git stash
    > `git stash`: 현재 작업 디렉터리의 변경된 파일(Tracked files)을 임시로 스택에 저장합니다. `push`, `pop`, `apply`, `list` 등의 하위 명령어를 통해 관리할 수 있습니다.

    # 원하는 브랜치로 이동하여 작업 수행
    git checkout hotfix/bug-report
    # ... 핫픽스 작업 ...
    git commit -m "Fix: Critical bug"
    git push origin hotfix/bug-report

    # 원래 브랜치로 복귀
    git checkout feature/new-login

    # 임시 저장했던 작업 내용 다시 적용
    git stash pop
    ```

#### 사례 2: 실수로 파일을 삭제했는데, 커밋은 아직 안 했을 때 (`rm a.txt`)

-   **문제 상황:** `git rm`이 아닌 `rm` 명령어로 파일을 삭제했습니다. `git status`에 "deleted: a.txt"로 표시됩니다.
-   **해결 방안:** `checkout`을 사용해 현재 브랜치(HEAD)의 마지막 커밋 상태에서 해당 파일을 복원합니다.
    ```bash
    # a.txt 파일을 마지막 커밋 상태로 복원
    git checkout HEAD -- a.txt
    ```
    > `git checkout <commit> -- <file>`: 특정 커밋 상태의 특정 파일을 현재 작업 디렉터리로 복원합니다. `--`는 브랜치/커밋과 파일 경로를 명확하게 구분하는 역할을 합니다.

    # -- 를 사용하면 브랜치 이름과 파일 이름을 명확히 구분할 수 있어 안전합니다.

#### 사례 3: 브랜치를 옮기지 않고 다른 브랜치의 파일 내용만 보고 싶을 때

-   **문제 상황:** 현재 브랜치는 `feature`인데, `main` 브랜치의 `config.yml` 파일 내용과 비교하고 싶습니다. 브랜치를 통째로 옮기기엔 부담스럽습니다.
-   **해결 방안:** `git show` 또는 `git checkout`을 특정 파일에 대해서만 실행합니다.
    ```bash
    # 1. git show 사용 (단순 조회)
    git show main:path/to/config.yml
    > `git show <branch>:<path/to/file>`: 브랜치를 변경하지 않고, 다른 브랜치에 있는 파일의 내용을 터미널에 출력합니다.

    # 2. git checkout 사용 (현재 작업 디렉터리로 가져오기)
    git checkout main -- path/to/config.yml
    # 위 명령은 `main` 브랜치의 `config.yml`을 현재 디렉터리로 가져와 덮어씁니다.
    # 주의: 현재 작업 디렉터리의 내용이 변경됩니다.
    ```

#### 사례 4: "Detached HEAD" 상태가 되었을 때

-   **문제 상황:** `git checkout <commit-hash>` 나 `git checkout origin/main` 처럼 브랜치가 아닌 포인터를 직접 체크아웃하면 "You are in 'detached HEAD' state." 라는 메시지가 나옵니다. 이 상태에서 작업하고 커밋하면 해당 커밋은 어떤 브랜치에도 속하지 않게 되어 나중에 잃어버릴 수 있습니다.
-   **해결 방안:** 현재 "Detached HEAD" 상태에서 새로운 브랜치를 만들어 작업을 이어갑니다.
    ```bash
    # 현재 위치에서 'temp-work' 라는 새 브랜치를 생성
    git checkout -b temp-work
    ```
    > `git checkout -b <new-branch>`: 현재 위치(커밋)에서 새로운 브랜치를 생성하고, 즉시 해당 브랜치로 전환합니다.

    # 이제 'temp-work' 브랜치에서 안전하게 커밋을 이어갈 수 있습니다.
    git add .
    git commit -m "Add new feature from detached state"
    ```

#### 사례 5: 과거의 특정 파일 버전 하나만 현재 브랜치로 가져오고 싶을 때

-   **문제 상황:** `config.js` 파일의 과거 버전이 필요합니다. 3개의 커밋 전(`HEAD~3`) 버전의 `config.js`만 현재 작업 내용에 덮어쓰고 싶습니다.
-   **해결 방안:** `git checkout`에 커밋 해시와 파일 경로를 지정합니다.
    ```bash
    # 3개 커밋 전 버전의 'config.js'를 현재 디렉터리로 가져옴
    git checkout HEAD~3 -- src/config.js
    ```
    > `git checkout <commit> -- <file>`: 특정 커밋에 해당하는 파일의 버전으로 현재 작업 디렉터리의 파일을 덮어씁니다.

---

## Part 2: `stash` 관련 문제 - "작업 내용이 사라졌어요!"

`stash`는 매우 유용한 임시 저장 기능이지만, 여러 개가 쌓이면 혼란스러워집니다.

#### 사례 6: Stash 이름 없이 저장해서 뭐가 뭔지 모를 때

-   **문제 상황:** 여러 번 `git stash`를 실행했더니 `stash@{0}`, `stash@{1}` ... 목록만 있고, 어떤 내용이 저장되었는지 기억나지 않습니다.
-   **해결 방안 1:** `git stash list`로 목록을 보고, `git stash show`로 각 내용을 확인합니다.

   
    ```bash
    git stash list
    

    # stash@{0}: WIP on feature/login: ...
    # stash@{1}: WIP on feature/login: ...

    # stash@{1}의 변경 내용 요약 보기
    git stash show stash@{1}

    # stash@{1}의 변경 내용 상세 보기 (diff)
    git stash show -p stash@{1}
    ```
    > `git stash list`: 현재 저장된 모든 stash 목록을 최신 순으로 보여줍니다.
    
-   **해결 방안 2:** 처음부터 `git stash push -m "메시지"` 로 저장합니다. (`git stash save`는 더 이상 권장되지 않습니다.)
    ```bash
    git stash push -m "Finish login UI, before API integration"
    ```

#### 사례 7: Untracked 파일(새로 만든 파일)은 `stash`에 포함되지 않았을 때

-   **문제 상황:** 새로 만든 파일(`new-component.js`)과 기존 파일 수정을 함께 `git stash`했는데, 브랜치를 옮겼다 돌아와 `stash pop`하니 새로 만든 파일이 사라졌습니다.
-   **해결 방안:** `stash` 시 `-u` 또는 `--include-untracked` 옵션을 사용합니다.
    ```bash
    # Untracked 파일까지 포함하여 stash
    git stash -u
    ```

#### 사례 8: 다른 브랜치에서 작업한 내용을 현재 브랜치에 적용하고 싶을 때

-   **문제 상황:** `feature/A`에서 작업하던 내용을 커밋 없이 `stash`하고, `feature/B`로 넘어왔습니다. `feature/A`의 작업 내용 일부가 `feature/B`에서도 필요합니다.
-   **해결 방안:** `git stash branch`를 사용해 stash로부터 새로운 브랜치를 생성합니다.
    ```bash
    # 현재 `feature/B` 브랜치에서...
    # 가장 최근의 stash (stash@{0}) 내용으로 'temp-branch' 생성
    git stash branch temp-branch stash@{0}

    # 이제 'temp-branch'는 'feature/A'에서 작업하던 내용을 커밋할 수 있는 상태가 됩니다.
    # 여기서 필요한 내용을 커밋한 뒤, 'feature/B'에서 `cherry-pick` 등으로 가져올 수 있습니다.
    ```

#### 사례 9: `stash pop` 실행 시 충돌(Conflict)이 발생했을 때

-   **문제 상황:** `stash`를 한 이후, 현재 브랜치에서 `stash`에 저장된 내용과 동일한 라인을 수정했습니다. `git stash pop`을 하니 충돌이 발생합니다.
-   **해결 방안:** 일반적인 `merge` 충돌과 동일하게 해결합니다.
    1.  충돌이 발생한 파일을 열어 `<<<<<`, `=====`, `>>>>>` 마커를 확인하고 코드를 올바르게 수정합니다.
    2.  수정한 파일을 `git add` 합니다.
    3.  `git stash drop`을 실행하여 적용된 stash를 스택에서 제거합니다. (`pop`은 충돌 시 자동으로 drop되지 않습니다.)

    ```bash
    # 1. 코드 수정 후
    git add .

    # 2. 변경 사항 커밋 (필요 시)
    git commit -m "Resolve stash conflict"

    # 3. 적용된 stash 제거
    git stash drop
    ```

#### 사례 10: 실수로 `stash clear`를 실행하여 모든 stash가 사라졌을 때

-   **문제 상황:** 중요한 내용이 `stash`에 있었는데, `git stash clear`로 모두 삭제해버렸습니다.
-   **해결 방안:** Git이 아직 가비지 컬렉션(GC)을 실행하지 않았다면, `fsck`로 복구할 수 있습니다.
    ```bash
    # Git 데이터베이스에서 유효성을 검사하며 "dangling" 객체를 찾음
    git fsck --no-reflogs
    # ... 수많은 해시값 출력 ...

    # 위에서 찾은 "dangling commit" 해시들을 하나씩 확인하여 stash 내용을 찾음
    git show <dangling-commit-hash>

    # 원하는 stash를 찾았다면, 해당 커밋에서 브랜치를 만들어 복구
    git branch recovered-stash <dangling-commit-hash>
    ```
    이 방법은 복잡하고 항상 성공하는 것은 아니므로, 중요한 작업은 `stash`보다는 커밋으로 남기는 습관이 좋습니다.

---

## Part 3: `branch` 및 병합 관련 문제 - "브랜치가 꼬였어요!"

브랜치 전략은 협업의 핵심이며, 가장 많은 문제가 발생하는 곳이기도 합니다.

#### 사례 11: `main` 브랜치에 직접 커밋해버렸을 때

-   **문제 상황:** `feature` 브랜치에서 작업해야 할 내용을 실수로 `main` 브랜치에 커밋했습니다. 아직 `push`는 하지 않았습니다.
-   **해결 방안:** `main` 브랜치를 이전 커밋으로 되돌리고, 새 브랜치를 만들어 해당 커밋을 가져옵니다.
    ```bash
    # 1. 현재 `main` 브랜치에서...
    # 올바른 `feature` 브랜치를 생성
    git branch feature/my-work

    # 2. `main` 브랜치를 이전 상태로 되돌림 (실수로 한 커밋 제거)
    # origin/main, 즉 원격 저장소의 상태로 강제 리셋
    git reset --hard origin/main

    # 3. 이제 새 브랜치로 이동하여 작업을 이어감
    git checkout feature/my-work
    ```

#### 사례 12: 실수로 `push`까지 해버린 커밋을 되돌리고 싶을 때

-   **문제 상황:** `main`에 잘못 커밋하고 `push`까지 해버렸습니다. 다른 팀원들이 `pull` 받기 전에 빨리 조치해야 합니다.
-   **해결 방안:** `revert`를 사용하여 "잘못된 커밋을 되돌리는 새로운 커밋"을 만듭니다.
    ```bash
    # `main` 브랜치에서...
    # 되돌리고 싶은 마지막 커밋을 타겟으로 `revert` 실행
    git revert HEAD

    # revert 커밋 메시지 저장 후, 변경 사항을 push
    git push origin main
    ```
    `reset --hard` 후 `push -f`를 하는 것은 팀원들의 히스토리를 엉망으로 만들 수 있으므로, 공유된 브랜치에서는 절대적으로 피해야 합니다. `revert`가 안전한 대안입니다.

#### 사례 13: 브랜치 이름을 변경하고 싶을 때 (로컬 & 원격)

-   **문제 상황:** 브랜치 이름에 오타가 있거나, 컨벤션을 따르지 않아 변경하고 싶습니다. (예: `feture/login` -> `feature/login`)
-   **해결 방안:**
    ```bash
    # 1. 현재 브랜치 이름 변경
    git branch -m feature/login

    # 2. 원격의 옛날 브랜치 삭제
    git push origin --delete feture/login

    # 3. 새로 바꾼 이름의 브랜치를 원격에 push
    git push origin -u feature/login
    ```

#### 사례 14: 다른 브랜치의 특정 커밋 하나만 현재 브랜치로 가져오고 싶을 때

-   **문제 상황:** `hotfix` 브랜치에서 수정한 버그 픽스 커밋(`a1b2c3d`)이 현재 개발 중인 `feature` 브랜치에도 즉시 필요합니다.
-   **해결 방안:** `cherry-pick`을 사용합니다.
    ```bash
    # `feature` 브랜치에서...
    git cherry-pick a1b2c3d
    ```

#### 사례 15: 너무 자잘하게 나눠진 커밋들을 하나로 합치고 싶을 때 (Push 전)

-   **문제 상황:** "Fix typo", "Add comment", "Refactor" 등 의미 없는 커밋이 너무 많아 PR 올리기 전에 정리하고 싶습니다.
-   **해결 방안:** `rebase -i` (interactive rebase)를 사용합니다.
    ```bash
    # 합치고 싶은 커밋의 *이전* 커밋 해시를 지정 (예: 최근 3개)
    git rebase -i HEAD~3
    ```
    -   위 명령을 실행하면 편집기가 열리고, 커밋 목록이 나옵니다.
    -   맨 위 커밋은 `pick`으로 두고, 나머지 커밋 앞의 `pick`을 `s` 또는 `squash`로 변경합니다.
    -   저장하고 닫으면, 커밋 메시지를 새로 작성하는 창이 열립니다. 하나의 깔끔한 메시지로 정리합니다.

---

## Part 4: 기타 고급 트러블 슈팅

#### 사례 16: 실수로 `git add` 한 파일을 다시 내리고 싶을 때

-   **문제 상황:** 커밋하고 싶지 않은 파일(`secret.key`)을 실수로 Staging Area에 추가(`add`)했습니다.
-   **해결 방안:** `git reset`을 사용합니다.
    ```bash
    # 특정 파일만 Staging Area에서 내림
    git reset HEAD secret.key

    # 모든 파일을 Staging Area에서 내림
    git reset
    ```

#### 사례 17: 마지막 커밋 메시지에 오타가 있을 때

-   **문제 상황:** 방금 커밋했는데, 메시지에 오타가 있습니다. 아직 `push`는 안했습니다.
-   **해결 방안:** `commit --amend`를 사용합니다.
    ```bash
    git commit --amend
    # 편집기가 열리면 메시지를 수정하고 저장
    ```
    **주의:** `push` 한 커밋에는 절대 사용하면 안 됩니다.

#### 사례 18: 브랜치를 삭제했는데, 다시 복구해야 할 때

-   **문제 상황:** `git branch -D my-feature`로 브랜치를 강제 삭제했는데, 아직 `main`에 병합되지 않은 중요한 커밋이 있었습니다.
-   **해결 방안:** `reflog`를 사용하여 Git의 모든 참조 변경 기록을 확인합니다.
    ```bash
    git reflog
    # ...
    # a1b2c3d HEAD@{5}: checkout: moving from my-feature to main
    # ...

    # 삭제된 브랜치의 마지막 커밋 해시(a1b2c3d)를 찾았다면,
    # 해당 커밋에서 브랜치를 다시 생성
    git checkout -b recovered-feature a1b2c3d
    ```

#### 사례 19: 현재 작업 내용 전체를 특정 과거 커밋 시점으로 되돌리고 싶을 때

-   **문제 상황:** 최근 몇 개의 커밋이 완전히 잘못된 방향으로 진행되어, `a1b2c3d` 커밋 시점으로 모든 것을 되돌리고 싶습니다. 로컬에서의 변경 사항이므로 히스토리가 깨져도 상관없습니다.
-   **해결 방안:** `reset --hard`를 사용합니다. **(경고: 복구 불가능한 데이터 손실을 유발할 수 있습니다!)**
    ```bash
    # 모든 변경사항, 커밋을 버리고 'a1b2c3d' 상태로 돌아감
    git reset --hard a1b2c3d
    ```

#### 사례 20: `pull`을 받았더니 관련 없는 커밋 히스토리가 잔뜩 병합될 때

-   **문제 상황:** `main` 브랜치에서 `feature` 브랜치를 따서 작업 후, `feature` 브랜치에서 `git pull origin main`을 실행했습니다. 의도와 달리 수많은 `main`의 커밋들이 `Merge branch 'main' into feature` 라는 메시지와 함께 들어왔습니다.
-   **해결 방안:** `pull` 시 `rebase` 옵션을 사용하거나, `git config`로 기본값으로 설정합니다. `Rebase`는 `main`의 변경사항을 내 브랜치의 "베이스"로 다시 설정하여, 내 커밋들을 그 위에 차곡차곡 쌓아줍니다. 히스토리가 훨씬 깔끔해집니다.
    ```bash
    # 1. 일회성으로 rebase pull 실행
    git pull origin main --rebase

    # 2. 향후 모든 pull을 rebase로 실행하도록 설정
    git config --global pull.rebase true
    ```

#### 사례 21: 특정 커밋을 찾기 위해 로그를 효율적으로 검색하고 싶을 때

-   **문제 상황:** 프로젝트 히스토리가 길어져서 특정 기능이 언제 추가되었는지, 특정 파일이 언제 마지막으로 수정되었는지 찾기 어렵습니다.
-   **해결 방안:** `git log`의 다양한 옵션을 활용하여 히스토리를 필터링합니다.
    ```bash
    # 한 줄로 로그를 깔끔하게 보기
    git log --oneline --graph
    ```
    > `git log --oneline`: 각 커밋을 한 줄로 요약하여 보여줍니다. `--graph` 옵션을 함께 사용하면 브랜치의 분기 및 병합 히스토리를 시각적으로 파악하기 좋습니다.

    ```bash
    # 특정 파일의 변경 이력만 보기
    git log -p -- src/components/Button.js

    # 특정 기간 동안의 커밋만 보기
    git log --since="2 weeks ago"

    # 특정 작성자의 커밋만 보기
    git log --author="cdecl"

    # 커밋 메시지에서 특정 키워드로 검색하기
    git log --grep="keyword"

    # 코드 변경 내용(diff)에서 특정 문자열이 추가/삭제된 커밋 검색
    git log -S"UserService"

    # 코드 변경 내용(diff)에서 정규식으로 특정 패턴을 검색
    git log -G"Login(Service|Manager)"

    # 두 커밋 사이의 모든 커밋 보기
    git log a1b2c3d..f4e5d6c
    ```
    > `git log --grep`은 커밋 메시지를 검색하지만, `git log -S`는 실제 코드 변경 내용(diff)에서 특정 문자열의 증감(추가/삭제)이 발생한 커밋을 찾아줍니다. `git log -G`는 `-S`와 유사하게 코드 변경 내용에서 정규표현식으로 특정 패턴을 검색할 때 사용합니다. 이 옵션들과 함께 `-p`를 사용하면 해당 커밋의 전체 diff를 함께 볼 수 있어 변경 내용을 상세히 파악하는 데 매우 유용합니다.

#### 사례 22: 모든 변경 사항 취소하기 (Tracked + Untracked)

-   **문제 상황:** 작업하던 모든 변경 사항을 취소하고 현재 HEAD 상태로 깨끗하게 되돌리고 싶습니다. 이미 수정한 파일(tracked)과 새로 만든 파일(untracked)을 모두 삭제하고 싶습니다.
-   **해결 방안:** 다음 명령들을 조합하여 사용합니다.

    ```bash
    # 1. Tracked 파일 모두 복원 (Working Directory + Staging Area 초기화)
    git reset --hard HEAD

    # 2. Untracked 파일 모두 삭제
    git clean -fd
    ```
    > `git reset --hard HEAD`: Working Directory와 Staging Area를 마지막 커밋 상태로 되돌립니다. tracked 파일의 모든 변경 사항을 취소합니다. untracked 파일은 삭제하지 않습니다.
    >
    > `git clean -fd`: 추적하지 않는 파일(`-f`)과 디렉터리(`-d`)를 모두 삭제합니다. **주의: 영구적으로 삭제되므로 복구할 수 없습니다!**

    **VSCode "Discard All Changes"와의 차이:**
    VSCode의 "Discard All Changes" 버튼은 `git restore`와 `git clean -fd`를 사용합니다. 이 방식은 `git reset --hard`와 달리 Staging Area의 파일을 처리하지 않습니다. 따라서 명령줄에서 직접 모든 변경 사항을 취소할 때는 `git reset --hard HEAD && git clean -fd`를 사용하는 것이 더 확실합니다.

    **참고:** 특정 파일만 취소하려면:
    ```bash
    # 특정 파일만 취소 (untracked 파일에 대해서는 동작하지 않음)
    git restore <file>
    # 또는
    git checkout HEAD -- <file>
    ```

    **팁:** 삭제하기 전에 변경 사항을 저장하고 싶다면:
    ```bash
    # untracked 파일까지 포함하여 저장
    git stash push -u
    # 나중에 복원
    git stash pop
    ```

---

Git 트러블 슈팅의 핵심은 "무엇을 하려 했는가"와 "실제로 무슨 일이 일어났는가"의 차이를 이해하는 것입니다. 이 글에서 소개된 사례들을 통해, 예상치 못한 상황에 더 자신감 있게 대처할 수 있기를 바랍니다.
