# 系统优化
## 1、系统的优化方法（基础优化）
``` shell
#1）了解系统的环境
#两个命令：
# a)、cat /etc/redhat-release 	------获得系统发行版本和具体系统版本信息
[root@web01 ~]# cat /etc/redhat-release
CentOS Linux release 7.5.1804 (Core) 

# b)、	uname 	-a

[root@web01 ~]# uname -a
Linux web01 3.10.0-862.el7.x86_64 #1 SMP Fri Apr 20 16:44:24 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
#记忆centos7系统的内核信息
#Q：一起你用的LINUX系统是什么环境的？
#a:	centos7 具体型号7.5 内核3.10 64位

```
![uname](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/QQ%E5%9B%BE%E7%89%8720210507103918.png)

## 2、操作系统优化---命令提示符优化
``` shell
#优化方法: 修改PS1环境变量
#默认配置: 
[root@web01 ~]# echo $PS1
[\u@\h \W]\$
# \u    --- 显示当前登录用户名称
# \h    --- 显示系统主机名称
# \W    --- 显示当前所在目录信息(目录结构的最后结尾信息)	
```
![参数说明](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210507104624.png)
## 修改优化方法:
### 01. 修改命令提示符的内容:
``` shell
 #  ------显示全路径 
vi /etc/profile
加入 export PS1='[\u@\H \w]\$'
[root@web01 /etc/sysconfig]# source /etc/profile
    	
```
### 02. 命令提示符如何修改颜色
``` shell

	# Linxu系统中如何给信息加颜色
	
	\[\e[F;Bm] 文字内容 \e[m
	
	”[\[\e[31;40m]\u\e[m @\h \W]\$ “
	
	[root@oldboyedu ~]# tail -5 /etc/profile
    export PS1='\[\e[32;1m\][\u@\h \W]\$ \[\e[0m\]'
	          设置颜色    内容         结束     
	
	export PS1='\[\e[30;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 黑色提示符
	export PS1='\[\e[31;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 红色提示符
	export PS1='\[\e[32;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 绿色提示符
    export PS1='\[\e[33;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 黄色提示符
	export PS1='\[\e[34;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 蓝色提示符
	export PS1='\[\e[35;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 粉色
	export PS1='\[\e[36;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 浅蓝 
	export PS1='\[\e[37;1m\][\u@\h \W]\$ \[\e[0m\]'  -- 白色

```

#### 实现命令提示符是彩色的
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210507110800.png)
```shell
#实现以上效果方法,在/etc/profile底行输入:
[root@web01 /etc/sysconfig]# vim /etc/profile
export PS1='[\[\e[31;1m\]\u@\[\e[32;1m\]\h\[\e[36;1m\] \w\[\e[33;1m\]]\$ '
```
##  操作系统优化---yum下载源优化
```text
yum软件优势: 简单 快捷
	01. 不需要到官方网站单独下载软件包(yum仓库)
	02. 可以解决软件的依赖关系
```
### 	yum优化方法:
#### 1. 优化基础的yum源文件，
```shell
#1）更换阿里云或者网易源
#通过阿里镜像源进行优化:
 curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#更新网易源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
2） #运行以下命令生成缓存：
yum clean all
yum makecache

```
#### 02. 优化扩展的yum源文件

``` shell
   
#通过阿里镜像源进行优化: 
# wget -O /etc/yum.repos.d/epe l.repo http://mirrors.aliyun.com/repo/epel-7.repo	
#检查可用的yum源信息
#yum repolist
#如何查看软件是否安装?
#利用rpm命令查看软件是否安装
#rpm 	-qa	查询的软件		--------q表示查询,-a表示所有
#查看软件包中有哪些信息
rpm -ql 软件名称	----		-l表示列表显示
#查看文件信息属于哪个软件大礼包
#which 软件名称
#rpm -qf 	`软件名称	`
```
## 02. 系统安全相关优化(将一些安全服务进行关闭)