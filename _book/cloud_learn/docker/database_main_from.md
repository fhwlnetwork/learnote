# 数据库主从

## 1、新建主服务器容器实例3307

```sh
docker run -p 3307:3306 --name mysql-master \
-v /mydata/mysql-master/log:/var/log/mysql \
-v /mydata/mysql-master/data:/var/lib/mysql \
-v /mydata/mysql-master/conf:/etc/mysql \
-e MYSQL_ROOT_PASSWORD=root  \
-d mysql:5.7
```

## 2、进入/mydata/mysql-master/conf目录下新建my.cnf

```sh
[mysqld]
## 设置server_id，同一局域网中需要唯一
server_id=101 
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql  
## 开启二进制日志功能
log-bin=mall-mysql-bin  
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M  
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed  
## 二进制日志过期清理时间。默认值为0，表示不自动清理。
expire_logs_days=7  
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062
```

## 3、修改完配置后重启master实例

```sh
# docker restart mysql-master
```

## 4、进入mysql-master容器

```sh
[root@wjh ~]# docker exec -it mysql-master /bin/bash
root@a856341f5cb9:/# mysql -uroot -proot
```

## 5、master容器实例内创建数据同步用户

```SQL
mysql> CREATE USER 'slave'@'%' IDENTIFIED BY '123456';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'slave'@'%';
Query OK, 0 rows affected (0.00 sec)
```

## 6、新建从服务器容器实例3308

```sh
docker run -p 3308:3306 --name mysql-slave \
-v /mydata/mysql-slave/log:/var/log/mysql \
-v /mydata/mysql-slave/data:/var/lib/mysql \
-v /mydata/mysql-slave/conf:/etc/mysql \
-e MYSQL_ROOT_PASSWORD=root  \
-d mysql:5.7
```

## 7、进入/mydata/mysql-slave/conf目录下新建my.cnf

```\SH
[mysqld]
## 设置server_id，同一局域网中需要唯一
server_id=102
## 指定不需要同步的数据库名称
binlog-ignore-db=mysql  
## 开启二进制日志功能，以备Slave作为其它数据库实例的Master时使用
log-bin=mall-mysql-slave1-bin  
## 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M  
## 设置使用的二进制日志格式（mixed,statement,row）
binlog_format=mixed  
## 二进制日志过期清理时间。默认值为0，表示不自动清理。
expire_logs_days=7  
## 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
## 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致
slave_skip_errors=1062  
## relay_log配置中继日志
relay_log=mall-mysql-relay-bin  
## log_slave_updates表示slave将复制事件写进自己的二进制日志
log_slave_updates=1  
## slave设置为只读（具有super权限的用户除外）
read_only=1
```

## 8、修改完配置后重启slave实例

```sh
docker restart mysql-slave
```

## 9、在主数据库中查看主从同步状态

```sql
>show master status;
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202061958972.png)

## 10、进入mysql-slave容器

```sh
 docker exec -it mysql-slave /bin/mysql -uroot -proot
```

## 11、在从数据库中配置主从复制

```sh
mysql -uroot -proot
change master to master_host='10.0.0.200',master_user='slave',master_password='123456',master_port=3307,master_log_file='mall-mysql-bin.000001',master_log_pos=154,master_connect_retry=30;
```

>主从复制命令参数说明
>
>master_host：主数据库的IP地址；
>
>master_port：主数据库的运行端口；
>
>master_user：在主数据库创建的用于同步数据的用户账号；
>
>master_password：在主数据库创建的用于同步数据的用户密码；
>
>master_log_file：指定从数据库要复制数据的日志文件，通过查看主数据的状态，获取File参数；
>
>master_log_pos：指定从数据库从哪个位置开始复制数据，通过查看主数据的状态，获取Position参数；
>
>master_connect_retry：连接失败重试的时间间隔，单位为秒。

## 12、在从数据库中查看主从同步状态

```sql
mysql> show slave status \G;
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062004684.png)

## 13、在<a style="color:red">从数据库</a>中开启主从同步

```sh
mysql> start slave;

```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062025921.png)

