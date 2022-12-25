# 安装mysql

## 查找镜像

```sh
# docker search mysql
```

## 拉取镜像

```sh
# docker pull mysql:5.7
```

##  创建容器

```sh
docker run -d -p 3306:3306 --privileged=true -v /wjhuse/mysql/log:/var/log/mysql -v /wjhuse/mysql/data:/var/lib/mysql -v /wjhuse/mysql/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=123456  --name mysql mysql:5.7
```

> 说明：
>
>  -v /wjhuse/mysql/log:/var/log/mysql					-------------------------指定log目录
>
> -v /wjhuse/mysql/data:/var/lib/mysql 	  			--------------------------指定数据存放目录
>
> -v /wjhuse/mysql/conf:/etc/mysql/conf.d			 ---------------------------指定配置文件目录

## 创建配置文件

```sh
cat >/wjhuse/mysql/conf/my.conf<<EOF
[client]
default_character_set=utf8
[mysqld]
collation_server = utf8_general_ci
character_set_server = utf8
EOF
```

##       重新启动mysql容器实例再重新进入并查看字符编码

```sh
# docker restart mysql
# docker exec -it msyql bash
root@2c882c696216:/# mysql -uroot -p123456
mysql> SHOW VARIABLES LIKE 'character%';
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202042126627.png)