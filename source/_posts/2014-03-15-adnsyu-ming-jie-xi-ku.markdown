---
layout: post
title: "域名解析库"
date: 2014-03-15 10:59
comments: true
categories: [网络应用,开源库]
---

#一个问题

在实际的开发中遇到了不能域名解析的情况，在网上搜集了大量的资料，发现有网友遇到了和我一样的状况，所以把查找的资料汇总一下，作个记录。以下信息摘自[这里](http://comments.gmane.org/gmane.comp.web.curl.library/39150)：

>I'm using libcurl 7.29.0 on Android with c-ares 1.9.1.

>I've been noticing a bug on a Samsung Galaxy S3 & Samsung Galaxy Note 2 (and possibly other devices too) when the bearer switches from wifi to 3G where I can no longer connect to a host.

>If I undefine USE_ARES (build without c-ares) then this issue is gone, but I would like to keep c-ares for performance.

>Some other (useful?) info:   
>1) Switching back to the original bearer will allow a connection again   
>2) I tried performing a curl_global_cleanup() and curl_global_init(CURL_GLOBAL_ALL) during the switch, but it didn't seem to help.

>If anyone knows of anything that I can do to continue to use c-ares I would greatly appreciate it!

<!--more-->

#Android NDK 编译c-ares

```
export NDK=/tmp/android-ndk-r8b

# Create the standalone toolchain
$NDK/build/tools/make-standalone-toolchain.sh \
--platform=android-9 \
--install-dir=/tmp/my-android-toolchain

export PATH=/tmp/my-android-toolchain/bin:$PATH
export SYSROOT=/tmp/my-android-toolchain/sysroot
export CC="arm-linux-androideabi-gcc --sysroot $SYSROOT"

# Download the latest release
curl -O http://c-ares.haxx.se/download/c-ares-1.9.1.tar.gz
tar xvfz c-ares-1.9.1.tar.gz

# Configure
cd c-ares-1.9.1 && mkdir build
./configure --prefix=$(pwd)/build \
--host=arm-linux \
--disable-shared \
CFLAGS="-march=armv7-a"

# Build and install
make && make install
```

#adns接口介绍及示例

