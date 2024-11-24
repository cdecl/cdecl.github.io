---
title: C++20 Modules - gnu c++ test
last_modified_at: 2024-11-22

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - c++
  - modules
  - c++20
  - g++
  - -fmodules-ts
  - -xc++-system-header
---

C++ Modules Test Example (g++)

{% raw %}

## C++20 Modules
C++20에 추가된 모듈 `Modules` 기능은 기존의 헤더 파일 `#include`로 인한 컴파일 시간 증가 문제를 해결하고, 필요한 로직(함수, 심볼)만을 내보내는(export) 방식을 통해 타 언어의 모듈 단위처럼 효율적인 라이브러리 관리를 지원합니다.

### Modules의 주요 장점
- **컴파일 시간 단축**: 각 모듈은 한 번만 컴파일되며, 그 결과가 캐시됨
- **심볼 격리**: 모듈 내부의 심볼은 명시적으로 export하지 않는 한 외부에서 접근 불가
- **순환 의존성 방지**: 헤더 파일과 달리 명확한 의존성 그래프 형성
- **매크로 독립성**: 모듈은 매크로의 영향을 받지 않아 더 안정적인 코드 작성 가능

> 일종의 PCH(Precompiled Header)의 기능을 포함한 표준적인 모듈 관리 기능입니다.  
> 현재 컴파일러마다 (MSVC, g++, Clang) Standard Library 지원과 모듈 사용 방법이 약간 상이합니다.

### 컴파일러 지원 여부 확인
C++20의 모듈은 최신 컴파일러에서 제한적으로 지원되며, 구현 상태는 다음과 같습니다:

- GCC: 11 이상에서 실험적으로 지원.
- Clang: 15 이상에서 실험적으로 지원.
- MSVC: Visual Studio 2019 (16.8) 이상에서 잘 지원.

#### 컴파일러 플래그
- GCC: -std=c++20, -fmodules-ts
- Clang: -std=c++20, -fmodules
- MSVC: /std:c++20, /experimental:module


## GCC (G++) 기준 테스트
- 참고 : [C++20 Modules — Complete Guide](https://itnext.io/c-20-modules-complete-guide-ae741ddbae3d){:target="_blank"}

### GCC 설치 및 설정
모듈 기능은 **GCC 11**부터 실험적으로 지원되며, **GCC 13**에서 안정화되었습니다.

#### 설치 방법
```sh
$ sudo add-apt-repository ppa:ubuntu-toolchain-r/test
$ sudo apt-get update
$ sudo apt-get install gcc-11 g++-11
```

#### 환경 설정
1. **컴파일러 플래그**
   - `-std=c++20`: C++20 표준 활성화
   - `-fmodules-ts`: 모듈 기능 활성화

2. **CMake 설정**
   ```cmake
   cmake_minimum_required(VERSION 3.26)
   project(MyModules LANGUAGES CXX)

   set(CMAKE_CXX_STANDARD 20)
   set(CMAKE_CXX_STANDARD_REQUIRED ON)
   set(CMAKE_CXX_EXTENSIONS OFF)
   ```

---

## Standard Library 사용
표준 라이브러리를 모듈로 사용하는 방법은 컴파일러마다 다릅니다.

```cpp
// main.cpp
import <iostream>;
import <string>;
using namespace std;

int main()
{
  string s = "main start ";
  cout << s << endl;
}
```

### GCC
- 표준 라이브러리 사용 시, 수동으로 모듈 맵을 생성해야 합니다.
- 예: `iostream` 및 `string` 모듈 생성
  ```sh
  g++ -std=c++20 -fmodules-ts -xc++-system-header iostream
  g++ -std=c++20 -fmodules-ts -xc++-system-header string
  ```

- 생성된 `gcm.cache` 구조:
  ```plaintext
  gcm.cache
  └── usr
      └── include
          └── c++
              └── 11
                  ├── iostream.gcm
                  └── string.gcm
  ```

  ```sh
  g++ -std=c++20 -fmodules-ts -o main main.cpp
  ```

### Clang
- `-fbuiltin-module-map` 플래그를 통해 표준 라이브러리 모듈 사용 가능.
  ```sh
  clang++ -std=c++20 -stdlib=libc++ -fmodules -fbuiltin-module-map main.cpp
  ```

### MSVC
- 추상화된 모듈 이름을 사용하여 접근 가능.
  - 예: `import std.io;`

  ```sh
  cl /std:c++20 /experimental:module /EHsc /c my_module.cppm
  cl /std:c++20 /EHsc main.cpp my_module.obj
  ```

---

## Modules 문법과 사용법

### 1. 모듈 선언 및 정의
```cpp
// my_module.cppm
export module my_module;          // 모듈 선언 및 정의

export int add(int a, int b) {    // 외부에 노출할 함수
    return a + b;
}
```

### 2. 모듈 사용
```cpp
// main.cpp
import my_module;                 // 모듈 가져오기
#include <iostream>               // 기존 헤더와 혼합 사용 가능

int main() {
    std::cout << "3 + 4 = " << add(3, 4) << std::endl;
    return 0;
}
```


---

## Modules 작성 및 사용 예제

### adder 모듈 작성
```cpp
// adder.cppm
export module cdecl_adder;

export template <typename T>
T add(T a, T b) {
    return a + b;
}

namespace { // 모듈 내부 구현
    template <typename T>
    T multiply(T a, T b) {
        return a * b;
    }
}
```

### main.cpp
```cpp
#include <iostream>
import cdecl_adder;

int main() {
    std::cout << "add(5, 8): " << add(5, 3) << std::endl; // 8 출력

    // multiply는 export되지 않았으므로 사용 불가
    // std::cout << multiply(5, 3); // 컴파일 에러
    return 0;
}
```

### 빌드 과정
#### 1. **모듈 인터페이스 컴파일**
```sh
$ g++ -std=c++20 -fmodules-ts -c adder.cppm
```

생성된 `gcm.cache` 구조:
```sh
gcm.cache
└── cdecl_adder.gcm
```

#### 2. **메인 프로그램 컴파일 및 링크**
```sh
g++ -std=c++20 -fmodules-ts main.cpp adder.o -o main
```

### 3. **실행**
```sh
$ ./main
add(5, 8): 8
```

---

## 모범 사례와 주의사항
- **모듈 심볼 관리**: export할 심볼을 신중히 선택하여 인터페이스 설계.
- **빌드 시스템**: CMake와 같은 빌드 도구를 활용하여 모듈 의존성을 효율적으로 관리.
- **초기화 순서**: 전역 상태나 초기화 순서에 의존하지 않도록 설계.

Modules는 헤더 파일 기반의 기존 방식을 대체하는 강력한 기능으로, 대규모 프로젝트에서 효율적인 코드 관리 및 컴파일 성능 향상을 제공합니다.

{% endraw %}