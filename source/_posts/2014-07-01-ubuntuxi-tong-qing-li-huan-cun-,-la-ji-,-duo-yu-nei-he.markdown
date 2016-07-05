---
layout: post
title: "Ubuntu系统清理缓存、垃圾、多余内核"
date: 2014-07-01 22:51
comments: true
categories: [Unix/Linux]
tags: []
keywords: 
description: 
---
Linux不会产生无用垃圾文件，但是在升级后它不会自动删除缓存中的文件，比较占系统硬盘资源。


#删除缓存

##清理升级缓存以及无用包的
```
$ sudo apt-get autoclean              清理旧版本的软件缓存
$ sudo apt-get clean                  清理所有软件缓存
$ sudo apt-get autoremove             删除系统不再使用的孤立软件
```

##清理opera/firefox的缓存文件
```
$ ls ~/.opera/cache4
$ ls ~/.mozilla/firefox/*.default/Cache
```

##清理Linux下孤立的包
```
$ sudo apt-get install deborphan -y
```

##卸载tracker

tracker不仅会产生大量的cache文件，而且还会影响开机速度，所以在新得立里面删掉就行。

<!--more-->
#删除软件

Ubuntu软件的删除一般用`Ubuntu软件中心`或`新得立`就能搞定，但用命令更快更好。
```
$ sudo apt-get remove --purge 软件名
$ sudo apt-get autoremove                删除系统不再使用的孤立软件
$ sudo apt-get autoclean                 清理旧版本的软件缓存
$ dpkg -l | grep ^rc | awk '{print $2}' | sudo xargs dpkg -P    清除残余的配置文件保证干净
```
包管理的临时文件目录为`/var/cache/apt/archives`,没有下载完的在`/var/cache/apt/archives/partial`。


#删除多余内核

- 查看当前Ubuntu系统使用的内核；
```
$ uname -a
```

- 查看所有内核；
```
$ dpkg --get-selections | grep linux
```

- 小心删除不需要的内核；
```
$ sudo apt-get remove linux-image-2.6.32-22-generic
```

`linux-image-xxxxxx-generic`就是要删除的内核版本，`linux-headers-xxxxxx`和`linux-headers-xxxxxx-generic`中间有`xxxxxx`那段的旧内核都能删，一般选内核号较小的删。

- 清理`/usr/src`目录，删除已经卸载的内核目录。

<br></br>
<big>参考文章</big>   

[清理Ubuntu系统的缓存、垃圾、多余内核](http://my.oschina.net/zhangqingcai/blog/23994)   
[Ubuntu清理boot分区](http://www.2cto.com/os/201304/206100.html)   