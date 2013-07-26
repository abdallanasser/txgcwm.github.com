---
layout: post
title: "astyle格式化代码"
date: 2013-07-24 18:36
comments: true
categories: [Shell, Unix/Linux]
---
astyle是一个开源工具，它可以方便的将代码格式化成自己想要的样式而不必人工修改。可以在终端下输入指令`sudo apt-get install astyle`安装，也可以到 [这里](http://astyle.sourceforge.net/) 下载源码后自己编译安装。

下面介绍一下astyle的简单使用。例如有以下的源码：
```
#include <stdio.h>
int main(int argc, char **argv)
{int i;printf("Just a test!\n");for(i=0;i<10;++i)printf("%d\n",i);}return 0;}
```
<!--more-->

然后在终端下输入以下指令：
```
$ astyle test1.c
```
效果如下：
```
#include <stdio.h>
int main(int argc, char **argv)
{
    int i;
    printf("Just a test!\n");
    for(i=0; i<10; ++i) {
        printf("%d\n",i);
    }
    return 0;
}
```

当然也可以加上一些选项，例如“astyle --style=bsd test1.c”，“ astyle --style=gnu test1.c”等等。

在vim中的命令模式下，可以使用下面的某一种方式来格式化代码。
```
%!astyle (simple case - astyle default mode is C/C++)
```
或者
```
%!astyle --mode=c --style=ansi -s2 (ansi C++ style, use two spaces per indent level)
```
或者
```
1,40!astyle --mode=c --style=ansi (ansi C++ style, filter only lines 1-40)
```

在格式化完代码后，会生成一个后缀为orig的文件，格式化完成之后将它们删除。为方便使用，可以把它写成一个脚本，代码如下：
```
#! /bin/bash

for f in $(find . -name '*.c' -or -name '*.cpp' -or -name '*.h' -type f)
do
    astyle $f
done

# after formate the code,we need to rm '*.orig' files 
for f in $(find . -name '*.orig' -type f)
do
    rm $f
done
```
