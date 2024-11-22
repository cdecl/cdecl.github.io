---
title: Python asyncio
last_modified_at: 2024-11-20

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - python
  - asyncio
  - async
  - await
  - coroutine
---

`asyncio`는 `async`/`await` 구문을 사용하여 동시성 코드를 작성하는 라이브러리입니다. 특히 I/O 작업이 많은 애플리케이션에서 높은 성능을 발휘합니다.

## asyncio : asynchronous io 처리 
- <https://docs.python.org/ko/3/library/asyncio.html>{:target="_blank"}
- `Threading` 동시성 제어는 `GIL (Global interpreter lock)` 제약에 의해 느리고, 복잡도는 그대로 가지고 있음
  - GIL은 Python 인터프리터가 한 번에 하나의 스레드만 실행할 수 있도록 제한하는 메커니즘
  - 멀티스레드를 사용해도 CPU 연산의 실제 병렬 처리가 어려움
- IO 병목에 의한 동시성을 관리하기 위한 도구로서 `Coroutine`을 통한 관리
  - 네트워크 요청, 파일 읽기/쓰기 등 I/O 작업에서 효율적
  - 코루틴은 스레드보다 가벼워서 수천 개의 동시 작업도 효율적으로 처리 가능

### 일반적인 `Coroutine` 코드 
- `Coroutine`으로 실행 되기는 하나, 비동기로 실행 되지는 않음
- `async def`로 정의된 함수는 코루틴 함수가 됨
- `await`는 다른 코루틴의 실행이 완료될 때까지 대기
- `asyncio.sleep()`은 I/O 작업을 시뮬레이션하는 용도로 자주 사용됨
  
```python
import asyncio
from datetime import datetime

def time_log(step):
    print(datetime.now().strftime('%H:%M:%S'), step)
    
async def async_sleep():
    await asyncio.sleep(2)
    time_log('async_sleep')

async def async_execute():
    time_log('start')

    await async_sleep()
    await async_sleep()

    time_log('end')

def main():
    asyncio.run(async_execute())
    
if __name__ == '__main__':
    main()
```

```sh
[Running] set PYTHONIOENCODING=utf8 && python -u tempCodeRunnerFile.python
11:39:00 start
11:39:02 async_sleep
11:39:04 async_sleep
11:39:04 end
```

실행 결과를 보면 start -> 2초 대기 -> async_sleep -> 2초 대기 -> async_sleep -> end 순서로 순차 실행됨을 알 수 있습니다.

### `asyncio` 비동기 동시 실행  
- `asyncio.create_task`: 코루틴을 태스크로 변환하여 이벤트 루프의 실행 큐에 예약
  - 태스크로 변환되면 곧바로 실행이 시작됨
  - 여러 태스크가 동시에 실행될 수 있음
- `await`: 코루틴, 태스크, Future 객체의 완료를 대기
  - await 없이 create_task만 하면 태스크가 완료되기 전에 프로그램이 종료될 수 있음
- `asyncio.run`: Python 3.7 이상에서 사용 가능한 고수준 API
  - 새로운 이벤트 루프를 생성하고 코루틴을 실행
  - 프로그램 시작점에서 한 번만 호출해야 함

```python
import asyncio
from datetime import datetime

def time_log(step):
    print(datetime.now().strftime('%H:%M:%S'), step)
    
async def async_sleep():
    await asyncio.sleep(2)
    time_log('async_sleep')

async def async_execute():
    time_log('start')

    # Event loop에 의한 실행 예약 
    asleep1 = asyncio.create_task(async_sleep())
    asleep2 = asyncio.create_task(async_sleep())

    # 실행 완료 대기 
    await asleep1
    await asleep2

    time_log('end')

def main():
    # asyncio event loop 생성 및 실행 객체 관리 
    asyncio.run(async_execute())

    # asyncio.run 대신 저수준 함수 사용 예 : run_until_complete
    # loop = asyncio.get_event_loop()
    # loop.run_until_complete(async_execute())
    
if __name__ == '__main__':
    main()
```   

```sh
[Running] set PYTHONIOENCODING=utf8 && python -u tempCodeRunnerFile.python
11:42:33 start
11:42:35 async_sleep
11:42:35 async_sleep
11:42:35 end
```

이 버전은 두 async_sleep이 동시에 실행되어 총 2초만에 완료됩니다.

