# 虚拟主机

##   1) 利用nginx服务搭建网站文件共享服务器
``` sh
[root@wjh conf.d]# cat file.conf
server {
   listen        80;
   server_name   www.testk.com;
   location / {
     root  /data;
    #配置账户
    # auth_basic      "wjhtest-sz-01";
    #配置密码
    # auth_basic_user_file password/htpasswd;
     autoindex on;   
    # --- 修改目录结构中出现的中文乱码问题
    charset utf-8;
   }
}
# 说明：
# 1. 需要将首页文件进行删除
# 2. mime.types媒体资源类型文件作用
# 文件中有的扩展名信息资源,   进行访问时会直接看到数据信息
# 文件中没有的扩展名信息资源, 进行访问时会直接下载资源
```
##   2) 利用nginx服务搭建网站
```sh
server {
    listen 80;
    server_name www.testk.com;
    root /data/www/keep_com;
    index index.html;
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
     root   /usr/share/nginx/html;
    }
    #根据路径指定访问目录
    location /dev {
        root /data;
        #指定ip端可以访问
        deny ip；
        allow ip;
    }
}
   
```

## 3）https配置
``` sh
server  {
    listen 443;
    server_name https.test.com;
    ssl om;
    # --指定srt的目录信息
    ssl_certificate  ssl_key/server.crt; 
    #   ----指定key的目录
    ssl_certificate_key ssl_key/server.key; 	
    location / {
    root /code/https;
    index index.html;
    }
}
server {
    listen 80;
    server_named
    rewrite .* https://$server_name$request_rui redirect;
}

#PS：负载均衡配置https时，只需要再LB的机器配置https，运行程序的主机不需要配置htps
```
