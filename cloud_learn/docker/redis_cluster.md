# redis集群

## 新建6个docker容器redis实例

```sh
docker run -d --name redis-node-1 --net host --privileged=true -v /data/redis/share/redis-node-1:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6381
docker run -d --name redis-node-2 --net host --privileged=true -v /data/redis/share/redis-node-2:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6382
docker run -d --name redis-node-3 --net host --privileged=true -v /data/redis/share/redis-node-3:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6383
docker run -d --name redis-node-4 --net host --privileged=true -v /data/redis/share/redis-node-4:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6384
docker run -d --name redis-node-5 --net host --privileged=true -v /data/redis/share/redis-node-5:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6385
docker run -d --name redis-node-6 --net host --privileged=true -v /data/redis/share/redis-node-6:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6386

docker ps -a 
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062153722.png)

>docker run																			---------------创建并运行docker容器实例
>name redis-node-6										  				---------------容器名字
>net host																				 ---------------使用宿主机的IP和端口，默认
>privileged=true												 				----------------获取宿主机root用户权限
>-v /data/redis/share/redis-node-6:/data				---------------容器卷，宿主机地址:docker内部地
>redis:6.0.8																			---------------redis镜像和版本号
>cluster-enabled yes														---------------开启redis集群
>appendonly yes																--------------开启持久化
>port 6386																			 -------------redis端口号

## 进入容器redis-node-1并为6台机器构建集群关系

### 进入容器

```sh
docker exec -it redis-node-1 /bin/bash
```

### 构建主从关系

> //注意，进入docker容器后才能执行一下命令，且注意自己的真实IP地址

```sh
redis-cli --cluster create 10.0.0.200:6381 10.0.0.200:6382 10.0.0.200:6383 10.0.0.200:6384 10.0.0.200:6385 10.0.0.200:6386 --cluster-replicas 1
# 在弹出信息后输入yes进行确认
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062210448.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062212097.png)

### 链接进入6381作为切入点，查看集群状态

```sh
root@wjh:/data# redis-cli -p 6381
127.0.0.1:6381> key *
127.0.0.1:6381> cluster info
127.0.0.1:6381> cluster nodes
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062215516.png)

## 主从容错切换迁移案例

### 数据读写存储

> 防止路由失效加参数-c并新增两个key

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062223320.png)

### 容错切换迁移

```sh
docker stop redis-node-1
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062234755.png)

### 先还原之前的3主3从

```sh
[root@wjh ~]# docker start redis-node-1
[root@wjh ~]# docker stop redis-node-4
[root@wjh ~]# docker start redis-node-4

```

## 查看集群状态

```sh
[root@wjh ~]# docker start redis-node-4
[root@wjh ~]# docker exec -it redis-node-1 /bin/bash

```



![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062248358.png)

## <a style="color:red">主从扩容案例</a>

### 新建6387、6388两个节点+新建后启动+查看是否8节点

```sh
docker run -d --name redis-node-7 --net host --privileged=true -v /data/redis/share/redis-node-7:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6387
docker run -d --name redis-node-8 --net host --privileged=true -v /data/redis/share/redis-node-8:/data redis:6.0.8 --cluster-enabled yes --appendonly yes --port 6388
docker ps
```

### 进入6387容器实例内部

```sh
[root@wjh ~]# docker exec -it redis-node-7 /bin/bash
```

#### 将新增的6387节点(空槽号)作为master节点加入原集群

将新增的6387作为master节点加入集群
redis-cli --cluster add-node 自己实际IP地址:6387 自己实际IP地址:6381
6387 就是将要作为master新增节点
6381 就是原来集群节点里面的领路人，相当于6387拜拜6381的码头从而找到组织加入集群

```sh
root@wjh:/data# redis-cli --cluster add-node 10.0.0.200:6387 10.0.0.200:6381
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062254264.png)

### 检查集群情况第1次

>#进入docker exec -it redis-node-7 /bin/bash
>#redis-cli --cluster check 真实ip地址:6381

```sh
[root@wjh ~]# docker exec -it redis-node-7 /bin/bash
root@wjh:/data# redis-cli --cluster check 10.0.0.200:6381
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062301128.png)

### 重新分派槽号

>重新分派槽号
>命令:redis-cli --cluster reshard IP地址:端口号
>redis-cli --cluster reshard 10.0.0.200:6381

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062340055.png)

### 查看集群情况

>为什么6387是3个新的区间，以前的还是连续？
>重新分配成本太高，所以前3家各自匀出来一部分，从6381/6382/6383三个旧节点分别匀出1364个坑位给新节点6387

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062342324.png)

### 为主节点6387分配从节点6388

> 命令：redis-cli --cluster add-node ip:新slave端口 ip:新master端口 --cluster-slave --cluster-master-id 新主机节点ID
>
> ```sh
> redis-cli --cluster add-node 10.0.0.200:6388 10.0.0.200:6387 --cluster-slave --cluster-master-id f0b4e73f8e334de67a2c91601d5f874a473e0578-------这个是6387的编号，按照自己实际情况
> ```
>
> 



![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062348723.png)

### 查看集群情况

```sh
redis-cli --cluster check 10.0.0.200:6381
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062349214.png)

## 主从缩容案例

> 目的：6387和6388下线

### 检查集群情况1获得6388的节点ID

```sh
docker exec -it redis-node-1 /bin/bash
redis-cli --cluster check 10.0.0.200:6382
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062355231.png)

###  将6388删除从集群中将4号从节点6388删除

>命令：redis-cli --cluster del-node ip:从机端口 从机6388节点ID
>
>```sh
>redis-cli --cluster del-node 10.0.0.200:6388 a0f8238e18d27339bd79a2868a3fbd5efbc5cdc8
>```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202062357981.png)

### 将6387的槽号清空，重新分配，本例将清出来的槽号都给6381

```sh
redis-cli --cluster reshard 10.0.0.200:6381
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202070003666.png)

### 检查集群情况第二次

```sh
root@wjh:/data# redis-cli --cluster check 10.0.0.200:6381
10.0.0.200:6381 (69f01736...) -> 0 keys | 8192 slots | 1 slaves.
10.0.0.200:6383 (10f3bc0e...) -> 0 keys | 4096 slots | 1 slaves.
10.0.0.200:6387 (f0b4e73f...) -> 0 keys | 0 slots | 0 slaves.
10.0.0.200:6382 (2de7935a...) -> 0 keys | 4096 slots | 1 slaves.
```



![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202070004537.png)

### 将6387删除

>命令：redis-cli --cluster del-node ip:端口 6387节点ID

```sh
redis-cli --cluster del-node 10.0.0.200:6387 f0b4e73f8e334de67a2c91601d5f874a473e0578
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202070007464.png)

### 检查集群情况第三次

```sh
root@wjh:/data#  redis-cli --cluster check 10.0.0.200:6381
10.0.0.200:6381 (69f01736...) -> 0 keys | 8192 slots | 1 slaves.
10.0.0.200:6383 (10f3bc0e...) -> 0 keys | 4096 slots | 1 slaves.
10.0.0.200:6382 (2de7935a...) -> 0 keys | 4096 slots | 1 slaves.
```





