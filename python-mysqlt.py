#!usr/bin/env python
#-*- coding:utf-8 -*-



import mysql.connector

#connect用于连接数据库
#cursor.execute用于执行create、insert、update、select等等一系列语句

#创建一个连接数据库的对象con、cursor
con=mysql.connector.connect(host='localhost',user='root',password='1991423',database='cookbook',use_unicode=True)
cursor=con.cursor()

#创建表格
sql1=u"create table pytest (id int primary key,name varchar(20),sex nchar(1) default '男' check(sex in ('男','女')))"
cursor.execute(sql1)

#插入数据的两种写法

#1、小心这种写法，回想一下mysql的插入语句，因为mysql本身在插入数据时字符串就要加'',
#   所以你写的让execute传人数据库的语句也要包含''，包含的方法有：
#           ①外面用双引号"",内部就可以用单引号而不冲突了
#           ②用转义字符\'即可
cursor.execute(u"insert into pytest values(1,'bob','男')")

#2、推荐！
#考虑到数据库是开放用来给用户查询的，所以时常需要修改输入的值，因此这种方法用的较多
sql2=u'insert into pytest values(%s,%s,%s)'
parameter=[2,'Kate','女']
cursor.execute(sql2,parameter)

#将insert的数据更新储存到数据库
conn.commit()

#在数据库的操作界面用selcet * from pytest会发现id=2女生那栏显示的是乱码（可能你的不会遇到）
#原因是上面的代码在传入中文的时候两者的编码可能不一样导致，可以如下用unicode格式更新一下
#顺便复习下update语句
sql3=u'update pytest set sex=%s where id=%s'
parameter=[u'女',2]
cursor.execute(sql3,parameter)
con.commit()


#查询select
cursor.execute('select * from pytest')
#使用fetchall获得所有的返回值
#还有fetchone返回一个，fetchmany返回多个，scroll函数等
#返回的是list，内部每个实例都是tuple
values=cursor.fetchall()

n=cursor.rowcount  #统计execute影响到的行数，像select选出了2行，所以这里n=2
print values
print n



#注：每次调用完select都必须fetchall，才能进行下一次的查询，否则会报错



#记得关闭cursor和conn，避免数据库泄露
cursor.close()
con.close()
#为了避免在执行出错的时候仍然能关闭数据库，多要跟try except finally结合








