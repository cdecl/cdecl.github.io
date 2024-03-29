---
title:  Vcpkg Basic

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - c++
  - vcpkg
  - cmake
  - triplet
---

<https://vcpkg.io/>{:target="_blank"}   
Vcpkg helps you manage C and C++ libraries on Windows, Linux and MacOS. This tool and ecosystem are constantly evolving, and we always appreciate contributions!

## Introduction
- <https://github.com/microsoft/vcpkg>{:target="_blank"}
- MS에서 만든 C++ Library Package 관리 (Cross Platform)

### Vcpkg install
- Git 이 필요하고, bootstrap-vcpkg 실행으로 필요한 툴을 다운로드(빌드)하는 작업을 수행
  - `vcpkg.exe` 생성 

```sh
$ git clone https://github.com/microsoft/vcpkg
$ cd vcpkg

# windows
$ bootstrap-vcpkg.bat

# linux 
$ ./bootstrap-vcpkg.sh
```

### Package search & install
- `triplet` : Target configuration set
- 설치시 `triplet` 을 지정하지 않으면 설치되어 있는 기본 C++ Toolset 으로 지정 
  - Windows의 경우 `x86-windows` default

  
#### 주요 Triplet list
- `vcpkg help triplet`

```sh
$ vcpkg help triplet
Available architecture triplets
VCPKG built-in triplets:
...
  x64-windows-static
  x64-windows
  x86-windows
...
VCPKG community triplets:
...
  x64-windows-static-md
  x86-windows-static-md
  x86-windows-static
  x64-mingw-dynamic
  x64-mingw-static
  x86-mingw-dynamic
  x86-mingw-static  
  x64-linux
...
```

#### Search 
- `vcpkg search` 

```sh
# Package search 
$ vcpkg search fmt
fmt                      7.1.3#5          Formatting library for C++. ...
The search result may be outdated. Run `git pull` to get the latest results. 
```

#### Install
- `vcpkg install` 
- `vcpkg search` 에서 찾은 패키지를 triplet 을 지정하여 설치
- 설치가 완료되면 프로젝트 CMakeLists.txt 넣을 find_package 문 표시 

```sh
# Package 별로 triplet 지정 
$ vcpkg.exe install fmt:x64-windows-static nlohmann-json:x64-windows-static

# triplet 공통 지정 
$ vcpkg.exe install fmt nlohmann-json --triplet=x64-windows-static
...
The package fmt provides CMake targets:

    find_package(fmt CONFIG REQUIRED)
    target_link_libraries(main PRIVATE fmt::fmt)

    # Or use the header-only version
    find_package(fmt CONFIG REQUIRED)
    target_link_libraries(main PRIVATE fmt::fmt-header-only)

The package nlohmann-json:x64-windows-static provides CMake targets:

    find_package(nlohmann_json CONFIG REQUIRED)
    target_link_libraries(main PRIVATE nlohmann_json nlohmann_json::nlohmann_json)
```

#### 설치된 리스트 
- `vcpkg list` 

```sh
# Package installed list 
$ vcpkg list
benchmark:x64-mingw-static                         1.5.5            A library to support the benchmarking of functio...
benchmark:x64-windows-static                       1.5.5            A library to support the benchmarking of functio...
cpp-httplib:x64-mingw-static                       0.9.1            A single file C++11 header-only HTTP/HTTPS serve...
cpp-httplib:x64-windows-static                     0.9.1            A single file C++11 header-only HTTP/HTTPS serve...
fmt:x64-windows                                    7.1.3#5          Formatting library for C++. It can be used as a ...
fmt:x64-windows-static                             7.1.3#5          Formatting library for C++. It can be used as a ...
nlohmann-json:x64-mingw-static                     3.9.1            JSON for Modern C++
nlohmann-json:x64-windows-static                   3.9.1            JSON for Modern C++
openssl:x64-mingw-static                           1.1.1k#8         OpenSSL is an open source project that provides ...
openssl:x64-windows-static                         1.1.1k#8         OpenSSL is an open source project that provides ...
vcpkg-cmake-config:x64-windows                     2021-05-22#1
vcpkg-cmake:x64-windows                            2021-07-30
zlib:x64-mingw-static                              1.2.11#11        A compression library
zlib:x64-windows-static                            1.2.11#11        A compression library
```

### Integrate install
- `vcpkg integrate install`
- Windows Visual Studio에서 vcpkg 라이브러리를 별도 설정 없이 바로 사용

```sh
$ vcpkg integrate install
Applied user-wide integration for this vcpkg root.

All MSBuild C++ projects can now #include any installed libraries.
Linking will be handled automatically.
Installing new libraries will make them instantly available.

CMake projects should use: "-DCMAKE_TOOLCHAIN_FILE=D:/Lib/vcpkg/scripts/buildsystems/vcpkg.cmake"
```

### vcpkg 명령어 

