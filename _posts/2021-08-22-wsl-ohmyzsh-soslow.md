---
title: oh-my-zsh so slow (WSL)

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - wsl
  - oh-my-zsh
  - zsh
---

oh-my-zsh 이 느린 경우 해결 방법 (특히 WSL)

## oh-my-zsh so slow 
- Theme 가 느린 경우는 Pass 
- git 관리 디렉토리 진입시 현저히 느려지는 경우

```sh
$ git config --global oh-my-zsh.hide-status 1
$ git config --global oh-my-zsh.hide-dirty 1

$ git config --global -l
oh-my-zsh.hide-status=1
oh-my-zsh.hide-dirty=1
```