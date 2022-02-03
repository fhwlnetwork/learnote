# centos安装docker

## 1、前提说明

目前，CentOS 仅发行版本中的内核支持 Docker。Docker 运行在CentOS 7 (64-bit)上， 

要求系统为64位、Linux系统内核版本为 3.8以上，这里选用Centos7.x 

> **查看自己的内核** 
>
> ```sh
> cat /etc/read-release
> ##uname命令用于打印当前系统相关信息（内核版本号、硬件架构、主机名称和操作系统类型等）。 
> uname -r
> ```

