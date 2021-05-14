# 安装

## 1、下载安装包
```sh
[root@wjh ~]# mkdir -p /data/soft
[root@wjh ~]# cd /data/soft/
[root@wjh soft]#  wget http://nginx.org/download/nginx-1.16.0.tar.gz
[root@wjh soft]# tar -zxvf nginx-1.16.0.tar.gz 
[root@wjh soft]# cd nginx-1.16.0/

 ```
## 2、解决依赖问题
``` sh
[root@wjh nginx-1.16.0]# yum -y install openssl-devel pcre-devel

```
## 3、指定安装的路径，安装的模块
``` sh
[root@wjh nginx-1.16.0]# ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --with-pcre-jit --with-http_ssl_module --with-http_v2_module --with-http_sub_module --with-stream --with-stream_ssl_module

```
## 4、编译安装

``` sh
[root@wjh nginx-1.16.0]# make & make install 
```
## 5、创建启动文件

```sh
#1.在系统服务目录里创建nginx.service文件

[root@wjh nginx-1.16.0]# cat >/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx
After=network.target
  
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
  
[Install]
WantedBy=multi-user.target
EOF

[root@wjh nginx-1.16.0]# chmod +x /lib/systemd/system/nginx.service 
[root@wjh ~]# ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
[root@wjh ~]# useradd nginx -s /sbin/nologin 
[root@wjh ~]# 

```

## 6、启动程序
``` sh

[root@wjh ~]# systemctl daemon-reload 
[root@wjh ~]# systemctl start nginx
[root@wjh ~]# systemctl status nginx
● nginx.service - nginx
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-05-14 10:07:34 CST; 7s ago
  Process: 4871 ExecStart=/usr/local/nginx/sbin/nginx (code=exited, status=0/SUCCESS)
 Main PID: 4872 (nginx)
   CGroup: /system.slice/nginx.service
           ├─4872 nginx: master process /usr/local/nginx/sbin/nginx
           └─4873 nginx: worker process

May 14 10:07:34 wjh systemd[1]: Starting nginx...
May 14 10:07:34 wjh systemd[1]: Started nginx.
[root@wjh ~]# systemctl enable nginx
Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /usr/lib/systemd/system/nginx.service.
[root@wjh ~]# 

```
