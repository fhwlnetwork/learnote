# mac安装pyhton3.0环境



## 确认系统版本

```sh
uname -a
```

![image-20230524230920507](https://gitee.com/fhwlkj/blog-pic/raw/master/note/image-20230524230920507.png)

## 官网下载选择需要的python版本

官网下载链接：https://www.python.org/downloads/macos/

![image-20230524231119004](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542255.png)

## 安装程序

### 选择安装包

双击运行安装，点击弹出框中的继续

![image-20230524231224452](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542556.png)



### 选择安装目录

点击存储选择按钮，在弹出款中选择python存储的位置

![image-20230524231348308](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542023.png)![image-20230524231503713](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542242.png)

确认无误后一路选择继续，在弹出款中输入账号密码，开始安装

![image-20230524231647099](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542751.png)

## 环境变量配置

### 查看python安装目录

运行终端 

![image-20230524231822416](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542832.png)

执行which查看安装路径

```sh
which python3
```



![image-20230524232002612](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281542241.png)

### 编辑ba sh_file文件

```sh
vi ~/.bash_profile
#python的路径见上一步
PATH="/usr/local/bin/python3/bin:${PATH}"
export PATH
alias python="/usr/local/bin/python3"
```

执行 source ~/.bash_profile 使配置生效

## 验证结果

新建运行终端输入python

![image-20230524232352817](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281543793.png)

输入 print ('hello world')

![image-20230524232435902](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img202305281543629.png)

到此python环境安装完成

