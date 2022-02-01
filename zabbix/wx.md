# 微信报警配置
## 1、需要注册企业微信,并进行配置
```text
我的企业: 
	01. 获取企业id: ww32d68104ab5f51b0
	02. 获取企业二维码: 允许员工加入
管理工具:
	01. 成员加入---进行审核通过
	应用小程序:
	01. 进行创建
	02. 收集程序信息
	    AgentId: 
		Secret: RvQYpaCjWbYMCcwhnPqg1ZYcEGB9cOQCvvlkn-ft6j4

```
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510221106.png)
![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210510221146.png)

![](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210512164342.png)

##    2、脚本wx.py

```text
cat /etc/zabbix/zabbix-server.conf 
	AlertScriptsPath=/usr/lib/zabbix/alertscripts  --- 放置告警脚本
```



```py
#!/usr/bin/env python
#-*- coding: utf-8 -*-
import requests
import sys
import os
import json
import logging
logging.basicConfig(level = logging.DEBUG, format = '%(asctime)s, %(filename)s, %(levelname)s, %(message)s',datefmt = '%a, %d %b %Y %H:%M:%S',filename = os.path.join('/tmp','weixin.log'),filemode = 'a')
corpid='ww4f8d9fad75efbe'

```

## 3、修改添加报警媒介---定义发微信配置