--EmpAndDept3
--主要是简单查询和表格的创建(列的默认属性check/unique/default设置))

--from 子句中使用子查询
--显示高于部门平均工资的员工名字,薪水和他所在部门的平均工资
--①首先知道各个部门的平均工资
select avg(sal),deptno from emp group by deptno;
--②把上边的结果当做一个临时表对待
select emp.ename,sal,temp.myavg,emp.deptno from
 emp,(select avg(sal) myavg,deptno from emp group by deptno) temp
where emp.deptno=temp.deptno and emp.sal>temp.myavg;


--分页查询
select * from emp;
--top后边的数表示要挑出的记录数,是sql server语句，mysql不可用
--limit n,i 第一个数值表示从第n+1开始取,i表示总共取几个数，mysql语句

--①显示第一个到第四个入职的雇员
select top 4 * from emp order by hiredate;

select * from emp order by hiredate limit 4;

--请显示第六个到第十个入职的雇员（按照时间的先后顺序）
select top 5 * from emp where empno not in
   (select top 5 empno from emp order by hiredate)
   order by hiredate;

select * from emp order by hiredate limit 5,5;

select * from emp 
    where empno not in (select empno from emp order by hiredate) 
    order by hiredate;

--显示第十一个到十三个入职的信息(时间顺序)
select top 3 * from emp where empno not in
(select top 10 empno from emp order by hiredate)
order by hiredate;

select * from emp order by hiredate limit 10,3;

--测试效率(压力测试)时数据的产生,疯狂复制 如: 
--identity是sqlserver的自增，mysql不可用
create table test(
testId int primary key identity(1,1),
testName varchar(30),
testPass varchar(30))engine=InnoDB;

--mysql使用auto_increment
create table test(
testId int auto_increment primary key,
testName varchar(30),
testPass varchar(30))engine=InnoDB;


insert into test (testName,testPass) values('xupei','xupei');
insert into test (testName,testPass) select testName,testPass from test --复制列
select count(*) from test
select * from test
select testId from test 
drop table test
--测试后,分页的效率还是很高的

--如何删除一张表中重复记录
create table temp(
catId int,
catName varchar(40)
)

insert into cat values(1,'aa');
insert into cat values(2,'bb');

insert into cat select * from cat;    --复制数据

insert into temp select * from cat;   --把cat 的记录distinct后，放入临时表中
delete from cat;                       --cat表的记录清空
insert into cat select * from #temp;   --把#temp中的数据（无重复记录）插入cat中
drop table temp;                       --删除临时表#temp


--左外连接和右外连接
--显示公司每个员工和他的上级的名字
--内连接（匹配上的才能显示）
select w.ename,b.ename from emp w,emp b where w.mgr=b.empno;

--显示公司每个员工和他的上级的名字,要求没有上级的人也要显示
--左外连接:如果左边的表记录全部显示,如果没有匹配的记录,就NULL来填
--右外连接：如果右边的表记录全部显示,如果没有匹配的记录,就NULL来填
--join其实就是把两个表联合在一起了
select w.ename,b.ename from emp w left join emp b on w.mgr=b.empno;
--外连接的作用特别强大，有时比where好，因为很多时候，我们不只是要选出需要的值，也需要对那些不含有某些值的行进行操作，EmpAndDept4有例子

--创建的表的列约束
--约束用于确保数据库满足特定的商业规则,在sql server 中，约束包括
--not null,unique,primary key,foreign key和check五种
--not null:如果在列上定义了not null ，那么插入数据时，必须为列提供数据
--auto_increment,即使插入记录失败也会自增1
create table test1(
test1Id int auto_increment primary key,
test1name varchar(30) unique,
test1pass varchar(30) not null,
test1age int
)engine=InnoDB;
--unique:当定义了唯一约束后，该列值是不能重复的，但是可以为null,且最多只有一个null
--primary key:用于唯一标示表行的数据，当定义主键约束后，该列不能重复，且不能为null
--需要说明的是：一张表最多有一个主键，但可以有多个unique约束
--表可以有复合主键
--复合主键小案例、
create table test2(
test1Id int ,
test1name varchar(30) ,
test1pass varchar(30) ,
test1age int
primary key(test1Id,test1name)
)engine=InnoDB;
--行级定义和表级定义
--foreign key：用于定义主表和从表之间的关系，外键约束要定义在从表上，
--主表则必须具有主键约束或unique约束，当定义外键约束后，要求外键列数据
--必须在主表的主键列存在或为null

--check:用于强制行数据必须满足的条件，假定在sal列上定义了check约束，并要求
--sal列值在1000~2000之间，如果不在1000~2000之间，就会提示出错
create table test3(
test1Id int ,
test1name varchar(30) ,
test1pass varchar(30) ,
sal int check(sal>=1000 and sal<=2000)
)engine=InnoDB;

--default使用
create table mes(
mesId int auto_increment primary key,
mescon varchar(2000) not null,
mesdate datetime default getdate()
)engine=InnoDB;
insert into mes(mescon) values('你好')
insert into mes(mescon,mesdate) values('你好','2015-8-5')
select * from mes




--商店售货系统表设计案例
--现有一个商店的数据库,记录客户及其购物情况,由下边三个表组成:
--商品goods(商品号goodsId，商品名goodsName,单价unitprice,商品类别category
--,供应商pr0vider);
--客户custumer(客户号customerId,姓名name,住址address,电邮email,性别sex,
--身份证cardId);
--购买purchase(客户号customerId,商品号goodsId,购买数量nums);
--用SQL语言完成下列功能：
--1 建表，在定义中要求声明：
--① 每个表的主外键；
--② 客户的姓名不能为空值；
--③ 单价必须大于0，购买数量必须在1到30之间；
--④ 电邮不能够重复；
--⑤ 客户性别必须是男或者女，默认是男
--⑥ 商品类别是 食物 日用品

--goods表
create table goods(
goodId nvarchar(50) primary key,
goodName nvarchar(80) not null,
unitprice numeric(10,2) check (unitprice>0),
category nvarchar(3) check(category in('食物','日用品')),
provider nvarchar(50)
)engine=InnoDB;

--customer表
--在mysql中同时设置default和check时需要先设置default 之后再加check约束，否则会报错
create table customer(
customerId nvarchar(50) primary key,
customername nvarchar(50) not null,
address nvarchar(100),
email nvarchar(100) unique,
sex nchar(1) default '男' check(sex in ('男','女'))  ,
cardId nvarchar(18)
)engine=InnoDB;

--purchase表
create table purchase(
customerId nvarchar(50) ,
goodId nvarchar(50) ,
nums int check(nums>0),
foreign key(customerId) references customer(customerId),
foreign key(goodId) references goods(goodId)
)engine=InnoDB;

















