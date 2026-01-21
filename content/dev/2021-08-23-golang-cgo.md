---
title: Golang, Cgo
tags:
  - golang
  - cgo
  - ldd
  - otool
---
Cgo enables the creation of Go packages that call C code.

## Cgo
- <https://pkg.go.dev/cmd/cgo>{:target="_blank"}
- Golang에서 C 코드를 통합 할 수 있도록 만든 의사 패키지 

### C코드 - Go 파일 통합 

- 예제
  - `import "C"` 바로 윗 부분의 주석 `/* */` or `//` 으로 C코드 작성
  - C 함수, 변수 영역 접근시, `C` 의 패키지 명으로 접근   
  - 함수, 변수선언, #include 선행처리지시자 등 일반적인 C 코드
  - cgo Cheat Sheet : <https://gist.github.com/zchee/b9c99695463d8902cd33>{:target="_blank"}

```go
package main
/*
#include <stdio.h>      // printf
#include <stdlib.h>     // free (C.free)

void println(const char *s) {
	printf("%s\n", s);
}
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func main() {
	s := C.CString("c lang println")
	C.free(unsafe.Pointer(s))

	C.println(s)
	fmt.Println("golang println")
}
```

```sh
$ go mod init main
$ go build 

$ ./main
c lang println
golang println
```

### C코드 통합 - 별도 파일(C/C++)로 구성 
- 같은 디렉토리의 C/C++ file extention 의 경우 기본 gcc(g++)로 빌드 및 링크
- 별도 파일의 경우 C++ 코드도 작성이 가능하나, golang 에서는 C언어 (`Name mangling`) 방식만 지원
- `Name mangling`: 컴파일러가 함수명이나 변수이름을 특정한 규칙으로 변경
  - C++의 경우는 함수 Overloading으로 인해 C언어와 규칙이 다름 
  - `extern "C"`: C언어 방식의 Name mangling으로 처리

```sh
$ tree
├── go.mod
├── main.go
└── print.cpp
```

```go
package main

// #include <stdlib.h>    // free
// void println(char *s);
import "C"
import (
	"fmt"
	"unsafe"
)

func main() {
	s := C.CString("cpp println")
	C.free(unsafe.Pointer(s))

	C.println(s)
	fmt.Println("golang println")
}
```

```cpp
#include <iostream>
using namespace std;

extern "C" void println(const char *s);

void println(const char *s) 
{
	cout << s << endl;
}
```

```sh
$ go build 
$ ./main
cpp println
```

### Static, Dynamic library link 

```sh
$ tree
├── go.mod
├── main.go
└── native
    ├── print.cpp
    └── print.h
```

```cpp
// print.h
#pragma once 

#ifdef __cplusplus
extern "C" {
#endif 

void println(const char *s);

#ifdef __cplusplus
}
#endif 
```

```cpp
// print.cpp
#include <iostream>
#include "print.h"

void println(const char *s) 
{
	std::cout << s << std::endl;
}
```


> - #cgo LDFLAG: 컴파일러 라이브러리 링크 옵션 지정   
> - #cgo CFLAGS: 컴파일러 컴파일 옵션 

```go
package main

// #cgo LDFLAGS: -Lnative -lprint -lstdc++
// #include <stdlib.h>
// #include "native/print.h"
import "C"
import (
	"fmt"
	"unsafe"
)

func main() {
	s := C.CString("cpp println")
	C.free(unsafe.Pointer(s))

	C.println(s)
	fmt.Println("golang println")
}
```

#### Static link

```sh
$ cd native 
$ g++ -c print.cpp
$ ar -cr libprint.a print.o

$ cd ..
$ go build 
$ ./main
cpp println
golang println
```

#### Dynamic Link

```sh
$ cd native 
$ g++ -dynamic -fPIC -o libprint.so -c libprint.cpp

$ cd ..
$ go build
# Mac : export DYLD_LIBRARY_PATH=$(pwd)/native 
$ export LD_LIBRARY_PATH=/root/cgo/native 
$ ./main
cpp println
golang println
```

#### 의존성 확인 
- Linux 

``` 
$  ldd ./main
	linux-vdso.so.1 (0x0000ffff9446a000)
	libprint.so => /root/cgo/native/libprint.so (0x0000ffff94428000)
	libpthread.so.0 => /lib/aarch64-linux-gnu/libpthread.so.0 (0x0000ffff943f7000)
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000ffff94281000)
	libstdc++.so.6 => /usr/lib/aarch64-linux-gnu/libstdc++.so.6 (0x0000ffff940a9000)
	/lib/ld-linux-aarch64.so.1 (0x0000ffff9443a000)
	libm.so.6 => /lib/aarch64-linux-gnu/libm.so.6 (0x0000ffff93ffe000)
	libgcc_s.so.1 => /lib/aarch64-linux-gnu/libgcc_s.so.1 (0x0000ffff93fda000)
```

- Mac

``` 
$ otool -L ./main
./main:
	libprint.so (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 905.6.0)
	/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1775.118.101)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1292.100.5)
```

---

### 예제 : `char *` 다루기

```md
- string → *C.char : C.CString(string)  // C.free(unsafe.Pointer(*C.char)) 메모리 해제 필수
- *C.char → string : C.GoString(*C.char)
- []C.char' : byte slice → *C.char  // buff := make([]byte, 128), (*C.char)(unsafe.Pointer(&buff[0]))
- *C.char, C.int → string : C.GoStringN(*C.char, C.int)
```	

```go 
package main
/*
#include <stdlib.h>
#include <string.h>
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func getptr(buff []byte) *C.char {
	return (*C.char)(unsafe.Pointer(&buff[0]))
}

func main() {
	buff := make([]byte, 128)

	s := C.CString("Hello")
	defer C.free(unsafe.Pointer(s))

	C.strcpy(getptr(buff), s)

	fmt.Println(string(buff))
}
```