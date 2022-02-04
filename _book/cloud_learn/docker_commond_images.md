# 基础命令

## 帮助启动类命令

启动docker： systemctl start docker
停止docker： systemctl stop docker
重启docker： systemctl restart docker
查看docker状态： systemctl status docker
开机启动： systemctl enable docker
查看docker概要信息： docker info
查看docker总体帮助文档： docker --help
查看docker命令帮助文档： docker 具体命令 --help

##  镜像命令

###  列出本地主机上的镜像

```sh
# docker images [options]
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20220204100006.png)

>**各个选项说明**:
>
>REPOSITORY：表示镜像的仓库源
>TAG：镜像的标签版本号
>IMAGE ID：镜像ID
>CREATED：镜像创建时间
>SIZE：镜像大小

 同一仓库源可以有多个 TAG版本，代表这个仓库源的不同个版本，我们使用 REPOSITORY:TAG 来定义不同的镜像。

如果你不指定一个镜像的版本标签，例如你只使用 ubuntu，docker 将默认使用 ubuntu:latest 镜像

>  **OPTIONS说明**：
>
>   -a :列出本地所有的镜像（含历史映像层）
>    -q :只显示镜像ID。
>
>```sh
># docker images -a
># docker images -q
># docker images -aq
>
>```
>
>

![image-20220204100219941](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204100219941.png)

###  某个XXX镜像名字

```sh
# docker search [OPTIONS] 镜像名字
```

> ![image-20220204100355734](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204100355734.png)
>
> 各项参数说明：
>
> name:镜像名称
> desription:镜像说明
> stars:点赞数量
> offical:是否官方的
> automated:是否自动构建的

>OPTIONS说明：
>
> --limit : 只列出N个镜像，默认25个
>
>```sh
># docker search --limit 5 redis
>```
>
>![image-20220204100440204](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204100440204.png)



###   docker pull 某个XXX镜像名字

 docker pull 镜像名字[:TAG]

docker pull 镜像名字

 没有TAG就是最新版等价于docker pull 镜像名字:latest

```sh
#  docker pull ubuntu
```

![image-20220204100617821](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204100617821.png)

###  查看镜像/容器/数据卷所占的空间

```sh
#	docker system df
```

>images:镜像
>
>containers:容器
>
>local volumes：本地卷
>
>build cache:构建缓存 

![image-20220204100659436](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204100659436.png)

### docker rmi 某个XXX镜像名字ID
####  删除单个
docker rmi -f 镜像ID

![image-20220204100801318](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204100801318.png)

#### 删除多个
docker rmi -f 镜像名1:TAG 镜像名2:TAG
#### 删除全部
docker rmi -f $(docker images -qa)

> <a style="color:red;">危险操作，没事别瞎执行</a>

![image-20220204120110566](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204120110566.png)