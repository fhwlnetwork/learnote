# nginxjson日志采集
    ## 安装nginx
``` shell
[root@db01 /data/soft]#yum -y install nginx
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
# 启动服务
[root@db01 /data/soft]#systemctl restart nginx

# 安装压测工具
[root@db01 /data/soft]#yum -y install httpd-tools
```
## 配置nginx 日志格式
``` shell

#在nging.conf文件 http中添加以下内容
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

# 验证ngingx配置
[root@db01 /data/soft]#nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

# 重启ngingx 服务
[root@db01 /data/soft]#systemctl restart nginx
# 清空数据日志

[root@db01 /data/soft]#> /var/log/nginx/access.log 
## 创建测试数据

[root@db01 /data/soft]#ab -n 100 -c 100 http://10.0.0.51/
[root@db01 /data/soft]#tail -f /var/log/nginx/access.log 
10.0.0.51 - - [26/Apr/2021:14:08:59 +0800] "GET / HTTP/1.0" 200 4833 "-" "ApacheBench/2.3" "-"
10.0.0.51 - - [26/Apr/2021:14:08:59 +0800] "GET / HTTP/1.0" 200 4833 "-" "ApacheBench/2.3" "-"
10.0.0.51 - - [26/Apr/2021:14:08:59 +0800] "GET / HTTP/1.0" 200 4833 "-" "ApacheBench/2.3" "-"
10.0.0.51 - - [26/Apr/2021:14:08:59 +0800] "GET / HTTP/1.0" 200 4833 "-" "ApacheBench/2.3" "-"


# 验证查看日志数据格式
[root@db01 /data/soft]#tail -1 /var/log/nginx/access.log 
{ "time_local": "26/Apr/2021:14:30:52 +0800", "remote_addr": "10.0.0.51", "referer": "-", "request": "GET / HTTP/1.0", "status": 200, "bytes": 4833, "agent": "ApacheBench/2.3", "x_forwarded": "-", "up_addr": "-","up_host": "-","upstream_time": "-","request_time": "0.000"}

```
![ngingx_json_Log](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426143500.png)



## 安装filebeat
``` shell 
[root@db01 /data/soft]# rpm -ivh filebeat-6.6.0-x86_64.rpm 
warning: filebeat-6.6.0-x86_64.rpm: Header V4 RSA/SHA512 Signature, key ID d88e42b4: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:filebeat-6.6.0-1                 ################################# [100%]


## 修改配置文件
[root@db01 /data/soft]#cp /etc/filebeat/filebeat.yml /tmp/
[root@db01 /data/soft]#cat > /etc/filebeat/filebeat.yml<<EOF
filebeat.inputs:
- type: log
  enabled: true 
  paths:
    - /var/log/nginx/access.log
  json.keys_under_root: true
  json.overwrite_keys: true
setup.kibana:
  host: "10.0.0.51:5601"
#自定义配置输出格式 
output.elasticsearch:
  hosts: ["10.0.0.51:9200"]
  index: "nginx-%{[beat.version]}-%{+yyyy.MM}"
#重新命名模板名称为ngingx
setup.template.name: "nginx"
#匹配格式，以nginx-开头的模板都使用nginx的模板
setup.template.pattern: "nginx-*"
#不使用系统自自带的模板
setup.template.enabled: false
setup.template.overwrite: true
EOF

# 启动服务
[root@db01 /data/soft]# systemctl start filebeat.service
```


## 添加kibana监控项目

![第一步](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426154159.png)

![第二步](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426154446.png)

![第三步](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426154646.png)

![查看监控内容](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210426155856.png)