```sh
# Vcpkg package management program version 2021-08-12-85ab112d5ee102bc6eac8cdbbfdd173a71374e04
$ vcpkg help
Commands:
  vcpkg search [pat]              Search for packages available to be built
  vcpkg install <pkg>...          Install a package
  vcpkg remove <pkg>...           Uninstall a package
  vcpkg remove --outdated         Uninstall all out-of-date packages
  vcpkg list                      List installed packages
  vcpkg update                    Display list of packages for updating
  vcpkg upgrade                   Rebuild all outdated packages
  vcpkg x-history <pkg>           (Experimental) Shows the history of CONTROL versions of a package
  vcpkg hash <file> [alg]         Hash a file by specific algorithm, default SHA512
  vcpkg help topics               Display the list of help topics
  vcpkg help <topic>              Display help for a specific topic

  vcpkg integrate install         Make installed packages available user-wide. Requires admin
                                  privileges on first use
  vcpkg integrate remove          Remove user-wide integration
  vcpkg integrate project         Generate a referencing nuget package for individual VS project use
  vcpkg integrate powershell      Enable PowerShell tab-completion

  vcpkg export <pkg>... [opt]...  Exports a package
  vcpkg edit <pkg>                Open up a port for editing (uses %EDITOR%, default 'code')
  vcpkg create <pkg> <url> [archivename]
                                  Create a new package
  vcpkg x-init-registry <path>    Initializes a registry in the directory <path>
  vcpkg owns <pat>                Search for files in installed packages
  vcpkg depend-info <pkg>...      Display a list of dependencies for packages
  vcpkg env                       Creates a clean shell environment for development or compiling
  vcpkg version                   Display version information
  vcpkg contact                   Display contact information to send feedback
...
```


---

### 1. 내 프로젝트에서 사용 (CMake, find_package)
- CMakeLists.txt 에 find_package 내용 추가 

#### CMakeLists.txt 

```cmake
cmake_minimum_required(VERSION 3.11)

project(main)
set(CMAKE_CXX_STANDARD 17)

add_executable(main main.cpp)

if(MSVC)
	target_compile_options(main PRIVATE /MT)
else()
	target_compile_options(main PRIVATE -Wall -O2)
endif()

find_package(fmt CONFIG REQUIRED)
target_link_libraries(main PRIVATE fmt::fmt)

find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(main PRIVATE nlohmann_json nlohmann_json::nlohmann_json)
```

#### CMake 초기화 
- `CMAKE_TOOLCHAIN_FILE` 과 `VCPKG_TARGET_TRIPLET` 을 지정하여 초기화 
  - `CMAKE_TOOLCHAIN_FILE` : vcpkg/scripts/buildsystems/vcpkg.cmake

```sh
$ mkdir build && cd build

# windows msvc 
$ cmake -G "Visual Studio 16 2019" -A x64 .. -DCMAKE_TOOLCHAIN_FILE=D:/Lib/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static

# windows mingw
$ cmake -G "MSYS Makefiles" .. -DCMAKE_TOOLCHAIN_FILE=D:/Lib/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-mingw-static

# linux : VCPKG_TARGET_TRIPLET 지정안함, defualt 사용 
$ cmake cmake .. -DCMAKE_TOOLCHAIN_FILE=~/lib/vcpkg/scripts/buildsystems/vcpkg.cmake
```

#### Build 

```sh
# windows msvc : Release 모드 빌드 
$ cmake --build . --config=Release
# run 
$ Release\main.exe

# mingw, linux 
$ make 
$ ./main
```

### 2. 내 프로젝트에서 사용 (라이브러리 수동으로 설정)
- CMake 수동 지정 : target_include_directories, target_link_directories, target_link_libraries 별도 지정 
- Makefile 사용 : `-I` `-l` `-L` 등의 옵션 추가 

#### vcpkg/installed/`triplet` 디렉토리 참고 
- 수동으로 include, lib 등 지정 사용 
  - `triplet/include` : header files
  - `triplet/lib` : static library
  - `triplet/bin` : shared library

```sh
$  tree vcpkg/installed -L 3
vcpkg/installed
├── vcpkg
...
├── x64-mingw-static
│   ├── debug
│   │   └── lib
│   ├── include
│   │   ├── benchmark
│   │   ├── httplib.h
│   │   ├── nlohmann
│   │   ├── openssl
│   │   ├── zconf.h
│   │   └── zlib.h
│   ├── lib
│   │   ├── libbenchmark.a
│   │   ├── libbenchmark_main.a
│   │   ├── libcrypto.a
│   │   ├── libssl.a
│   │   ├── libzlib.a
│   │   └── pkgconfig
│   └── share
│       ├── benchmark
│       ├── cpp-httplib
│       ├── nlohmann-json
│       ├── nlohmann_json
│       ├── openssl
│       └── zlib
├── x64-windows
│   ├── bin
│   │   ├── fmt.dll
│   │   └── fmt.pdb
│   ├── debug
│   │   ├── bin
│   │   └── lib
│   ├── include
│   │   └── fmt
│   ├── lib
│   │   ├── fmt.lib
│   │   └── pkgconfig
│   └── share
│       ├── fmt
│       ├── vcpkg-cmake
│       └── vcpkg-cmake-config
└── x64-windows-static
    ├── debug
    │   ├── lib
    │   └── misc
    ├── include
    │   ├── benchmark
    │   ├── fmt
    │   ├── httplib.h
    │   ├── nlohmann
    │   ├── openssl
    │   ├── zconf.h
    │   └── zlib.h
    ├── lib
    │   ├── benchmark.lib
    │   ├── benchmark_main.lib
    │   ├── fmt.lib
    │   ├── libcrypto.lib
    │   ├── libssl.lib
    │   ├── ossl_static.pdb
    │   ├── pkgconfig
    │   └── zlib.lib
    ├── misc
    │   ├── CA.pl
    │   └── tsget.pl
    ├── share
    │   ├── benchmark
    │   ├── cpp-httplib
    │   ├── fmt
    │   ├── nlohmann-json
    │   ├── nlohmann_json
    │   ├── openssl
    │   └── zlib
    └── tools
        └── openssl

```



