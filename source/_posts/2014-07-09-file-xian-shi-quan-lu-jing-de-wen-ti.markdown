---
layout: post
title: "__FILE__显示全路径的问题"
date: 2014-07-09 22:12
comments: true
categories: [C/C++]
tags: []
keywords: 
description: 
---
在日志中，使用到`__FILE__`来显示源码的文件名，可它显示了绝对路径，这样使得整个log看起来很长，主要log都显示在了右边，让人看着很是不舒服。查找了半天才知道这是编译造成的，由于编译目录和源码目录不同，所以在实际编译的时候使用的是源码的绝对路径，以致打印出来就是绝对路径了（这样的解释不是很准确，有待改进）。

针对这种现象，使用以下的例子作为测试。

```
#include <stdio.h>

int main(int argc, char **argv)
{
	printf("%s, %d\n", __FILE__, __LINE__);

	return 0;
}
```

使用源码的全路径编译：
```
$ gcc -o filetest /srv/example/c/test/filetest.c
```

执行结果：
```
$ ./filetest 
/srv/example/c/test/filetest.c, 5
```

为了解决以上问题，当然可以改变编译的方式：
```
$ gcc -o filetest filetest.c
```

执行结果：
```
$ ./filetest 
filetest.c, 5
```

<!--more-->
可对项目而言，改动一下会牵动很多的东西，那么可以对`__FILE__`进行一些操作：
```
#define __FILENAME__ (strrchr(__FILE__, '/') ? (strrchr(__FILE__, '/') + 1):__FILE__)
```

测试代码修改如下：
```
#include <string.h>
#include <stdio.h>

#define __FILENAME__ (strrchr(__FILE__, '/') ? (strrchr(__FILE__, '/') + 1):__FILE__)

int main(int argc, char **argv)
{
	printf("%s, %d\n", __FILENAME__, __LINE__);

	return 0;
}
```

执行结果：
```
$ ./filetest 
filetest.c, 8
```

考虑到以上的操作需要两次执行`strrchr`，这种方案也被枪毙掉了。最后采取了换行的操作，只是使用脚本去分析log文件时有很大的不便，不能快速定位到哪个文件，毕竟它们显示在不同行上。