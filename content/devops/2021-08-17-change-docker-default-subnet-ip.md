---
title: Docker 운영 Tip (daemon.json)
tags:
  - docker
---
## Docker default bridge 네트워크 대역 변경 

> 내부 사설 IP와의 출동 등의 이슈 

### daemon.json 
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

#### 반영 전

```sh
$ ip a
...
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:82:58:25:33 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
...
```

#### 반영 후 

```sh
$ ip a
...
1519: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:c0:d9:e2:56 brd ff:ff:ff:ff:ff:ff
    inet 10.1.0.1/24 brd 10.1.0.255 scope global docker0
       valid_lft forever preferred_lft forever
...
```

## Data root directory 경로 변경
- 기본 경로 : `/var/lib/docker`

### daemon.json 
- `/etc/docker/daemon.json`

```json
{
  "data-root": "/docker",
  "default-address-pools": [
    {
      "base": "10.1.0.0/16",
      "size": 24
    }
  ]
}
```

```
$ sudo systemctl restart docker

$ sudo ls -l /docker
합계 0
drwx--x--x 4 root root 120  8월 18 11:51 buildkit
drwx------ 2 root root   6  8월 18 11:51 containers
drwx------ 3 root root  22  8월 18 11:51 image
drwxr-x--- 3 root root  19  8월 18 11:51 network
drwx------ 4 root root 112  8월 18 11:51 overlay2
drwx------ 4 root root  32  8월 18 11:51 plugins
drwx------ 2 root root   6  8월 18 11:51 runtimes
drwx------ 2 root root   6  8월 18 11:51 swarm
drwx------ 2 root root   6  8월 18 11:51 tmp
drwx------ 2 root root   6  8월 18 11:51 trust
drwx------ 2 root root  50  8월 18 11:51 volumes
```


## Docker log 용량 관리 
- <https://docs.docker.com/config/containers/logging/json-file/>{:target="_blank"}
- <data-root>/containers/

### daemon.json 
- `/etc/docker/daemon.json`

```json
{
  "data-root": "/docker",
  "log-opts": {
    "max-size": "100m"
  },
  "default-address-pools": [
    {
      "base": "10.1.0.0/16",
      "size": 24
    }
  ]
}
```