---
title: DuckDB, CSV에서 MySQL로의 ETL
tags:
  - duckdb
  - etl
  - mysql
  - sqlite3
---
DuckDB를 ETL 도구로 활용 : CSV 데이터 → MySQL 



## DuckDB를 통한 CSV 데이터를 MySQL로 ETL 하는 방법

### ETL이란?
- ETL이란 Extract, Transform, Load의 약자로, 데이터를 다양한 소스에서 추출하고 변환하고 적재하는 과정
- ETL을 수행하기 위해서는 여러가지 툴을 사용할 수 있는데 그 중 하나 DuckDB 활용하는 안

### DuckDB
- DuckDB는 분석 쿼리에 최적화된 임베디드 데이터베이스 
- DuckDB는 PostgreSQL과 호환되는 SQL 문법을 사용하고, 여러 DB와 연결하여 데이터를 효율적으로 가져와 로컬 DuckDB에서 데이터 처리 가능
  - Extensions : https://duckdb.org/docs/extensions/overview

### ETL 예제  
- DuckDB에서 CSV 파일을 읽어와 테이블 생성 
- [MySQL Extension](https://duckdb.org/docs/extensions/mysql){:target="_blank"}

```sql
CREATE TABLE csv_table AS SELECT * FROM read_csv_auto('your_csv_file');
```

- DuckDB에서 MySQL에 연결합니다. 다음과 같은 명령어를 사용할 수 있습니다.

```sql
INSTALL MySQL;
LOAD MySQL;

ATTACH 'host=localhost user=root port=0 database=etldb' AS mysqldb (TYPE mysql)
USE mysqldb;
```

- DuckDB에서 MySQL로 데이터를 적재합니다. 다음과 같은 명령어를 사용할 수 있습니다.

```sql
CREATE TABLE mysqldb.etldb.csvtbl AS SELECT * FROM csv_table;
```

### 참고 
- [MySQL LOAD DATA](/devops/mysql-load-data/){:target="_blank"}
- [CSV to SQLite3](/devops/csv-to-sqlite3/){:target="_blank"}


