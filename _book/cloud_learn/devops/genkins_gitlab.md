## 安装jenkins

> 使用docker安装jenkins
>
> /var/jenkins_home jenkins的家目录 
>
> 包含了jenkins的所有配置。 
>
> 以后要注意备份 /var/jenkins_home （以文件的方式固化的）
>
> 官方参考文档：**https://www.jenkins.io/zh/doc/book/installing/**

```sh
docker run \
-u root \
-d \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins-data:/var/jenkins_home \
-v /etc/localtime:/etc/localtime:ro \
-v /var/run/docker.sock:/var/run/docker.sock \
--restart=always \ jenkinsci/blueocean 

```

自己构建镜像 RUN的时候就把时区设置好 
如果是别人的镜像，docker hub，UTC； 容器运行时 同步挂载本地时间， -v/etc/localtime:/etc/localtime:ro

 jenkinsci/jenkins 是没有 blueocean插件的，得自己装 如果使用jenkinsci/blueocean镜像默认自带插件 
#/var/run/docker.sock 表示Docker守护程序通过其监听的基于Unix的套接字。 该映射允许 jenkinsci/blueocean 容器与Docker守护进程通信， 如果 jenkinsci/blueocean 容器需要实例化 其他Docker容器，则该守护进程是必需的。 如果运行声明式管道，其语法包含agent部分用 docker；例 如， agent { docker { ... } } 此选项是必需的。

### 插件源优化：



 #如果你的jenkins 安装插件装不上。使用这个镜像【 registry.cn- qingdao.aliyuncs.com/lfy/jenkins:plugins-blueocean 】默认访问账号/密码是 【admin/admin】



## 安装gitlab

