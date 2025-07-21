---
title: Python uv 프로젝트 구조

toc: true
toc_sticky: true

categories:
  - dev

tags:
  - python
  - uv
  - project-structure
  - pyproject.toml
  - src-layout
---

uv를 활용한 현대적인 Python 프로젝트 구조, `src` 레이아웃과 Flat 레이아웃의 차이점, 그리고 `uvx`를 통한 원격 도구 실행 방법을 알아봅니다.

## Python 프로젝트 구조의 중요성

잘 구성된 프로젝트 디렉토리 구조는 코드의 유지보수성, 확장성, 그리고 협업 효율성을 크게 향상시킵니다. Python에서는 전통적으로 두 가지 주요 레이아웃이 사용됩니다: **Flat 레이아웃**과 **`src` 레이아웃**. 현대적인 Python 프로젝트에서는 `src` 레이아웃이 많은 이점을 제공하여 표준으로 자리 잡고 있습니다.

## 일반적인 Python 프로젝트 디렉토리 구조

현대적인 Python 프로젝트는 일반적으로 다음과 같은 구조를 가집니다.

```text
my-project/
├── .venv/
├── src/
│   └── my_package/
│       ├── __init__.py
│       └── main.py
├── tests/
│   └── test_main.py
├── pyproject.toml
└── README.md
```

- **`.venv/`**: `uv venv`로 생성된 가상 환경 폴더입니다.
- **`src/`**: 패키지의 소스 코드가 위치하는 디렉토리입니다.
- **`tests/`**: 테스트 코드가 위치하는 디렉토리입니다.
- **`pyproject.toml`**: `uv`가 프로젝트의 메타데이터와 의존성을 관리하는 표준 설정 파일입니다.

### 구조 생성을 위한 명령어

이러한 구조는 몇 가지 간단한 명령어로 빠르게 생성할 수 있습니다.

```bash
# 프로젝트 디렉토리 및 하위 폴더 생성
mkdir -p my-project/src/my_package my-project/tests

# 빈 파일 생성
touch my-project/src/my_package/__init__.py my-project/src/my_package/main.py
touch my-project/tests/test_main.py
touch my-project/pyproject.toml my-project/README.md

# 프로젝트 디렉토리로 이동하여 가상 환경 생성
cd my-project
uv venv
```

이 명령어들을 실행하면 위에서 설명한 기본 프로젝트 구조가 완성됩니다.

## `src` 레이아웃 (권장)

`src` 레이아웃은 프로젝트의 모든 소스 코드를 `src`라는 이름의 하위 디렉토리에 배치하는 구조입니다.

### `src` 레이아웃의 장점

1.  **경로 문제 방지**: 현재 작업 디렉토리가 Python의 `sys.path`에 자동으로 추가되어 발생하는 잠재적인 임포트 오류를 방지합니다. `src` 레이아웃을 사용하면, 패키지를 반드시 설치해야만 임포트할 수 있으므로 실제 배포 환경과 동일한 조건에서 테스트할 수 있습니다.
2.  **명확한 구분**: 소스 코드(`src`)와 테스트 코드(`tests`), 문서(`docs`) 등 다른 프로젝트 파일들을 명확하게 분리하여 구조를 깔끔하게 유지합니다.
3.  **편집 가능한 설치 (Editable Install)의 신뢰성**: `uv pip install -e .`와 같은 편집 가능한 모드로 설치했을 때, `src` 레이아웃은 패키지가 올바르게 설치되었는지 명확하게 확인할 수 있도록 돕습니다.

### `pyproject.toml` 최소 설정

`src` 레이아웃을 사용하려면 `pyproject.toml` 파일에 패키지의 소스가 어디에 있는지 `uv`에게 알려주어야 합니다.

```toml
[project]
name = "my_package"
version = "0.1.0"
dependencies = [
    "requests",
]

[tool.uv.sources]
my_package = "src"
```

- `[tool.uv.sources]` 테이블은 `my_package`라는 패키지의 소스 코드가 `src` 디렉토리에 있음을 `uv`에 명시합니다.

## `src` 레이아웃 vs. Flat 레이아웃

