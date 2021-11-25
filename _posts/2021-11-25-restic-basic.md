---
title: restic Basic

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - restic 
  - snapshot backup
  - minio
  - rclone
---

Snapshots 기능을 제공하는 modern backup program

{% raw %}


## restic
- <https://restic.net/>{:target="_blank"}
- Go로 만들어진 백업 프로그램, 크로스프랫폼 지원

```
- from Linux, BSD, Mac and Windows
- to many different storage types, including self-hosted and online services
- easily, being a single executable that you can run without a server or complex setup
- effectively, only transferring the parts that actually changed in the files you back up
- securely, by careful use of cryptography in every part of the process
- verifiably, enabling you to make sure that your files can be restored when needed
- freely - restic is entirely free to use and completely open source
```

### Install 
- Package 설치 및 Binary 지원 
  - Package : <https://restic.readthedocs.io/en/stable/020_installation.html>{:target="_blank"}
  - Binary : <https://github.com/restic/restic/releases/tag/v0.12.1>{:target="_blank"}

```sh
$ curl -LO https://github.com/restic/restic/releases/download/v0.12.1/restic_0.12.1_linux_amd64.bz2

# install bzip2
$ sudo yum install bzip2 -y

$ bunzip2 restic_0.12.1_linux_amd64.bz2
$ mv restic_0.12.1_linux_amd64 restic
$ sudo mv restic /usr/local/bin
```

```sh
$ restic

restic is a backup program which allows saving multiple revisions of files and
directories in an encrypted repository stored on different backends.

Usage:
  restic [command]

Available Commands:
  backup        Create a new backup of files and/or directories
  cache         Operate on local cache directories
  cat           Print internal objects to stdout
  check         Check the repository for errors
  copy          Copy snapshots from one repository to another
  diff          Show differences between two snapshots
  dump          Print a backed-up file to stdout
  find          Find a file, a directory or restic IDs
  forget        Remove snapshots from the repository
  generate      Generate manual pages and auto-completion files (bash, fish, zsh)
  help          Help about any command
  init          Initialize a new repository
  key           Manage keys (passwords)
  list          List objects in the repository
  ls            List files in a snapshot
  migrate       Apply migrations
  mount         Mount the repository
  prune         Remove unneeded data from the repository
  rebuild-index Build a new index
  recover       Recover data from the repository
  restore       Extract the data from a snapshot
  self-update   Update the restic binary
  snapshots     List all snapshots
  stats         Scan the repository and show basic statistics
  tag           Modify tags on snapshots
  unlock        Remove locks other processes created
  version       Print version information
....
```

---

### Backup & Restore 

##### Backup Repository 생성

```sh
# Repository 접근을 위한 패드워스 필요, 일단 1111
# -r, --repo repository repository to backup to or restore from (default: $RESTIC_REPOSITORY)
$ restic init -r repo
enter password for new repository:
enter password again:
created restic repository 7f3cfb3e9a at repo

Please note that knowledge of your password is required to access
the repository. Losing your password means that your data is
irrecoverably lost.

# password 파일 생성, -p 옵션으로 지정 
$ echo 1111 > passwd
```

##### Backup : snapshots 생성

```sh
# Backup 
# restic -r <repository> -p <passwd file> backup <Source>
# -p, --password-file file  file to read the repository password from (default: $RESTIC_PASSWORD_FILE)
$ restic -r repo -p passwd backup /home/cdecl/temp/mvcapp
repository e4ccc49d opened successfully, password is correct
no parent snapshot found, will read all files

Files:          79 new,     0 changed,     0 unmodified
Dirs:           40 new,     0 changed,     0 unmodified
Added to the repo: 4.854 MiB

processed 79 files, 4.811 MiB in 0:00
snapshot 9aff8447 saved

# 파일생성 및 다시백업 
$ touch /home/cdecl/temp/mvcapp/test.txt

$ restic -r repo -p passwd backup /home/cdecl/temp/mvcapp
repository e4ccc49d opened successfully, password is correct
using parent snapshot 9aff8447

Files:           1 new,     0 changed,    79 unmodified
Dirs:            0 new,     4 changed,    36 unmodified
Added to the repo: 7.742 KiB

processed 80 files, 4.811 MiB in 0:00
snapshot f4b94d9b saved

```

##### Snapshots 확인

