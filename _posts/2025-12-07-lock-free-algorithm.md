---
title: 락프리(Lock-Free) 알고리즘 이해하기

toc: true
toc_sticky: true

categories:
  - dev

tags:
  - lock-free
  - spinlock
  - mutex
  - c++
  - performance
  - multithreading
---

멀티스레드 프로그래밍 환경에서 동시성 제어는 성능과 직결되는 매우 중요한 문제입니다. 이번 글에서는 전통적인 락 기반 동시성 제어의 한계를 극복하기 위해 등장한 **락프리(Lock-Free) 알고리즘**에 대해 알아보고, 그 개념과 구현 방법, 그리고 장단점을 살펴보겠습니다.

## 락프리 알고리즘이란?

**락프리(Lock-Free)**는 이름 그대로 **"자물쇠(Lock) 없이"** 여러 스레드가 동시에 데이터를 처리하는 기술입니다.

쉽게 비유하자면 **회전문**과 같습니다.
- **락(Lock)**: 한 번에 한 명만 들어갈 수 있는 화장실입니다. 누군가 안에 있으면 밖에서 열쇠를 받을 때까지 마냥 기다려야 합니다.
- **락프리(Lock-Free)**: 여러 사람이 동시에 지나갈 수 있는 회전문입니다. 가끔 문이 꽉 차서 한 바퀴 더 돌아야 할 수도 있지만, 멈추지 않고 계속 움직일 수 있습니다.

락프리는 시스템 전체가 멈추는 일(Deadlock) 없이, 누군가는 반드시 작업을 완료한다는 것을 보장합니다.

## 락프리 알고리즘을 사용하지 않는 일반적인 방법 (Lock-Based)

락프리 기법을 사용하지 않는 경우, 우리는 데이터 경쟁(Data Race)을 막기 위해 **상호 배제(Mutual Exclusion)** 메커니즘을 사용합니다.

- **Mutex (뮤텍스)**: 공유 자원에 접근하기 전 락을 획득하고, 사용 후 반납합니다.
- **Semaphore (세마포어)**: 정해진 수의 스레드만 자원에 접근하도록 제한합니다.

이 방식은 직관적이고 구현이 쉽지만 다음과 같은 문제점이 발생할 수 있습니다.

1.  **Deadlock (교착 상태)**: 두 스레드가 서로의 자원을 기다리며 영원히 멈추는 현상.
2.  **Priority Inversion (우선순위 역전)**: 낮은 우선순위의 스레드가 락을 잡고 있어 높은 우선순위의 스레드가 실행되지 못하는 현상.
3.  **Convoying (컨보이 현상)**: 락을 쥐고 있는 스레드가 스케줄링에서 배제되면, 해당 락을 기다리는 모든 스레드가 대기하게 되어 성능이 저하되는 현상.

## 락프리 알고리즘 구현 내용: 컨셉 및 의사코드

락프리 알고리즘의 핵심은 **원자적 연산(Atomic Operation)**, 특히 **CAS (Compare-And-Swap)** 연산입니다.

### 핵심 컨셉: CAS (Compare-And-Swap)

CAS는 **"이 자리가 비어있으면 제가 앉을게요, 아니면 다시 올게요"**라고 말하는 것과 같습니다.

하드웨어 수준에서 단숨에(원자적으로) 처리되는 이 명령어는 다음과 같은 로직을 가집니다.

1.  **확인**: "지금 내 데이터가 A가 맞니?"
2.  **변경**: "맞다면 B로 바꿔줘."
3.  **실패**: "아니라고? (누가 벌써 바꿨네) 그럼 다시 시도할게."

```cpp
// 가상의 CAS 함수 설명
bool CAS(int* addr, int expected, int new_value) {
    // *하드웨어적인 배제(Exclusion) 발생*
    // CPU는 이 순간 메모리 버스를 잠그거나(Bus Lock), 
    // 캐시 라인을 독점(Cache Lock/MESI 프로토콜)하여 
    // 다른 코어가 접근하지 못하게 막습니다.
    if (*addr == expected) { 
        *addr = new_value;   
        return true;        
    }
    return false;           
}
```

> **Q. `compare_exchange`도 내부적으로 락을 쓰나요?**  
> 네, 맞습니다. 하지만 **적용 범위와 매커니즘**이 다릅니다.
>
> | 구분 | CAS (Atomic Op) | 스핀락 (Spinlock) | 뮤텍스 (Mutex) |
> | :--- | :--- | :--- | :--- |
> | **성격** | **하드웨어 락** (미시적) | **소프트웨어 락** (거시적) | **OS 관리 락** (거시적) |
> | **잠금 대상** | 단일 메모리 주소 (변수 하나) | 코드 영역 (Critical Section) | 코드 영역 (Critical Section) |
> | **동작 방식** | Bus Lock / Cache Lock | CAS 루프 (Busy Waiting) | Sleep / Wakeup (Context Switching) |
> | **비용** | 극도로 낮음 | 낮음 (경합 없을 시) ~ 높음 (경합 시) | 높음 (시스템 콜 + 스케줄링) |
>
> 즉, CAS는 **"데이터 갱신 그 자체"**를 위한 미시적인 배제이고, 스핀락/뮤텍스는 이를 이용해 **"코드 영역"**을 보호하는 거시적인 배제입니다.

락프리 알고리즘은 보통 다음과 같은 패턴을 따릅니다.
1. 변경하려는 값을 읽어옵니다 (`expected`).
2. 변경할 새로운 값을 계산합니다 (`new_value`).
3. CAS를 시도합니다. 만약 실패했다면(다른 스레드가 먼저 값을 바꿨다면), 1번부터 다시 시도합니다.

