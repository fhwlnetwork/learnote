# keepalieved配置nginx高可用冗余
![架构](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210516201009.png)
## keepalived编译安装
### 编译安装keepalived
```sh
#安装依赖
[root@wjh soft]# yum install curl gcc openssl-devel libnl3-devel net-snmp-devel libnfnetlink-devel -y


# 下载软件
[root@wjh soft]#  wget https://www.keepalived.org/software/keepalived-2.2.2.tar.gz
#解压文件
[root@wjh soft]# tar -zxvf keepalived-2.2.2.tar.gz 
[root@wjh soft]# cd keepalived-2.2.2/
# 编译，指定安装路径位/usr/local/keepalived
./configure --with-init=systemd --with-systemdsystemunitdir=/usr/lib/systemd/system --prefix=/usr/local/keepalived --with-run-dir=/usr/local/keepalived/run 

# 安装
[root@wjh keepalived-2.2.2]# make 
[root@wjh keepalived-2.2.2]#  make install 
# 可执行文件拷贝一份到系统执行文件目录，该目录在path变量里面，可以直接使用keepalived命令
cp /usr/local/keepalived/sbin/keepalived /usr/sbin/keepalived   
# 或者
[root@wjh keepalived-2.2.2]# ln -s /usr/local/keepalived/sbin/keepalived /usr/sbin/keepalived

# keepalived附加参数文件，为了跟yum安装一致，其实是不用配置的。启动文件指定实际路径就可以了。
[root@wjh keepalived-2.2.2]# ln -s  /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/keepalived

# pid文件放置目录,目录可以自己定义在启动脚本里面使用
mkdir /usr/local/keepalived/run


```

### 配置system自启动文件

```sh
cat > /usr/lib/systemd/system/keepalived.service<<EOF
[Unit]
Description=LVS and VRRP High Availability Monitor
After=network-online.target syslog.target
Wants=network-online.target

[Service]
Type=simple
PIDFile=/usr/local/keepalived/run/keepalived.pid
KillMode=process
EnvironmentFile=-/etc/sysconfig/keepalived
ExecStart=/usr/sbin/keepalived -f /usr/local/keepalived/etc/keepalived/keepalived.conf $KEEPALIVED_OPTIONS 
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF

```
### 从节点与上述操作一致

### master节点配置
```sh 
cat > /usr/local/keepalived/etc/keepalived/keepalived.conf <<EOF
global_defs {
   router_id nginx01
}
#指定监控脚本
vrrp_script chk_haproxy {
    script "/usr/local/keepalived/etc/keepalived/chk_nginx.sh"
    interval 2
    weight 2
}
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 55
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
       10.0.0.3
    }
    track_script {
        chk_haproxy
    }
}
EOF


```

### backuup节点
```sh 
cat > /usr/local/keepalived/etc/keepalived/keepalived.conf <<EOF

global_defs {
   router_id nginx02
}
vrrp_script chk_haproxy {
    script "/usr/local/keepalived/etc/keepalived/chk_nginx.sh"
    interval 2
    weight 2
}
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 55
    priority 100 
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    #指定vip地址
    virtual_ipaddress {
        10.0.0.3
    }
    track_script {
        chk_haproxy
    }
}
EOF

```

### 监控脚本
```sh
cat >/usr/local/keepalived/etc/keepalived/chk_nginx.sh<<EOF
#!/bin/bash
num=`ps -ef|grep -c [n]ginx`
if [ $num -lt 2 ]
then
    systemctl stop keepalived
fi
EOF

```

## nginx配置
```sh
  upstream wjhtest {
       server 10.0.0.7:80;
       server 10.0.0.8:80;
       server 10.0.0.9:80;
    }
    server {
        listen       10.0.0.3:80;
        server_name  www.wjhtest.com;
        location / {
           proxy_pass http://wjhtest;
           proxy_set_header Host $host;
           proxy_set_header X-Forwarded-For $remote_addr;
           proxy_next_upstream error timeout http_404 http_502 http_403;
        }
    }
    

```