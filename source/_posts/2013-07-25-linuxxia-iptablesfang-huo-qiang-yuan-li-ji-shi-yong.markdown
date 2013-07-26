---
layout: post
title: "Linux下iptables防火墙原理及使用"
date: 2013-07-25 23:36
comments: true
categories: [路由器/防火墙, Unix/Linux]
---
netfilter/iptables（简称为iptables）组成Linux平台下的包过滤防火墙，与大多数的Linux软件一样，这个包过滤防火墙是免费的，它可以代替昂贵的商业防火墙解决方案，完成封包过滤、封包重定向和网络地址转换（NAT）等功能。iptables和netfilter的关系是一个很容易让人搞不清的问题：很多人知道iptables却不知道netfilter，其实iptables（位于/sbin目录下）只是Linux防火墙的管理工具而已，真正实现防火墙功能的是netfilter（它是Linux内核中实现包过滤的内部结构）。


#iptables传输数据包的过程
  
![ flow ](/images/2013/7/iptables/flow.png)

<!--more-->

1. 当一个数据包进入网卡时，它首先进入PREROUTING链，内核根据数据包目的ip地址判断是否需要转送出去。 
2. 如果数据包就是进入本机的，它就会沿着上图所指方向向下移动，到达INPUT链。数据包到了INPUT链后，任何进程都会收到它。本机上运行的程序可以发送数据包，这些数据包会经过OUTPUT链，然后到达POSTROUTING链输出。 
3. 如果数据包是要转发出去的，且内核允许转发，数据包就会如图所示向右移动，经过FORWARD链，然后到达POSTROUTING链输出。



#规则表和规则链

iptables采用“表”和“链”的分层结构。表（tables）提供特定的功能，iptables内置了4个表，即Filter表、Nat表、Mangle表和Raw表，分别用于实现包过滤、网络地址转换、包重构(修改)和数据跟踪处理。链（chains）是数据包传播的路径，每一条链其实就是众多规则中的一个检查清单，每一条链中可以有一条或数条规则。当一个数据包到达一个链时，iptables就会从链中第一条规则开始检查，看该数据包是否满足规则所定义的条件。如果满足，系统就会根据该条规则所定义的方法处理该数据包，否则iptables将继续检查下一条规则。如果该数据包不符合链中任一条规则，iptables就会根据该链预先定义的默认策略来处理数据包。

![ table ](/images/2013/7/iptables/table.png)

##规则表

iptables有4个规则表，其之间的优先顺序为Raw---Mangle---Nat---Filter。

1. Filter表有三个链：INPUT、FORWARD、OUTPUT

    作用：过滤数据包  
    内核模块：iptables_filter

2. Nat表有三个链：PREROUTING、POSTROUTING、OUTPUT

    作用：用于网络地址转换（IP、端口）   
    内核模块：iptable_nat

3. Mangle表有五个链：PREROUTING、POSTROUTING、INPUT、OUTPUT、FORWARD

    作用：修改数据包的服务类型、TTL、并且可以配置路由实现QOS     
    内核模块：iptable_mangle

4. Raw表有两个链：OUTPUT、PREROUTING

    作用：决定数据包是否被状态跟踪机制处理  
    内核模块：iptable_raw


##规则链

1. INPUT——进来的数据包应用此规则链中的策略。
2. OUTPUT——外出的数据包应用此规则链中的策略。
3. FORWARD——转发数据包时应用此规则链中的策略。
4. PREROUTING——对数据包作路由选择前应用此链中的规则，所有的数据包进来的时侯都先由这个链处理。
5. POSTROUTING——对数据包作路由选择后应用此链中的规则，所有的数据包出来的时侯都先由这个链处理。


规则链之间的优先顺序分三种情况：

1. 入站数据流向

    从外界到达防火墙的数据包，先被PREROUTING规则链处理（是否修改数据包地址等），之后会进行路由选择（判断该数据包应该发往何处），如果数据包的目标主机是防火墙本机（比如说Internet用户访问防火墙主机中的web服务器的数据包），那么内核将其传给INPUT链进行处理（决定是否允许通过等），通过以后再交给系统上层的应用程序（比如Apache服务器）进行响应。

2. 转发数据流向

    来自外界的数据包到达防火墙后，首先被PREROUTING规则链处理，之后会进行路由选择，如果数据包的目标地址是其它外部地址（比如局域网用户通过网关访问QQ站点的数据包），则内核将其传递给FORWARD链进行处理（是否转发或拦截），然后再交给POSTROUTING规则链（是否修改数据包的地址等）进行处理。

