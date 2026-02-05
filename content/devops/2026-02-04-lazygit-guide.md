---
title: "Lazygit 가이드: 설치부터 패널별 치트시트"
tags:
  - lazygit
  - git
  - tui
  - devops
  - productivity
  - terminal
---

Git은 강력하지만 명령어 입력 방식은 때로 직관성이 떨어집니다. 특히 수많은 파일을 개별적으로 스테이징하거나 복잡한 인터랙티브 리베이스를 수행할 때 터미널 UI(TUI) 도구의 진가가 드러납니다. 그중에서도 가장 완성도 높은 도구인 **Lazygit**을 파헤쳐 봅니다.

---

## 1. Lazygit 설치 (Installation)

환경에 맞는 패키지 매니저를 사용하여 간단히 설치할 수 있습니다.

### macOS
```bash
brew install lazygit
```

### Windows
```bash
# Scoop 사용 시
scoop bucket add extras
scoop install lazygit

# Winget 사용 시
winget install jesseduffield.lazygit
```

### Linux (Ubuntu/Debian 등)
```bash
# 바이너리 직접 설치 예시
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```

---

## 2. TUI 구성 및 레이아웃 (Layout)

Lazygit는 한 화면에서 Git의 모든 상태를 조망할 수 있는 **대시보드형 레이아웃**을 가지고 있습니다.

### 인터페이스 구조도

```text
┌───────────────────────────────┬─────────────────────────────────────────┐
│ [1] Status & Remotes          │ [Main View]                             │
│ 리포 상태, 업/다운 스트림 정보  │ Diff 내용, 커밋 그래프, 충돌 해결 뷰      │
├───────────────────────────────┤                                         │
│ [2] Files                     │                                         │
│ 작업 디렉토리 변경 파일 목록    │                                         │
├───────────────────────────────┤                                         │
│ [3] Branches                  │                                         │
│ 로컬/리모트 브랜치 및 태그      │                                         │
├───────────────────────────────┤                                         │
│ [4] Commits                   │                                         │
│ 현재 브랜치의 커밋 히스토리     │                                         │
├───────────────────────────────┤                                         │
│ [5] Stash                     │                                         │
│ 임시 저장된 변경 사항 목록      │                                         │
└───────────────────────────────┴─────────────────────────────────────────┘
```

---

## 3. 핵심 치트시트 (Cheatsheet)

### 🔑 공통 명령어 (Global)
패널과 상관없이 항상 작동하는 기본 단축키입니다.

| 키 | 기능 | 설명 |
|:---:|:---|:---|
| `q` | 종료 | Lazygit을 종료합니다. |
| `Tab` | 다음 패널 | 패널을 순차적으로 이동합니다 (1 → 2 → 3 → 4 → 5). |
| `1`~`5` | 패널 점프 | 숫자 키를 눌러 해당 패널로 즉시 이동합니다. |
| `x` | 메뉴 열기 | 현재 상황에서 사용 가능한 명령 메뉴를 보여줍니다. |
| `?` | 도움말 | 전체 단축키 목록을 띄웁니다. |
| `z` | Undo | 마지막 Git 작업을 실행 취소합니다 (Reflog 기반). |
| `ctrl+z` | Redo | 취소한 작업을 다시 실행합니다. |

---

### [1] Status & Remotes 패널
상태 확인 및 서버 동기화 구역입니다.

| 키 | 기능 | Git 명령어 | 설명 |
|:---:|:---|:---|:---|
| `p` | Pull | `git pull` | 원격 저장소에서 변경 사항을 가져옵니다. |
| `P` | Push | `git push` | 로컬 커밋을 서버에 올립니다. |
| `f` | Fetch | `git fetch` | 원격 정보를 동기화합니다. |
| `e` | 에디터 열기 | - | `.gitconfig` 등을 기본 에디터로 엽니다. |

---

### [2] Files 패널
파일을 스테이징하고 커밋을 준비하는 가장 핵심적인 구역입니다.

