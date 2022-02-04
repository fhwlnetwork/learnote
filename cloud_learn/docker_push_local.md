# 推送镜像到本地

	## 下载镜像Docker Registry

```sh
# docker pull registry  
```



	## 运行私有库Registry，相当于本地有个私有Docker hub

```sh 
$ docker run -d -p 5000:5000 -v /zzyyuse/myregistry/:/tmp/registry --privileged=true registry 
```

> 默认情况，仓库被创建在容器的/var/lib/registry目录下，建议自行用容器卷映射，方便于宿主机联调 

### 案例演示创建一个新镜像，ubuntu安装ifconfig命令

```sh
apt-get -y install net-tools
```

![image-20220204180753957](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204180753957.png)

```sh
root@wjh:/home/wjh# docker commit -m="本地测试" -a="wjh" 6dc642adb22e wjhubuntu:1.1
```

>命令： 在容器外执行，记得 

### curl验证私服库上有什么镜像

```sh
root@wjh:/home/wjh# curl -XGET http://172.16.34.129:5000/v2/_catalog
{"repositories":[]}
```



### 将新镜像zzyyubuntu:1.2修改符合私服规范的Tag

按照公式： docker  tag  镜像:Tag  Host:Port/Repository:Tag 

自己host主机IP地址，填写同学你们自己的，不要粘贴错误，O(∩_∩)O 

使用命令 docker tag 将wjhbuntu:1.1这个镜像修改为172.16.34.129:5000/wjhubuntu:1.1

```sh
root@wjh:~# docker tag wjhubuntu:1.1 172.16.34.129:5000/wjhubuntu:1.1
```

![image-20220204185452606](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204185452606.png)

### 修改配置文件使之支持http

```sh
root@wjh:~# cat /etc/docker/daemon.json 
{
  "registry-mirrors": ["https://rcl1cdp5.mirror.aliyuncs.com"],
  "insecure-registries":["172.16.34.129:5000"]
}
```

> 上述理由：docker默认不允许http方式推送镜像，通过配置选项来取消这个限制。====>  修改完后如果不生效，建议重启docker 

### push推送到私服库

```sh
root@wjh:~# docker push 172.16.34.129:5000/wjhubuntu:1.1
```

![image-20220204190057767](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204190057767.png)

### curl验证私服库上有什么镜像2

```sh
root@wjh:~# curl -XGET http://172.16.34.129:5000/v2/_catalog
{"repositories":["wjhubuntu"]}
```

### pull到本地并运行

```sh
root@wjh:~# docker pull 172.16.34.129:5000/wjhubuntu:1.1
```

![image-20220204190634581](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204190634581.png)
