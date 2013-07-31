---
layout: post
title: "Linux的硬链接与软链接"
date: 2013-07-29 23:37
comments: true
categories: [Unix/Linux, Shell]
---
文件有文件名与数据，这在Linux上被分成两个部分：用户数据(user data)与元数据(metadata)。用户数据，即文件数据块 (data block)，数据块是记录文件真实内容的地方；而元数据则是文件的附加属性，如文件大小、创建时间、所有者等信息。在Linux中，元数据中的inode号（inode是文件元数据的一部分但其并不包含文件名，inode号即索引节点号）才是文件的唯一标识而非文件名。文件名仅是为了方便人们的记忆和使用，系统或程序通过inode号寻找正确的文件数据块。下图展示了程序通过文件名获取文件内容的过程。

![ file ](/images/2013/7/link/file.png)

为解决文件的共享使用，Linux系统引入了两种链接：硬链接(hard link)与软链接（又称符号链接，即soft link或symbolic link）。链接为Linux系统解决了文件的共享使用，还带来了隐藏文件路径、增加权限安全及节省存储等好处。若一个inode号对应多个文件名，则称这些文件为硬链接。换言之，硬链接就是同一个文件使用了多个别名。

![ access ](/images/2013/7/link/access.png)

<!--more-->

#硬链接

硬链接可由命令link或ln创建。如下是对文件oldfile创建硬链接。
```
link oldfile newfile 
ln oldfile newfile 
```
由于硬链接是有着相同inode号仅文件名不同的文件，因此硬链接存在以下几点特性：

+ 文件有相同的inode及data block；
+ 只能对已存在的文件进行创建；
+ 不能交叉文件系统进行硬链接的创建；
+ 不能对目录进行创建，只可对文件创建；
+ 删除一个硬链接文件并不影响其它有相同inode号的文件。
```
$ ls -li
total 0

// 只能对已存在的文件创建硬连接
$ link old.file hard.link
link: cannot create link `hard.link' to `old.file': No such file or directory

$ echo "This is an original file" > old.file
$ cat old.file
This is an original file
$ stat old.file
  File: `old.file'
  Size: 25        	Blocks: 8          IO Block: 4096   regular file
Device: 807h/2055d	Inode: 796901      Links: 1
Access: (0664/-rw-rw-r--)  Uid: ( 1000/  txgcwm)   Gid: ( 1000/  txgcwm)
Access: 2013-07-29 23:57:49.435157205 +0800
Modify: 2013-07-29 23:57:27.295157688 +0800
Change: 2013-07-29 23:57:27.295157688 +0800
 Birth: -
 
// 文件有相同的inode号以及data block
$ link old.file hard.link | ls -li
total 8
796901 -rw-rw-r-- 2 txgcwm txgcwm 25 Jul 29 23:57 hard.link
796901 -rw-rw-r-- 2 txgcwm txgcwm 25 Jul 29 23:57 old.file

// 不能交叉文件系统
$ sudo ln /dev/input/event5 /root/bfile.txt
[sudo] password for txgcwm: 
ln: failed to create hard link `/root/bfile.txt' => `/dev/input/event5': Invalid cross-device link

