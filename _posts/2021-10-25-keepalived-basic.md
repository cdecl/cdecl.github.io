---
title: Keepalived Basic

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - keepalived
  - vrrp
  - loadbalancing
  - ha
---

{% raw %}

Loadbalancing & High-Availability 를 위한 Keepalived 설정 및 간단 테스트 

## Keepalived 
- VRRP 를 활용 가상IP (VIP) 기반 서버 다중화 도구 

> VRRP 는 여러 대의 라우터를 그룹으로 묶어 하나의 가상 IP 어드레스를 부여, 마스터로 지정된 라우터 장애시 VRRP 그룹 내의 백업 라우터가 마스터로 자동 전환되는 프로토콜입니다.

### Install
```sh
# install
$ sudo yum install keepalived 

# service start
$ sudo systemctl start keepalived

$ sudo systemctl status keepalived
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; disabled; vendor preset: disabled)
   Active: active (running) since 화 2021-10-26 11:37:04 KST; 4s ago
  Process: 18356 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 18357 (keepalived)
    Tasks: 3
   Memory: 1.6M
   CGroup: /system.slice/keepalived.service
           ├─18357 /usr/sbin/keepalived -D
           ├─18358 /usr/sbin/keepalived -D
           └─18359 /usr/sbin/keepalived -D

10월 26 11:37:05 node1 Keepalived_vrrp[18359]: VRRP_Instance(VI_1) forcing a new MASTER ...on
10월 26 11:37:06 node1 Keepalived_vrrp[18359]: VRRP_Instance(VI_1) Transition to MASTER STATE
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: VRRP_Instance(VI_1) Entering MASTER STATE
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: VRRP_Instance(VI_1) setting protocol VIPs.
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: Sending gratuitous ARP on eth0 for 192.16...00
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: VRRP_Instance(VI_1) Sending/queueing grat...00
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: Sending gratuitous ARP on eth0 for 192.16...00
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: Sending gratuitous ARP on eth0 for 192.16...00
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: Sending gratuitous ARP on eth0 for 192.16...00
10월 26 11:37:07 node1 Keepalived_vrrp[18359]: Sending gratuitous ARP on eth0 for 192.16...00
Hint: Some lines were ellipsized, use -l to show in full.
```

### 기본 설정 
- <https://www.redhat.com/sysadmin/keepalived-basics>{:target="_blank"}
- <https://www.redhat.com/sysadmin/advanced-keepalived>{:target="_blank"}

####  `/etc/keepalived/keepalived.conf`
- `vrrp_instance` : 인터페이스에서 실행되는 프로토콜의 개별 인스턴스 정의
- `state` : 인스턴스에서 시작해야 하는 초기 상태
- `interface` : 네트워크 인터페이스 
- `virtual_router_id` : : 네트워크 가상 ID
- `priority` : 우선 순위
- `advert_int` : `VRRP` 패킷 송신 간격 (sec)
- `authentication` : 서로 서버간, 인증 계정 정보 
- `virtual_ipaddress` : 가상 IP `vip`
  
##### MASTER 설정 : `192.168.137.201`
```conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 210
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.137.200
    }
}
```

##### BACKUP 설정 : `192.168.137.202`
```conf
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 200
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.137.200
    }
}
```

> `MASTER` 노드에 우선순위 `priority 210` 를 높게 줌 

---

#### 서비스 확인 : IP 할당 확인
- `eth0` 인터페이스에 2개의 IP가 보임 
  - `Host` : `inet 192.168.137.201/24`  
  - `VIP` : `inet 192.168.137.200/32`

```sh
$ ip a
...
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:3a:4a:02 brd ff:ff:ff:ff:ff:ff
    inet 192.168.137.201/24 brd 192.168.137.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.137.200/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a576:e68c:a11c:f43/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

#### 서비스 확인 : VRRP Packet Capture
- `virtual_router_id(vrid) 51` 에 대해서 `192.168.137.201` 서버로 할당 `ARP Request`

```sh 
$ sudo tcpdump -n vrrp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
12:08:02.810202 IP 192.168.137.201 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 210, authtype simple, intvl 1s, length 20
12:08:03.811340 IP 192.168.137.201 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 210, authtype simple, intvl 1s, length 20
...
```

#### Failover Test
- `192.168.137.201` 서버에서 `keepalived` 서비스 중지 → `192.168.137.202` 로 `Failover`

```sh 
# 192.168.137.201 MASTER 에서 keepalived 서비스 중지 
$ sudo systemctl stop keepalived

# 192.168.137.202 서버로 변경 
$ sudo tcpdump -n vrrp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
12:08:49.068284 IP 192.168.137.202 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 200, authtype simple, intvl 1s, length 20
12:08:50.068723 IP 192.168.137.202 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 200, authtype simple, intvl 1s, length 20


# 192.168.137.201 MASTER 에서 keepalived 서비스 다시 시작 
$ sudo systemctl start keepalived

# 다시 MASTER priority 가 높으로 쪽으로 돌아옴
$ sudo tcpdump -n vrrp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
12:09:31.084794 IP 192.168.137.201 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 210, authtype simple, intvl 1s, length 20
12:09:32.085300 IP 192.168.137.201 > 224.0.0.18: VRRPv2, Advertisement, vrid 51, prio 210, authtype simple, intvl 1s, length 20
```

---

### 서비스 상태를 확인하기 위한 방법 
- `Failover` 조건으로서 호스트의 프로세스나 파일, 스크립트 등으로 판단
  
##### Tracking processes : 프로세스 명으로 추적
  
```conf
vrrp_track_process track_apache {
      process httpd
      weight 10
}

vrrp_instance VI_1 {
      ...
      track_process {
         track_apache
      }
}
```

##### Tracking files : 파일 존재 여부로 추적 
  
```conf
vrrp_track_file track_app_file {
      file /var/run/my_app/vrrp_track_file
}

vrrp_instance VI_1 {
    ...
    track_file {
         track_app_file weight 1
    }
}
```

##### Track interface : 여러개의 Network I/F가 있는 경우 상태로 추적 
  
```conf
vrrp_instance VI_1 {
    ...
    track_interface {
        ens9 weight 5
    }
}
```

##### Track script : Script 실해 결과로 추적
- `interval` : 스크립트 실행 간격 `sec`
- `timeout` : Timeout 시간 `sec`
- `rise` : 호스트가 "정상"으로 간주되기 위해 스크립트가 성공적으로 반환되어야 하는 횟수
- `fall` : 호스트가 "비정상"으로 간주되기 위해 스크립트가 성공적으로 반환되지 않는 횟수

```sh
$ /etc/keepalived/check.sh 
$ echo $?
0
```

```conf
vrrp_script keepalived_check {
      script "/etc/keepalived/check.sh"
      interval 5
      timeout 5
      fall 3
}

vrrp_instance VI_1 {
    ...
    track_script {
        keepalived_check
    }
}
```

---

### VRRP 마스터가 실패하면 마스터가 되지 않도록 방지
- <https://serverfault.com/questions/44122/prevent-vrrp-master-from-becoming-master-once-it-has-failed>{:target="_blank"}
- `nopreempt` 플래그 추가

```conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 210
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.137.200
    }
}
```

{% endraw %}
