# 一台主机搭建多实例

## 1、准备多个目录
```sh 
mkdir -p /data/330{7,8,9}/data
```
## 2、准备配置文件
```sh
cat > /data/3307/my.cnf <<EOF
[mysqld]
basedir=/application/mysql
datadir=/data/3307/data
socket=/data/3307/mysql.sock
log_error=/data/3307/mysql.log
port=3307
server_id=7
log_bin=/data/3307/mysql-bin
EOF

cat > /data/3308/my.cnf <<EOF
[mysqld]
basedir=/application/mysql
datadir=/data/3308/data
socket=/data/3308/mysql.sock
log_error=/data/3308/mysql.log
port=3308
server_id=8
log_bin=/data/3308/mysql-bin
EOF

cat > /data/3309/my.cnf <<EOF
[mysqld]
basedir=/application/mysql
datadir=/data/3309/data
socket=/data/3309/mysql.sock
log_error=/data/3309/mysql.log
port=3309
server_id=9
log_bin=/data/3309/mysql-bin
EOF


```
## 3、初始化三套数据

```sh
# 为防止初始化时使用默认设置，将默认my.cnf改名
mv /etc/my.cnf /etc/my.cnf.bak
# 执行初始化命令
mysqld --initialize-insecure  --user=mysql --datadir=/data/3307/data --basedir=/application/mysql
mysqld --initialize-insecure  --user=mysql --datadir=/data/3308/data --basedir=/application/mysql
mysqld --initialize-insecure  --user=mysql --datadir=/data/3309/data --basedir=/application/mysql
```
## 4、systemd管理多实例
```sh
cd /etc/systemd/system
cp mysqld.service mysqld3307.service
cp mysqld.service mysqld3308.service
cp mysqld.service mysqld3309.service
vim mysqld3307.service
# 修改为:
ExecStart=/application/mysql/bin/mysqld  --defaults-file=/data/3307/my.cnf
vim mysqld3308.service
# 修改为:
ExecStart=/application/mysql/bin/mysqld  --defaults-file=/data/3308/my.cnf
vim mysqld3309.service
# 修改为:
ExecStart=/application/mysql/bin/mysqld  --defaults-file=/data/3309/my.cnf

[root@db01 system]# grep "ExecStart" mysqld3309.service
ExecStart=/application/mysql/bin/mysqld --defaults-file=/data/3309/my.cnf
[root@db01 system]# grep "ExecStart" mysqld3308.service
ExecStart=/application/mysql/bin/mysqld --defaults-file=/data/3308/my.cnf
[root@db01 system]# grep "ExecStart" mysqld3307.service
ExecStart=/application/mysql/bin/mysqld --defaults-file=/data/3307/my.cnf
[root@db01 system]# 

```
## 5 启动
```sh
# 启动文件授权
chown -R mysql.mysql /data/*
# 启动
systemctl start mysqld3307.service
systemctl start mysqld3308.service
systemctl start mysqld3309.service

## 验证
netstat -lnp|grep 330
mysql -S /data/3307/mysql.sock -e "select @@server_id"
mysql -S /data/3308/mysql.sock -e "select @@server_id"
mysql -S /data/3309/mysql.sock -e "select @@server_id"

``` 