---
title: Change the Docker default subnet IP address

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - docker
---

Docker default bridge 네트워크 대역 변경 

> 내부 사설 IP와의 출동 등의 이슈 

## daemon.json 
- `/etc/docker/daemon.json`

```json
{
  "default-address-pools": [
    {
      "base": "10.1.0.0/16",
      "size": 24
    }
  ]
}
```

- Docker restart 

```
$ sudo systemctl restart docker
```

### 반영 전

```sh
$ ip a
...
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:82:58:25:33 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
...
```

### 반영 후 

```sh
$ ip a
...
1519: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:c0:d9:e2:56 brd ff:ff:ff:ff:ff:ff
    inet 10.1.0.1/24 brd 10.1.0.255 scope global docker0
       valid_lft forever preferred_lft forever
...
```
