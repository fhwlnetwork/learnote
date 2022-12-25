## NFS存储服务概念介绍



 NFS是Network File System的缩写,中文意思是网络文件共享系统，它的主要功能是通过网络（一般是局域网）让不同的主机系统之间可以共享文件或目录

​	存储服务的种类,用于中小型企业: 实现数据共享存储

## NFS存储服务作用

​    (1) 实现数据的共享存储

​    (2) 编写数据操作管理

​    (3) 节省购买服务器磁盘开销 淘宝--上万 用电开销	

##  NFS服务部署流程	

### 第一个历程: 下载安装软件

```sh
rpm -qa|grep -E "nfs|rpc"
yum install -y nfs-utils rpcbind
```

###  第二个历程: 编写nfs服务配置文件

```sh

echo "/data   172.16.1.0/24(rw,sync)" >> /etc/exports

```

>```tex
>参数说明：
>
>01: 设置数据存储的目录 /data
>02: 设置网络一个白名单 (允许哪些主机连接到存储服务器进行数据存储)
>03: 配置存储目录的权限信息 存储目录一些功能
>```

  ### 第三个历程: 创建一个存储目录

```sh
	mkdir /data
	chown nfsnobody.nfsnobody /data
```

>	​	ps:必须修改权限，不修改权限，客户端挂在后，创建文件时将会报错
>
>	(tocuh :cannot touch 'xxxxx' :Permission denied)

		###  第四个历程: 启动服务程序

```sh
#先启动 rpc服务
	systemctl start rpcbind.service 
    systemctl enable rpcbind.service
#	再启动 nfs服务
	systemctl start nfs
    systemctl enable nfs
```

## 	客户端部署

### 	第一个历程: 安装nfs服务软件

​	ps:必须安装此服务，如果不安装，则在关在的时候无法识别磁盘格式，将会报错

```sh
yum install -y nfs-utils
```

###   第二个历程查看挂载点

```sh
#执行以下命令检查 nfs 服务器端是否有设置共享目录
# showmount -e $(nfs服务器的IP)
showmount -e 172.31.0.201
```



### 第三个历程: 查看挂载点

```sh
mount -t nfs 172.31.0.201:/data  /mnt 
```





