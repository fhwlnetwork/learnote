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
### 修改优化方法:
#### 01. 修改命令提示符的内容:
``` shell
 #  ------显示全路径 
vi /etc/profile
加入 export PS1='[\u@\H \w]\$'
[root@web01 /etc/sysconfig]# source /etc/profile
    	
```
#### 02. 命令提示符如何修改颜色
``` shell

	# Linxu系统中如何给信息加颜色
	
	\[\e[F;Bm] 文字内容 \e[m
	
	”[\[\e[31;40m]\u\e[m @\h \W]\$ “
	
	[root@web01 ~]# tail -5 /etc/profile
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

## 3、操作系统优化-----yum下载源优化
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
## 4. 系统安全相关优化(将一些安全服务进行关闭)

###  1). 防火墙服务程序
#### centos6
```text
查看防护墙服务状态
	/etc/init.d/iptables status
临时关闭防火墙服务
	/etc/init.d/iptables stop
	/etc/init.d/iptables status
永久关闭防火墙服务
	chkconfig iptables off
```
#### centos7
```text

查看防火墙服务状态
	systemctl status firewalld	   
临时关闭防火墙服务
	systemctl stop firewalld
	systemctl status firewalld  -- 操作完确认		   
永久关闭防火墙服务
	systemctl disable firewalld	   
补充: 查看服务状态信息简便方法
	systemctl is-active firewalld   --- 检查服务是否正常运行
 	systemctl is-enabled firewalld  --- 检查确认服务是否开机运行
```
![关闭防火墙](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210509144705.png)

## 4、关闭selinux服务程序

``` text
1.什么是selinux：
selinux(security enhanced linux)安全增强型linux系统，它是一个linux内核模块，也是linux的一个安全子系统。
selinux的主要作用就是最大限度地减小系统中服务进程可访问的资源（最小权限原则）
2.selinux有两个级别 强制和警告  setenforce  0|1  0表示警告(Permissive)，1表示强制（Enforcing）
3.selinux相当于一个插件  (内核级的插件)
4.selinux功能开启后，会关闭系统中不安全的功能
5.查看日志中的警告：cat /var/log/audit/audit.log
临时关闭:
检查确认: 
getenforce    --- 确认selinux服务是否开启或是关闭的
如何关闭:  
[root@web01 /etc]# setenforce
usage:  setenforce [ Enforcing | Permissive | 1 | 0 ]
Enforcing   1  --- 临时开启selinux
Permissive  0  --- 临时关闭selinux
setenforce 0   --- 临时关闭selinux服务

永久关闭:
enforcing 	- SELinux security policy is enforced.  （selinux服务处于正常开启状态）
permissive 	- SELinux prints warnings instead of enforcing.（selinux服务被临时关闭了）
disabled 	- No SELinux policy is loaded.（selinux服务彻底关闭）
vi /etc/selinux/config
SELINUX=disabled
PS: 如果想让selinux配置文件生效,重启系统

```
## 05、字符编码优化

``` TEXT
 出现乱码的原因:
	01. 系统字符集设置有问题
	02. 远程软件字符集设置有问题
	03. 文件编写字符集和系统查看的字符集不统一
出现乱码的原因:
	01. 系统字符集设置有问题
	02. 远程软件字符集设置有问题
	03. 文件编写字符集和系统查看的字符集不统一
```

### 	centos6 设置方法

```SHELL

#	查看默认编码信息:
 [root@web01 /etc]# echo $LANG --- LANG用于设置字符编码信息
    en_US.UTF-8
	
#临时修改:
 [root@web01 ~]# LANG=XXX
	
#永久修改:
#方法一:
[root@web01 ~]# tail -5 /etc/profile
 export LANG='en_US.UTF-8'
#方法二:
vi /etc/sysconfig/i18n
LANG='en_US.UTF-8
source /etc/sysconfig/i18n
```

### centos7设置方法

``` shell
#	查看默认编码信息
	[root@web01 ~]# echo $LANG
    en_US.UTF-8
 #   临时修改:
	[root@web01 ~]# echo $LANG
    en_US.UTF-8
	LANG=XXX
#	永久修改:
#	方法一: 更加有先
    [root@web01 ~]# tail -5 /etc/profile
    export LANG='en_US.UTF-8'
#	方法二:
	[root@web01 ~]# cat /etc/locale.conf 
    LANG="zh_CN.UTF-8"
#	补充：一条命令即临时设置，又永久设置
	localectl set-locale LANG=zh_CN.GBK
```

##  06、使xshell软件远程连接速度加快

``` shell
    #第一个步骤：修改ssh服务配置文件
	vi /etc/ssh/sshd_config
	79  GSSAPIAuthentication no
	115 UseDNS no
	#第二个步骤：重启ssh远程服务
	systemctl restart sshd
```

## 7、时间同步：[时间同步]（linux/time_synchronism.md）

