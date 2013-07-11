---
layout: post
title: "minilzo无损压缩库测试例子（二）"
date: 2013-07-10 23:01
comments: true
categories: 
---

在minilzo无损压缩库中提供了一个测试例子（文件名为testmini.c），对该示例作一个分析。如果我们要使用该库中的四个基本函数，首先必须包含以下的头文件。
```
#include "minilzo.h"
```
其中，lzo_init()函数包含在以下的头文件中。
```
#include "lzoconf.h"
```
lzoconf.h已包含在minilzo.h中，所以在写测试例子时只需包含minilzo.h头文件即可。


将原始数据存放在in中且定义其长度为IN_LEN，压缩后的数据存放在out中且定义其长度为OUT_LEN。因为输入块可能是不可压缩的，所以我们必须提供多一点的输出空间。
```
#if defined(__LZO_STRICT_16BIT)
#define IN_LEN      (8*1024u)
#elif defined(LZO_ARCH_I086) && !defined(LZO_HAVE_MM_HUGE_ARRAY)
#define IN_LEN      (60*1024u)
#else
#define IN_LEN      (128*1024ul)
#endif
#define OUT_LEN     (IN_LEN + IN_LEN / 16 + 64 + 3)

static unsigned char __LZO_MMODEL in  [ IN_LEN ];
static unsigned char __LZO_MMODEL out [ OUT_LEN ];
```

<!--more-->

压缩需要工作缓冲区，内存分配以‘lzo_align_t’（而不是‘char’）为单元，以确保它对齐。
```
#define HEAP_ALLOC(var,size) \
    lzo_align_t __LZO_MMODEL var [ ((size) + (sizeof(lzo_align_t) - 1)) / \
                                    sizeof(lzo_align_t) ]

static HEAP_ALLOC(wrkmem, LZO1X_1_MEM_COMPRESS);
```

Step 1: 初始化lzo库。
```
    if (lzo_init() != LZO_E_OK)
    {
        printf("internal error - lzo_init() failed !!!\n");
        printf("(this usually indicates a compiler bug - try recompiling\n
                    without optimizations, and enable '-DLZO_DEBUG' for diagnostics)\n");
        return 3;
    }
```

Step 2: 准备将要被压缩的输入块，在这个例子程序中我们只是简单的写入“0”。在实际的应用中，应该写入真正需要压缩的数据。
```
    in_len = IN_LEN;
    lzo_memset(in,0,in_len);
```

Step 3: 使用LZO1X-1将in中的数据压缩到out中。
```
    r = lzo1x_1_compress(in,in_len,out,&out_len,wrkmem);
    if (r == LZO_E_OK)
        printf("compressed %lu bytes into %lu bytes\n",
            (unsigned long) in_len, (unsigned long) out_len);
    else
    {
        /* this should NEVER happen */
        printf("internal error - compression failed: %d\n", r);
        return 2;
    }
    /* check for an incompressible block */
    if (out_len >= in_len)
    {
        printf("This block contains incompressible data.\n");
        return 0;
    }
```

Step 4: 将out中的数据解压缩到in中。
```
    new_len = in_len;
    r = lzo1x_decompress(out,out_len,in,&new_len,NULL);
    if (r == LZO_E_OK && new_len == in_len)
        printf("decompressed %lu bytes back into %lu bytes\n",
            (unsigned long) out_len, (unsigned long) in_len);
    else
    {
        /* this should NEVER happen */
        printf("internal error - decompression failed: %d\n", r);
        return 1;
    }
```

minilzo支持多个平台，在编译的时候应该设置编译选项。在Linux系统中，编译该测试例程使用以下指令。
```
$ make gcc
gcc  -s -Wall -O2 -fomit-frame-pointer -o testmini testmini.c minilzo.c
```
以下为运行结果。
```
$ ./testmini 

LZO real-time data compression library (v2.06, Aug 12 2011).
Copyright (C) 1996-2011 Markus Franz Xaver Johannes Oberhumer
All Rights Reserved.

compressed 131072 bytes into 598 bytes
decompressed 598 bytes back into 131072 bytes

miniLZO simple compression test passed.
```