---
layout: post
title: "minilzo无损压缩库介绍（一）"
date: 2013-07-07 23:32
comments: true
categories: [Unix/Linux, 开源库]
keywords:
---

在网络上传输大批量数据的时候，网络的传输速度是固定的（比如100 Mb的以太网实际测量的传输速度大概在10 MB/s左右），而想要在固定时间内传输更多容量的数据，最常见的解决方案是——在传输之前通过一定的算法把数据的容量压缩，然后通过网络传输，对端接收到数据之后再通过相应的算法进行解压还原。如果“压缩的时间 + 压缩后数据的传输时间 + 解压缩的时间 < 未压缩数据的传输时间”，就相当于提高了单位时间内的传输能力，拓宽了网络传输的带宽。


#minilzo库使用介绍

lzo是一个开源的无损压缩c语言库，其优点是压缩/解压缩比较迅速且占用内存小等特点。具体可查看 [这里](http://www.oberhumer.com/opensource/lzo/)，提供了比较全的lzo库和一个minilzo库。minilzo库提供了1个c文件和3个头文件，解压后的目录树如下：
```
    minilzo-2.06$ tree
    .
    ├── COPYING
    ├── lzoconf.h
    ├── lzodefs.h
    ├── Makefile
    ├── minilzo.c
    ├── minilzo.h
    ├── README.LZO
    └── testmini.c
```

<!--more-->

常用的有4个API（在使用的时候包含minilzo.h即可）：
```
    /* lzo_init() should be the first function you call.
     * Check the return code !
     *
     * lzo_init() is a macro to allow checking that the library and the
     * compiler's view of various types are consistent.
     */
    #define lzo_init() __lzo_init_v2(LZO_VERSION,(int)sizeof(short),(int)sizeof(int),\
        (int)sizeof(long),(int)sizeof(lzo_uint32),(int)sizeof(lzo_uint),\
        (int)lzo_sizeof_dict_t,(int)sizeof(char *),(int)sizeof(lzo_voidp),\
        (int)sizeof(lzo_callback_t))
    
    /* compression */
    LZO_EXTERN(int)
    lzo1x_1_compress        ( const lzo_bytep src, lzo_uint  src_len,
                                    lzo_bytep dst, lzo_uintp dst_len,
                                    lzo_voidp wrkmem );
    
    /* decompression */
    LZO_EXTERN(int)
    lzo1x_decompress        ( const lzo_bytep src, lzo_uint  src_len,
                                    lzo_bytep dst, lzo_uintp dst_len,
                                    lzo_voidp wrkmem /* NOT USED */ );
    
    /* safe decompression with overrun testing */
    LZO_EXTERN(int)
    lzo1x_decompress_safe   ( const lzo_bytep src, lzo_uint  src_len,
                                    lzo_bytep dst, lzo_uintp dst_len,
                                    lzo_voidp wrkmem /* NOT USED */ );
```
minilzo库使用十分简单，在压缩和解压缩之前先调用lzo_init函数进行初始化，返回LZO_E_OK表示初始化成功。压缩数据时调用lzo1x_1_compress函数；解压数据时调用lzo1x_decompress函数或lzo1x_decompress_safe函数，这两个函数的区别是——lzo1x_decompress_safe函数会对解压缩数据的有效性进行验证，验证通过才会进行解压缩操作，而lzo1x_decompress函数则不会这么做，数据不是有效时就会产生“段错误”，建议使用lzo1x_decompress_safe函数。以下是这些函数的详细操作说明：

* lzo1x_1_compress函数进行压缩数据操作，需要5个参数：压缩的数据、压缩数据的大小、压缩后数据的缓冲区、压缩缓冲区的大小、压缩工作缓冲区。压缩数据成功之后会返回LZO_E_OK。第4个参数传进去的是用来指示存放压缩后数据缓冲区的大小，执行成功之后通过指针返回的结果是压缩后的数据实际使用的缓冲区大小（即压缩后的数据大小）。压缩后需要的数据缓冲区大小的上限是可以根据未压缩数据大小进行计算的，其公式为：
```
    output_size = input_size + (input_size / 16) + 64 + 3；
```
第5个参数是压缩的时候需要使用的工作缓冲区，缓冲的生成在minilzo库提供的测试例程中有相关的宏定义。

* lzo1x_decompress和lzo1x_decompress_safe函数进行数据的解压缩操作，需要5个参数：解压缩的数据、解压缩数据的大小、解压缩后数据的存放缓冲区、原始数据（未压缩数据）大小、解压缩工作缓冲区（不需要，可以置为NULL）。执行成功之后返回LZO_E_OK。第4个参数传进去的值是原始的未压缩数据的大小，执行成功之后通过指针返回的是实际解压缩后数据的大小。所以压缩之后的数据在传输的时候需要将原始数据的大小和压缩后数据一起传输，否则对方在解压缩的时候将无法解压。可以定义一个数据结构专门用来传输，这些数据在传输的时候相当于有效载荷：
```
    typedef struct{
        unsigned long org_data_size;    /* 原始的未压缩数据大小 */
        unsigned char data[MAX_DATA_SIZE];  /* 压缩之后的数据 */
    }COMP_DATA, *P_COMP_DATA;
```    

#压缩/解压缩时间的计算

在压缩/解压缩数据之前，可以通过gettimeofday函数获取当前的系统时间，接着进行相关操作，完成之后再次获取系统时间，对2次获取的时间进行减操作即可得到实际操作所花费的时间。以下是计算操作所需花费时间的例子：
```
    unsigned long interval_ms = 0;       /* 间隔的毫秒数 */
    struct timeval stime, etime;
    
    gettimeofday(&stime, NULL);
    
    /* TODO:Do compression or decompression */
    
    gettimeofday(&etime, NULL);
    
    interval_ms = (etime.tv_sec - stime.tv_sec) * 1000.0 + \
                        （etime.tv_usec - stime.tv_usec）/ 1000.0;
```    
