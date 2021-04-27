# Elasticsearch安装部署-rpm安装

``` shell
### 安装java
[root@db01 ~]# yum install -y java-1.8.0-openjdk.x86_64
[root@db01 ~]# mkdir  -p /data/es_soft/
[root@db01 ~]# cd /data/es_soft/
[root@db01 /data/es_soft]# rpm -ivh elasticsearch-6.6.0.rpm
[root@db01 /data/es_soft]# systemctl daemon-reload
[root@db01 /data/es_soft]# systemctl enable elasticsearch.service
Created symlink from /etc/systemd/system/multi-user.target.wants/elasticsearch.service to /usr/lib/systemd/system/elasticsearch.service.
[root@db01 /data/es_soft]# systemctl start elasticsearch.service
[root@db01 /data/es_soft]# systemctl status elasticsearch.service
● elasticsearch.service - Elasticsearch
   Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-04-22 21:38:35 CST; 10s ago
     Docs: http://www.elastic.co
 Main PID: 6738 (java)
   CGroup: /system.slice/elasticsearch.service
           └─6738 /bin/java -Xms1g -Xmx1g -XX:+UseConcMarkSweepGC...

Apr 22 21:38:35 db01 systemd[1]: Started Elasticsearch.
Apr 22 21:38:35 db01 systemd[1]: Starting Elasticsearch...
Apr 22 21:38:36 db01 elasticsearch[6738]: OpenJDK 64-Bit Server V...
Hint: Some lines were ellipsized, use -l to show in full.
```

``` shell
#文件目录说明
rpm -qc elasticsearch		#查看elasticsearch的所有配置文件

/etc/elasticsearch/elasticsearch.yml    #配置文件
/etc/elasticsearch/jvm.options.            #jvm虚拟机配置文件
/etc/init.d/elasticsearch  		#init启动文件
/etc/sysconfig/elasticsearch		#环境变量配置文件
/usr/lib/sysctl.d/elasticsearch.conf	#sysctl变量文件，修改最大描述符
/usr/lib/systemd/system/elasticsearch.service  #systemd启动文件
/var/lib/elasticsearch		# 数据目录
/var/log/elasticsearch		#日志目录
/var/run/elasticsearch		#pid目录
```

``` shell
#修改配置
[root@db01 /data/es_soft]# vim /etc/elasticsearch/elasticsearch.yml
network.host: 10.0.0.51
#
# Set a custom port for HTTP:
#
http.port: 9200

修改完配置文件后我们需要重启一下
[root@db01 /data/es_soft]# grep "^[a-Z]" /etc/elasticsearch/elasticsearch.yml
node.name: node-1
path.data: /data/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 10.0.0.51
http.port: 9200
bootstrap.memory_lock: true


#JVM 配置
# 不要超过32g
# 最大最小内存设置为一样
#配置文件设置锁定内存
#至少给服务器本身空余50%的内存
[root@db01 /etc/elasticsearch]# vim jvm.options 

-Xms512m
-Xmx512m


# 创建目录
[root@db01 /data/es_soft]# mkdir -p /data/elasticsearch
[root@db01 /data/es_soft]# chown -R elasticsearch:elasticsearch /data/elasticsearch/
[root@db01 /data/es_soft]# systemctl restart elasticsearch
[root@db01 /data/es_soft]# systemctl status elasticsearch

这个时候可能会启动失败，查看日志可能会发现是锁定内存失败
官方解决方案
https://www.elastic.co/guide/en/elasticsearch/reference/6.6/setup-configuration-memory.html
https://www.elastic.co/guide/en/elasticsearch/reference/6.6/setting-system-settings.html#sysconfig


### 修改启动配置文件或创建新配置文件
方法1: systemctl edit elasticsearch
方法2: vim /usr/lib/systemd/system/elasticsearch.service 
### 增加如下参数
[Service]
LimitMEMLOCK=infinity

### 重新启动
systemctl daemon-reload
systemctl restart elasticsearch




```

``` SHELL
可能遇到的错误
initial heap size [16777216] not equal to maximum heap size [536870912]; this can cause resize pauses and prevents mlockall from locking the entire heap
说明此时处于生产模式
修改elasticsearch.yml
discvery.type： single-node

```

