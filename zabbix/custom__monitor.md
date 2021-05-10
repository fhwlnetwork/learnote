# zabbix自定义监控

```text
监控项: 可以自定义监控收集主机的信息
应用集: 将多个类似的监控项进行整合 便于查看检查
模板:   将多个监控项 触发器 图形都配置在模板中, 方便多个监控的主机进行调用
动作:	指定将报警信息发送给谁OK/定义报警的信息ok/定义报警的类型OK(邮件 微信 短信电话)
	    PS: 宏信息定义方法: 
		https://www.zabbix.com/documentation/4.0/zh/manual/appendix/macros/supported_by_location
触发器: 可以实现报警提示(条件表达式),默认页面提示报警
图形:   将多个图整合成一张,便于分析数据
报警媒介: 定义报警的方式
```
## 需求: 监控nginx服务是否启动
### 1) 在zabbix-agent进行配置文件编写
 #### 第一步: 编写自定义监控命令
```sh
[root@web01 zabbix_agentd.d]# ps -ef|grep -c [n]ginx
```
#### 第二步：编写zabbix-agent配置文件
```sh
#第一种方法: 直接修改zabbix-agent配置文件参数
	UserParameter=
# 第二种方法: 在zabbix_agentd.d/目录中编写自定义监控文件
#	UserParameter=键(变量名),值(变量信息)
#	UserParameter=web_state,ps -ef|grep -c [n]ginx
[root@web01 zabbix_agentd.d]# cat web_server.conf 
UserParameter=web_state,ps -ef|grep -c [n]ginx
```
#### 第三步: 重启zabbix-agent服务
```sh
[root@web01 zabbix_agentd.d]# systemctl restart zabbix-agent.service 
[root@web01 zabbix_agentd.d]# systemctl status zabbix-agent.service 
```
### 2) 在zabbix-server命令行进行操作
   #### 第一步： 检测自定义监控信息是否正确
```sh
[root@zabbix ~]# yum -y install zabbix-get
[root@zabbix ~]# zabbix_get -s 10.0.0.7 -k 'web_state'
3
```
### 3)在zabbix-server网站页面进行配置
#### 第一个历程: 进入到创建监控项页面:
```text
配置---主机---选择相应主机的监控项
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510172909.png)
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510172944.png)
#### 第二个历程: 监控项页面如何配置:
```text
名称 键值 更新间隔时间 应用集
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510173508.png)
#### 第三个历程: 检查是否收集到监控信息
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510173658.png)

## 需求2:复杂的自定义监控配置(多个服务状态)
```sh
# 编辑配置文件
[root@web01 zabbix_agentd.d]# vim server_state.conf
UserParameter=server_state[*],netstat -lntup|grep -c $1
# 重启服务
[root@web01 zabbix_agentd.d]# systemctl restart zabbix-agent.service 
[root@web01 zabbix_agentd.d]# 
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510174712.png)