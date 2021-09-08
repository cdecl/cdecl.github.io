---
title: C++20 Modules Test (`g++`)

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

{% raw %}

C++ Modules Test Example (g++)

## C++20 Modules
C++20 에 추가된 모듈 `Modules` 기능은 기존의 header files 의 `#include` 로 인한 컴파일 시간 증가 이슈 및 
필요한 로직(함수, 심볼)만을 내보내기(export)를 통해서 타 언어의 단위 모듈 처럼 효율적인 라이브러리 관리 목적

> 일종의 pch(precompiled header)의 기능을 포함한 표준적인 모듈 관리 기능 

> 현재 컴파일러마다 (msvc, g++, clang) Standard Library의 지원과 모듈을 사용하기위한 방법이 약간 상이함 

### GCC (G++) 기준 테스트
- 참고 : [C++20 Modules — Complete Guide](https://itnext.io/c-20-modules-complete-guide-ae741ddbae3d){:target="_blank"}

### GCC (G++) 11 설치 
- gcc 11 이상 버전 필요 (ubuntu)

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

#### Standard Library 사용 Example
- imort module 
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
}
```

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

$ g++ -std=c++20 -fmodules-ts -O2 -o main main.cpp adder.o

$ ./main
one - two
```

{% endraw %}