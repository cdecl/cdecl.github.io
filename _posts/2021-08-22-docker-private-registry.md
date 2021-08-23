---
title: Docker Private Registry

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - docker
  - registry
---

Docker Private Registry 구성 

## Registry 실행 
- docker-compose.yml

```yaml
version: '3'

services:
  registry:
    image: registry
    container_name: registry
    restart: always
    ports:
      - 5000:5000
    environment:
      REGISTRY_HTTP_ADDR: 0.0.0.0:5000
    volumes:
      - registry:/var/lib/registry
      - ./config.yml:/etc/docker/registry/config.yml

volumes:
  registry:
```

```sh
# 실행
$ docker-compose up -d

$ curl -s http://localhost:5000/v2/_catalog
{"repositories":[]}
```

- SSL 적용 

```yaml
version: '3'

services:
  registry:
    image: registry
    container_name: private_registry
    restart: always
    ports:
      - 5000:5000
    environment:
      REGISTRY_HTTP_ADDR: 0.0.0.0:5000
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain-pem.pem
      REGISTRY_HTTP_TLS_KEY: /certs/domain-pem.key
    volumes:
      - registry:/var/lib/registry
      - ./config.yml:/etc/docker/registry/config.yml
      - ./certs:/certs

volumes:
  registry:
```

### Image Push 
- 테스트용 이미지 태깅 

```sh
# get alpine images
$ docker pull alpine
$ docker pull alpine:3.13
# tagging
$ docker tag alpine localhost:5000/cdecl/alpine:latest
$ docker tag alpine:3.13 localhost:5000/cdecl/alpine:3.13

$ docker images
REPOSITORY                    TAG       IMAGE ID       CREATED        SIZE
alpine                        latest    ae607a46d002   2 weeks ago    5.33MB
localhost:5000/cdecl/alpine   latest    ae607a46d002   2 weeks ago    5.33MB
alpine                        3.13      81efc9693413   2 months ago   5.35MB
localhost:5000/cdecl/alpine   3.13      81efc9693413   2 months ago   5.35MB
```

- Image Push 

```sh
# image push 
$ docker push localhost:5000/cdecl/alpine:3.13
The push refers to repository [localhost:5000/cdecl/alpine]
c55d5dbdab40: Layer already exists
3.13: digest: sha256:55fc95a51d97f7b76b124f3b581a58ebf5555d12574f16087de3971a12724dd4 size: 528

$ docker push localhost:5000/cdecl/alpine:latest
The push refers to repository [localhost:5000/cdecl/alpine]
5bfa694cc00a: Layer already exists
latest: digest: sha256:bd9137c3bb45dbc40cde0f0e19a8b9064c2bc485466221f5e95eb72b0d0cf82e size: 528

# Catalog list 
$ curl -s http://localhost:5000/v2/_catalog
{"repositories":["cdecl/alpine"]}

# Tag 정보 
$ curl -s http://localhost:5000/v2/cdecl/alpine/tags/list
{"name":"cdecl/alpine","tags":["latest","3.13"]}
```

### Image Pull

```
$ docker pull localhost:5000/cdecl/alpine
Using default tag: latest
latest: Pulling from cdecl/alpine
Digest: sha256:bd9137c3bb45dbc40cde0f0e19a8b9064c2bc485466221f5e95eb72b0d0cf82e
Status: Downloaded newer image for localhost:5000/cdecl/alpine:latest
localhost:5000/cdecl/alpine:latest
```

### Image Delete
- Tag 확인 -> Manifests 확인 ->  Manifests 이미지 삭제

