---
title: Python asyncio

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

{% raw %}

`asyncio`는 `async`/`await` 구문을 사용하여 동시성 코드를 작성하는 라이브러리 

## asyncio : asynchronous io 처리 
- <https://docs.python.org/ko/3/library/asyncio.html>{:target="_blank"}
- `Threading` 동시성 제어는 `GIL (Global interpreter lock)` 제약에 의해 느리고, 복잡도는 그대로 가지고 있음
- IO 병목에 의한 동시성을 관리하기 위한 도구로서  `Coroutine` 을 통한 관리 

--- 

### 일반적인  `Coroutine` 코드 
-  `Coroutine`으로 실행 되기는 하나, 비동기로 실행 되지는 않음
  
```py
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

---

### `asyncio` 비동기 동시 실행  
- `asyncio.create_task` :  `Coroutine`을 `Task`로 감싸고 Event loop에 의한 실행 예약. `Task` 객체 반환.
- `await` :  `Coroutine`, `Task`, `Future` 객체를 대기
- `asyncio.run` : 새로운 Asyncio Event loop 를 만들고  `Coroutine` 실행 및 관리 `python 3.7 >=` 
  - `python 3.7` 아래 버전은 저수준 함수로 대체 
  - `loop = asyncio.get_event_loop()` / `loop.run_until_complete(async_execute())`

```py
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

#### `asyncio` 동시에 여러개 `Task` 예약 
- `asyncio.gather` : `awaitable` 객체를 동시에 실행 (대기)

```py
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

#### `asyncio` 동시에 여러개 `Task` 예약 (리턴값 처리)

```py
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
- `awaitable` 하지 않은 일반 함수의 경우 실행 방법 
- `run_in_executor` : 지정된 실행기에서 함수를 호출 하도록 배치, `Future` 반환
  - executor가 `None` 이면 기본 실행기

```py
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

{% endraw %}