#### `asyncio` 동시에 여러개 `Task` 예약 
- `asyncio.gather`: 여러 awaitable 객체를 동시에 실행
  - 모든 태스크가 완료될 때까지 대기
  - 태스크들의 실행 순서는 보장되지 않음
  - CPU 바운드가 아닌 I/O 작업의 경우 실제로 병렬 처리 효과를 얻을 수 있음

```python
import asyncio
from datetime import datetime

def time_log(step):
    print(datetime.now().strftime('%H:%M:%S'), step)
    
async def async_sleep():
    await asyncio.sleep(2)
    time_log('async_sleep')

async def async_execute():
    time_log('start')

    tasks = []
    for i in range(5):
        t = asyncio.create_task(async_sleep())
        tasks.append(t)

    # task 의 배열, 모두 실행 완료대기 
    await asyncio.gather(*tasks)

    time_log('end')

def main():
    asyncio.run(async_execute())
    
if __name__ == '__main__':
    main()
```

```sh
[Running] set PYTHONIOENCODING=utf8 && python -u tempCodeRunnerFile.python
12:15:01 start
12:15:03 async_sleep
12:15:03 async_sleep
12:15:03 async_sleep
12:15:03 async_sleep
12:15:03 async_sleep
12:15:03 end
```

5개의 태스크가 동시에 실행되어 여전히 2초 정도만 소요됩니다.

#### `asyncio` 동시에 여러개 `Task` 예약 (리턴값 처리)
- gather는 각 태스크의 반환값을 리스트로 수집
- 태스크의 실행 순서와 관계없이 전달한 순서대로 결과가 저장됨
- 어떤 태스크에서 예외가 발생하면 gather도 예외를 발생시킴

```python
import asyncio
from datetime import datetime

def time_log(step):
    print(datetime.now().strftime('%H:%M:%S'), step)
    
async def async_sleep():
    await asyncio.sleep(2)
    return datetime.now().strftime('%H:%M:%S') + ' async_sleep'

async def async_execute():
    time_log('start')

    tasks = []
    for i in range(5):
        t = asyncio.create_task(async_sleep())
        tasks.append(t)

    # Future 및 Task 객체 대기 및 리턴값 수집
    fut = await asyncio.gather(*tasks)
    [ print(f) for f in fut ]

    time_log('end')

def main():
    asyncio.run(async_execute())
    
if __name__ == '__main__':
    main()
```

```sh
[Running] set PYTHONIOENCODING=utf8 && python -u tempCodeRunnerFile.python
12:24:41 start
12:24:43 async_sleep
12:24:43 async_sleep
12:24:43 async_sleep
12:24:43 async_sleep
12:24:43 async_sleep
12:24:43 end
```

---

### awaitable 하지 않은 blocking 함수 `asyncio` 실행 
- 일반적인 동기 함수(time.sleep 등)는 이벤트 루프를 블록하므로 직접 await 불가
- `run_in_executor`: 동기 함수를 별도의 스레드 풀에서 실행
  - 기본 실행기(executor=None)는 ThreadPoolExecutor 사용
  - CPU 바운드 작업의 경우 ProcessPoolExecutor를 사용하는 것이 유리
  - Future 객체를 반환하므로 await로 완료 대기 가능

```python
import asyncio
from asyncio import futures
import time
from datetime import datetime

def time_log(step):
    print(datetime.now().strftime('%H:%M:%S'), step)
    
def sync_sleep(name):
    time.sleep(2) # blocking
    return datetime.now().strftime('%H:%M:%S') + ' ' + name

async def async_execute():
    time_log('start')

    loop = asyncio.get_running_loop()

    futures = []
    for i in range(5):
        # executor가 `None` 이면 기본 실행기
        # run_in_executor 저수준 함수를 통해 동기 함수 등록
        t = loop.run_in_executor(None, sync_sleep, str(i))
        futures.append(t)

    # Future 객체 대기 
    fut = await asyncio.gather(*futures)
    [ print(f) for f in fut ]

    time_log('end')

def main():
    asyncio.run(async_execute())
    
if __name__ == '__main__':
    main()
```

```sh
[Running] set PYTHONIOENCODING=utf8 && python -u tempCodeRunnerFile.python
12:34:14 start
12:34:16 0
12:34:16 1
12:34:16 2
12:34:16 3
12:34:16 4
12:34:16 end
```

주요 추가 고려사항:
- 에러 처리를 위해 try/except 사용을 권장
- 태스크 취소 처리도 고려해야 할 수 있음
- 데이터베이스 등의 리소스는 비동기 라이브러리(aiohttp, asyncpg 등) 사용 권장
- 디버깅이 어려울 수 있으므로 로깅을 적극 활용

{% endraw %}