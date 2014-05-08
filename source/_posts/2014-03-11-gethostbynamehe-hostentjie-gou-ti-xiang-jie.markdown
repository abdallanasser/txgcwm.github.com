---
layout: post
title: "gethostbyname和hostent结构体详解"
date: 2014-03-11 22:43
comments: true
categories: [网络应用]
---
```
struct hostent *gethostbyname(const char *name);
```
gethostbyname函数根据域名解析出服务器的ip地址，它返回一个结构体struct hostent：
```
#include <netdb.h>

struct hostent {
	char  *h_name;            /* official name of host */
	char **h_aliases;         /* alias list */
	int    h_addrtype;        /* host address type */
	int    h_length;          /* length of address */
	char **h_addr_list;       /* list of addresses */
}
#define h_addr h_addr_list[0]  /* for backward compatibility */
```

除了服务器的ip地址外，这个结构体还包含了更多服务器的信息，有：
```
char *h_name

This is the “official” name of the host. 
```
```
char **h_aliases

These are alternative names for the host, represented as a null-terminated vector of strings. 
```
主机的可选名字，以NULL作为结束标记。
<!--more-->
```
int h_addrtype

This is the host address type; in practice, its value is always either AF_INET or AF_INET6, with the latter being used for IPv6 hosts. In principle other kinds of addresses could be represented in the database as well as Internet addresses; if this were done, you might find a value in this field other than AF_INET or AF_INET6. See Socket Addresses. 
```
```
int h_length

This is the length, in bytes, of each address. 
```
ip地址的长度，ipv4对应4个字节。
```
char **h_addr_list

This is the vector of addresses for the host. (Recall that the host might be connected to multiple networks and have different addresses on each one.) The vector is terminated by a null pointer. 
```
一般主机可以有多个ip地址，比如www.163.com就有121.14.228.43和121.11.151.72两个ip，h_addr_list就用来保存多个ip地址。
```
char *h_addr

This is a synonym for h_addr_list[0]; in other words, it is the first host address.
```
即为h_addr_list[0]，表示第一个地址，这个符号其实是兼容老系统而存在的。


写一个程序来获取主机的详细信息：

```
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define SERVPORT 80

int main(int argc, char **argv)
{
    int i, sockfd;
    struct hostent *host;
    struct sockaddr_in serv_addr;

    if ((host = gethostbyname(argv[1])) == NULL) {
        printf("gethostbyname error\n");
        exit(0);
    }

    printf("official name: %s\n\n", host->h_name);
    printf("address length: %d bytes\n\n", host->h_length);

    printf("host name alias: \n");
    for (i = 0; host->h_aliases[i]; i++) {
        printf("%s\n", host->h_aliases[i]);
    }
    printf("\naddress list: \n");

    for (i = 0; host->h_addr_list[i]; i++) {
        if ((sockfd = socket(AF_INET, SOCK_STREAM,0)) == -1) {
            printf("socket error\n");
            exit(0);
        }
        // 先清零，然后用struct sockaddr_in来填值
        bzero(&serv_addr, sizeof(serv_addr));
        serv_addr.sin_family = AF_INET;
        serv_addr.sin_port = htons(SERVPORT);
        /* h_addr_list[i]指向in_addr类型 */
        serv_addr.sin_addr = *((struct in_addr *)host->h_addr_list[i]);
        const char *ip = inet_ntoa(serv_addr.sin_addr);
        printf("connect to %s  ", ip);

        // 系统调用的时候，把sockaddr_in转换成sockaddr
        if (connect(sockfd, (struct sockaddr *)&serv_addr, \
                    sizeof(struct sockaddr)) == -1) {
            printf("error\n");
            exit(0);
        }
        printf("success\n");
    }

    return 0;
}
```

这个程序首先调用gethostbyname得到服务器的各种信息，其中就包含它拥有的ip地址，保存在h_addr_list中，然后对于h_addr_list中的每个ip地址，都调用connect连接其80端口。h_addr_list保存的ip地址类型是char *，struct sockaddr_in中sin_addr的类型是struct in_addr，而程序中却直接把h_addr_list[i]强制转换成struct in_addr *
```
serv_addr.sin_addr = *((struct in_addr *)host->h_addr_list[i]);
```
这是没有问题的，因为h_addr_list保存的并不是真正的字符串，而是指向struct in_addr类型的指针。

另外，struct in_addr用来表示ip地址，本质上是一个long类型，刚好4个字节。然后我们调用inet_ntoa把它转换成可读性更强的dots-and-number字符串。关于ip地址和dots-and-number字符串之间的转换有4个函数：

 
```
#include <arpa/inet.h>
/* network to ascii */
char *inet_ntoa(struct in_addr in);
   						
/* ascii to network */
int inet_aton(const char *cp, struct in_addr *inp);

const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);
								
int inet_pton(int af, const char *src, void *dst);  /* presentation format to network */
```
inet_ntoa和inet_aton不支持ipv6, 据说迟早要废除，不过目前来说，很多系统都可以看见这两个函数。