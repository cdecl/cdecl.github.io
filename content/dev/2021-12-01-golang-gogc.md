---
title: Golang GC
tags:
  - golang
  - gogc
  - tcmalloc
  - tri-color
  - gctrace
last_modified_at: '2024-11-15'
---
Golang GC (가비지 컬렉터) 주요 내용



## Golang GC : `GOGC`
- 유효하지 않는 메모리(Dangling Object)를 주기적으로 해제하는 기법
  - Java의 `Parallel GC`, `G1GC` 와 유사하나 구현 방식에서 차이가 있음
  - Stop-the-World 시간을 최소화하도록 설계됨
- Tri-Color Algorithm 사용
  - 동시성을 고려한 효율적인 메모리 관리 알고리즘
- CMS (Concurrent Mark and Sweep) 방식 운영
  - Java 와 같은 Generation GC 기법이나 Compaction은 지원하지 않음
  - 대신 더 효율적인 메모리 할당 전략을 사용
- Compaction (압축, 재배치) 가 없음 
  - 재배치를 하지 않는 대신 `TCMalloc`를 통한 메모리 할당 관리
  - 메모리 단편화를 최소화하고 빠른 할당을 지원
  - [멀티쓰레드 최적화 힙 메모리 할당기 - tcmalloc. jemalloc](https://cdecl.net/304){:target="_blank"}

### Tri-Color Algorithm 동작 원리
`white`, `black`, `grey` 세 가지 상태를 통한 메모리 관리 

1. 초기 단계
   - 모든 메모리 객체를 `white` 상태로 설정
   - 이는 잠재적으로 수집 가능한 상태를 의미

2. 마킹 단계
   - `GC Root`에서 직접 참조하는 객체들을 `grey`로 표시
   - `grey` 객체들은 검사가 필요한 상태를 의미

3. 스캐닝 단계
   - `grey` 상태 객체가 참조하는 다른 객체들을 `grey`로 표시
   - 검사가 완료된 객체는 `black`으로 변경
   - 이 과정을 grey 객체가 없을 때까지 반복

4. 수집 단계
   - 남아있는 `white` 상태의 객체들을 메모리에서 해제
   - 이 객체들은 더 이상 접근할 수 없는(unreachable) 상태

![Tri-Color Mark and Sweep](/images/2021-12-02-10-43-45.png)

### TCMalloc (Thread-Caching Malloc)
- Google이 개발한 고성능 메모리 할당기
- 특징:
  - Thread 별 캐시를 통한 빠른 메모리 할당
  - 크기별로 최적화된 할당 전략 사용
  - 메모리 단편화 최소화
  - Lock contention 감소로 인한 성능 향상

- 장점:
  - 멀티스레드 환경에서 우수한 성능
  - 메모리 재사용 최적화
  - 캐시 지역성 향상
  - 할당/해제 오버헤드 감소

### GOGC 옵션
가비지 컬렉션 대상 백분율 설정  
이전 수집 후 남은 라이브 데이터에 대한 새로 할당된 데이터의 비율을 조정

- `GOGC=100` : 기본값, 100% 비율
  - 힙이 라이브 메모리의 100%만큼 증가하면 GC 트리거
- `GOGC=50` : GC를 더 자주 실행
  - 메모리 사용량은 줄지만 CPU 사용량 증가
- `GOGC=200` : GC를 덜 자주 실행
  - CPU 사용량은 줄지만 메모리 사용량 증가
- `GOGC=off` : GC를 사용하지 않음
  - 특수한 경우에만 사용 (벤치마크, 테스트 등)

### GC Trace 활용
`gctrace` 옵션을 통한 가비지 컬렉션 모니터링

#### 예제 코드
```go
package main

import (
	"fmt"
	"sync"
	"time"
)

type log struct {
	Info string
	Seq  int
}

func main() {
	wg := sync.WaitGroup{}

	for i := 0; i < 1000000; i++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			info := fmt.Sprintf("test %d", i)
			_ = log{info, i}
			// fmt.Println(s, t)
			time.Sleep(time.Millisecond * 1000)
		}()
	}
	wg.Wait()
}
```

#### 실행 및 모니터링
```sh
# 프로젝트 초기화
$ go mod init gctest
$ go mod tidy

# build
$ go build
```

##### 실행 테스트

```sh
# GODEBUG=gctrace=1 : gctrace 활성화
$ GODEBUG=gctrace=1 ./gctest
```

#### 트레이스 출력 분석
```
gc 1 @0.010s 9%: 0.058+2.6+0.083 ms clock, 0.46+6.6/2.9/0+0.66 ms cpu, 4->5->4 MB, 5 MB goal, 8 P
gc 2 @0.015s 19%: 0.093+4.7+0.17 ms clock, 0.74+14/6.1/0+1.4 ms cpu, 6->7->6 MB, 8 MB goal, 8 P
gc 3 @0.027s 25%: 0.15+5.7+0.34 ms clock, 1.2+22/9.0/0+2.7 ms cpu, 10->13->11 MB, 13 MB goal, 8 P
gc 4 @0.044s 29%: 0.084+11+0.35 ms clock, 0.67+45/18/0+2.8 ms cpu, 18->22->20 MB, 23 MB goal, 8 P
gc 5 @0.076s 31%: 0.24+17+0.19 ms clock, 1.9+66/31/0+1.5 ms cpu, 32->37->34 MB, 40 MB goal, 8 P
gc 6 @0.129s 33%: 0.13+26+0.065 ms clock, 1.1+124/50/4.6+0.52 ms cpu, 54->62->58 MB, 68 MB goal, 8 P
gc 7 @0.214s 34%: 0.095+40+0.099 ms clock, 0.76+204/79/0.34+0.79 ms cpu, 93->98->91 MB, 116 MB goal, 8 P
gc 8 @0.355s 35%: 0.086+66+0.12 ms clock, 0.69+375/132/0+0.99 ms cpu, 152->158->144 MB, 182 MB goal, 8 P
gc 9 @0.605s 35%: 0.11+109+0.087 ms clock, 0.88+624/216/0+0.70 ms cpu, 252->261->242 MB, 289 MB goal, 8 P
gc 10 @1.033s 35%: 0.077+206+1.0 ms clock, 0.61+1021/397/0.93+8.1 ms cpu, 430->437->403 MB, 484 MB goal, 8 P
```

#### 출력 항목 설명:
- `gc 1`: GC 실행 번호
- `@0.010s`: 프로그램 시작 후 경과 시간
- `9%`: GC에 사용된 CPU 시간 비율
- `0.058+2.6+0.083 ms`: 각 GC 단계별 소요 시간
- `4->5->4 MB`: GC 전후의 힙 크기 변화
- `5 MB goal`: 목표 힙 크기
- `8 P`: 사용된 프로세서 수

