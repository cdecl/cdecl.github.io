---
title: ReaR (Relax & Recover) Basic
tags:
  - rear
  - os bacup
---
ReaR(Relax & Recover), Linux 재해 복구 도구



## ReaR
- <https://relax-and-recover.org/>{:target="_blank"}  
- Manual Page : <https://github.com/rear/rear/blob/master/doc/rear.8.adoc>{:target="_blank"}  
- OS의 부팅 가능한 복구 시스템 구성, 시스템 파일 백업 및 복구 지원 

---

### Simple Example
- NFS 백업 서버 구성
- ReaR 백업 및 복구 테스트 
- `centos7`, `Hyper-v` 환경 테스트 
- <https://access.redhat.com/solutions/2115051>{:target="_blank"} 

#### Backup용 NFS 서버 구성 
- 백업서버 NFS 구성 
  
```sh
# nfs-utils 설치 
$ sudo yum install nfs-utils

# 디렉토리 생성 
$ sudo mkdir -p /storage/rear

# nfs 서버 설정 
$ cat /etc/exports
/storage         *(rw,sync,no_root_squash)

# nfs-server start 
# sudo systemctl enable nfs-server
$ sudo systemctl start nfs-server
```

#### 대상 서버 구성 
- RaaR 설치 및 구성 

```sh
# nfs clients 
$ sudo yum install nfs-utils

# ReaR 설치 
sudo yum install nfs-utils

# 필요에 따라 아래 모듈 설치
# rear -d -v mkbackup 시 해당 모듈이 없다고 나오면
# WARNING: /usr/lib/grub/x86_64-efi/moddep.lst not found, grub2-mkimage will likely fail. 
# Please install the grub2-efi-x64-modules package to fix this.
$ sudo yum install grub2-efi-x64-modules
```

##### RaaR 설정 
- <https://github.com/rear/rear/blob/master/doc/user-guide/03-configuration.adoc>{:target="_blank"} 
- `/etc/rear/local.conf`
  - `OUTPUT` : Rescue media, BOOT용 이미지
    - `ISO` : ISO BOOT 이미지 생성 
  - `BACKUP`, `BACKUP_URL` : Backup/Restore strategy, 시스템파일 및 백업 데이터 종류 및 위치 지정 
    - `NETFS` : Use Relax-and-Recover internal backup with tar or rsync (or similar)
    - `BACKUP_URL` 경로 및 HostName 폴더에 생성 
    - `BACKUP_PROG_EXCLUDE` : 백업 제외 경로 지정 

```conf
# /etc/rear/local.conf

OUTPUT=ISO
OUTPUT_URL=nfs://192.168.137.100/storage/rear
BACKUP=NETFS
BACKUP_URL=nfs://192.168.137.100/storage/rear

# BACKUP_TYPE=incremental
# FULLBACKUPDAY=Sun
# BACKUP_PROG_EXCLUDE=('/syslogs/logs/*' '/var/log/*')
```

---

#### Backup 실행
- `mkbackup` : create rescue media and backup system
- `mkbackuponly` : backup system without creating rescue media
- `mkrescue` : create rescue media only

```sh
## verbose mode
# -d : debug mode 의 경우 /tmp 밑에 파일을 지우지 않음
$ sudo rear -v mkbackup
```

- Backup 데이터 확인 

```sh
# Backup 서버
$ hostname -I
192.168.137.100

# hostname 디렉토리별로 백업 
$ tree /storage
/storage
└── rear
    ├── node1
    │   ├── README
    │   ├── VERSION
    │   ├── backup.log
    │   ├── backup.tar.gz
    │   ├── rear-node1.iso
    │   └── rear-node1.log
    └── node2
        ├── README
        ├── VERSION
        ├── backup.log
        ├── backup.tar.gz
        ├── rear-node2.iso
        └── rear-node2.log
```

---

#### 복구 실행

> 백업된 rescue media (iso)로 부팅을 한 후, 복구 모드로 실행 

![](/images/2022-02-08-09-47-08.png)

> login 이름을 지정 후, RESCUE 프롬프트 상에서 복구 명령 실행 

![](/images/2022-02-08-09-59-07.png)

```sh
# 복구 명령, 백업된 정보를 기반으로 복구 
# 수동 복구의 경우 별도 인터렉티브한 환경에서 수행 
$ rear -v recover 
```

---

### 기타 
- FAQ : <http://relax-and-recover.org/documentation/faq>{:target="_blank"}
- Manual Recover : <https://github.com/rear/rear/issues/847>{:target="_blank"}

#### 백업시 복원 IP 세팅
- 백업전에 `/etc/rear/mappings/ip_addresses` 파일 생성

```sh
$ cat /etc/rear/mappings/ip_addresses
eth0 192.268.1.100/24
```

#### 복원시 IP 변경 
- 복구 이미지 부팅시, 커널 파라미터로 아래와 같이 지정 

> 부팅시 아래 메뉴의 e (edit)를 눌러 편집

![](/images/2022-02-09-13-34-20.png)

> 파라미터에 아래 내용 추가

```sh
ip=192.168.100.2 nm=255.255.255.0 netdev=eth0 gw=192.168.100.1
```

![](/images/2022-02-09-13-44-25.png)




