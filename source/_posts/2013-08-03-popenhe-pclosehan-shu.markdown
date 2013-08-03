---
layout: post
title: "popen和pclose函数"
date: 2013-08-03 22:07
comments: true
categories: [C/C++, Unix/Linux]
---
标准I/O函数库提供了popen函数，它启动一个子进程去执行一个shell命令行。popen函数还创建一个管道用于父子进程间通信。父进程要么从管道读信息，要么向管道写信息，至于是读还是写取决于父进程调用popen时传递的参数。以下给出popen、pclose的定义： 
```
FILE *popen( const char* command, const char* mode )
```
参数说明

command： 是一个指向以NULL结束的shell命令字符串的指针。这行命令将被传到bin/sh并使用-c标志，shell将执行这个命令。  
mode： 只能是读或者写中的一种，得到的返回值(标准I/O流)也具有和type相应的只读或只写类型。如果type是“r”则文件指针连接到command的标准输出;如果type是“w”则文件指针连接到command的标准输入。

<!--more-->

返回值

如果调用成功，则返回一个读或者写打开文件的指针；如果失败，返回NULL，具体错误要根据errno判断。


```
int pclose (FILE* stream)
```
参数说明

stream： popen返回的文件指针。

返回值

如果调用失败，返回-1。


由于平时接触到usb插拔的事情比较多，现以列举系统中usb设备vid/pid为例。本想从`/proc/bus/usb/devices`中获取到usb设备的相关信息，可Ubuntu系统下没有`/proc/bus/usb/`这个目录。至于为什么没有这个目录和如何重新找回这个目录，可以查看 [这里](http://ubuntuforums.org/showthread.php?t=1432598) 。所以这里我们使用`lsusb`去获取usb设备的基本信息。构建`int get_device_info(void)`函数获取系统中usb设备的vid/pid信息：
```
int get_device_info(void)
{
	FILE *fp = NULL;
	char buffer[128];
	char *ptr = NULL;
	int vid, pid;

	fp = popen("lsusb", "r");
	if (fp == NULL)
		return -1;

	while (NULL != fgets(buffer, sizeof(buffer), fp)) {
		ptr = strstr(buffer, "ID");
		if (ptr) {
			sscanf(ptr, "ID %04x:%04x", &vid, &pid);
			printf("%04x:%04x\n", vid, pid);
		}
	}
	pclose(fp);

	return 0;
}
```
编写主函数调用以上的接口，使用`lsusb`查看usb设备及执行测试程序：
```
$ lsusb 
Bus 001 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 002 Device 002: ID 8087:0024 Intel Corp. Integrated Rate Matching Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 003: ID 1532:0016 Razer USA, Ltd DeathAdder Mouse
Bus 001 Device 004: ID 058f:b002 Alcor Micro Corp. 

$ ./a.out 
8087:0024
8087:0024
1d6b:0002
1d6b:0002
1532:0016
058f:b002

```

<big>参考文章</big>   

[基于管道的popen和pclose函数](http://my.oschina.net/renhc/blog/35116)  
[Linux popen函数的使用总结](http://networking.ctocio.com.cn/tips/137/9412137.shtml)  
[关于/proc/iomem中信息解释](http://bbs.chinaunix.net/thread-4087539-1-1.html)    
[proc文件系统功能总览](http://tech.watchstor.com/storage-systems-117859.htm)   