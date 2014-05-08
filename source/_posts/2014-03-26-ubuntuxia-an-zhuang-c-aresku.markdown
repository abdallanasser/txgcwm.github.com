---
layout: post
title: "Ubuntu下安装c-ares库"
date: 2014-03-26 22:59
comments: true
categories: [开源库,Unix/Linux]
---

安装c-ares库的三种方法：

#源码安装

到[这里](http://c-ares.haxx.se/)下载源码，然后执行以下指令编译和安装。
```
$ cd c-ares-1.10.0
$ ./buildconf
$ autoconf configure.ac
$ ./configure
$ make
$ sudo make install
```


#第三方软件安装

在新得立搜索c-ares，然后安装相应的库。


#终端安装

```
$ sudo apt-get install libc-ares2 libc-ares-dev
```