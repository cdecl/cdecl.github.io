---
title: DuckDB CLI 및 SQL CheatSheet  

toc: true  
toc_sticky: true  

categories:  
  - 데이터-엔지니어링  

tags:  
  - duckdb  
  - sql  
  - cli  
  - csv  
  - parquet  
  - json  
  - excel  
  - 데이터베이스  
  - http  
  - s3  
---

DuckDB CLI 및 SQL CheatSheet - 주요 파일 포맷, DB Attach, HTTP/S3, Excel

## DuckDB CLI 및 SQL CheatSheet 가이드

### 1. DuckDB와 CLI/SQL 기능 소개

DuckDB는 고성능 분석 쿼리를 위해 설계된 인-프로세스, 컬럼 지향 OLAP 데이터베이스입니다. CLI와 SQL 인터페이스를 통해 CSV, Parquet, JSON, Excel 등의 파일 포맷을 처리하고, 데이터베이스를 관리하며, HTTP/S3와 같은 웹 기반 스토리지와 통합할 수 있습니다. 이 치트시트는 DuckDB의 CLI와 SQL 명령어를 중심으로 실용적인 예제와 모범 사례를 제공합니다.

**주요 기능**:
- **파일 포맷 지원**: CSV, Parquet, JSON, Excel 등을 손쉽게 읽고 쓰기.
- **데이터베이스 관리**: 여러 데이터베이스를 연결하고 테이블을 효율적으로 관리.
- **웹 통합**: `httpfs` 확장을 통해 HTTP 또는 S3에서 원격 데이터 접근.
- **사용 편의성**: 직관적인 CLI와 SQL 문법으로 빠른 데이터 처리.

이 가이드는 데이터 엔지니어, 분석가, 개발자가 로컬 및 원격 데이터 워크플로우에 DuckDB를 활용하고자 할 때 유용합니다.

### 2. 파일 포맷 vs. 데이터베이스 작업

DuckDB는 파일 직접 작업과 전통적인 데이터베이스 관리를 모두 지원합니다. 아래 표는 두 접근 방식의 차이를 비교합니다:

| 기능                | 파일 작업                           | 데이터베이스 작업                   |
|---------------------|------------------------------------|------------------------------------|
| **범위**            | CSV, Parquet, JSON, Excel 파일     | 영구 DB 파일 (`.db`)               |
| **접근 방식**       | SQL로 직접 읽기/쓰기               | 데이터베이스 연결, 테이블 생성 및 쿼리 |
| **사용 사례**       | 임시 분석, ETL                     | 구조화된 데이터 저장, 인덱싱        |
| **예제**            | `SELECT * FROM 'file.csv';`        | `ATTACH 'mydb.db'; SELECT * FROM mytable;` |

파일 작업은 빠른 분석에 적합하며, 데이터베이스 작업은 구조화된 영구 저장에 적합합니다. DuckDB는 두 방식 간 전환을 유연하게 지원합니다.

### 3. 파일 포맷 작업

DuckDB는 `read_csv_auto`, `read_parquet`, `read_json_auto`, 그리고 `excel` 확장을 통해 CSV, Parquet, JSON, Excel 파일을 지원합니다. 각 포맷에 대한 주요 명령어는 아래와 같습니다.

#### 3.1 CSV 파일
- **가져오기**:
  - CLI:
    ```bash
    duckdb -c "CREATE TABLE mytable AS SELECT * FROM 'file.csv';"
    ```
  - SQL:
    ```sql
    SELECT * FROM read_csv_auto('file.csv');
    CREATE TABLE mytable AS SELECT * FROM read_csv('file.csv', delim=',', header=TRUE);
    ```
  - 사용자 정의 스키마:
    ```sql
    SELECT * FROM read_csv('file.csv', columns={'id': 'INTEGER', 'name': 'VARCHAR'});
    ```

