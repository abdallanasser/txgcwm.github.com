---
layout: post
title: "Linux操作系统下的MAN命令"
date: 2013-07-27 13:27
comments: true
categories: [Shell, Unix/Linux]
---
Unix/Linux下的man命令可以查询常用的命令和函数。可是只知道用“man 函数名”来查询会遇到很多问题，比如`man read`，想看的是ANSI C中stdio的read函数原型和说明，出来的却是BASH命令的说明。这是怎么回事呢？原来read本身是man命令的一个参数，这样就会以为你要使用read的功能，而不是查看read函数。那么要怎样查看read函数呢?可以使用`man 2 read`或者是`man 3 read`查看。


#分卷号

以上指令的中间数字是什么意思呢？是man的分卷号，所有的手册页都属于一个特定的分卷号，用一个字符来表示。Linux下最通用的分卷号及其名称和说明如下表所示。

分卷号         |名称 |说明
--------------|---------------|---------------   
1| 用户命令     | 可由任何人启动  
2| 系统调用     | 由内核提供的函数  
3| 例程        | 库函数    
4| 设备        | /dev目录下的特殊文件   
5| 文件格式描述  | 例如/etc/passwd   
6| 游戏        | 略  
7| 杂项        | 例如宏命令包、惯例等  
8| 系统管理员工具| 只能由root启动  
9| 其他（Linux特定的）| 用来存放内核例行程序的文档  
n| 新文档           | 可能要移到更适合的领域  
o| 老文档           | 可能会在一段期限内保留  
l| 本地文档          | 与特定系统有关的  

<!--more-->
<br></br>

#常用参数和用法

+ 打开所有领域内的同名帮助，例如man fam，首先会进入一个fam(1M)的命令版fam帮助，再按q键就会进入FAM(3X)，库函数版的帮助。
```
$ man -a cmd
```
+ 显示所有cmd的所有手册文件的路径，如`man -aw fam`指令。
```
$ man -aw cmd
```
+ 直接指定特定领域内搜索手册页，如`man 3 fam`直接进入库函数版的帮助。
```
$ man 领域代号 cmd
```
+ 指定手册文件的搜索路径，如`man -M /home/mysql/man mysql`显示的就是你安装的mysql的帮助，而不是系统自带的旧版mysql的帮助。
```
$ man -M cmd
```
+ 把man手册信息输出到文本文件。
```
$ man cmd | col -b > cmd.txt
```
+ 查看特定语言版本的手册页，显示特定语言manpage文件的路径。
```
$ LANG=语言代号
$ man -w cmd
```

例如要查看mplayer的中文man路径：
```
$ LANG=en_US.UTF-8
$ man -w mplayer
/usr/share/man/zh/man1/mplayer.1.gz
```


#配置文件/etc/man.config

如果不想每次`man cmd`都要用`-M`指定路径，那么可以通过修改配置文件，添加内容如：

    MANPATH /home/mysql/man

man在各领域的搜索次序可以通过修改以下设置：

    MANSECT 1:8:2:3:4:5:6:7:9:tcl:n:l:p:o

不过，一般不推荐修改man的配置文件。