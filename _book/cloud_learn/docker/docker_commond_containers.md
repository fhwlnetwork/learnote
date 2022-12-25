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

### <a name="交互式">使用镜像centos:latest以交互模式启动一个容器,在容器内执行/bin/bash命令。</a>

```sh
# docker run -it centos /bin/bash 
```

>参数说明：
>
>-i: 交互式操作。
>-t: 终端。
>centos : centos 镜像。
>/bin/bash：放在镜像名后的是命令，这里我们希望有个交互式 Shell，因此用的是 /bin/bash。
>要退出终端，直接输入 exit:
>
>![image-20220204102219542](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204102219542.png)

##       列出当前所有正在运行的容器

>```sh
># docker ps [OPTIONS]
>```
>
>OPTIONS说明（常用）：
>
>-a :列出当前所有正在运行的容器+历史上运行过的
>-l :显示最近创建的容器。
>-n：显示最近n个创建的容器。
>-q :静默模式，只显示容器编号。

![image-20220204102515251](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204102515251.png)

##  退出容器

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

![image-20220204103144440](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204103144440.png)

## 重启容器

>    docker restart 容器ID或者容器名

##      停止容器

> ​     docker stop 容器ID或者容器名

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204103111540-20220204103247664.png)

## 强制停止容器

> ​    docker kill 容器ID或容器名

![image-20220204103342655](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204103342655.png)

##  删除已停止的容器

>docker rm 容器ID
>
>一次性删除多个容器实例
>
> docker rm -f $(docker ps -a -q)
>
> docker ps -a -q | xargs docker rm

![image-20220204120030408](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204120030408.png)

##       启动守护式容器(后台服务器)

```sh
# docker run -d 镜像名称
```

\#使用镜像centos:latest以后台模式启动一个容器

>```sh
># docker run -d centos
>```
>
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

> <a href="#交互式">操作截图见第一节</a>

### 后台守护式启动

```sh
# docker run -d redis:6.0.8
```

![image-20220204103901575](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204103901575.png)

###       查看容器日志

```sh
# docker logs 容器ID
```

![image-20220204104725953](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204104725953.png)

###  查看容器内运行的进程

```sh
# docker top 容器ID
```

![image-20220204104749617](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204104749617.png)

###  查看容器内部细节

```sh
# docker inspect 容器ID
```

![image-20220204104821731](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204104821731.png)

### 进入正在运行的容器并以命令行交互

### docker exec进入容器

```sh
# docker exec -it 容器ID bash
```

![image-20220204105819180](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204105819180.png)

![image-20220204105842456](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204105842456.png)

### docker attach 重新进入容器

```sh
# docker attach
```

![image-20220204110159671](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204110159671.png)

>**attach与exec比对**
>
>attach 直接进入容器启动命令的终端，不会启动新的进程用exit退出，会导致容器的停止。
>exec 是在容器中打开新的终端，并且可以启动新的进程用exit退出，不会导致容器的停止。
>
><a style="color:red">生产中推荐大家使用 docker exec 命令，因为退出容器终端，不会导致容器的停止。</a>

#### 用之前的redis容器实例进入试试

docker exec -it 容器ID /bin/bash

docker exec -it 容器ID /bin/bash

![image-20220204110803356](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204110803356.png)

### 从容器内拷贝文件到主机上

> 容器→主机
> docker cp 容器ID:容器内路径 目的主机路径

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204112203766.png)

### 导入和导出容器

​	export 导出容器的内容留作为一个tar归档文件[对应import命令]

​	import 从tar包中的内容创建一个新的文件系统再导入为镜像[对应export]

​	案例

​		docker export 容器ID > 文件名.tar

![image-20220204113605251](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204113605251.png)

​		cat 文件名.tar | docker import - 镜像用户/镜像名:镜像版本号

![image-20220204113659546](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204113659546.png)

## 常用命令

attach   Attach to a running container         # 当前 shell 下 attach 连接指定运行镜像 

build   Build an image from a Dockerfile        # 通过 Dockerfile 定制镜像 

commit   Create a new image from a container changes  # 提交当前容器为新的镜像 

cp     Copy files/folders from the containers filesystem to the host path  #从容器中拷贝指定文件或者目录到宿主机中 

create   Create a new container             # 创建一个新的容器，同 run，但不启动容器 

diff    Inspect changes on a container's filesystem  # 查看 docker 容器变化 

events   Get real time events from the server      # 从 docker 服务获取容器实时事件 

exec    Run a command in an existing container     # 在已存在的容器上运行命令 

export   Stream the contents of a container as a tar archive  # 导出容器的内容流作为一个 tar 归档文件[对应 import ] 

history  Show the history of an image          # 展示一个镜像形成历史 

images   List images                  # 列出系统当前镜像 

import   Create a new filesystem image from the contents of a tarball # 从tar包中的内容创建一个新的文件系统映像[对应export] 

info    Display system-wide information        # 显示系统相关信息 

inspect  Return low-level information on a container  # 查看容器详细信息 

kill    Kill a running container            # kill 指定 docker 容器 

load    Load an image from a tar archive        # 从一个 tar 包中加载一个镜像[对应 save] 

login   Register or Login to the docker registry server   # 注册或者登陆一个 docker 源服务器 

logout   Log out from a Docker registry server      # 从当前 Docker registry 退出 

logs    Fetch the logs of a container         # 输出当前容器日志信息 

port    Lookup the public-facing port which is NAT-ed to PRIVATE_PORT   # 查看映射端口对应的容器内部源端口 

pause   Pause all processes within a container     # 暂停容器 

ps     List containers                # 列出容器列表 

pull    Pull an image or a repository from the docker registry server  # 从docker镜像源服务器拉取指定镜像或者库镜像 

push    Push an image or a repository to the docker registry server   # 推送指定镜像或者库镜像至docker源服务器 

restart  Restart a running container          # 重启运行的容器 

rm     Remove one or more containers         # 移除一个或者多个容器 

rmi    Remove one or more images    # 移除一个或多个镜像[无容器使用该镜像才可删除，否则需删除相关容器才可继续或 -f 强制删除] 

run    Run a command in a new container        # 创建一个新的容器并运行一个命令 

save    Save an image to a tar archive         # 保存一个镜像为一个 tar 包[对应 load] 

search   Search for an image on the Docker Hub     # 在 docker hub 中搜索镜像 

start   Start a stopped containers           # 启动容器 

stop    Stop a running containers           # 停止容器 

tag    Tag an image into a repository         # 给源中镜像打标签 

top    Lookup the running processes of a container  # 查看容器中运行的进程信息 

unpause  Unpause a paused container           # 取消暂停容器 

version  Show the docker version information      # 查看 docker 版本号 

wait    Block until a container stops, then print its exit code  # 截取容器停止时的退出状态值 
