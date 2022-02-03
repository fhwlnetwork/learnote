# 安装

## 1、准备工作
``` SH
# 创建保存安装包的文件夹
[root@wjh ~]# mkdir -p /server/tools
# 上传软件数据包

# 创建保存数据库运行程序的目录
[root@wjh ~]# mkdir -p /application

# 解压文件
[root@wjh ~]# tar -xf mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz -C /appliacation/ 

```
## 2、卸载系统自带的mariadb
```sh 
[root@wjh ~]# yum -y remove mariadb
```

##  3、创建用户
```sh 
[root@wjh ~]# useradd -s /sbin/nologin mysql
```
## 4、配置环境变量
```sh
[root@db01 ~]# vim /etc/profile
#文件末尾添加
export PATH=/application/mysql/bin:$PATH
# 配置完成之后加载文件 
[root@db01 ~]# source /etc/profile
# 验证配置是否生效
[root@wjh application]# mysql -V
mysql  Ver 14.14 Distrib 5.7.26, for linux-glibc2.12 (x86_64) using  EditLine wrapper
```
## 5、初始化数据

``` sh
[root@wjh application]# mkdir /data/mysql/data -p
[root@wjh application]# chown -R mysql.mysql /data 
[root@wjh application]# 
#执行初始化命令
mysqld --initialize --user=mysql --basedir=/application/mysql --datadir=/data/mysql/data
 
--initialize 参数说明：
1、对于密码复杂度进行定制：12位，4种
2 、密码过期时间 180
root@wjh application]# mysqld --initialize-insecure  --user=mysql --basedir=/application/mysql --datadir=/data/mysql/data

```
### 5.1 报错解决
错误信息：
![错误信息](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210514165107.png)
```sh 
##解决方式：
[root@wjh application]# rm -rf /data/mysql/*

```
## 6、编辑配置文件

``` sh
[root@wjh application]#  cat >/etc/my.cnf <<EOF
[mysqld]
user=mysql
basedir=/application/mysql
datadir=/data/mysql/data
socket=/tmp/mysql.sock
server_id=6
port=3306
[mysql]
socket=/tmp/mysql.sock
EOF
# 配置 systemdqidong 
cat > /etc/systemd/system/mysqld.service <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=/application/mysql/bin/mysqld --defaults-file=/etc/my.cnf
LimitNOFILE = 5000
EOF

```
## 启动服务
```sh 

[root@wjh application]# systemctl start mysqld
[root@wjh application]# systemctl status mysqld

```

# 调错方法
## 如何分析处理MySQL数据库无法启动
### without updating PID 类似错误

```sh
# 日志文件位置
# 查看、etc/my.cnf 中datadir配置的路径
[root@wjh application]# cat /data/mysql/data/wjh.err 

# 可能情况：
#	/etc/my.cnf 路径不对等
#	/tmp/mysql.sock文件修改过 或 删除过 
#	数据目录权限不是mysql
#	参数改错了

```
### 2、将日志直接显示到屏幕
```sh
[root@wjh ~]# /application/mysql/bin/mysqld --defaults-file=/etc/my.cnf

```
# 密码管理
## 管理密码设定
```sh
~]# mysqladmin -uroot -p password wjh123
```
## 管理员忘记密码重设
```sh
# --skip-grant-tables  #跳过授权表
# --skip-networking    #跳过远程登录
# 第一步：关闭数据库
~] # /etc/init.d/mysqld stop
# 第二步：启动数据库到维护模式
~] # mysql_sate --skip-grant-tables --skip-networking &
# 第三步：登陆并修改服务器

mysql> alter user root@'localhost' identified by '123456';
##可能遇到的报错
ERROR 1290 (HY000): The MySQL server is running with the --skip-grant-tables option so it cannot execute this statement
#执行一下操作
mysql> flush privileges;
mysql> alter user root@'localhost' identified by '123456';
# 第四步：关闭服务器重新启动
~]# /etc/init.d/mysqld restart

```