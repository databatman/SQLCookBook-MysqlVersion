--复杂的多表查询

--显示表格前几行
select * from emp limit 4;
--显示前几名，降序、必须有别名x，否则会报错
select * from(select * from emp order by sal) as x limit 4;
--选取表示为：clark as a manager即'ename' as a 'job'
select concat(ename,' work as a ',job) as x from emp where deptno=10;
--随机产生5个实例
select ename,job from emp order by rand() limit 5;
--选取comm列，同时用0来代替空值  PS：isnull(comm)返回的是1,0；coalesce(comm)返回的是实际值和0
--也可以使用case函数 is null then 0
select ename,coalesce(comm) as comm from emp;

--重复的数据
--union对2个结果集取并集，重复数据仅显示一次
--union all 对...，       重复数据全部显示
--如下例子（所谓视图就是临时表的意思，但要知道，当实际表的内容改变时，视图的表也会跟着改变）
--第二个语句创建的v将在后面使用到
create view v as select * from emp union select * from emp;
create view v as 
       select * from emp where deptno!=10 
       union all 
       select * from emp where ename='WARD';

--exists函数（速度较快）
--功能跟in有点类似，exists()括号内存在时返回true，否则返回false
--记住exists里面的where需要跟外部的dept表有联合，否则exists会只返回true
--例子：查询在deptno里，emp里没有的部门
select depno from dept d where not exists(select deptno from emp e where e.deptno=d.deptno);

--使用关联子查询和union all 来查找视图V中存在而在表emp中不存在的行，然后与在表emp中存在而在视图v中不存在
--的行进行合并
--cookbook上的这个例子简直又臭又长，花了好长功夫才搞懂，如下：
--要看懂这个得简化下他的表达式如下：
--select * from e where not exists(select null from v where v.all=e.all)
--意思就是当e中的数据，v中有时，not exists就返回false，没有时则返回true，ok，这就是我们要的那行，选出来
--select null是选出一列null列，通常用在exists，表示我们其实不是要选列，只是想通过他的返回来判断真假
--记住这里的null列在exists中是真值
select * 
from (  
      select e.empno,e.ename,e.job,e.mgr,e.hiredate,
             e.sal,e.comm,e.deptno,count(*) as cnt 
      from emp e 
      group by empno,ename,job,mgr,hiredate,sal,comm,deptno
      ) e 
where not exists
      (
      select null 
      from(
           select v.empno,v.ename,v.job,v.mgr,v.hiredate,
                  v.sal,v.comm,v.deptno,count(*) as cnt
           from v
           group by empno,ename,job,mgr,hiredate,sal,comm,deptno
           ) v
      where  v.empno=e.empno
         and v.ename=e.ename
         and v.job=e.job
         and v.mgr=e.mgr
         and v.hiredate=e.hiredate
         and v.sal=e.sal
         and v.deptno=e.depno
         and v.cnt=e.cnt
         and coalesce(v.comm,0)=coalesce(e.comm,0)
      )
      
      union all
      
select * 
from (--跟上面一模一样，只是把v跟e倒换过来了,可以自己写一遍试试
     )

     
--创建一个emp_bonus 表
create table emp_bonus(
    empno int primary key,
    received date,
    type int,
    )engine=InnoDB;
insert into emp_bonus values(7934,2005-3-17,1);
insert into emp_bonus values(7839,2005-2-15,3);
insert into emp_bonus values(7782,2005-2-15,1);
--插入以下行，会发现插入失败，所以现在我们要先学下怎么去除主键
insert into emp_bonus values(7934,2005-2-15,2);
--去除主键：1.先去除自增长  2.去除主键
--（自增长的意思是即使你的insert里面没有主键，他也会默认设置为0，但是下次再这样insert就不行了，因为主键唯一，不能再默认为0）
alter table emp_bonus empno empno int(10);
alter table emp_bonus drop primary key;
--之后再insert

--返回所有员工的姓名，工资,部门号和奖金，type为1时奖金为薪水的10%，type为2时奖金为薪水的20%，3时为30%
select e.empno,e.ename,e.deptno,e.sal,e.sal* case 
   when eb.type=1 then .1
   when eb.type=2 then .2
   when eb.type=3 then .3
   else 0
   end as bonus
   from emp e left join emp_bonus eb on e.empno=eb.empno;
--注意结果miller有2个奖金

--可以使用sum和group by将相同员工编号的人奖金汇总到一起   
select e.empno,e.ename,e.deptno,e.sal,sum(e.sal* case 
   when eb.type=1 then .1
   when eb.type=2 then .2
   when eb.type=3 then .3
   else 0
   end) as bonus
   from emp e left join emp_bonus eb on e.empno=eb.empno 
   group by e.empno;
    
--计算各个部门员工的全部薪水总和、全部奖金总和
select deptno,
       sum(sal) as total_sal,
       sum(bonus) as total_bonus
       from(
       select e.empno,e.ename,e.deptno,e.sal,e.sal* case 
              when eb.type=1 then .1
              when eb.type=2 then .2
              when eb.type=3 then .3
              else 0
              end as bonus
              from emp e left join emp_bonus eb on e.empno=eb.empno
           ) x
       group by deptno ;
--你会发现总体薪水那一栏返回的值是错误的，可以自己计算检测一下，原因是因为x中有重复的人被多次计算了，因为他获得了多个奖金
--解决办法是在x中加入group by e.empno 
--但是只加group的话会发现奖金那栏又不对了。。所以正确的做法是还要加入个sum函数统计bonus，如下：
select deptno,
       sum(sal) as total_sal,
       sum(bonus) as total_bonus
       from(
       select e.empno,e.ename,e.deptno,e.sal,sum(e.sal* case 
              when eb.type=1 then .1
              when eb.type=2 then .2
              when eb.type=3 then .3
              else 0
              end 
              ) as bonus
              from emp e left join emp_bonus eb on e.empno=eb.empno
              group by e.empno
           ) x
       group by deptno ;
--要注意到，上面的例子基本都使用了外联接left join，如果这里不是使用的外联接而是where的话，自行对比下面两个语句：

select e.empno,e.ename,e.deptno,e.sal,sum(e.sal* case 
              when eb.type=1 then .1
              when eb.type=2 then .2
              when eb.type=3 then .3
              else 0
              end 
              ) as bonus
              from emp e left join emp_bonus eb on e.empno=eb.empno
              group by e.empno;
              
select e.empno,e.ename,e.deptno,e.sal,sum(e.sal* case 
              when eb.type=1 then .1
              when eb.type=2 then .2
              when eb.type=3 then .3
              else 0
              end 
              ) as bonus
              from emp e ,emp_bonus eb 
              where e.empno=eb.empno
              group by e.empno;
--第二个语句只产生了含有bonus的列，有时需要这样，但是当需要用到其他不含奖金的行一起来统计薪水总和时他就会出错，
--如前面的例子，用where筛选出来的表无法得到total_sal