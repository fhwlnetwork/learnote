# 数据查询
```sql
mysql> desc city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   |     |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   |     | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.07 sec)

```
## 1、select语句的应用
### 1.1 select单独使用的情况
```sql

mysql> select @@basedir;
+---------------------+
| @@basedir           |
+---------------------+
| /application/mysql/ |
+---------------------+
1 row in set (0.06 sec)

------ 查询端口
mysql> select @@port;
+--------+
| @@port |
+--------+
|   3306 |
+--------+
1 row in set (0.06 sec)


---值为0 : 提交事务的时候，不立即把 redo log buffer 里的数据刷入磁盘文件的，而是依靠 InnoDB 的主线程每秒执行一次刷新到磁盘。此时可能你提交事务了，结果 mysql 宕机了，然后此时内存里的数据全部丢失。
--值为1 : 提交事务的时候，就必须把 redo log 从内存刷入到磁盘文件里去，只要事务提交成功，那么 redo log 就必然在磁盘里了。注意，因为操作系统的“延迟写”特性，此时的刷入只是写到了操作系统的缓冲区中，因此执行同步操作才能保证一定持久化到了硬盘中。
---值为2 : 提交事务的时候，把 redo 日志写入磁盘文件对应的 os cache 缓存里去，而不是直接进入磁盘文件，可能 1 秒后才会把 os cache 里的数据写入到磁盘文件里去。

mysql> select @@innodb_flush_log_at_trx_commit;
+----------------------------------+
| @@innodb_flush_log_at_trx_commit |
+----------------------------------+
|                                1 |
+----------------------------------+
1 row in set (0.06 sec)

mysql> select database();
+------------+
| database() |
+------------+
| wjh        |
+------------+
1 row in set (0.07 sec)

mysql> select now();
+---------------------+
| now()               |
+---------------------+
| 2021-05-29 17:21:36 |
+---------------------+
1 row in set (0.10 sec)

```

### 1.2 SELECT 配合 FROM 子句使用
```sql
--- -- select 列,列,列 from 表
--- 例子:
--- 1. 查询表中所有的信息(生产中几乎是没有这种需求的)
select * from city;
---2. 查询表中 name和population的值
select name,population from city;
```
### 1.3 SELECT 配合 WHERE 子句使用
```sql
-- select 列,列,列 from 表 where 过滤条件
-- where等值条件查询 *****
---例子:
---- 1. 查询中国所有的城市名和人口数
select name population from city where countrycode='chn';
-- where 配合比较判断查询(> < >= <=) ***** 
---例子: 
------1. 世界上小于100人的城市名和人口数
select name population from city where population <100;
-- where 配合 逻辑连接符(and or) 
--例子:
---1. 查询中国人口数量大于1000w的城市名和人口
select name population from city where countrycode='chn' and population> 1000000;
---2. 查询中国或美国的城市名和人口数
select name population from city where coutrycode='chn' or countrycode='usa';
---3. 查询人口数量在500w到600w之间的城市名和人口数
select name population from city where population between 5000000 and 6000000;
-- where 配合 like 子句 模糊查询 *****
--例子:
-- 1. 查询一下contrycode中带有CH开头,城市信息
select * from city where countrycode='ch%';
--- 注意:不要出现类似于 %CH%,前后都有百分号的语句,因为不走索引,性能极差 如果业务中有大量需求,我们用"ES"来替代

-- where 配合 in 语句 
--例子: 
---   1. 查询中国或美国的城市信息. 
select * from city where countrycode in ('chn','usa')

```
### 1.4 GROUP BY
```sql
--- 将某列种有共同条件的数据行，分成一组，然后在进行聚合函数操作
---- 例子
------ 1、统计每个国家，城市的个数
select countrycode,count(id) from city group by countrycode;
------ 2、统计每个国家的总人口数
select countrycode,count(population) from city group by countrycode;
------ 3、统计每个国家省的个数
-----distinct去除重复
select countrycode,count( distinct district ) from city group by coutrycode;
----- 4、统计中国每个省的总人口数
select district ,count(population) from city where countrycode='chn' group by district;
----- 5、 统计中国 每个省城市的个数
select district ,count(name) from city where countrycode='chn' group by district;
----- 6. 统计中国 每个省城市的名字列表GROUP_CONCAT()
select district ,group_count(name) from city where countrycode='chn' group by district;
----- 按照anhui : hefei,huaian ....显示
mysql> select concat(district,":" , group_concat(name)) from city where countrycode='chn' group by district;

```