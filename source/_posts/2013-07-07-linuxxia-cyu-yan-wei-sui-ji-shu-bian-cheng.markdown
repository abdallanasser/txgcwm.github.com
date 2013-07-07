---
layout: post
title: "Linux下C语言伪随机数编程"
date: 2013-07-07 12:50
comments: true
categories: 
---

在日常生活中，我们经常会遇到随机数（比如丢骰子，抓阄，抽签等等），那么在程序中如何实现随机数呢？现在很多操作系统内核都会提供相应的api，通过获取一些计算机运行时的原始信息（如内存，电压，物理信号等等，它们的值在一个时间段可以保证是唯一的）来生成随机数。下文介绍如何使用rand、srand来生成伪随机数。


#rand产生伪随机数

Linux中rand()会返回一随机数值，范围在0至RAND_MAX 间，其中RAND_MAX定义在stdlib.h，其值为2147483647。

以下例子利用rand函数生成随机数。

    #include <stdlib.h>
    #include <stdio.h>

    #define LOOP_TIMES    5

    int main(int argc, char *argv[])
    {
        int i;

        for(i=0; i< LOOP_TIMES; i++)
            printf("%d ", rand());

        printf("\n");

        return 0;
    }

运行结果：

    $ ./rand
    1804289383 846930886 1681692777 1714636915 1957747793 
    $ ./rand
    1804289383 846930886 1681692777 1714636915 1957747793

从以上的结果可以看出，rand两次产生的随机数是一样的，之所以这样是因为“在调用rand函数产生随机数前没有先利用srand()设好随机数种子”。如果未设随机数种子，rand()在调用时会自动设随机数种子为1。


#srand设置随机数种子

要想每次运行得到的随机数不同，我们还要设置随机数种子。既然要设置随机数种子，那我们就使用srand()来设置rand()产生随机数时的随机数种子。参数seed必须是个整数，通常可以利用geypid()或time(NULL)的返回值来当做seed。如果每次seed都设相同值，rand()所产生的随机数值每次就会一样。

以下例子设置随机数种子然后生成随机数。

    #include <stdlib.h>
    #include <stdio.h>
    #include <time.h>

    #define LOOP_TIMES    5

    int main(int argc, char *argv[])
    {
        int i;

        srand((unsigned int) time(NULL));

        for(i=0; i<LOOP_TIMES; i++)
            printf("%d ", rand());

        printf("\n");

        return 0;
    }

运行结果：

    $ ./rand
    1943306114 679448932 319436844 1922998560 1458181616 
    $ ./rand
    1789418334 999331839 757991171 363979956 882919632 


#合理利用随机数

运行结果是不是不同了，但这么大的数对我们来说也没有多大意义，又怎么利用这些这些随机数呢？我们可对它进行范围化分，这样就可以产生我们想要范围内的数。

产生一定范围随机数的通用表示公式：a + rand() % n，其中的a是起始值，n是整数的范围；

要取得[a,b)的随机整数，使用(rand() % (b-a))+ a;

要取得[a,b]的随机整数，使用(rand() % (b-a+1))+ a，另一种表示为a + (int)b * rand() / (RAND_MAX + 1)；

要取得(a,b]的随机整数，使用(rand() % (b-a))+ a + 1;

要取得0～1之间的浮点数，可以使用rand() / double(RAND_MAX)。

以下例子生成［0，26］之间的数，使用了语句“nu = 0 + (int)( 26.0 *rand()/(RAND_MAX + 1.0));”来获取a到b之间的随机整数。

    #include <stdlib.h>
    #include <stdio.h>
    #include <time.h>

    #define LOOP_TIMES    5

    int main(int argc, char *argv[])
    {
        int i, nu;

        srand((unsigned int) time(NULL));

        for(i=0; i< LOOP_TIMES; i++) {
            nu = 0 + (int)( 26.0 *rand()/(RAND_MAX + 1.0));
            printf("%d ", nu);
        }

        printf("\n");

        return 0;
    }

运行结果：

    $ ./rand
    6 21 20 22 7
    $ ./rand
    4 12 25 3 13


#生成随机字符串

以下例子用来生成一个指定长度的随机字符串。

    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>
    #include <time.h>

    #define BUFFER_LENGTH 257

    int main(int argc, char *argv[])
    {
        int leng = 128 ;
        int i, nu;
        char buffer[BUFFER_LENGTH];

        printf("Please Input length for the String, Default is 128, The Maxest legth is 256:");
        fgets(buffer, BUFFER_LENGTH, stdin);
        buffer[strlen(buffer)-1] = '\0' ;

        if(buffer[0] != '\0')
            leng = atoi(buffer);

        srand((unsigned int)time(NULL));
        bzero(buffer, BUFFER_LENGTH);

        for (i= 0; i< leng; i++)
            buffer[i] = 'a' + ( 0+ (int)(26.0 *rand()/(RAND_MAX + 1.0)));

        buffer[strlen(buffer)] = '\0';

        printf("The randm String is [ %s ]\n", buffer);
        return 0;
    }

运行结果：

    $ ./rand
    Please Input length for the String, Default is 128, The Maxest legth is 256:8
    The randm String is [ rdekbnxj ]
    $ ./rand
    Please Input length for the String, Default is 128, The Maxest legth is 256:36
    The randm String is [ bvfrbvvhdcuwdoarefcrkytsntltawpbsusu ]

注意，需要使用bzero(buffer, 257)这条语句将缓存清空，否则生成的随机字符串中可能就会出现乱码的情况。