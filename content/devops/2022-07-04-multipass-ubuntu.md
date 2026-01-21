---
title: Multipass, Ubuntu VM 설정
tags:
  - multipass
  - ubuntu
  - vm
  - hyper-v
  - qemu
  - lxd
---
Canonical 재단에서 지원하는 단일 명령으로 Ubuntu VM 구성 할 수 있는 도구 



## Multipass
- <https://multipass.run/>{:target="_blank"}
- 최소한의 오버헤드를 위한 각 플랫폼 지원 
  - Windows : Hyper-V
  - macOS : QEMU, HyperKit
  - Linux : LXD

### Multipass install 
- <https://multipass.run/install>{:target="_blank"}
- 플랫폼 별 패키지 설치 방법

```sh
# windows 
$ choco install multipass 

# macOS
$ brew install multipass 
```

### Multipass 주요 명령 및 VM Instance 생성 

#### 주요 명령어 
- `launch` : Ubuntu instance 생성 및 시작
- `start`, `stop`, `restart` : 시작 중지
- `delete` : Ubuntu instance 삭제
- `purge` : 삭제된 이미지 영구 삭제
- `shell` : Instance 내부 shell 로 접속 
- `list` : 생성된 Instance 확인 
- `info` : Instance 정보 확인  
  
```sh
$ multipass --help
...

Available commands:
  alias         Create an alias
  aliases       List available aliases
  authenticate  Authenticate client
  delete        Delete instances
  exec          Run a command on an instance
  find          Display available images to create instances from
  get           Get a configuration setting
  help          Display help about a command
  info          Display information about instances
  launch        Create and start an Ubuntu instance
  list          List all available instances
  mount         Mount a local directory in the instance
  networks      List available network interfaces
  purge         Purge all deleted instances permanently
  recover       Recover deleted instances
  restart       Restart instances
  set           Set a configuration setting
  shell         Open a shell on a running instance
  start         Start instances
  stop          Stop running instances
  suspend       Suspend running instances
  transfer      Transfer files between the host and instances
  umount        Unmount a directory from an instance
  unalias       Remove an alias
  version       Show version details
```

#### Ubuntu VM Instance 생성 : 기본 생성

```sh
# node1 이름의 instance 생성 
$ multipass launch -n node01
Launched: node01

# 기본 lts 이미지로 생성 :  Ubuntu 20.04 LTS
$ multipass list
Name                    State             IPv4             Image
node01                  Running           192.168.196.207  Ubuntu 20.04 LTS

# instace 정보 
$ multipass info node01
Name:           node01
State:          Running
IPv4:           192.168.196.207
Release:        Ubuntu 20.04.4 LTS
Image hash:     75a04c7eed58 (Ubuntu 20.04 LTS)
Load:           0.38 0.15 0.05
Disk usage:     1.4G out of 4.7G
Memory usage:   162.4M out of 912.5M
Mounts:         --
```

> 기본 설정으로 Instance 생성시, Disk 등의 리소스가 부족 할 수 있음


#### Ubuntu VM Instance 생성 : 리소스 설정 및 이미지 선택

```sh
# Instace 삭제 
$ multipass delete node01
$ multipass purge

# Ubuntu 이미지 확인 
$ multipass find
Image                       Aliases           Version          Description
core                        core16            20200818         Ubuntu Core 16
core18                                        20211124         Ubuntu Core 18
18.04                       bionic            20220615         Ubuntu 18.04 LTS
20.04                       focal,lts         20220615         Ubuntu 20.04 LTS
21.10                       impish            20220616         Ubuntu 21.10
22.04                       jammy             20220622         Ubuntu 22.04 LTS
appliance:adguard-home                        20200812         Ubuntu AdGuard Home Appliance
appliance:mosquitto                           20200812         Ubuntu Mosquitto Appliance
appliance:nextcloud                           20200812         Ubuntu Nextcloud Appliance
appliance:openhab                             20200812         Ubuntu openHAB Home Appliance
appliance:plexmediaserver                     20200812         Ubuntu Plex Media Server Appliance
anbox-cloud-appliance                         latest           Anbox Cloud Appliance
charm-dev                                     latest           A development and testing environment for charmers
docker                                        latest           A Docker environment with Portainer and related tools
minikube                                      latest           minikube is local Kubernetes


# Instace 생성 : cpu 2, disk 40G, mem 2G,  Ubuntu 22.04 LTS
$ multipass launch -c 2 -d 40G -m 2G -n node01 22.04
Launched: node01

$ multipass info node01
Name:           node01
State:          Running
IPv4:           192.168.197.165
Release:        Ubuntu 22.04 LTS
Image hash:     d90ea6784789 (Ubuntu 22.04 LTS)
Load:           0.01 0.07 0.04
Disk usage:     1.4G out of 38.6G
Memory usage:   217.1M out of 1.9G
Mounts:         --


# shell 접속 
$ multipass shell node01
...
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
```


##### Ubuntu instance 내부

```sh
ubuntu@node01:~$ cat /etc/*-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04 LTS"
PRETTY_NAME="Ubuntu 22.04 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
```


