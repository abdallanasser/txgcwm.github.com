---
layout: post
title: "Grub Rescue修复方法"
date: 2014-07-01 23:46
comments: true
categories: [Unix/Linux]
tags: []
keywords: 
description: 
---
在笔记本电脑上安装了两个Linux系统，有一个几乎不用，所以决定把它给删除了，在网上看到[OS-Uninstaller（操作系统卸载）——轻松删除电脑中多余的操作系统](http://www.linuxidc.com/Linux/2014-06/103871.htm)一文可以操作成功，就决定试试了。本着学习的态度，边操作边作笔记，把它记录在了[这里](http://txgcwm.github.io/blog/2014/06/30/cao-zuo-xi-tong-xie-zai-ruan-jian-%3Aos-uninstaller/)。可天公并不眷恋我这个爱折腾的孩子，操作并没有成功，开机显示如下信息：
```
GRUB loading

error:unknow filesystem

grub rescue>
```

下面几种操作会导致这种问题：

- 想删除Ubuntu，于是直接在Windows下删除/格式化了Ubuntu所在的分区。
- 调整磁盘，利用工具合并/分割/调整/删除分区，使磁盘分区数目发生了变化。
- 重新安装系统，把Linux安装到了新分区，原有分区已经格式化，但是没有重新安装grub2。
- 用Ubuntu备份工具/衍生版制造工具等，把主分区恢复成了8.X的老版本，结果老版本的grub是grub1,于是把grub2破坏掉了。

总归是由于操作者不知道grub2分为两部分，一部分（一般情况下）写在了mbr上，另一部分写在了某个分区的`/boot/grub`目录（如果`/boot`单独分区，则直接写在对应分区的`/grub`目录）里面。由于上述操作，致使grub2的mbr里面的那一部分找不到`/grub`目录里面的那一部分了（或者另一部分已经删除了）。

#彻底删除grub2，让这个提示不再出现

适用于已经不想再使用Ubuntu，要转回Windows的人。只要有Windows启动盘（非Ghost），用它启动，至选择安装位置，不用真正安装，退出重启就可以。或者用它启动到故障修复台，运行fixboot或者fixmbr都可以。
win7命令行下，则是执行：
```
BootRec.exe /fixmbr
```
`/fixmbr`修复mbr，`/FixBoot`修复启动扇区，`/ScanOs`检测已安装的win7，`/RebuildBcd`重建bcd。

<!--more-->
#重新安装、修复grub2

##先使用`ls`命令，找到Ubuntu安装在哪个分区

在grub rescue>下输入以下命令：
```
ls
```
会罗列所有的磁盘分区信息，比如：
```
(hd0,1),(hd0,5),(hd0,3),(hd0,2)
```

##依次调用如下命令： X表示各个分区号码

如果`/boot`没有单独分区，用以下命令：
```
ls (hd0,X)/boot/grub
```

如果`/boot`单独分区，则用下列命令：
```
ls （hd0,X)/grub
```

正常情况下，会列出来几百个文件，很多文件的扩展名是`.mod`、`.lst`和`.img`，还有一个文件是`grub.cfg`。假设找到（hd0,5）时，显示了文件夹中的文件，则表示Linux安装在这个分区。

##如果找到了正确的grub目录，则设法临时性将grub的两部分关联起来

以下是`/boot`没有单独分区的命令：
```
grub rescue>set root=(hd0,5)
grub rescue>set prefix=(hd0,5)/boot/grub
grub rescue>insmod /boot/grub/normal.mod
```

以下是`/boot`单独分区的命令：
```
grub rescue>set root=(hd0,5)
grub rescue>set prefix=(hd0,5)/grub
grub rescue>insmod /grub/normal.mod
```

为了显示出丢失的grub菜单，需要调用如下命令：
```
grub rescue>normal
```
如果重启后问题依旧存在，则需要进入Linux中对grub进行修复。启动起来，进入Ubuntu之后，在终端执行：
```
$ sudo update-grub
$ sudo grub-install /dev/sda
```
sda是硬盘号码，千万不要指定分区号码，例如sda1，sda5等都不对。

##如果找不到正确的/grub目录，则尝试寻找是否有linux核心文件，则依次在`grub rescue>`下调用如下命令： X表示各个分区号码

如果`/boot`没有单独分区：
```
ls (hd0,X)/boot
```

如果`/boot`单独分区：
```
ls （hd0,X)
```
找名字类似`vmlinuz-3.0.0-12-generic`这样的文件，这是Linux核心文件，如果找到，记下(hd0,X)中的X值。假设找到（hd0,5）时，显示了文件夹中的文件。

然后用live cd或者live usb启动，在live cd的Ubuntu终端中依次输入以下命令（sda5中的5必须改成上面记录下来数值）：

如果`/boot`没有单独分区：
```
sudo mount /dev/sda5 /mnt
sudo grub-install --boot-directory=/mnt/boot /dev/sda
```

如果`/boot`单独分区：
```
sudo mount /dev/sda5 /mnt
sudo grub-install --boot-directory=/mnt /dev/sda
```

然后重新启动即可。

以上这两句命令也可以解决“安装Ubuntu时grub安装位置不对，没有将grub安装到/dev/sda，造成启动时不出现Ubuntu启动项直接进入Windows”的问题，不过需要自行确定sda5中的5改成什么数字。

##如果连Linux核心文件都没有，那么就得彻底重新安装

<br></br>  
找到了grub分区的目录，却找不到`normal.mod`这个文件，所以最后直接借助U盘里的Linux系统来完成修复了。面对这种状况的时候，最坏的打算就是重新安装系统了，可惜的就是那些辛辛苦苦收集的资料了。不过谁让自己瞎折腾的呢？这一切代价都需要自己去承担。不过索性有强大的网络，让我找到了解决的措施，在此感谢那些无私奉献的Linux爱好者辛勤的付出，是他们的存在才让生活更美好！

<br></br> 
<big>参考文章</big>  

[Grub Rescue修复方法](http://www.2cto.com/os/201111/112327.html)   
[grub rescue修复方法](http://blog.sina.com.cn/s/blog_4d6c45250100wxnq.html)   
[Ubuntu启动问题以及Grub Rescue修复方法](http://www.cnblogs.com/samcn/archive/2011/03/30/1999615.html)   
[Grub Rescue来修复Grub 问题](http://blog.csdn.net/jikiwh/article/details/5497900)   
[grub rescue模式下启动并修复](http://blog.csdn.net/tody_guo/article/details/7537454)   
[Ubuntu Grub Rescue几种修复方法](http://tech.ccidnet.com/art/738/20100803/2140203_1.html)   
[grub rescue修复](http://blog.csdn.net/miromelo/article/details/6132702)   
[grub rescue 模式下引导修复](http://openwares.net/linux/grub_rescue_unkown_filesystem.html)   