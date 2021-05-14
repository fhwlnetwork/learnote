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
