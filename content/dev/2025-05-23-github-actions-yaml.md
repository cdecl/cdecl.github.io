---
title: GitHub Actions YAML 사용법
tags:
  - GitHub Actions
  - CI/CD
  - YAML
  - Automation
  - DevOps
---
GitHub Actions YAML: CI/CD 워크플로우의 핵심

GitHub Actions는 CI/CD 및 자동화 워크플로우를 정의하는 강력한 도구로, YAML 파일을 통해 설정됩니다. 이 포스트에서는 GitHub Actions YAML의 주요 사용법, 실행 환경, 쉘 스크립트 활용 방법, 그리고 실무에서 유용한 팁을 정리합니다.


## 왜 GitHub Actions YAML이 중요한가?

GitHub Actions는 코드 푸시, 풀 리퀘스트, 스케줄링 등 다양한 이벤트를 기반으로 자동화된 워크플로우를 실행할 수 있습니다. YAML 파일은 이를 직관적이고 선언적으로 정의하며, 다음과 같은 장점을 제공합니다:
- **가독성**: 명확한 구조로 워크플로우 정의.
- **유연성**: 다양한 환경과 도구 지원.
- **재사용성**: 액션과 워크플로우를 모듈화해 생산성 향상.
- **2025년 기준**: GitHub Actions는 대부분의 주요 언어와 배포 환경을 지원하며, 커뮤니티 액션으로 확장 가능.



## 1. GitHub Actions YAML 기본 구조

GitHub Actions 워크플로우는 `.github/workflows/` 디렉토리에 `.yml` 파일로 저장됩니다. 기본 구조는 다음과 같습니다:

```yaml
name: CI Pipeline
run-name: ${{ github.actor }}'s CI Run
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Run a command
        run: echo "Hello, GitHub Actions!"
```

### 주요 구성 요소
- **name**: 워크플로우 이름 (옵션).
- **run-name**: 실행 시 표시될 이름 (동적 설정 가능, 예: `${{ github.actor }}`).
- **on**: 트리ガー 이벤트 (예: `push`, `pull_request`, `schedule`).
- **jobs**: 실행할 작업 단위.
- **steps**: Job 내의 개별 단계.
- **uses**: 외부 액션 사용 (예: `actions/checkout@v4`).
- **run**: 쉘 명령어 실행.

> **주의**: YAML은 들여쓰기에 민감하므로, 2칸 공백을 사용하세요.



## 2. 실행 환경 및 배포판

GitHub Actions는 다양한 실행 환경(Runner)을 제공하며, `runs-on`으로 지정합니다.

### 주요 실행 환경
- **ubuntu-latest**: 최신 Ubuntu (리눅스 기반, 가장 보편적).
- **windows-latest**: 최신 Windows Server.
- **macos-latest**: 최신 macOS.
- 특정 버전 지정 가능 (예: `ubuntu-22.04`, `windows-2022`).

### 배포판 선택 팁
- **Ubuntu**: 속도와 호환성으로 인해 표준 선택.
- **Windows**: .NET, C# 프로젝트 또는 Windows 전용 테스트.
- **macOS**: iOS/macOS 앱 빌드 및 테스트.
- **매트릭스 빌드**: 여러 환경에서 테스트.

  ```yaml
  jobs:
    test:
      runs-on: ${{ matrix.os }}
      strategy:
        matrix:
          os: [ubuntu-latest, windows-latest, macos-latest]
          node-version: [14, 16, 18]
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: ${{ matrix.node-version }}
        - run: npm test
  ```



## 3. 쉘 스크립트 사용법

`run` 키워드로 쉘 스크립트를 실행하며, `bash`, `pwsh`(PowerShell), `cmd` 등을 지정할 수 있습니다.

### 기본 사용법

```yaml
steps:
  - name: Run shell script
    run: |
      echo "Running multi-line script"
      ls -la
      python script.py
    shell: bash
```

### 쉘 지정
- **bash**: Linux/macOS 기본.
- **pwsh**: PowerShell Core (크로스 플랫폼).
- **cmd**: Windows 전용

  ```yaml
  - name: Windows command
    run: dir
    shell: cmd
  ```

### 환경 변수
- Job 단위 환경 변수:

  ```yaml
  jobs:
    build:
      env:
        MY_VAR: my-value
      steps:
        - run: echo $MY_VAR
  ```

- 시크릿 사용:

  ```yaml
  steps:
    - run: echo ${{ secrets.MY_SECRET }}
  ```



## 4. 주요 팁 및 모범 사례

### 1. 모듈화 및 재사용
- **Composite Actions**:

  ```yaml
  # .github/actions/my-action/action.yml
  name: My Custom Action
  runs:
    using: composite
    steps:
      - run: echo "Reusable step"
        shell: bash
  ```

- **Workflow 재사용**:
  ```yaml
  on:
    workflow_call:
  ```

### 2. 시크릿 관리
- 민감한 정보는 리포지토리 설정에서 시크릿으로 관리.

  ```yaml
  steps:
    - run: aws s3 sync ./dist s3://my-bucket
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  ```

### 3. 로컬 테스트
- `act` 도구로 로컬 디버깅:

  ```bash
  brew install act
  act -j build
  ```

