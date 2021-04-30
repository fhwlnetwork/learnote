# redis作为缓存收集日志

## 方式一
![结构](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210430150710.png)

### 安装logstash
```shell
[root@db01 /data/soft]#rpm -ivh logstash-6.6.0.rpm 
warning: logstash-6.6.0.rpm: Header V4 RSA/SHA512 Signature, key ID d88e42b4: NOKEY
Preparing...                          
################################# [100%]
Updating / installing...
   1:logstash-1:6.6.0-1               ################################# [100%]
Using provided startup.options file: /etc/logstash/startup.options
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
Successfully created system startup script for Logstash

```

###  配置filebeat写入到不同的key中
``` shell
[root@db01 /data/soft]#cat >/etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
  json.keys_undr_root: true
  json.overwrite_keys: true
  tags: ["access"]
- type: log
  enabled: true
  paths:
    - /var/log/nginx/error.log
  tags: ["error"]
setup.kibana:
  hosts: 10.0.0.51:5601
output.redis:
  hostst: ["localhost"]
  keys: 
    - key: "nginx_access"
      when.contains:
        tags: "access"
    - key: "nginx_error"
      when.contains:
        tags: "error"
EOF
```

###  6.1.6 logstash根据tag区分一个key里的不同日志
``` shell

[root@db01 /data/soft]#cat >/etc/logstash/conf.d/redis.conf<<EOF
input {
  redis {
    host => "127.0.0.1"
    port => "6379"
    db => "0"
    key => "nginx_access"
    data_type => "list"
  }
  redis {
    host => "127.0.0.1"
    port => "6379"
    db => "0"
    key => "nginx_error"
    data_type => "list"
  }
}

filter {
  mutate {
    convert => ["upstream_time", "float"]
    convert => ["request_time", "float"]
  }
}

output {
    stdout {}
    if "access" in [tags] {
      elasticsearch {
        hosts => "http://localhost:9200"
        manage_template => false
        index => "nginx_access-%{+yyyy.MM.dd}"
      }
    }
    if "error" in [tags] {
      elasticsearch {
        hosts => "http://localhost:9200"
        manage_template => false
        index => "nginx_error-%{+yyyy.MM.dd}"
      }
    }
}
EOF

#启动服务
[root@db01 /data/soft]#/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/redis.conf 

```

## 方式二

### filebeat收集日志写入到一个key中

```shell 
[root@db01 /data/soft]#cat > /etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
  json.keys_undr_root: true
  json.overwrite_keys: true
  tags: ["access"]
- type: log
  enabled: true
  paths:
    - /var/log/nginx/error.log
  tags: ["error"]
setup.kibana:
  hosts: 10.0.0.51:5601
output.redis:
  hosts: ["localhost"]
  key: "filebeat"
EOF

```

### logstash根据tag区分一个key里的不同日志

``` shell
[root@db01 /data/soft]#cat >/etc/logstash/conf.d/redis.conf <<EOF
input {
  redis {
    host => "127.0.0.1"
    port => "6379"
    db => "0"
    key => "nginx_access"
    data_type => "list"
  }
  redis {
    host => "127.0.0.1"
    port => "6379"
    db => "0"
    key => "nginx_error"
    data_type => "list"
  }
}

filter {
  mutate {
    convert => ["upstream_time", "float"]
    convert => ["request_time", "float"]
  }
}

output {
    stdout {}
    if "access" in [tags] {
      elasticsearch {
        hosts => "http://localhost:9200"
        manage_template => false
        index => "nginx_access-%{+yyyy.MM.dd}"
      }
    }
    if "error" in [tags] {
      elasticsearch {
        hosts => "http://localhost:9200"
        manage_template => false
        index => "nginx_error-%{+yyyy.MM.dd}"
      }
    }
}
EOF

```
### 重启服务
``` shell
[root@db01 /data/soft]#systemctl restart filebeat.service 

[root@db01 /data/soft]#/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/redis.conf 
```