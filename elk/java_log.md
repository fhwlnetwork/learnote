# java多行日志收集
``` shell
# 编辑修改配置文件
[root@db01 ~]# vim /etc/filebeat/filebeat.yml

    - /var/log/elasticsearch/elasticsearch.log
  tags: ["es"]
  multiline.pattern: '^\['
  multiline.negate: true
  multiline.match: after
#####################output_messages##############
setup.kibana:
  host: "10.0.0.51:5601"
#自定义配置输出格式 
output.elasticsearch:
  hosts: ["10.0.0.51:9200"]
#  判断条件可以为其他属性
  indices:
    - index: "nginx-access-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "access"
    - index: "nginx-error-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "error"
    - index: "tomact-access-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "tomact"
    - index: "es-java-%{[beat.version]}-%{+yyyy.MM}"
      when.contains:
        tags: "es"
#重新命名模板名称为ngingx
setup.template.name: "nginx"
#匹配格式，以nginx-开头的模板都使用nginx的模板
setup.template.pattern: "nginx-*"
#不使用系统自自带的模板
setup.template.enabled: false

```
![日志结果](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210427234829.png)
![日志结果2](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img/20210428000715.png)
