---
layout: post
title: "RobotsBrain: log输出"
date: 2014-07-10 22:09
comments: true
categories: [RobotsBrain]
tags: []
keywords: 
description: 
---
在构建一个库的时候，通常会写专门的log输出函数，下面介绍一个简单的实现。根据不同的需求，需要对日志的输出作一个级别限定，便于查阅及跟踪流程。以下是对级别的设置：
```
typedef enum log_level_en {
	RB_LOG_MIN,
	RB_LOG_DEBUG,
	RB_LOG_INFO,
	RB_LOG_NOTICE,
	RB_LOG_WARNING,
	RB_LOG_ERROR,
	RB_LOG_CRIT,
	RB_LOG_ALERT,
	RB_LOG_EMERG,
	RB_LOG_MAX
}log_level;
```

该部分参考内核的级别设定，不同的是数值越低其信息的重要程度越低。

具体的日志输出，我们采用了宏定义的方式，因为考虑到要输出`__FUNCTION__`等信息，其具体的实现如下所示：
```
#define RB_LOG(level, fmt, args...)	\
	do {	\
		if(rb_log_check_level(level) == 0)	\
			break;	\
		char rb_log_buf[RB_LOG_BUFFER_LEN] = {0};	\
		snprintf(rb_log_buf, RB_LOG_BUFFER_LEN, "pid(%d) %s %s(%d)", \
					getpid(), __FILE__, __FUNCTION__, __LINE__);	\
		rb_log_printf(level, rb_log_buf, fmt, ##args);	\
	} while(0)
```

每个级别输出的宏定义如下：
```
#define RB_DEBUG(fmt, args...)	RB_LOG(RB_LOG_DEBUG, fmt, ##args)

#define RB_INFO(fmt, args...)	RB_LOG(RB_LOG_INFO, fmt, ##args)

#define RB_NOTICE(fmt, args...)	RB_LOG(RB_LOG_NOTICE, fmt, ##args)
	
#define RB_WARNING(fmt, args...)	RB_LOG(RB_LOG_WARNING, fmt, ##args)

#define RB_ERROR(fmt, args...)	RB_LOG(RB_LOG_ERROR, fmt, ##args)

#define RB_CRIT(fmt, args...)	RB_LOG(RB_LOG_CRIT, fmt, ##args)

#define RB_ALERT(fmt, args...)	RB_LOG(RB_LOG_ALERT, fmt, ##args)

#define RB_EMERG(fmt, args...)	RB_LOG(RB_LOG_EMERG, fmt, ##args)
```

<!--more-->
初始化函数，用于设置输出文件的名称和输出级别的设定：如果`log_file`设置成`NULL`的话，则直接将信息打印到`stderr`；`level`的值设置的越小，它输出的信息越多:
```
void rb_log_init(const char *log_file, log_level level);
```

释放分配的资源，如果调用了`rb_log_init`就必须调用以下的接口:
```
void rb_log_uninit(void);
```

检测是否要打印信息:
```
int rb_log_check_level(log_level level);
```

日志输出:
```
void rb_log_printf(log_level level, const char *prefix, const char *fmt, ...);
```

当然我们也可以直接调用`RB_DEBUG`等接口，这样的话，log信息直接输出到`stderr`。具体的代码及测试用例，请参考[这里](https://github.com/RobotsBrain/robrain/tree/master/src)。