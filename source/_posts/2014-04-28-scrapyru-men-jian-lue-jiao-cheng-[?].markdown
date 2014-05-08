---
layout: post
title: "Scrapy入门简略教程（一）"
date: 2014-04-28 23:04
comments: true
categories: [网络爬虫]
---
在本教程中，将假设Scrapy已经安装在你的系统上。如果不是，请参见官方的安装指南。我将使用我自己的例子来介绍，主要完成以下任务：

1. 创建一个新的Scrapy项目；
2. 定义你将提取的Items；
3. 写一个蜘蛛抓取网站并提取Items；
4. 写一个项目管道存储所提取的Items。

Scrapy是用Python编写的，如果不了解的话，需要去学习一下，从项目上入手的话，应该学起来比较的快。


#创建一个项目

在开始之前，需要在你的目录下创建一个项目，执行以下命令即可：
```
$ scrapy startproject shiyifang
```

在当前的目录下就会生成一个叫`shiyifang`的文件夹，它包含以下一些文件和目录：
```
$ tree
.
├── scrapy.cfg
└── shiyifang
    ├── __init__.py
    ├── items.py
    ├── pipelines.py
    ├── settings.py
    └── spiders
        └── __init__.py

2 directories, 6 files
```

关于该目录下文件和文件夹的说明：

- scrapy.cfg: 项目的配置文件。
- shiyifang/: 项目的python模块，后续会将代码放入这个目录。
- shiyifang/items.py: 项目的items文件。
- shiyifang/pipelines.py: 项目的pipelines文件。
- shiyifang/settings.py: 项目的settings文件。
- shiyifang/spiders/: 存放爬虫程序的目录。

<!--more-->

#定义Item

Items包含了将要被抓取的数据，它们就像简单的Python dicts，但对未填充字段提供额外的保护，以防止错误。在shiyifang目录下编辑items.py文件，Item类看起来像如下的样子：
```
from scrapy.item import Item, Field

class ShiyifangItem(Item):
    # define the fields for your item here like:
    # name = Field()
    title = Field()
    link = Field()
    desc = Field()
```

#第一个爬虫

爬虫是用户自己写的一个类，用于爬取一个或一组域名的数据，需要定义一个初始化的URL列表，要完成如何抓取链接和如何去解析数据等基本的工作。我们在shiyifang/spiders目录下创建一个叫shiyifang_spider.py文件：
```
from scrapy.spider import BaseSpider

class ShiyifangSpider(BaseSpider):
    name = "shiyifang"
    allowed_domains = ["s.taobao.com"]
    start_urls = [
        "http://s.taobao.com/search?q=%E6%A0%B8%E6%A1%83"
    ]

    def parse(self, response):
        filename = response.url.split("/")[-2]
        open(filename, 'wb').write(response.body)
```

#Crawling

到项目的顶层目录，执行以下的指令：
```
$ scrapy crawl shiyifang
2014-04-28 23:01:34+0800 [scrapy] INFO: Scrapy 0.20.0 started (bot: shiyifang)
2014-04-28 23:01:34+0800 [scrapy] DEBUG: Optional features available: ssl, http11
2014-04-28 23:01:34+0800 [scrapy] DEBUG: Overridden settings: {'NEWSPIDER_MODULE': 'shiyifang.spiders', 'SPIDER_MODULES': ['shiyifang.spiders'], 'BOT_NAME': 'shiyifang'}
2014-04-28 23:01:35+0800 [scrapy] DEBUG: Enabled extensions: LogStats, TelnetConsole, CloseSpider, WebService, CoreStats, SpiderState
2014-04-28 23:01:35+0800 [scrapy] DEBUG: Enabled downloader middlewares: HttpAuthMiddleware, DownloadTimeoutMiddleware, UserAgentMiddleware, RetryMiddleware, DefaultHeadersMiddleware, MetaRefreshMiddleware, HttpCompressionMiddleware, RedirectMiddleware, CookiesMiddleware, ChunkedTransferMiddleware, DownloaderStats
2014-04-28 23:01:35+0800 [scrapy] DEBUG: Enabled spider middlewares: HttpErrorMiddleware, OffsiteMiddleware, RefererMiddleware, UrlLengthMiddleware, DepthMiddleware
2014-04-28 23:01:35+0800 [scrapy] DEBUG: Enabled item pipelines: 
2014-04-28 23:01:35+0800 [shiyifang] INFO: Spider opened
2014-04-28 23:01:35+0800 [shiyifang] INFO: Crawled 0 pages (at 0 pages/min), scraped 0 items (at 0 items/min)
2014-04-28 23:01:35+0800 [scrapy] DEBUG: Telnet console listening on 0.0.0.0:6023
2014-04-28 23:01:35+0800 [scrapy] DEBUG: Web service listening on 0.0.0.0:6080
2014-04-28 23:01:36+0800 [shiyifang] DEBUG: Crawled (200) <GET http://s.taobao.com/search?q=%E6%A0%B8%E6%A1%83> (referer: None)
2014-04-28 23:01:36+0800 [shiyifang] INFO: Closing spider (finished)
2014-04-28 23:01:36+0800 [shiyifang] INFO: Dumping Scrapy stats:
	{'downloader/request_bytes': 245,
	 'downloader/request_count': 1,
	 'downloader/request_method_count/GET': 1,
	 'downloader/response_bytes': 34569,
	 'downloader/response_count': 1,
	 'downloader/response_status_count/200': 1,
	 'finish_reason': 'finished',
	 'finish_time': datetime.datetime(2014, 4, 28, 15, 1, 36, 232914),
	 'log_count/DEBUG': 7,
	 'log_count/INFO': 3,
	 'response_received_count': 1,
	 'scheduler/dequeued': 1,
	 'scheduler/dequeued/memory': 1,
	 'scheduler/enqueued': 1,
	 'scheduler/enqueued/memory': 1,
	 'start_time': datetime.datetime(2014, 4, 28, 15, 1, 35, 615729)}
2014-04-28 23:01:36+0800 [shiyifang] INFO: Spider closed (finished)
```
从debug信息可以看出，我们发送的get请求是收到回复的，且是成功的。此时，在当前目录下你会看到一个叫s.taobao.com的文件生成，这就是我们抓取到的网页。

<big>参考文章</big>   

[Scrapy Tutorial](http://doc.scrapy.org/en/latest/intro/tutorial.html)  
[Scrapy 轻松定制网络爬虫](http://blog.pluskid.org/?p=366)  