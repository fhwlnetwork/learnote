# 主从配置

# 1. 主从复制介绍
```text
(1) 主从复制基于binlog来实现的
(2) 主库发生新的操作,都会记录binlog
(3) 从库取得主库的binlog进行回放
(4) 主从复制的过程是异步
```

# 2. 主从复制的前提 (搭建主从复制) 
```text
(1) 2个或以上的数据库实例
(2) 主库需要开启二进制日志 
(3) server_id要不同,区分不同的节点
(4) 主库需要建立专用的复制用户 (replication slave)
(5) 从库应该通过备份主库,恢复的方法进行"补课"
(6) 人为告诉从库一些复制信息(ip port user pass,二进制日志起点)
(7) 从库应该开启专门的复制线程

```
## 2.1 实例搭建 ：[mysql安装](../mysql/install.md)
### 2.1.1 同一机器配置多个实例：[多实例配置](../mysql/Multiple_Examples_install.md)
### 2.2 检查配置文件
```sh
# 主库: 二进制日志是否开启
# 两个节点: server_id
[root@db01 data]# cat /data/3308/my.cnf 
[mysqld]
basedir=/application/mysql
datadir=/data/3308/data
socket=/data/3308/mysql.sock
log_error=/data/3308/mysql.log
port=3308
server_id=8
log_bin=/data/3308/mysql-bin

[root@db01 data]# cat /data/3307/my.cnf 
[mysqld]
basedir=/application/mysql
datadir=/data/3307/data
socket=/data/3307/mysql.sock
log_error=/data/3307/mysql.log
port=3307
server_id=7
log_bin=/data/3307/mysql-bin
```
## 2.3 主库创建复制用户
```sh
[root@db01 ~]# mysql -uroot -p123 -S /data/3307/mysql.sock -e "grant replication slave on *.* to repl@'10.0.0.%' identified by '123'"
```
## 2.4 基础数据同步，"补课"
```sh 
# 主: 
[root@db01 ~]# mysqldump -uroot -p123 -S /data/3307/mysql.sock -A --master-data=2 --single-transaction -R -E --triggers >/tmp/full.sql
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/1621481469.png)

```sh 
# 从:
[root@db01 ~]# mysql -S /data/3308/mysql.sock 
mysql> set sql_log_bin=0;
mysql> source /tmp/full.sql
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/1621481564.png)

## 2.5 告诉从库信息

```sh
# 获取配置格式help change master to
# 获取需要补充的数据起点，从备份文件中查看
vim /tmp/full.sql
-- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000004', MASTER_LOG_POS=444;
```
![获取数据备份的位置](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/1621487885.png)

```SH 
# 配置mysql
#  如果是多实例是指定sock 登陆或者使用端口号 mysql -S /data/3308/mysql.sock 
#  多服务器大件事直接登陆3306端口的服务器即可
# 特比注意： MASTER_LOG_FILE，MASTER_LOG_POS必须与备份文件中的值一样，否则数据会有缺失，如上图所示
[root@db01 ~]# mysql -S /data/3308/mysql.sock 
CHANGE MASTER TO 
MASTER_HOST='10.0.0.51',
MASTER_USER='repl',
MASTER_PASSWORD='123',
MASTER_PORT=3307,
MASTER_LOG_FILE='mysql-bin.000008',
MASTER_LOG_POS=704,
MASTER_CONNECT_RETRY=10;

```

## 2.6 从库开启复制线程(IO,SQL)
``` sh
[root@db01 ~]# mysql -S /data/3308/mysql.sock 
mysql> start slave;
```
## 2.7 检查主从复制状态
```sh
[root@db01 ~]# mysql -S /data/3308/mysql.sock 
mysql> show slave status \G
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
```
![验证](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/1621488401.png)

```sh
# 主库:
[root@db01 ~]# mysql -uroot -p123 -S /data/3307/mysql.sock -e "create database alexsb"
# 从库:
[root@db01 world]# mysql -S /data/3308/mysql.sock -e "show databases"
```
![验证效果](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/1621488501.png)
## 2.8 重置主从配置(注意起始位置)：
```sh 
# 登陆mysql
# 1、停止主从复制服务
stop slave ;
# 2、充值配置
reset slave all;
CHANGE MASTER TO 
MASTER_HOST='10.0.0.51',
MASTER_USER='repl',
MASTER_PASSWORD='123',
MASTER_PORT=3307,
MASTER_LOG_FILE='mysql-bin.000004',
MASTER_LOG_POS=444,
MASTER_CONNECT_RETRY=10;

``` 