### 구현 예시: 락프리 스택 (C++ 스타일)

복잡한 템플릿 대신, 간단한 **정수형(int) 스택**으로 예시를 들어보겠습니다.

```cpp
#include <atomic>

struct Node {
    int data;
    Node* next;
};

class LockFreeIntStack {
    std::atomic<Node*> head; // 스택의 맨 위(Top)를 가리키는 포인터

public:
    void push(int value) {
        Node* new_node = new Node{value, nullptr};
        
        // 1. 새 노드의 next가 현재 head를 가리키도록 설정
        new_node->next = head.load();

        // 2. CAS: head가 여전히 new_node->next와 일치하면 new_node로 교체
        // 실패 시: compare_exchange_weak가 new_node->next를 최신 head 값으로 자동 갱신 -> 재시도
        while (!head.compare_exchange_weak(new_node->next, new_node)) {
             // (Empty Body: 실패 시 new_node->next가 자동으로 갱신됨)
        }
        
        // [상황: 성공]
        // Head -> [내노드 30] -> [40] -> [20] -> ...
    }
};
```

### 구현 예시: 스핀락 (Spinlock) (C++ std::atomic<int> 활용)

락프리 자료구조는 아니지만, 락프리 구현에 쓰이는 원자적 연산을 이해하기 좋은 예제로 스핀락이 있습니다. `std::atomic<int>`를 사용하여 락을 획득할 때까지 계속 루프를 도는(Spinning) 방식입니다.

```cpp
class SpinLock {
    std::atomic<int> flag = {0}; // 0: Unlocked, 1: Locked

public:
    void lock() {
        int expected = 0;
        // CAS: 0(Open)이면 1(Locked)로 변경 시도
        // 실패 시 expected가 1로 바뀌므로, 0으로 다시 초기화 후 재시도
        while (!flag.compare_exchange_weak(expected, 1)) {
            expected = 0;
        }
    }

    void unlock() {
        flag.store(0); // 락 반납
    }
};
```


## 알고리즘별 비교: 락프리 vs 일반 락(Wait Lock) vs 스핀락(Spinlock)

락을 사용하는 방식도 대기 흐름에 따라 **Wait Lock**과 **Spinlock**으로 나뉩니다. 이들과 **락프리**를 한눈에 비교해 봅시다.

| 구분 | 일반 락 (Wait Lock, Mutex) | 스핀락 (Spinlock) | 락프리 (Lock-Free) |
| :--- | :--- | :--- | :--- |
| **대기 방식** | **Sleep** (대기 상태로 전환, CPU 양보) | **Spin** (루프 돌며 계속 확인, CPU 점유) | **Non-Blocking** (계속 작업 시도, 실패 시 즉시 재시도) |
| **컨텍스트 스위칭** | 락 대기 시 발생 (비용 큼) | 발생하지 않음 (단, 타임슬라이스 소진 시 발생) | 발생하지 않음 |
| **구현 난이도** | 쉬움 (OS/라이브러리 제공) | 중간 (직접 구현 시 주의 필요) | **매우 어려움** (ABA, 메모리 해제 등) |
| **CPU 사용량** | 대기 중에는 거의 없음 | 대기 중에도 계속 소모 (Busy Waiting) | 경합 시 높음 (계속 CAS 시도) |
| **적합한 상황** | 락 보유 시간이 길거나, 경합이 심할 때 | 락 보유 시간이 매우 짧고, 컨텍스트 스위칭 비용을 아끼고 싶을 때 | 매우 정밀한 성능이 필요하고, 데드락을 원천 차단하고 싶을 때 |

## 베스트 케이스와 최악의 상황 (Performance Analysis)

### 1. 일반 락 (Wait Lock / Mutex)
- **Best Case**: 경합이 없을 때. 뮤텍스 획득/해제가 빠르지만, 시스템 콜 오버헤드가 약간 있을 수 있습니다.
- **Worst Case**: **경합이 많을 때**. 스레드가 계속 잠들었다 깨어나는(Context Switching) 비용이 급증하여 성능이 급격히 저하됩니다. 또한 **Deadlock** 발생 위험이 있습니다.

### 2. 스핀락 (Spinlock)
- **Best Case**: **잠깐 기다려서 바로 락을 얻을 때**. 컨텍스트 스위칭 없이 즉시 자원을 쓰므로 대기 비용이 사실상 0에 가깝습니다.
- **Worst Case**: **락 소유자가 오랫동안 락을 놓지 않을 때**. 기다리는 스레드는 의미 없이 무한 루프를 돌며 **CPU 100%**를 소모합니다. (전기세 낭비의 주범)

### 3. 락프리 (Lock-Free)
- **Best Case**: 경합이 적을 때. CAS 연산 한 번으로 끝나며, 어떤 락 매커니즘보다 빠릅니다.
- **Worst Case**: **경합이 극심할 때**. 수많은 스레드가 동시에 CAS를 시도하고 실패하기를 반복합니다. 스핀락과 비슷하게 CPU를 많이 쓰지만, 적어도 시스템 전체가 멈추지 않고(Deadlock Free) 누군가는 계속 진행한다는 점에서 스핀락보다는 낫습니다.

---

락프리 알고리즘은 고성능 시스템에 필수적일 수 있지만, 그 복잡도로 인해 신중하게 도입해야 합니다. 무조건적인 락프리 전환보다는 프로파일링을 통해 병목 구간을 확인하고 적용하는 것이 바람직합니다.
