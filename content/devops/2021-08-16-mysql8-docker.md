---
title: MySQL 8 Docker Basic, Json Type 지원
tags:
  - mysql
  - docker
  - json
---
MySQL 8 Docker 실행 및 백업, 복원

## MySQL Docker 실행 

### docker-compose 
- data:/var/lib/mysql : Data 파일 
- conf.d:/etc/mysql/conf.d : my.cnf 등의 설정파일 
- root:/root : login-path 사용시 
- ports : 
  - "3380:3306" : mysql port 
  - "33800:33060" : mysql-shell port 

```yaml
version: '3'

services:
  db:
    image: mysql:8
    container_name: mysql8
    command: --default-authentication-plugin=mysql_native_password 
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: passwd
      TZ: Asia/Seoul
    ports:
      - "3380:3306"
      - "33800:33060"
    volumes:
      - data:/var/lib/mysql
      - conf.d:/etc/mysql/conf.d
      - root:/root

volumes:
  data:
  conf.d:
  root:
```

```sh
$  docker-compose up -d
Creating network "mysql_default" with the default driver
Creating volume "mysql_data" with default driver
Creating volume "mysql_conf.d" with default driver
Creating volume "mysql_root" with default driver
Pulling db (mysql:8)...
8: Pulling from library/mysql
e1acddbe380c: Pull complete
bed879327370: Pull complete
03285f80bafd: Pull complete
ccc17412a00a: Pull complete
1f556ecc09d1: Pull complete
adc5528e468d: Pull complete
1afc286d5d53: Pull complete
6c724a59adff: Pull complete
0f2345f8b0a3: Pull complete
c8461a25b23b: Pull complete
3adb49279bed: Pull complete
77f22cd6c363: Pull complete
Digest: sha256:d45561a65aba6edac77be36e0a53f0c1fba67b951cb728348522b671ad63f926
Status: Downloaded newer image for mysql:8
Creating mysql8 ... done
```

### 연결 테스트 
- docker `-t` 옵션 제외 : the input device is not a TTY

```sh
#  echo 'select host, user from mysql.user' | docker exec -i mysql8 mysql -uroot -ppasswd
$ docker exec -i mysql8 mysql -uroot -ppasswd <<< 'select host, user from mysql.user'
mysql: [Warning] Using a password on the command line interface can be insecure.
host    user
%       root
localhost       mysql.infoschema
localhost       mysql.session
localhost       mysql.sys
localhost       root
```

> mysql: [Warning] Using a password on the command line interface can be insecure.

#### login-path 설정 
- password를 노출 안하고 batch 등의 실행시 유용

```sh
# mysql_config_editor 사용
$ docker exec -it mysql8 mysql_config_editor set --login-path=local --host=localhost --user=root -p
Enter password: xxxxxxxx

# login 정보 저장
$ docker exec mysql8 ls -la /root/.mylogin.cnf
-rw------- 1 root root 136 Aug 18 09:19 /root/.mylogin.cnf

# docker exec -i mysql8 mysql -uroot -ppasswd <<< 'select host, user from mysql.user'
$ docker exec -i mysql8 mysql --login-path=local < <(echo 'select host, user from mysql.user')
host    user
%       root
localhost       mysql.infoschema
localhost       mysql.session
localhost       mysql.sys
localhost       root
```

### MySQL Docker Restore 

```sh
$ docker exec -i mysql8 mysql --login-path=local  < backup.sql
```

### MySQL Docker Backup

```sh
$ docker exec -i mysql8 mysqldump --login-path=local --column-statistics=0 \
  --single-transaction --routines --all-databases > backup_to.sql
```

---

## MySQL 8, Json Type 지원 
- Document DB 로서의 활용 가능 

### Json Type 지원
- MySQL 5.7.8 버전부터 Json 타입을 지원  
	- <https://mysqlserverteam.com/indexing-json-documents-via-virtual-columns/>{:target="_blank"}
	- <https://dev.mysql.com/doc/refman/8.0/en/json-function-reference.html>{:target="_blank"}

- Json 지원 함수
	- JSON_EXTRACT 함수 : Json 항목에서 Column 값을 평가 (operator -> 매핑)
	- JSON_UNQUOTE 함수 : Json 항목에서 "" (QUOTE)를 제거 
- Json 지원 함수 매핑 Operator 
	- JSON_EXTRACT(doc, "$.key")  : doc->"$.key"
	- JSON_UNQUOTE(JSON_EXTRACT(doc, "$.key"))  : doc->>"$.key"

```sh
doc 
------
{"id": "20180601-001", "CPU": "Power7 3.808Ghz (11core)", "UNIT": "12",  ...}
```

```sql
SELECT 	
  -- 같음  "Power7 3.808Ghz (11core)"
  JSON_EXTRACT(doc, '$.CPU'), doc->'$.CPU' 

  -- 같음  Power7 3.808Ghz (11core)
  JSON_UNQUOTE(JSON_EXTRACT(doc, '$.CPU')), doc->>'$.CPU' 
from asset i;
```

### MySQL Shell
- MySQL 8  MySQL Shell 추가   
- 기존 MySQL CLI 기능을 포함하면서 별도로 Javascript 나 Python 을 통해서 Scripting 을 할 수 있고, 기본 포트 3306 에 33060 가 추가되서 확장된 --mysqlx 프로토콜로 접속하여 더 많은 기능 활용 가능 
- <https://dev.mysql.com/doc/mysql-shell/8.0/en/>{:target="_blank"}

```
# centos
$ sudo yum install mysql-shell

$ mysqlsh --version
mysqlsh   Ver 8.0.19 for Linux on x86_64 - for MySQL 8.0.19 (MySQL Community Server (GPL))
```

### Json Import 지원
- MySQL Shell 을 통해서 Json(ndjson) 파일을 Import 할수 있는 기능이 추가
- ES의 Bulk Insert 와 유사 기능

```sh
# x pro
# glass database 에 itasset 이라는 Table 을 만들고 해당 내용을 Import 
$ mysqlsh --mysqlx cdecl@localhost:33060/glass --import asset.json

# collection (table) 명을 지정 가능 
$ mysqlsh --mysqlx cdecl@localhost:33060/glass --import asset.json --collection=asset_db 
```

- 아래와 같은 스키마로 테이블이 생성 됩니다. 

```sh
+--------------+---------------+------+-----+---------+-------------------+
| Field        | Type          | Null | Key | Default | Extra             |
+--------------+---------------+------+-----+---------+-------------------+
| doc          | json          | YES  |     | NULL    |                   |
| _id          | varbinary(32) | NO   | PRI | NULL    | STORED GENERATED  |
| _json_schema | json          | YES  |     | NULL    | VIRTUAL GENERATED |
+--------------+---------------+------+-----+---------+-------------------+
```

### Json Type Indexing 
- 필드를 추가후 해당 필드를 Json 데이터의 특정 필드에 매핑(이라기 보다 트리거 같음) 할수 있음 

```sql
-- 필드를 추가하고  id_index 와 "$.id" 값을 매핑 
ALTER TABLE asset ADD id_index VARCHAR(30) AS (doc->>"$.id");

-- id_index 에 index 추가 
ALTER TABLE asset ADD INDEX (id_index);
```