### 4. 성능 최적화
- **캐시**:

  ```yaml
  steps:
    - uses: actions/cache@v3
      with:
        path: ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
  ```

- **병렬 실행**: `strategy.matrix`로 병렬화.
- **조건문**: `if`로 불필요한 스텝 제외.

  ```yaml
  - run: echo "Only on push"
    if: github.event_name == 'push'
  ```

### 5. 스케줄링
- Cron으로 주기적 실행:
  ```yaml
  on:
    schedule:
      - cron: '0 0 * * *' # 매일 자정
  ```

### 4.6. 주요 `uses:` 모듈 소개
GitHub Actions의 `uses` 키워드는 재사용 가능한 액션을 통해 워크플로우를 간소화합니다. 2025년 기준, 자주 사용되는 표준 액션을 소개합니다:

- **actions/checkout@v4**:
  - **설명**: 리포지토리 코드를 워크플로우 환경으로 체크아웃.
  - **사용 예**:

    ```yaml
    - uses: actions/checkout@v4
      with:
        ref: ${{ github.head_ref }}
    ```
  - **용도**: 모든 워크플로우의 첫 단계로 필수적.

- **actions/setup-node@v4**:
  - **설명**: Node.js 환경 설정 및 특정 버전 설치.
  - **사용 예**:

    ```yaml
    - uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    ```
  - **용도**: Node.js 프로젝트 빌드/테스트.

- **actions/setup-python@v4**:
  - **설명**: Python 환경 설정 및 의존성 캐싱.
  - **사용 예**:

    ```yaml
    - uses: actions/setup-python@v4
      with:
        python-version: '3.9'
        cache: 'pip'
    ```
  - **용도**: Python 프로젝트 빌드/테스트/배포.

- **actions/setup-go@v4**:
  - **설명**: Go 언어 환경 설정.
  - **사용 예**:

    ```yaml
    - uses: actions/setup-go@v4
      with:
        go-version: '1.21'
    ```
  - **용도**: Go 프로젝트 빌드/테스트.

- **actions/cache@v3**:
  - **설명**: 의존성 캐싱으로 빌드 시간 단축.
  - **사용 예**:

    ```yaml
    - uses: actions/cache@v3
      with:
        path: ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    ```
  - **용도**: npm, pip, Maven 등 의존성 캐싱.

- **actions/upload-artifact@v3** / **actions/download-artifact@v3**:
  - **설명**: 빌드 결과물을 저장하거나 다운로드.
  - **사용 예**:

    ```yaml
    - uses: actions/upload-artifact@v3
      with:
        name: my-artifact
        path: build/
    ```
  - **용도**: Job 간 아티팩트 공유 또는 배포.

- **docker/build-push-action@v5**:
  - **설명**: Docker 이미지 빌드 및 레지스트리에 푸시.
  - **사용 예**:

    ```yaml
    - uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: user/app:latest
    ```
  - **용도**: 컨테이너 기반 배포.

- **aws-actions/configure-aws-credentials@v4**:
  - **설명**: AWS CLI를 위한 자격 증명 설정.
  - **사용 예**:

    ```yaml
    - uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    ```
  - **용도**: AWS S3, ECS, Lambda 배포.

**팁**: 최신 버전은 [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)에서 확인하고, `vX` 태그를 명시하여 안정성을 확보하세요.

---

## 5. 예제: Node.js, Python, C++ 프로젝트 배포
다양한 언어로 작성된 프로젝트의 빌드, 테스트, 배포 워크플로우 예제를 제공합니다.

### Node.js 프로젝트 배포
```yaml
name: Node.js CI/CD
on:
  push:
    branchesસ
    branches:
      - main
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Deploy to server
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: ./deploy.sh
```

### Python 프로젝트 배포
```yaml
name: Python CI/CD
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run tests
        run: pytest
      - name: Build package
        run: python -m build
      - name: Deploy to PyPI
        env:
          PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
        run: twine upload dist/* --username __token__ --password $PYPI_TOKEN
```

### C++ 프로젝트 배포
```yaml
name: C++ CI/CD
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up CMake
        run: |
          sudo apt-get update
          sudo apt-get install -y cmake g++ ninja-build
      - name: Configure CMake
        run: cmake -S . -B build -G Ninja
      - name: Build
        run: cmake --build build
      - name: Run tests
        run: ctest --test-dir build
      - name: Package artifact
        run: |
          mkdir -p artifacts
          cp build/myapp artifacts/
      - name: Deploy to server
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
        run: scp artifacts/myapp user@server:/path/to/deploy
```

---



## 결론

GitHub Actions YAML은 CI/CD와 자동화를 위한 강력한 도구로, 직관적인 문법과 유연한 환경 설정을 제공합니다. 실행 환경 선택, 쉘 스크립트 활용, 모듈화, 캐싱, 그리고 표준 액션(`uses`) 활용을 통해 워크플로우를 최적화하세요. 프로젝트 요구사항에 따라 적절한 설정을 선택하고, `act`로 로컬 테스트를 수행해 안정성을 높이세요.


## 추가 리소스
- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [act GitHub](https://github.com/nektos/act)


