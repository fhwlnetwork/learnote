

``` text
redis集群方案有哨兵和集群，但可惜的是filebeat和logstash都不支持这两种方案。

解决方案如下：
1.使用nginx+keepalived反向代理负载均衡到后面的多台redis
2.考虑到redis故障切换中数据一致性的问题，所以最好我们只使用2台redis,并且只工作一台，另外一台作为backup，只有第一台坏掉后，第二台才会工作。
3.filebeat的oputut的redis地址为keepalived的虚拟I
4.logstash可以启动多个节点来加速读取redis的数据
5.后端可以采用多台es集群来做支撑

```

![图谱架构图](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/keepalived_nginx_redis20210506203308.png)

## redis安装配置：[redis安装](../redis/安装.md)

## keepalived安装配置

``` shell
#db01 db02上分别安装
[root@db02 /opt/kafka]# yum -y install keepalived
#配置主
[root@db01 ~]# cat >/etc/keepalived/keepalived.conf<<EOF
! Configuration File for keepalived
global_defs {
    router_id db01
}
vrrp_instance VI_1 {
    state MASTER
        interface eth0
        virtual_router_id 50
        priority 150
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 1111
        }
        virtual_ipaddress {
            10.0.0.3
        }
}
EOF 
#配置从
[root@db02 /opt/kafka]# cat > /etc/keepalived/keepalived.conf<<EOF 
! Configuration File for keepalived
global_defs {
    router_id db02
}
vrrp_instance VI_1 {
    state BACKUP
        interface eth0
        virtual_router_id 50
        priority 100
        advert_int 1
        authentication {
        auth_type PASS
        auth_pass 1111
        }
    virtual_ipaddress {
        10.0.0.3
    }
}
EOF

#启动服务
[root@db01 ~]# systemctl start keepalived
[root@db02 ~]# systemctl start keepalived


```

## nginx反向代理配置
```shell
#在  /etc/nginx/nginx.conf 最后添加不能加到conf.d里面添加子配置
stream {
  upstream redis {
      server 10.0.0.52:6379 max_fails=2 fail_timeout=10s;
      server 10.0.0.53:6379 max_fails=2 fail_timeout=10s backup;
  }

  server {
          listen 6379;
          proxy_connect_timeout 1s;
          proxy_timeout 3s;
          proxy_pass redis; 
  }
}

```

### filbeat 配置
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
  hosts: ["10.0.0.3"]
  key: "filebeat"
EOF

```

### logstach 配置
``` shell
cat >/etc/logstash/conf.d/redis.conf<<EOF
input {
  redis {
    host => "10.0.0.3"
    port => "6379"
    db => "0"
    key => "filebeat"
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
[root@db01 ~]# systemctl restart filebeat

[root@db01]# /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/redis.conf
```