3. 出站数据流向

    防火墙本机向外部地址发送的数据包（比如在防火墙主机中测试公网DNS服务器时），首先被OUTPUT规则链处理，之后进行路由选择，然后传递给POSTROUTING规则链（是否修改数据包的地址等）进行处理。



#管理和设置iptables规则

规则（rules）其实就是网络管理员预定义的条件，规则一般的定义为“如果数据包头符合这样的条件，就这样处理这个数据包”。规则存储在内核空间的信息包过滤表中，这些规则分别指定了源地址、目的地址、传输协议（如TCP、UDP、ICMP）和服务类型（如HTTP、FTP和SMTP）等。当数据包与规则匹配时，iptables就根据规则所定义的方法来处理这些数据包，如放行（accept）、拒绝（reject）和丢弃（drop）等。配置防火墙的主要工作就是添加、修改和删除这些规则。

![ cmd ](/images/2013/7/iptables/cmd.png)

![ filter ](/images/2013/7/iptables/filter.png)


##iptables的基本语法格式

iptables [-t 表名] 命令选项 ［链名］ ［条件匹配］ ［-j 目标动作或跳转］

说明：表名、链名用于指定iptables命令所操作的表和链，命令选项用于指定管理iptables规则的方式（比如插入、增加、删除、查看等）；条件匹配用于指定对符合什么样条件的数据包进行处理；目标动作或跳转用于指定数据包的处理方式（比如允许通过、拒绝、丢弃、跳转给其它链处理）。


iptables命令的管理控制选项：
```
-A 在指定链的末尾添加（append）一条新的规则 
-D 删除（delete）指定链中的某一条规则，可以按规则序号和内容删除 
-I 在指定链中插入（insert）一条新的规则，默认在第一行添加 
-R 修改、替换（replace）指定链中的某一条规则，可以按规则序号和内容替换 
-L 列出（list）指定链中所有的规则进行查看
-E 重命名用户定义的链，不改变链本身 
-F 清空（flush） 
-N 新建（new-chain）一条用户自己定义的规则链 
-X 删除指定表中用户自定义的规则链（delete-chain） 
-P 设置指定链的默认策略（policy）
-Z 将所有表的所有链的字节和数据包计数器清零 
-n 使用数字形式（numeric）显示输出结果 
-v 查看规则表详细信息（verbose）的信息 
-V 查看版本(version) 
-h 获取帮助（help）
```

##防火墙处理数据包的四种方式

1. ACCEPT：允许数据包通过。
2. DROP：直接丢弃数据包，不给任何回应信息
3. REJECT：拒绝数据包通过，必要时会给数据发送端一个响应的信息。
4. LOG：在/var/log/messages文件中记录日志信息，然后将数据包传递给下一条规则。

 
##防火墙规则的保存与恢复

iptables-save把规则保存到文件中（生成保存规则的文件名为/etc/sysconfig/iptables），再由rc.d目录下的脚本（/etc/rc.d/init.d/iptables）自动装载。使用`iptables-save > /etc/sysconfig/iptables`命令来保存规则，也可以用`service iptables save`指令把规则自动保存起来。当计算机启动时，rc.d下的脚本将用命令`iptables-restore`调用这个文件，从而就自动恢复了规则。


##防火墙常用策略


+ 拒绝进入防火墙的所有ICMP协议数据包
```
    $ iptables -I INPUT -p icmp -j REJECT
```


+ 允许防火墙转发除ICMP协议以外的所有数据包，使用“！”可以将条件取反。
```
    $ iptables -A FORWARD -p ! icmp -j ACCEPT
```


+ 拒绝转发来自192.168.1.10主机的数据，允许转发来自192.168.0.0/24网段的数据。要把拒绝的放在前面，不然就不起作用了。
```
    $ iptables -A FORWARD -s 192.168.1.11 -j REJECT
    $ iptables -A FORWARD -s 192.168.0.0/24 -j ACCEPT
```


+ 丢弃从外网接口（eth1）进入防火墙本机的源地址为私网地址的数据包。
```
    $ iptables -A INPUT -i eth1 -s 192.168.0.0/16 -j DROP
    $ iptables -A INPUT -i eth1 -s 172.16.0.0/12 -j DROP
    $ iptables -A INPUT -i eth1 -s 10.0.0.0/8 -j DROP
```

