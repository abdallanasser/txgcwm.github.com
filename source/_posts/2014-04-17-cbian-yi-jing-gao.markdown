---
layout: post
title: "C编译警告"
date: 2014-04-17 00:00
comments: true
categories: [C/C++]
---

编译的时候，一看到warning信息就心烦，尤其在遇到错误的时候还得在一大堆信息中去查找error。公司的代码在编译时有一大堆的warning信息，我觉得它们可恶透了，在心情好的时候就慢慢地把它们给修改了。遇到警告的信息，我一般不太会使用编译选项把它们给避免了，因为这可能隐藏掉一些潜在的错误。

在整个的清理过程中，主要发现以下几类警告信息：

- 类在构建时，变量初始化的次序颠倒；
- 有无符号数在作比较；
- 宏定义不正确；
- 定义了没有使用的变量，如果有很多条件宏定义的时候，这个处理要细致一些；
- 结构体和数组的初始化方式不正确，其实是错误的方式，却也只是警告；
- 不小心书写代码引发的警告，有些其实也是错误，不过编译器不能识别出来，例如以下列举的例子；
```
if(ptr != NULL);  // 分号错误的添加
    printf("[%s, %d] address: %p \n", __FUNCTION__, __LINE__, ptr); 
    //当然这里在程序运行时，如果ptr为NULL会引发段错误。若是其它的一些操作，可能一下子根本查不出错误的所在。
    
if(a=1)  //实际上代码的本意是想表达if(a==1)，这样写是潜在的错误，其它的逻辑根本执行不到。
    /*do something*/
```
- 函数的形参定义了，在函数体内却没有使用到。

<!--more-->

针对最后一点警告信息，可以有以下的方式处理：

- 去除没有使用的形参；
- 使用`(void)x`的方式；
```
#define UNUSED(x) (void)x 
void SomeFunction(int param1, int param2) 
{ 
    UNUSED(param2); 
    //UNUSED(param2)语句不产生任何目标代码，消除对未使用变量的警告，并明确文件不要使用变量的代码。
    //do stuff with param1 
}
```
- 对没使用的参数使用`para=para`方式；
```
int SomeFunction(int param1, int param2)
{
    param2=param2;    //添加该行
    //do stuff with param1 
    return 0;
}
```
- 使用`gcc`的`__attribute__((unused))`功能项；
```
#ifdef UNUSED
#elif defined(__GNUC__)
# define UNUSED(x) UNUSED_ ## x __attribute__((unused))
#elif defined(__LCLINT__)
# define UNUSED(x) /*@unused@*/ x
#else
# define UNUSED(x) x
#endif

void dcc_mon_siginfo_handler(int UNUSED(whatsig)) 
```

所有的warning信息去除之后，整个代码的编译过程就清晰了很多。大伙并不是没有察觉到这些警告的重要性，只是已经习惯了自己的方式，而漠视了这一切，殊不知细看的话这里面还是存在还多的错误。世间百态任它如何，我要坚守自己的风格，还自己一个清净的世界。

<big>参考文章</big>   
[如何消除gcc编译警告 warning: "unused parameter xxxx"](http://bbs.csdn.net/topics/340049876)  
[UNUSED in gcc](http://sourcefrog.net/weblog/software/languages/C/unused.html)    
