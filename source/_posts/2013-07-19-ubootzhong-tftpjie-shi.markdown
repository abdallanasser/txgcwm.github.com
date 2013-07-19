---
layout: post
title: "Uboot中TFTP解释"
date: 2013-07-19 22:45
comments: true
categories: 
---

TFTP在Uboot中用于发送较小的文件，使用UDP协议，发送使用69端口，每次发送的最大分组为512 bytes，发送双方采用超时重传机制，数据传输模式为octet模式（二进制模式）。发送文件时使用`tftp MemoryAddress FileName`命令即可，其中MemoryAddress为放入文件的内存首地址，FileName为传送文件的文件名。

使用TFTP传送文件的步骤： 

1. 使用时已经初始化以下变量：NetOurIP（本机IP地址，定义在Net.c文件）、NetServerIP（TFTP服务器的IP地址，定义在Net.c文件）、BootFile（需要传送文件的文件名，定于在tftp.c）、NetOurGatewayIP（本机的网关地址）、NetOurSubnetMask（本机子网掩码）。
2. 调用TftpStart 函数开始文件传送。
<!--more-->

#客户端状态

TFTP使用一个变量TftpState来描述TFTP客户端可能的5种状态：

![ states ](/images/2013/7/tftp/states.png)


#包类型 

使用TFTP传送的包分为6种类型：

![ types ](/images/2013/7/tftp/types.png)

#各种包结构 
         
TFTP协议中各种包的结构：

![ pack_struct ](/images/2013/7/tftp/pack_struct.png)


Uboot中客户端发送的包的包括RRQ和ACK。RRQ（请求读的包）包的结构:

![ rrq ](/images/2013/7/tftp/rrq.png)

ACK（确认帧）结构：

![ ack ](/images/2013/7/tftp/ack.png)

#主要函数及作用 

Uboot中与tftp协议有关的文件有tftp.c与tftp.h文件，主要函数包括：
```
/* 根据预先设定的地址load_addr决定将首地址为src，长度为len的block个数据块写入flash 或写入内存*/
static __inline__ void store_block (unsigned block, uchar * src, unsigned len);

/* 根据TftpState变量的不同值发送不同的 Tftp包 （使用UDP协议发送） */
static void TftpSend (void) ;

/* 处理收到的Tftp包 */
static void TftpHandler (uchar * pkt, unsigned dest, unsigned src, unsigned len) ;

/* 超时处理函数 */
static void TftpTimeout (void);

/* 初始化各个需要的数据 然后开始发送TFTP读请求 */
void TftpStart (void);
```


#流程 

TFTP总体流程：首先客户端发出读写请求，如果服务器批准此请求，则打开连接并接收第一个数据包。客户端收到数据包后发回确认，而服务器发出下一个数据包以前必须得到客户对上一个数据包的确认。如果数据包在传输过程中丢失，服务器方会在超时后重新传输最后一个未被确认的数据包。发送的数据包一般为512字节，如果一个数据包小于 512 字节，则表示这个包是最后一个包，如果发送的数据正好是 512 的整数倍，发送完后再发一个空包。

以下是客户端和服务器端通信的流程图：

![ flow ](/images/2013/7/tftp/flow.png)

客户端程序流程：

1. 客户端设定NetOurIP 、NetServerIP、BootFile 变量的值。
2. 调用TftpStart函数完成如下6步工作：（1）若BootFile为空则使用默认文件名，否则使用BootFile为传送的文件名。（2）比较客户端和服务器的子网地址，判断两者是否在同一个子网内。（3）设定超时处理函数为TftpTimeout 。（4）设置处理接收到的TFTP包的函数为TftpHandler。（5）初始化服务器端口、本机端口、超时次数为0、初始状态为RRQ。（6）调用TftpSend函数发送TFTP读取请求。
3. TftpSend函数根据TftpState发送不同的包，同时根据包的类型和当前客户端的状态（TftpState）处理接收到的包。