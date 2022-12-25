## 1、基础环境构建

![image-20220313230154555](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313230154555.png)

![image-20220313230235902](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313230235902.png)

![image-20220313230330595](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313230330595.png)

![image-20220313225108733](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313225108733.png)

![image-20220313225412325](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313225412325.png)

![image-20220313225423885](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313225423885.png)

![image-20220313230629346](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220313230629346.png)

## 2、打包jar

### dockerfile

```yaml
FROM openjdk:8-jdk
LABEL maintainer=leifengyang


#docker run -e PARAMS="--server.port 9090"
ENV PARAMS="--server.port=8080 --spring.profiles.active=prod --spring.cloud.nacos.discovery.server-addr=his-nacos.his:8848 --spring.cloud.nacos.config.server-addr=his-nacos.his:8848 --spring.cloud.nacos.config.namespace=prod --spring.cloud.nacos.config.file-extension=yml"
#修改镜像的时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
#拷贝jar文件
COPY target/*.jar /app.jar
#指定启动端口为8080
EXPOSE 8080

#
ENTRYPOINT ["/bin/sh","-c","java -Dfile.encoding=utf8 -Djava.security.egd=file:/dev/./urandom -jar app.jar ${PARAMS}"]
```

>env 环境变量(key =v) ,params由ENTRYPOINT引用
>
>--spring.profiles.active=prod   指定运行环境为生产
>
>--spring.cloud.nacos.discovery.server-addr=his-nacos.his:8848 指定nacos地址



### 制作镜像

```sh
[root@k8s-master /opt/soft/docker/ruoyi-auth]# docker build -t ruoyi-auth:v1.0 -f Dockerfile .
Sending build context to Docker daemon  88.26MB
Step 1/7 : FROM openjdk:8-jdk
8-jdk: Pulling from library/openjdk
0e29546d541c: Pull complete 
9b829c73b52b: Pull complete 
cb5b7ae36172: Pull complete 
6494e4811622: Pull complete 
668f6fcc5fa5: Pull complete 
c0879393b07e: Pull complete 
bef50c41a74d: Pull complete 
Digest: sha256:8a9d5c43f540e8d0c003c723a2c8bd20ae350a2efed6fb5719cae33b026f8e7c
Status: Downloaded newer image for openjdk:8-jdk
 ---> e24ac15e052e
Step 2/7 : LABEL maintainer=leifengyang
 ---> Running in 10c459ae4c18
Removing intermediate container 10c459ae4c18
 ---> 7542de6ebb68
Step 3/7 : ENV PARAMS="--server.port=8080 --spring.profiles.active=prod --spring.cloud.nacos.discovery.server-addr=his-nacos.his:8848 --spring.cloud.nacos.config.server-addr=his-nacos.his:8848 --spring.cloud.nacos.config.namespace=prod --spring.cloud.nacos.config.file-extension=yml"
 ---> Running in c8775ab87014
Removing intermediate container c8775ab87014
 ---> 83411e1271e0
Step 4/7 : RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone
 ---> Running in 1eb3c41fe1bb
Removing intermediate container 1eb3c41fe1bb
 ---> dda389346a2f
Step 5/7 : COPY target/*.jar /app.jar
 ---> f76ce70d0dc9
Step 6/7 : EXPOSE 8080
 ---> Running in 60a64890c073
Removing intermediate container 60a64890c073
 ---> f660e42afce2
Step 7/7 : ENTRYPOINT ["/bin/sh","-c","java -Dfile.encoding=utf8 -Djava.security.egd=file:/dev/./urandom -jar app.jar ${PARAMS}"]
 ---> Running in 9aa06e6d2d22
Removing intermediate container 9aa06e6d2d22
 ---> ef23430dc684
Successfully built ef23430dc684
Successfully tagged ruoyi-auth:v1.0

```

![image-20220319154302998](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220319154302998.png)

### 推送镜像到阿里云

> 开通阿里云容器服务
>
> ​	创建一个名称空间
>
> 推送镜像到阿里云

```sh
#登录阿里云
sudo docker login --username=1355997****@139.com registry.cn-hangzhou.aliyuncs.com

#把本地镜像，改名成符合阿里云名字规范的镜像
# $ docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/镜像:[镜像版本号]
docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/
$ docker push registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/镜像:[镜像版本号]
```

![image-20220319154435202](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220319154435202.png)

#### 若依所有的镜像

```sh
$ docker pull registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/ruoyi-visual-monitor:V1.0
$ docker pull registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/ruoyi-job:V1.0
$ docker pull registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/ruoyi-auth:V1.0
$ docker pull registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/ruoyi-gateway:V1.0
$ docker pull registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/ruoyi-file:V1.0
$ docker pull registry.cn-hangzhou.aliyuncs.com/wjh_ruoyi/ruoyi-system:V1.0
```



