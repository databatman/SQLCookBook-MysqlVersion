--多表查询
--需要思考的问题
--①通过什么条件把两张表联系起来
--显示销售部门地址和员工姓名
--如果两张表都有相同名字的字段,则需要带表名(也可以是别名)
select ename,sal,loc,emp.deptno from emp ,dept where dept.dname='sales' and emp.deptno=dept.deptno;
select ename,sal,loc,e.deptno from emp as e ,dept as d where d.dname='sales' and e.deptno=d.deptno;
--显示部门号为10 的部门名,员工名和工资
select d.dname,e.ename,e.sal from emp e,dept d 
where e.deptno=10 and e.deptno=d.deptno;
--显示雇员名,雇员工资及所在部门的名字,并按部门排序
select d.dname,e.ename,e.sal from emp e,dept d 
where e.deptno=d.deptno order by d.dname;


--自连接:在同一张表上的连接查询
--显示某个员工的上级领导的姓名 比如 ford
--1.知道ford上级编号
select ename from emp 
where empno=(select mgr from emp where ename='ford');
--显示公司每个员工名字和他的上级名字
--分析,把emp表看成两张表,分别是worker boss
select worker.ename 雇员,boss.ename 老板 from emp worker,emp boss
where worker.mgr=boss.empno;
--外连接（左外连接和右外连接）在EmpAndDept3里面有介绍
--子查询：嵌入到其他sql语句中的select语句，也叫嵌套查询
--单行子查询，如 显示与smith同一部门的所有员工
select * from emp where deptno=
(select deptno from emp where ename='smith');
--多行子查询
-- 如 查询和部门10的工作相同的雇员的名字,岗位,工资,部门号
select distinct job from emp where deptno=10;
select * from emp where job in
(select distinct job from emp where deptno=10);
--如何排除10部门自己
select * from emp where (job in
(select distinct job from emp where deptno=10)) and deptno!=10;
--在from子句中使用子查询
--







