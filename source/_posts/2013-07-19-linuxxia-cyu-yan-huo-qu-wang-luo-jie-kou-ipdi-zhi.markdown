---
layout: post
title: "Linux下c语言获取网络接口IP地址"
date: 2013-07-19 22:34
comments: true
categories: 
---
在Linux环境下，可以使用以下的代码获取网络的ip地址：
```
    if (gethostname(host, sizeof(host)) < 0) {
        printf("Can't get hostname\n");
        return -1;
    }
    if ((hp = gethostbyname(host)) == NULL) {
        printf("Can't get host address\n");
        return -1;
    }
    memcpy((char *) &intaddr, (char *) hp->h_addr_list[0],
            (size_t) hp->h_length);
```
<!--more-->
在嵌入式系统中，使用goahead的时候， 以上代码是获取不到正确ip地址的，我们可以结合以下两个接口函数去获取需要的ip地址：
```
    #include <sys/socket.h>
    #include <sys/ioctl.h>
    #include <arpa/inet.h>
    #include <netinet/in.h>
    #include <net/if.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>


    static int getIfaceName(char *iface_name, int len)
    {
        int r = -1;
        int flgs, ref, use, metric, mtu, win, ir;
        unsigned long int d, g, m;    
        char devname[20];
        FILE *fp = NULL;

        if((fp = fopen("/proc/net/route", "r")) == NULL) {
            perror("fopen error!\n");
            return -1;
        }

        if (fscanf(fp, "%*[^\n]\n") < 0) {
            fclose(fp);
            return -1;
        }

        while (1) {
            r = fscanf(fp, "%19s%lx%lx%X%d%d%d%lx%d%d%d\n",
                     devname, &d, &g, &flgs, &ref, &use,
                     &metric, &m, &mtu, &win, &ir);
            if (r != 11) {
                if ((r < 0) && feof(fp)) {
                    break;
                }
                continue;
            }

            strncpy(iface_name, devname, len);
            fclose(fp);
            return 0;
        }

        fclose(fp);

        return -1;
    }

    static int getIpAddress(char *iface_name, char *ip_addr, int len)
    {
        int sockfd = -1;
        struct ifreq ifr;
        struct sockaddr_in *addr = NULL;

        memset(&ifr, 0, sizeof(struct ifreq));
        strcpy(ifr.ifr_name, iface_name);
        addr = (struct sockaddr_in *)&ifr.ifr_addr;
        addr->sin_family = AF_INET;

        if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
            perror("create socket error!\n");
            return -1;
        }
        
        if (ioctl(sockfd, SIOCGIFADDR, &ifr) == 0) {
            strncpy(ip_addr, inet_ntoa(addr->sin_addr), len);
            close(sockfd);
            return 0;
        }

        close(sockfd);

        return -1;
    }

    int main(int argc, char** argv)
    {
        struct in_addr    intaddr;
        char iface_name[20];

        if(getIfaceName(iface_name, sizeof(iface_name)) < 0) {
            printf("get interface name error!\n");
            return -1;
        }

        if(getIpAddress(iface_name, (char *) &intaddr, 15) < 0) {
            printf("get interface ip address error!\n");
            return -1;
        }
        
        printf("address:%s\n",(char *) &intaddr);

        return 0;
    }
```