```sh
# snapshots 2개 화인 확인
$ restic -r repo -p passwd snapshots
repository e4ccc49d opened successfully, password is correct
ID        Time                 Host        Tags        Paths
------------------------------------------------------------------------------
9aff8447  2021-11-25 15:17:52  centos1                 /home/cdecl/temp/mvcapp
f4b94d9b  2021-11-25 15:22:24  centos1                 /home/cdecl/temp/mvcapp
------------------------------------------------------------------------------
2 snapshots
```

- Snapshots 비교
  
```sh
$ restic -r repo -p passwd diff 9aff8447 f4b94d9b
repository e4ccc49d opened successfully, password is correct
comparing snapshot 9aff8447 to f4b94d9b:

+    /home/cdecl/temp/mvcapp/test.txt

Files:           1 new,     0 removed,     0 changed
Dirs:            0 new,     0 removed
Others:          0 new,     0 removed
Data Blobs:      0 new,     0 removed
Tree Blobs:      5 new,     5 removed
  Added:   7.742 KiB
  Removed: 7.456 KiB
```

##### Restore : Snapshots 에서 복원

```sh
# restic -r <repository> -p <passwd file> restore <snapshots id> -t <Target>
$ restic -r repo -p passwd restore 9aff8447 -t restore-mvcapp
repository e4ccc49d opened successfully, password is correct
restoring <Snapshot 9aff8447 of [/home/cdecl/temp/mvcapp] at 2021-11-25 15:17:52.115925352 
 +0900 KST by cdecl@centos1> to restore-mvcapp
```

### MinIO & RClone Backend 지원
- <https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html>{:target="_blank"}

```
Local, SFTP, REST Server, Amazon S3, Minio Server, Microsoft Azure Blob Storage, 
Google Cloud Storage, Other Services via rclone 등 지원
```


##### MinIO Repository 만들기 

```sh
$ export AWS_ACCESS_KEY_ID=key
$ export AWS_SECRET_ACCESS_KEY=passwd

$  restic init -r s3:http://minio.server:9000/restic
enter password for new repository:
enter password again:
created restic repository 65a27250da at s3:http://minio.server:9000/restic

Please note that knowledge of your password is required to access
the repository. Losing your password means that your data is
irrecoverably lost.


# Backup
$ restic -r s3:http://minio.server:9000/restic -p passwd backup /home/cdecl/temp/mvcapp

# snapshots
$ restic -r s3:http://minio.server:9000/restic -p passwd snapshots
repository 65a27250 opened successfully, password is correct
ID        Time                 Host        Tags        Paths
------------------------------------------------------------------------------
73d37fbd  2021-11-25 15:37:34  centos1                 /home/cdecl/temp/mvcapp
------------------------------------------------------------------------------
1 snapshots
```

##### RClone Backend 로 사용 

```sh
$ rclone config show
[infradb]
type = s3
env_auth = false
access_key_id = key
secret_access_key = passwd
region = us-east-1
endpoint = http://minio.server:9000

# rclone config 사용 respository 만들기 
$ restic init -r rclone:infradb:restic
enter password for new repository:
enter password again:
created restic repository ce850667c9 at rclone:infradb:restic

Please note that knowledge of your password is required to access
the repository. Losing your password means that your data is
irrecoverably lost.

# Backup
$ restic -r rclone:infradb:restic -p passwd backup /home/cdecl/temp/mvcapp

# snapshots
$ restic -r rclone:infradb:restic -p passwd snapshots
```

---

#### Snapshots 관리
- <https://restic.readthedocs.io/en/stable/060_forget.html>{:target="_blank"}
  