**Flat 레이아웃**은 프로젝트 루트에 패키지 디렉토리를 바로 두는 방식입니다.

```text
my-project/
├── my_package/
│   ├── __init__.py
│   └── main.py
├── tests/
...
```

두 레이아웃의 주요 차이점은 다음과 같습니다.

| 특징 | `src` 레이아웃 | Flat 레이아웃 |
| :--- | :--- | :--- |
| **구조** | 소스 코드가 `src/` 디렉토리 내에 위치 | 소스 코드가 프로젝트 루트에 위치 |
| **장점** | 설치된 패키지만 임포트 가능하여 신뢰성 높음 | 구조가 단순하여 작은 프로젝트에 적합 |
| **단점** | 초기 설정이 약간 더 복잡 (`pyproject.toml` 설정 필요) | 로컬 경로 문제로 인해 예기치 않은 임포트 오류 발생 가능 |
| **추천 대상** | 라이브러리, 애플리케이션 등 모든 규모의 프로젝트 | 매우 간단한 스크립트나 개인 프로젝트 |

결론적으로, 장기적인 유지보수와 신뢰성을 위해 **`src` 레이아웃을 사용하는 것이 강력히 권장됩니다.**

## `tests` 디렉토리 위치 및 주의점

테스트 코드는 소스 코드와 분리하여 프로젝트 루트에 `tests/` 디렉토리를 만들어 관리하는 것이 가장 좋습니다.

```text
my-project/
├── src/
│   └── my_package/
└── tests/
    └── test_my_package.py
```

### 왜 `src` 밖에 두어야 하는가?

`tests` 디렉토리를 `src` 외부에 두면, **설치된 패키지**를 기준으로 테스트하게 됩니다. 만약 `tests`가 `src` 내부에 있다면, 로컬 소스 파일을 직접 임포트하여 테스트하게 되어 실제 사용자가 패키지를 설치했을 때와 다른 환경에서 테스트가 진행될 수 있습니다.

`pytest`와 같은 테스트 프레임워크는 프로젝트 루트에서 `tests` 디렉토리를 자동으로 찾아 실행하므로 이 구조와 잘 맞습니다.

## `uvx`를 활용한 원격 도구 실행

`uvx`는 `pipx`와 유사하게, 특정 도구를 가상 환경에 설치하지 않고도 일회성으로 실행할 수 있게 해주는 `uv`의 강력한 기능입니다. 특히 GitHub 저장소에서 직접 도구를 가져와 실행할 수 있습니다.

예를 들어, `ruff` 린터를 프로젝트에 설치하지 않고 실행하고 싶다면 다음과 같이 명령할 수 있습니다.

```bash
# astral-sh/ruff 저장소에서 ruff를 가져와 현재 디렉토리에서 실행
uvx astral-sh/ruff check .

# black 포맷터를 실행
uvx psf/black .

# git 저장소에서 직접 실행
uvx --from git+https://github.com/cdecl/gemini-mcp gemini-mcp
```

- `uvx`는 임시 가상 환경을 만들고 도구를 실행한 뒤, 환경을 자동으로 정리합니다.
- 이를 통해 `pyproject.toml`에 개발용 도구를 명시하지 않고도 필요할 때마다 최신 버전의 도구를 사용할 수 있습니다.

## 결론

현대적인 Python 프로젝트에서는 `uv`와 같은 빠른 도구와 함께 체계적인 디렉토리 구조를 채택하는 것이 중요합니다.

- **`src` 레이아웃**을 사용하여 경로 문제를 방지하고 코드의 신뢰성을 높이세요.
- **`tests` 디렉토리**는 소스 코드와 분리하여 실제 배포 환경과 유사한 테스트를 보장하세요.
- **`uvx`**를 활용하여 프로젝트를 깔끔하게 유지하면서 필요한 개발 도구를 유연하게 사용하세요.

이러한 모범 사례들은 프로젝트가 성장하더라도 높은 수준의 코드 품질과 유지보수성을 유지하는 데 큰 도움이 될 것입니다.

## 추가 리소스

* Astral uv 공식 문서
* Python Packaging User Guide: src layout vs flat layout
