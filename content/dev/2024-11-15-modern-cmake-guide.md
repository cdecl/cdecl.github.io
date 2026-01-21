---
title: 모던 CMake 기본 가이드
tags:
  - c++
  - build
  - make
  - cmake
  - cmakelists.txt
  - modern cmake
  - cross platform
---
모던 CMake 기본 가이드: 타겟 중심의 현대적인 빌드 시스템



## 1. Makefile 대비 CMake의 장점

### 크로스 플랫폼 지원
- Makefile은 Unix 계열 시스템에 특화되어 있지만, CMake는 Windows, Linux, macOS 등 다양한 플랫폼 지원
- Visual Studio, Ninja, Unix Makefiles 등 다양한 빌드 시스템 생성 가능

### 타겟 중심의 의존성 관리
- 명확한 의존성 전파 (PUBLIC, PRIVATE, INTERFACE)
- 자동 헤더 의존성 추적
- 현대적인 패키지 관리 (find_package)

### 향상된 IDE 지원
- Visual Studio, CLion 등과 완벽한 통합
- 자동 완성 및 인텔리센스 지원
- CMake 프리셋 지원

## 2. 모던 CMake의 특징

### 기존 CMake와의 주요 차이점
- 타겟 중심 접근: 전역 변수 대신 특정 타겟에 한정하여 빌드 옵션을 지정합니다.
- 개선된 의존성 관리: 빌드 의존성 문제를 해결하고 불필요한 참조를 줄입니다.
- 새로운 명령어 도입: target_link_libraries, target_include_directories 등의 새로운 명령어를 사용합니다.
- PUBLIC, PRIVATE 키워드를 통한 세밀한 의존 관계 설정

> - CMake 3.0.0부터 모던 CMake의 기본 기능 지원
> - CMake 3.12+ 버전부터 "More Modern CMake" 기능 제공
> - CMake 3.15+ 버전 사용 권장

### 타겟 중심 접근
```cmake
# 안티패턴 (사용하지 말 것)
include_directories(include)
add_definitions(-DSOME_DEFINE)
link_directories(lib)

# 모던 패턴 (권장)
add_executable(myapp src/main.cpp)
target_include_directories(myapp
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)
target_compile_definitions(myapp
    PRIVATE
        SOME_DEFINE
)
target_link_directories(myapp
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/lib
)
```

### 범위와 전파
```cmake
# 라이브러리 설정
add_library(mylib SHARED
    src/lib.cpp
    include/lib.h
)

target_include_directories(mylib
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include  # 헤더는 공개
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src      # 구현은 비공개
)

# 실행 파일에서 라이브러리 사용
add_executable(myapp src/main.cpp)
target_link_libraries(myapp PRIVATE mylib)  # 자동으로 include 경로 전파
```

### 범위(Scope)와 전파(Propagation)의 개념
CMake에서 범위는 특정 설정(컴파일 옵션, include 디렉토리 등)이 어디에 적용될지를 나타냅니다. 전파는 이러한 설정이 다른 타겟(target)으로 전달되는 방식을 정의합니다.

- PRIVATE: 설정이 해당 타겟에만 적용됩니다.
- PUBLIC: 설정이 해당 타겟과 이를 사용하는 다른 타겟에 모두 적용됩니다.
- INTERFACE: 설정이 해당 타겟에는 적용되지 않고, 이를 사용하는 다른 타겟에만 전파됩니다.



## 3. CMake 기초 사용법

### 최소한의 CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject VERSION 1.0)
# C++17 사용 설정 (모던 방식)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(myapp src/main.cpp)
```

### 기본 빌드 명령어
```bash
# 권장하는 현대적인 방식
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## 4. 컴파일러 및 빌드 옵션

### 컴파일러 옵션 설정 (모던 방식)
```cmake
add_executable(myapp src/main.cpp)

# 컴파일러별 옵션 설정
target_compile_options(myapp
    PRIVATE
        $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra>
        $<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra>
        $<$<CXX_COMPILER_ID:MSVC>/W4>
)

# 최적화 옵션
target_compile_options(myapp PRIVATE
    $<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:Debug>>:-O0 -g>
    $<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:Release>>:-O3>
)
```

### 여러 소스 파일 추가
```cmake
# 명시적인 소스 파일 나열 (권장)
add_executable(myapp
    src/main.cpp
    src/utils.cpp
    src/config.cpp
)

# 또는 glob 패턴 사용 (권장하지 않음)
file(GLOB SOURCES "src/*.cpp")
add_executable(myapp ${SOURCES})
```

### 헤더 파일 및 라이브러리 포함
```cmake
target_include_directories(myapp
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/public_include
)

target_link_libraries(myapp
    PRIVATE
        mylib
        external::lib
)
```

## 5. 라이브러리 생성

### 정적 라이브러리
```cmake
add_library(staticlib STATIC
    src/lib1.cpp
    src/lib2.cpp
)

target_include_directories(staticlib
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Position Independent Code 설정
target_compile_options(staticlib
    PRIVATE
        $<$<CXX_COMPILER_ID:GNU>:-fPIC>
)
```

### 공유 라이브러리
```cmake
add_library(sharedlib SHARED
    src/lib1.cpp
    src/lib2.cpp
)

set_target_properties(sharedlib PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER include/lib.h
)

target_include_directories(sharedlib
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)
```

## 6. 빌드 구성

### Release/Debug 구성 설정 (모던 방식)
```cmake
add_executable(myapp src/main.cpp)

# Debug 구성
target_compile_definitions(myapp PRIVATE
    $<$<CONFIG:Debug>:DEBUG_MODE>
)

target_compile_options(myapp PRIVATE
    $<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:Debug>>:-g -O0 -Wall -Wextra>
    $<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:Release>>:-O3>
)
```

### 빌드 명령어
```bash
# Debug 빌드
cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug
cmake --build build-debug

# Release 빌드
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release
cmake --build build-release
```

## 7. 외부 라이브러리 통합

### 외부 라이브러리 찾기
```cmake
# Boost 찾기
find_package(Boost 1.70 REQUIRED COMPONENTS system filesystem)

target_link_libraries(myapp
    PRIVATE
        Boost::system
        Boost::filesystem
)

# OpenSSL 찾기
find_package(OpenSSL REQUIRED)
target_link_libraries(myapp
    PRIVATE
        OpenSSL::SSL
        OpenSSL::Crypto
)
```

### 설치 규칙 정의
```cmake
install(TARGETS myapp sharedlib
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)

install(FILES cmake/MyLibConfig.cmake
    DESTINATION lib/cmake/MyLib
)
```

## 8. 모범 사례

### 프로젝트 구조
```
project/
├── CMakeLists.txt
├── cmake/
│   └── FindMyLib.cmake
├── include/
│   └── public_header.h
├── src/
│   ├── private_header.h
│   └── source.cpp
├── tests/
│   └── CMakeLists.txt
└── extern/
    └── third_party_lib/
```

### 변수 명명 규칙
```cmake
# 프로젝트 옵션
option(BUILD_TESTING "Build tests" ON)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(MYPROJECT_BUILD_EXAMPLES "Build example programs" OFF)

# 캐시 변수
set(MYPROJECT_SOME_OPTION "default" CACHE STRING "Option description")
```

### 권장 사항
- 전역 변수 사용을 피하고 타겟별 설정 사용
- 명시적인 의존성 선언
- target_* 명령어 사용
- 제너레이터 표현식 활용
- CMake 프리셋 사용


