# Docker容器监控之CAdvisor+InfluxDB+Granfana

## 是什么

CAdvisor监控收集+InfluxDB存储数据+Granfana展示图表

![image-20220207203936667](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072039735.png)

![image-20220207203948907](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072039975.png)

![image-20220207204017835](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072040899.png)

## 安装
### 新建目录，创建文件

```sh
[root@wjh ~]# mkdir /mydocker/cig -p
[root@wjh ~]# cd /mydocker/cig/
[root@wjh cig]# touch docker-compose.yml
[root@wjh cig]# vim docker-compose.yml
```

```yaml
version: '3.1'
 
volumes:
  grafana_data: {}
 
services:
 influxdb:
  image: tutum/influxdb:0.9
  restart: always
  environment:
    - PRE_CREATE_DB=cadvisor
  ports:
    - "8083:8083"
    - "8086:8086"
  volumes:
    - ./data/influxdb:/data
 
 cadvisor:
  image: google/cadvisor
  links:
    - influxdb:influxsrv
  command: -storage_driver=influxdb -storage_driver_db=cadvisor -storage_driver_host=influxsrv:8086
  restart: always
  ports:
    - "8080:8080"
  volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:rw
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
 
 grafana:
  user: "104"
  image: grafana/grafana
  user: "104"
  restart: always
  links:
    - influxdb:influxsrv
  ports:
    - "3000:3000"
  volumes:
    - grafana_data:/var/lib/grafana
  environment:
    - HTTP_USER=admin
    - HTTP_PASS=admin
    - INFLUXDB_HOST=influxsrv
    - INFLUXDB_PORT=8086
    - INFLUXDB_NAME=cadvisor
    - INFLUXDB_USER=root
    - INFLUXDB_PASS=root

```

#### 启动docker-compose文件

```sh
docker-compose up
```

![image-20220207204601333](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/202202072046424.png)

### 浏览cAdvisor收集服务，http://ip:8080/

![image-20220208105214788](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208105214788.png)

### 浏览influxdb存储服务，http://ip:8083/

![image-20220208105853184](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208105853184.png)

### 浏览grafana展现服务，http://ip:3000

ip+3000端口的方式访问,默认帐户密码（admin/admin）

#### 配置步骤

1、配置数据源

![image-20220208110034152](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208110034152.png)



2、选择influxdb数据源

![image-20220208110112869](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208110112869.png)

![image-20220208110212135](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208110212135.png)

![image-20220208110334052](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208110334052.png)

3、配置面板panel

![image-20220208111211233](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208111211233.png)

选择图表

![image-20220208111355151](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208111355151.png)

配置数据

![image-20220208111510209](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208111510209.png)

![image-20220208111619065](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208111619065.png)

![image-20220208112454038](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/image-20220208112454038.png)