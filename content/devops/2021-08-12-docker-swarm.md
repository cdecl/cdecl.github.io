---
title: Docker Swarm 101
tags:
  - docker
  - swarm
---
https://docs.docker.com/engine/swarm/

### Docker Swarm Node 

#### Manager Node 초기화 
https://docs.docker.com/engine/reference/commandline/swarm_init/

- 초기화 Initialize a swarm
	- `docker swarm init`
	
```sh 
$ docker swarm init
Swarm initialized: current node (bvz81updecsj6wjz393c09vti) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx \
    172.17.0.2:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

- Initialize a swarm with advertised address 
	- `docker swarm init --advertise-addr <ip|interface>[:port]`

```sh
$ docker swarm init --advertise-addr 192.168.99.121
Swarm initialized: current node (bvz81updecsj6wjz393c09vti) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx \
    172.17.0.2:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

#### 노드 추가 Join Node
Join a swarm as a node and/or manager  
https://docs.docker.com/engine/reference/commandline/swarm_join/

```sh
$ docker swarm join --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-7p73s1dx5in4tatdymyhg9hu2 192.168.99.121:2377
This node joined a swarm as a manager.

$ docker node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
dkp8vy1dq1kxleu9g4u78tlag *  manager2  Ready   Active        Reachable
dvfxp4zseq4s0rih1selh0d20    manager1  Ready   Active        Leader
```

#### Docker swarm join-token
Worker or Manager join-token 확인  
https://docs.docker.com/engine/reference/commandline/swarm_join-token/

```sh
$ docker swarm join-token worker
To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx \
    172.17.0.2:2377

$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-7p73s1dx5in4tatdymyhg9hu2 \
    172.17.0.2:2377
  
```

---

### Docker Swarm 노드관리 
https://docs.docker.com/engine/swarm/manage-nodes/

- docker node promote : 관리자노드로 승격
	- `docker node promote NODE [NODE...]`
	- Promote one or more nodes to manager in the swarm

```sh
$ docker node promote node-3 node-2

Node node-3 promoted to a manager in the swarm.
Node node-2 promoted to a manager in the swarm.
```

- `docker node demote` : 워크노드로 강등  
	- `docker node demote NODE [NODE...]`
	- Demote one or more nodes from manager in the swarm

- `docker node rm` : 노드 삭제
	- `docker node rm [OPTIONS] NODE [NODE...]`

- `docker node update` : 노드 속성 변경 
	- `docker node update [OPTIONS] NODE`
	- `docker node update --availability "active"|"pause"|"drain" NODE`
		- active : 활성
 
```sh
Options:
      --availability string   Availability of the node ("active"|"pause"|"drain")
      --label-add list        Add or update a node label (key=value)
      --label-rm list         Remove a node label if exists
      --role string           Role of the node ("worker"|"manager")

# active : 활성 / pause : 일시중지
# drain : Manager Node에서 Worcker Node 사용하지 못하게 빼냄(drain)
$ docker node update --availability "active"|"pause"|"drain" NODE
```

### Deploy services to a swarm
https://docs.docker.com/engine/swarm/services/
https://docs.docker.com/engine/reference/commandline/service_create/  

#### Create a service
- `docker service create [OPTIONS] IMAGE [COMMAND] [ARG...]`

```sh
$ docker service create --name mvcapp cdecl/mvcapp:0.1
tv39xae6cwxosh5e5ydaznfwu
overall progress: 1 out of 1 tasks 
1/1: running   [==================================================>] 
verify: Service converged 

$ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                   PORTS
t7199mqnj0r9        mvcapp              replicated          1/1                 cdecl/mvcapp:0.1        *:80->80/tcp
```

#### Create a service with 4 replica tasks

```sh
$ docker service create --name mvcapp --replicas=4 cdecl/mvcapp:0.1
7vu2ihz8gqxager66ernevyyb
overall progress: 4 out of 4 tasks 
1/4: running   [==================================================>] 
2/4: running   [==================================================>] 
3/4: running   [==================================================>] 
4/4: running   [==================================================>] 
verify: Service converged 

$ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                   PORTS
7vu2ihz8gqxa        mvcapp              replicated          4/4                 cdecl/mvcapp:0.1   
```

### Docker Update Service 
https://docs.docker.com/engine/reference/commandline/service_update/ 

- `docker service update [OPTIONS] SERVICE`

```sh
# replicas
$ docker service update --replicas=2 mvcapp
\mvcapp
overall progress: 2 out of 2 tasks 
1/2: running   [==================================================>] 
2/2: running   [==================================================>] 
verify: Service converged 

# rollback
$ docker service update --rollback mvcapp
mvcapp
rollback: manually requested rollback 
overall progress: rolling back up
1/4: running   [>                                                  ] 
2/4: new       [============================================>      ] 
3/4: running   [>                                                  ] 
4/4: new       [============================================>      ] 
service rolled back: rollback completed

# update deploy
$ docker service update --image=cdecl/mvcapp:0.2  mvcapp
mvcapp
overall progress: 4 out of 4 tasks 
1/4: running   [==================================================>] 
2/4: running   [==================================================>] 
3/4: running   [==================================================>] 
4/4: running   [==================================================>]
```

