---
title: Gitlab CI/CD

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - gitlab
  - workflow
  - cicd
---


{% raw %}

# Gitlab CI/CD 101 
- Gitlab 에서 제공하는 CI/CD 목적의 Workflow 툴 
- Auto DevOps or gitlab-runner 에서 실행 
- Setup CI/CD 를 통해 세팅 
  - .gitlab-ci.yml 파일에 기술 

## Gitlab-Runner 
- gitlab-runner : .gitlab-ci.yml 기반 파이프 라인 구성 
  - Shared Runners : gitlab.com 에서 hosting 해주는 Runner
  - Self hosting Runners : 별도 머신을 통해 Runner 설치 

## Gitlab-Runner 세팅 (Self hosting)

### Installing the Runner
- <https://docs.gitlab.com/runner/install/linux-repository.html>{:target="_blank"}

### Registering Runners
- <https://docs.gitlab.com/runner/register/index.html>{:target="_blank"}
- Interactive register runner 

```sh
$ sudo gitlab-runner register 
Runtime platform arch=amd64 os=linux pid=120146 revision=c5874a4b version=12.10.2
Running in system-mode.                            
                                                   
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://hqgit.inpark.kr/
Please enter the gitlab-ci token for this runner:
xxxxxxxxxxxxxxxxxxxxxxxxxxx
Please enter the gitlab-ci description for this runner:
ci-test runner
Please enter the gitlab-ci tags for this runner (comma separated):
centos24,ci-test,cdecl
Registering runner... succeeded                     runner=WpQDakzK
Please enter the executor: shell, kubernetes, parallels, docker, docker-ssh, ssh, virtualbox, docker+machine, docker-ssh+machine, custom:
shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
```

```sh
# inline 
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --tag-list "docker" \


sudo gitlab-runner register \
  --non-interactive \
  --url "http://centos.cdecl.net/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-image alpine \
  --description "docker-runner" \
  --tag-list "docker" \
  --env "DOCKER_TLS_CERTDIR=" \
  --docker-privileged=true \
  --docker-volumes "/ansible:/ansible" \
  --docker-extra-hosts "centos.cdecl.net:192.168.0.20"
```

## Pipeline Configuration Basic
- GitLab CI/CD Pipeline Configuration Reference
  - <https://docs.gitlab.com/ee/ci/yaml/>{:target="_blank"}
- Pipeline
  - 기본적으로 git checkout 실행 
- Github Action 과 다르게 매뉴얼 실행 버튼 존재 

```yaml
image: ubuntu

stages:                   # statge 정의 
  - build
  - test
  - deploy

before_script:            # 
  - echo "Before script section"
  - echo "For example you might run an update here or install a build dependency"
  - echo "Or perhaps you might print out some debugging details"

after_script:
  - echo "After script section"
  - echo "For example you might do some cleanup here"

build_stage:
  stage: build
  script:
    - echo "Do your build here"

test_stage1:
  stage: test
  script:
    - echo "Do a test here"
    - echo "For example run a test suite"

test_stage2:
  stage: test
  script:
    - echo "Do another parallel test here"
    - echo "For example run a lint test"

deploy_stage:
  stage: deploy
  script:
    - echo "Do your deploy here"
```

![](/images/2020-05-18-17-50-34.png)

![](/images/2020-05-18-17-51-51.png)


## Pipeline 예제

### Docker Build & Registry Push
- 변수 등록 : [Settings] - [CI / CD] - [Variables] 
  - ${DOCKERHUB_PASS}

```yaml
image: docker          # docker client

services:
  - docker:dind        # docker deamon

#services:
#  - name: docker:dind
#    command: ["--insecure-registry=registry.bucker.net"]

stages:
- build

build_stage:
  stage: build
  script: 
    - docker build . --tag cdecl/gcc-boost-test
    - echo ${DOCKERHUB_PASS} | docker login -u cdecl --password-stdin
    - docker push cdecl/gcc-boost-test
```

### Custome Image 사용 
- cdecl/gcc-boost  활용 
- tags를 통해 runner 선택
  - gitlab.com 의 경우 tags 가 없으면 Shared Runners로 실행 

```yaml
image: cdecl/gcc-boost

stages:
- build

build_stage:
  stage: build
  script: 
    - cd src 
    - make 
    - ./asb -test http://httpbin.org/get
  tags:
    - centos24-docker          # custome runner, docker executor

```


### Go build 및 Docker image registry (artifacts)
- golang 이미지에서 소스 빌드 후, docker build-push
- `artifacts` 를 활용, stage간 디렉토리 공유 
  - <https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html>{:target="_blank"}

```yaml
image: docker 

services:
  - docker:dind
  
stages:                   
  - build
  - deploy

build_stage:
  image: golang 
  stage: build
  script:
    - go build 
    - mkdir ./output
    - cp go-sitecheck ./output/
  artifacts:
    paths: 
      - ./output

deploy_stage:
  stage: deploy
  script:  
    - cp ./output/go-sitecheck .
    - docker build . --tag cdecl/go-sitecheck-test
    - echo ${DOCKERHUB_PASS} | docker login -u cdecl --password-stdin
    - docker push cdecl/go-sitecheck-test
```

#### Runner 정보 

![](/images/2020-05-18-18-08-57.png)


### Git Commit/Push 
- 계정 Token 생성후, 인증으로 사용 
- git push 형식
  > git push origin HEAD:master # OK  
  > git push origin master  # Error


```yaml
stages:                   # statge 정의 
  - build
  - test
  - deploy

  
build_stage:
  image: cdecl/alpine-ansible
  stage: build
  only:
    changes:
      - .gitlab-ci.yml
  script:
    - git version
    - git config --global user.email "-"
    - git config --global user.name "${GITLAB_USER_LOGIN}"
    
    - echo $CI_COMMIT_REF_NAME  # master
    - echo $GITLAB_USER_LOGIN   # loginID
    
    - date > date.txt
    - git add -u
    - git commit -m "update"

    - git push https://${GITLAB_USER_ID}:${TOKEN}@gitlab.com/cdeclare/ci-test.git HEAD:$CI_COMMIT_REF_NAME 
  
```


{% endraw %}