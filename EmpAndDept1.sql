--win 7 环境
--语句已修改成mysql专用
--先启动mysql数据库服务器，才能进入mysql
--方法是用管理员模式运行cmd，在mysql的bin文件夹里使用net start mysql启动
--启动后可输入mysql -h localhost -u root -p 进入数据库，这时需要密码，刚安装好后默认密码是空，按enter就行
--进入数据库

--修改密码,用update函数
update mysql.user set password=PASSWORD(1991423) where user='root';

--创建数据库cookbook
create database cookbook;
--显示所有的数据库
show databases;
--进入数据库
use cookbook;
--显示所有的表格
show tables;

--创建dept表，将表格的格式设置为InnoDB，,mysql默认的格式myisam，这种表格的操作速度快，但是不能设置外键
--修改为适合mysql的代码

create table dept
(deptno int primary key,  --设置成主键
dname nvarchar(30),
loc nvarchar(30))engine=InnoDB;

--查看dept表格的列情况
describe dept;


--创建emp
create table emp
(empno int primary key,
 ename nvarchar(30),
 job nvarchar(30),
 mgr int,
 hiredate datetime,
 sal numeric(10,2),
 comm numeric(10,2),
 deptno int,  --需要先声明才能在下面作为外键
 foreign key (deptno) references dept(deptno) on delete cascade)engine=innoDB;



--针对外键请注意
--  ①外键只能指向主键
--  ②外键和主键的数据类型要一致
insert into dept values(10,'accounting','new york');
insert into dept values(20,'research','dallas');
insert into dept values(30,'sales','chicago');
insert into dept values(40,'operations','boston');

--以下的语句书写方式会按照emp后面的括号里面的顺序来输入
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7934,'miller','clerk',7782,'1982-1-23',1300.00,10);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7902,'ford','analyst',7566,'1981-12-3',3000.00,20);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7900,'james','clerk',7698,'1981-12-3',950.00,30);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7876,'adams','clerk',7788,'1987-5-23',1100.00,20);
insert into emp values
(7844,'turner','salsman',7698,'1982-9-8',1500.00,0.00,30);
insert into emp(empno,ename,job,hiredate,sal,deptno) values
(7839,'king','president','1981-11-17',5000.00,10);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7788,'scott','analyst',7566,'1987-4-19',3000.00,20);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7782,'clark','manager',7839,'1981-6-9',2450.00,10);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7698,'blake','manager',7839,'1981-5-1',2850.00,30);
insert into emp values
(7654,'martin','salsman',7698,'1981-9-28',1250.00,1400.00,30);
insert into emp(empno,ename,job,mgr,hiredate,sal,deptno) values
(7566,'jones','manager',7839,'1981-4-2',2975.00,20);
insert into emp values
(7521,'ward','salesman',7698,'1981-2-22',1250.00,500.00,30);
insert into emp values
(7499,'allen','salseman',7698,'1981-2-20',1600.00,300.00,30);
insert into emp (empno,ename,job,mgr,hiredate,sal,deptno) values
(7369,'smith','clerk',7902,'1980-12-27',800.00,20);

--从储存成文本格式的文件中直接写入数据库，如：
LOAD DATA LOCAL infile ‘D:/pet.txt’ 
     INTO TABLE emp 
                lines terminated BY ‘\r\n’
--每行间要用换行符隔开


--查询所有列
select * from emp;
select * from dept;
--查询指定列
--select 字段1，字段2 from 表名 where 条件
--如：查询smith 的薪水，工作和所在部门
select sal,job,deptno from emp where ename='smith';
--如何取消重复行(distinct只会消除完全相同的行)
--select distinct 字段 from 表名 where 条件
--如：统计共有多少个部门编号？
select distinct deptno from emp;
--使用算术表达式
--显示每个雇员的年工资
select ename,sal*13 '年工资' from emp;
--更精确的表达(加上奖金),如何处理NULL问题
select ename ,sal*13+isnull(comm*13,0) 年工资 from emp;
--使用where子句
--显示工资高于3000的员工
select * from emp where sal>3000;
--查找1982.1.1后入职的员工
select * from emp where hiredate>'1982.1.1';
--显示工资在2000和2500之间的
select * from emp where sal between 2000 and 2500;
select * from emp where sal>2000 and sal<2500;
--如何使用like操作符（模糊查询），like后面的是正则表达式，不懂的可百度下，使用规则都大同小异
--只是注意，当添加了^或$作为开头和结尾的匹配时，like要改写成regexp才行
--显示首字符为S的员工姓名和工资
select ename,sal from emp where ename like 'S%';
--显示第三个字符为O的所有员工姓名和工资
select ename,sal from emp where ename like '__O%';

--如何显示empno为123,345,800...的雇员情况
--可以这样 select * from emp where empno=123 or empno=345 or empno=800
--但是这样效率太低，处理这种情况，一般用 in 关键字
select * from emp where empno in(123,345,800);

--is null 的使用
--显示没有上级雇员的情况
select * from emp where mgr is null;

--使用逻辑操作符号
-- 查询工资高于500或者岗位为MANAGER雇员,同时还要满足他们姓名首字母为J
select * from emp where (sal>500 or job='manager') and ename like 'j%';

--order by 子句,默认升序,降序时用 order by desc
--按工资从低到高的顺序显示雇员的信息
select * from emp order by sal desc;
--按照入职的先后顺序排列
select * from emp order by hiredate;
--部门号升序，工资降序,order by 可以根据不同的字段排序
select * from emp order by deptno,sal desc;
--使用列的别名排序，如：把年薪算出来，年薪从低到高排序
select ename,sal*13+isnull(comm) as nianxin from emp order by nianxin;


--表的复杂查询

--数据分组 max,min,avg,sum,count
--显示最高和最低工资
select min(sal) from emp;
--如何显示相关信息,涉及到子查询
select * from emp where sal=(select min(sal) from emp);
--显示所有员工的平均工资和工资总和
select avg(sal) 平均工资,sum(sal) 总工资 from emp;
--找出高于平均工资的雇员的名字和他的工资
select ename,sal from emp where sal>(select avg(sal) from emp);
--找出高于平均工资的雇员的名字和他的工资,并显示平均工资

--计算多少员工
select count(*) from emp;


--group by 用于对查询结果分组显示
--having 子句用于限制分组显示结果
--显示每个部门的平均工资和最高工资
select avg(sal) 平均工资, max(sal) 最高工资,deptno from emp group by deptno;
--显示每个部门的每种岗位的平均工资和最低工资
select avg(sal),min(sal),deptno,job from emp group by deptno,job order by deptno;
--显示平均工资低于2000的部门号和它的平均工资
--having 往往和group by 结合使用，它可以对分组查询结果进行筛选
select avg(sal),deptno from emp group by deptno having avg(sal)<2000;
--显示平均工资高于2000的部门号和它的平均工资,并按照从低到高
select avg(sal),deptno from emp group by deptno having avg(sal)>2000 order by avg(sal);

