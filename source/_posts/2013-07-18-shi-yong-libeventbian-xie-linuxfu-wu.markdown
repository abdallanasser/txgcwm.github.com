---
layout: post
title: "使用libevent编写Linux服务"
date: 2013-07-18 19:01
comments: true
categories: 
---
libevent是一个事件触发的网络库，适用于windows、linux、bsd等多种平台，内部使用select、epoll、kqueue等系统调用管理事件机制，著名分布式缓存软件memcached也使用到了该库。


#初始化事件

首先完成对libenvent的事件初始化和事件驱动模型的选择。在使用多线程的情况下，一般我们需获取所返回的事件根基。
```
main_base = event_init();
```
event_init函数返回的是一个event_base对象，该对象包括了事件处理过程中的一些全局变量，其结构为：
```
struct event_base {
    const struct eventop *evsel;
    void *evbase;
    int event_count;        /* counts number of total events */
    int event_count_active; /* counts number of active events */
    int event_gotterm;      /* Set to terminate loop */
    int event_break;        /* Set to terminate loop immediately */
    /* active event management */
    struct event_list **activequeues;
    int nactivequeues;
    /* signal handling info */
    struct evsignal_info sig;
    struct event_list eventqueue;
    struct timeval event_tv;
    struct min_heap timeheap;
    struct timeval tv_cache;
};
```
<!--more-->

#添加事件

事件初始化完毕后，可以使用event_set设置事件，然后使用event_add将其加入。首先完成socket的监听，然后将其加入到事件队列中（这里对所有的异常都不做考虑）。

（1）socket监听
```
struct sockaddr_in listen_addr;

int port = 10000; //socket监听端口
int listen_fd = socket(AF_INET, SOCK_STREAM, 0);

memset(&listen_addr, 0, sizeof(listen_addr));

listen_addr.sin_family = AF_INET;
listen_addr.sin_addr.s_addr = INADDR_ANY;
listen_addr.sin_port = htons(port)

reuseaddr_on = 1;

/*支持端口复用*/
setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &reuseaddr_on, sizeof(reuseaddr_on));

bind(listen_fd, (struct sockaddr *) &listen_addr, sizeof(listen_addr));
listen(listen_fd, 1024);

/*将描述符设置为非阻塞*/
int flags = fcntl(listen_fd,F_GETFL);
flags |= O_NONBLOCK;
fcntl(listen_fd, F_SETFL, flags);
```
（2）事件设置

socket服务建立后，就可以进行事件设置。使用event_set来设置事件对象，其传入参数包括事件根基(event_base对象)，描述符，事件类型，事件发生时的回调函数，回调函数传入参数。其中事件类型包括EV_READ、EV_WRITE、EV_PERSIST，EV_PERSIST和前两者结合使用，表示该事件为持续事件。
```
struct event ev;

event_set(&ev, listen_fd, EV_READ | EV_PERSIST, accept_handle, (void *)&ev);
```
（3）事件添加与删除

事件设置好后，就可以将其加入事件队列。event_add用来将事件加入，它接受两个参数：要添加的事件和时间的超时值。如果需要将事件删除，可以使用event_del来完成。event_del函数会取消所指定的事件。
```
event_add(&ev, NULL)
```


#进入事件循环

libevent提供了多种方式来进入事件循环，常用的是event_dispatch和event_base_loop，前者最后实际是使用当前事件根基来调用event_base_loop。
```
event_base_loop(main_base, 0);
```


#处理连接

已经完成了事件的设置、事件的添加并进入到了事件循环，但是当事件发生时又如何处理呢？ 当连接建立时回调函数accept_handle会自动的得到调用。对于缓冲区的读写在非阻塞式网络编程中是一个难以处理的问题，幸运的是libevent提供了bufferevent和evbuf来替我们完成该项工作。这里我们采用bufferevent来处理。

（1）生成bufferevent对象

