---
title: Helm chart 생성, 배포

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - helm
  - kubernetes
  - k8s
  - docker
  - k3s
---

`Kubernetes` 패키지 매니저 도구인 `helm`을 통해 `chart` 생성 및 `Kubernetes` 배포

{% raw %}

> K3S 환경에서 테스트 

## Helm
- <https://helm.sh/>{:target="_blank"}
- Kubernetes 배포를 위한 패키지 매니저 툴 (e.g `yum`, `choco`)
- `chart` 라는 `yaml` 파일 기반의 템플릿 파일을 통해 패키지화 및 `Kubernetes` 설치 관리
  - `Deployment`, `Service`, `Ingress` 등 `Kubernetes` 서비스의 manifest 생성 및 설치 
- Helm Repository 를 통해 패키지 등록 및 다른 패키지 설치 가능 

--- 

### Helm Install 
- 바이너리 직접 설치 및 설치 Script 활용 
- `Homebrew`, `Chocolatey` 등의 패키지로도 설치 가능 

##### 바이너리 다운로드 
- https://github.com/helm/helm/releases

```sh
$ curl -LO https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
$ tar -zxvf helm-v3.7.1-linux-amd64.tar.gz

$ tree linux-amd64
linux-amd64
├── LICENSE
├── README.md
└── helm

$ sudo cp linux-amd64/helm /usr/local/bin/
```

##### 설치 Script 활용 

```sh
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

---

### Creating Your Own Charts
- `kubernetes` 설치를 위한 `chart` 생성 및 세팅 
- <https://helm.sh/docs/helm/helm_create/>{:target="_blank"}

```sh
# chart 생성
$ helm create mvcapp
Creating mvcapp
```

##### Chart directory 구조 
- `Chart.yaml` : Chart 버전, 이미지버전, 설명등을 기술하는 파일
- `values.yaml` : manifest template 파일 기반, 기준 값을 세팅하는 파일
- `templates/` : kubernetes manifest template 파일
- `charts/`  : chart 의존성 파일

```sh
$ tree mvcapp
mvcapp
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

##### `Chart.yaml` 수정
- `version` : Chart 버전 
- `appVersion` : Deploy 되는 image 버전 
  
```yaml
apiVersion: v2
name: mvcapp
description: .net core test mvc application
# ... 생략
type: application
# ... 생략
version: 0.1.0
# ... 생략
appVersion: "0.6"  # appVersion: "1.16.0"
```

##### `values.yaml` 수정
- `replicaCount` : Pod 의 replica 개수, 2개로 수정
- `image.repository` : docker image 이름, `cdecl/mvcapp` 로 수정
- `service.type` : `On-Premise`에서 테스트 목적, `NodePort`로 수정 
- `service.nodePort` : `nodePort`를 적용하기 위해 신규 추가 

```yaml
# Default values for mvcapp.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 2

image:
  repository: cdecl/mvcapp
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

# ... 생략

service:
  type: NodePort   # ClusterIP
  port: 80
  nodePort: 30010

ingress:

# ... 생략

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

# ... 생략
```

