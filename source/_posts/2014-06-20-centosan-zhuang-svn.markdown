---
layout: post
title: "CentOS安装SVN"
date: 2014-06-20 22:07
comments: true
categories: [Unix/Linux]
tags: []
keywords: 
description: 
---
#安装ssh服务器和subversion服务器

```
# yum update      
# yum install openssh-server     
# yum install subversion      
```


#创建登陆svn的用户

```
# useradd test // 添加test用户     
# groupadd svn // 添加svn用户组     
# usermod -a -G svn test // 将test用户添加到svn用户组   
```
另外，如果test用户不存在，则可以用以下语句完成：

```
# useradd -g svn test     
```


#建立用户存储

``` 
# mkdir -p /home/test/svn/trunk        
# svnadmin create /home/test/svn/trunk      
```


#为svn用户组赋予权限

```
# chown -R root:svn /home/test/svn/trunk      
# chmod -R g+rws /home/test/svn/trunk    /*给svn组赋予读写权限，可以根据需要更改相应权限*/     
# chmod -R o-rwx /home/test/svn/trunk    /*删除其他无关人员的读、写、执行权限，默认情况下可能其他人有读权限*/       
```

<!--more-->
#为成员生成密钥 

生成密钥对：
```
# ssh-keygen -b 1024 -t rsa -N passwd -f testkey    
```
其中，passwd为密钥关键字（相当于密码），由用户自定义；testkey为密钥文件名，生成之后会产生两个文件（testkey和testkey.pub，前者为密钥，后者为公钥）；rsa指定使用rsa进行加密，如果改成dsa，则使用dsa加密。

创建/home/test/.ssh目录，拷贝公钥并重命名成authorized_keys：
```
# cp testkey.pub /home/test/.ssh/authorized_keys     
```
注意：文件名称必须为authorized_keys。


#更改资源访问权限

修改/home/test/svn/trunk/conf/svnserve.conf文件，在general中加入以下几行：

```
[general]    

anon-access = none // 未认证的用户没有任何访问权限     
auth-access = write // 认证的用户有写权限          
authz-db = authz // 认证文件为conf目录下的authz文件      
```

修改/home/test/svn/trunk/conf/authz文件（如果没有则创建），在其中加入：

```
[/]       // 访问权限为本资源的根目录以及以下目录      
test = rw // test用户的访问权限为“读+写”      
```
还可以采用以下方法进行认证：

```
[groups]      
svn = test,sam // 定义用户组svn包含两个用户：test和sam     
      
[/]     
@svn = rw // svn用户组的成员访问权限为“读+写”      
```

#启动svnserve
```
# svnserve -d -r /home/test/svn/
```

<br></br>
<big>参考文章</big>  

[CentOS中安装subversion，并使用svn+ssh访问](http://blog.csdn.net/wangjingfei/article/details/5424338)  
[linux（centos）搭建SVN服务器](http://blog.163.com/longsu2010@yeah/blog/static/173612348201202114212933/)  
[CentOS Linux搭建SVN Server配置详解](http://zhumeng8337797.blog.163.com/blog/static/100768914201292641420400/)  
[CentOS Linux下配置svn HTTP server](http://www.cnblogs.com/ayanmw/archive/2011/12/19/2294054.html)  
[svn: E170001 : Authorization failed](http://stackoverflow.com/search?q=svn%3A+E170001+%3A+Authorization+failed)  
[解决svn Authorization failed错误](http://blog.sina.com.cn/s/blog_4b93170a0100leb2.html)  
[ubuntu下架设svn服务器及在windows建立svn+ssh客户端](http://blog.csdn.net/laverock/article/details/2195290)  
[svn登陆时它出现：Authorization failed](http://bbs.csdn.net/topics/310115750)  
[Howto: Linux Add User To Group](http://www.cyberciti.biz/faq/howto-linux-add-user-to-group/)  
