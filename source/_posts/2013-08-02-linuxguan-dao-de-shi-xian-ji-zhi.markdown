---
layout: post
title: "Linux管道的实现机制"
date: 2013-08-02 00:24
comments: true
categories: [C/C++, Unix/Linux]
---
在Linux中，管道是一种使用非常频繁的通信机制。从本质上说，管道也是一种文件，但它又和一般的文件有所不同，管道可以克服使用文件进行通信的两个问题，具体表现为：

+ 限制管道的大小。实际上，管道是一个固定大小的缓冲区。在Linux中，该缓冲区的大小为1页，即4K字节，使得它的大小不像文件那样不加检验地增长。使用单个固定缓冲区也会带来问题，比如在写管道时可能变满，当这种情况发生时，随后对管道的write()调用将默认地被阻塞，等待某些数据被读取，以便腾出足够的空间供write()调用写。

+ 读取进程也可能工作得比写进程快。当所有当前进程数据已被读取时，管道变空。当这种情况发生时，一个随后的read()调用将默认地被阻塞，等待某些数据被写入，这解决了read()调用返回文件结束的问题。

注意：从管道读数据是一次性操作，数据一旦被读，它就从管道中被抛弃，释放空间以便写更多的数据。

<!--more-->

#管道的结构

在Linux中，管道的实现并没有使用专门的数据结构，而是借助了文件系统的file结构和VFS的索引节点inode。通过将两个file结构指向同一个临时的VFS索引节点，而这个VFS索引节点又指向一个物理页面而实现的。如下图所示。

![ struct ](/images/2013/8/pipe/struct.png)

图中有两个file数据结构，但它们定义文件操作例程地址是不同的，其中一个是向管道中写入数据的例程地址，而另一个是从管道中读出数据的例程地址。这样，用户程序的系统调用仍然是通常的文件操作，而内核却利用这种抽象机制实现了管道这一特殊操作。


#管道的读写

管道实现的源代码在fs/pipe.c中，在pipe.c中有很多函数，其中有两个函数比较重要，即管道读函数pipe_read()和管道写函数pipe_wrtie()。管道写函数通过将字节复制到VFS索引节点指向的物理内存而写入数据，而管道读函数则通过复制物理内存中的字节而读出数据。当然，内核必须利用一定的机制同步对管道的访问，为此，内核使用了锁、等待队列和信号。

当写进程向管道中写入时，它利用标准的库函数write()，系统根据库函数传递的文件描述符，可找到该文件的file结构。file结构中指定了用来进行写操作的函数（即写入函数）地址，于是，内核调用该函数完成写操作。写入函数在向内存中写入数据之前，必须首先检查VFS索引节点中的信息，同时满足如下条件时，才能进行实际的内存复制工作：

+ 内存中有足够的空间可容纳所有要写入的数据；
+ 内存没有被读程序锁定。

如果同时满足上述条件，写入函数首先锁定内存，然后从写进程的地址空间中复制数据到内存。否则，写入进程就休眠在VFS索引节点的等待队列中，接下来，内核将调用调度程序，而调度程序会选择其他进程运行。写入进程实际处于可中断的等待状态，当内存中有足够的空间可以容纳写入数据，或内存被解锁时，读取进程会唤醒写入进程，这时，写入进程将接收到信号。当数据写入内存之后，内存被解锁，而所有休眠在索引节点的读取进程会被唤醒。

管道的读取过程和写入过程类似。但是，进程可以在没有数据或内存被锁定时立即返回错误信息，而不是阻塞该进程，这依赖于文件或管道的打开模式。反之，进程可以休眠在索引节点的等待队列中等待写入进程写入数据。当所有的进程完成了管道操作之后，管道的索引节点被丢弃，而共享数据页也被释放。


#CU上的问题

##popkart718的提问

《Unix环境高级编程》403页中部分描述如下：

![ sync ](/images/2013/8/pipe/sync.jpg)

明明是两个管道，为什么read的时候会发生阻塞呢？

##解答

read依赖于管道的打开模式，打开管道时可使用pipe2设定相应的flags。书上所写的阻塞是在管道中没有数据的情况下发生的。
```
       int pipe2(int pipefd[2], int flags);

DESCRIPTION
       pipe()  creates  a  pipe, a unidirectional data channel that can be used for interprocess communication.  The array pipefd is used to return
       two file descriptors referring to the ends of the pipe.  pipefd[0] refers to the read end of the pipe.  pipefd[1] refers to the write end of
       the  pipe.  Data written to the write end of the pipe is buffered by the kernel until it is read from the read end of the pipe.  For further
       details, see pipe(7).

       If flags is 0, then pipe2() is the same as pipe().  The following values can be bitwise ORed in flags to obtain different behavior:

       O_NONBLOCK  Set the O_NONBLOCK file status flag on the two new open file descriptions.  Using this flag saves extra  calls  to  fcntl(2)  to
                   achieve the same result.

       O_CLOEXEC   Set  the  close-on-exec  (FD_CLOEXEC) flag on the two new file descriptors.  See the description of the same flag in open(2) for
                   reasons why this may be useful.
```
同时也可以查看内核文件fs/pipe.c中的pipe_read函数实现。以下是简单的测试程序。

测试一：使用pipe2且传入参数的flags为0（相当于使用pipe）
```
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>

int fd[2];

void handle(int sig)
{
	if (sig == SIGUSR1)
		write(fd[1], "p", 1);
}

int main(int argc, char **argv)
{
	char c;
	pid_t pid;

	if (pipe2(fd, 0) < 0) {
		printf("can not creat pipe!\n");
		return -1;
	}

	if ((pid = fork()) < 0) {
		printf("can not fork!\n");
		return -1;
	} else if (pid > 0) {
		close(fd[0]);
		signal(SIGUSR1, handle);
		for (;;) {
		}
	} else {
		close(fd[1]);
		for (;;) {
			if (read(fd[0], &c, 1) == 1)
				printf("c:%c\n", c);
			else
				printf("nothing to read!\n");

			sleep(2);
		}
	}

	return 0;
}
```
编译后，可以看到程序阻塞在那里，当使用“kill -10 进程号”时，才会从管道中读出数据。


测试二：使用pipe2时设置flags的参数为O_NONBLOCK
```
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>

int fd[2];

void handle(int sig)
{
	if (sig == SIGUSR1)
		write(fd[1], "p", 1);
}

int main(int argc, char **argv)
{
	char c;
	pid_t pid;

	if (pipe2(fd, O_NONBLOCK) < 0) {
		printf("can not creat pipe!\n");
		return -1;
	}

	if ((pid = fork()) < 0) {
		printf("can not fork!\n");
		return -1;
	} else if (pid > 0) {
		close(fd[0]);
		signal(SIGUSR1, handle);
		for (;;) {
		}
	} else {
		close(fd[1]);
		for (;;) {
			if (read(fd[0], &c, 1) == 1)
				printf("c:%c\n", c);
			else
				printf("nothing to read!\n");

			sleep(2);
		}
	}

	return 0;
}
```
编译后，执行程序可以看到它不停的打印消息，若管道内没有数据的话，read就直接返回了。


#参考文章

[Linux管道的实现机制](http://oss.org.cn/kernel-book/ch07/7.1.1.htm)
[进程通信管道问题](http://bbs.chinaunix.net/thread-4069374-1-1.html)