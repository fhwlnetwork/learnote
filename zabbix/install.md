# 安装----在线安装

##第一步 ：下载安装zabbix yum 源文件

```sh
[root@zabbix soft]#  rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
```
##第二步:下载安装zabbix服务端相关软件
```sh
#zabbix服务程序软件: zabbix-server-mysql
#zabbix服务web软件: zabbix-web-mysql httpd php
#数据库服务软件: mariadb-server
[root@zabbix soft]# yum install -y zabbix-server-mysql zabbix-web-mysql httpd php mariadb-server
```
##第三步：软件配置
```sh
#配置数据库密码
[root@zabbix soft]#  vim /etc/zabbix/zabbix_server.conf
126 DBPassword=zabbix
#配置时区
[root@zabbix soft]# vim /etc/httpd/conf.d/zabbix.conf
21         php_value date.timezone Asia/Shanghai

```
##第四步：编写配置数据库服务

```sh
[root@zabbix soft]#  systemctl start mariadb.service 
#    创建zabbix数据库--zabbix
#    创建数据库管理用户
[root@zabbix soft]# mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 2
Server version: 5.5.68-MariaDB MariaDB Server
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
MariaDB [(none)]>   create database zabbix character set utf8 collate utf8_bin;
Query OK, 1 row affected (0.00 sec)
MariaDB [(none)]>  grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
Query OK, 0 rows affected (0.00 sec)
#   在zabbix数据库中导入相应的表信息
[root@zabbix soft]# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix

```

##第五步：启动zabbix程序相关服务
```sh
# 数据库服务 zabbix服务 httpd服务
[root@zabbix soft]#     systemctl start zabbix-server.service httpd mariadb.service
#   配置开启自动启动
[root@zabbix soft]#     systemctl enable zabbix-server.service httpd mariadb.service

```
##第六步： 登录zabbix服务端web界面, 进行初始化配置
```text
10051  zabbix-server 服务端端口号
10050  zabbix-agent  客户端端口号
http://10.0.0.101/zabbix/setup.php
默认账户密码：Admin zabbix
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152118.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152142.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152228.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152329.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152419.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152429.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510152451.png)

# 一件部署脚本

```sh
#/!bin/bash
echo "-----------------下载安装zabbix yum 源文件--------------------"

rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
rpm -qa|grep zabbix
if [ $? -eq 0 ]
then
	echo "-----------------下载安装zabbix服务端相关软件-----------------"
	#zabbix服务程序软件: zabbix-server-mysql
	#zabbix服务web软件: zabbix-web-mysql httpd php
	#数据库服务软件: mariadb-server
	yum install -y zabbix-server-mysql zabbix-web-mysql httpd php mariadb-server
	rpm -qa | grep  zabbix-server-mysql
	if [ $? -ne 0 ]
	then
		echo " zabbix-server-mysql 安装失败"
		exit
	fi
	rpm -qa | grep  zabbix-web-mysql
        if [ $? -ne 0 ]
        then
                echo " zabbix-web-mysql 安装失败"
		exit
        fi
	echo "-----------------软件配置-------------------------------------"
	sed -i.bak 's/# DBPassword=/DBPassword=zabbix/g'  /etc/zabbix/zabbix_server.conf
	sed -i.bak 's#\# php_value date.timezone Europe/Riga#php_value date.timezone Asia/Shanghai#g' /etc/httpd/conf.d/zabbix.conf
	echo "-----------------软件配置-------------------------------------"
	systemctl start mariadb.service
	netstat -lnutp|grep 3306
	if [ $? -eq 0 ]
	then
		mysql -e "create database zabbix character set utf8 collate utf8_bin;"
		mysql -e " show databases"|grep zabbix
		if [ $? -ne 0 ]
		then
		 echo "创建数据库失败"
		 exit 
		fi
		mysql -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
		mysql -e " select * from mysql.user"|grep zabbix
                if [ $? -ne 0 ]
                then
                 echo "创建数据库管理用户失败"
                 exit
                fi
	else
		echo "数据库启动失败"
		exit
	fi
	zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
	echo "-----------------启动zabbix程序相关服务-----------------------"
	systemctl start zabbix-server.service httpd mariadb.service
	systemctl enable zabbix-server.service httpd mariadb.service
else
	echo "安装失败"
	exit
fi


```

