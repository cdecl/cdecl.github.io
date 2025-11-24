---
title: "Linux vs Windows 쓰레딩 모델 비교"

toc: true
toc_sticky: true

categories:
  - dev

tags: 
  - linux
  - windows
  - thread
  - kernel
---

Linux와 Windows는 멀티쓰레드를 구현하고 처리하는 방식에서 **커널의 설계 철학**과 **API 구현**에 큰 차이가 있습니다.

## 1. 커널 모델 및 정의 (Thread Model)

### Linux (NPTL 기반)
*   Linux 커널에게 쓰레드는 단지 **"자원을 공유하는 프로세스(Lightweight Process, LWP)"**일 뿐입니다.
*   `clone()` 시스템 콜을 통해 생성되며, 커널은 쓰레드와 프로세스를 명확히 구분하지 않고 동일한 `task_struct` 구조체로 관리합니다.
*   사용자 레벨에서는 POSIX 표준인 **Pthread** 라이브러리를 사용하여 이를 제어합니다.

### Windows
*   Windows 커널은 **프로세스와 쓰레드를 명확하게 구분**합니다.
*   프로세스는 단순히 자원(메모리, 핸들 등)을 담는 컨테이너 역할을 하며, 실제 실행 단위는 쓰레드입니다.
*   커널 내부에 쓰레드를 위한 별도의 데이터 구조(Thread Object, TIB 등)가 존재하며, `CreateThread` 같은 명시적인 API를 통해 관리됩니다.

## 2. 스케줄링 (Scheduling)

### Linux
*   **CFS (Completely Fair Scheduler)**를 사용합니다. 쓰레드별로 공평한 CPU 시간을 분배하는 데 초점을 둡니다.
*   SMP(대칭형 다중 처리) 환경에서 코어 간 부하 분산을 효율적으로 처리하며, 특정 코어에 쓰레드를 오래 머물게 하여 캐시 효율을 높이는 경향이 있습니다.

### Windows
*   **우선순위 기반(Priority-based) 선점형 스케줄링**을 사용합니다.
*   쓰레드의 우선순위가 매우 중요하게 작용하며, 포그라운드 작업(사용자가 보고 있는 창)의 쓰레드에 더 긴 타임 슬라이스(Quantum)를 할당하여 **반응성(Responsiveness)**을 높이는 데 최적화되어 있습니다.

## 3. 동기화 및 성능 (Synchronization & Performance)

### Linux
*   동기화를 위해 **Futex (Fast Userspace Mutex)**를 사용하여, 경합이 없을 때는 커널 모드로 전환하지 않고 사용자 모드에서 빠르게 처리합니다. 이로 인해 문맥 교환(Context Switch) 오버헤드가 적은 편입니다.
*   쓰레드 생성과 소멸 속도가 매우 빠르며, 서버 사이드 및 대규모 병렬 처리에 유리합니다.

### Windows
*   동기화를 위해 **Critical Section**(사용자 모드), **Mutex/Event/Semaphore**(커널 모드) 등 다양한 객체를 제공합니다.
*   커널 객체를 사용하는 동기화는 무겁지만, 기능이 강력합니다.
*   일반적으로 Linux보다 쓰레드 생성 비용이 다소 높다고 평가받지만, GUI 애플리케이션 환경에서의 반응성은 매우 뛰어납니다.

## 요약

| 특징 | Linux | Windows |
| :--- | :--- | :--- |
| **정의** | 자원을 공유하는 경량 프로세스 (LWP) | 프로세스 내의 독립적인 실행 단위 (First-class citizen) |
| **구현** | `clone()` 시스템 콜 (Task) | 커널 쓰레드 객체 (Win32 API) |
| **스케줄링** | CFS (공정성 중심) | 우선순위 기반 (반응성 중심) |
| **주 용도** | 서버, 고성능 연산, 대규모 병렬 처리 | 데스크톱, GUI, 복합 응용 프로그램 |

이러한 차이로 인해, 서버 환경에서는 리눅스의 가벼운 쓰레드 모델이 선호되며, 데스크톱 환경에서는 윈도우의 반응성 중심 모델이 유리하게 작용합니다.
