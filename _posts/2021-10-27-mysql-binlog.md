---
title: MySQL BinLog

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - mysql
  - binlog
---

MySQL BinLog (Binary Log) 설정 및 확인

{% raw %}

## MySQL Binlog
- <https://dev.mysql.com/doc/internals/en/binary-log-overview.html>{:target="_blank"}
- <https://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html>{:target="_blank"}

> 데이터 수정에 대한 정보를 포함하는 로그 파일 세트

### Binlog 를 사용하는 목적 
- 복제 : 마스터 복제 서버에서 슬레이브 서버로 보낼 명령문의 기록으로 사용
- 데이터 복구 : 백업 파일이 복원된, 특정 시점 이후의 데이터 복구를 위해 사용 

### Binlog 기록하는 방법 `binlog-format`
- `STATEMENT` : 이벤트에는 데이터 변경(삽입, 업데이트, 삭제)을 생성하는 SQL 문이 포함
  - `MySQL 5.7.7` 이전 버전까지 `Default`
- `ROW` : 행 기반 로깅: 이벤트는 개별 행의 변경 사항을 설명합니다.
  - `MySQL 5.7.7` 버전 부터 `Default`
- `MIXED` : 기본적으로 `STATEMENT` 로깅, 필요에 따라 자동으로 `ROW` 로깅으로 전환 `일관성`
  - NDB Cluster 경우 `Default`

> `STATEMENT` 경우 `ISOLATION LEVEL`이 `READ-COMMITTED` 경우 복구시, Dirty Read 에 의한 일관성이 문제가 될 수 있음

---

### 주요 확인 및 설정 

```sh
mysql> show binary logs;
+---------------+-----------+-----------+
| Log_name      | File_size | Encrypted |
+---------------+-----------+-----------+
| binlog.000018 |       178 | No        |
| binlog.000019 |       178 | No        |
| binlog.000020 |       178 | No        |
| binlog.000021 |       178 | No        |
| binlog.000022 |      1222 | No        |
| binlog.000023 |       155 | No        |
+---------------+-----------+-----------+
```

##### `max_binlog_size` 
- Binlog 파일별 (`binlog.000xxx`) 로그 크기 `defualt 1G` 

##### `binlog_expire_logs_seconds` /  `expire_logs_days`
- `binlog_expire_logs_seconds` : 로그 저장 기간 설정, 지난 로그는 자동 삭제 `default 2592000 (30days)` 
- `expire_logs_days` : `MySQL 8` 이전 버전 사용, `binlog_expire_logs_seconds` 와 같이 사용 할 수 없음
  - `MySQL 8` 이전 버전에서는 `default 0` 으로 자동 삭제를 하지 않음
  
```sh
mysql> show variables like '%expire_log%';
+----------------------------+---------+
| Variable_name              | Value   |
+----------------------------+---------+
| binlog_expire_logs_seconds | 2592000 |
| expire_logs_days           | 0       |
+----------------------------+---------+
```

#### `my.cnf` 설정
```conf
[mysqld]
binlog_format = ROW  # STATEMENT, MIXED
max_binlog_size = 300M
binlog_expire_logs_seconds = 604800  # 일주일
```

---

### Binlog 추출 
- `mysqlbinlog` : `Binlog` 를 Text 형태로 덤프

```sh
# Basic 
$ mysqlbinlog binlog.000023 > recover.sql

# Database 지정 
$ mysqlbinlog --database=dbname binlog.000023 > recover.sql

# 이벤트 시점 지정 
$ mysqlbinlog --database=dbname --start-datetime="2021-10-28 01:00:00" --stop-datetime="2021-10-28 12:00:00" binlog.000023 > recover.sql
```

##### Binlog 반영 

```sh
$ mysql -u root -p < recover.sql
```

> 주의 : 데이터 삭제 등의 실수로 복구시에는, 삭제 쿼리도 같이 들어가 있어 해당 내용의 적절한 정리가 필요함


{% endraw %}
