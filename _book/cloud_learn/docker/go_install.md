# go环境安装

- https://golang.google.cn/dl/

go env查看环境

![image-20220115233350312](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20220115233713.png)


## **创建GOPATH目录**

l **src：存放源代码**

l **pkg：存放依赖包**

l bin：存放可执行文件

```
mdkdir -p $GOPATH/{bin，src，pkg}
```



![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20220115234921.png)

##  **修改环境变量**

###  **1、创建用户变量gopath**

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20220115234621.png)



## **配置国内代理**

l GOOS，GOARCH，GOPROXY

l 国内用户建议设置 goproxy：export GOPROXY=https://goproxy.cn

https://goproxy.io,direct

## ![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20220115234823.png)

##  **一些基本命令**

- build 将文件编译成可执行文件 

  --  goos=linux go build xx.go	指定环境为linux编译程序

- fmt 格式化代码
-- go fmt xxx.go
-  get 下载依赖

- isntall 编译并安装包和依赖
- test 运行 测试
- tool 运行共提供的工具
- mod  维护模块





​	