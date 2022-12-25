# Docker容器数据卷

## 什么是卷

卷就是目录或文件，存在于一个或多个容器中，由docker挂载到容器，但不属于联合文件系统，因此能够绕过Union File System提供一些用于持续存储或共享数据的特性：

卷的设计目的就是数据的持久化，完全独立于容器的生存周期，因此Docker不会在容器删除时删除其挂载的数据卷

 ```sh
docker run -it --privileged=true -v /宿主机绝对路径目录:/容器内目录      镜像名
 ```

##   **能干嘛**

将运用与运行的环境打包镜像，run后形成容器实例运行 ，但是我们对数据的要求希望是持久化的
Docker容器产生的数据，如果不备份，那么当容器实例删除后，容器内的数据自然也就没有了。
为了能保存数据在docker中我们使用卷。

>特点：
>
>1：数据卷可在容器之间共享或重用数据
>2：卷中的更改可以直接实时生效，爽
>3：数据卷中的更改不会包含在镜像的更新中
>4：数据卷的生命周期一直持续到没有容器使用它为止

##      **数据卷案例**

>命令
>
> 公式：docker run -it -v /宿主机目录:/容器内目录 ubuntu /bin/bash
>
### 创建容器

```sh
[root@wjh ~]# docker run -it --name myu3 --privileged=true -v /tmp/myHostData:/tmp/myDockerData ubuntu /bin/bash
root@f7ef2383e12d:/# 
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042008187.png)

### 查看数据卷是否挂载成功

```sh
 [root@wjh ~]# docker inspect 容器id
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042014021.png)

##      读写规则映射添加说明

### 读写(默认)

> 命令格式：docker run -it --privileged=true -v /宿主机绝对路径目录:/容器内目录:rw   镜像名

```sh
[root@wjh ~]# docker run -it --name myu4 --privileged=true -v /tmp/myHostData:/tmp/myDockerData:rw ubuntu /bin/bash
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042024320.png)

### 只读

容器实例内部被限制，只能读取不能写

> 命令格式：docker run -it --privileged=true -v /宿主机绝对路径目录:/容器内目录:ro   镜像名

```sh
[root@wjh ~]# docker run -it --name myu5 --privileged=true -v /tmp/myHostData:/tmp/myDockerData:ro ubuntu /bin/bash

```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042030476.png)

## 卷的继承和共享

> 命令格式：     docker run -it --privileged=true --volumes-from 父类 --name u2 ubuntu

```sh
docker run -it --privileged=true --volumes-from myu4 --name u2 ubuntu
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042038467.png)

