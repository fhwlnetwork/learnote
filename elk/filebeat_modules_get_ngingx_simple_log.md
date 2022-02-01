# filebeat模块收集ngingx普通日志
![图示](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210429220514.png)

## 第一步
``` shell
#查看filebeat文件
[root@db01 /data/soft]# rpm -qc filebeat 
/etc/filebeat/filebeat.yml
/etc/filebeat/modules.d/apache2.yml.disabled
/etc/filebeat/modules.d/auditd.yml.disabled
/etc/filebeat/modules.d/elasticsearch.yml.disabled
/etc/filebeat/modules.d/haproxy.yml.disabled
/etc/filebeat/modules.d/icinga.yml.disabled
/etc/filebeat/modules.d/iis.yml.disabled
/etc/filebeat/modules.d/kafka.yml.disabled
/etc/filebeat/modules.d/kibana.yml.disabled
/etc/filebeat/modules.d/logstash.yml.disabled
/etc/filebeat/modules.d/mongodb.yml.disabled
/etc/filebeat/modules.d/mysql.yml.disabled
/etc/filebeat/modules.d/nginx.yml.disabled
/etc/filebeat/modules.d/osquery.yml.disabled
/etc/filebeat/modules.d/postgresql.yml.disabled
/etc/filebeat/modules.d/redis.yml.disabled
/etc/filebeat/modules.d/suricata.yml.disabled
/etc/filebeat/modules.d/system.yml.disabled
/etc/filebeat/modules.d/traefik.yml.disabled


#查询模板
filebeat modules list
#激活模块
filebeat moudles enable nginx
#配置nginx.yml文件配置
[root@db01 /data/soft]# vim /etc/filebeat/modules.d/nginx.yml
- module: nginx
  # Access logs
  access:
    enabled: true
    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    var.paths: ["/var/log/nginx/access.log"]
  # Error logs
  error:
    enabled: true
    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    #var.paths:
    var.paths: ["/var/log/nginx/error.log"]

#配置filebeat modules
#============================= Filebeat modules ===============================
#
filebeat.config.modules:
#  # Glob pattern for configuration loading
    path: ${path.config}/modules.d/*.yml
    reload.enabled: false
    reload.period: 10s

output.elasticsearch:
  hosts: ["10.0.0.51:9200"]
~     
~                                                
```

## 第二步

```shell
#重启服务
[root@db01 /data/soft]# systemctl restart filebeat.service

#查看日志报错
2021-04-29T21:49:12.254+0800	ERROR	fileset/factory.go:142	Error loading pipeline: Error loading pipeline for fileset nginx/access: This module requires the following Elasticsearch plugins: ingest-user-agent, ingest-geoip. You can install them by running the following commands on all the Elasticsearch nodes:
    sudo bin/elasticsearch-plugin install ingest-user-agent
    sudo bin/elasticsearch-plugin install ingest-geoip
#安装插件
[root@db01 /data/soft]# /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-user-agent
-> Downloading ingest-user-agent from elastic
[=================================================] 100%   
-> Installed ingest-user-agent

[root@db01 /data/soft]# /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip
-> Downloading ingest-geoip from elastic
[=================================================] 100%   
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@     WARNING: plugin requires additional permissions     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
* java.lang.RuntimePermission accessDeclaredMembers
* java.lang.reflect.ReflectPermission suppressAccessChecks
See http://docs.oracle.com/javase/8/docs/technotes/guides/security/permissions.html
for descriptions of what these permissions allow and the associated risks.

Continue with installation? [y/N]y
-> Installed ingest-geoip



#查看elasticsearch-plugin命令目录
[root@db01 /data/soft]# rpm -ql elasticsearch |grep elasticsearch-plugin
/usr/share/elasticsearch/bin/elasticsearch-plugin
/usr/share/elasticsearch/lib/tools/plugin-cli/elasticsearch-plugin-cli-6.6.0.jar


```

## 第三步
```shell
## 配置etc/filebeat/filebeat.yml
[root@db01 /var/log/nginx]# cat >/etc/filebeat/filebeat.yml <<EOF
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: true 
  reload.period: 10s

setup.kibana:
  host: "10.0.0.51:5601"
  
output.elasticsearch:
  hosts: ["10.0.0.51:9200"]
  indices:
  - index: "nginx-access-%{[beat.version]}-%{+yyyy.MM}"
    when.contains:
      fileset.name: "access"

  - index: "nginx-error-%{[beat.version]}-%{+yyyy.MM}"
    when.contains:
      fileset.name: "error"

setup.template.name: "nginx"
setup.template.pattern: "nginx-*"
setup.template.enabled: false
setup.template.overwrite: true
EOF

```