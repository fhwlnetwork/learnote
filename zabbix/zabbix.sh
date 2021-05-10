#/!bin/bash
echo "-----------------下载安装zabbix yum 源文件--------------------"

rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/zabbix/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
rpm -qa|grep zabbix
if [ $? -eq 0]
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

echo "-----------------软件配置-------------------------------------"
echo "-----------------编写配置数据库服务---------------------------"
echo "-----------------启动zabbix程序相关服务-----------------------"

