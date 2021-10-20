---
title: MySQL LOAD DATA

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - mysql
  - csv
  - load data
---

{% raw %}

MySQL 테이블에 Text 파일을 빠르게 Insert 하는 방벙

## MySQL LOAD DATA
- <https://dev.mysql.com/doc/refman/8.0/en/load-data.html>{:target="_blank"}
  - The LOAD DATA statement reads rows from a text file into a table at a very high speed
  

### LOAD DATA statement 

#### 사전 준비 : secure_file_priv
- `secure_file_priv` 의 설정값이 NULL 로 되어 있는데 빈문자열로 수정해야 함

```sql
SHOW VARIABLES LIKE 'secure_file_priv'  -- NULL 
```

- my.cnf 에서 수정 및 재시작 필요

```ini
[mysqld]
secure-file-priv=""
```

### LOAD DATA 최소 설정 

```sql
LOAD DATA INFILE '/path/data.txt' INTO TABLE data_table 
```

##### Field and Line Handling : Default 설정 
```sql
LOAD DATA INFILE '/path/data.txt' INTO TABLE data_table
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY ''
```

##### 헤더 라인 무시 
```sql
LOAD DATA INFILE '/path/data.txt' INTO TABLE data_table IGNORE 1 LINES
```

### LOAD DATA 기본 설정 

```sql
LOAD DATA INFILE '/path/data.txt' IGNORE INTO TABLE data_table 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n' 
(filed1, filed2, filed3 )
```

##### Duplicate-Key and Error Handling
- `IGNORE` : unique key 값이 있으면 새로운 행은 버려짐 `default`
- `REPLACE` : unique key 값 기준으로 새로운 행으로 변경

##### 필드 개수, 순서 
- 기본적으로 파일의 구분자 기준 순서와 필드와 1:1 매치됨 
- 필드 지정을 통해 순서 조정 가능 
  - 파일의 구분자 필드가 많으면 : 버려짐 
  - 테이블의 필드가 많으면 : 나머지 필드는 Default 값이나 NULL 처리 (NULL 허용시)

##### Input Preprocessing
- 테이블의 중간 필드를 무시 (Default 값 or NULL 처리) 하려면 `@dummy` 키워드로 필드 지정 
- 필드 가공은 `SET` 명령으로 처리
- `@변수` 명으로 받아서 가공후 필드에 지정할 수 있음
  
```sql
LOAD DATA INFILE '/path/data.txt' IGNORE INTO TABLE data_table 
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' 
(filed1, @dummy, filed3, @var1, filed5 )
SET filed2 = CURRENT_TIMESTAMP, filed4 = @var1 * 2;
```

##### Index Handling : `LOAD DATA` 문의 성능향상을 위한 Index check option
- unique index checks option : `SET unique_checks = 0`  `SET unique_checks = 1`
- foreign key check option : `SET foreign_key_checks = 0` `SET foreign_key_checks = 1`

---

#### 로컬(클라이언트) 데이터 원격 INSERT 
- <https://dev.mysql.com/doc/refman/8.0/en/load-data-local-security.html>{:target="_blank"}

##### 사전 준비 : local_infile 설정 (server and client)
- server : `local_infile` 의 설정값이 ON(1) 로 수정해야 함
- client : 접속시 `--local-infile` 옵션 추가 

```sql
SHOW VARIABLES LIKE 'local_infile' ; -- OFF
SET GLOBAL local_infile = 1 ;
SHOW VARIABLES LIKE 'local_infile' ; -- ON
```

##### LOCAL PATH 지정 
- `LOAD DATA LOCAL INFILE ...`

```sql
LOAD DATA LOCAL INFILE '/path/data.txt' INTO TABLE data_table 
```


{% endraw %}