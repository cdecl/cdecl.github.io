---
title: SQL Server, BCP

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - sqlserver
  - mssql
  - bcp
  - bulk
---

{% raw %}

SQL Server 대량 복사 프로그램 유틸리티(**b** ulk **c** opy **p** rogram utility, `bcp`)

## BCP
- <https://docs.microsoft.com/ko-kr/sql/tools/bcp-utility>{:target="_blank"}
- SQL Server 의 Bulk 대량 데이터 Export 및 Import 유틸리티

### 설치 

#### Windows 
- 다운로드 : [Microsoft® Command Line Utilities 14.0 for SQL Server](https://www.microsoft.com/en-us/download/details.aspx?id=53591){:target="_blank"}

#### Linux 
- SQL Server 의 리눅스 지원으로 사용 가능 
- [Linux에서 SQL Server 명령줄 도구 sqlcmd 및 bcp 설치](https://docs.microsoft.com/ko-kr/sql/linux/sql-server-linux-setup-tools){:target="_blank"}


### Export 기본 
`cvs` 파일로 테이블(쿼리 데이터) Export 

```sh
$ bcp
사용법: bcp {dbtable | query} {in | out | queryout | format} 데이터 파일
  [-m 최대 오류 수]                  [-f 서식 파일]          [-e 오류 파일]
  [-F 첫 행]                         [-L 마지막 행]          [-b 일괄 처리 크기]
  [-n 네이티브 유형]                 [-c 문자 유형]          [-w 와이드 문자 유형]
  [-N 비텍스트 네이티브 유지]        [-V 파일 형식 버전]    [-q 따옴표 붙은 식별자]
  [-C 코드 페이지 지정자]            [-t 필드 종결자]        [-r 행 종결자]
  [-i 입력 파일]                     [-o 출력 파일]          [-a 패킷 크기]
  [-S 서버 이름]                     [-U 사용자 이름]        [-P 암호]
  [-T 트러스트된 연결]               [-v 버전]               [-R 국가별 설정 사용]
  [-k Null 값 유지]     [-E ID 값 유지][-G Azure Active Directory 인증]
  [-h "힌트 로드"]                   [-x xml 서식 파일 생성]
  [-d 데이터베이스 이름]        [-K 애플리케이션 의도]  [-l 로그인 제한 시간]
```

### Export `csv`
```sh
$ bcp "SELECT * FROM dbname.dbo.tablename" queryout tablename.csv -c -t "," -r "\n" -S <SERVER> -U <USER> -P <PASSWD>
```

##### 테이블 지정 Export : `out`
```sh
$ bcp "dbname.dbo.tablename" out output.csv ...
```

##### 쿼리 실행 결과 Export : `queryout`
```sh
$ bcp "query" queryout output.csv ...
```

##### Export 데이터 형식
- `-n` : 네이티브 포맷, SQL Server로 데이터 이전 할때 유용 (종결자 등의 이유로 데이터 이슈 해결)
- `-c` : 문자유형, OS의 기본 Charset을 따라감 
  - 한글 Windows : `EUC-KR`
  - Linux : `UTF-8`
- `-w` : 와이드 문자유형, 유니코드 `UTF-16 LE`

---

### Import 
```sh
$ bcp "dbname.dbo.tablename" in input.csv -c -t "," -r "\n" -S <SERVER> -U <USER> -P <PASSWD>
```

---

### 특이사항 
- 길이가 0인 문자열의 경우 데이터 내에 `NULL` 문자를 삽입 
- SQL Server의 경우 문제는 없지만, 다른 DB 에 Import 의 경우 `NULL` 문자가 들어감

```sql
INSERT INTO tablename (filed) SELECT CHARACTER(0)

-- MySQL 5.7 
SELECT * FROM tablename WHERE filed = '';        -- Not Working 
SELECT * FROM tablename WHERE ASCII(filed) = 0;  -- Working 

-- MySQL 8 
SELECT * FROM tablename WHERE filed = '';        -- Working 
SELECT * FROM tablename WHERE ASCII(filed) = 0;  -- Working 
```

{% endraw %}