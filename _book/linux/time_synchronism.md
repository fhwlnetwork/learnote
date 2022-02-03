# 时间管理

## 1、查看时间信息:

```shell
[root@web01 /etc]# date
Sun May  9 16:06:04 CST 2021
```

## 2、 调整时间显示格式

```shell
[root@web01 /etc]# date +%F
2021-05-09
[root@web01 /etc]# date "+%F %T"
2021-05-09 16:07:27
[root@web01 /etc]# date "+%Y +%F %T"
2021 +2021-05-09 16:07:58
[root@web01 /etc]# date "+%Y-%m +%F %T"
2021-05 +2021-05-09 16:09:03
[root@web01 /etc]# date "+%Y-%m-%d +%F %T"
2021-05-09 +2021-05-09 16:09:15
#显示历史时间信息:
[root@web01 /etc]#  date +%F -d "-2day"
2021-05-07
[root@web01 /etc]# date +%F -d "1 day ago"
2021-05-08
#显示未来时间信息:
[root@web01 /etc]# # date  -d "+2day"
[root@web01 /etc]#  date  -d "+2day"
Tue May 11 16:11:32 CST 2021
[root@web01 /etc]# date  -d "2day"
Tue May 11 16:11:47 CST 2021

```

## 3、如何实际修改系统时间

``` shell
[root@web01 /etc]# date -s "2020-04-17"
Fri Apr 17 00:00:00 CST 2020
[root@web01 /etc]# date
Fri Apr 17 00:00:02 CST 2020
[root@web01 /etc]# date -s "2020/04/17 14:00"
Fri Apr 17 14:00:00 CST 2020
[root@web01 /etc]# 

```

## 4、时间同步

```shell
[root@web01 /etc]# yum install -y ntpdate ntp
#配置ntp
[root@web01 /var/lib/ntp]# vim /etc/ntp.conf 
 21 #server 0.centos.pool.ntp.org iburst
 22 #server 1.centos.pool.ntp.org iburst
 23 #server 2.centos.pool.ntp.org iburst
 24 #server 3.centos.pool.ntp.org iburst
 25 server ntp1.aliyun.com

在ntpd服务启动时，先使用ntpdate命令同步时间：
[root@web01 ~]# ntpdate ntp1.aliyun.com
[root@web01 /var/lib/ntp]# systemctl restart ntpd


```

