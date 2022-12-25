# 安装tomact

##  docker hub上面查找tomcat镜像

```sh
#  docker search tomcat
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042049925.png)

## 从docker hub上拉取tomcat镜像到本地

```sh
 # docker pull tomact
```

## 确定拉取的镜像

```sh
# docker images
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042055696.png)

##  使用tomcat镜像创建容器实例(也叫运行镜像)

```sh 
docker run -it -p 8080:8080 tomcat
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042057525.png)

### 404问题处理

> 把webapps.dist目录换成webapps

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042102799.png)

## 面修改版安装

```sh
# docker pull billygoo/tomcat8-jdk8
# docker run -d -p 8080:8080 --name mytomcat8 billygoo/tomcat8-jdk8

```

