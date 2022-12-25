# 安装redis

##  从docker hub上(阿里云加速器)拉取redis镜像到本地标签为6.0.8

```sh
 # docker pull redis:6.0.8
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042137189.png)

## 在CentOS宿主机下新建目录/app/redis

```sh
[root@wjh conf]# mkdir -p /app/redis/
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042144521.png)

###  /app/redis目录下修改redis.conf文件

> 内容件[conf](../redis/redisconf.md)
>

## 创建容器

```sh
# docker run  -p 6379:6379 --name myr3 --privileged=true -v /app/redis/redis.conf:/etc/redis/redis.conf -v /app/redis/data:/data -d redis:6.0.8 redis-server /etc/redis/redis.conf
```

## 测速redis-cli链接

```sh
redis]# docker exec -it 9d8321580455 /bin/bash
root@9d8321580455:/data# redis-cli

```



![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042158484.png)