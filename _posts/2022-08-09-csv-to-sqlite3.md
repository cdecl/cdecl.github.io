---
title: CSV to SQLite3 

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - csv
  - sqlite3
  - bat
---
 
CSV 파일을 SQLite3 Import 및 Query

{% raw %}

## CSV to SQLite3 
CSV 파일을 SQLite3로 Import 쿼리


### CSV 샘플 데이터 확인 

```sh
$ cat cities.csv
"LatD", "LatM", "LatS", "NS", "LonD", "LonM", "LonS", "EW", "City", "State"
   41,    5,   59, "N",     80,   39,    0, "W", "Youngstown", OH
   42,   52,   48, "N",     97,   23,   23, "W", "Yankton", SD
   46,   35,   59, "N",    120,   30,   36, "W", "Yakima", WA
...
```

> TIP: cat 대신 bat 사용하면 더 나은 뷰어를 제공 

```sh
$ bat cities.csv
```
![](/images/2022-08-10-02-18-58.png)

### CSV Import
- `.mode csv` : csv 모드로 전환
- `.import ./cities.csv ci` : `./cities.csv` 파일을 ci 테이블로 Import 
   - `.import --skip 1 ./cities.csv ci` : `./cities.csv`  테이블이 존재 할때 header 제외 
   - `.import --csv ./cities.csv ci` : `./cities.csv`  csv 모드 inline 옵션 

```sh
# ci.db 생성 및 인터랙티브 모드
$ sqlite3 ci.db
SQLite version 3.37.0 2021-12-09 01:34:53
Enter ".help" for usage hints.
sqlite> .mode csv
sqlite> .import ./cities.csv ci
sqlite> .tables
ci
sqlite> select count(*) from ci;
count(*)
129
sqlite> .mode list
sqlite> .header on
sqlite> select * from ci limit 10;
LatD| "LatM"| "LatS"| "NS"| "LonD"| "LonM"| "LonS"| "EW"| "City"| "State"
   41|    5|   59| "N"|     80|   39|    0| "W"| "Youngstown"| OH
   42|   52|   48| "N"|     97|   23|   23| "W"| "Yankton"| SD
   46|   35|   59| "N"|    120|   30|   36| "W"| "Yakima"| WA
   42|   16|   12| "N"|     71|   48|    0| "W"| "Worcester"| MA
   43|   37|   48| "N"|     89|   46|   11| "W"| "Wisconsin Dells"| WI
   36|    5|   59| "N"|     80|   15|    0| "W"| "Winston-Salem"| NC
   49|   52|   48| "N"|     97|    9|    0| "W"| "Winnipeg"| MB
   39|   11|   23| "N"|     78|    9|   36| "W"| "Winchester"| VA
   34|   14|   24| "N"|     77|   55|   11| "W"| "Wilmington"| NC
   39|   45|    0| "N"|     75|   33|    0| "W"| "Wilmington"| DE
```

#### Inline command 

```sh
$ sqlite3 /tmp/t.db ".import -csv ./cities.csv ci" "select * from ci" -header
LatD| "LatM"| "LatS"| "NS"| "LonD"| "LonM"| "LonS"| "EW"| "City"| "State"
   41|    5|   59| "N"|     80|   39|    0| "W"| "Youngstown"| OH
   42|   52|   48| "N"|     97|   23|   23| "W"| "Yankton"| SD
   46|   35|   59| "N"|    120|   30|   36| "W"| "Yakima"| WA
   42|   16|   12| "N"|     71|   48|    0| "W"| "Worcester"| MA
   43|   37|   48| "N"|     89|   46|   11| "W"| "Wisconsin Dells"| WI
   36|    5|   59| "N"|     80|   15|    0| "W"| "Winston-Salem"| NC
   49|   52|   48| "N"|     97|    9|    0| "W"| "Winnipeg"| MB
   39|   11|   23| "N"|     78|    9|   36| "W"| "Winchester"| VA
   34|   14|   24| "N"|     77|   55|   11| "W"| "Wilmington"| NC
   39|   45|    0| "N"|     75|   33|    0| "W"| "Wilmington"| DE
```

{% endraw %}
