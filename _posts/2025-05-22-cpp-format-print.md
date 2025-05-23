---
title: C++ std::format, std::print 사용법과 컴파일러 호환성

toc: true
toc_sticky: true

categories:
  - dev

tags:
  - c++
  - c++20
  - c++23
  - std::format
  - std::print
  - fmt
  - formatting
  - performance
---

C++20 std::format과 C++23 std::print: 현대적인 문자열 포매팅

{% raw %}

C++20과 C++23은 문자열 포매팅을 현대화한 `std::format`과 `std::print`를 도입하며, 기존의 `printf`나 `std::cout`에 비해 안전하고 직관적인 API를 제공합니다. 이 글에서는 두 기능의 사용법, 컴파일러 호환성, 그리고 지원되지 않는 환경에서 `fmt` 라이브러리 사용 방법을 다룹니다.

## 왜 새로운 포매팅 API가 중요한가?

기존 C++ 문자열 포매팅 방법(`printf`, `std::stringstream`, `std::cout`)은 다음과 같은 단점이 있습니다:
- **안전성 부족**: `printf`는 타입 안정성을 보장하지 않아 런타임 오류 발생 가능.
- **복잡성**: `std::stringstream`은 장황하고 성능 오버헤드 존재.
- **가독성**: `std::cout`은 연속적인 `<<` 연산으로 코드가 길어짐.

`std::format`(C++20)과 `std::print`(C++23)는 Python의 `str.format`에서 영감을 받아 타입 안전성, 가독성, 성능을 개선했습니다. `fmt` 라이브러리는 이를 보완하며, 최신 표준을 지원하지 않는 환경에서도 동일한 경험을 제공합니다.

## 1. std::format (C++20)

`std::format`은 문자열 포매팅을 위한 타입 안전한 템플릿 기반 API로, `<format>` 헤더에 포함됩니다.

### 특징
- **타입 안전성**: 컴파일 타임에 포맷 문자열과 인수 타입 검증.
- **유연성**: 사용자 정의 타입 포매팅 지원.
- **성능**: `printf`보다 빠르며, 동적 메모리 할당 최소화.
- **2025년 기준**: C++20 표준의 대부분 컴파일러에서 안정적으로 지원.

### 사용법
```cpp
#include <format>
#include <string>
#include <iostream>

int main() {
    std::string s = std::format("Hello, {}! You are {} years old.", "Alice", 25);
    std::cout << s << std::endl;

    // 위치 지정자
    std::string s2 = std::format("{1}, {0}!", "World", "Hello");
    std::cout << s2 << std::endl;

    // 형식 지정
    std::string s3 = std::format("Pi: {:.2f}", 3.14159);
    std::cout << s3 << std::endl;
}
```

**출력**:
```
Hello, Alice! You are 25 years old.
Hello, World!
Pi: 3.14
```

### 사용자 정의 타입
```cpp
#include <format>
#include <string>

struct Person {
    std::string name;
    int age;
};

template <>
struct std::formatter<Person> {
    constexpr auto parse(std::format_parse_context& ctx) { return ctx.begin(); }
    auto format(const Person& p, std::format_context& ctx) const {
        return std::format_to(ctx.out(), "Person{{name: {}, age: {}}}", p.name, p.age);
    }
};

int main() {
    Person p{"Bob", 30};
    std::string s = std::format("{}", p);
    std::cout << s << std::endl; // 출력: Person{name: Bob, age: 30}
}
```

### 컴파일러 호환성 (2025년 기준)
- **GCC**: 11.1 이상 (`-std=c++20`)
- **Clang**: 14.0 이상 (`-std=c++20`)
- **MSVC**: Visual Studio 2019 16.10 이상 (`/std:c++20`)
- **Apple Clang**: Xcode 14 이상
- **제약사항**: 일부 임베디드 환경(예: 특정 RTOS)에서는 `<format>` 지원 미비.

## 2. std::print (C++23)

`std::print`는 `std::format`을 기반으로, 콘솔 출력에 최적화된 함수입니다. `<print>` 헤더에 포함되며, `std::cout`보다 간결하고 효율적입니다.

### 특징
- **간결성**: 포매팅과 출력을 단일 호출로 처리.
- **유니코드 지원**: UTF-8 출력 최적화.
- **2025년 기준**: C++23 지원이 초기 단계로, 최신 컴파일러에서만 동작.

### 사용법
```cpp
#include <print>

int main() {
    std::print("Hello, {}! You are {} years old.\n", "Charlie", 35);
    std::print("Pi: {:.2f}\n", 3.14159);
}
```

**출력**:
```
Hello, Charlie! You are 35 years old.
Pi: 3.14
```

