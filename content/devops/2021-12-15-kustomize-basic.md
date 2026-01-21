---
title: Kustomize Basic
tags:
  - kubernetes
  - kustomize
  - k8s
---
kubernetes manifest 리소스 관리 도구 



## Kustomize
- <https://kubernetes.io/ko/docs/tasks/manage-kubernetes-objects/kustomization/>{:target="_blank"}  
- kubernetes manifest (yaml) 파일을 Template 형태로 관리 Patch(Merge) 및 배포 해주는 툴 
- kubernetes 1.14 이후, kubectl 명령어로 kustomization 지원 

---

### Simple Example

```sh
$ tree .
.
├── deployment.yaml
├── kustomization.yaml
└── version.yaml
```

#### kustomization.yaml
- Manifest 파일의 기본 구조 및 리소스, 패치 파일을 기술하는 파일 
  
```yaml
resources:
- deployment.yaml
patchesStrategicMerge:
- version.yaml
```

- `resources` : 리소스 파일 리스트 
  - `resources` 이외에 `configMapGenerator`, `secretGenerator` 기능도 있음
  - <https://kubernetes.io/ko/docs/tasks/manage-kubernetes-objects/kustomization/#kustomize-%EA%B8%B0%EB%8A%A5-%EB%A6%AC%EC%8A%A4%ED%8A%B8>{:target="_blank"} 
- `patchesStrategicMerge` : resources의 Patch 파일

> Patch : yaml file merge

##### `resources:`

- deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mvcapp
spec:
  selector:
    matchLabels:
      app: mvcapp
  replicas: 2
  template:
    metadata:
      labels:
        app: mvcapp
    spec:
      containers:
      - name: mvcapp
        image: cdecl/mvcapp:0.4
        imagePullPolicy: Always
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: mvcapp
spec:
  type: NodePort
  #type: LoadBalancer
  #loadBalancerIP: 192.168.0.10
  selector:
    app: mvcapp
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30010
```

##### `patchesStrategicMerge:`

- version.yaml 
  - `spec.replicas` 와 `spec.template.spec.containers.image` 를 변경 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mvcapp
spec:
  replicas: 4
  template:
    spec:
      containers:
      - name: mvcapp
        image: cdecl/mvcapp:0.5
```


#### 실행 테스트 

> $ kubectl kustomize "kustomization_directory"

- 리소스파일 deployment.yaml 이 version.yaml 값으로 patch (merge) 됨
  - `spec.replicas` 
  - `spec.template.spec.containers.image`

```sh
$ kubectl kustomize .
apiVersion: v1
kind: Service
metadata:
  name: mvcapp
spec:
  ports:
  - nodePort: 30010
    port: 80
    targetPort: 80
  selector:
    app: mvcapp
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mvcapp
spec:
  replicas: 4
  selector:
    matchLabels:
      app: mvcapp
  template:
    metadata:
      labels:
        app: mvcapp
    spec:
      containers:
      - image: cdecl/mvcapp:0.5
        imagePullPolicy: Always
        name: mvcapp
        ports:
        - containerPort: 80
```

---

### Base와 Overlay
- Kustomize 를 관리하기 위해 디렉토리 구조 권고
- base : 기본이 되는 Kustomize 환경
- overlays : Patch 되는 환경으로 구분 
  - e.g. `dev`, `stage`, `prod`

```sh
$ tree
.
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── version.yaml
└── overlays
    ├── dev
    │   ├── kustomization.yaml
    │   └── version.yaml
    └── prod
        ├── kustomization.yaml
        └── version.yaml
```

##### overlays/dev/kustomization.yaml
- namePrefix: name 앞에 prefix 
- bases : kustomization 기본(base) 환경 경로
- patchesStrategicMerge : base 적용 후, 추가 Patch

```yaml
namePrefix: dev-
bases:
- ../../base
patchesStrategicMerge:
- version.yaml
```

---

### 설치 테스트
manifest 파일의 `kubectl -f` 옵션 대신 `kubectl -k` 옵션 사용 

> $ kubectl apply -k "kustomization_directory"


##### Install (apply)

```sh
$ kubectl apply -k overlays/dev
```

##### get/describe

```sh
$ kubectl get -k overlays/dev
$ kubectl describe -k overlays/dev
```

##### diff
- 클러스터 상태와 manifest 파일 비교 

```sh
$ kubectl diff -k overlays/dev
...
   creationTimestamp: "2021-12-15T08:08:11Z"
-  generation: 1
+  generation: 2
   managedFields:
   - apiVersion: apps/v1
     fieldsType: FieldsV1
@@ -93,7 +93,7 @@
   uid: 4610c9b8-501d-4b27-8a77-ab4fbf3c73e8
 spec:
   progressDeadlineSeconds: 600
-  replicas: 2
+  replicas: 4
   revisionHistoryLimit: 10
   selector:
     matchLabels:
```

##### delete

```sh
kubectl delete -k overlays/dev
```