```sh
# Tag 정보 확인 
$ curl -s http://localhost:5000/v2/cdecl/alpine/tags/list
{"name":"cdecl/alpine","tags":["latest","3.13"]}

# Tag의 Manifest 정보확인 - headers 확인 
# <registry-url>/v2/<image-path-name>/manifests/<tag>
$ curl -s -I -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    http://localhost:5000/v2/cdecl/alpine/manifests/latest
HTTP/1.1 200 OK
Content-Length: 528
Content-Type: application/vnd.docker.distribution.manifest.v2+json
Docker-Content-Digest: sha256:bd9137c3bb45dbc40cde0f0e19a8b9064c2bc485466221f5e95eb72b0d0cf82e
Docker-Distribution-Api-Version: registry/2.0
Etag: "sha256:bd9137c3bb45dbc40cde0f0e19a8b9064c2bc485466221f5e95eb72b0d0cf82e"
Date: Mon, 23 Aug 2021 11:45:06 GMT

# Manifest 정보로 이미지 삭제 
# Docker-Content-Digest: <sha256:로 시작하는 해쉬 문자열> 
$ curl -s -XDELETE http://localhost:5000/v2/cdecl/alpine/manifests/sha256:bd9137c3bb45dbc40cde0f0e19a8b9064c2bc485466221f5e95eb72b0d0cf82e

# 확인
$ curl -s http://localhost:5000/v2/cdecl/alpine/tags/list
{"name":"cdecl/alpine","tags":["3.13"]}
```

### Delete marked manifests

```sh
$ curl -sS http://localhost:5000/v2/cdecl/alpine/tags/list
{"name":"cdecl/alpine","tags":null}

$ docker exec -it registry bin/registry garbage-collect /etc/docker/registry/config.yml
cdecl/alpine

0 blobs marked, 3 blobs and 0 manifests eligible for deletion
blob eligible for deletion: sha256:81efc9693413c6292235ea2c29ea07c149701140b98df6c1998bb91d41acf802
INFO[0000] Deleting blob: /docker/registry/v2/blobs/sha256/81/81efc9693413c6292235ea2c29ea07c149701140b98df6c1998bb91d41acf802  go.version=go1.11.2 instance.id=d8bbbd10-232a-457a-9ceb-312b7317da5f service=registry
blob eligible for deletion: sha256:55fc95a51d97f7b76b124f3b581a58ebf5555d12574f16087de3971a12724dd4
INFO[0000] Deleting blob: /docker/registry/v2/blobs/sha256/55/55fc95a51d97f7b76b124f3b581a58ebf5555d12574f16087de3971a12724dd4  go.version=go1.11.2 instance.id=d8bbbd10-232a-457a-9ceb-312b7317da5f service=registry
blob eligible for deletion: sha256:595b0fe564bb9444ebfe78288079a01ee6d7f666544028d5e96ba610f909ee43
INFO[0000] Deleting blob: /docker/registry/v2/blobs/sha256/59/595b0fe564bb9444ebfe78288079a01ee6d7f666544028d5e96ba610f909ee43  go.version=go1.11.2 instance.id=d8bbbd10-232a-457a-9ceb-312b7317da5f service=registry
```

- 위 작업으로는 물리적인 데이터가 삭제 안됨 

```sh
# 물리적인 파일 삭제 
$ docker exec -it registry rm -rf /var/lib/registry/docker/registry/v2/repositories/cdecl
```

---
### Script 
- registry-image-delete.sh

```sh
#!/bin/bash

URI="$1"
NAME="$2"
TAG="$3"

if [[ -z "$URI" ]]; then
        echo "Usage: $0 <URI> <NAME> [<TAG>]"
        exit -1
fi

if [[ -z "$NAME" ]]; then
        echo "Usage: $0 $URI <NAME> [<TAG>]"
        echo
        curl -sS $URI/v2/_catalog | jq -r '.repositories[]'
        echo
        exit -1
fi

if [[ -z "$TAG" ]]; then
        echo "Usage: $0 $URI $NAME [<TAG>]"
        echo
        curl -sS $URI/v2/$NAME/tags/list | jq -r '.tags[]'
        echo
        exit -1
fi

MANIFESTS=$(curl -sS -I -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        $URI/v2/$NAME/manifests/$TAG | grep -i Docker-Content-Digest | awk '{print $2}')

if [[ -z "$MANIFESTS" ]]; then
        echo "No manifest found for $NAME:$TAG"
        exit -1
fi

echo $MANIFESTS
echo
echo curl -sS -XDELETE $URI/v2/$NAME/manifests/$MANIFESTS
echo
```