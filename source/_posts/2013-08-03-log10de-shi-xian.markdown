---
layout: post
title: "log10的实现"
date: 2013-08-03 01:46
comments: true
categories: [C/C++, Unix/Linux]
---
在项目中要使用到log10计算，可所用系统的标准库里并没有移植该功能，需要自己实现。请问，采用什么算法实现该功能？

在网上找了一个例子，但不确定能否在嵌入式的一些平台使用。
```
    double my_log10(double x)
    {
        register double ret;

  	 __asm__(
		"fldlg2\n\t" 
		"fxch\n\t" 
		"fyl2x"
		:"=t"(ret)
  		:"0"(x)
			);
       return ret;
    }
```
<!--more-->

也查看了glibc的源码，可调用了其它的一些API，对库的依赖比较大，逐步移植的话比较麻烦。代码如下：
```
    double __log10 (double x)
    {
        if (__builtin_expect (islessequal (x, 0.0), 0) && _LIB_VERSION != _IEEE_)
        {
            if (x == 0.0)
	        {
	             feraiseexcept (FE_DIVBYZERO);
	             return __kernel_standard (x, x, 18); /* log10(0) */
	        }
            else
	        {
	            feraiseexcept (FE_INVALID);
	            return __kernel_standard (x, x, 19); /* log10(x<0) */
	        }
         }

       return  __ieee754_log10 (x);
    }
```

参考 [这里](http://www.cnblogs.com/skyivben/archive/2013/02/15/2912914.html) 实现了一个c语言版本的log10快速算法，还不是很完善。
```
#include <math.h>
#include <string.h>
#include <stdio.h>

static double Sqrt(double x)
{
    if (x < 0)
        return -1;
    if (x == 0)
        return 0;
    double y = (double)sqrt((double)x);

    return (y + x / y) / 2;
}

static double NegativeLog(double q)
{                           
    int p;
    double pi2 = 6.283185307179586476925286766559;
    double eps2 = 0.00000000000001; // 1e-14
    double eps1;    // 1e-28
    double r = q, s = q, n = q, q2 = q * q, q1 = q2 * q;

    eps1 = eps2 * eps2;

    for (p = 1; (n *= q1) > eps1; s += n, q1 *= q2)
        r += (p = !p) ? n : -n;

    double u = 1 - 2 * r, v = 1 + 2 * s, t = u / v;
    double a = 1, b = Sqrt(1 - t * t * t * t);

    for (; a - b > eps2; b = Sqrt(a * b), a = t)
        t = (a + b) / 2;

    return pi2 / (a + b) / v / v;
}

static double Log(double x)
{
    int k = 0;
    double ln10 = 2.30258509299404568401799145468;

    if (x <= 0)
        return -1;
    if (x == 1)
        return 0;

    for (; x > 0.1; k++)
        x /= 10;
    for (; x <= 0.01; k--)
        x *= 10;

    return k * ln10 - NegativeLog(x);
}

double Log10(double x)
{
    double ln10 = 2.30258509299404568401799145468;

    return Log(x) / ln10;
}

int main(int argc, char **argv)
{
    printf(" self Log10: %f\n math log10: %f\n\n", Log10(1000), log10(1000));
    printf(" self Log10: %f\n math log10: %f\n\n", Log10(1), log10(1));
    printf(" self Log10: %f\n math log10: %f\n\n", Log10(8192.1024), log10(8192.1024));
    printf(" self Log10: %f\n math log10: %f\n\n", Log10(0.3), log10(0.3));
    printf(" self Log10: %f\n math log10: %f\n\n", Log10(33.8), log10(33.8));

    return 0;
}
```