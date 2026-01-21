---
title: trino(presto) nested json 예제
tags:
  - presto
  - trino
  - json
  - ddl
---
trino(presto) nested json 를 처리하기 위한 table schema 예제



## trino(presto) - create table 
- row : json object (nested json) 타입을 위한 sub column 정의 
- array : 배열

### Example 

```json
{"id":1,"name":"Alice"}
{"id":2,"name":"Bob"}
{"id":3,"name":"Carol"}
{"id":4,"name":"David", "etc1": [{"key": "key-data11"}, {"key": "key-data22"}] }
{"id":5,"name":"Elise", "etc2": ["data1", "data2", "data3"]}
```

```sql
create table hive.default.sample (
	id varchar,
	name varchar,
	etc1 array(row(key varchar)),
	etc2 array(varchar)
)
with (
	format = 'json',
	external_location = 's3a://data/sample/'
)
```

---

### trino cli
```sh
trino> use hive.default;
USE
trino:default> select * from sample;
 id | name  |                 etc1                 |         etc2
----+-------+--------------------------------------+-----------------------
 1  | Alice | NULL                                 | NULL
 2  | Bob   | NULL                                 | NULL
 3  | Carol | NULL                                 | NULL
 4  | David | [{key=key-data11}, {key=key-data22}] | NULL
 5  | Elise | NULL                                 | [data1, data2, data3]
(5 rows)

Query 20220824_000627_00008_qpvtj, FINISHED, 1 node
Splits: 1 total, 1 done (100.00%)
0.27 [5 rows, 212B] [18 rows/s, 777B/s]
```


