---
layout: post
title: "kfifo.c中in和out的溢出问题"
date: 2013-08-03 01:08
comments: true
categories: [内核/驱动]
---

先上内核循环缓冲结构体的定义：
```
struct kfifo {
    unsigned char *buffer;        /* the buffer holding the data */
    unsigned int size;        /* the size of the allocated buffer */
    unsigned int in;        /* data is added at offset (in % size) */
    unsigned int out;        /* data is extracted from off. (out % size) */
    spinlock_t *lock;        /* protects concurrent modifications */
};
```
如果对“Linux内核中的循环缓冲区”不是很了解的话，可以先参考 [这里](http://www.kerneltravel.net/jiaoliu/kern-kfifo.html) 。内核中有关kfifo.c和kfifo.h两个文件的源码以及该问题的具体情况，可以查看 [这里](http://bbs.chinaunix.net/thread-4088139-1-1.html) 。

<!--more-->

对于结构体内的in和out两个变量，内核是作如下处理的:1、在读入数据时增加in；2、在取出数据时增加out；3、当检测到两个相等的时候将它们复位归0。1和2不作讨论和分析，针对第3点的处理，内核代码如下：
```
static inline unsigned int kfifo_get(struct kfifo *fifo,
                                     unsigned char *buffer, unsigned int len)
{
    unsigned long flags;
    unsigned int ret;

    spin_lock_irqsave(fifo->lock, flags);
    ret = __kfifo_get(fifo, buffer, len);

    /*
     * optimization: if the FIFO is empty, set the indices to 0
     * so we don't wrap the next time
     */
    if (fifo->in == fifo->out)
        fifo->in = fifo->out = 0;

    spin_unlock_irqrestore(fifo->lock, flags);

    return ret;
}
```
问题：当数据写入速度大于读取速度的时候，in和out的值将永远不会相等，也就是说buffer永远是有数据的，这样的话in和out都存在超出自身数值表示范围，从而导致错误？

针对这个问题，不知大家有什么好的建议？



##网友felix021的回复

之前看错了你的问题。

从源码的实现上来说，in和out的确是有可能会出现溢出，但是出现的情况非常极端：每次读取数据的时候都比当前缓冲区中的数据还少、而且这种情况持续直到写入的数据超过4GB。通常应该是不会遇到的；鉴于墨菲定律可能带来的恶果，的确还是得考虑一下。

不过可以再想想，溢出了就真的会导致程序出错吗？

回头再仔细看看 __kfifo_put()里面的代码，在写入的时候是这样实现的：
```
/* first put the data starting from fifo->in to buffer end */
l = min(len, fifo->size - (fifo->in & (fifo->size - 1)));
memcpy(fifo->buffer + (fifo->in & (fifo->size - 1)), buffer, l);
```
注意`(fifo->in & (fifo->size - 1)`这里用了`&`符号，而不是直接`%fifo->size`，也就是说，初始化的时候size必然得设置成2的n次方（这个限制在内核里很合理，因为内核分配的空间通常是2的倍数，比如一个page）。

在像x86这种溢出跟取模操作等价的处理器上，对于当前的写入操作实际上“正好”没有风险。同样的，由于in/out都是 unsigned int，在后续的 kfifo_get/kfifo_len 里面`in - out`(比如说`2 - 4294967295`，你可以试试)，结果仍然“正好”是正确的。

结论就是，它居然真的没有风险（前提是在溢出、无符号整数减法操作与x86处理器类似的CPU上）。

不得不说，内核源码的开发者真吝啬啊，多写一个赋值操作都不舍得。

##参考文章

[内核kfifo.c中in和out的问题](http://segmentfault.com/q/1010000000249362)   
[内核中kfifo.c相关的问题](http://bbs.chinaunix.net/thread-4088139-1-1.html)   