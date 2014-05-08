---
layout: post
title: "运行Scrapy项目出错：KeyError: 'Spider not found: tutorial'"
date: 2014-04-27 22:40
comments: true
categories: [网络爬虫]
---

运行Scrapy抓取网上数据的时候，出现了以下的错误：
```
$ sudo scrapy crawl tutorial
Traceback (most recent call last):
  File "/usr/local/bin/scrapy", line 4, in <module>
    execute()
  File "/usr/local/lib/python2.7/dist-packages/scrapy/cmdline.py", line 143, in execute
    _run_print_help(parser, _run_command, cmd, args, opts)
  File "/usr/local/lib/python2.7/dist-packages/scrapy/cmdline.py", line 89, in _run_print_help
    func(*a, **kw)
  File "/usr/local/lib/python2.7/dist-packages/scrapy/cmdline.py", line 150, in _run_command
    cmd.run(args, opts)
  File "/usr/local/lib/python2.7/dist-packages/scrapy/commands/crawl.py", line 48, in run
    spider = crawler.spiders.create(spname, **opts.spargs)
  File "/usr/local/lib/python2.7/dist-packages/scrapy/spidermanager.py", line 44, in create
    raise KeyError("Spider not found: %s" % spider_name)
KeyError: 'Spider not found: tutorial'
```
<!--more-->
查看`tutorial/spiders/dmoz_spider.py`文件中的内容如下：
```
$ cat tutorial/spiders/dmoz_spider.py
from scrapy.spider import BaseSpider

class DmozSpider(BaseSpider):
    name = "dmoz"
    allowed_domains = ["s.taobao.com"]
    start_urls = [
        "http://s.taobao.com/search?q=%E6%A0%B8%E6%A1%83"
    ]

    def parse(self, response):
        filename = response.url.split("/")[-2]
        open(filename, 'wb').write(response.body)
```

`name = "dmoz"`中的`dmoz`才是crawler的名字。修改crawler的名字后，正常运行如下：
```
$ sudo scrapy crawl dmoz
2014-04-27 22:50:09+0800 [scrapy] INFO: Scrapy 0.20.0 started (bot: tutorial)
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Optional features available: ssl, http11
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Overridden settings: {'NEWSPIDER_MODULE': 'tutorial.spiders', 'SPIDER_MODULES': ['tutorial.spiders'], 'BOT_NAME': 'tutorial'}
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Enabled extensions: LogStats, TelnetConsole, CloseSpider, WebService, CoreStats, SpiderState
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Enabled downloader middlewares: HttpAuthMiddleware, DownloadTimeoutMiddleware, UserAgentMiddleware, RetryMiddleware, DefaultHeadersMiddleware, MetaRefreshMiddleware, HttpCompressionMiddleware, RedirectMiddleware, CookiesMiddleware, ChunkedTransferMiddleware, DownloaderStats
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Enabled spider middlewares: HttpErrorMiddleware, OffsiteMiddleware, RefererMiddleware, UrlLengthMiddleware, DepthMiddleware
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Enabled item pipelines: 
2014-04-27 22:50:09+0800 [dmoz] INFO: Spider opened
2014-04-27 22:50:09+0800 [dmoz] INFO: Crawled 0 pages (at 0 pages/min), scraped 0 items (at 0 items/min)
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Telnet console listening on 0.0.0.0:6023
2014-04-27 22:50:09+0800 [scrapy] DEBUG: Web service listening on 0.0.0.0:6080
2014-04-27 22:50:10+0800 [dmoz] DEBUG: Crawled (200) <GET http://s.taobao.com/search?q=%E6%A0%B8%E6%A1%83> (referer: None)
2014-04-27 22:50:10+0800 [dmoz] INFO: Closing spider (finished)
2014-04-27 22:50:10+0800 [dmoz] INFO: Dumping Scrapy stats:
	{'downloader/request_bytes': 245,
	 'downloader/request_count': 1,
	 'downloader/request_method_count/GET': 1,
	 'downloader/response_bytes': 35012,
	 'downloader/response_count': 1,
	 'downloader/response_status_count/200': 1,
	 'finish_reason': 'finished',
	 'finish_time': datetime.datetime(2014, 4, 27, 14, 50, 10, 637578),
	 'log_count/DEBUG': 7,
	 'log_count/INFO': 3,
	 'response_received_count': 1,
	 'scheduler/dequeued': 1,
	 'scheduler/dequeued/memory': 1,
	 'scheduler/enqueued': 1,
	 'scheduler/enqueued/memory': 1,
	 'start_time': datetime.datetime(2014, 4, 27, 14, 50, 9, 940145)}
2014-04-27 22:50:10+0800 [dmoz] INFO: Spider closed (finished)
```

<big>参考文章：</big>  

[运行Scrapy项目结果出错：KeyError: ‘Spider not found: manta’](http://www.crifan.com/python_run_scrapy_keyerror_spider_not_found/)  
[折腾Scrapy的Tutorial](http://www.crifan.com/try_scrapy_tutorial/)  
[Scrapy spider not found error](http://stackoverflow.com/questions/9876793/scrapy-spider-not-found-error)  