使用bufferevent_new对象来生成bufferevent对象，并分别指定读、写、连接错误时的处理函数和函数传入参数。

（2）设置读取量

bufferevent的读事件激活以后，即使用户没有读取完bufferevent缓冲区中的数据, bufferevent读事件也不会再次被激活。因为bufferevent的读事件是由其所监控的描述符的读事件激活的，只有描述符可读，读事件才会被激活。可通过设置wm_read.high来控制bufferevent从描述符缓冲区中读取的数据量。

（3）将事件加入事件队列

和前面一样，在事件设置好后，需将事件加入到事件队列中， 不过bufferevent的有自己专门的加入函数bufferevent_base_set和激活函数bufferevent_enable。bufferevent接收两个参数事件根基和事件对象，前者用来指定事件将加入到哪个事件根基中，后者说明需将那个bufferevnet事件加入。在bufferevent初始化完毕后，可以使用bufferevent_enable和bufferevent_disable反复的激活与禁止事件，其接收参数为事件对象和事件标志。其中标志参数为EV_READ和EV_WRITE。
```
void accept_handle(const int sfd, const short event, void *arg)
{
    struct sockaddr_in addr;

    socklen_t addrlen = sizeof(addr);

    int fd = accept(sfd, (struct sockaddr *) &addr, &addrlen); //处理连接

    buf_ev = bufferevent_new(fd,   buffered_on_read, NULL, NULL, fd)
    buf_ev->wm_read.high = 4096
    bufferevent_base_set(main_base, buf_ev);
    bufferevent_enable(buf_ev, EV_READ);
}
```


#读取缓冲区

当缓冲区读就绪时会自动激活前面注册的缓冲区读函数，我们可以使用bufferevent_read函数来读取缓冲区，bufferevent_read函数参数分别为:所需读取的事件缓冲区，读入数据的存放地，希望读取的字节数。函数返回实际读取的字节数。注意：即时缓冲区未读完，事件也不会再次被激活（除非再次有数据）。因此此处需反复读取直到全部读取完毕。



#写回客户端

bufferevent系列函数不但支持读取缓冲区，而且支持写缓冲区（即将结果返回给客户端）。
```
void buffered_on_read(struct bufferevent *bev, void * arg){
    char buffer[4096]

    ret = bufferevent_read(bev, &buffer, 4096);
    bufferevent_write(bef, (void *)&buffer, 4096);
}
```


#异步事件处理示例