adns是一个开源的dns解析库，官方文档点击[这里](http://www.chiark.greenend.org.uk/~ian/adns/)。

初始化
```
adns_state   adns;
adns_query   query;
adns_answer   *answer;
``` 
函数原型：
```
int adns_init(adns_state *newstate_r, adns_initflags flags, FILE *diagfile /*0=>stderr*/);
``` 
举例：
```
adns_init(&adns, adns_if_noenv, 0);
```

提交待解析的域名   
函数原型：
```
int adns_submit(adns_state ads, 
                const char *owner, 
                adns_rrtype type, 
                adns_queryflags flags, 
                void *context, 
                adns_query *query_r);
``` 
举例：
```
adns_submit(adns, argv[1], adns_r_a, (adns_queryflags) 0, NULL, &query);
```

检测是否有域名已检测完成   
函数原型：
```
int adns_check(adns_state ads,
           adns_query *query_io,
           adns_answer **answer_r,
           void **context_r);
``` 
举例：
```
adns_check(adns, &query, &answer, NULL);
```

函数原型：
```
int adns_wait(adns_state ads,
          adns_query *query_io,
          adns_answer **answer_r,
          void **context_r);
``` 
举例：
```
adns_wait(adns, &query, &answer, NULL);
```

检测是否已完成所有提交的域名的解析   
函数原型：
```
void adns_finish(adns_state ads);
``` 
举例：
```
adns_finish(adns);
```

示例代码`testdns.c`（解析IPv4地址可使用adns v1.2或adns v1.4，解析IPv6地址使用adns v1.6）：

``` 
#include <sys/errno.h> 
#include <sys/socket.h>                    
#include <netinet/in.h>                      
#include <arpa/inet.h> 
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "adns.h"
 
int test_dns(char *host)   
{ 
    int tryCount = -1; 
    int adns_cname = 0;
    adns_state ads; 
    adns_initflags flags;  
    adns_query quer = NULL;  
    flags = adns_if_nosigpipe | adns_if_noerrprint; 
    
    adns_init(&ads, flags, NULL); 
    adns_submit(ads, host, (adns_rrtype) adns_r_a, (adns_queryflags) 0, NULL, &quer);  
 
    while(tryCount < 32) { 
        tryCount += 1; 
           
        adns_answer *ans; 
        int res = adns_check(ads, &quer, &ans, NULL); 
        if(res == 0) {       
            if (ans->status == adns_s_prohibitedcname) { 
                char cname[128]; 
                strncpy(cname, ans->cname, 127); 
                cname[strlen(ans->cname)] = '\0';       
                adns_query quer = NULL; 
                adns_submit(ads, cname, (adns_rrtype) adns_r_addr, (adns_queryflags) 0, 
                            NULL, &quer);       
                adns_cname = 1; 
            } else { 
			#if 1
                //resolve IPv4 address                 
				if(adns_cname) 
                    printf("ip: %s\n", ans->status == adns_s_ok ? 
                            inet_ntoa(ans->rrs.addr->addr.inet.sin_addr) : "no"); 
               else 
                    printf("ip: %s\n", ans->status == adns_s_ok ? 
                            inet_ntoa(*(ans->rrs.inaddr)) : "no");             
     		#else
                //resolve IPv6 address
                if(adns_cname){
                    if(ans->status == adns_s_ok){
                        char buf[INET6_ADDRSTRLEN];
                        inet_ntop(AF_INET6, &ans->rrs.addr->addr.inet6.sin6_addr, 
                                    buf, sizeof(buf));
                        printf("ip: %s\n", buf);
                    }
                    else{
                         printf("no\n");
                     }
                 }
                 else{
                     if(ans->status == adns_s_ok){
                         char buf[INET6_ADDRSTRLEN];
                         inet_ntop(AF_INET6, ans->rrs.in6addr, buf, sizeof(buf));
                         printf("ip: %s\n", buf);
                     }
                     else{
                          printf("no\n");
                     }
				}
			#endif
                 adns_finish(ads); 
                 break; 
            }                   
        }        
        else if (res == ESRCH || res == EAGAIN) { 
            sleep(1); 
        } else { 
            printf("host(%s) is err!\n", host); 
        } 
    }   
    
    return 0; 
} 
 
int main(int argc, char *argv[]) { 
    char host[128]; 
    
    while(1) { 
        scanf("%s", host); 
        
        if(strlen(host) == 3 && strcmp(host, "eof")) 
            break; 
            
        test_dns(host); 
    } 
    
    return 0; 
}
```

Makefile
```
CFLAGS = -g 
TARGETS = libadns.a 
LIBOBJS = types.o event.o query.o reply.o general.o setup.o \
            parse.o poll.o check.o 
 
all: testdns 
 
testdns: testdns.c libadns.a 
libadns.a: $(LIBOBJS) 
	$(AR) cq $@ $(LIBOBJS)
    
clean: 
	rm -f $(LIBOBJS) libadns.a *~ config.status 
 
distclean: clean 
	rm -f config.h .depend   
 
$(LIBOBJS): adns.h internal.h config.h
```
下载adns-1.2的源码，然后解压，到`adns-1.2/`目录下执行`./configure`，进入到`src/`目录并加入以上的`testdns.c`、`Makefile`两个文件，`make`编译后就得到了我们需要的测试程序。
     

<big>参考链接：</big>  
[libcurl + c-ares on Android](http://comments.gmane.org/gmane.comp.web.curl.library/39150)   
[Android NDK 编译c-ares](http://blog.chinaunix.net/uid-20535334-id-3757613.html)   
[c-ares](http://c-ares.haxx.se/)   
[adns解析库——域名解析实例(C++、linux)](http://www.cnblogs.com/sunada2005/p/3232600.html)   
[GNU adns](http://www.chiark.greenend.org.uk/~ian/adns/)   