# 邮件报警配置

## 1、创建触发器
```text
配置---主机---选择相应监控主机触发器---创建触发器 
	设置好表达式
	{web01:server_state[nginx].last()}<=2
	{监控主机名称:键值名称.调用的表达式函数}<=2 
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510210940.png)

## 2、修改动作配置
```text
    配置---动作---将默认动作进行开启	
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510211127.png)
## 3、建立和163邮箱服务关系
```text
    管理---报警媒介类型---创建报警媒介
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510211317.png)
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510213109.png)
## 4、定义接收报警的邮件地址
```text
    小人头--报警媒介--设置收件人信息
```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510213649.png)