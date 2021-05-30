# 数据库操作
# 用户的操作
## 建用户
```sql
mysql> create user oldboy@'10.0.0.%' identified by '123';
Query OK, 0 rows affected (0.00 sec)
```
## 修改用户密码
```sql 
mysql> alter user wjh@'localhost' indentified by '123456';
```
## 权限管理
### 权限列表
```sql
--  ALL 
--  SELECT,INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER, CREATE TABLESPACE
--- 授权命令
grant all on *.* to oldguo@'10.0.0.%' identified by '123' with grant option;
--- 1. 创建一个应用用户wordpress，可以通过10网段，wordpress库下的所有表进行SELECT,INSERT, UPDATE, DELETE.
mysql> grant SELECT,INSERT, UPDATE, DELETE wordpres.* to wordpress@'10.0.0.%' indentified by '123456' with grant option

----查看用户权限
mysql> show grants for wordpress@'10.0.0.%'

--- 权限回收
mysql>  revoke delete on wordpress.* from  'wordpress'@'10.0.0.%';

```
## DDL的应用--数据定义语言
### 库的定义
```sql
---- 创建数据库
CREATE DATABASE zabbix CHARSET utf8mb4 COLLATE utf8mb4_bin;
---- 收看数据库
SHOW DATABASES;
---- 删除数据库
DROP DATABASE TEST;
---- 修改数据库字符集
----- 注意：一定是从小往大改，如utf8==>utf8mb4
-----  目标字符集一定是源字符集的严格超级；
alter table test charset utf8mb4;

```
### 表定义
#### 创建表
```sql
--- 建表
表名,列名,列属性,表属性
--- 列属性
PRIMARY KEY : 主键约束,表中只能有一个,非空且唯一.
NOT NULL    : 非空约束,不允许空值
UNIQUE KEY  : 唯一键约束,不允许重复值
DEFAULT     : 一般配合 NOT NULL 一起使用.
UNSIGNED    : 无符号,一般是配合数字列,非负数
COMMENT     : 注释
AUTO_INCREMENT : 自增长的列

CREATE TABLE stu (
id INT PRIMARY KEY NOT NULL AUTO_INCREMENT COMMENT '学号',
sname VARCHAR(255) NOT NULL  COMMENT '姓名',
age TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '年龄',
gender ENUM('m','f','n') NOT NULL DEFAULT 'n' COMMENT '性别',
intime DATETIME NOT NULL DEFAULT NOW() COMMENT '入学时间'
)ENGINE INNODB CHARSET utf8mb4;

```
#### 查询建表信息
```sql
---查看数据库的所有表
SHOW TABLES;
---查看表的创建语句
SHOW CREATE TABLES stu;
---查看表的字段
DESC stu;
```
#### 创建一个表结构一样的表
```sql
create table t1 like stu;
```
#### 删除表
```sql 
drop table test;
```
#### 修改表
```sql
--- 再stu表种增加qq列
alter table  stu ADD qq int(11) not null comment 'qq号';
--- 在sname后加微信列 
alter table stu add wechat varchar(20) not null comment '微信号' after sname;
------- 把刚才添加的列都删掉(危险,不代表生产操作) ***
alter table stu drop qq;
alter table stu drop wechat;
--- 修改sname数据类型的属性 
alter table stu modify sname varchar(64) not null comment '姓名';
--- 将gender改位sex 数据类型改为char
alter table stu change dender sex char(4) not null comment '性别'
```

#### 建表规范
```text
--- 1. 表名小写字母,不能数字开头,
--- 2. 不能是保留字符,使用和业务有关的表名
--- 3. 选择合适的数据类型及长度
--- 4. 每个列设置 NOT NULL + DEFAULT .对于数据0填充,对于字符使用有效字符串填充
--- 5. 没个列设置注释
--- 6. 表必须设置存储引擎和字符集
--- 7. 主键列尽量是无关列数字列,最好是自增长
--- 8. enum类型不要保存数字,只能是字符串类型
```
#### DML  数据操作语言
##### 插入数据

```SQL
--- 数据插入
-----规范写法
insert into stu(id,snamq,age,sex,intime) values (1,'wjh',27,'f',NOW() );
-----缩略写法
insert into stu values (1,'wjh',27,'f',NOW() );
--- 针对性的录入数据
INSERT INTO stu(sname,age,sex) VALUES ('w5',11,'m');

```
##### 删除数据
```SQL
-- update(一定要加where条件)
update stu set sname='test' where id=1;
-- delete (一定要有where条件)
DELETE FROM stu WHERE id=9;
```
##### 特别说明
```text
-- 生产中屏蔽delete功能
--- 使用update替代delete 
ALTER TABLE stu ADD is_del TINYINT DEFAULT 0 ;
UPDATE stu SET is_del=1 WHERE id=7;
SELECT * FROM stu WHERE is_del=0;
```
#### DQL  数据查询语言



