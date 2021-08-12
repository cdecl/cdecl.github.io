---
title: SQLAlchemy Query Basic (w/Flask)

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - python
  - sqlalchemy
  - flask
---


Flask 에서 SQLAlchemy 사용시 Query 팁 

## Configure 

### Connection

```py
# MySQL
app.config['SQLALCHEMY_DATABASE_URI'] = r'mysql+pymysql://user:passwd@address:3306/db_name?charset=UTF8MB4'
db = SQLAlchemy()
db.init_app(app)
```

### Bind 추가 
추가적인 DB 정보 추가 

```py
app.config['SQLALCHEMY_BINDS'] = { 
    'dbms1': r'mysql+pymysql://user:passwd@address1:3306/db_name?charset=UTF8MB4',
    'dbms2': r'mysql+pymysql://user:passwd@address2:3306/db_name?charset=UTF8MB4'
}

# Model Example
class Network(db.Model):
    __tablename__ = 'network'
    __bind_key__ = 'dbms1'

    ip = db.Column(db.String(128), primary_key=True)
    switch = db.Column(db.String(128))
    doc = db.Column(db.JSON)
```

### AlchemyEncoder
SQLAlchemy Json Encoder

```py
class AlchemyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj.__class__, DeclarativeMeta):
            # an SQLAlchemy class
            fields = {}
            for field in [x for x in dir(obj) if not x.startswith('_') and x != 'metadata']:
                data = obj.__getattribute__(field)
                try:
                    json.dumps(data) # this will fail on non-encodable values, like other classes
                    fields[field] = data
                except TypeError:
                    if isinstance(data, datetime):
                        fields[field] = data.strftime('%Y-%m-%d %H:%M:%S')
                    elif isinstance(data, date):
                        fields[field] = data.strftime('%Y-%m-%d')
                    else:
                        fields[field] = None
            return fields
        return json.JSONEncoder.default(self, obj)
```

### Flask Basic Route 

```py
@app.route('/api/network/')
def api_network():
    cur = db.session.query(Network)
    return json.dumps({ 'data': cur.all() }, cls=AlchemyEncoder)
```

### DB Model Generate

```sh
# All
$ ./venv/bin/flask-sqlacodegen 'mysql+pymysql://user:passwd@address2:3306/db_name' --flask

# 테이블 지정
$ ./venv/bin/flask-sqlacodegen 'mysql+pymysql://user:passwd@address2:3306/db_name' --flask --table network,other_table
```

## Query Sample 

### Select All

```py
cur = db.session.query(Network)
```

### Select Filter, Sort 

```py
# Filter 
cur = db.session.query(network).filter(network.switch == switch_name)
cur = db.session.query(network).filter(network.ip.like('{}%'.format(ip)))
cur = db.session.query(network).filter(network.switch.in_(('AA', 'BB')))

# Text filter, json
cur = db.session.query(network).filter(text(r'''doc->>"$.name" <> '' '''))

# OR
cur = db.session.query(network).filter(or_(network.ip == ip, network.switch == switch_name))

# AND
cur = db.session.query(network).filter(and_(network.ip == ip, network.switch == switch_name))

# SORT
cur = db.session.query(network).filter(network.switch == switch_name) \
        .order_by(network.ip.desc())
```

### Join

```py

# Join 
cur = db.session.query(Network, NetworkSwitch) \
        .filter(Network.ip == NetworkSwitch.ip, Network.switch == NetworkSwitch.switch)

# Outer Join
cur = db.session.query(Network) \
        .outerjoin(NetworkSwitch, and_(Network.ip == NetworkSwitch.ip, Network.switch == NetworkSwitch.switch)) 


# Self Join, Table Alias  
NetworkAlias = aliased(Network)
cur = db.session.query(Network, NetworkAlias) \
        .filter(Network.ip == NetworkAlias.ip, Network.switch == NetworkAlias.switch)
```