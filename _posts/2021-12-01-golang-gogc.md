---
title: Golang GC

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - golang 
  - gogc
  - tcmalloc
  - tri-color
  - gctrace
---

Golang GC (가비지 컬렉터) 주요 내용

{% raw %}

## Golang GC : `GOGC`
- 유효하지 않는 메모리(Danling Object)를 주기적으로 해제하는 기법
  - Java의 `Parallel GC`, `G1GC` 와 같은
- Tri-Color Algorithm 사용
- CMS (Concurrent Mark and Sweep) 방식 운영
  - Java 와 같은 Generation GC 기법이나 Compaction은 지원하지 않음
- Compaction (압축, 재배치) 가 없음 
  - 재배치를 하지 않는 대신 `TCMalloc`를 통한 메모리 할당 관리
  - [멀티쓰레드 최적화 힙 메모리 할당기 - tcmalloc. jemalloc](https://cdecl.net/304){:target="_blank"}

#### Tri-Color Algorithm 사용
`white`, `black`, `grey` 상태를 통한 메모리 관리 

- 초기 모든 메모리 상태를 `white` 로 set
- `GC Root` 부터 연결되어 있는 주소를 `grey`로 표시
- `grey` 상태에서 연결 되어 있는 주소를 `grey`로 표시, 자기는 `black`로 표시
- 위 내용 반복 후, 남은 `white` 상태 memory free (unreachable) 

![](/images/2021-12-02-10-43-45.png)

#### TCMalloc
- <https://github.com/google/tcmalloc>{:target="_blank"}
- 구글이 만든 Multi Thread 환경에서 최적화된 메모리 할당기
- malloc 으로 대표되는 할당자의 경우 멀티쓰레드의 최적화 및 단편화가 고려되지 않음
- Multi Thread 환경에서의 Memory Pooling, 단편화 관리에 최적화된 메모리 할당기


#### GOGC 옵션
가비지 수집 대상 백분율.  
이전 수집 후 남은 라이브 데이터에 대한 새로 할당된 데이터의 비율

- `GOGC=100` : default, 100% 비율
- `GOGC=off` : GC를 사용하지 않음 

---

### GC Trace 
`gctrace` 옵션을 통한 gc 로깅

##### 예제코드 
  
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

{% endraw %}
