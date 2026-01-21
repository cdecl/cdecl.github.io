---
title: K3S Overview
tags:
  - k3s
  - k8s
  - Kubernetes
  - rancher
---
Lightweight Kubernetes : The certified Kubernetes distribution built for IoT & Edge computing

### 특징 
- <https://k3s.io/>{:target="_blank"}
- Kubernetes의 경량화 버전으로 아래와 같은 특징 
  - 기본 설치만으로 바로 배포 테스트 가능
  - Overlay Netowrk(Flannel), Load balancer, Ingress(Traefik), CoreDNS 등이 기본 설치 됨
    - <https://rancher.com/docs/k3s/latest/en/networking/>{:target="_blank"}
  - etcd 대신 sqlite 운영
    - [High Availability with an External DB](https://rancher.com/docs/k3s/latest/en/installation/ha/)
    - [High Availability with Embedded DB (Experimental)](https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/)
  - Master node schedulable
    - uncordon 제외 가능
    - Worker node 필요 없음 (필요시 추가 가능)

#### 사용 목적
- Edge Computing
- 개발 테스트 및 스테이징 서버 구성 
- 기타 어플리케이션 테스트 용 

### Master 설치 
- 설치 `curl -sfL https://get.k3s.io | sh -` 실행으로 끝 
  - `systemd 관리 `
- kubectl 설치 및 심볼릭 링크 설정 해줌   
  - 이미 kubectl 가 설치 되어 있는 경우는 심볼릭 링크 실패 
  
```sh
# alias 필요시 아래 참고 
$ alias kubectl='sudo k3s kubectl' 
```

```sh
# Install
$ curl -sfL https://get.k3s.io | sh -

# master node
$ kubectl get node
NAME      STATUS   ROLES                  AGE   VERSION
centos1   Ready    control-plane,master   37s   v1.21.3+k3s1

$ kubectl get pod -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   local-path-provisioner-5ff76fc89d-wh9cg   1/1     Running     0          2m35s
kube-system   coredns-7448499f4d-2d7pb                  1/1     Running     0          2m35s
kube-system   metrics-server-86cbb8457f-x9l6n           1/1     Running     0          2m35s
kube-system   helm-install-traefik-crd-w27q7            0/1     Completed   0          2m35s
kube-system   helm-install-traefik-2zllj                0/1     Completed   1          2m35s
kube-system   svclb-traefik-55qfd                       2/2     Running     0          113s
kube-system   traefik-97b44b794-smzl9                   1/1     Running     0          114s
```

### K8S 서비스 테스트  
- 서비스 타입 : `NodePort`
- <https://kubernetes.github.io/ingress-nginx/deploy/baremetal/>{:target="_blank"}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mvcapp
spec:
  selector:
    matchLabels:
      app: mvcapp
  replicas: 2 # --replicas=2 옵션과 동일 
  template: 
    metadata:
      labels:
        app: mvcapp
    spec:
      containers:
      - name: mvcapp
        image: cdecl/mvcapp:0.6
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: mvcapp
spec:
  type: NodePort
  selector:
    app: mvcapp
  ports:
  - port: 80
    targetPort: 80

```

```sh
$ kubectl apply -f mvcapp-deploy-service.yaml
deployment.apps/mvcapp created
service/mvcapp created

$ kubectl get pod -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   local-path-provisioner-5ff76fc89d-wh9cg   1/1     Running     0          9m29s
kube-system   coredns-7448499f4d-2d7pb                  1/1     Running     0          9m29s
kube-system   metrics-server-86cbb8457f-x9l6n           1/1     Running     0          9m29s
kube-system   helm-install-traefik-crd-w27q7            0/1     Completed   0          9m29s
kube-system   helm-install-traefik-2zllj                0/1     Completed   1          9m29s
kube-system   svclb-traefik-55qfd                       2/2     Running     0          8m47s
kube-system   traefik-97b44b794-smzl9                   1/1     Running     0          8m48s
default       mvcapp-79874d888c-6htvq                   1/1     Running     0          62s
default       mvcapp-79874d888c-clslc                   1/1     Running     0          62s

$ kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.43.0.1      <none>        443/TCP        10m
mvcapp       NodePort    10.43.36.139   <none>        80:32105/TCP   106s

# Nodeport IP
$ curl 10.43.36.139:80
    * Project           : Mvcapp
    * Version           : 0.5 / net5.0
    * Hostname          : mvcapp-79874d888c-6htvq
    * RemoteAddr        : 10.42.0.1
    * X-Forwarded-For   :
    * Request Count     : 1
    * User-Agent        : curl/7.29.0

$ curl localhost:32105
    * Project           : Mvcapp
    * Version           : 0.5 / net5.0
    * Hostname          : mvcapp-79874d888c-clslc
    * RemoteAddr        : 10.42.0.1
    * X-Forwarded-For   :
    * Request Count     : 1
    * User-Agent        : curl/7.29.0
```


### Agent 추가 
- Master Node만으로도 테스트 가능하나 Scale 테스트시 Agent(Worker Node) 추가 가능 
- 환경변수 세팅 : 필요시 참고 

```sh
$ sudo cat /var/lib/rancher/k3s/server/node-token	 > ~/.node-token
$ K3S_TOKEN=$(< ~/.node-token)
$ HOST_IP=$(ip a | sed -rn 's/.*inet ([0-9\.]+).*eth0/\1/p')
```

#### Agent 등록 : 원격실행 OR Agent 머신에서 실행
- HostIP, Token 정보 필요 (위 환경변수 세팅 참고)

```sh
# Agent 머신에서 실행 
$ curl -sfL https://get.k3s.io | K3S_URL=https://$HOST_IP:6443 K3S_TOKEN=$K3S_TOKEN sh -

# Agent 추가 다른방법 
$ ansible node01 -m shell -a "curl -sfL https://get.k3s.io | sh -s - agent --server https://$HOST_IP:6443 --token $K3S_TOKEN" -v
```

---

### K3S 삭제 

```sh
ls /usr/local/bin/k3s-* | xargs -n1 sh -
```
