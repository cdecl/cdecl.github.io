---
title: Httplib (cpp-httplib) Sample
tags:
  - c++
  - httplib
  - cpp-httplib
  - cmake
---
## Introduction
- <https://github.com/yhirose/cpp-httplib>{:target="_blank"}
- A C++11 single-file header-only cross platform HTTP/HTTPS library.  
  - This is a multi-threaded 'blocking' HTTP library
- header-only 라이브러리로 Server와 Client Http 지원 
- SSL을 위한 OpenSSL 필요
- `cpprestsdk`비해 가볍고, 쉽게 사용 가능 

### Httplib package install (w/ vcpkg)
- <https://github.com/microsoft/vcpkg>{:target="_blank"}
- vcpkg 통해서 패키지 설치 
- header-only로 바로 사용가능하나 OpenSSL 필요시 패키지 설치가 용이

```sh
# --triplet=x64-windows-static
$ vcpkg.exe install cpp-httplib openssl --triplet=x64-windows-static

...
The package cpp-httplib:x64-windows-static is header only and can be used from CMake via:

    find_path(CPP_HTTPLIB_INCLUDE_DIRS "httplib.h")
    target_include_directories(main PRIVATE ${CPP_HTTPLIB_INCLUDE_DIRS})

The package openssl is compatible with built-in CMake targets:

    find_package(OpenSSL REQUIRED)
    target_link_libraries(main PRIVATE OpenSSL::SSL OpenSSL::Crypto)
```

#### Json test
- <https://github.com/nlohmann/json>{:target="_blank"}

```
$ vcpkg.exe install nlohmann-json --triplet=x64-windows-static
The package nlohmann-json:x64-windows-static provides CMake targets:

    find_package(nlohmann_json CONFIG REQUIRED)
    target_link_libraries(main PRIVATE nlohmann_json nlohmann_json::nlohmann_json)
```

### Sample code 
- HTTPS 호출을 위해 `CPPHTTPLIB_OPENSSL_SUPPORT` 매크로가 정의 되어 있어야 함
  - 정의하지 않고 HTTPS 호출시 : `'https' scheme is not supported.`
- `using namespace std;` std namespace 노출시 byte 타입 정의 모호함으로 인한 에러 발생
  - 표준 라이브러리 보다 먼저 선언되던가 `using namespace std;`를 피해야 함
  - 'byte': 모호한 기호입니다. 

```cpp
#define CPPHTTPLIB_OPENSSL_SUPPORT
#include <httplib.h>
#include <iostream>
using namespace std;

#include <nlohmann/json.hpp>
using json = nlohmann::json;

void HttpRequest()
{
	httplib::Client cli("https://httpbin.org");
	
	{
		auto resp = cli.Get("/get");
		cout << "status: " << resp->status << endl;
		cout << resp->body << endl;
	}
	{
		auto resp = cli.Post("/post");
		cout << "status: " << resp->status << endl;
		cout << resp->body << endl;

		auto js = json::parse(resp->body);
		cout << "User-Agent: " << js["headers"]["User-Agent"] << endl;
	}
}
 
int main()
{
	try {
		HttpRequest();
	}
	catch (exception &e) {
		cerr << e.what() << endl;
	}
	catch (...) {
		cerr << "catch ..." << endl;
	}
 
	return 0; 
}
```

### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.11)

project(main)
set(CMAKE_CXX_STANDARD 17)

add_executable(main main.cpp)

target_compile_options(main PRIVATE /MT)

find_package(OpenSSL REQUIRED)
target_link_libraries(main PRIVATE OpenSSL::SSL OpenSSL::Crypto)

find_path(CPP_HTTPLIB_INCLUDE_DIRS "httplib.h")
target_include_directories(main PRIVATE ${CPP_HTTPLIB_INCLUDE_DIRS})

find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(main PRIVATE nlohmann_json nlohmann_json::nlohmann_json)
```

```sh
$ mkdir build && cd build

# x64-windows-static
$ cmake -G "Visual Studio 16 2019" -A x64 .. -DCMAKE_TOOLCHAIN_FILE=D:/Lib/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static
```


### Build & Run

```sh
# build 
$ echo cmake --build . --config Release > make.bat
$ make.bat

# run
$ Release\main.exe
status: 200
{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Cache-Control": "max-stale=0",
    "Host": "httpbin.org",
    "User-Agent": "cpp-httplib/0.9",
    "X-Amzn-Trace-Id": "Root=1-611dba9f-0bdb46bb04c05b410da75cf4",
    "X-Bluecoat-Via": "ce2cfae06b3f12b4"
  },
  "origin": "xx.xx.xx.xx",
  "url": "https://httpbin.org/get"
}

status: 200
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Host": "httpbin.org",
    "User-Agent": "cpp-httplib/0.9",
    "X-Amzn-Trace-Id": "Root=1-611dba9f-091d99a41e5b3c023550162f",
    "X-Bluecoat-Via": "ce2cfae06b3f12b4"
  },
  "json": null,
  "origin": "xx.xx.xx.xx",
  "url": "https://httpbin.org/post"
}

User-Agent: "cpp-httplib/0.9"
```