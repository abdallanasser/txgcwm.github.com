---
layout: post
title: "Base64编码解码算法"
date: 2013-07-11 23:09
comments: true
categories: [Unix/Linux, C/C++, 数据结构算法]
---
Base64使用ascii码子集的64个字符，即大小写的26个英文字母，0～9，＋，/。编码基于3个字符，每个字符用8位二进制表示，一共24位，再分为4四组，每组6位表示一个Base64值（例如0就是A，27就是b）。Base64值如下：
```
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/',
```
如果被加密的字符串每3个一组，还剩1或2个字符，使用特殊字符"="补齐。例如编码只有2个字符“me”，m的ascii是109，e的是101，用二进制表示分别是01101101、01100101，连接起来就是0110110101100101，再按6位分为一组：011011、010110、010100（不足6位补0），ascii分别是27、22、 20，即Base64值为bWU，不足4字用＝补齐，因此bWU＝就me的Base64值。

<!--more-->

在[这里](https://github.com/dwjackson/basenc)可以找到一个c语言的base32/base64开源库。以下是goahead中base64编码解码的实现：
```
    static char_t    map64[] = {
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
        -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
        -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    };

    static char_t    alphabet64[] = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
        'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
        'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3',
        '4', '5', '6', '7', '8', '9', '+', '/',
    };

    /*********************************** Code *************************************/
    /*
     *    Decode a buffer from "string" and into "outbuf"
     */
    int websDecode64(char_t *outbuf, char_t *string, int outlen)
    {
        unsigned long    shiftbuf;
        char_t            *cp, *op;
        int                c, i, j, shift;

        op = outbuf;
        *op = '\0';
        cp = string;
        while (*cp && *cp != '=') {
            /*
             *        Map 4 (6bit) input bytes and store in a single long (shiftbuf)
             */
            shiftbuf = 0;
            shift = 18;
            for (i = 0; i < 4 && *cp && *cp != '='; i++, cp++) {
                c = map64[*cp & 0xff];
                if (c == -1) {
                    error(E_L, E_LOG, T("Bad string: %s at %c index %d"), string,
                          c, i);
                    return -1;
                }
                shiftbuf = shiftbuf | (c << shift);
                shift -= 6;
            }
            /*
             *        Interpret as 3 normal 8 bit bytes (fill in reverse order).
             *        Check for potential buffer overflow before filling.
             */
            --i;
            if ((op + i) >= &outbuf[outlen]) {
                gstrcpy(outbuf, T("String too big"));
                return -1;
            }
            for (j = 0; j < i; j++) {
                *op++ = (char_t) ((shiftbuf >> (8 * (2 - j))) & 0xff);
            }
            *op = '\0';
        }
        return 0;
    }

    /******************************************************************************/
    /*
     *    Encode a buffer from "string" into "outbuf"
     */
    void websEncode64(char_t *outbuf, char_t *string, int outlen)
    {
        unsigned long    shiftbuf;
        char_t            *cp, *op;
        int                x, i, j, shift;

        op = outbuf;
        *op = '\0';
        cp = string;
        while (*cp) {
            /*
             *        Take three characters and create a 24 bit number in shiftbuf
             */
            shiftbuf = 0;
            for (j = 2; j >= 0 && *cp; j--, cp++) {
                shiftbuf |= ((*cp & 0xff) << (j * 8));
            }
            /*
             *        Now convert shiftbuf to 4 base64 letters. The i,j magic calculates
             *        how many letters need to be output.
             */
            shift = 18;
            for (i = ++j; i < 4 && op < &outbuf[outlen] ; i++) {
                x = (shiftbuf >> shift) & 0x3f;
                *op++ = alphabet64[(shiftbuf >> shift) & 0x3f];
                shift -= 6;
            }
            /*
             *        Pad at the end with '='
             */
            while (j-- > 0) {
                *op++ = '=';
            }
            *op = '\0';
        }
    }
```


Linux提供了命令行方式的base64编码和解码。

+ 将字符串str+换行 编码为base64字符串输出。
```
    $ echo "str" | base64
```
+ 将字符串str编码为base64字符串输出。
```
    $ echo -n "str" | base64
```
+ 从指定的文件file中读取数据，编码为base64字符串输出。
```
    $ base64 file
```
+ 从标准输入中读取已经进行base64编码的内容，解码输出。
```
    $ base64 -d 
```
+ 从标准输入中读取已经进行base64编码的内容，解码输出。加上-i参数，忽略非字母表字符，比如换行符。
``` 
    $ base64 -d -i
```
+ 将base64编码的字符串str+换行 解码输出。
```
    $ echo "str" | base64 -d
```
+ 将base64编码的字符串str解码输出。
```
    $ echo -n "str" | base64 -d
```
+ 从指定的文件file中读取base64编码的内容，解码输出。
```
    $ base64 -d file 
```
