---
title: C++ 메모리 할당기 - tcmalloc, jemalloc

toc: true
toc_sticky: true

categories:
  - dev

tags:
  - c++
  - memory-allocation
  - tcmalloc
  - jemalloc
  - mimalloc
  - multithreading
  - performance
---

멀티스레드 최적화 힙 메모리 할당기: tcmalloc, jemalloc

> [이글 UPDATE : https://cdecl.tistory.com/304](https://cdecl.tistory.com/304)

## 왜 멀티스레드 메모리 할당기가 중요한가?

기본 메모리 할당기(glibc의 `malloc`, Windows의 `HeapAlloc`)는 범용성을 목표로 설계되었지만, 멀티스레드 환경에서는 다음과 같은 문제로 성능이 저하됩니다:
- **락 경합(Lock Contention)**: 다중 스레드가 동시에 메모리를 할당/해제할 때 락으로 인한 대기 시간 증가.
- **메모리 단편화(Memory Fragmentation)**: 빈번한 할당/해제로 메모리 사용 효율 저하.
- **ABI 호환성 문제**: 서로 다른 컴파일러나 표준 라이브러리 간 메모리 관리 방식 차이로 인한 런타임 오류.

**tcmalloc**, **jemalloc**, **mimalloc**은 스레드별 캐싱, 효율적인 메모리 관리, ABI 안정성을 고려한 설계로 이러한 문제를 해결합니다. 이들은 웹 브라우저(Chrome, Firefox), 데이터베이스(MySQL, RocksDB), 고성능 서버에서 널리 사용됩니다.

## 1. tcmalloc (Thread-Caching Malloc)

**tcmalloc**은 Google이 개발한 고성능 메모리 할당기로, Chrome, TensorFlow, MySQL 등에서 사용됩니다. 스레드별 캐싱과 페이지 단위 할당으로 락 경합을 최소화합니다.

### 특징
- **스레드별 캐싱**: 각 스레드에 로컬 캐시를 제공해 락 없는 할당.
- **공간 효율성**: 소형 객체(≤256KB)에서 1% 미만 오버헤드.
- **대형 객체**: 256KB 이상은 페이지 단위로 직접 할당.
- **최신 업데이트 (2025)**: per-CPU 캐싱 모드 개선으로 스레드 확장성 강화, C23 표준의 메모리 정렬 최적화 지원.

### 설치 방법

#### Ubuntu 24.04
```bash
sudo apt update
sudo apt install libtcmalloc-minimal4
```

CMake 설정:
```cmake
find_library(TCMALLOC_LIB tcmalloc_minimal)
target_link_libraries(myapp PRIVATE ${TCMALLOC_LIB})
```

#### Windows 11 (MSVC/vcpkg)
```bash
vcpkg install gperftools:x64-windows
```

CMake:
```cmake
find_package(gperftools CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE gperftools::tcmalloc_minimal)
```

#### 소스 빌드
```bash
git clone https://github.com/gperftools/gperftools
cd gperftools
./autogen.sh
./configure --prefix=/usr/local
make && sudo make install
```

### 사용 방법
1. **직접 호출**:
    ```cpp
    #include <gperftools/tcmalloc.h>
    void* ptr = tc_malloc(size);
    tc_free(ptr);
    ```

2. **라이브러리 링크** (기본 `malloc` 대체):
    ```bash
    g++ -o myapp myapp.cpp -ltcmalloc_minimal
    ```

3. **LD_PRELOAD** (권장하지 않음):
    ```bash
    LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so ./myapp
    ```

#### Windows (MSVC)
```cpp
#pragma comment(lib, "libtcmalloc_minimal.lib")
#pragma comment(linker, "/include:__tcmalloc")
```

### 성능
- **벤치마크 (2025)**: 16코어 서버에서 glibc `malloc` 대비 소형 객체 할당 3.5배 빠름.
- **MySQL**: 8 vCPU 환경에서 TPS 5500 (glibc: 3500).
- **단점**: 메모리 사용량이 glibc보다 2~3배 높을 수 있음.

### ABI 고려사항
- GCC/Clang에서 `-D_GLIBCXX_USE_CXX11_ABI=1` 설정 필요.
- `libstdc++`와 `libc++` 혼용 시 메모리 손상 가능.

## 2. jemalloc

**jemalloc**은 Firefox, FreeBSD, RocksDB에서 사용되는 메모리 할당기로, 메모리 단편화 감소와 멀티스레드 확장성에 강점이 있습니다.

### 특징
- **아레나 기반 할당**: 스레드별 독립 메모리 아레나로 경합 최소화.
- **단편화 감소**: 슬랩 기반 소형 객체 관리.
- **디버깅**: `malloc_stats_print()`와 `mallctl`로 메모리 통계 제공.
- **최신 업데이트 (2025)**: jemalloc 5.4.0, 동적 스레드 풀 최적화.

### 설치 방법

#### Ubuntu 24.04
```bash
sudo apt update
sudo apt install libjemalloc-dev
```

CMake:
```cmake
find_library(JEMALLOC_LIB jemalloc)
target_link_libraries(myapp PRIVATE ${JEMALLOC_LIB})
```

#### Windows 11 (vcpkg)
```bash
vcpkg install jemalloc:x64-windows
```

CMake:
```cmake
find_package(jemalloc CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE jemalloc::jemalloc)
```

#### 소스 빌드
```bash
git clone https://github.com/jemalloc/jemalloc
cd jemalloc
./autogen.sh
./configure --prefix=/usr/local
make && sudo make install
```

### 사용 방법
1. **직접 호출**:
    ```cpp
    #include <jemalloc/jemalloc.h>
    void* ptr = je_malloc(size);
    je_free(ptr);
    ```

2. **라이브러리 링크**:
    ```bash
    g++ -o myapp myapp.cpp -ljemalloc
    ```

3. **LD_PRELOAD**:
    ```bash
    LD_PRELOAD=/usr/lib/libjemalloc.so ./myapp
    ```

#### C++ 사용자 정의 할당자
```cpp
#include <jemalloc/jemalloc.h>
void* operator new(size_t size) { return je_malloc(size); }
void operator delete(void* ptr) noexcept { je_free(ptr); }
```

### 성능
- **벤치마크**: MySQL 16코어 환경에서 glibc 대비 TPS 2.2배.
- **메모리 효율성**: RocksDB에서 RSS 55% 감소.
- **단점**: 동적 스레드 생성/소멸 빈번 시 캐시 오버헤드.

### ABI 고려사항
- 표준 라이브러리 객체(`std::vector`)를 인터페이스로 노출하면 안 됨.
- `extern "C"` 인터페이스 사용 권장.

## 3. mimalloc

Microsoft의 **mimalloc**은 컴팩트하고 고성능 할당기로, 서버 워크로드와 긴 실행 시간 애플리케이션에 최적화되었습니다.

### 특징
- **스레드 간 객체 마이그레이션**: 캐시 효율성 극대화.
- **낮은 오버헤드**: 메모리 사용량 최소화.
- **최신 업데이트 (2025)**: C23 정렬 최적화, ARM64 성능 개선.

### 설치
```bash
vcpkg install mimalloc
```

CMake:
```cmake
find_package(mimalloc CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE mimalloc)
```

### 성능
- **벤치마크**: Lean 컴파일러에서 tcmalloc 대비 15% 속도 향상.
- **메모리 효율성**: glibc 대비 RSS 40% 감소.

### ABI 고려사항
- 표준 라이브러리와의 호환성을 위해 동일한 컴파일러/플래그 사용.

## tcmalloc vs. jemalloc vs. mimalloc: 비교

| 기준             | tcmalloc                        | jemalloc                        | mimalloc                       |
|------------------|---------------------------------|---------------------------------|--------------------------------|
| **주요 사용 사례** | Chrome, MySQL, TensorFlow      | Firefox, FreeBSD, RocksDB      | Lean, 서버 워크로드            |
| **성능**         | 소형 객체 할당 속도 빠름        | 단편화 감소에 강점             | 균형 잡힌 성능                |
| **메모리 효율성** | glibc 대비 2~3배 사용량 증가 가능 | glibc 대비 RSS 55% 감소        | glibc 대비 RSS 40% 감소       |
| **멀티스레드**   | 동적 스레드 환경에 유리         | 정-static 스레드 풀에 최적화   | 동적/정적 모두 적합           |
| **디버깅 도구**  | 힙 프로파일링 지원              | 상세 통계, mallctl API         | 기본 통계 제공                |

### 선택 가이드
- **tcmalloc**: 소형 객체 할당이 빈번하거나 동적 스레드 환경(웹 브라우저, 실시간 서버).
- **jemalloc**: 메모리 단편화가 문제인 장기 실행 서버(데이터베이스, 캐시 서버).
- **mimalloc**: 메모리 효율성과 성능 균형이 필요한 최신 프로젝트.
- **테스트 필수**: 애플리케이션 워크로드에 따라 성능 차이가 크므로 벤치마킹 필수.

## 결론

**tcmalloc**, **jemalloc**, **mimalloc**은 멀티스레드 환경에서 glibc `malloc`을 대체해 성능과 메모리 효율성을 크게 향상시킵니다.  
애플리케이션 특성에 맞는 할당기를 선택하려면 직접 벤치마킹이 필수입니다.  

## 추가 리소스
- [tcmalloc GitHub](https://github.com/gperftools/gperftools)
- [jemalloc GitHub](https://github.com/jemalloc/jemalloc)
- [mimalloc GitHub](https://github.com/microsoft/mimalloc)