| 키 | 기능 | Git 명령어 | 설명 |
|:---:|:---|:---|:---|
| `Space` | 스테이징 토글 | `git add <file>` | 개별 파일을 Index에 추가/제거합니다. |
| `a` | 전체 스테이징 | `git add .` | 모든 변경 파일을 한 번에 추가합니다. |
| `c` | 커밋 생성 | `git commit` | 스테이징된 파일들을 커밋합니다. |
| `A` | Amend 커밋 | `git commit --amend` | 마지막 커밋에 현재 변경 사항을 합칩니다. |
| `d` | 변경 사항 폐기 | `git checkout -- <f>` | 파일의 수정을 취소하고 되돌립니다. |
| `Enter` | 상세 보기 | - | 파일 내부의 Diff를 라인 단위로 확인합니다 (Main View 이동). |

---

### [3] Branches 패널
브랜치 전략을 실행하는 구역입니다.

| 키 | 기능 | Git 명령어 | 설명 |
|:---:|:---|:---|:---|
| `Enter` | 체크아웃 | `git checkout` | 선택한 브랜치로 이동합니다. |
| `n` | 신규 생성 | `git checkout -b` | 현재 위치에서 새 브랜치를 만듭니다. |
| `r` | 이름 변경 | `git branch -m` | 브랜치 이름을 바꿉니다. |
| `d` | 브랜치 삭제 | `git branch -d` | 선택한 브랜치를 삭제합니다. |
| `M` | Merge | `git merge` | 선택한 브랜치를 현재 브랜치로 병합합니다. |
| `R` | Rebase | `git rebase` | 현재 브랜치를 선택한 브랜치 위로 리베이스합니다. |

---

### [4] Commits 패널
히스토리를 확인하고 커밋을 정리(Cleanup)하는 구역입니다.

| 키 | 기능 | Git 명령어 | 설명 |
|:---:|:---|:---|:---|
| `i` | 리베이스 시작 | `git rebase -i` | 선택한 지점부터 리베이스를 시작합니다. |
| `s` | Squash | (rebase -i) | 커밋을 이전 커밋과 하나로 합칩니다. |
| `f` | Fixup | (rebase -i) | 메시지 수정 없이 이전 커밋에 합칩니다. |
| `d` | Drop | (rebase -i) | 커밋을 삭제합니다. |
| `e` | Edit | (rebase -i) | 커밋 내용을 수정합니다. |
| `shift+c` | 복사 | - | 커밋을 체리픽 대상으로 복사합니다. |
| `shift+v` | 붙여넣기 | `git cherry-pick` | 복사한 커밋을 현재 브랜치에 적용합니다. |

---

### [5] Stash 패널
임시 저장소를 관리합니다.

| 키 | 기능 | Git 명령어 | 설명 |
|:---:|:---|:---|:---|
| `Enter` | Apply | `git stash apply` | 스태시 내용을 가져오고 목록에 남겨둡니다. |
| `g` | Pop | `git stash pop` | 스태시 내용을 가져오고 목록에서 삭제합니다. |
| `d` | Drop | `git stash drop` | 스태시 항목을 삭제합니다. |

---

## 4. 고급 팁: 메인 뷰(Main View) 활용

파일 뷰에서 `Enter`를 눌러 메인 뷰로 이동하면 다음과 같은 세밀한 제어가 가능합니다.

- **라인 단위 스테이징**: `Space`로 전체가 아닌 특정 줄만 골라 스테이징할 수 있습니다.
- **범위 스테이징**: `v`로 범위를 지정한 뒤 스테이징하거나 폐기합니다.
- **충돌 해결 (Conflict Resolution)**: 머지 충돌 시 `◀`, `▶` 키로 어떤 코드를 선택할지 결정하고 `Space`로 확정합니다.

---

## 5. Lazygit vs 기타 TUI 도구 (비교)

| 비교 항목 | Lazygit | Tig | GitUI |
|---|---|---|---|
| **언어** | Go | C | Rust |
| **특징** | 풍부한 기능, 대시보드형 | 가볍고 빠른 로그 탐색 | 가장 빠른 반응 속도 |
| **강점** | 리베이스, 충돌 해결의 편의성 | 역사적인 안정성 | 대용량 저장소 처리 |

---

## 결론

Lazygit는 "명령어를 몰라도 된다"는 것을 넘어, "Git의 흐름을 시각적으로 이해하게 해준다"는 강력한 장점이 있습니다. 이 치트시트를 활용하여 터미널 환경에서의 Git 생산성을 한 단계 업그레이드해 보시기 바랍니다.