利用libevent编写服务端程序，主要有4部分。
（1）创建主通知链base
```
base = event_base_new();
```
（2）创建要监听的事件，并将其加入到主通知链中。
```
listener_event = event_new(base, listener, EV_READ|EV_PERSIST, do_accept, (void*)base);
event_add(listener_event, NULL);
event_free( listener_event ); //释放由event_new申请的结构体
``` 
（3）主循环
```
event_base_dispatch(base);
```
（4）释放
```
event_base_free(base);
```
以下程序中do_read, do_write是异步的，为了解决了异步之间的问题，程序使用了state这个结构体变量将do_read和do_write联系起来。
```
    #include <netinet/in.h>
    #include <sys/socket.h>
    #include <event2/event.h>
    #include <assert.h>
    #include <unistd.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <errno.h>
    #include <fcntl.h>

    #define MAX_LINE 16384
    #define PORT 9999

    void do_read(evutil_socket_t fd, short events, void *arg);
    void do_write(evutil_socket_t fd, short events, void *arg);

    struct fd_state {
        char buffer[MAX_LINE];
        size_t buffer_used;

        size_t n_written;
        size_t write_upto;

        struct event *read_event;
        struct event *write_event;
    };

    struct fd_state *alloc_fd_state(struct event_base *base, evutil_socket_t fd)
    {
        struct fd_state *state =
         (struct fd_state *)malloc(sizeof(struct fd_state));
        if (!state) {
            return NULL;
        }

        state->read_event =
         event_new(base, fd, EV_READ | EV_PERSIST, do_read, state);
        if (!state->read_event) {
            free(state);
            return NULL;
        }

        state->write_event =
         event_new(base, fd, EV_WRITE | EV_PERSIST, do_write, state);
        if (!state->write_event) {
            event_free(state->read_event);
            free(state);
            return NULL;
        }

        assert(state->write_event);

        return state;
    }

    void free_fd_state(struct fd_state *state)
    {
        event_free(state->read_event);
        event_free(state->write_event);
        free(state);
    }

    void do_read(evutil_socket_t fd, short events, void *arg)
    {
        struct fd_state *state = arg;
        char buf[1024];
        int i;
        ssize_t result;
        while (1) {
            // assert(state->write_event);
            result = recv(fd, buf, sizeof(buf), 0);
            if (result <= 0)
                break;
            printf("[%s][%d]buf=[%s]len=[%d]\n", __FILE__, __LINE__, buf,
             result);
        }

        memcpy(state->buffer, "reply", sizeof("reply"));
        assert(state->write_event);
        event_add(state->write_event, NULL);
        state->write_upto = state->buffer_used;

        if (result == 0) {
            free_fd_state(state);
        } else if (result < 0) {
            if (errno == EAGAIN)    // XXXX use evutil macro
                return;
            perror("recv");
            free_fd_state(state);
        }
    }

    void do_write(evutil_socket_t fd, short events, void *arg)
    {
        struct fd_state *state = arg;

        //while (state->n_written < state->write_upto)
        {
            //ssize_t result = send(fd, state->buffer + state->n_written,
            //state->write_upto - state->n_written, 0);
            ssize_t result =
             send(fd, state->buffer, strlen(state->buffer), 0);
            if (result < 0) {
                if (errno == EAGAIN)    // XXX use evutil macro
                    return;
                free_fd_state(state);
                return;
            }
            assert(result != 0);
            state->n_written += result;
        }

        //if (state->n_written == state->buffer_used)
        {
            state->n_written = state->write_upto = state->buffer_used = 1;
        }

        event_del(state->write_event);
    }

    void do_accept(evutil_socket_t listener, short event, void *arg)
    {
        struct event_base *base = arg;
        struct sockaddr_storage ss;
        socklen_t slen = sizeof(ss);

        int fd = accept(listener, (struct sockaddr *)&ss, &slen);
        if (fd < 0) {        // XXXX eagain??
            perror("accept");
        } else if (fd > FD_SETSIZE) {
            close(fd);    // XXX replace all closes with EVUTIL_CLOSESOCKET */
        } else {
            struct fd_state *state;
            evutil_make_socket_nonblocking(fd);
            state = alloc_fd_state(base, fd);

            assert(state);    /*XXX err */
            assert(state->write_event);
            event_add(state->read_event, NULL);
        }
    }

    int main(int argc, char **argv)
    {
        evutil_socket_t listener;
        struct sockaddr_in sin;
        struct event_base *base;
        struct event *listener_event;

        setvbuf(stdout, NULL, _IONBF, 0);
        
        base = event_base_new();
        if (!base)
            return -1;        /*XXXerr */

        sin.sin_family = AF_INET;
        sin.sin_addr.s_addr = 0;
        sin.sin_port = htons(PORT);

        listener = socket(AF_INET, SOCK_STREAM, 0);
        evutil_make_socket_nonblocking(listener);

    #ifndef WIN32
        {
            int one = 1;
            setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &one,
                 sizeof(one));
        }
    #endif

        if (bind(listener, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
            perror("bind");
            return -1;
        }

        if (listen(listener, 16) < 0) {
            perror("listen");
            return -1;
        }

        listener_event =
         event_new(base, listener, EV_READ | EV_PERSIST, do_accept,
             (void *)base);
        /*XXX check it */
        event_add(listener_event, NULL);
        event_base_dispatch(base);
        event_base_free(base);

        return 0;
    }
```