##### `templates/service.yaml` 수정
- `nodePort` 를 적용하기 위해 template 수정 
- `spec.ports.nodePort: {{ .Values.service.nodePort }}` 추가

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mvcapp.fullname" . }}
  labels:
    {{- include "mvcapp.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
      nodePort: {{ .Values.service.nodePort }}
  selector:
    {{- include "mvcapp.selectorLabels" . | nindent 4 }}
```

##### `helm lint` : chart 파일 검사  
- <https://helm.sh/docs/helm/helm_lint/>{:target="_blank"}

```sh
$ helm lint mvcapp
==> Linting mvcapp
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

##### `helm template` : kubernetes manifest 생성  
- <https://helm.sh/docs/helm/helm_template/>{:target="_blank"}
- `values.yaml` 에 세팅한 기준으로 manifest 생성 

```sh
$ helm template mvcapp
---
# Source: mvcapp/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: RELEASE-NAME-mvcapp
  labels:
    helm.sh/chart: mvcapp-0.1.0
    app.kubernetes.io/name: mvcapp
    app.kubernetes.io/instance: RELEASE-NAME
    app.kubernetes.io/version: "0.6"
    app.kubernetes.io/managed-by: Helm
---
# Source: mvcapp/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: RELEASE-NAME-mvcapp
  labels:
    helm.sh/chart: mvcapp-0.1.0
    app.kubernetes.io/name: mvcapp
    app.kubernetes.io/instance: RELEASE-NAME
    app.kubernetes.io/version: "0.6"
    app.kubernetes.io/managed-by: Helm
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: mvcapp
    app.kubernetes.io/instance: RELEASE-NAME
---
# Source: mvcapp/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: RELEASE-NAME-mvcapp
  labels:
    helm.sh/chart: mvcapp-0.1.0
    app.kubernetes.io/name: mvcapp
    app.kubernetes.io/instance: RELEASE-NAME
    app.kubernetes.io/version: "0.6"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: mvcapp
      app.kubernetes.io/instance: RELEASE-NAME
  template:
    metadata:
      labels:
        app.kubernetes.io/name: mvcapp
        app.kubernetes.io/instance: RELEASE-NAME
    spec:
      serviceAccountName: RELEASE-NAME-mvcapp
      securityContext:
        {}
      containers:
        - name: mvcapp
          securityContext:
            {}
          image: "cdecl/mvcapp:0.6"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {}
---
# Source: mvcapp/templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "RELEASE-NAME-mvcapp-test-connection"
  labels:
    helm.sh/chart: mvcapp-0.1.0
    app.kubernetes.io/name: mvcapp
    app.kubernetes.io/instance: RELEASE-NAME
    app.kubernetes.io/version: "0.6"
    app.kubernetes.io/managed-by: Helm
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['RELEASE-NAME-mvcapp:80']
  restartPolicy: Never
```

##### `helm install` : chart 활용 kubernetes service install
- <https://helm.sh/docs/helm/helm_install/>{:target="_blank"}
- install : `helm install [NAME] [CHART] [flags]`

```sh
# 설치하지는 않고 테스트 
$ helm install mvcapp-svc mvcapp --dry-run

# 로컬 Chart 를 통한 설치 
$ helm install mvcapp-svc mvcapp
NAME: mvcapp-svc
LAST DEPLOYED: Thu Nov  4 13:29:38 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services mvcapp-svc)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP        78d
mvcapp-svc   NodePort    10.43.202.254   <none>        80:31503/TCP   29s

$ kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
mvcapp-svc-78ff4d97f9-hd9rf   1/1     Running   0          37s
mvcapp-svc-78ff4d97f9-x4984   1/1     Running   0          37s
```

> KS3 `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml` 세팅

##### `helm upgrade`, `helm uninstall`
- upgrade : `helm upgrade [NAME] [CHART] [flags]`
- uninstall : `helm uninstall [NAME]`
  
```sh
$ helm upgrade mvcapp-svc mvcapp
Release "mvcapp-svc" has been upgraded. Happy Helming!
NAME: mvcapp-svc
LAST DEPLOYED: Thu Nov  4 13:44:54 2021
NAMESPACE: default
STATUS: deployed
REVISION: 5
...

# helm list
$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART          APP VERSION
mvcapp-svc      default         5               2021-11-04 13:44:54.170028077 +0900 KST deployed        mvcapp-0.1.0   0.6

# helm history
$ helm history mvcapp-svc
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Thu Nov  4 13:42:12 2021        superseded      mvcapp-0.1.0    0.6             Install complete
2               Thu Nov  4 13:42:58 2021        superseded      mvcapp-0.1.0    0.5             Upgrade complete
3               Thu Nov  4 13:43:40 2021        superseded      mvcapp-0.1.0    0.6             Rollback to 1
4               Thu Nov  4 13:44:32 2021        superseded      mvcapp-0.1.0    0.5             Upgrade complete
5               Thu Nov  4 13:44:54 2021        deployed        mvcapp-0.1.0    0.6             Upgrade complete

# helm uninstall
$ helm uninstall mvcapp-svc
release "mvcapp-svc" uninstalled
```

---

#### Chart package, repository 

##### `helm package` 
- <https://helm.sh/docs/helm/helm_package/>{:target="_blank"}
- chart 디렉토리를 압축하여 패키지화 

```sh
$ helm package mvcapp
Successfully packaged chart and saved it to: /home/cdecl/temp/helm/mvcapp-0.1.0.tgz
```

##### Local repository directory 
- <https://helm.sh/docs/helm/helm_repo_index/>{:target="_blank"}
- `helm repo index` : 패키지된 차트의 Index 파일 생성

```sh
# repository local directory
$ mkdir chart-repo

# index 파일 생성 
$ helm repo index chart-repo

$ cat chart-repo/index.yaml
apiVersion: v1
entries: {}
generated: "2021-11-04T14:00:37.388050909+09:00"

# chart package 파일 넣기
$ mv mvcapp-0.1.0.tgz chart-repo

# index 파일 갱신
$ helm repo index chart-repo

$ cat chart-repo/index.yaml
apiVersion: v1
entries:
  mvcapp:
  - apiVersion: v2
    appVersion: "0.6"
    created: "2021-11-04T14:02:46.688756427+09:00"
    description: A Helm chart for Kubernetes
    digest: ff28f1c2434531c801bf68106bd5b314e4ff90adac5619e6856d9765052afb83
    name: mvcapp
    type: application
    urls:
    - mvcapp-0.1.0.tgz
    version: 0.1.0
generated: "2021-11-04T14:02:46.688277626+09:00"
```

---

#### Github chart repository 활용 
- github repository 생성 및 local repository directory `push`
- github repository page 세팅 

![](/images/2021-11-04-14-30-32.png)

##### Repository 등록 및 설치 
- github page url 로 등록 
  
```sh
# add
$ helm repo add github https://cdecl.github.io/chart-repo/
"github" has been added to your repositories

# list 
$ helm repo list
NAME    URL
stable  https://charts.helm.sh/stable
github  https://cdecl.github.io/chart-repo/

# search
$ helm search repo mvcapp
NAME            CHART VERSION   APP VERSION     DESCRIPTION
github/mvcapp   0.1.0           0.6             A Helm chart for Kubernetes
```


{% endraw %}
