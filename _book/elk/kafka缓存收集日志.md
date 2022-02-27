# kafka和zookeeper安装
## zookeeper安装
### 准备工作
```shell
# 解压文件
[root@db01 /data/soft]#  tar zxf zookeeper-3.4.11.tar.gz -C /opt/
# 创建软连接
[root@db01 /data/soft]#  ln -s /opt/zookeeper-3.4.11/ /opt/zookeeper
# 安装java 环境
[root@db01 ~]# yum install -y java-1.8.0-openjdk.x86_64

```
![结构](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/zookeeper20210505224538.png)

### 安装配置zookeeper

``` shell
[root@db01 /data/soft]# mkdir -p /data/zookeeper
[root@db01 /data/soft]# cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
[root@db01 /data/soft]# vim /opt/zookeeper/conf/zoo.cfg
[root@db01 /data/soft]# cat >/opt/zookeeper/conf/zoo.cfg<<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper
clientPort=2181
server.1=10.0.0.51:2888:3888
server.2=10.0.0.52:2888:3888
server.3=10.0.0.53:2888:3888
EOF
#配置mid
[root@db01 /opt]# cat /data/zookeeper/mid
1

```
### 其他节点配置步骤和节点1一样,只是最后myid不一样而已
``` shell
[root@db01 /opt]# rsync -avz zookeeper* db02:/opt/
[root@db02 /opt]# cat /data/zookeeper/mid
2
[root@db01 /opt]# rsync -avz zookeeper* db03:/opt/
[root@db03 /opt]# cat /data/zookeeper/mid
3
```
### 启动服务&查看状态
``` shell 
#启动
[root@db01 /opt]# /opt/zookeeper/bin/zkServer.sh start
#查看状态
 [root@db01 /opt]# /opt/zookeeper/bin/zkServer.sh status
```
## kafka安装

### 准备工作
``` shell
[root@db01 /opt]# tar -xvzf /data/soft/kafka_2.11-1.0.0.tgz -C /opt
[root@db01 /opt]# ln -s /opt/kafka_2.11-1.0.0/ /opt/kafka
```
### 安装配置
``` shell
[root@db01 /opt/kafka]# vim /opt/kafka/config/server.properties
21 broker.id=1                                                                              
31 listeners=PLAINTEXT://10.0.0.51:9092           
60 log.dirs=/opt/kafka/logs                                     
103 log.retention.hours=24                                                                   
123 zookeeper.connect=10.0.0.51:2181,10.0.0.52:2181,10.0.0.53:2181

```
### 其他节点配置步骤和节点1一样,只是最listeners不一样而已
``` shell
[root@db01 /opt]# rsync -avz zookeeper* db02:/opt/
[root@db02 /opt]# sed -i 's#broker.id=1#broker.id=2#g' /opt/kafka/config/server.properties
[root@db02 /opt]# sed -i 's#10.0.0.51:9092#10.0.0.52:9092#g' /opt/kafka/config/server.properties
[root@db01 /opt]# rsync -avz zookeeper* db03:/opt/
[root@db03 /opt]# sed -i 's#broker.id=1#broker.id=3#g' /opt/kafka/config/server.properties
[root@db03 /opt]# sed -i 's#10.0.0.51:9092#10.0.0.53:9092#g' /opt/kafka/config/server.properties
```

### 节点1,可以先前台启动,方便查看错误日志

``` shell
[root@db01 /opt]# /opt/kafka/bin/kafka-server-start.sh  /opt/kafka/config/server.properties
[2021-05-06 17:06:33,642] INFO Result of znode creation is: OK (kafka.utils.ZKCheckedEphemeral)
[2021-05-06 17:06:33,644] INFO Registered broker 2 at path /brokers/ids/2 with addresses: EndPoint(10.0.0.52,9092,ListenerName(PLAINTEXT),PLAINTEXT) (kafka.utils.ZkUtils)
[2021-05-06 17:06:33,655] INFO Kafka version : 1.0.0 (org.apache.kafka.common.utils.AppInfoParser)
[2021-05-06 17:06:33,655] INFO Kafka commitId : aaa7af6d4a11b29d (org.apache.kafka.common.utils.AppInfoParser)
[2021-05-06 17:06:33,658] INFO [KafkaServer id=2] started (kafka.server.KafkaServer)
# 后台启动
[root@db01 /opt]## /opt/kafka/bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties
[root@db01 /opt]# tail -f /opt/kafka/logs/server.log
=========================
[2021-05-06 17:06:33,658] INFO [KafkaServer id=1] started (kafka.server.KafkaServer)

```