+ 封堵网段（192.168.1.0/24），两小时后解封。这个策略可以借助crond计划任务来完成。
```
    $ iptables -I INPUT -s 10.20.30.0/24 -j DROP
    $ iptables -I FORWARD -s 10.20.30.0/24 -j DROP
    $ at now 2 hours at> iptables -D INPUT 1 at> iptables -D FORWARD 1

    [1]   Stopped     at now 2 hours
```

+ 只允许管理员从202.13.0.0/16网段使用SSH远程登录防火墙主机。比较适合对设备进行远程管理时使用，比如位于分公司中的SQL服务器需要被总公司的管理员管理时。
```
    $ iptables -A INPUT -p tcp --dport 22 -s 202.13.0.0/16 -j ACCEPT
    $ iptables -A INPUT -p tcp --dport 22 -j DROP
```


+ 允许本机开放从TCP端口20-1024提供的应用服务。
```
    $ iptables -A INPUT -p tcp --dport 20:1024 -j ACCEPT
    $ iptables -A OUTPUT -p tcp --sport 20:1024 -j ACCEPT
```
 
+ 允许转发来自192.168.0.0/24局域网段的DNS解析请求数据包。
```
    $ iptables -A FORWARD -s 192.168.0.0/24 -p udp --dport 53 -j ACCEPT
    $ iptables -A FORWARD -d 192.168.0.0/24 -p udp --sport 53 -j ACCEPT
```
 
+ 禁止其他主机ping防火墙主机，但是允许从防火墙上ping其他主机
```
    $ iptables -I INPUT -p icmp --icmp-type Echo-Request -j DROP
    $ iptables -I INPUT -p icmp --icmp-type Echo-Reply -j ACCEPT
    $ iptables -I INPUT -p icmp --icmp-type destination-Unreachable -j ACCEPT
```

+ 禁止转发来自MAC地址为00：0C：29：27：55：3F的主机的数据包。iptables中使用“-m 模块关键字”的形式调用显示匹配。这里用“-m mac --mac-source”来表示数据包的源MAC地址。
```
    $ iptables -A FORWARD -m mac --mac-source 00:0c:29:27:55:3F -j DROP
```
 

+ 允许防火墙本机对外开放TCP端口20、21、25、110以及被动模式FTP端口1250-1280，这里用“-m multiport --dport”来指定目的端口及范围。
```
    $ iptables -A INPUT -p tcp -m multiport --dport 20,21,25,110,1250:1280 -j ACCEPT
```
  

+ 禁止转发源IP地址为192.168.1.20-192.168.1.99的TCP数据包。此处用“-m iprange --src-range”指定IP范围。
```
    $ iptables -A FORWARD -p tcp -m iprange --src-range 192.168.1.20-192.168.1.99 -j DROP
```
  

+ 禁止转发与正常TCP连接无关的非--syn请求数据包。“-m state”表示数据包的连接状态，“NEW”表示与任何连接无关。
```
    $ iptables -A FORWARD -m state --state NEW -p tcp ! --syn -j DROP
```
  

+ 拒绝访问防火墙的新数据包，但允许响应连接或与已有连接相关的数据包。“ESTABLISHED”表示已经响应请求或者已经建立连接的数据包，“RELATED”表示与已建立的连接有相关性的，比如FTP数据连接等。
```
    $ iptables -A INPUT -p tcp -m state --state NEW -j DROP
    $ iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
```
  

+ 只开放本机的web服务（80）、FTP(20、21、20450-20480)，放行外部主机发住服务器其它端口的应答数据包，将其他入站数据包均予以丢弃处理。
```
    $ iptables -I INPUT -p tcp -m multiport --dport 20,21,80 -j ACCEPT
    $ iptables -I INPUT -p tcp --dport 20450:20480 -j ACCEPT
    $ iptables -I INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
    $ iptables -P INPUT DROP
```

#参考文章

+ [netfilter](http://netfilter.org/)
+ [Iptables 指南 1.1.19](http://man.chinaunix.net/network/iptables-tutorial-cn-1.1.19.html)　
+ [iptable 笔记](http://blog.csdn.net/thmono/archive/2010/04/08/5462043.aspx)
+ [网络安全频道](http://netsecurity.51cto.com/art/200512/14457.htm)
+ [iptables_2](http://blog.sina.com.cn/s/blog_40ba724c0100jz12.html)
+ [netfilter/iptables全攻略](http://qiliuping.blog.163.com/blog/static/1023829320105245337799/)