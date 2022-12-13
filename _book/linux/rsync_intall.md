​    

## 安装rsync

### 第一个历程: 下载安装软件

查看软件是否已经存在： rpm -qa|grep rsync

 安装软件：	yum install -y rsync 

### 第二个历程: 编写配置文件

```conf
##created by HQ at 2017
###rsyncd.conf start##
  
#指定管理备份目录的用户组  
gid = rsync       				
#指定管理备份目录的用户
uid = rsync       				
#定义rsync备份服务的网络端口号
port = 873       				
#将rsync虚拟用户伪装成为一个超级管理员用户 
fake super = yes  			
#和安全相关的配置
use chroot = no   
#最大连接数  同时只能有200个客户端连接到备份服务器
max connections = 200  
#超时时间(单位秒)
timeout = 300          
#记录进程号码信息 1.让程序快速停止进程 2. 判断一个服务是否正在运行
pid file = /var/run/rsyncd.pid   
 #锁文件
lock file = /var/run/rsync.lock 
#rsync服务的日志文件 用于排错分析问题
log file = /var/log/rsyncd.log   
#忽略传输中的简单错误
ignore errors                    
#指定备份目录是可读可写
read only = false                
#使客户端可以查看服务端的模块信息
list = false                     
#允许传输备份数据的主机(白名单)
hosts allow = 172.16.1.0/24      
#禁止传输备份数据的主机(黑名单)
hosts deny = 0.0.0.0/32          
#指定认证用户
auth users = rsync_backup        
#指定认证用户密码文件 用户名称:密码信息
secrets file = /etc/rsync.password  
#模块信息
[backup]                         
comment = "backup dir by WJH"
#模块中配置参数 指定备份目录
path = /backup                   


```

![img](F:\有道笔记\qq82602573DABD0AB54B634A8238F27B2E\1e87f450c97d4de7b44669d888f2e664\image.png)

### 第三个历程: 创建rsync服务的虚拟用户

```sh
	useradd rsync -M -s /sbin/nologin
```

![img](F:\有道笔记\qq82602573DABD0AB54B634A8238F27B2E\777831040cf24f0797f186ec42f364e8\image.png)

### 第四个历程: 创建备份服务认证密码文件

```sh
echo "rsync_backup:123456" >/etc/rsync.password
chmod 600 /etc/rsync.password
```

![img](F:\有道笔记\qq82602573DABD0AB54B634A8238F27B2E\0ca1b23fdd2849a5a8b9b0cbd103240c\image.png)

### 第五个历程: 创建备份目录并修改属主属组信息

```sh
mkdir /backup
chown rsync.rsync /backup/
```

### 第六个历程: 启动备份服务

```sh
systemctl start rsyncd
systemctl enable rsyncd
#查看服务运行状态：
systemctl status rsyncd
```



![img](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/clipboard.png)

## 语法格式说明   

 需要熟悉rsync守护进程名称语法:

​		Access via rsync daemon:

​	客户端做拉的操作: 恢复数据

   		 Pull:  rsync  [OPTION...]   [USER@]HOST::SRC...  [DEST]

​         	 		rsync [OPTION...] rsync://[USER@]HOST[:PORT]/SRC... [DEST]

​	客户端做推的操作: 备份数据

​    		Push: rsync [OPTION...] SRC... [USER@]HOST::DEST

​	      			src: 要推送备份数据信息	

​					[user@]指定认证用户信息

​		  			HOST: 指定远程主机的IP地址或者主机名称

​		 	 	::DEST: 备份服务器的模块信息 

​        	rsync [OPTION...] SRC... rsync://[USER@]HOST[:PORT]/DEST

##   rsync守护进程客户端配置:

### 	第一个历程: 创建一个秘密文件

```sh
echo "123456" >/etc/rsync.password
chmod 600 /etc/rsync.password
```

###     第二个历程: 进行免交互传输数据测试

```sh
rsync -avz /etc/hosts rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password
```

![img](F:\有道笔记\qq82602573DABD0AB54B634A8238F27B2E\3c4dfd3a78ec452d8b1442de4eb8847a\clipboard.png)

## 企业应用

### 分部门分目录存储数据

守护进程多模块功能配置  (vim /etc/rsyncd.conf)

​	[backup]

​    	comment = "backup dir by wjh"

​    	path = /backup

   [dba]

​    	comment = "backup dir by wjh"

​    	path = /dba

   [dev]

​    	comment = "backup dir by wjh"

​    	path = /devdata

### 守护进程的排除功能实践

 需求01: 将/wjh目录下面 a目录数据全部备份 b目录不要备份1.txt文件 c整个目录不要做备份

​    --exclude=PATTERN

​    绝对路径方式:

​    [root@nfs01 /]# rsync -avz /wjh --exclude=/wjh/b/1.txt --exclude=/wjh/c/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password 