### 컴파일러 호환성 (2025년 기준)
- **GCC**: 13.1 이상 (`-std=c++23`)
- **Clang**: 16.0 이상 (`-std=c++23`)
- **MSVC**: Visual Studio 2022 17.8 이상 (`/std:c++23`)
- **제약사항**: `<print>`는 최신 표준이므로, GCC 12 또는 Clang 15 이하에서는 사용 불가.

## 3. fmt 라이브러리: 지원되지 않는 환경에서의 대안

`fmt` 라이브러리는 `std::format`의 원형으로, C++20/C++23을 지원하지 않는 환경에서 동일한 포매팅 기능을 제공합니다. Chrome, Redis, MongoDB 등에서 사용됩니다.

### 특징
- **호환성**: C++11 이상에서 동작.
- **성능**: `std::format`과 유사하거나 더 빠름.
- **2025년 기준**: `fmt` 10.2.0 이상, C++23 `std::print` 호환 API 추가.

### 설치 방법

#### Ubuntu 24.04
```bash
sudo apt update
sudo apt install libfmt-dev
```

CMake:
```cmake
find_package(fmt CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE fmt::fmt)
```

#### Windows (vcpkg)
```bash
vcpkg install fmt:x64-windows
```

CMake:
```cmake
find_package(fmt CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE fmt::fmt)
```

#### 소스 빌드
```bash
git clone https://github.com/fmtlib/fmt
cd fmt
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build --target install
```

### 사용법
```cpp
#include <fmt/format.h>
#include <fmt/printf.h> // printf 스타일 지원
#include <fmt/std.h>   // C++23 print 호환

int main() {
    // std::format 스타일
    std::string s = fmt::format("Hello, {}! You are {} years old.", "Dave", 40);
    fmt::print("{}\n", s);

    // printf 스타일
    fmt::printf("Pi: %.2f\n", 3.14159);

    // C++23 print 스타일
    fmt::print("Modern C++: {}\n", 2023);
}
```

**출력**:
```
Hello, Dave! You are 40 years old.
Pi: 3.14
Modern C++: 2023
```

### 사용자 정의 타입
```cpp
#include <fmt/format.h>

struct Person {
    std::string name;
    int age;
};

template <>
struct fmt::formatter<Person> {
    constexpr auto parse(format_parse_context& ctx) { return ctx.begin(); }
    auto format(const Person& p, format_context& ctx) const {
        return fmt::format_to(ctx.out(), "Person{{name: {}, age: {}}}", p.name, p.age);
    }
};

int main() {
    Person p{"Eve", 45};
    fmt::print("{}\n", p); // 출력: Person{name: Eve, age: 45}
}
```

### 성능
- **벤치마크 (2025)**: `fmt::format`은 `std::format`과 비슷하거나 10~20% 빠름 (GCC 13, Clang 16).
- **메모리 효율성**: 동적 메모리 할당 최소화.
- **단점**: 외부 종속성 추가로 빌드 복잡성 증가 가능.

## std::format vs std::print vs fmt: 비교

| 기준             | std::format                     | std::print                      | fmt                           |
|------------------|---------------------------------|---------------------------------|--------------------------------|
| **표준**         | C++20                          | C++23                          | C++11 이상                    |
| **주요 사용 사례** | 문자열 생성                    | 콘솔 출력                       | 모든 환경                     |
| **성능**         | `printf`보다 빠름              | `std::cout`보다 빠름           | `std::format`과 유사/더 빠름  |
| **컴파일러 지원** | GCC 11+, Clang 14+, MSVC 2019 | GCC 13+, Clang 16+, MSVC 2022 | 대부분 컴파일러               |
| **유니코드**     | 제한적                         | UTF-8 최적화                   | UTF-8 지원                    |
| **디버깅**       | 표준 에러 메시지               | 표준 에러 메시지               | 상세 에러 메시지              |

### 선택 가이드
- **std::format**: C++20을 지원하는 환경에서 문자열 생성에 적합.
- **std::print**: C++23을 지원하며 간단한 콘솔 출력이 필요한 경우.
- **fmt**: C++20/23 미지원 환경, 또는 성능과 호환성을 모두 원하는 경우.
- **테스트 필수**: 워크로드에 따라 성능 차이가 있으므로 벤치마킹 권장.

## 결론

C++20의 `std::format`과 C++23의 `std::print`는 현대적인 문자열 포매팅과 출력을 제공하며, 타입 안전성과 성능을 개선합니다. 지원되지 않는 환경에서는 `fmt` 라이브러리가 강력한 대안입니다. 애플리케이션 요구사항과 컴파일러 지원 여부에 따라 적절한 도구를 선택하세요.

## 추가 리소스
- [C++ Reference: std::format](https://en.cppreference.com/w/cpp/utility/format)
- [C++ Reference: std::print](https://en.cppreference.com/w/cpp/io/print)
- [fmt GitHub](https://github.com/fmtlib/fmt)

{% endraw %}
