# Docker网络

## 是什么

docker不启动，默认网络情况下网卡为 ens33/eth0 lo virbro

> virbro说明：
>
> 在CentOS7的安装过程中如果有选择相关虚拟化的的服务安装系统后，启动网卡时会发现有一个以网桥连接的私网地址的virbr0网卡(virbr0网卡：它还有一个固定的默认IP地址192.168.122.1)，是做虚拟机网桥的使用的，其作用是为连接其上的虚机网卡提供 NAT访问外网的功能。

![image-20220207153527587](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071537091.png)

docker启动后，网络情况

![image-20220207153853102](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220207153853102.png)

## 常用基本命令

### 查看网络

```sh
docker netwokr ls
```

![image-20220207154925404](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071549526.png)

### 查看网络源数据

```sh
[root@wjh ~]# docker network inspect bridge
```

![image-20220207155321421](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071553493.png)

### 创建、删除网络

```sh
[root@wjh ~]# docker network create test_network
[root@wjh ~]# docker network ls
[root@wjh ~]# docker network rm test_network
```



![image-20220207155709139](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071557208.png)

## 能干嘛

1、容器间的互联和通信以及端口映射

2、容器IP变动时候可以通过服务名直接网络通信而不受到影响

## 网络模式

### 网络模式

>bridge模式：使用--network  bridge指定，默认使用docker0
>
>host模式：使用--network host指定
>
>none模式：使用--network none指定
>
>container模式：使用--network container:NAME或者容器ID指定

#### bridge

ocker 服务默认会创建一个 docker0 网桥（其上有一个 docker0 内部接口），该桥接网络的名称为docker0，它在内核层连通了其他的物理或虚拟网卡，这就将所有容器和本地主机都放到同一个物理网络。Docker 默认指定了 docker0 接口 的 IP 地址和子网掩码，让主机和容器之间可以通过网桥相互通信。

查看 bridge 网络的详细信息，并通过 grep 获取名称项

```sh
[root@wjh ~]# docker network inspect bridge | grep name
            "com.docker.network.bridge.name": "docker0",
[root@wjh ~]# ifconfig | grep docker
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
[root@wjh ~]# 

```

1、Docker使用Linux桥接，在宿主机虚拟一个Docker容器网桥(docker0)，Docker启动一个容器时会根据Docker网桥的网段分配给容器一个IP地址，称为Container-IP，同时Docker网桥是每个容器的默认网关。因为在同一宿主机内的容器都接入同一个网桥，这样容器之间就能够通过容器的Container-IP直接通信。

2、docker run 的时候，没有指定network的话默认使用的网桥模式就是bridge，使用的就是docker0。在宿主机ifconfig,就可以看到docker0和自己create的network(后面讲)eth0，eth1，eth2……代表网卡一，网卡二，网卡三……，lo代表127.0.0.1，即localhost，inet addr用来表示网卡的IP地址

3、网桥docker0创建一对对等虚拟设备接口一个叫veth，另一个叫eth0，成对匹配。
   3.1 整个宿主机的网桥模式都是docker0，类似一个交换机有一堆接口，每个接口叫veth，在本地主机和容器内分别创建一个虚拟接口，并让他们彼此联通（这样一对接口叫veth pair）；
   3.2 每个容器实例内部也有一块网卡，每个接口叫eth0；
   3.3 docker0上面的每个veth匹配某个容器实例内部的eth0，两两配对，一一匹配。
 通过上述，将宿主机上的所有容器都连接到这个内部网络上，两个容器在同一个网络下,会从这个网关下各自拿到分配的ip，此时两个容器的网络是互通的。

![image-20220207161419350](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071614441.png)

##### 案例

```sh
docker run -d -p 8081:8080   --name tomcat81 billygoo/tomcat8-jdk8
docker run -d -p 8082:8080   --name tomcat82 billygoo/tomcat8-jdk8
```

![image-20220207164918893](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071649029.png)

#### host

直接使用宿主机的 IP 地址与外界进行通信，不再需要额外进行NAT 转换。

```sh
docker run -d -p 8083:8080 --network host --name tomcat83 billygoo/tomcat8-jdk8
```

![image-20220207165209333](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071652000.png)

>问题：
>     docke启动时总是遇见标题中的警告
>原因：
>    docker启动时指定--network=host或-net=host，如果还指定了-p映射端口，那这个时候就会有此警告，
>并且通过-p设置的参数将不会起到任何作用，端口号会以主机端口号为主，重复时则递增。
>解决:
>    解决的办法就是使用docker的其他网络模式，例如--network=bridge，这样就可以解决问题，或者直接无视
>
>```sh
>docker run -d                          --network host --name tomcat84 billygoo/tomcat8-jdk8
>```
>
>![image-20220207165328614](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071653674.png)

![image-20220207165939319](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071659401.png)

在浏览器访问容器内的tomcat83看到访问成功，因为此时容器的IP借用主机的，所以容器共享宿主机网络IP，这样的好处是外部主机与容器可以直接通信。

![image-20220207170828808](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071708931.png)

#### node

禁用网络功能，只有lo标识(就是127.0.0.1表示本地回环)

```sh
docker run -d -p 8084:8080 --network none --name tomcat84 billygoo/tomcat8-jdk8
```

#### container

新建的容器和已经存在的一个容器共享一个网络ip配置而不是和宿主机共享。新创建的容器不会创建自己的网卡，配置自己的IP，而是和一个指定的容器共享IP、端口范围等。同样，两个容器除了网络方面，其他的如文件系统、进程列表等还是隔离的。



##### 案例

```sh
docker run -it                                                    --name alpine1  alpine /bin/sh
docker run -it --network container:alpine1 --name alpine2  alpine /bin/sh
```

![image-20220207172611021](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071726120.png)

当alpine退出后再看alpine2的IP只剩下lo

![image-20220207172912944](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071729060.png)

#### 自定义网络

自定义桥接网络,自定义网络默认使用的是桥接网络bridge

##### 案例

创建网络

```sh
docker create wjh_network
docker network ls
```

![image-20220207173524199](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071735264.png)

新建容器加入上一步新建的自定义网络

```sh
docker run -d -p 8081:8080 --network wjh_network  --name tomcat81 billygoo/tomcat8-jdk8
docker run -d -p 8082:8080 --network wjh_network  --name tomcat82 billygoo/tomcat8-jdk8

```

![image-20220207174015113](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202071740216.png)

>自定义网络本身就维护好了主机名和ip的对应关系（ip和域名都能通）

## 整体说明

从其架构和运行流程来看，Docker 是一个 C/S 模式的架构，后端是一个松耦合架构，众多模块各司其职。 

Docker 运行的基本流程为：

1 用户是使用 Docker Client 与 Docker Daemon 建立通信，并发送请求给后者。
2 Docker Daemon 作为 Docker 架构中的主体部分，首先提供 Docker Server 的功能使其可以接受 Docker Client 的请求。
3 Docker Engine 执行 Docker 内部的一系列工作，每一项工作都是以一个 Job 的形式的存在。
4 Job 的运行过程中，当需要容器镜像时，则从 Docker Registry 中下载镜像，并通过镜像管理驱动 Graph driver将下载镜像以Graph的形式存储。
5 当需要为 Docker 创建网络环境时，通过网络管理驱动 Network driver 创建并配置 Docker 容器网络环境。
6 当需要限制 Docker 容器运行资源或执行用户指令等操作时，则通过 Execdriver 来完成。
7 Libcontainer是一项独立的容器管理包，Network driver以及Exec driver都是通过Libcontainer来实现具体对容器进行的操作。