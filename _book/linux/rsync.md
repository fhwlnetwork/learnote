

# 什么是rsync服务

​    Rsync是一款开源的、快速的、多功能的、可实现全量及增量的本地或远程数据同步备份的优秀工具



# rsync命令语法格式

>  SYNOPSIS
>   Local:  rsync [OPTION...] SRC... [DEST]



## 本地备份数据: 
   src: 要备份的数据信息
   dest: 备份到什么路径中

## 远程备份数据:

   Access via remote shell:

### 拉取数据

   Pull: rsync [OPTION...] [USER@]HOST:SRC... [DEST]
   [USER@]    --- 以什么用户身份拉取数据(默认以当前用户)
   hosts      --- 指定远程主机IP地址或者主机名称
   SRC        --- 要拉取的数据信息
   dest       --- 保存到本地的路径信息

> EG: rsync  -rp wjh@172.06.1.31:/etc/hosts /backup
>
> <a style="color:red">使用的用户必须是对端服务器上存在,推荐使用root用户</a>

 ![image-20220904162320119](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220904162320119.png)

#### 推送数据 

 Push: rsync [OPTION...] SRC... [USER@]HOST:DEST
   SRC        --- 本地要进行远程传输备份的数据
   [USER@]    --- 以什么用户身份推送数据(默认以当前用户)
   hosts      --- 指定远程主机IP地址或者主机名称
   dest       --- 保存到远程的路径信息

 

## 守护进程方式备份数据 备份服务 

   1. 可以进行一些配置管理

   2. 可以进行安全策略管理

   3. 可以实现自动传输备份数据
         Access via rsync daemon:
         Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
        rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]
         Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
        rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST

      

# rsync软件使用方法:

> ​    rsync命令  可以替代cp，scp，rm，ls命令

## 本地备份数据 

### 使用cp进行备份

```sh
	[root@nfs01 backup]# cp /etc/hosts /tmp
    [root@nfs01 backup]# ll /tmp/hosts
    -rw-r--r-- 1 root root 371 May  6 16:11 /tmp/hosts
  
```

	### 使用rsync代替cp进行本地文件备份

```sh
  	[root@nfs01 backup]# rsync /etc/hosts /tmp/host_rsync
    [root@nfs01 backup]# ll /tmp/host_rsync
    -rw-r--r-- 1 root root 371 May  6 16:12 /tmp/host_rsync
```

## 远程备份数据 scp

### 使用scp进行备份

```sh
scp -rp /etc/hosts root@172.16.1.41:/backup
    root@172.16.1.41's password: 
    hosts         100%  371    42.8KB/s   00:00
    -r    --- 递归复制传输数据
    -p    --- 保持文件属性信息不变
```

###  使用rsync进行备份

```sh
[root@nfs01 ~]# rsync -rp /etc/hosts 172.16.1.41:/backup/hosts_rsync
    root@172.16.1.41's password: 	
	
	rsync远程备份目录:
	[root@nfs01 ~]# rsync -rp /wjh 172.16.1.41:/backup   --- 备份的目录后面没有 /
    root@172.16.1.41's password: 
	[root@backup ~]# ll /backup
    total 0
    drwxr-xr-x 2 root root 48 May  6 16:22 wjh
    [root@backup ~]# tree /backup/
    /backup/
    └── wjh
        ├── 01.txt
        ├── 02.txt
        └── 03.txt
    
    1 directory, 3 files

[root@nfs01 ~]# rsync -rp /wjh/ 172.16.1.41:/backup  --- 备份的目录后面有 / 
 root@172.16.1.41's password:
 [root@backup ~]# ll /backup
total 0
-rw-r--r-- 1 root root 0 May  6 16:24 01.txt
-rw-r--r-- 1 root root 0 May  6 16:24 02.txt
-rw-r--r-- 1 root root 0 May  6 16:24 03.txt
```

>总结: 在使用rsync备份目录时:
>	备份目录后面有  / -- /wjh/ : 只将目录下面的内容进行备份传输 
>	备份目录后面没有/ -- /wjh  : 会将目录本身以及下面的内容进行传输备份

​	

## 	替代rm删除命令

```sh
 rsync -rp --delete /null/ 172.16.1.41:/backup
    root@172.16.1.41's password: 
#--delete   实现无差异同步数据
```

>面试题: 有一个存储数据信息的目录, 目录中数据存储了50G数据, 如何将目录中的数据快速删除
>	使用，rm /目录/* -rf删除会耗时很久，使用rsync可以节省时间
>
>EG:  rsync -rp --delete /null/ 172.16.1.41:/backup

## 	替代查看文件命令 ls 

### 使用ls查看文件列表

```sh
	[root@backup ~]# ls /etc/hosts
    /etc/hosts
 
```

### 使用rsync查看文件列表

```sh
   [root@backup ~]# rsync /etc/hosts
    -rw-r--r--            371 2019/05/06 11:55:22 hosts
```