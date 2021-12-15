---
title: MinIO Windows Service 등록

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - minio 
  - winsw
  - windows service
---

MinIO Windows Service 등록

{% raw %}

## MinIO Service 등록 

### WinSW
- <https://github.com/winsw/winsw>{:target="_blank"}
- Windows 실행 파일을 서비스로 래핑해주는 툴 
- .NET Framework / Core 기반 Windows 플랫폼에서 실행

### MinIO Service
- <https://github.com/minio/minio-service/tree/master/windows>{:target="_blank"}

#### WinSW 최신 Release 다운로드 및 XML 설정 파일 작성

```sh
# choco install curl
# 다운로드 
$ curl -LO https://github.com/winsw/winsw/releases/download/v2.11.0/WinSW-x64.exe

# rename
$ move WinSW-x64.exe minio-service.exe
```

- minio-service.xml

```xml
<service>
  <id>MinIO</id>
  <name>MinIO</name>
  <description>MinIO is a high performance object storage server</description>
  <executable>minio.exe</executable>
  <env name="MINIO_ROOT_USER" value="minio"/>
  <env name="MINIO_ROOT_PASSWORD" value="minio1234"/>
  <arguments>server d:\minio\data --console-address ":9001"</arguments>
  <logmode>rotate</logmode>
</service>
```

#### 서비스 등록 
- `Administrator` 권한으로 실행
- `minio` 실행 파일 PATH 등록 or 같은 디렉토리에 위치

```sh
# service install
$ minio-service.exe install 
2021-12-09 15:57:24,987 INFO  - Installing service 'MinIO (MinIO)'...
2021-12-09 15:57:25,085 INFO  - Service 'MinIO (MinIO)' was installed successfully.

# service status
$ minio-service.exe status
Stopped

# service start 
$ minio-service.exe start
2021-12-09 16:05:59,133 INFO  - Starting service 'MinIO (MinIO)'...
2021-12-09 16:06:00,322 INFO  - Service 'MinIO (MinIO)' started successfully.
```

{% endraw %}
