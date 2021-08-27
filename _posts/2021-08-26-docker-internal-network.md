---
title: Docker 내부 네트워크 상태 확인

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - docker
  - nsenter
  - netstat
  - inspect
---

{% raw %}
## netstat
- Host 머신에서 `netstat` 명령으로 docker container의 네트워크 상태가 확인 안됨  
  - 물론 container 내부에서 실행하면 되지만...
- docker container는 bridge 네트워크 기반으로 운영이 되므로 Host Network 에서는 노출이 안됨 

```sh
# docker 실행 
$ docker run -d -p 8081:80 --name=mvcapp cdecl/mvcapp
4fafaf418f84bf6541a1301b4422f825c58fa20b11d1190e87a3e23eea7a6825

# Host 에서는 publsh port (listen) 정보만 노출
$ netstat -ntl | grep 8081
tcp6       0      0 :::8081                 :::*                    LISTEN

# ip 현황
$ ip a
...
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:3a:4a:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.137.100/24 brd 192.168.137.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
4: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default <-- docker bridge
    link/ether 02:42:58:c6:1b:23 brd ff:ff:ff:ff:ff:ff
    inet 10.1.0.1/24 brd 10.1.0.255 scope global docker0
       valid_lft forever preferred_lft forever
...

# bridge network 
$ docker inspect -f '{{.NetworkSettings.Gateway}}' mvcapp
10.1.0.1

# 라우팅 정보
$ netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         gateway         0.0.0.0         UG        0 0          0 eth0
10.1.0.0        0.0.0.0         255.255.255.0   U         0 0          0 docker0  <-- docker bridge
10.42.0.0       0.0.0.0         255.255.255.0   U         0 0          0 cni0
192.168.137.0   0.0.0.0         255.255.255.0   U         0 0          0 eth0
```

## nsenter
- <https://github.com/jpetazzo/nsenter>{:target="_blank"}
- 격리되어 있는 **n**ame**s**pace **enter** 진입하는 명령 

> It is a small tool allowing to enter into namespaces. Technically, it can enter existing namespaces, or spawn a process into a new set of namespaces.   

```sh
$ nsenter --help

Usage:
 nsenter [options] <program> [<argument>...]

Run a program with namespaces of other processes.

Options:
 -t, --target <pid>     target process to get namespaces from
 ...
 -n, --net[=<file>]     enter network namespace
 ...
```

```sh
# docker pid 확인하기
$ docker inspect -f '{{.State.Pid}}' mvcapp
3900

# root 권한 필요 
# netstat tcp listen 
$ sudo nsenter -t $(docker inspect -f '{{.State.Pid}}' mvcapp) -n netstat -ntl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN

# ip 정보
$ sudo nsenter -t $(docker inspect -f '{{.State.Pid}}' mvcapp) -n ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
25: eth0@if26: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:0a:01:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.1.0.2/24 brd 10.1.0.255 scope global eth0
       valid_lft forever preferred_lft forever

# routing 
$ sudo nsenter -t $(docker inspect -f '{{.State.Pid}}' mvcapp) -n route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         gateway         0.0.0.0         UG    0      0        0 eth0
10.1.0.0        0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

### 테스트 

![](/images/nsenter.gif)

{% endraw %}