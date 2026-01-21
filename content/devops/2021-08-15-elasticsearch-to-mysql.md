---
title: ElasticSearch to MySQL ETL
tags:
  - elasticsearch
  - mysql
  - mysql-shell
  - jq
---
ElasticSearch to MySQL ETL

## 준비
- `curl` : Http 기반 ElasticSearch Query (SQL)
- `jq` : ElasticSearch 결과 JSON 변환 (NDJSON)
-  `mysql-shell` : MySQL 데이터 Bulk Insert (Json 타입의 Table)

### ElasticSearch Query  `curl`
- 쿼리 후, 해당 내용 JSON 저장 

```bash
$ curl -s -XPOST -H 'content-type: application/json' \
	-d '{"query" : "select timestamp, activesession, loadavg, processor from \"mysql-perf-*\" limit 100"}' \
	'http://elasticsearch-server:7200/_sql' > result.json

$ cat result.json | jq .
{
  "columns": [
    {
      "name": "timestamp",
      "type": "datetime"
    },
    {
      "name": "activesession",
      "type": "long"
    },
    {
      "name": "loadavg",
      "type": "float"
    },
    {
      "name": "processor",
      "type": "float"
    }
  ],
  "rows": [
    [
      "2021-05-02T03:40:47.000Z",
      2,
      0.019999999552965164,
      0
    ],
    [
      "2021-06-01T00:04:24.000Z",
      4,
      2.0399999618530273,
      14.579999923706055
    ],
	...
```


### NDJSON 형태로 변환 `jq`
- `-c` : compact instead of pretty-printed output

```bash
$ cat result.json | \
        jq -c ' { "col": [.columns[] | .name], "row" : .rows[] }
        | [.col, .row]
        | transpose
        | map({ (.[0]): .[1] })
        | add ' > result_t.json

$ cat result_t.json | jq .
{
  "timestamp": "2021-05-02T03:40:47.000Z",
  "activesession": 2,
  "loadavg": 0.019999999552965164,
  "processor": 0
}
{
  "timestamp": "2021-06-22T05:25:24.000Z",
  "activesession": 3,
  "loadavg": 1.809999942779541,
  "processor": 4.599999904632568
}
{
  "timestamp": "2021-07-01T00:04:21.000Z",
  "activesession": 1,
  "loadavg": 0.2800000011920929,
  "processor": 0.41999998688697815
```

### MySQL JSON Import `mysql-shell`
- 테이블내 `doc json` 필드 생성 및 JSON 데이터 Row 단위 적재 

```sh
# truncate table
$ mysqlsh --sql user@mysql-server:3360/dbname -p<PASSWD> \
	--execute 'truncate table data_table ;'

# import 
$ mysqlsh --mysqlx user@mysql-server:3360/dbname -p<PASSWD> \
	--import result_t.json --collection=data_table 
```

![](/images/2021-08-17-09-42-43.png)  

![](/images/2021-08-17-09-41-38.png)