---
title: Oracle, Sqlldr

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - oracle
  - sqlldr
  - bulk
  - SQL*Loader
---

{% raw %}

Oracle 대량 Bulk Insert Tool

## 구성요소 
- Control File : `sqlldr` 명령행을 실행하기 위한 제어, 설정 파일 
- `sqlldr` : SQL*Loader, Oracle 데이터 Insert Tool 

### Control File 기본 구성 

```conf
OPTIONS (DIRECT=TRUE,ERRORS=100000,readsize=204800000)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'infile/${CTL_INFILE}.csv'
TRUNCATE INTO TABLE ${CTL_TABLE}
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY " "
TRAILING NULLCOLS
( ${CTL_TABLE_COLS} )
```

##### OPTIONS DIRECT
- ERRORS : 허용하는 에러수, `default 50`
- DIRECT=TRUE : Direct Path, 쿼리를 실행하지 않고 메모리에 블록을 만들어 테이블에 저장 

##### LOAD DATA  
- INFILE : 데이터 파일, 다수의 파일 등록 가능

##### INSERT/APPEND/REPLACE/TRUNCATE INTO TABLE 
- INSERT : 신규 데이터, 데이터 존재하면 에러 
- APPEND : 중복되지 않은 데이터 추가
- REPLACE, TRUNCATE: 모든 행을 지우고 추가

##### FIELDS TERMINATED
- FIELDS TERMINATED : 필드 구분자
- ENCLOSED BY " " : 텍스트 한정자

##### ${CTL_TABLE_COLS} 
- 테이블 컬럼 리스트 

---

### Control File Sample 

```sql
CREATE TABLE IPMAN (
	IP varchar2(128),
	SERVERNAME varchar2(128),
	ETC  varchar2(128)
)
```

```conf
OPTIONS (DIRECT=TRUE,ERRORS=100000,readsize=204800000)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'infile/IPMAN.csv'
TRUNCATE INTO TABLE IPMAN
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY " "
TRAILING NULLCOLS
( IP "NVL(:IP, ' ')" , SERVERNAME "NVL(:SERVERNAME, ' ')" , ETC "NVL(:ETC, ' ')"  )
```

--- 

### SQLLDR
- Control File 설정으로 SQL*Loader 실행 
  
```sh
$ sqlldr 'dev/<PASSWD>@<SERVER>:1521/<SID>' control=ctl/IPMAN.ctl log=log/IPMAN.log bad=log/IPMAN.bad
```

---
### Control File 자동 생성 SCRIPT 

##### ctl.sh
```sh
#!/bin/bash

if [[ -z "$1" ]]; then
        echo "$0 [TABLE_NAME]"
        exit -1
fi

TABLE_NM="$1"
echo "TABLE NAME: " $TABLE_NM

FD_LIST=$(sqlplus -s ${CTL_CONN} << SQLEOF
set pagesize 0 feedback off verify off heading off echo off

SELECT (CASE WHEN DATA_TYPE = 'DATE' OR DATA_TYPE LIKE 'TIMESTAMP%' THEN COLUMN_NAME || ' TIMESTAMP "YYYY-MM-DD HH24:MI:SS.FF3" @'
             WHEN DATA_TYPE = 'NUMBER' THEN COLUMN_NAME || ' "NVL(:' || COLUMN_NAME || ', 0)" @'
             WHEN DATA_LENGTH > 255 THEN COLUMN_NAME || ' CHAR(65535) @'
        ELSE COLUMN_NAME || ' "NVL(:' || COLUMN_NAME || ', '' '')" @' END) COLUMN_NAME
FROM user_tab_cols
WHERE table_name = '${TABLE_NM}'
AND column_id IS NOT NULL
ORDER BY COLUMN_ID;

exit;
SQLEOF
)

FD_LIST=`echo ${FD_LIST} | sed 's/@/,/g'`
FD_LIST=${FD_LIST%*,*}

export CTL_INFILE=$TABLE_NM
export CTL_TABLE=$TABLE_NM
export CTL_TABLE_COLS=$FD_LIST

envsubst < ctl.template > ctl/$CTL_TABLE.ctl

echo sqlldr \${CTL_CONN} control=ctl/${CTL_TABLE}.ctl log=log/${CTL_TABLE}.log bad=log/${CTL_TABLE}.bad
```

##### ctl.template
```conf
OPTIONS (DIRECT=TRUE,ERRORS=100000,readsize=204800000)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'infile/${CTL_INFILE}.csv'
TRUNCATE INTO TABLE ${CTL_TABLE}
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY " "
TRAILING NULLCOLS
( ${CTL_TABLE_COLS} )
```

##### 실행 

```sh
# infile : 데이터 
# ctl : Control File 
# log : log
$ mkdir -p infile ctl log

# DB 연결 변수 
$ export CTL_CONN='dev/<PASSWD>@<SERVER>:1521/<SID>'
```

```sh
$ ./ctl.sh IPMAN
TABLE NAME:  IPMAN
sqlldr ${CTL_CONN} control=ctl/IPMAN.ctl log=log/IPMAN.log bad=log/IPMAN.bad
```

```sh
$ sqlldr ${CTL_CONN} control=ctl/IPMAN.ctl log=log/IPMAN.log bad=log/IPMAN.bad

SQL*Loader: Release 21.0.0.0.0 - Production on Tue Oct 19 11:36:00 2021
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle and/or its affiliates.  All rights reserved.

Path used:      Direct

Load completed - logical record count 200.

Table IPMAN:
  199 Rows successfully loaded.

Check the log file:
  log/IPMAN.log
for more information about the load.
```


{% endraw %}
