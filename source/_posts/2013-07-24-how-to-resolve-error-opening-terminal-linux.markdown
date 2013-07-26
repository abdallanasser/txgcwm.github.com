---
layout: post
title: How to resolve "error opening terminal Linux"
date: 2013-07-24 18:33
comments: true
categories: [嵌入式开发, Unix/Linux]
---
Linux环境下，编译嵌入式系统时会用到`make menuconfig`或`make config`命令，这些命令通常会使用ncurses库，如果ncurses库没有安装设置正确，可能出现如下的错误信息：
```
error opening terminal Linux
error opening terminal xterm
error opening terminal vt100
error opening terminal vt102
error opening terminal unknown
error opening terminal cgywin
...
```
<!--more-->

可以按照以下两步解决问题：

1. 首先要确定ncurses库是否已经正确安装。在Debian或Ubuntu上，可以用`dpkg -l | grep ncurses`查看ncurses库是否已安装。
2. 如果ncurses已经安装了，需要查看TERM和TERMINFO两个环境变量是否已经设置正确。如果没有设置正确，需要设置为正确的值。
```
    $ echo $TERM
    $ echo $TERMINFO
```

关于TERMINFO, 应设置为terminfo的路径，比如/usr/share/terminfo或者/lib/terminfo。查看terminfo的存储位置用以下指令：
```
$ whereis terminfo
terminfo: /etc/terminfo /lib/terminfo /usr/share/terminfo /usr/share/man/man5/terminfo.5.gz
```

查看terminfo目录下是否保存了终端信息文件：其中通常分为a, b, c, d...z这些字母目录，每个目录中包含了以该字母开头的term信息。比如vt100放在"v"目录中。我们需要的term必须在对应的目录中存在term信息。确定这些信息后，就可以设置TERM和TERMINFO信息：
```
$ export TERM=vt100
$ export TERMINFO=/usr/share/terminfo
```

上面的设置必须保证/usr/share/terminfo中存在term信息，且/usr/share/terminfo/v/vt100是存在的。关于TERM的设置，有可能需要设置成Linux，vt100-putty等不同的TERM。Linux通常用于Linux控制台，vt100-putty顾名思义是使用putty远程登录的vt100终端。

以下是在Ubuntu12.10环境下，解决了此问题后TERM和TERMINFO两个环境变量的值。
```
$ echo $TERM
xterm
$ echo $TERMINFO
/lib/terminfo/
```