# Docker轻量级可视化工具Portainer

## 是什么

Portainer 是一款轻量级的应用，它提供了图形化界面，用于方便地管理Docker环境，包括单机环境和集群环境。

## 安装

> 官网：
>
> https://www.portainer.io/
>
> https://docs.portainer.io/v/ce-2.9/start/install/server/docker/linux

### docker 命令安装

```sh
docker run -d -p 8000:8000 -p 9000:9000 --name portainer     --restart=always     -v /var/run/docker.sock:/var/run/docker.sock     -v portainer_data:/data     portainer/portainer
```

### 第一次登录需创建admin，访问地址：xxx.xxx.xxx.xxx:9000

![image-20220207202039523](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072020601.png)

### 设置admin用户和密码后首次登陆

![image-20220207202129112](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072021206.png)

### 选择local选项卡后本地docker详细信息展示

![image-20220207202426444](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072024779.png)

