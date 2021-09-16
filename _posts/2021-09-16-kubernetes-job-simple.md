---
title: Kubernetes Job 실행 

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - kubernetes
  - k8s
  - job
  - jq
---

{% raw %}

Kubernetes Job 을 활용한 동시작업

## Kubernetes Job
- <https://kubernetes.io/ko/docs/concepts/workloads/controllers/job/>{:target="_blank"}

> Pod 를 생성하고, Pod를 통해 성공적으로 종료할떄까지의 일련의 작업실행   

### Job : 단일 Job 테스트 
`alpine` pod 실행 및 `ip` 명령어로 IP 확인

- `command` : 명령어 (배열)
- `restartPolicy` : `Always`, `OnFailure`, `Never` (default `Always`)
  - 배치 작업이므로 재시작 하면 안됨 : `Never`
- `backoffLimit` : 실패시 재시작 횟수 (defalut: 6)

```yaml
# time.yml
apiVersion: batch/v1
kind: Job
metadata:
 name: ip
spec:
  template:
    metadata:
      name: ip
    spec:
      containers:
      - name: ip
        image: alpine
        command: ["ip", "a"]
      restartPolicy: Never
  backoffLimit: 0
```

```sh
$ kubectl apply -f ip.yml
job.batch/ip created

$ kubectl get pod
NAME       READY   STATUS      RESTARTS   AGE
ip-5x8qm   0/1     Completed   0          14s
```

#### 로그 확인

```sh
$ kubectl logs ip-5x8qm
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if58: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue state UP
    link/ether 9a:f9:d3:9f:32:eb brd ff:ff:ff:ff:ff:ff
    inet 10.42.0.37/24 brd 10.42.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::98f9:d3ff:fe9f:32eb/64 scope link
       valid_lft forever preferred_lft forever
```

---

### Job : Parallel 동시작업
- wrk 를 활용 http 퍼포먼스 테스트 : <https://github.com/wg/wrk>{:target="_blank"}
- Image : [cdecl/asb](https://hub.docker.com/r/cdecl/asb/){:target="_blank"}

#### Parallel 실행 1
- `parallelism` : 동시 실행 Pod 개수 (default: 1)
- `completions` : Pod 완료로 판단하는 개수 (default: `parallelism` )

```yaml
apiVersion: batch/v1
kind: Job
metadata:
 name: wrk
spec:
  completions: 4
  parallelism: 4
  template:
    metadata:
      name: wrk
    spec:
      containers:
      - name: wrk
        image: cdecl/asb
        command: ["wrk", "-d5", "http://httpbin.org/get"]
      restartPolicy: Never
  backoffLimit: 0
```

#### 실행, 로그 확인
```sh
$ kubectl apply -f wrk.yml
```

![](/images/job-4-4.gif)

```sh
$ kubectl logs wrk-6fkm4
Running 5s test @ http://httpbin.org/get
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    34.45ms   63.03ms 408.58ms   92.36%
    Req/Sec   108.80     29.09   191.00     78.89%
  1003 requests in 5.01s, 557.33KB read
Requests/sec:    200.39
Transfer/sec:    111.35KB
```

#### Parallel 실행 2
- `completions` > `parallelism` : `parallelism` 개수만큼 동시 실행되고, `completions` 개수만큼 Pod 생성

```yaml
apiVersion: batch/v1
kind: Job
metadata:
 name: wrk
spec:
  completions: 4
  parallelism: 2
...
```

![](/images/job-4-2.gif)

---

### Job 의 전체 Pod 로그 확인 
- kubectl 을 통해서 json output을 다룰수 있으나, `jq` 만큼 유연하지는 않음

```sh
# Pod 이름 확인
$ kubectl get pod --selector=job-name=wrk -o=json | jq -r '.items[].metadata.name'
wrk-g4kxr
wrk-44vlk
wrk-g7jtv
wrk-lx9rf

# 각 Pod 의 로그확인
$ kubectl get pod --selector=job-name=wrk -o=json | jq -r '.items[].metadata.name' | xargs -i kubectl logs {}
Running 5s test @ http://httpbin.org/get
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     0.00us    0.00us   0.00us    -nan%
    Req/Sec     0.00      0.00     0.00      -nan%
  0 requests in 5.01s, 0.00B read
Requests/sec:      0.00
Transfer/sec:       0.00B
Running 5s test @ http://httpbin.org/get
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    26.63ms   81.87ms 644.70ms   91.58%
    Req/Sec   272.61    155.98   540.00     60.71%
  826 requests in 5.01s, 519.76KB read
  Socket errors: connect 0, read 0, write 0, timeout 10
Requests/sec:    164.99
Transfer/sec:    103.82KB
Running 5s test @ http://httpbin.org/get
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    19.15ms   52.63ms 314.47ms   92.81%
    Req/Sec   249.73     88.39   500.00     69.47%
  2407 requests in 5.01s, 1.57MB read
Requests/sec:    480.89
Transfer/sec:    322.16KB
Running 5s test @ http://httpbin.org/get
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    11.73ms   37.52ms 304.20ms   96.02%
    Req/Sec   215.97    105.45   535.00     67.71%
  2074 requests in 5.10s, 1.36MB read
Requests/sec:    406.69
Transfer/sec:    272.45KB

```


{% endraw %}