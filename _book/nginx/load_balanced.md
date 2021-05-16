# 负载均衡
##  (反向代理)负载均衡的概念说明
```text
 什么是集群?
	完成相同任务或工作的一组服务器 (web01 web02 web03 -- web集群)

什么是负载均衡?
	1) 实现用户访问请求进行调度分配
	2) 实现用户访问压力分担
	
什么是反向代理?
反向代理: 	外网 ---> (eth0外网) 代理服务器 (eth1内网) ---> 公司网站服务器web(内网)
			外网用户(客户端)   ---  代理服务器 (服务端)
			代理服务器(客户端) ---  web服务器(服务端)	

正向代理:   内网(局域网主机)  	--- (内网)代理服务器(外网) --- 互联网 --- web服务器(日本)
            翻墙的操作
```

## 准备负载均衡环境
```text
	01. 先部署好一台LNMP服务器,上传代码信息
	02. 进行访问测试
	03. 批量部署多台web服务器
	04. 将nginx配置文件进行分发
	05. 将站点目录分发给所有主机
```
### ngingx安装：[安装](./install.md)

### 负载配置（虚拟主机配置）
 #### 1. 轮询分配请求(平均)
``` sh
# ngx_http_upstream_module   --- upstream   负载均衡 
# ngx_http_proxy_module	     --- proxy_pass   反向代理
upstream wjhtest {
    server 10.0.0.7:80;
    server 10.0.0.8:80;
    server 10.0.0.9:80;
}
server {
    listen       80;
    server_name  www.wjhtest.com;
    location / {
        proxy_pass http://wjhtest;
    }
}
```
 #### 2. 权重分配请求(能力越强责任越重)
```sh 
upstream wjhtest {
          server 10.0.0.7:80 weight=3;
          server 10.0.0.8:80 weight=2;
          server 10.0.0.9:80 weight=1;
}
server {

}
```
 #### 3. 实现热备功能(备胎功能)
```sh
#当所有的主机都停止服务的时候才生效
upstream wjhtest {
          server 10.0.0.7:80;
          server 10.0.0.8:80;
          server 10.0.0.9:80 backup;
       }
```
#### 4. 定义最大失败次数（健康检查参数）
```sh
upstream wjhtest {
        server 10.0.0.7:80 weight=3   max_fails=5;
        server 10.0.0.8:80 weight=2   max_fails=5;
        server 10.0.0.9:80 backup;
       }
```
#### 5. 定义失败之后重发的间隔时间
```sh
# fail_timeout=10s  会给失败的服务器一次机会
upstream wjhtest {
        server 10.0.0.7:80 weight=3   max_fails=5  fail_timeout=10s ;
        server 10.0.0.8:80 weight=2   max_fails=5  fail_timeout=10s ;
        server 10.0.0.9:80 backup;
       }
```
### 分发配置
```sh
# scp /usr/local/nginx/conf.d/weblb.conf 
```

### 实现不同调度算法
```text
1. rr  轮询调度算法
2. wrr 权重调度算法
3. ip_hash 算法  (出现反复登录的时候)
4. least_conn  根据服务器连接数分配资源
```
#### ip_hash 算法
```sh
upstream wjhtest {
        ip_hash;
        server 10.0.0.7:80 weight=3   max_fails=5  fail_timeout=10s ;
        server 10.0.0.8:80 weight=2   max_fails=5  fail_timeout=10s ;
        server 10.0.0.9:80 backup;
       }
```

#### least_conn 
```sh
#
#假如上一个请求选择了第二台10.0.0.8，下一个请求到来，通过比较剩下可用的server的conns/weight值来决定选哪一台。

#如果10.0.0.7连接数为100，10.0.0.9连接数为80，因为权重分别是2和1，因此计算结果
# 100/2=50, 80/1 =80。因为 50 < 80 所以选择第一台而不选第三台。尽管连接数第一台要大于第三台。

upstream wjhtest {
        ip_hash;
        least_conn;
        server 10.0.0.7:80 weight=3   max_fails=5  fail_timeout=10s ;
        server 10.0.0.8:80 weight=2   max_fails=5  fail_timeout=10s ;
        server 10.0.0.9:80 weight=1 ;
       }
       
```

## 负载均衡企业实践应用
### 需求一，根据用户访问的uri信息进行负载均衡

#### 1、环境配置
```sh
# 10.0.0.8:80 上进行环境部署:
[root@web02 ~]# mkdir /html/www/upload
[root@web02 ~]# echo  "upload-web集群_10.0.0.8" >/html/www/upload/wjhtest.html
# 10.0.0.7上进行环境部署:
	[root@wjhtest01 html]# mkdir /html/www/static
    [root@wjhtest01 html]# echo static-web集群_10.0.0.7 >/html/www/static/wjhtest.html
# 10.0.0.9:80上进行环境部署:
    echo  "default-web集群_10.0.0.9" >/html/www/wjhtest.html
```

#### 2、编写负载均衡配置文件
```sh
upstream upload {
    server 10.0.0.8:80;
}
upstream static {
    server 10.0.0.7:80;
}
upstream default {
    server 10.0.0.9:80;
}
        
server {
    listen       80;
    server_name  www.wjhtest.com;
    location / {
      proxy_pass http://default;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_next_upstream error timeout http_404 http_502 http_403;
    }
    location /upload {
       proxy_pass http://upload;
       proxy_set_header Host $host;
       proxy_set_header X-Forwarded-For $remote_addr;
       proxy_next_upstream error timeout http_404 http_502 http_403;
    }
    location /static {
        proxy_pass http://static;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_next_upstream error timeout http_404 http_502 http_403;
    }
}	

```
```text
总结: 实现网站集群动静分离
	01. 提高网站服务安全性
	02. 管理操作工作简化
	03. 可以换分不同人员管理不同集群服务器
	
```

### 需求二，根据用户访问的终端信息显示不同页面
#### 第一步: 准备架构环境
```sh
	iphone   www.wjhtest.com  --- iphone_access 10.0.0.7:80  mobile移动端集群
	谷歌     www.wjhtest.com  --- google_access 10.0.0.8:80  web端集群
	IE 360   www.wjhtest.com  --- default_access 10.0.0.9:80 default端集群
	
	web01:
	echo "iphone_access 10.0.0.7" >/html/www/wjhtest.html
	web02:
	echo "google_access 10.0.0.8" >/html/www/wjhtest.html
	web03:
	echo "default_access 10.0.0.9" >/html/www/wjhtest.html
```
#### 第二步：编写负载均衡配置文件
```sh

[root@lb01 conf.d]# cat lb.conf
upstream web {
    server 10.0.0.8:80;
}
upstream mobile {
    server 10.0.0.7:80;
}
upstream default {
    server 10.0.0.9:80;
}
    
 
server {
    listen       80;
    server_name  www.wjhtest.com;
    location / {
        if ($http_user_agent ~* iphone) {
            proxy_pass http://mobile;
        }
        if ($http_user_agent ~* Chrome) {
            proxy_pass  http://web;
        }
        proxy_pass http://default;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_next_upstream error timeout http_404 http_502 http_403;
    }
}
    	
```