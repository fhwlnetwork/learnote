# 前置准备工作

##  中间件部署

####  1、部署Sentinel

a、创建优状态服务

![image-20220327210219208](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210219208.png)

b、指定容器镜像

![image-20220327210329816](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210329816.png)

C、默认下一步创建

#### 2、MongoDB创建

![image-20220327210617044](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210617044.png)

##### 选择应用模板进行创建

| <img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210632126.png" alt="image-20220327210632126" style="zoom:80%;" /><img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327210704351.png" alt="image-20220327210632126" style="zoom:80%;" /> |      |
| ------------------------------------------------------------ | ---- |
|                                                              |      |
###### 配置账户密码   
| <img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327211232257.png" alt="image-20220327211232257" style="zoom: 67%;" /><img src="https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327211411571.png" alt="image-20220327211232257" style="zoom: 75%;" /> |      |
| ------------------------------------------------------------ | ---- |
|                                                              |      |

###### 密钥配置



![image-20220327205155161](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327205155161.png)

###### 配置案例云镜像仓库信息

1、创建名称

![image-20220327205235357](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327205235357.png)

2、配置案例云仓库地址（或其他仓库）

![image-20220327205505037](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327205505037.png)



## 网络环境优化

#### 配置maven

>- 使用admin登陆ks
>- 进入集群管理
>- 进入配置中心
>- 找到配置
>
>- - ks-devops-agent
>  - 修改这个配置。加入maven阿里云镜像加速地址

![image-20220327221348297](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327221348297.png)

![image-20220327221552455](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327221552455.png)

```xml
<mirror>
    <id>nexus-aliyun</id>
    <mirrorOf>*,!jeecg,!jeecg-snapshots</mirrorOf>
    <name>Nexus aliyun</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public</url>
</mirror> 

```

![image-20220322213322073](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220322213322073.png)

# 创建devops工程

## 1、创建devops

> 进入分公司，找到devops工程，点击创建

![image-20220327213430426](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327213430426.png)

![image-20220327213533498](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327213533498.png)

## 2、创建凭证

### 1、创建git凭证

![image-20220327220021610](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220021610.png)

### 2、创建案例镜像登录凭证

![image-20220327220200098](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220200098.png)

## 2、进入工程创建流水线

![image-20220327214137747](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214137747.png)

### 方式1：手动配置Jenkins

#### 1、配置流水线名称

![image-20220327214301720](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214301720.png)

#### 2、编辑流水线

> 选择持续集成模板

![image-20220327214443889](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214443889.png)

![image-20220327214629468](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214629468.png)

##### 1、拉取代码

![image-20220327214859690](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327214859690.png)

###### a) 指定容器

![image-20220327215151603](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327215151603.png)

b) 添加嵌套步骤

添加git 拉取代码

| ![image-20220327215352956](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327215352956.png)![image-20220327215529925](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327215529925.png) |      |
| ------------------------------------------------------------ | ---- |
|                                                              |      |

##### 2、项目编译

###### a) 指定容器

###### b)添加嵌套步骤

1、确定文件是否存在，添加shell

![image-20220327220544541](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220544541.png)

2、编译代码，添加shell

```sh
mvn clean package -Dmaven.test.skip=true
```

![image-20220327220639181](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220639181.png)

3、确定是否编译成功,添加shell

```SH
ls hospital-manage/target
```

![image-20220327220812507](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220327220812507.png)