// 不能对目录进行创建硬连接
$ mkdir -p old.dir/test
$ ln old.dir/ hardlink.dir
ln: `old.dir/': hard link not allowed for directory
```
文件old.file与hard.link有着相同的inode号（796901）及文件权限，inode是随着文件的存在而存在，因此只有当文件存在时才可创建硬链接，即当inode存在且链接计数器（link count）不为0时。inode号仅在各文件系统下是唯一的，当Linux挂载多个文件系统后将出现inode号重复的现象，因此硬链接创建时不可跨文件系统。设备文件目录/dev使用的文件系统是devtmpfs，而/home（与根目录/一致）使用的是磁盘文件系统ext4。以下使用命令df查看当前系统中挂载的文件系统类型、各文件系统inode使用情况及文件系统挂载点。
```
$ sudo df -i --print-type
Filesystem     Type      Inodes  IUsed   IFree IUse% Mounted on
/dev/sda5      ext4     1250928  63404 1187524    6% /
udev           devtmpfs  211313    603  210710    1% /dev
tmpfs          tmpfs     215180    566  214614    1% /run
none           tmpfs     215180      3  215177    1% /run/lock
none           tmpfs     215180      9  215171    1% /run/shm
none           tmpfs     215180     23  215157    1% /run/user
/dev/sda6      ext4       62464    355   62109    1% /boot
/dev/sda7      ext4     1250928  91579 1159349    8% /home
/dev/sda11     ext4     2501856 336584 2165272   14% /srv
/dev/sda12     ext4     1875968 144226 1731742    8% /opt
/dev/sda8      ext4      249984    132  249852    1% /tmp
/dev/sda9      ext4     1250928 584616  666312   47% /usr
/dev/sda10     ext4      249984  24565  225419   10% /var

$ sudo find / -inum 1114
/lib/modules/3.5.0-25-generic/kernel/drivers/hwmon/mcp3021.ko
/sys/devices/LNXSYSTM:00/device:00/PNP0A08:00/device:02/PNP0C02:00/power/autosuspend_delay_ms
```
值得一提的是，Linux系统存在inode号被用完但磁盘空间还有剩余的情况。硬链接不能对目录创建是受限于文件系统的设计。现Linux文件系统中的目录均隐藏了两个特殊的目录：当前目录（.）与父目录（..）。查看这两个特殊目录的inode号可知其实这两目录就是两个硬链接（注意目录/lost+found/的inode号）。若系统允许对目录创建硬链接，则会产生目录环。
```
$ sudo ls -aliF /lost+found
total 20
11 drwx------  2 root root 16384 Nov 11  2012 ./
 2 drwxr-xr-x 23 root root  4096 Jul  7 13:47 ../
 
$ sudo stat /lost+found/
  File: `/lost+found/'
  Size: 16384     	Blocks: 32         IO Block: 4096   directory
Device: 805h/2053d	Inode: 11          Links: 2
Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2013-07-30 00:10:47.479140197 +0800
Modify: 2012-11-11 00:50:27.000000000 +0800
Change: 2012-11-11 00:50:27.000000000 +0800
 Birth: -
```

#软链接

软链接与硬链接不同，若文件用户数据块中存放的内容是另一文件的路径名的指向，则该文件就是软连接。软链接就是一个普通文件，只是数据块内容有点特殊。软链接有着自己的inode号以及用户数据块。因此软链接的创建与使用没有类似硬链接的诸多限制：

+ 软链接有自己的文件属性及权限等；
+ 可对不存在的文件或目录创建软链接；
+ 软链接可交叉文件系统；
+ 软链接可对文件或目录创建；
+ 创建软链接时，链接计数 i_nlink 不会增加；
+ 删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（即 dangling link，若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。
```
$ ls -li
total 0

// 可对不存在的文件创建软链接
$ ln -s old.file soft.link
$ ls -liF
total 0
796810 lrwxrwxrwx 1 txgcwm txgcwm 8 Jul 30 00:25 soft.link -> old.file

// 由于被指向的文件不存在，此时的软链接 soft.link 就是死链接
$ cat soft.link
cat: soft.link: No such file or directory

// 创建被指向的文件 old.file，soft.link 恢复成正常的软链接
$ echo "This is an original file_A" >> old.file
$ cat soft.link
This is an original file_A

// 对不存在的目录创建软链接
$ ln -s old.dir soft.link.dir
$ mkdir -p old.dir/test
$ tree . -F --inodes
.
├── [ 796834]  old.dir/
│   └── [ 796851]  test/
├── [ 796830]  old.file
├── [ 796830]  soft.link -> old.file
└── [ 796834]  soft.link.dir -> old.dir/

3 directories, 2 files
```

#参考文章
[理解Linux的硬链接与软链接](http://www.ibm.com/developerworks/cn/linux/l-cn-hardandsymb-links/)