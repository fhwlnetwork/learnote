# 磁盘空间未完全分配场景文件系统扩容处理

## **一、场景分析**

系统安装好后，磁盘空间不足，虚拟机动态扩容磁盘空间，默认情况sda1-sda2为主分区,使用lsblk 查看当前情况。

![image-20220307212440201](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220307212440201.png)

>**得出结果**
>
>**磁盘名称为** sda，总大小70G，空间已分配 60G **左右，还剩** 10G **多空间未分配**
>
>sda2**下存在** 两 **个卷组** vg**：**centos_master-root，centos_master-swap此卷组有2个逻辑卷lv
>
>**逻辑卷** lv**：**root **和** swap**，对应的挂载点**/**和**/swap

## **二、磁盘剩余空间创建分区**

> 请忽略上午图中 vda **和下文** sda 名称的差异，一切以lsblk **扫描出来的结果为准**

### 1、 sda1~sda4 **未全部分配可用** fdisk 来完成分区

####   在系统中检查是否识别到了新的硬盘

```SH
[root@master ~]# fdisk -l 

Disk /dev/sda: 75.2 GB, 75161927680 bytes, 146800640 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000d0ec1

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048      411647      204800   83  Linux
/dev/sda2          411648    41943039    20765696   8e  Linux LVM
/dev/sda3        41943040   125829119    41943040   8e  Linux LVM

Disk /dev/mapper/centos_master-root: 63.1 GB, 63132663808 bytes, 123305984 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos_master-swap: 4 MB, 4194304 bytes, 8192 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

```

#### 对磁盘进行分区处理(fdisk-- 进行分区处理 查看分区信息)

```sh
[root@master ~]# fdisk /dev/sda 
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default e): p
Selected partition 4
First sector (125829120-146800639, default 125829120):          
Using default value 125829120
Last sector, +sectors or +size{K,M,G} (125829120-146800639, default 146800639): 
Using default value 146800639
Partition 4 of type Linux and of size 10 GiB is set

Command (m for help): t
Partition number (1-4, default 4): 
Hex code (type L to list all codes): L

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1 80  Old Minix      
Hex code (type L to list all codes): 8e  
Changed type of partition 'Linux' to 'Linux LVM'

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 16: Device or resource busy.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.


```

![image-20220307215355230](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220307215355230.png)

![image-20220307215418453](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220307215418453.png)

#### ③查看分区是否完成分配。

![image-20220307224425124](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220307224425124.png)

#### 格式化磁盘

```
cat /proc/partitions 
mkfs.ext3 /dev/sda4
```

​	

![image-20220307224941972](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220307224941972.png)

#### 下一步，创建物理卷和分区：

```SH
[root@master ~]# pvcreate /dev/sda4
WARNING: ext3 signature detected on /dev/sda4 at offset 1080. Wipe it? [y/n]: y
  Wiping ext3 signature on /dev/sda4.
  Physical volume "/dev/sda4" successfully created.
[root@master ~]# vgextend centos_master /dev/sda4
  Volume group "centos_master" successfully extended

```

#### 我们查看物理卷情况，知道了可以增加的硬盘空间容量总量。

```SH
[root@master ~]# vgdisplay
  --- Volume group ---
  VG Name               centos_master
  System ID             
  Format                lvm2
  Metadata Areas        3
  Metadata Sequence No  7
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                3
  Act PV                3
  VG Size               69.79 GiB
  PE Size               4.00 MiB
  Total PE              17867
  Alloc PE / Size       15053 / 58.80 GiB
  Free  PE / Size       2814 / 10.99 GiB
  VG UUID               xqPaU2-S9On-Pfrv-Zg9Q-bBrf-nmxD-8GF4Lj
```

#### 按照实际大小酌情增加，比如我现在需增加10.99 GiB

```SH
[root@master ~]# lvresize -L +10G /dev/mapper/centos_master-root
  Size of logical volume centos_master/root changed from <58.80 GiB (15052 extents) to <68.80 GiB (17612 extents).
  Logical volume centos_master/root successfully resized.

```

####  然后动态扩容分区的大小

```SH
[root@master ~]# xfs_growfs /dev/mapper/centos_master-root 
meta-data=/dev/mapper/centos_master-root isize=512    agcount=12, agsize=1297408 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=15413248, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 15413248 to 18034688

```

最后，查看最终的结果

```SH
[root@master ~]#  df -h
Filesystem                      Size  Used Avail Use% Mounted on
devtmpfs                        2.0G     0  2.0G   0% /dev
tmpfs                           2.0G     0  2.0G   0% /dev/shm
tmpfs                           2.0G   12M  2.0G   1% /run
tmpfs                           2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/mapper/centos_master-root   69G  2.7G   67G   4% /
/dev/sda1                       197M  116M   82M  59% /boot
tmpfs                           394M     0  394M   0% /run/user/0

```



### 2、sda1~sda4 **全部分配可用**cfdisk 来完成分区