# lnmp配置

## 网站的LNMP架构是什么
```text
L   --- linux系统
 注意:  
	a selinux必须关闭  防火墙关闭
	b /tmp 1777 mysql服务无法启动
N 	--- nginx服务部署
	作用:
	处理用户的静态请求 html jpg txt mp4/avi

P  	--- php服务部署
	作用:
	1. 处理动态的页面请求
	2. 负责和数据库建立关系
	
M   --- mysql服务部署 (yum会很慢 编译安装会报错) mariadb
	作用:
	存储用户的字符串数据信息
```
## nginx安装：[nginx安装](nginx/install.md)

## mysql安装配置：[mysql安装](mysql/install.md)

## php安装配置
```sh
#安装路径：/usr/local/php
# 先安装如下依赖包
[root@wjh mysql]#  wget https://www.php.net/distributions/php-7.3.28.tar.gz

[root@wjh mysql]# yum install -y gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
#解压文件
[root@wjh php-7.2.0]# tar -zxvf php-7.2.0.tar.gz 
[root@wjh tools]# cd php-7.2.0/

#指定安装目录，指定安装模块
[root@wjh tools]# ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php --enable-mbstring --with-openssl --enable-ftp --with-gd --with-jpeg-dir=/usr --with-png-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pear --enable-sockets --with-freetype-dir=/usr --with-zlib --with-libxml-dir=/usr --with-xmlrpc --enable-zip --enable-fpm --enable-xml --enable-sockets --with-gd --with-zlib --with-iconv --enable-zip --with-freetype-dir=/usr/lib/ --enable-soap --enable-pcntl --enable-cli --with-curl

|# 编译完成之后，执行安装命令：
[root@wjh tools]#  make && make install

Wrote PEAR system config file at: /usr/local/php/etc/pear.conf
You may want to add: /usr/local/php/lib/php to your php.ini include_path
/server/tools/php-7.2.0/build/shtool install -c ext/phar/phar.phar /usr/local/php/bin
ln -s -f phar.phar /usr/local/php/bin/phar
Installing PDO headers:           /usr/local/php/include/php/ext/pdo/


```
###【配置PHP】
```sh
#在之前编译的源码包中，找到 php.ini-production，复制到/usr/local/php下，并改名为php.ini：
#[可选项] 设置让PHP错误信息打印在页面上 

[root@wjh php-7.2.0]# cp php.ini-production /usr/local/php/php.ini
[root@wjh php-7.2.0]# vim /usr/local/php/php.ini +477
[root@wjh php-7.2.0]# sed -i '477cdisplay_errors = On' /usr/local/php/php.ini|grep display_er

#复制启动脚本：
[root@wjh php-7.2.0]# cp ./sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
[root@wjh php-7.2.0]# chmod +x /etc/init.d/php-fpm

# 修改php-fpm配置文件：
#1、去掉 pid = run/php-fpm.pid 前面的分号
[root@wjh php-7.2.0]# cd /usr/local/php/etc
[root@wjh etc]# cp php-fpm.conf.default php-fpm.conf
[root@wjh etc]# sed '17cpid = run/php-fpm.pid' php-fpm.conf

#2、修改user和group的用户为当前用户(也可以不改，默认会添加nobody这个用户和用户组)
 [root@wjh etc]# 	
[root@wjh php-fpm.d]#  cp www.conf.default www.conf
[root@wjh php-fpm.d]# vim www.conf
[root@wjh php-fpm.d]# sed -i 's#user = nobody#user = nginx#g' www.conf
[root@wjh php-fpm.d]# sed -i 's#group = nobody#group = nginx#g' www.conf

```
### 【启动PHP】
``` sh
$ /etc/init.d/php-fpm start        #php-fpm启动命令

$ /etc/init.d/php-fpm stop         #php-fpm停止命令

$ /etc/init.d/php-fpm restart        #php-fpm重启命令

$ ps -ef | grep php 或者 ps -A | grep -i php  #查看是否已经成功启动PHP
```

### 【PHP7.2的MySQL扩展】
```sh
#解压，并进入目录：
[root@wjh tools]# cd mysql-24d32a0/
[root@wjh mysql-24d32a0]# /usr/local/php/bin/phpiz
-bash: /usr/local/php/bin/phpiz: No such file or directory
[root@wjh mysql-24d32a0]# /usr/local/php/bin/phpize
Configuring for:
PHP Api Version:         20170718
Zend Module Api No:      20170718
Zend Extension Api No:   320170718
#编译mysql扩展，使用mysql native driver 作为mysql链接库
[root@wjh mysql-24d32a0]# ./configure --with-php-config=/usr/local/php/bin/php-config --with-mysql=mysqlnd
[root@wjh mysql-24d32a0]# make && make install
Dont forget to run 'make test'.
Installing shared extensions:     /usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/
# 最后，编辑php.ini文件，在最后面加入 extension=mysql.so
[root@wjh mysql-24d32a0]# sed -i '$aextension=mysql.so' /usr/local/php/php.ini

```

### 报错解决
```sh
# 错误：virtual memory exhausted: Cannot allocate memory
#问题原因：由于物理内存本身很小，且阿里云服务器并没有分配swap空间，当物理内存不够用时，
3物理内存中暂时不用的内容没地方转存。

#解决方法：手动分配一个swap空间
#创建一个大小为1G的文件/swap
dd if=/dev/zero of=/swap bs=1024 count=1M    
#将/swap作为swap空间
mkswap /swap                                                 
#enable /swap file  for paging and swapping
swapon /swap                                                  
#Enable swap on boot, 开机后自动生效
echo "/swap swap swap sw 0 0" >> /etc/fstab    

好文要顶 关注我 收藏该文  
```

## nginx添加php编译
```sh 
server {
        listen       80;
        server_name  localhost;
       root /data/www;
       index  index.php index.html index.htm;
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        location ~ \.php$ {
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /$document_root$fastcgi_script_name;
            fastcgi_pass   127.0.0.1:9000;
            include        fastcgi_params;
        }

    }
```