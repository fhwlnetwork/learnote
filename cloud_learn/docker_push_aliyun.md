# 推送镜像到阿里云

##  本地镜像素材原型

![image-20220204170207963](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204170207963.png)

## 创建仓库镜像

### 选择控制台，进入容器镜像服务

![image-20220204170653893](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204170653893.png)

### 选择个人实例

![image-20220204170726639](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204170726639.png)

### 命名空间

​	![image-20220204170751465](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204170751465.png)

### 仓库名称

​	![image-20220204170902623](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204170902623.png)

![image-20220204171017669](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204171017669.png)

### 进入管理界面获得脚本

![image-20220204171059616](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204171059616.png)

## 将镜像推送到阿里云

	### seq1:登录阿里云Docker Registry

```sh
$ docker login --username=1355997****@139.com registry.cn-hangzhou.aliyuncs.com
```

![image-20220204172019312](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204172019312.png)

### seq2:镜像打标签

```sh 
$ docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/fhwlkj/ubuntu:[镜像版本号]
```

Seq3:将镜像推送到Registry

```sh
$ docker push registry.cn-hangzhou.aliyuncs.com/fhwlkj/ubuntu:[镜像版本号]
```

![image-20220204172247296](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204172247296.png)

## 拉去阿里仓库镜像到本地

```sh
$ docker pull registry.cn-hangzhou.aliyuncs.com/fhwlkj/ubuntu:[镜像版本号]
```

![image-20220204172634396](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220204172634396.png)
