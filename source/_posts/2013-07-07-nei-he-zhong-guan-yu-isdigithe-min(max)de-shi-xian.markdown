---
layout: post
title: "内核中关于isdigit和min（max）的实现"
date: 2013-07-07 10:41
comments: true
categories: [Unix/Linux, C/C++]
---
isdigit、min、max等函数或宏定义是我们平时最常使用的，但往往没有更多的去思考它们的效率及其副作用。下面让我们来看看，内核是如何实现它们的。

#isdigit

在标准C中，isdigit函数可以用来判断字符是否为0~9之间的数字。比如：

    int a = isdigit('1');
    int b = isdigit('a');
    int c = isdigit(3);

可以使用宏定义去实现这个简单的函数，如下所示：

    #define isdigit(c) ((c) >= '0' && (c) <= '9')

<!--more-->

Linux内核中isdigit的实现，其代码如下所示：

    #define _U 0x01 /* upper */
    #define _L 0x02 /* lower */
    #define _D 0x04 /* digit */
    #define _C 0x08 /* cntrl */
    #define _P 0x10 /* punct */
    #define _S 0x20 /* white space (space/lf/tab) */
    #define _X 0x40 /* hex digit */
    #define _SP 0x80 /* hard space (0x20) */
     
    extern unsigned char _ctype[];

    #define isdigit(c) ((_ctype+1)[c]&(_D))

    unsigned char _ctype[] = {0x00, /* EOF */
     _C,_C,_C,_C,_C,_C,_C,_C, /* 0-7 */
     _C,_C|_S,_C|_S,_C|_S,_C|_S,_C|_S,_C,_C, /* 8-15 */
     _C,_C,_C,_C,_C,_C,_C,_C, /* 16-23 */
     _C,_C,_C,_C,_C,_C,_C,_C, /* 24-31 */
     _S|_SP,_P,_P,_P,_P,_P,_P,_P, /* 32-39 */
     _P,_P,_P,_P,_P,_P,_P,_P, /* 40-47 */
     _D,_D,_D,_D,_D,_D,_D,_D, /* 48-55 */
     _D,_D,_P,_P,_P,_P,_P,_P, /* 56-63 */
     _P,_U|_X,_U|_X,_U|_X,_U|_X,_U|_X,_U|_X,_U, /* 64-71 */
     _U,_U,_U,_U,_U,_U,_U,_U, /* 72-79 */
     _U,_U,_U,_U,_U,_U,_U,_U, /* 80-87 */
     _U,_U,_U,_P,_P,_P,_P,_P, /* 88-95 */
     _P,_L|_X,_L|_X,_L|_X,_L|_X,_L|_X,_L|_X,_L, /* 96-103 */
     _L,_L,_L,_L,_L,_L,_L,_L, /* 104-111 */
     _L,_L,_L,_L,_L,_L,_L,_L, /* 112-119 */
     _L,_L,_L,_P,_P,_P,_P,_C, /* 120-127 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 128-143 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 144-159 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 160-175 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 176-191 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 192-207 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 208-223 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* 224-239 */
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; /* 240-255 */

字符'0'~'9'对应的ASCII码为48~57，映射到上面的_ctype数组，相应的位置全是_D，_D&_D则为真，其它的字符则判断为false。对不同种类的字符进行了分类，并使用唯一的二进制来进行标识，使用&和|保证了不同类别的字符不会同时满足两种分类的条件。


#min和max

实现min和max这两个函数，可以有三种形式：1）定义宏；2）定义函数； 3）定义inline函数。以定义宏举例，一般都是以下形式：

    #define min(x,y) ((x)>(y)?(y):(x))
    #define max(x,y) ((x)>(y)?(x):(y))

但是上面的写法是有副作用的。比如输入：

    minval = min(x++, y);

替换宏之后，代码变成：

    minval = ((x++)>(y)? (y):(x++))

可以看出，如果x是最小值，那么它加了两次，很明显是不对的。

Linux内核实现min和max宏：

    /*
     * min()/max() macros that also do
     * strict type-checking.. See the
     * "unnecessary" pointer comparison.
     */
     #define min(x, y) ({ \
             typeof(x) _min1 = (x); \
             typeof(y) _min2 = (y); \
             (void) (&_min1 == &_min2); \
             _min1 < _min2 ? _min1 : _min2; })
     
     #define max(x, y) ({ \
             typeof(x) _max1 = (x); \
             typeof(y) _max2 = (y); \
             (void) (&_max1 == &_max2); \
             _max1 > _max2 ? _max1 : _max2; })

1、typeof(x)的用途：得到x的类型信息，比如typeof(10) 为int， typeof(1.0)为double。

2、({})的用途：一句语句，({ 和 })之间可以有很多表达式，它的值为最后一个表达式的值。

3、(void)(&_x == &_y);这一句的作用：判断_x和_y的类型是否一样。如果是不同的类型，编译器会报“warning: comparison of distinct pointer types lacks a cast”的警告信息。

其实，内核的宏定义就是先引入和x及y同样类型的两个临时变量，然后对临时变量进行求最大值或者最小值。
