# 磁盘分区





``` sh
#不关机，添加硬盘，自动识别
[root@web01 ~]# echo "- - -" > /sys/class/scsi_host/host0/scan

```



## 1、磁盘分区实践--磁盘小于2T

### 第一个里程: 准备磁盘环境

```text
准备了一块新的10G硬盘
```

###  第二个里程: 在系统中检查是否识别到了新的硬盘

```sh
	fdisk -l   --- 查看分区信息 
[root@web01 ~]# echo "- - -" > /sys/class/scsi_host/host0/scan
# 查看分区信息 
[root@web01 ~]# fdisk -l

```

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210509204851.png)

### 第三个里程: 对磁盘进行分区处理(fdisk-- 进行分区处理 查看分区信息)

#### 指令说明

``` text
   d   delete a partition  *****
        删除分区	
    g   create a new empty GPT partition table
	    创建一个新的空的GPT分区表(可以对大于2T磁盘进行分区)
    l   list known partition types
	    列出可以分区的类型???
    m   print this menu
	    输出帮助菜单
    n   add a new partition  *****
	    新建增加一个分区
    p   print the partition table  *****
	    输出分区的结果信息
    q   quit without saving changes 
	    不保存退出
    t   change a partition's system id
	    改变分区的系统id==改变分区类型(LVM 增加swap分区大小)
    u   change display/entry units
	    改变分区的方式  是否按照扇区进行划分
    w   write table to disk and exit  *****
	    将分区的信息写入分区表并退出==保存分区信息并退出
	    
```

####     a  ) 规划分4个主分区 ,1,2分区1g,3分区10g,其余的给第四分区

```sh
[root@web01 ~]# fdisk /dev/sdc
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039): +1G
Partition 1 of type Linux and of size 1 GiB is set
Command (m for help): n
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
Partition number (2-4, default 2): 
First sector (2099200-41943039, default 2099200): 
Using default value 2099200
Last sector, +sectors or +size{K,M,G} (2099200-41943039, default 41943039): +1G
Partition 2 of type Linux and of size 1 GiB is set
Command (m for help): n
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p
Partition number (3,4, default 3): 
First sector (4196352-41943039, default 4196352):      
Last sector, +sectors or +size{K,M,G} (20971520-41943039, default 41943039): +10G  
Using default value 41943039
Partition 3 of type Linux and of size 10 GiB is set
Command (m for help): n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default e): p
Selected partition 4
First sector (4196352-41943039, default 4196352): 
Using default value 4196352
Last sector, +sectors or +size{K,M,G} (4196352-20971519, default 20971519): 
Using default value 20971519
Partition 4 of type Linux and of size 8 GiB is set
Command (m for help): p
Disk /dev/sdc: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb478de23
   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048     2099199     1048576   83  Linux
/dev/sdc2         2099200     4196351     1048576   83  Linux
/dev/sdc3        20971520    41943039    10485760   83  Linux
/dev/sdc4         4196352    20971519     8387584   83  Linux
Partition table entries are not in disk order
Command (m for help): w


```

####  b) 规划分3个主分区 1个扩展分区 每个主分区1G  剩余都给扩展分区

```sh
[root@web01 ~]# fdisk /dev/sdc
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p

Disk /dev/sdc: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb478de23

   Device Boot      Start         End      Blocks   Id  System

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-41943039, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039): 1G
Value out of range.
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039): +1G
Partition 1 of type Linux and of size 1 GiB is set

Command (m for help): n
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
Partition number (2-4, default 2): 
First sector (2099200-41943039, default 2099200): 
Using default value 2099200
Last sector, +sectors or +size{K,M,G} (2099200-41943039, default 41943039): +1G
Partition 2 of type Linux and of size 1 GiB is set

Command (m for help): n
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p
Partition number (3,4, default 3): 
First sector (4196352-41943039, default 4196352): 
Using default value 4196352
Last sector, +sectors or +size{K,M,G} (4196352-41943039, default 41943039): +1G
Partition 3 of type Linux and of size 1 GiB is set

Command (m for help): p

Disk /dev/sdc: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb478de23
   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048     2099199     1048576   83  Linux
/dev/sdc2         2099200     4196351     1048576   83  Linux
/dev/sdc3         4196352     6293503     1048576   83  Linux
Command (m for help): n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default e): e
Selected partition 4
First sector (6293504-41943039, default 6293504): 
Using default value 6293504
Last sector, +sectors or +size{K,M,G} (6293504-41943039, default 41943039): 
Using default value 41943039
Partition 4 of type Extended and of size 17 GiB is set

Command (m for help): p

Disk /dev/sdc: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb478de23
   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048     2099199     1048576   83  Linux
/dev/sdc2         2099200     4196351     1048576   83  Linux
/dev/sdc3         4196352     6293503     1048576   83  Linux
/dev/sdc4         6293504    41943039    17824768    5  Extended
Command (m for help): n
All primary partitions are in use
Adding logical partition 5
First sector (6295552-41943039, default 6295552): 
Using default value 6295552
Last sector, +sectors or +size{K,M,G} (6295552-41943039, default 41943039): +1G
Partition 5 of type Linux and of size 1 GiB is set

Command (m for help): p

Disk /dev/sdc: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0xb478de23

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1            2048     2099199     1048576   83  Linux
/dev/sdc2         2099200     4196351     1048576   83  Linux
/dev/sdc3         4196352     6293503     1048576   83  Linux
/dev/sdc4         6293504    41943039    17824768    5  Extended
/dev/sdc5         6295552     8392703     1048576   83  Linux

Command (m for help): 

###说明：
#### 有了扩展分区才能逻辑分区，扩展分区不能直接使用，只能在逻辑分区种才能使用

```

