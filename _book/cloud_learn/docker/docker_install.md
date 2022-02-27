# 乌图班图安装docker

## 1、卸载旧版本

Docker 的旧版本被称为 docker，docker.io 或 docker-engine 。如果已安装，请卸载它们：

```sh
 sudo apt-get remove docker docker-engine docker.io containerd runc
```

![image-20220201193804661](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201193804661.png)

## 2、设置仓库

### 更新 apt 包索引。

```shell
 $ sudo apt-get update
```

![QQ20220201-135208](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/QQ20220201-135208.png)

### 安装 apt 依赖包，用于通过HTTPS来获取仓库:

```sh
 $ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

![image-20220201193944401](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201193944401.png)

### 添加 Docker 的官方 GPG 密钥：

```sh
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
```

![image-20220201195831614](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201195831614.png)

9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88 通过搜索指纹的后8个字符，验证您现在是否拥有带有指纹的密钥。

````sh
sudo apt-key fingerprint 0EBFCD88
````

![image-20220201200540677](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201200540677.png)

### 使用以下指令设置稳定版仓库

```sh
$ sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ \
  $(lsb_release -cs) \
  stable"
```

![image-20220201200701259](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201200701259.png)

## 安装 Docker Engine-Community

### 更新 apt 包索引。

```sh
$ sudo apt-get update
```

### 安装最新版本的 Docker Engine-Community 和 containerd ，或者转到下一步安装特定版本：

```sh
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

![image-20220201201623972](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201201623972.png)

### 仓库中列出可用版本

````sh
sudo apt-cache madison docker-ce
````

![image-20220201201812214](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201201812214.png)

```sh
## 使用第二列中的版本字符串安装特定版本，例如 5:18.09.1~3-0~ubuntu-xenial。
sudo apt-get install docker-ce=5:20.10.6~3-0~ubuntu-focal docker-ce-cli=5:20.10.6~3-0~ubuntu-focal containerd.io
```

![image-20220201201930377](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201201930377.png)

## 验证结果

```sh
sudo docker run hello-world
```

![image-20220201202215373](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220201202215373.png)







