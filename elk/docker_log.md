# 收集docker日志
## docker安装:[docker安装过程](../k8_docker/install.md)

``` shell
#配置docker
cat  >docker-compose.yml<<EOF
version: '3'
services:
  nginx:
    image: nginx:v2
    # 设置labels
    labels:
      service: nginx
    # logging设置增加labels.service
    logging:
      options:
        labels: "service"
    ports:
      - "8080:80"
  db:
    image: nginx:latest
    # 设置labels
    labels:
      service: db 
    # logging设置增加labels.service
    logging:
      options:
        labels: "service"
    ports:
      - "80:80"
EOF

#配置修改
 cat  >/etc/filebeat/filebeat.yml<<EOF
filebeat.inputs:
- type: log
  enabled: true 
  paths:
    - /var/lib/docker/containers/*/*-json.log
  json.keys_under_root: true
  json.overwrite_keys: true
output.elasticsearch:
  hosts: ["10.0.0.51:9200"]
  indices:
    - index: "docker-nginx-access-%{[beat.version]}-%{+yyyy.MM.dd}"
      when.contains:
          attrs.service: "nginx"
          stream: "stdout"
    - index: "docker-nginx-error-%{[beat.version]}-%{+yyyy.MM.dd}"
      when.contains:
          attrs.service: "nginx"
          stream: "stderr"
    - index: "docker-db-access-%{[beat.version]}-%{+yyyy.MM.dd}"
      when.contains:
          attrs.service: "db"
          stream: "stdout"
    - index: "docker-db-error-%{[beat.version]}-%{+yyyy.MM.dd}"
      when.contains:
          attrs.service: "db"
          stream: "stderr"
setup.template.name: "docker"
setup.template.pattern: "docker-*"
setup.template.enabled: false
setup.template.overwrite: true

EOF

```