- **헤더 옵션 (`header`)**:
  - `header=TRUE`: 첫 번째 행을 컬럼 이름으로 사용.
    ```sql
    SELECT * FROM read_csv('file.csv', header=TRUE);
    ```
  - `header=FALSE`: 첫 번째 행을 데이터로 처리, 기본 컬럼 이름 생성 (예: `column0`, `column1`).
    ```sql
    SELECT * FROM read_csv('file.csv', header=FALSE);
    ```
  - `read_csv_auto`는 기본적으로 `header=TRUE`로 동작하며, 헤더 유무를 자동 감지.
    ```sql
    SELECT * FROM read_csv_auto('file.csv', header=TRUE);
    ```

- **내보내기**:
  - CLI:
    ```bash
    duckdb -c "COPY mytable TO 'output.csv';"
    ```
  - SQL:
    ```sql
    COPY mytable TO 'output.csv' (DELIMITER ',', HEADER);
    ```
  - 내보내기 시 `HEADER` 옵션 추가로 컬럼 이름 포함:
    ```sql
    COPY mytable TO 'output.csv' (DELIMITER ',', HEADER TRUE);
    ```

- **참고**:
  - `read_csv_auto`는 구분자와 스키마를 자동으로 감지.
  - `header` 옵션은 데이터의 구조를 명확히 지정할 때 유용.
  - 압축 파일 지원 (예: `file.csv.gz`).

#### 3.2 Parquet 파일
- **가져오기**:
  - CLI:
    ```bash
    duckdb -c "CREATE TABLE mytable AS SELECT * FROM 'file.parquet';"
    ```
  - SQL:
    ```sql
    SELECT * FROM read_parquet('file.parquet');
    CREATE TABLE mytable AS SELECT * FROM read_parquet('file.parquet');
    ```
  - 다중 파일:
    ```sql
    SELECT * FROM read_parquet(['file1.parquet', 'file2.parquet']);
    ```

- **내보내기**:
  - CLI:
    ```bash
    duckdb -c "COPY mytable TO 'output.parquet';"
    ```
  - SQL:
    ```sql
    COPY mytable TO 'output.parquet' (FORMAT PARQUET);
    ```

- **참고**:
  - 컬럼 지향 저장으로 대규모 데이터에 최적화.
  - 원격 접근 지원 (HTTP/S3 섹션 참조).

#### 3.3 JSON 파일
- **가져오기**:
  - CLI:
    ```bash
    duckdb -c "CREATE TABLE mytable AS SELECT * FROM read_json_auto('file.json');"
    ```
  - SQL:
    ```sql
    SELECT * FROM read_json_auto('file.json');
    CREATE TABLE mytable AS SELECT * FROM read_json('file.json', format='auto');
    ```
  - JSON Lines:
    ```sql
    SELECT * FROM read_json('file.jsonl', lines=TRUE);
    ```

- **내보내기**:
  - CLI:
    ```bash
    duckdb -c "COPY mytable TO 'output.json';"
    ```
  - SQL:
    ```sql
    COPY mytable TO 'output.json' (FORMAT JSON);
    ```

- **참고**:
  - 중첩 JSON은 `unnest`로 평탄화 가능.
  - `read_json_auto`는 스키마를 자동 추론.

#### 3.4 Excel 파일
- **설정**:
  - Excel 파일 처리는 `excel` 확장이 필요.
  - 설치 및 로드:
    ```sql
    INSTALL excel;
    LOAD excel;
    ```

- **가져오기**:
  - CLI:
    ```bash
    duckdb -c "CREATE TABLE mytable AS SELECT * FROM read_xlsx('file.xlsx');"
    ```
  - SQL:
    ```sql
    SELECT * FROM read_xlsx('file.xlsx');
    CREATE TABLE mytable AS SELECT * FROM read_xlsx('file.xlsx');
    ```
  - 특정 시트 지정:
    ```sql
    SELECT * FROM read_xlsx('file.xlsx', sheet='Sheet1');
    ```
  - 특정 셀 범위 지정:
    ```sql
    SELECT * FROM read_xlsx('file.xlsx', sheet='Sheet1', range='A1:C10');
    ```

- **내보내기**:
  - CLI:
    ```bash
    duckdb -c "COPY mytable TO 'output.xlsx' WITH (FORMAT xlsx);"
    ```
  - SQL:
    ```sql
    COPY mytable TO 'output.xlsx' WITH (FORMAT xlsx, SHEET 'Sheet1');
    ```
  - 여러 시트로 내보내기:
    ```sql
    COPY mytable TO 'output.xlsx' WITH (FORMAT xlsx, SHEET 'DataSheet');
    ```

