---
layout: post
title: "操作系统卸载软件：OS-Uninstaller"
date: 2014-06-30 21:20
comments: true
categories: [Unix/Linux]
tags: []
keywords: 
description: 
---
OS-Uninstaller提供了一个图形化的界面，可以清除Windows, MacOS, Ubuntu以及其它的操作系统，可谓是强大又好用。

Ubuntu下通过添加PPA安装，打开终端输入：
```
$ sudo add-apt-repository ppa:yannubuntu/boot-repair
```

然后输入以下内容回车:
```
$ sudo sed 's/trusty/saucy/g' -i /etc/apt/sources.list.d/yannubuntu-boot-repair-trusty.list
```

执行以下命令安装:
```
$ sudo apt-get update; sudo apt-get install -y os-uninstaller && os-uninstaller
```
安装完之后，软件会自己启动。

也可以直接下载包含有OS-Uninstaller的镜像刻录使用，点击[这里](http://sourceforge.net/projects/boot-repair-cd/)下载。

<!--more-->
该软件需要安装lvm2，可以在软件中心搜索lvm安装。

启动操作系统卸载（OS-Uninstaller的中文名），打开后会看到正在扫描操作系统界面。中间可能会弹出提示`Is there RAID on this computer?`，一般选否就可以。扫描完成后软件会列出电脑上所有的操作系统，可以选定自己要卸载的操作系统，然后确定。会看到再确认窗口，下面有很多高级选项，选择默认即可，点击应用。接下来的几步很重要，请务必确认操作正确，以免造成损失。

卸载GRUB：
```
$ sudo dpkg --configure -a
$ sudo apt-get install -fy
$ sudo apt-get install -y --force-yes lvm2
$ sudo apt-get purge -y --force-yes grub*
```
执行到最后一个指令的时候，出现以下的错误（还未找到解决措施）：
```
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Note, selecting 'grub-legacy-doc' for regex 'grub*'
Note, selecting 'grub-efi-amd64-bin' for regex 'grub*'
Note, selecting 'grub-efi-amd64-dbg' for regex 'grub*'
Note, selecting 'grub-emu-dbg' for regex 'grub*'
Note, selecting 'libgruff-ruby' for regex 'grub*'
Note, selecting 'ruby-gruff' for regex 'grub*'
Note, selecting 'grub-firmware-qemu' for regex 'grub*'
Note, selecting 'grub2' for regex 'grub*'
Note, selecting 'grub-efi-ia32-bin' for regex 'grub*'
Note, selecting 'grub-efi-ia32-dbg' for regex 'grub*'
Note, selecting 'grub-theme-starfield' for regex 'grub*'
Note, selecting 'grub-efi-amd64' for regex 'grub*'
Note, selecting 'grub-disk' for regex 'grub*'
Note, selecting 'longrun' for regex 'grub*'
Note, selecting 'fgrun' for regex 'grub*'
Note, selecting 'grub2-common' for regex 'grub*'
Note, selecting 'grub-imageboot' for regex 'grub*'
Note, selecting 'libgruff-ruby1.8' for regex 'grub*'
Note, selecting 'grub-efi-ia32' for regex 'grub*'
Note, selecting 'grub-efi-ia64' for regex 'grub*'
Note, selecting 'kde-config-grub2' for regex 'grub*'
Note, selecting 'grub-pc' for regex 'grub*'
Note, selecting 'libgruel3.6.1' for regex 'grub*'
Note, selecting 'grub2-splashimages' for regex 'grub*'
Note, selecting 'grub-gfxpayload-lists' for regex 'grub*'
Note, selecting 'grub-efi-amd64-signed' for regex 'grub*'
Note, selecting 'libgruff-ruby-doc' for regex 'grub*'
Note, selecting 'espresso-grub' for regex 'grub*'
Note, selecting 'grub-ipxe' for regex 'grub*'
Note, selecting 'grub-coreboot-bin' for regex 'grub*'
Note, selecting 'grub-coreboot-dbg' for regex 'grub*'
Note, selecting 'grub-linuxbios' for regex 'grub*'
Note, selecting 'wmlongrun' for regex 'grub*'
Note, selecting 'grub-splashimages' for regex 'grub*'
Note, selecting 'grub-pc-bin' for regex 'grub*'
Note, selecting 'grub-pc-dbg' for regex 'grub*'
Note, selecting 'grub-rescue-pc' for regex 'grub*'
Note, selecting 'grub-legacy' for regex 'grub*'
Note, selecting 'grub-ieee1275' for regex 'grub*'
Note, selecting 'congruity' for regex 'grub*'
Note, selecting 'grub-ieee1275-bin' for regex 'grub*'
Note, selecting 'grub-yeeloong' for regex 'grub*'
Note, selecting 'grub' for regex 'grub*'
Note, selecting 'grub-ieee1275-dbg' for regex 'grub*'
Note, selecting 'grun' for regex 'grub*'
Note, selecting 'grub-efi' for regex 'grub*'
Note, selecting 'grub-doc' for regex 'grub*'
Note, selecting 'grub-invaders' for regex 'grub*'
Note, selecting 'grub-emu' for regex 'grub*'
Note, selecting 'grub-common' for regex 'grub*'
Note, selecting 'grub-coreboot' for regex 'grub*'
Note, selecting 'sabily-grub-artwork' for regex 'grub*'
Note, selecting 'grub-legacy-ec2' for regex 'grub*'
Package 'grub-efi-ia64' is not installed, so not removed
Package 'grub-yeeloong' is not installed, so not removed
Package 'grub-legacy' is not installed, so not removed
Package 'espresso-grub' is not installed, so not removed
Package 'grub-efi-amd64-signed' is not installed, so not removed
Package 'grub' is not installed, so not removed
Package 'grub-common' is not installed, so not removed
Package 'grub-doc' is not installed, so not removed
Package 'grub-efi' is not installed, so not removed
Package 'grub-efi-amd64' is not installed, so not removed
Package 'grub-efi-amd64-bin' is not installed, so not removed
Package 'grub-efi-amd64-dbg' is not installed, so not removed
Package 'grub-efi-ia32' is not installed, so not removed
Package 'grub-efi-ia32-bin' is not installed, so not removed
Package 'grub-efi-ia32-dbg' is not installed, so not removed
Package 'grub-gfxpayload-lists' is not installed, so not removed
Package 'grub-legacy-doc' is not installed, so not removed
Package 'grub-pc-bin' is not installed, so not removed
Package 'grub-pc-dbg' is not installed, so not removed
Package 'grub2-common' is not installed, so not removed
Package 'congruity' is not installed, so not removed
Package 'fgrun' is not installed, so not removed
Package 'grub-coreboot' is not installed, so not removed
Package 'grub-coreboot-bin' is not installed, so not removed
Package 'grub-coreboot-dbg' is not installed, so not removed
Package 'grub-disk' is not installed, so not removed
Package 'grub-emu' is not installed, so not removed
Package 'grub-emu-dbg' is not installed, so not removed
Package 'grub-firmware-qemu' is not installed, so not removed
Package 'grub-ieee1275' is not installed, so not removed
Package 'grub-ieee1275-bin' is not installed, so not removed
Package 'grub-ieee1275-dbg' is not installed, so not removed
Package 'grub-imageboot' is not installed, so not removed
Package 'grub-invaders' is not installed, so not removed
Package 'grub-ipxe' is not installed, so not removed
Package 'grub-linuxbios' is not installed, so not removed
Package 'grub-rescue-pc' is not installed, so not removed
Package 'grub-splashimages' is not installed, so not removed
Package 'grub-theme-starfield' is not installed, so not removed
Package 'grub2' is not installed, so not removed
Package 'grub2-splashimages' is not installed, so not removed
Package 'grun' is not installed, so not removed
Package 'kde-config-grub2' is not installed, so not removed
Package 'libgruel3.6.1' is not installed, so not removed
Package 'libgruff-ruby' is not installed, so not removed
Package 'libgruff-ruby-doc' is not installed, so not removed
Package 'libgruff-ruby1.8' is not installed, so not removed
Package 'longrun' is not installed, so not removed
Package 'ruby-gruff' is not installed, so not removed
Package 'sabily-grub-artwork' is not installed, so not removed
Package 'wmlongrun' is not installed, so not removed
Package 'grub-legacy-ec2' is not installed, so not removed
The following packages will be REMOVED:
  grub-pc*
0 upgraded, 0 newly installed, 1 to remove and 2 not upgraded.
After this operation, 558 kB disk space will be freed.
(Reading database ... 1115878 files and directories currently installed.)
Removing grub-pc ...
dpkg: error processing grub-pc (--purge):
 subprocess installed pre-removal script returned error exit status 10
No apport report written because MaxReports is reached already
                                                              Errors were encountered while processing:
 grub-pc
E: Sub-process /usr/bin/dpkg returned an error code (1)
```
如果出现选择窗口，可使用Tab键、空格键和回车键以将GRUB安装至希望的磁盘上。

重装GRUB，按照说明操作（空格可以选定安装位置，tab键切换选项，回车确认操作），按前进继续下一步：
```
$ sudo apt-get install -y --force-yes grub-pc
```

至此，已经完成了所有的操作，剩下来的工作就是软件自动删除要删除的系统，成功后会出现提示信息。卸载完成后重启电脑，确实完全删除。


<big>参考文章</big>   

[OS-Uninstaller（操作系统卸载）——轻松删除电脑中多余的操作系统](http://www.linuxidc.com/Linux/2014-06/103871.htm)   