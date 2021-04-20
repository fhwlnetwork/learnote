# 安装

## 1、目录规划

```text
### redis 下载目录

/data/soft/

### redis 安装目录

/opt/redis_cluster/redis_{PORT}/{conf,logs,pid}

### redis数据目录

/opt/redis_cluster/redis_{PORT}/redis_{port}.rdb

### redis 运维脚本

/root/scripts/redis_shell.sh
```

## 2、安装命令

### 2.1、 安装准备

```text
###编辑hosts文件
[root@db01 ~]#vim /etc/hosts
[root@db01 ~]#tail -3 /etc/hosts
10.0.0.51    db01
10.0.0.52    db02
10.0.0.53    db03
[root@db01 ~]#创建目录
[root@db01 ~]#mkdir -p /data/soft
[root@db01 ~]#mkdir -p /opt/redis_cluster/redis_6379
[root@db01 ~]#mkdir -p /opt/redis_cluster/redis_6379/{conf,pid,logs}
[root@db01 ~]#mkdir -p /data/redis_cluster/redis_6379

[root@db01 ~]#cd /data/soft/
root@db01 ~]#下载文件
[root@db01 /data/soft]#wget http://download.redis.io/releases/redis-3.2.12.tar.gz
[root@db01 /data/soft]#tar zxvf redis-3.2.12.tar.gz -C /opt/redis_cluster/
```

![&#x7ED3;&#x6784;](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/imgredis_file.png)

### 2.2、 安装程序

```text
[root@db01 /opt/redis_cluster]#ln -s /opt/redis_cluster/redis-3.2.12/ /opt/redis_cluster/redis
[root@db01 /opt/redis_cluster]#ll
total 0
lrwxrwxrwx 1 root root  32 Apr 20 13:40 redis -> /opt/redis_cluster/redis-3.2.12/
drwxrwxr-x 6 root root 309 Jun 13  2018 redis-3.2.12
drwxr-xr-x 5 root root  41 Apr 20 13:20 redis_6379
[root@db01 /opt/redis_cluster]#cd redis
[root@db01 /opt/redis_cluster/redis]#make && make install
```

### 2.3、编辑配置文件

```text
[root@db01 /opt/redis_cluster/redis_6379/conf]#vim /opt/redis_cluster/redis_6379/conf
 ### 以守护模式启动
daemonize yes
### 绑定的主机地址
bind 10.0.0.51 127.0.0.1
### 监听接口
port 6379
### pid文件和log文件的保存地址
pidfile /opt/redis_cluster/redis_6379/pid/redis_6379.pid
logfile /opt/redis_cluster/redis_6379/logs/redis_6379.log
### 设置数据库的数量，默认数据库为0
databases 16
### 指定本地持计划文件的文件名，默认是dump.rdb
dbfilename redis_6379.rdb
### 本地数据库的目录
dir /data/redis_cluster/redis_6379
```

### 2.3 借助官方工具生成启动配置文件

进入utils，执行install文件，生成

```text
[root@db01 /opt/redis_cluster/redis_6379/conf]#cd 
[root@db01 ~]#cd /opt/redis_cluster/redis/utils/
[root@db01 /opt/redis_cluster/redis/utils]#./install_server.sh 
Welcome to the redis service installer
This script will help you easily set up a running redis server

Please select the redis port for this instance: [6379] 
Selecting default: 6379
Please select the redis config file name [/etc/redis/6379.conf] 
Selected default - /etc/redis/6379.conf
Please select the redis log file name [/var/log/redis_6379.log] 
Selected default - /var/log/redis_6379.log
Please select the data directory for this instance [/var/lib/redis/6379] 
Selected default - /var/lib/redis/6379
Please select the redis executable path [/usr/local/bin/redis-server] 
Selected config:
Port           : 6379
Config file    : /etc/redis/6379.conf
Log file       : /var/log/redis_6379.log
Data dir       : /var/lib/redis/6379
Executable     : /usr/local/bin/redis-server
Cli Executable : /usr/local/bin/redis-cli
Is this ok? Then press ENTER to go on or Ctrl-C to abort.
Copied /tmp/6379.conf => /etc/init.d/redis_6379
Installing service...
Successfully added to chkconfig!
Successfully added to runlevels 345!
Starting Redis server...
Installation successful!
```

## 3、启动/关闭服务

```text
###启动服务
[root@db01 ~]# redis-server /opt/redis_cluster/redis_6379/conf/redis_6379.conf 
###关闭服务
[root@db01 ~]# redis-cli -h db01 shutdown
```

## 4、验证服务

```text
[root@db01 /opt/redis_cluster/redis/utils]#ps -ef |grep redis
root       5106      1  0 14:49 ?        00:00:03 redis-server 10.0.0.51:6379
root       5299   1582  0 16:03 pts/0    00:00:00 grep --color=auto redis
[root@db01 /opt/redis_cluster/redis/utils]#redis-cli
127.0.0.1:6379> set name wjh
OK
127.0.0.1:6379> get name
"wjh"
127.0.0.1:6379>
```

## 5、配置密码验证

```text
# 2) No password is configured.
# If the master is password protected (using the "requirepass" configuration
# masterauth <master-password>
# resync is enough, just passing the portion of data the slave missed while
# 150k passwords per second against a good box. This means that you should
# use a very strong password otherwise it will be very easy to break.
requirepass foobared
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/imgimage-20210420161125245.png)

## 6、 配置持久化

```kotlin
AOF 持久化(append-only log file)
    记录服务器执行的所有写操作命令，并在服务器启动时，通过重新执行这些命令来还原数据集。 
    AOF 文件中的命令全部以 Redis 协议的格式来保存，新命令会被追加到文件的末尾。
    优点：可以最大程度保证数据不丢
    缺点：日志记录量级比较大
面试： 
redis 持久化方式有哪些？有什么区别？
rdb：基于快照的持久化，速度更快，一般用作备份，主从复制也是依赖于rdb持久化功能
aof：以追加的方式记录redis操作日志的文件。可以最大程度的保证redis数据安全，类似于mysql的binlog
Aof 和rdb同时存在时，优先读取aof
```

```text
### rdb配置持久化
#说明：从下往上分别表示，60s内写入10000次自动保存
#300s 写入10次自动保存
#900s 写入一次自动保存
save 900 1
save 300 10
save 60 10000

### AOF持久化配置
#是否打开aof日志功能
appendonly yes
#每1个命令,都立即同步到aof 
appendfsync always
#每秒写1次
appendfsync everysec
#写入工作交给操作系统,由操作系统判断缓冲区大小,统一写入到aof.
appendfsync no
```

