---
title: C++20 Modules Test (`g++`)
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
C++20 에 추가된 모듈 `Modules` 기능은 기존의 header files 의 `#include` 로 인한 컴파일 시간 증가 이슈 및 
필요한 로직(함수, 심볼)만을 내보내기(export)를 통해서 타 언어의 단위 모듈 처럼 효율적인 라이브러리 관리 목적

### Modules의 주요 장점
- **컴파일 시간 단축**: 각 모듈은 한 번만 컴파일되며, 그 결과가 캐시됨
- **심볼 격리**: 모듈 내부의 심볼은 명시적으로 export하지 않는 한 외부에서 접근 불가
- **순환 의존성 방지**: 헤더 파일과 달리 명확한 의존성 그래프 형성
- **매크로 독립성**: 모듈은 매크로의 영향을 받지 않아 더 안정적인 코드 작성 가능

> 일종의 pch(precompiled header)의 기능을 포함한 표준적인 모듈 관리 기능 

> 현재 컴파일러마다 (msvc, g++, clang) Standard Library의 지원과 모듈을 사용하기위한 방법이 약간 상이함 

### GCC (G++) 기준 테스트
- 참고 : [C++20 Modules — Complete Guide](https://itnext.io/c-20-modules-complete-guide-ae741ddbae3d){:target="_blank"}

### GCC (G++) 11 설치 
- gcc 11 이상 버전 필요 (ubuntu)
- 모듈 기능은 gcc 11부터 실험적 지원 시작, gcc 13에서 안정화

```sh
$ sudo add-apt-repository ppa:ubuntu-toolchain-r/test
$ sudo apt-get update

$ sudo apt-get install gcc-11 g++-11
```

### Standard Library 사용 
- `clang++` 의 경우 `-fbuiltin-module-map` 옵션을 통해 표준 라이브러리 사용 가능
  - `clang++ -std=c++20 -stdlib=libc++ -fmodules -fbuiltin-module-map xxxx.cpp `
- `msvc`의 경우 `std.io` 등의 추상화된 이름으로 접근 가능 
  - <https://docs.microsoft.com/en-us/cpp/cpp/modules-cpp?view=msvc-160>{:target="_blank"}

#### GCC 사용
- `g++`의 경우 수동으로 표준 라이브러리의 map 파일을 생성 해줘야 함 
  - `g++ -std=c++20 -fmodules-ts -xc++-system-header iostream`
  - `gcm.cache` 디렉토리 생성 및 gcm 파일 생성을 해줌
  
```sh
$ g++ -std=c++20 -fmodules-ts -xc++-system-header iostream
$ g++ -std=c++20 -fmodules-ts -xc++-system-header string

$ tree gcm.cache
gcm.cache
└── usr
    └── include
        └── c++
            └── 11
                ├── iostream.gcm
                └── string.gcm
```

### 모듈 문법과 사용법

#### 모듈 선언
```cpp
// 모듈 인터페이스 유닛
export module my_module;              // 모듈 선언
export void foo() { /* ... */ }       // 외부 노출 함수
void internal_foo() { /* ... */ }     // 모듈 내부 함수
```

#### 파티션 사용
```cpp
// interface-part.cpp
export module my_module:interface;    // 인터페이스 파티션
export void api_function();

// impl-part.cpp
module my_module:implementation;      // 구현 파티션
void api_function() { /* ... */ }
```

#### Standard Library 사용 Example
- import module 
  - `#include` 를 `import` 로 변경 및 `;` 세미콜론 마무리
  
```cpp
import <iostream>;
import <string>;
using namespace std;

int main()
{
    auto s = "modules string"s;
    cout << s << endl;
}
```

- build 

```sh
$ g++ -std=c++20 -fmodules-ts -o main main.cpp
$ ./main
modules string
```

#### 모듈 작성 및 사용 Example

```cpp
// adder.cpp
export module adder;

export template <typename Ty>
Ty add(Ty n1, Ty n2)
{
    return n1 + n2;
}

// 추가적인 내부 구현
namespace {
    template <typename T>
    T multiply(T n1, T n2) { return n1 * n2; }  // 모듈 내부에서만 사용 가능
}
```

```cpp
// main.cpp
import <iostream>;
import <string>;
using namespace std;

import adder;

int main()
{
    auto r = add("one "s, "two"s);
    cout << r << endl;
    
    // multiply는 export되지 않았으므로 사용 불가
    // auto m = multiply(2, 3);  // 컴파일 에러
}
```

### 빌드 과정
1. 모듈 인터페이스 컴파일
```sh
$ g++ -std=c++20 -fmodules-ts -O2 -c adder.cpp
$ tree gcm.cache
gcm.cache
├── adder.gcm
└── usr
    └── include
        └── c++
            └── 11
                ├── iostream.gcm
                └── string.gcm
```

2. 메인 프로그램 컴파일 및 링크
```sh
$ g++ -std=c++20 -fmodules-ts -O2 -o main main.cpp adder.o
```

3. 실행
```sh
$ ./main
one - two
```

### 모범 사례와 주의사항
- 모듈은 전역 상태나 초기화 순서에 의존하지 않도록 설계
- 큰 프로젝트의 경우 모듈 파티션을 활용하여 논리적으로 분할
- export할 심볼을 신중하게 선택하여 인터페이스 설계
- 빌드 시스템에서 모듈 의존성을 올바르게 처리하도록 구성

{% endraw %}