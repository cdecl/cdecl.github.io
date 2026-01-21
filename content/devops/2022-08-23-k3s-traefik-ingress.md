---
title: K3s traefik ingress
tags:
  - k3s
  - kubernetes
  - ingress
  - traefik
---
K3s traefik ingress 사용 서비스 테스트 



## traefik ingress
- traefik : <https://cdecl.github.io/devops/traefik-proxy/>{:target="_blank"}
- traefik 을 활용한 ingress 구현체 : K3s 에서 번들로 제공 

### 서비스 테스트
- `traefik/whoami` 서비스 테스트 
- `type: NodePort`

```yaml
# whoami-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
spec:
  selector:
    matchLabels:
      app: whoami
  replicas: 2
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
      - name: whoami
        image: traefik/whoami
        imagePullPolicy: Always
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  type: NodePort
  selector:
    app: whoami
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

```sh
$ kubectl apply -f whoami-deploy.yaml

$ kubectl get pod -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   local-path-provisioner-7b7dc8d6f5-jnmt5   1/1     Running     0          11m
kube-system   coredns-b96499967-brb9f                   1/1     Running     0          11m
kube-system   helm-install-traefik-crd-hrfr5            0/1     Completed   0          11m
kube-system   metrics-server-668d979685-xj5jj           1/1     Running     0          11m
kube-system   helm-install-traefik-nr5jq                0/1     Completed   1          11m
kube-system   svclb-traefik-632fd507-mdwnl              2/2     Running     0          11m
kube-system   traefik-7cd4fcff68-47ms4                  1/1     Running     0          11m
default       whoami-6bbfdbb69c-phxts                   1/1     Running     0          102s
default       whoami-6bbfdbb69c-9rpxv                   1/1     Running     0          102s

$ kubectl get svc  -A
NAMESPACE     NAME             TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
default       kubernetes       ClusterIP      10.43.0.1       <none>          443/TCP                      26m
kube-system   kube-dns         ClusterIP      10.43.0.10      <none>          53/UDP,53/TCP,9153/TCP       26m
kube-system   metrics-server   ClusterIP      10.43.90.12     <none>          443/TCP                      26m
kube-system   traefik          LoadBalancer   10.43.147.171   192.168.136.5   80:32391/TCP,443:31718/TCP   25m
default       whoami           NodePort       10.43.116.252   <none>          80:30080/TCP                 16m

$ curl localhost:30080
Hostname: whoami-6bbfdbb69c-9rpxv
IP: 127.0.0.1
IP: ::1
IP: 10.42.0.10
IP: fe80::7c46:beff:fe57:f495
RemoteAddr: 10.42.0.1:43930
GET / HTTP/1.1
Host: localhost:30080
User-Agent: curl/7.81.0
Accept: */*
```

### Ingress 적용 

```yaml 
# ingress-rule.yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: main-ingress
spec:
  rules:
# - host: domain
  - http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: whoami
            port:
              number: 80
```

> Ingress 가 Proxy 역할로 X-Forwarded-For 등이 추가됨 

```sh
$ kubectl apply -f ingress-rule.yml
ingress.networking.k8s.io/main-ingress created

$ kubectl get ing -A
NAMESPACE   NAME           CLASS    HOSTS   ADDRESS         PORTS   AGE
default     main-ingress   <none>   *       192.168.136.5   80      9s

$ curl localhost
Hostname: whoami-6bbfdbb69c-9rpxv
IP: 127.0.0.1
IP: ::1
IP: 10.42.0.10
IP: fe80::7c46:beff:fe57:f495
RemoteAddr: 10.42.0.8:40046
GET / HTTP/1.1
Host: localhost
User-Agent: curl/7.81.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 10.42.0.7
X-Forwarded-Host: localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: traefik-7cd4fcff68-47ms4
X-Real-Ip: 10.42.0.7
```


