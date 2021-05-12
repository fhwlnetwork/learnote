# 安装

./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --with-pcre-jit --with-http_ssl_module --with-http_v2_module --with-http_sub_module --with-stream --with-stream_ssl_module


[root@web01 system]# vim nginx.service
[root@web01 system]# pwd
/usr/lib/systemd/system

1.在系统服务目录里创建nginx.service文件
vi /lib/systemd/system/nginx.service
编辑如下内容

复制代码
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