###  第四个里程: 保存退出,让系统可以加载识别分区信息

```sh
#输入w,保存退出
Command (m for help): w
The partition table has been altered!
Calling ioctl() to re-read partition table.
Syncing disks.
#让系统可以加载识别分区文件
[root@web01 ~]# partprobe /dev/sdc

```

### 第五个里程：格式化磁盘

```sh
[root@web01 ~]# partprobe /dev/sdc
# ext3/4  centos6 
# xfs     centos7  格式效率较高  数据存储效率提升(数据库服务器)
	
[root@web01 ~]# mkfs -t xfs /dev/sdc1
meta-data=/dev/sdc1              isize=512    agcount=4, agsize=65536 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=262144, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@web01 ~]# mkfs.xfs /dev/sdc2
meta-data=/dev/sdc2              isize=512    agcount=4, agsize=65536 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=262144, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```





## 2、磁盘分区实践--磁盘大于2T

### 第一个里程: 准备磁盘环境 

```text
虚拟主机中添加一块3T硬盘
```
### 第二个里程: 使用parted命令进行分区

#### 帮助说明

``` text
	mklabel,mktable LABEL-TYPE               		 create a new disklabel (partition table)
	                                         		 创建一个分区表 (默认为mbr)
	                                         
	print [devices|free|list,all|NUMBER]    		 display the partition table, available devices, free space, all found
                                             		  partitions, or a particular partition
										 		  显示分区信息
										 
	mkpart PART-TYPE [FS-TYPE] START END     		 make a partition
	                                         		  创建一个分区 
                                       		  
    quit                                             exit program
	                                         		退出分区状态
	                                         		
	rm NUMBER                                delete partition NUMBER
	                                         删除分区 

```

``` sh
[root@web01 ~]# parted /dev/sdd
GNU Parted 3.1
Using /dev/sdd
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt                                                      
(parted) print                                                            
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdd: 3221GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start  End  Size  File system  Name  Flags

(parted) mkpart primary 0 2100G
Warning: The resulting partition is not properly aligned for best performance.
Ignore/Cancel? Ignore                                                     
(parted) mkpart primary 2100 2200G
Warning: You requested a partition from 2100MB to 2200GB (sectors 4101562..4296875000).
The closest location we can manage is 2100GB to 2200GB (sectors 4101562501..4296875000).
Is this still acceptable to you?
Yes/No? yes                                                               
Warning: The resulting partition is not properly aligned for best performance.
Ignore/Cancel? Ignore     
#查看分区
(parted) print                                                            
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdd: 3221GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  2100GB  2100GB               primary
 2      2100GB  2200GB  100GB                primary
#删除第二个分区
(parted) rm 2                                                            
(parted) print                                                            
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdd: 3221GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  2100GB  2100GB               primary
(parted) mkpart primary 2100 2200G                                    
Warning: You requested a partition from 2100MB to 2200GB (sectors 4101562..4296875000).
The closest location we can manage is 2100GB to 2200GB (sectors 4101562501..4296875000).
Is this still acceptable to you?
Yes/No? yes                                                               
Warning: The resulting partition is not properly aligned for best performance.
Ignore/Cancel? ingnore                                                    
parted: invalid token: ingnore
Ignore/Cancel? Ignore                                                     
#退出分区模式
(parted) quit                                                             
Information: You may need to update /etc/fstab.

```

### 	第三个里程: 加载磁盘分区

```sh
[root@web01 ~]# partprobe /dev/sdd
```

### 第四个里程:格式化分区

