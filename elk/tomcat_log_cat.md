# tomcat日志收集
## 安装tomcat
```shell
[root@db01 ~]# yum install tomcat tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc -y

```

## 启动服务
```shell
[root@db01 ~]# systemctl start tomcat

```
## 验证服务
![查看页面](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426232140.png)

## 配置tomacat日志格式为json
``` shell 
[root@db01 ~]# vim /etc/tomcat/server.xml
[root@db01 ~]# cat -n /etc/tomcat/server.xml
----------------
   137          <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
   138                 prefix="localhost_access_log." suffix=".txt"
   139                 pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;ClientUser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;AccessTime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;SendBytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;AgentVersion&quot;:&quot;%{User-Agent}i&quot;}"/>
----------------

```
## 重启确认日志是否为json格式
``` shell
[root@db01 ~]# systemctl restart tomcat
[root@db01 ~]# tail -f /var/log/tomcat/localhost_access_log.2021-04-26.txt

{"clientip":"10.0.0.1","ClientUser":"-","authenticated":"-","AccessTime":"[26/Apr/2021:23:35:07 +0800]","method":"GET / HTTP/1.1","status":"200","SendBytes":"11217","Query?string":"","partner":"-","AgentVersion":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36"}
{"clientip":"10.0.0.1","ClientUser":"-","authenticated":"-","AccessTime":"[26/Apr/2021:23:35:07 +0800]","method":"GET /favicon.ico HTTP/1.1","status":"200","SendBytes":"21630","Query?string":"","partner":"http://10.0.0.51:8080/","AgentVersion":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36"}
{"clientip":"10.0.0.1","ClientUser":"-","authenticated":"-","AccessTime":"[26/Apr/2021:23:35:07 +0800]","method":"GET / HTTP/1.1","status":"200","SendBytes":"11217","Query?string":"","partner":"-","AgentVersion":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36"}


```
## 修改filebeat配置文件

``` shell
[root@db01 ~]# cat > /etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
#############nginx_messages###################
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
  json.keys_under_root: true
  json.overwrite_keys: true
  tags: ["access"]
#指定tags标签 
- type: log
  enable: true
  paths:
    - /var/log/nginx/access.log
  json.keys_under_root: true
  json.overwrite_keys: true
  tags: ["access"]
- type: log
  enable: true
  paths:
    - /var/log/nging/error.log
  tags: ["error"]
####################tomcat_messages###############
- type: log
  enabled: true
  paths:
    - /var/log/tomcat/localhost_access_log.*.txt
  json.keys_under_root: true
  json.overwrite_keys: true
  tags: ["tomact"]
#####################output_messages##############

setup.kibana:
  host: "10.0.0.51:5601"
#自定义配置输出格式 
output.elasticsearch:
  hosts: ["10.0.0.51:9200"]
#  判断条件可以为其他属性
  indices:
    - index: "nginx-access-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "access"
    - index: "nginx-error-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "error"
    - index: "tomact-access-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "tomact"

#重新命名模板名称为ngingx
setup.template.name: "nginx"
#匹配格式，以nginx-开头的模板都使用nginx的模板
setup.template.pattern: "nginx-*"
#不使用系统自自带的模板
setup.template.enabled: false
EOF
```

## 重启服务&c查看状态
``` shell
[root@db01 ~]# systemctl restart filebeat.service 

[root@db01 ~]# tail -f /var/log/filebeat/filebeat
2021-04-26T23:51:54.518+0800	INFO	[monitoring]	log/log.go:144	Non-zero metrics in the last 30s	{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":70,"time":{"ms":2}},"total":{"ticks":150,"time":{"ms":13},"value":150},"user":{"ticks":80,"time":{"ms":11}}},"handles":{"limit":{"hard":4096,"soft":1024},"open":8},"info":{"ephemeral_id":"18f558bb-c001-4fdf-9e1c-1e9ef28bfbd7","uptime":{"ms":240047}},"memstats":{"gc_next":4194304,"memory_alloc":1903176,"memory_total":7411504}},"filebeat":{"harvester":{"open_files":1,"running":1}},"libbeat":{"config":{"module":{"running":0}},"pipeline":{"clients":4,"events":{"active":0}}},"registrar":{"states":{"current":3}},"system":{"load":{"1":0.05,"15":0.22,"5":0.2,"norm":{"1":0.05,"15":0.22,"5":0.2}}}}}}

```

## 添加mangement 
![第一步](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426235817.png)
![第二步](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426235817.png)
![第三步](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426235940.png)