### 验证测试
``` shell
#创建一个topic
[root@db01 /opt]# /opt/kafka/bin/kafka-topics.sh --create  --zookeeper 10.0.0.51:2181,10.0.0.52:2181,10.0.0.53:2181 --partitions 3 --replication-factor 3 --topic kafkatest
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
Created topic "kafkatest".
# 获取topic
[root@db02 /opt/kafka]# /opt/kafka/bin/kafka-topics.sh  --list --zookeeper 10.0.0.51:2181,10.0.0.52:2181,10.0.0.53:2181

OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
kafkatest

```

#### kafka测试命令发送消息

``` shell

#创建一个名为messagetest的topic
 [root@db02 /opt/kafka]# /opt/kafka/bin/kafka-topics.sh --create --zookeeper 10.0.0.51:2181,10.0.0.52:2181,10.0.0.53:2181 --partitions 3 --replication-factor 3 --topic  messagetest
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
Created topic "messagetest".
#发送消息:注意,端口是 kafka的9092,而不是zookeeper的2181
 [root@db02 /opt/kafka]# /opt/kafka/bin/kafka-console-producer.sh --broker-list 10.0.0.51:9092,10.0.0.52:9092,10.0.0.53:9092 --topic  messagetestOpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
>
>biubiu
# 其他kafka服务器获取消息
[root@db01 /opt]# /opt/kafka/bin/kafka-console-consumer.sh --zookeeper 10.0.0.51:2181,10.0.0.52:2181,10.0.0.53:2181 --topic messagetest --from-beginning
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N
Using the ConsoleConsumer with old consumer is deprecated and will be removed in a future major release. Consider using the new consumer by passing [bootstrap-server] instead of [zookeeper].
hello
biubiu
```
## kafka收集日志配置

### 	 修改filebeat配置

``` shell
[root@kafka-175 conf.d]# cat >/etc/filebeat/filebeat.yml<<EOF
filebeat.inputs:
- type: log
  enabled: true 
  paths:
    - /var/log/nginx/access.log
  json.keys_under_root: true
  json.overwrite_keys: true
  tags: ["access"]
- type: log
  enabled: true 
  paths:
    - /var/log/nginx/error.log
  tags: ["error"]
setup.kibana:
  host: "10.0.0.51:5601"
output.kafka:
  hosts: ["10.0.0.51:9092","10.0.0.52:9092","10.0.0.53:9092"]
  topic: elklog
EOF


```

### 修改 logstash配置

```shell
cat >/etc/logstash/conf.d/kafka.conf<<EOF
input{
  kafka{
    bootstrap_servers=>"10.0.0.51:9092"
    topics=>["elklog"]
    group_id=>"logstash"
    codec => "json"
  }
}
filter {
  mutate {
    convert => ["upstream_time", "float"]                                                                                                                        
    convert => ["request_time", "float"]
  }
}
output {
    if "access" in [tags] {
      elasticsearch {
        hosts => "http://localhost:9200"
        manage_template => false
        index => "nginx_access-%{+yyyy.MM.dd}"
      }
    }
    if "error" in [tags] {
      elasticsearch {
        hosts => "http://localhost:9200"
        manage_template => false
        index => "nginx_error-%{+yyyy.MM.dd}"
      }
    }
}
EOF
```

### 重启服务

``` shell
#启动filebeat
[root@db01 ~]# systemctl restart filebeat
#启动logstash
#启动服务
[root@db01 /data/soft]#/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/redis.conf

```

