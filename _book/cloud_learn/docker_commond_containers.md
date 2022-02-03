# 容器命令

## 新建+启动容器

```sh
docker run [OPTIONS] IMAGE[COMMAD][ARG...]
```

> options说明：有些是一个减号，有些是两个减号
>
> --name="容器新名字"    为容器指定一个名称；
>
> -d: 后台运行容器并返回容器ID，也即启动守护式容器(后台运行)；
>
> -i：以交互模式运行容器，通常与 -t 同时使用；
>
> -t：为容器重新分配一个伪输入终端，通常与 -i 同时使用；
>
> 也即启动交互式容器(前台有伪终端，等待交互)；
>
> -P: 随机端口映射，大写P
>
> -p: 指定端口映射，小写p

| 参数                          | 说明                                 |
| :---------------------------- | :----------------------------------- |
| -p hostPort:containerPort     | 端口映射    -p      8080:80          |
| -p hostPort:containerPort     | 配置监听地址   -p 10.0.0.100:8000:80 |
| -p hostPort:containerPort:udp | 指定协议 -p 8080:80:tcp              |
| -p 81:80  -p 443:443          | 指定多个                             |

### 使用镜像centos:latest以交互模式启动一个容器,在容器内执行/bin/bash命令。

```SH
# docker run -it centos /bin/bash 
```

>参数说明：
>
>-i: 交互式操作。
>-t: 终端。
>centos : centos 镜像。
>/bin/bash：放在镜像名后的是命令，这里我们希望有个交互式 Shell，因此用的是 /bin/bash。
>要退出终端，直接输入 exit:

##       列出当前所有正在运行的容器

>```SH
># docker ps [OPTIONS]
>```
>
>OPTIONS说明（常用）：
>
>-a :列出当前所有正在运行的容器+历史上运行过的
>-l :显示最近创建的容器。
>-n：显示最近n个创建的容器。
>-q :静默模式，只显示容器编号。

##  推出容器

```sh
# exit
```

>run进去容器，exit退出，容器停止

```sh
  # ctrl+p+q
```

>   run进去容器，ctrl+p+q退出，容器不停止

##      启动已停止运行的容器

> ​     docker start 容器ID或者容器名



## 重启容器

>    docker restart 容器ID或者容器名



##      停止容器

> ​     docker stop 容器ID或者容器名



## 强制停止容器

> ​    docker kill 容器ID或容器名



##  删除已停止的容器

>docker rm 容器ID
>
>一次性删除多个容器实例
>
> docker rm -f $(docker ps -a -q)
>
> docker ps -a -q | xargs docker rm



##       启动守护式容器(后台服务器)

```sh
# docker run -d 容器名
# docker run -d centos
```

\#使用镜像centos:latest以后台模式启动一个容器

>问题：然后docker ps -a 进行查看, 会发现容器已经退出
>
>很重要的要说明的一点: Docker容器后台运行,就必须有一个前台进程.
>
>容器运行的命令如果不是那些一直挂起的命令（比如运行top，tail），就是会自动退出的。
>
>这个是docker的机制问题,比如你的web容器,我们以nginx为例，正常情况下,
>
>我们配置启动服务只需要启动响应的service即可。例如service nginx start
>
>但是,这样做,nginx为后台进程模式运行,就导致docker前台没有运行的应用,
>
>这样的容器后台启动后,会立即自杀因为他觉得他没事可做了.

### 前台交互式启动

```sh
# docker run -it redis:6.0.8
```



### 后台守护式启动

```sh
# docker run -d redis:6.0.8
```

###       查看容器日志

```sh
# docker logs 容器ID
```

###  查看容器内运行的进程

```sh
# docker top 容器ID
```

###  查看容器内部细节

```sh
# docker inspect 容器ID
```

### 进入正在运行的容器并以命令行交互