---
title:  C++ REST SDK(cpprestsdk) Sample

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - c++
  - cpprestsdk
  - vcpck
---


## Introduction
- <https://github.com/Microsoft/cpprestsdk>{:target="_blank"}
- Microsoft에서 만든 클라이언트, 서버용 C++ HTTP 통신 모듈이며, JSON URI, 비동기, 웹소켓, oAuth 등을 지원 
- C++11의 비동기, 병렬 프로그램 모델 지원
- 크로스 플랫폼 지원 등..

### cpprestsdk package install (w/ vcpkg)
- <https://github.com/microsoft/vcpkg>{:target="_blank"}
- vcpkg 통해서 패키지 설치 

```sh
# --triplet=x64-windows-static
$ vcpkg.exe install cpprestsdk:x64-windows-static

...
The package cpprestsdk:x64-windows-static provides CMake targets:

    find_package(cpprestsdk CONFIG REQUIRED)
    target_link_libraries(main PRIVATE cpprestsdk::cpprest cpprestsdk::cpprestsdk_zlib_internal cpprestsdk::cpprestsdk_brotli_internal)
```

### Sample code 
- U("") 는 _T("") 와 비슷한, UNICODE 및 MBCS 환경의 문자열 타입을 스위칭 해주는 매크로. 
  - 허나 U는 _T와는 다르게 _WIN32 환경이면 기본으로 _UTF16_STRINGS으로 정의되어 있어 프로젝트의 문자집합의 세팅과 관계 없이 UNICODE와 같은 환경으로 동작 
  - 리눅스 환경에서는 다른 설정을 해주지 않는 이상 char, std::string으로 정의 
- utility::string_t은 std::string과 std::wstring을 스위칭 해주는 타입 
- 대체적인 패턴은, 동기는 .get(), 비동기는 then().wait() 조합으로 사용


```cpp
#include <iostream>
using namespace std;
#include <cpprest/http_client.h>
#include <cpprest/filestream.h>
using namespace utility;
using namespace web;
using namespace web::http;
using namespace web::http::client;
using namespace concurrency::streams;
 
void HttpRequest()
{
	http_client client(U("http://httpbin.org/get"));
	http_request req(methods::GET);

	// sync request
	auto resp = client.request(req).get();
	wcout << resp.status_code() << " : sync request" << endl;
	wcout << resp.extract_string(true).get() << endl;
 
 	// async request
	client.request(req).then([=](http_response r){
		wcout << r.status_code() << " : async request" << endl;
		wcout << U("content-type : ") << r.headers().content_type() << endl;
 
		r.extract_string(true).then([](string_t v) {
			wcout << v << endl;
		}).wait();

	}).wait();

	// async request json
	client.request(req).then([=](http_response r){
		wcout << r.status_code() << " : async request json" << endl;
		wcout << U("content-type : ") << r.headers().content_type() << endl;
 
		r.extract_json(true).then([](json::value v) {
			wcout << v << endl;
		}).wait();
	}).wait();
}
 
int main()
{
	// wcout.imbue(locale("kor"));  // windows only
	HttpRequest();
 
	return 0; 
}
```

### CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.11)

project(main)

add_executable(main main.cpp)
target_compile_options(main PRIVATE /MT)

find_package(cpprestsdk CONFIG REQUIRED)
target_link_libraries(main PRIVATE cpprestsdk::cpprest cpprestsdk::cpprestsdk_zlib_internal cpprestsdk::cpprestsdk_brotli_internal)
```

```sh
$ mkdir build && cd build

# x64-windows-static
$ cmake -G "Visual Studio 16 2019" -A x64 .. -DCMAKE_TOOLCHAIN_FILE=D:/Lib/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static
```


### Build & Run

```sh
# build 
$ cmake --build . --config Release

# run
$ Release\main.exe
200 : sync request
{
  "args": {},
  "headers": {
    "Cache-Control": "max-stale=0",
    "Host": "httpbin.org",
    "User-Agent": "cpprestsdk/2.10.18",
    "X-Amzn-Trace-Id": "Root=1-611cbc68-27731b2a1cd55cbd682c517e",
    "X-Bluecoat-Via": "ce2cfae06b3f12b4"
  },
  "origin": "180.70.97.80",
  "url": "http://httpbin.org/get"
}

200 : async request
content-type : application/json
{
  "args": {},
  "headers": {
    "Cache-Control": "max-stale=0",
    "Host": "httpbin.org",
    "User-Agent": "cpprestsdk/2.10.18",
    "X-Amzn-Trace-Id": "Root=1-611cbc68-27731b2a1cd55cbd682c517e",
    "X-Bluecoat-Via": "ce2cfae06b3f12b4"
  },
  "origin": "180.70.97.80",
  "url": "http://httpbin.org/get"
}

200 : async request json
content-type : application/json
{"args":{},"headers":{"Cache-Control":"max-stale=0","Host":"httpbin.org","User-Agent":"cpprestsdk/2.10.18","X-Amzn-Trace-Id":"Root=1-611cbc68-27731b2a1cd55cbd682c517e","X-Bluecoat-Via":"ce2cfae06b3f12b4"},"origin":"180.70.97.80","url":"http://httpbin.org/get"}
```