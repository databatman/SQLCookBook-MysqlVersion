--EmpAndDept5
--主要关于更新表格、数据库备份、日志的开启、删除和通过python来调用mysql

--将select的数据返回创建一个新表
create table emp2 as
       select empno,sal from emp where 1=0;
--这种方式可以创建一个包含列字段但是没有数据的方法，因为后面的where始终为false

--将depno为20的部门的每个员工的薪水更新为现在的110%，要求永久保存，使用update
update emp set sal=sal*1.1 where deptno=10;

--仅更新在emp_bonus中有奖金的人的薪水(1.1倍)
update emp set sal=sal*1.1 where empno in (select empno from emp_bonus);
--使用exists实现跟in一样的功能
update emp e set sal=sal*1.1 where exists(select null from emp_bonus eb where e.empno=eb.empno);
--记住任何时候都要记得where，除非你想全部的数据都更新

--删除重复数据，先insert一个,因为主键的原因，empno不一样，但是我们知道这两就是一个人，是重复的
insert into emp(ename,job,mgr,hiredate,sal,comm,deptno) values('smith','clerk',7902,1980-12-27,1064.80,null,10);
delete from emp where empno not in (select max(empno) from emp group by ename);
--这时会发现delete报错了，原因是因为修改一个表和子查询不能是同一个表(不知道为啥书上的就可以通过。。。)
--有一个办法是将他变成孙子查询！
delete from emp where empno not in (select * from (select max(empno) from emp group by ename) a );



--删除表格
--delete和drop的区别,delete删除的是数据，表列元素还在，drop删除的是整个表
delete from pet;
drop table pet;
--删除单个记录
delete from emp where empno=1000;

--数据库备份和恢复
--有几种方法：
--No.1 土方法：找到电脑上存放mysql数据库的文件夹（一般默认是在mysql文件夹的data里），直接复制文件夹中数据库内的内容....
--             需要恢复的时候就创建一个新数据库将内容复制进去覆盖就行了
--       缺点：依赖于windows的文件存储系统，不能移植到其他类型机器上

--No.2 mysqldump法
--cmd模式下进到bin目录下输入：mysqldump -u root -p basename > backup.sql  
                            --basename为你要备份的数据库名字，backup为导出的文件名，会在bin下生成back.sql文件，或者你在backup.sql前加上路径如：C:\安装文件备份\backup.sql
                            --提示locktable错误则在basename后面加上--skip-lock-tables
--恢复数据库
--从cmd进入数据库界面，执行以下命令，即可
create database restoretest;
use RestoreTest;
source C:/User/backup.sql;  --注：路径最好不要包含中文，我用了中文结果source不到了
                            --    路径最好用/而不是\，source下容易因为转义字符的存在而出错，否则这里要用\\
--      优点：生成的文件可移植到其他机器上
--      缺点：速度较慢

--No.3 采用第三方软件备份(这里就不介绍了)


--日志
--其中的二进制日志记载了你的一系列sql操作，如当系统崩溃，数据库资料丢失，我们通过数据库备份文件恢复之后，
--可以让服务器执行二进日志，将数据库恢复到崩溃之前的状态
--可以通过以下命令查看是否开启了相关的日志：
show global variables like '%log%';
show global variables like 'log_bin';
show binary logs;     --查看二进制日志
show master status;   --查看当前使用的日志(主要查看现在是用的哪个二进制日志)

--暂时开启日志：(关闭mysql之后日志又会关闭)

mysqlbinlog mail-bin.000001 | tail
update 

--要永久开启二进制日志和其他日志，可以配置my.ini文件，配置方法可以查看我的另一篇博文：http://blog.csdn.net/databatman/article/details/49951853
--注：网上大部分的配置都是针对mysql5.6版本以前的，基本已经过时了，此配置方法是针对mysql5.6.x以后版本的

--日志更新(每使用一次，二进制日志的序号+1，即新建一个二进制日志，可使用查看二进制日志的方法查看)
flush logs;
--此外，每次重启服务器也会+1，







--删除数据库
drop database if exists Heros;  --如果存在，就删除


--用python来调用mysql数据库
--参见我的另一篇博文：










