---
title: Ansible dynamic inventory - AWS EC2

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - ansible
  - aws
  - ec2
  - aws_ec2
  - boto3
---

Ansible `aws_ec2` plugin 활용, AWS EC2 동적 Inventory 구성 

{% raw %}

## Ansible plugin : `aws_ec2`
- <https://docs.ansible.com/ansible/2.9/plugins/inventory/aws_ec2.html>{:target="_blank"}
- Get inventory hosts from Amazon Web Services EC2

### Requirements
- python package : boto3, botocore
- YAML 설정 파일 이름이 `aws_ec2.(yml|yaml)` 로 끝나야 함

```sh
$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/cdecl/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Jun  2 2021, 10:49:15) [GCC 9.4.0]


# install boto3, botocore
$ pip3 install boto3
```

---

### 기본설정 

##### aws_ec2.yaml
- plugin : 프러그인 이름, 필수
- regions : 지정하면 더 빠른 조회

```yaml
plugin: aws_ec2
regions:
  - ap-northeast-2

# .aws/credendial 파일이 없으면 
aws_access_key_id: AKIA3**************
aws_secret_access_key: 1oxRajyBX**********************
```

#####  ~/.aws/credentials

```toml
[default]
aws_access_key_id = AKIA3**************
aws_secret_access_key = 1oxRajyBX**********************
```

#### Inventory 확인
- 기본 `aws_ec2` 그룹으로 생성 
  
```sh
# json 형태로 ec2 node 정보 및 group 정보 리스트 
$ ansible-inventory -i aws_ec2.yaml --list
...
    "all": {
        "children": [
            "aws_ec2",
            "ungrouped"
        ]
    },
    "aws_ec2": {
        "hosts": [
            "ip-10-211-20-159.ap-northeast-2.compute.internal",
            "ip-10-211-20-229.ap-northeast-2.compute.internal",
            "ip-10-211-20-45.ap-northeast-2.compute.internal"
        ]
    }
}

# inventory 정보를 그래프 형태로 표시
$ ansible-inventory -i aws_ec2.yaml --graph
@all:
  |--@aws_ec2:
  |  |--ip-10-211-20-159.ap-northeast-2.compute.internal
  |  |--ip-10-211-20-229.ap-northeast-2.compute.internal
  |  |--ip-10-211-20-45.ap-northeast-2.compute.inte

# ansible 명령으로 확인
$ ansible -i aws_ec2.yaml --list-hosts all
  hosts (3):
    ip-10-211-20-229.ap-northeast-2.compute.internal
    ip-10-211-20-159.ap-northeast-2.compute.internal
    ip-10-211-20-45.ap-northeast-2.compute.internal
```


#### 필터 및 그룹화
- 예제 : <https://docs.ansible.com/ansible/2.9/plugins/inventory/aws_ec2.html#examples>{:target="_blank"}
- filters : 필터로 원하는 항목만 가져옴 
  - AWS CLI 명령 describe-instances --filters 항목 참고 
  - <https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html#options>{:target="_blank"}
- keyed_groups : Inventory 그룹화 항목 

```yaml
plugin: aws_ec2
regions:
  - ap-northeast-2

filters:
  # tag 정보가 AutoDelete:False 인 인스턴스 
  tag:AutoDelete: "False"
  # running 상태 인스턴스
  instance-state-name: 'running'

keyed_groups:
  # tag 를 기준으로 그룹화, "prefix_key_value" 형식의 그룹이름 
  - prefix: tag
    key: tags
```

```sh
# tag 로 그룹화 
$ ansible-inventory -i aws_ec2.yaml --graph
@all:
  |--@aws_ec2:
  |  |--ip-10-211-20-159.ap-northeast-2.compute.internal
  |  |--ip-10-211-20-229.ap-northeast-2.compute.internal
  |  |--ip-10-211-20-45.ap-northeast-2.compute.internal
  |--@tag_AutoDelete_False:
  |  |--ip-10-211-20-159.ap-northeast-2.compute.internal
  |  |--ip-10-211-20-229.ap-northeast-2.compute.internal
  |  |--ip-10-211-20-45.ap-northeast-2.compute.internal
...
  |--@tag_Name_kube01:
  |  |--ip-10-211-20-45.ap-northeast-2.compute.internal
  |--@tag_Name_kube02:
  |  |--ip-10-211-20-159.ap-northeast-2.compute.internal
  |--@tag_Name_kube03:
  |  |--ip-10-211-20-229.ap-northeast-2.compute.internal
  |--@ungrouped:


# ansible 명령으로 확인
$ ansible -i aws_ec2.yaml tag_AutoDelete_False --list-hosts
  hosts (3):
    ip-10-211-20-229.ap-northeast-2.compute.internal
    ip-10-211-20-159.ap-northeast-2.compute.internal
    ip-10-211-20-45.ap-northeast-2.compute.internal

$ ansible -i aws_ec2.yaml tag_Name_kube01 --list-hosts
  hosts (1):
    ip-10-211-20-45.ap-northeast-2.compute.internal
```

---

#### Host 연결을 위한 inventory parameters 추가 
- multiple inventory로 정보 추가 
- <https://docs.ansible.com/ansible/2.9/user_guide/intro_inventory.html#connecting-to-hosts-behavioral-inventory-parameters>{:target="_blank"}


```toml
# aws.host
[win:children]
tag_AutoDelete_False

[win:vars]
ansible_user=rundeck
ansible_password=<passowrd>
ansible_connection=winrm
ansible_port=5985
```

```sh
$ ansible-inventory -i aws_ec2.yaml -i aws.host --vars --list
{
    "_meta": {
        "hostvars": {
            "ip-10-211-20-159.ap-northeast-2.compute.internal": {
                "ami_launch_index": 1,
                "ansible_connection": "winrm",
                "ansible_password": "<passowrd>",
                "ansible_port": 5985,
                "ansible_user": "ansible",
                "architecture": "x86_64",
...
```

---

#### `ansible-inventory --list` 옵션으로 hosts 파일 형식 구성 

```sh
$ ansible-inventory -i aws_ec2.yaml --list | jq -r '._meta.hostvars[] | "\(.private_ip_address) \(.tags.Name) "'
10.211.20.159 kube02
10.211.20.229 kube03
10.211.20.45 kube01
```

---

#### Ansible EC2 Dynamic inventory minimum IAM policies
- <https://stackoverflow.com/questions/30519470/ansible-ec2-dynamic-inventory-minimum-iam-policies>{:target="_blank"}

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Demo201505282045",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": "*"
        }
    ]
}
```


{% endraw %}
