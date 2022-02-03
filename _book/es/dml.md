# 增删改查
``` shell
#创建索引
[root@db01 /etc/elasticsearch]#curl -XPUT '10.0.0.51:9200/vipinfo?pretty'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "vipinfo"
}
#插入文档数据
curl -XPUT '10.0.0.51:9200/vipinfo/user/1?pretty' -H 'Content-Type: application/json' -d'
{
    "first_name" : "John",
    "last_name": "Smith",
    "age" : 25,
    "about" : "I love to go rock climbing", "interests": [ "sports", "music" ]
}'


curl -XPUT  'localhost:9200/vipinfo/user/2?pretty' -H 'Content-Type: application/json' -d' {
"first_name": "Jane",
"last_name" : "Smith",
"age" : 32,
"about" : "I like to collect rock albums", "interests": [ "music" ]
}'

curl -XPUT  'localhost:9200/vipinfo/user/3?pretty' -H 'Content-Type: application/json' -d' {
"first_name": "Douglas", "last_name" : "Fir",
"age" : 35,
"about": "I like to build cabinets", "interests": [ "forestry" ]
}'
#说明：创建数据时，使用默认的随机id,如果需要与mysql建立联系可以新增一个sid列，填入mysql中数据列的id
```


![状态说明](https://cdn.jsdelivr.net/gh/fhwlnetwork/blos_imgs/img20210423145828.png)