# 3、主从原理
## 3.1 主从复制中涉及的文件
```text
主库: 
	binlog 
从库: 
	relaylog  中继日志
	master.info  主库信息文件
	relaylog.info relaylog应用的信息
```
## 3.2 主从复制中涉及的线程
``` text
主库:
	Binlog_Dump Thread : DUMP_T
从库: 
	SLAVE_IO_THREAD     : IO_T
	SLAVE_SQL_THREAD    : SQL_T
```
## 主从复制工作(过程)原理
```text
1.从库执行change master to 命令(主库的连接信息+复制的起点)
2.从库会将以上信息,记录到master.info文件
3.从库执行 start slave 命令,立即开启IO_T和SQL_T
4. 从库 IO_T,读取master.info文件中的信息
获取到IP,PORT,User,Pass,binlog的位置信息
5. 从库IO_T请求连接主库,主库专门提供一个DUMP_T,负责和IO_T交互
6. IO_T根据binlog的位置信息(mysql-bin.000004 , 444),请求主库新的binlog
7. 主库通过DUMP_T将最新的binlog,通过网络TP（传送）给从库的IO_T
8. IO_T接收到新的binlog日志,存储到TCP/IP缓存,立即返回ACK给主库,并更新master.info
9.IO_T将TCP/IP缓存中数据,转储到磁盘relaylog中.
10. SQL_T读取relay.info中的信息,获取到上次已经应用过的relaylog的位置信息
11. SQL_T会按照上次的位置点回放最新的relaylog,再次更新relay.info信息
12. 从库会自动purge应用过relay进行定期清理
补充说明:
一旦主从复制构建成功,主库当中发生了新的变化,都会通过dump_T发送信号给IO_T,增强了主从复制的实时性.

```
# 4、主从复制监控
```sh
# 命令:
mysql> show slave status \G
主库有关的信息(master.info):
Master_Host: 10.0.0.51
Master_User: repl
Master_Port: 3307
Connect_Retry: 10
*******************************
Master_Log_File: mysql-bin.000004
Read_Master_Log_Pos: 609
*******************************
从库relay应用信息有关的(relay.info):
Relay_Log_File: db01-relay-bin.000002
Relay_Log_Pos: 320
Relay_Master_Log_File: mysql-bin.000004
从库线程运行状态(排错)
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Last_IO_Errno: 0
Last_IO_Error: 
Last_SQL_Errno: 0
Last_SQL_Error: 			
			
过滤复制有关的信息:			
Replicate_Do_DB: 
Replicate_Ignore_DB: 
Replicate_Do_Table: 
Replicate_Ignore_Table: 
Replicate_Wild_Do_Table: 
Replicate_Wild_Ignore_Table: 
 
从库延时主库的时间(秒):  
Seconds_Behind_Master: 0
				
延时从库:
SQL_Delay: 0
SQL_Remaining_Delay: NULL

GTID复制有关的状态信息		  
Retrieved_Gtid_Set: 
Executed_Gtid_Set: 
Auto_Position: 0
```
# 5、故障排查
## 5.1 IO 线程故障 
### (1) 连接主库: connecting
```text
1、产生的原因：
    网络错误,连接信息错误或变更了,防火墙阻断,msyql连接数上线
排查思路：
 1、查看防火墙策略
 iptables -L -n

 2、查看连接数
 mysql> show status like 'Threads%';  
    +-------------------+-------+  
    | Variable_name     | Value |  
    +-------------------+-------+  
    | Threads_cached    | 58    |  
    | Threads_connected | 57    |   ###这个数值指的是打开的连接数  
    | Threads_created   | 3676  |  
    | Threads_running   | 4     |   ###这个数值指的是激活的连接数，这个数值一般远低于connected数值  
    +-------------------+-------+  

    Threads_connected 跟show processlist结果相同，表示当前连接数。准确的来说，Threads_running是代表当前并发数  
       
    这是是查询数据库当前设置的最大连接数  
    mysql> show variables like '%max_connections%';  
    +-----------------+-------+  
    | Variable_name   | Value |  
    +-----------------+-------+  
    | max_connections | 100  |  
    +-----------------+-------+  
       
    可以在/etc/my.cnf里面设置数据库的最大连接数  
    max_connections = 1000
3、使用复制用户手动登录，查看是否可以连接
[root@db01 data]# mysql -urepl -p12321321 -h 10.0.0.51 -P 3307
    连接错误解决方案：
    1. stop slave 
    2. reset slave all;
    3. change master to 
    4. start slave
````
### (2)请求Binlog
```text
原因：binlog 没开
      binlog 损坏,不存在
      主库执行了reset master
解决方案：
从库 
stop slave ;
reset slave all; 
CHANGE MASTER TO 
MASTER_HOST='10.0.0.51',
MASTER_USER='repl',
MASTER_PASSWORD='123',
MASTER_PORT=3307,
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=154,
MASTER_CONNECT_RETRY=10;
start slave;
```
### (3) 存储binlog到relaylog
```text
查看relaylog写入权限
``
## 5.2  SQL线程故障
```text
relay log回放，relay-log损坏，研究一条SQL语句为什么执行失败?

1、从库已存在，造成失败
合理处理方法: 
把握一个原则,一切以主库为准进行解决.
如果出现问题,尽量进行反操作
最直接稳妥办法,重新构建主从
删除从库中的数据，重启服务
mysql> start slave;


暴力的解决方法(不推荐)
方法一：

stop slave; 
set global sql_slave_skip_counter = 1;
start slave;
#将同步指针向下移动一个，如果多次不同步，可以重复操作。
start slave;
方法二：
/etc/my.cnf
slave-skip-errors = 1032,1062,1007
常见错误代码:
1007:对象已存在
1032:无法执行DML
1062:主键冲突,或约束冲突
但是，以上操作有时是有风险的，最安全的做法就是重新构建主从。把握一个原则,一切以主库为主.

索引限制冲突时：
解决办法，找出报错的数据，对比主库数据后进行update,再进行 跳过报错


为了很程度的避免SQL线程故障
(1) 从库只读
read_only
super_read_only
db01 [(none)]>show variables like "%read_only%";
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| innodb_read_only      | OFF   |
| read_only             | OFF   |
| super_read_only       | OFF   |
| transaction_read_only | OFF   |
| tx_read_only          | OFF   |
+-----------------------+-------+
5 rows in set (0.00 sec)

(2) 使用读写分离中间件
atlas 
mycat
ProxySQL 
MaxScale
```