```sh
[root@web01 ~]# mkfs.xfs /dev/sdd1
meta-data=/dev/sdd1              isize=512    agcount=4, agsize=128173827 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=512695308, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=250339, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@web01 ~]# 
```

## 3、挂载分区

#### 3.1 手动挂载

```sh
 #创建挂在目录
[root@web01 ~]# mkdir /mount01
[root@web01 ~]# mount /dev/sdc1 /mount01
#查看挂载结果
[root@web01 ~]# df -h
Filesystem                   Size  Used Avail Use% Mounted on
/dev/mapper/centos_wjh-root   19G  2.2G   17G  12% /
devtmpfs                     476M     0  476M   0% /dev
tmpfs                        488M     0  488M   0% /dev/shm
tmpfs                        488M  7.7M  480M   2% /run
tmpfs                        488M     0  488M   0% /sys/fs/cgroup
/dev/sda1                    197M  108M   90M  55% /boot
tmpfs                         98M     0   98M   0% /run/user/0
/dev/sdc1                   1014M   33M  982M   4% /mount01

```

#### 3.2 开机自动挂载

##### 方法一: 将挂载命令放入/etc/rc.local

```sh
[root@web01 ~]# vim /etc/rc.local
[root@web01 ~]# tail -2 /etc/rc.local 
touch /var/lock/subsys/local
mount /dev/sdc1 /mount01
[root@web01 ~]# chmod +x /etc/rc.d/rc.local
```

##### 方法二: 在/etc/fstab文件中进行设置

```sh
#查看uuid
[root@web01 ~]# blkid
/dev/sda1: UUID="ef56a16b-6ffe-4ee9-84bc-54519c404628" TYPE="xfs" 
/dev/sda2: UUID="9mzWRG-c76T-l0GG-nMAm-KjJ0-vA3V-8s1UcP" TYPE="LVM2_member" 
/dev/sdc1: UUID="719b1119-bc16-421f-9039-032fc874e302" TYPE="xfs" 
/dev/sdc2: UUID="895dac6f-5864-4f0d-9a58-0ed43bf690a8" TYPE="xfs" 
/dev/mapper/centos_wjh-root: UUID="c570790b-11f1-4237-835a-06115e3b4890" TYPE="xfs" 
/dev/mapper/centos_wjh-swap: UUID="130c3eaf-c634-4f5b-8cf2-21d48c3956d4" TYPE="swap" 
/dev/sdd1: UUID="bcc9ed95-532b-4c9e-a697-9d66bae6a3c8" TYPE="xfs" PARTLABEL="primary" PARTUUID="4e66de18-0674-4b4a-b784-d93332dbf466" 
/dev/sdd2: PARTLABEL="primary" PARTUUID="3b280fe8-5d0a-414a-aafc-2772ecffb2e0" 
##使用uuid或者直接行磁盘路径
[root@web01 ~]# tail -2 /etc/fstab 
#/dev/sdd1                                 /mount2  xfs     defaults        0 0          
UUID=bcc9ed95-532b-4c9e-a697-9d66bae6a3c /mount2  xfs     defaults        0 0    

```

## 4、企业磁盘常见问题:

```text
 1) 磁盘满的情况 No space left on device
 a)存储的数据过多了
         block存储空间不足了
解决方式:
	a 删除没用的数据		 
    b 找出大的没用的数据
	find / -type f -size +xxx
	du -sh /etc/sysconfig/network-scripts/*|sort -h (按照数值排序命令)
b)  存储的数据过多了
       inode存储空间不足了: 出现了大量小文件
 df -i 查看inode
解决方式: 删除大量的没用的小文件
```

## 5、swap分区调整

### 第一步： 将磁盘分出一部分空间给swap分区使用
``` sh
[root@web01 ~]# dd if=/dev/zero  of=/tmp/1G  bs=100M count=10
```
### 第二步： 将指定磁盘空间作为swap空间使用
``` sh
[root@web01 ~]# mkswap /tmp/1G 
Setting up swapspace version 1, size = 1023996 KiB
no label, UUID=9a9aed5d-aade-41ba-8a1a-6f67275c2873

```
### 第三步： 加载使用swap空间
``` sh
[root@web01 ~]# swapon /tmp/1G 
swapon: /tmp/1G: insecure permissions 0644, 0600 suggested.
[root@web01 ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:           974M        119M        164M         25M        691M        662M
Swap:          2.0G          0B        2.0G
## swap足够时，释放资源
[root@web01 ~]#  swapoff /tmp/1G
[root@web01 ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:           974M        118M        164M         25M        691M        663M
Swap:          1.0G          0B        1.0G
[root@web01 ~]# rm /tmp/1G -f
[root@web01 ~]# 
````