```sh
$ restic -r rclone:infradb:restic -p passwd snapshots
repository ce850667 opened successfully, password is correct
ID        Time                 Host        Tags        Paths
------------------------------------------------------------------------------
a3737738  2021-11-25 15:44:05  centos1                 /home/cdecl/temp/mvcapp
00f16d70  2021-11-25 15:44:50  centos1                 /home/cdecl/temp/mvcapp
0e83568a  2021-11-25 15:44:51  centos1                 /home/cdecl/temp/mvcapp
4041e3ca  2021-11-25 15:44:53  centos1                 /home/cdecl/temp/mvcapp
eb1e56c7  2021-11-25 15:44:54  centos1                 /home/cdecl/temp/mvcapp
d81b3d2a  2021-11-25 15:44:55  centos1                 /home/cdecl/temp/mvcapp
------------------------------------------------------------------------------
6 snapshots

# snapshots 1개 지우기
$ restic -r rclone:infradb:restic -p passwd forget d81b3d2a
repository ce850667 opened successfully, password is correct
[0:00] 100.00%  1 / 1 files deleted

# 스냅샷의 파일에서 참조한 데이터는 여전히 저장소에 저장
# 참조되지 않은 데이터를 정리하려면 prune 명령 실행
$ restic -r rclone:infradb:restic -p passwd prune
repository ce850667 opened successfully, password is correct
loading indexes...
loading all snapshots...
finding data that is still in use for 5 snapshots
[0:00] 100.00%  5 / 5 snapshots
searching used packs...
collecting packs for deletion and repacking
[0:00] 100.00%  9 / 9 packs processed

to repack:            0 blobs / 0 B
this removes          0 blobs / 0 B
to delete:            2 blobs / 1004 B
total prune:          2 blobs / 1004 B
remaining:          125 blobs / 4.862 MiB
unused size after prune: 0 B (0.00% of remaining size)

rebuilding index
[0:00] 100.00%  8 / 8 packs processed
deleting obsolete index files
[0:00] 100.00%  6 / 6 files deleted
removing 1 old packs
[0:00] 100.00%  1 / 1 files deleted
done

# 최근 1개만 놔두고 snapshots 삭제 및 prune
$ restic -r rclone:infradb:restic -p passwd forget --keep-last 1 --prune
repository ce850667 opened successfully, password is correct
Applying Policy: keep 1 latest snapshots
keep 1 snapshots:
ID        Time                 Host        Tags        Reasons        Paths
---------------------------------------------------------------------------------------------
eb1e56c7  2021-11-25 15:44:54  centos1                 last snapshot  /home/cdecl/temp/mvcapp
---------------------------------------------------------------------------------------------
1 snapshots

remove 4 snapshots:
ID        Time                 Host        Tags        Paths
------------------------------------------------------------------------------
a3737738  2021-11-25 15:44:05  centos1                 /home/cdecl/temp/mvcapp
00f16d70  2021-11-25 15:44:50  centos1                 /home/cdecl/temp/mvcapp
0e83568a  2021-11-25 15:44:51  centos1                 /home/cdecl/temp/mvcapp
4041e3ca  2021-11-25 15:44:53  centos1                 /home/cdecl/temp/mvcapp
------------------------------------------------------------------------------
4 snapshots

[0:00] 100.00%  4 / 4 files deleted
4 snapshots have been removed, running prune
loading indexes...
loading all snapshots...
finding data that is still in use for 1 snapshots
[0:00] 100.00%  1 / 1 snapshots
searching used packs...
collecting packs for deletion and repacking
[0:00] 100.00%  8 / 8 packs processed

to repack:           39 blobs / 47.305 KiB
this removes          2 blobs / 1007 B
to delete:            6 blobs / 2.950 KiB
total prune:          8 blobs / 3.934 KiB
remaining:          117 blobs / 4.858 MiB
unused size after prune: 0 B (0.00% of remaining size)

repacking packs
[0:00] 100.00%  2 / 2 packs repacked
rebuilding index
[0:00] 100.00%  5 / 5 packs processed
deleting obsolete index files
[0:00] 100.00%  1 / 1 files deleted
removing 5 old packs
[0:00] 100.00%  5 / 5 files deleted
done

# snapshots 확인
$ restic -r rclone:infradb:restic -p passwd snapshots
repository ce850667 opened successfully, password is correct
ID        Time                 Host        Tags        Paths
------------------------------------------------------------------------------
eb1e56c7  2021-11-25 15:44:54  centos1                 /home/cdecl/temp/mvcapp
------------------------------------------------------------------------------
1 snapshots
```


- forget 주요 인수 

```
--keep-last n never delete the n last (most recent) snapshots
--keep-hourly n for the last n hours in which a snapshot was made, keep only the last snapshot for each hour.
--keep-daily n for the last n days which have one or more snapshots, only keep the last one for that day.
--keep-weekly n for the last n weeks which have one or more snapshots, only keep the last one for that week.
--keep-monthly n for the last n months which have one or more snapshots, only keep the last one for that month.
--keep-yearly n for the last n years which have one or more snapshots, only keep the last one for that year.
--keep-tag keep all snapshots which have all tags specified by this option (can be specified multiple times).
```



{% endraw %}
