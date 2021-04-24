# 交互

``` reStructuredText
Head插件在5.0以后安装方式发生了改变，需要nodejs环境支持，或者直接使用别人封装好的docker镜像
插件官方地址
https://github.com/mobz/elasticsearch-head

使用docker部署elasticsearch-head
docker pull alivv/elasticsearch-head
docker run --name es-head -p 9100:9100 -dit elivv/elasticsearch-head

使用nodejs编译安装elasticsearch-head
yum install nodejs npm openssl screen -y
node -v
npm  -v
npm install -g cnpm --registry=https://registry.npm.taobao.org
cd /opt/
git clone git://github.com/mobz/elasticsearch-head.git
cd elasticsearch-head/
cnpm install
screen -S es-head
cnpm run start
Ctrl+A+D

修改ES配置文件支持跨域
http.cors.enabled: true 
http.cors.allow-origin: "*"

```
