# centos安装docker

## 1、前提说明

目前，CentOS 仅发行版本中的内核支持 Docker。Docker 运行在CentOS 7 (64-bit)上， 

要求系统为64位、Linux系统内核版本为 3.8以上，这里选用Centos7.x 

> **查看自己的内核** 
>
> ```sh
> cat /etc/redhat-release 
> ##uname命令用于打印当前系统相关信息（内核版本号、硬件架构、主机名称和操作系统类型等）。 
> uname -r
> ```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20220203113847.png)

## 2、卸载旧版本

```sh
 sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202031225565.png)

## 3、yum安装gcc相关

```sh
# yum install -y gcc  gcc-c++
```



![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202031229269.png)

4、安装需要的软件包

```sh
# yum install -y yum-utils
```

## 5、设置stable镜像仓库

```sh 
# yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

> 说明：
>
> 官方文档要求配置的源：yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
>
> 由于是海外资源，加载资源时容易404，推荐使用国内源，本文档使用阿里源

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202032147896.png)

## 6、更新yum软件包索引

```sh
# yum makecache fast
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202032147919.png)

## 7、安装Docker ce

```sh
# yum -y install docker-ce docker-ce-cli containerd.io
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202032147941.png)

## 8、启动docker

```sh
# systemctl start docker
```

### 验证

```sh
# docker version
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202032147964.png)

## 、9、卸载

```sh
# systemctl stop docker
# yum remove docker-ce docker-ce-cli containerd.io
# rm -rf /var/lib/docker
# rm -rf /var/lib/containerd

```

## ## 10、 配置镜像加速器

```sh
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://rcl1cdp5.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202032147985.png)