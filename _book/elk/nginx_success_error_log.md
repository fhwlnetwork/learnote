# ELk 收集Nginx的正常日志和错误日志

## 收集多台nginx服务日志信息
``` shell
    #n台服务的配置文件的日志格式为一样
  http {
   
    log_format json  '{ "time_local": "$time_local", '
                          '"remote_addr": "$remote_addr", '
                          '"referer": "$http_referer", '
                          '"request": "$request", '
                          '"status": $status, '
                          '"bytes": $body_bytes_sent, '
                          '"agent": "$http_user_agent", '
                          '"x_forwarded": "$http_x_forwarded_for", '
                          '"up_addr": "$upstream_addr",'
                          '"up_host": "$upstream_http_host",'
                          '"upstream_time": "$upstream_response_time",'
                          '"request_time": "$request_time"'
    '}';
}
```
## 正常日志，错误日志拆分
``` shell
#修改配置信息
[root@db01 ~]# cat >/etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
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
    - /var/log/nginx/error.log
  tags: ["error"]

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

#重新命名模板名称为ngingx
setup.template.name: "nginx"
#匹配格式，以nginx-开头的模板都使用nginx的模板
setup.template.pattern: "nginx-*"
#不使用系统自自带的模板
setup.template.enabled: false
EOF

```
## 说明
```text
特别说明:如果之前已产生日志数据，需将旧日志信息移除或移动到其他目录
        删除添加的好的management
```
