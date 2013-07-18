---
layout: post
title: "求两个整数的最大公约数"
date: 2013-07-07 17:10
comments: true
categories: 
---

辗转相除法又名欧几里德算法（Euclidean algorithm），用于求两个正整数的最大公因子的算法。它是已知最古老的算法，可追溯至公元前300年。它首次出现于欧几里德的《几何原本》中，而在中国则可以追溯至东汉出现的《九章算术》。

设两数为a、b(b<a)，求它们的最大公约数的步骤如下：用b除a，得a＝bq...r1(0≤r1)。若r1=0，则(a，b)＝b；若r1≠0，则再用r1除b，得b＝r1q...r2(0≤r2)。若r2＝0，则(a，b)＝r1，若r2≠0，则继续用r2除r1,...如此下去，直到能整除为止。其最后一个非零余数即为(a，b)。

<!--more-->

辗转相除法是利用以下性质来确定两个正整数a和b的最大公因子的：

1、若r是a÷b的余数,则gcd(a,b) = gcd(b,r)；

2、若b为0，则其最大公因子为a。

另一种置换实现方式：

1、r为a÷b所得余数（0≤r<b）。若r=0，算法结束，b即为答案；

2、若r不为0，则互换：置a←b，b←r，并返回第一步。

递归实现：

    int gcd(int a,int b)
    {
        if(b == 0)
            return a;
        else
            return gcd(b, a%b);
    }


对递归实现的改进：

    int gcd(int a,int b)
    {
        return b ? gcd(b, a%b) : a;
    }


置换实现：

    int gcd( int a, int b)
    {
        int temp;

         while(b) {
            temp = b;
            b = a%b;
            a = temp;      
         }

         return a;
    }


对置换实现的改进：

    int gcd(int a, int b)
    {
        while(b)
            b = a%b + 0/(a=b);

        return a;
    }