- **참고**:
  - `read_xlsx`은 `.xlsx`, `.xls` 파일을 지원하며, `sheet` 또는 `range` 옵션으로 데이터 범위를 지정할 수 있음.
  - `COPY ... WITH (FORMAT xlsx)`을 사용해 Excel 파일로 내보내기 가능.
  - 복잡한 서식(예: 차트, 매크로)은 지원하지 않음.
  - 원격 Excel 파일은 HTTP/S3를 통해 접근 가능 (아래 섹션 참조).
  - 대규모 데이터는 Parquet으로 변환 권장.

### 4. 데이터베이스 작업 및 Attach

DuckDB는 인-메모리 및 파일 기반 데이터베이스를 지원하며, `ATTACH` 명령어로 다중 데이터베이스 워크플로우를 구현할 수 있습니다.

#### 4.1 데이터베이스 관리
- **데이터베이스 열기**:
  - CLI:
    ```bash
    duckdb mydb.db  # 파일 기반 DB
    duckdb          # 인-메모리 DB
    ```
  - SQL:
    ```sql
    ATTACH DATABASE 'mydb.db' AS mydb;
    DETACH DATABASE mydb;
    ```

- **테이블 작업**:
  - SQL:
    ```sql
    CREATE TABLE mytable (id INTEGER, name VARCHAR);
    INSERT INTO mytable VALUES (1, 'Alice'), (2, 'Bob');
    SELECT * FROM mytable WHERE id > 1;
    DROP TABLE mytable;
    ```

- **인덱싱**:
  - SQL:
    ```sql
    CREATE INDEX idx ON mytable(id);
    ```

#### 4.2 다중 데이터베이스 쿼리를 위한 ATTACH
- **단일 데이터베이스**:
  - SQL:
    ```sql
    ATTACH DATABASE 'mydb.db' AS mydb;
    USE mydb;
    SELECT * FROM mytable;
    ```
  - CLI:
    ```bash
    duckdb -c "ATTACH DATABASE 'mydb.db' AS mydb;"
    ```

- **다중 데이터베이스**:
  - SQL:
    ```sql
    ATTACH DATABASE 'db1.db' AS db1;
    ATTACH DATABASE 'db2.db' AS db2;
    SELECT * FROM db1.mytable JOIN db2.another_table ON db1.mytable.id = db2.another_table.id;
    ```

- **참고**:
  - `ATTACH`로 여러 데이터베이스 간 쿼리 가능.
  - 기본 데이터베이스는 `main`, 추가 데이터베이스는 별칭(예: `mydb`)으로 구분.

### 5. HTTP 및 S3 통합

DuckDB의 `httpfs` 확장은 HTTP 또는 S3를 통해 원격 파일에 접근할 수 있게 해주며, 클라우드 기반 워크플로우에 이상적입니다.

#### 5.1 설정
- **확장 설치 및 로드**:
  - SQL:
    ```sql
    INSTALL httpfs;
    LOAD httpfs;
    ```
  - CLI:
    ```bash
    duckdb -c "INSTALL httpfs; LOAD httpfs;"
    ```

#### 5.2 HTTP 접근
- **가져오기**:
  - SQL:
    ```sql
    SELECT * FROM read_csv_auto('https://example.com/data.csv');
    SELECT * FROM read_parquet('https://example.com/file.parquet');
    SELECT * FROM read_xlsx('https://example.com/file.xlsx', sheet='Sheet1');
    ```
  - CLI:
    ```bash
    duckdb -c "SELECT * FROM read_xlsx('https://example.com/file.xlsx');"
    ```

- **내보내기**:
  - SQL:
    ```sql
    COPY mytable TO 'https://example.com/output.xlsx' WITH (FORMAT xlsx, SHEET 'Sheet1');
    ```

