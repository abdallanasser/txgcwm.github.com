---
layout: post
title: "pkg-config的使用"
date: 2013-07-14 11:22
comments: true
categories: [Shell, Unix/Linux]
---
pkg-config是向用户和应用程序提供相应库的路径、版本号等信息的程序。比如使用pkg-config查看gcc的CFLAGS参数。
```
$ pkg-config --libs --cflags opencv
-I/usr/include/opencv  -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_ml 
-lopencv_video -lopencv_features2d -lopencv_calib3d -lopencv_objdetect 
-lopencv_contrib -lopencv_legacy -lopencv_flann
```
以上就是我们用gcc编译连接时CFLAGS的参数。因此当我们需要编译连接某个库时，只需要把上面那行加入gcc的参数里面即可。这也是configure的作用，它会检查你需要的包，产生相应的信息。

pkg-config从包名为xxx.pc这个文件中查找相应的信息。缺省情况下，首先在prefix/lib/pkgconfig/（在linux上其路径为/usr/lib/pkconfig/）中查找相关包（比如opencv）对应的文件（opencv.pc）。若是没有找到，它也会到PKG_CONFIG_PATH这个环境变量所指定的路径下去找。若是还没有找到，它就会报错，例如：
```
Package opencv was not found in the pkg-config search path.
Perhaps you should add the directory containing `opencv.pc'
to the PKG_CONFIG_PATH environment variable
No package 'opencv' found
```
<!--more-->

设置环境变量PKG_CONFIG_PATH方法如下：
```
export PKG_CONFIG_PATH=/cv/lib:$PKG_CONFIG_PATH
```

查看opencv.pc文件的内容如下：
```
$ cat opencv.pc 
# Package Information for pkg-config

prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir_old=${prefix}/include/opencv
includedir_new=${prefix}/include

Name: OpenCV
Description: Open Source Computer Vision Library
Version: 2.3.1
Libs: -L${libdir} -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_ml 
-lopencv_video -lopencv_features2d -lopencv_calib3d -lopencv_objdetect -lopencv_contrib 
-lopencv_legacy -lopencv_flann
Cflags: -I${includedir_old} -I${includedir_new}
```
