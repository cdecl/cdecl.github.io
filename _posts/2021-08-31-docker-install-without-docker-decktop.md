---
title: Docker install without docker desktop (WSL)

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - docker
  - docker desktop
  - wsl2
---

{% raw %}

WSL2 에 Docker 설치 (without Docker Desktop)

## Docker Desktop 
- [Docker Desktop 유료화](https://www.docker.com/blog/updating-product-subscriptions/){:target="_blank"}

> Docker Desktop remains free for small businesses (fewer than 250 employees AND less than $10 million in annual revenue), personal use, education, and non-commercial open source projects.

- WSL2 이후, Docker Desktop 의 기능을 따로 사용하지 않아도 CLI 기능으로도 충분
  - 개인적으로 Hyper-v VM 사용 권고


## Docker install without docker desktop

### WSL2 Install 
- [Windows 10에 Linux용 Windows 하위 시스템 설치 가이드](https://docs.microsoft.com/ko-kr/windows/wsl/install-win10){:target="_blank"}


### Docker install 
- <https://newbedev.com/shell-install-docker-on-wsl-without-docker-desktop-code-example>{:target="_blank"}

```sh
# Update the apt package list.
$ sudo apt-get update -y

# Install Docker's package dependencies.
$ sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Download and add Docker's official public PGP key.
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify the fingerprint.
$ sudo apt-key fingerprint 0EBFCD88

# Add the `stable` channel's Docker upstream repository.
#
# If you want to live on the edge, you can change "stable" below to "test" or
# "nightly". I highly recommend sticking with stable!
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update the apt package list (for the new apt repo).
$ sudo apt-get update -y

# Install the latest version of Docker CE.
$ sudo apt-get install -y docker-ce

# Allow your user to access the Docker CLI without needing root access.
$ sudo usermod -aG docker $USER
```

```sh
# START DOCKER DAEMON
$ sudo service docker start
$ sudo service docker status

$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```



{% endraw %}