#### 5.3 S3 접근
- **자격 증명으로 가져오기**:
  - SQL:
    ```sql
    SET s3_access_key_id = 'your_access_key';
    SET s3_secret_access_key = 'your_secret_key';
    SELECT * FROM read_parquet('s3://bucket/file.parquet');
    SELECT * FROM read_xlsx('s3://bucket/file.xlsx', sheet='Sheet1');
    ```
  - 익명 접근:
    ```sql
    SELECT * FROM read_parquet('s3://bucket/public/file.parquet');
    SELECT * FROM read_xlsx('s3://bucket/public/file.xlsx');
    ```

- **내보내기**:
  - SQL:
    ```sql
    COPY mytable TO 's3://bucket/output.xlsx' WITH (FORMAT xlsx, SHEET 'Sheet1');
    ```

- **참고**:
  - S3 리전 설정: `SET s3_region = 'us-east-1';`.
  - `httpfs`는 HTTP와 S3 프로토콜 모두 지원.
  - Excel 파일의 원격 내보내기는 `httpfs` 확장과 함께 작동.

### 6. CLI 유틸리티

DuckDB의 CLI는 출력 형식과 실행 옵션을 통해 생산성을 높입니다.

- **출력 형식**:
  ```bash
  .mode box  # 보기 좋은 테이블 출력
  .mode csv  # CSV 출력
  ```

- **쿼리 실행**:
  ```bash
  duckdb -c "SELECT * FROM 'file.csv';"  # 단일 쿼리
  duckdb < query.sql                    # SQL 파일 실행
  ```

- **기타 명령어**:
  ```bash
  .open mydb.db  # DB 열기
  .help          # 도움말 보기
  .exit          # 종료
  ```

### 7. 예제 SQL 및 CLI 워크플로우

아래는 실제 데이터 처리 시나리오를 보여주는 예제입니다.

#### 예제 데이터
- **로컬 CSV 파일**: `users.csv` (id, name 컬럼, 헤더 포함).
- **로컬 Excel 파일**: `sales.xlsx` (Sheet1에 데이터 포함).
- **원격 Parquet 파일**: `s3://bucket/data.parquet`.
- **데이터베이스**: `mydb.db`.

#### 예제 워크플로우
```bash
# CLI로 DuckDB 실행 및 확장 로드
duckdb
> INSTALL httpfs; LOAD httpfs;
> INSTALL excel; LOAD excel;

# 로컬 CSV에서 테이블 생성 (헤더 포함)
> CREATE TABLE users AS SELECT * FROM read_csv_auto('users.csv', header=TRUE);

# 로컬 Excel 파일에서 데이터 가져오기
> CREATE TABLE sales AS SELECT * FROM read_xlsx('sales.xlsx', sheet='Sheet1');

# 원격 Parquet 데이터 쿼리
> SELECT * FROM read_parquet('s3://bucket/data.parquet') LIMIT 5;

# 데이터베이스 연결 및 데이터 삽입
> ATTACH DATABASE 'mydb.db' AS mydb;
> INSERT INTO mydb.users SELECT * FROM users;

# 다중 DB 쿼리
> ATTACH DATABASE 'db2.db' AS db2;
> SELECT u.name FROM mydb.users u JOIN db2.orders o ON u.id = o.user_id;

# 결과 내보내기 (Excel 파일)
> COPY users TO 'output.xlsx' WITH (FORMAT xlsx, SHEET 'Users');
```

이 워크플로우는 로컬 및 원격 데이터를 통합하고, 다중 데이터베이스 쿼리를 실행하며, 결과를 다양한 포맷(특히 Excel)으로 내보내는 과정을 보여줍니다.

### 8. 추가 팁

- **쿼리 최적화**:
  ```sql
  EXPLAIN ANALYZE SELECT * FROM mytable;  # 실행 계획 분석
  SUMMARIZE mytable;                     # 데이터 요약
  ```

- **다중 포맷 통합**:
  ```sql
  SELECT * FROM read_csv_auto('file.csv')
  UNION ALL
  SELECT * FROM read_parquet('file.parquet')
  UNION ALL
  SELECT * FROM read_xlsx('file.xlsx', sheet='Sheet1');
  ```

- **로컬 및 원격 혼합**:
  ```sql
  SELECT * FROM read_csv_auto('https://example.com/data.csv')
  UNION ALL
  SELECT * FROM read_xlsx('https://example.com/file.xlsx', sheet='Sheet1');
  ```

