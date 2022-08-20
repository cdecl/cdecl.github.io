---
title: trino(presto), minio docker 테스트 환경 

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - presto
  - trino
  - minio
  - docker
---
 
trino(presto), minio docker 활용 테스트 환경 

{% raw %}

## trino (hive connector) to minio 
- trino 의 hive connector 를 활용해서 minio 데이터 분석 환경
   - Hive connector : <https://trino.io/docs/current/connector/hive.html>{:target="_blank"}
- 참고 : <https://github.com/cdecl/trino-minio-docker>{:target="_blank"}

### docker-compose (trino, minio)

```yaml
version: '3'
services:
  trino:
    image: trinodb/trino
    container_name: trino
    restart: always
    ports:
      - "8080:8080"
    volumes:
      - ./etc:/etc/trino

  minio:
    image: minio/minio
    restart: always
    command: server /data --console-address ":9001"
    container_name: minio
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio1234
    restart: always
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - ./minio-data:/data
```

#### minio (hive) properties
- `etc/catalog/hive.properties`
- metastore 는 minio catalog 버킷에 저장  `s3a://catalog/trino/`
- minio 세팅 정보 : `access-key`, `secret-key`, `endpoint`

```properties
connector.name=hive-hadoop2
hive.metastore=file
hive.metastore.catalog.dir=s3a://catalog/trino/

hive.recursive-directories=true
hive.non-managed-table-writes-enabled=true
hive.allow-drop-table=true

hive.s3.path-style-access=true
hive.s3.ssl.enabled=false
hive.s3select-pushdown.enabled=true

hive.s3.aws-access-key=minio
hive.s3.aws-secret-key=minio1234
hive.s3.endpoint=http://minio:9000
```

### docker-compose 실행 및 초기값 세팅 

```sh
## 실행 
$ docker-compose up -d 
reating network "trino_default" with the default driver
Creating minio ... done
Creating trino ... done
```

#### rclone 으로 minio 버킷 생성 

```sh
# rclone 설정
$ cat local.conf
[local]
type = s3
provider = Minio
env_auth = false
access_key_id = minio
secret_access_key = minio1234
endpoint = http://localhost:9000

# create catalog, data directory 
$ rclone --config local.conf mkdir local:catalog
$ rclone --config local.conf mkdir local:data
```

```sh
# sample json (ndjson) data)
$ cat 1.json
{"id":1,"name":"Alice"}
{"id":2,"name":"Bob"}
{"id":3,"name":"Carol"}

# test data copy
$ rclone --config local.conf copy 1.json local:data/sample/
```

#### schema, table 생성 
- `default` schema (db) 생성 및 external_location table 생성

```sql
-- hive 의 schema(db) 생성 
create schema hive.default;

-- table 생성 
create table hive.default.sample (
  id varchar,
  name varchar
)
with (
  format = 'json',  
  external_location = 's3a://data/sample/'
);

-- select 
select * from sample;
```

#### 쿼리 테스트 (dbeaver)

![](/images/2022-08-20-13-38-49.png)


{% endraw %}
