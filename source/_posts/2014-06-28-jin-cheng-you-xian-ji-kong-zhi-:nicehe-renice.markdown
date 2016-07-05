---
layout: post
title: "进程优先级控制：nice和renice"
date: 2014-06-28 14:41
comments: true
categories: [Shell]
tags: []
keywords: 
description: 
---
Linux进程调度的目标：

1. 高效性：高效意味着在相同的时间下要完成更多的任务，调度程序会被频繁的执行，所以调度程序要尽可能的高效；
2. 加强交互性能：在系统相当的负载下，也要保证系统的响应时间；
3. 保证公平和避免饥渴；
4. SMP调度：调度程序必须支持多处理系统；
5. 软实时调度：系统必须有效的调用实时进程，但不保证一定满足其要求。

Linux给予进程一个优先运行序 (priority, PRI)， 这个PRI值越低代表优先级越高。不过这个PRI值是由核心动态调整的，使用者无法直接调整PRI值。

由于PRI是核心动态调整的，使用者无权去干涉。如果想要调整进程的优先运行序，就要透过Nice值了。一般来说， PRI与NI的相关性如下：
```
PRI(new) = PRI(old) + nice
```

<!--more-->
不过要特别留意，如果原本的PRI是50，并不是给予一个`nice = 5`，就会让PRI变成55，因为PRI是系统动态决定的。所以，虽然nice值可以影响PRI，不过最终的PRI仍是要经过系统分析后才会决定。另外，nice值是有正负的，而既然PRI越小越早被运行，所以当nice值为负值时，那么该进程就会降低PRI值，亦即会被优先处理。此外，必须要留意到：

- nice值可调整的范围为-20 ~ 19；
- root可随意调整自己或他人进程的Nice值，且范围为-20 ~ 19；
- 一般使用者仅可调整自己进程的Nice值，且范围仅为0 ~ 19(避免一般用户抢占系统资源)；
- 一般使用者仅可将nice值越调越高，例如本来nice为5，则未来仅能调整到大于5；
- 一开始运行程序就立即给予一个特定的nice值，用nice命令，例如`nice -n 10 ping www.163.com`；
- 调整某个已经存在的PID的nice值，用renice命令，例如`renice 19 2251`或者`renice 19 3675 4103`（同时调整多个进程的优先级）;
- 针对指定用户，把这些用户的进程优先级全部做调整，例如`sudo renice 1 -u test`或者`sudo renice -2 -u test mysql root`（调整多个用户的进程优先级）；
- 优先级会继承，例如当前bash的优先级是81，nice为1，在bash下产生的所有子进程都会继续父进程的优先级。

<br></br>
<big>参考文章</big>  

[Linux进程调度原理](http://www.cnblogs.com/zhaoyl/archive/2012/09/04/2671156.html)  
[进程优先级控制——nice和renice命令](http://linzhibin824.blog.163.com/blog/static/7355771020135801151813/)   
[进程优先级，进程nice值和%nice的解释](http://blog.csdn.net/ganglia/article/details/11028199)   
[linux中限制用户进程CPU和内存占用率](http://blog.sina.com.cn/s/blog_53689eaf0101b5xd.html)  
[使用shell脚本对Linux系统和进程资源进行监控](http://www.ibm.com/developerworks/cn/linux/l-cn-shell-monitoring/)