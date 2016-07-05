---
layout: post
title: "Scrapy入门简略教程（二）"
date: 2014-06-15 13:44
comments: true
categories: [网络爬虫]
tags: []
keywords: 
description: 
---
#What just happened under the hood?

Scrapy为爬虫中的`start_urls`属性中每个URL创建了一个`scrapy.http.Request`对象 ，并把`parse`方法作为回调函数指定给爬虫。

这些`Request`会被调度，执行，`scrapy.http.Response`对象被返回，结果也被反馈给爬虫，之后通过`parse()`方法解析。


#Extracting Items

##Introduction to Selectors

有很多方法从网站中提取数据。Scrapy使用一种叫做Scrapy Selectors的机制，它基于XPath或者是CSS表达式。如果想了解更多selectors和其它机制，可查阅[Selectors documentation](http://doc.scrapy.org/en/latest/topics/selectors.html#topics-selectors)。

以下是XPath表达式的例子和它们的含义：

- `/html/head/title`: 选择HTML文档`<head>`元素下面的`<title>`标签。
- `/html/head/title/text()`: 选择前面提到的`<title>`元素下面的文本内容。
- `//td`: 选择所有 `<td>`元素。
- `//div[@class="mine"]`: 选择所有包含`class="mine"`属性的`div`标签元素。

这只是几个使用XPath的简单例子，但是实际上XPath非常强大。如果你想了解更多XPATH的内容，我们向你推荐这个[XPath教程](http://www.w3schools.com/XPath/default.asp)。

为了方便使用XPaths，Scrapy提供XPath`Selector`类， 有两种方式可以选择，`HtmlResponse`(HTML数据解析) 和`XmlResponse`(XML数据解析)。 

使用XPath选择器，Scrapy提供了一个`Selector`类，它实例化一个`Htmlresponse`或`Xmlresponse`对象作为第一个参数。

你可以看到selectors作为对象表示在文档结构节点。所以，第一个实例化selectors是与根节点相关联，或整个文档。

Selectors有四种基本方法（具体的使用请查看API文档）：

- `path()`：返回selectors列表, 每一个select表示一个xpath参数表达式选择的节点。
- `css()`: 返回selectors列表, 每一个select表示一个CSS参数表达式选择的节点。
- `extract()`：返回一个unicode字符串，该字符串为XPath选择器返回的数据。
- `re()`： 返回unicode字符串列表，字符串作为参数由正则表达式提取出来。

<!--more-->

##Trying Selectors in the Shell

为了演示Selectors的用法，我们将用到内建的Scrapy shell，这需要系统已经安装IPython (一个扩展的python交互环境)。

要开始shell，必须进入项目顶层目录，然后输入：
```
scrapy shell "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/"
```
shell会输入以下的类似信息：
```
[ ... Scrapy log here ... ]

2014-01-23 17:11:42-0400 [default] DEBUG: Crawled (200) <GET http://www.dmoz.org/Computers/Programming/Languages/Python/Books/> (referer: None)
[s] Available Scrapy objects:
[s]   crawler    <scrapy.crawler.Crawler object at 0x3636b50>
[s]   item       {}
[s]   request    <GET http://www.dmoz.org/Computers/Programming/Languages/Python/Books/>
[s]   response   <200 http://www.dmoz.org/Computers/Programming/Languages/Python/Books/>
[s]   sel        <Selector xpath=None data=u'<html>\r\n<head>\r\n<meta http-equiv="Conten'>
[s]   settings   <CrawlerSettings module=None>
[s]   spider     <Spider 'default' at 0x3cebf50>
[s] Useful shortcuts:
[s]   shelp()           Shell help (print this help)
[s]   fetch(req_or_url) Fetch request (or URL) and update local objects
[s]   view(response)    View response in a browser

In [1]:
```

Shell加载完毕后，将获得回应，这些内容被存储在本地变量`response`中，所以如果你输入`response.body`将会看到response的body部分，或者输入`response.headers`来查看它的header部分。

Shell通过变量`sel`为这个response提前初始化一个selector，这个selector基于response的类型自动选择最佳的解析规则（XML或者HTML）。

我们来看看里面有什么：

```
In [1]: sel.xpath('//title')
Out[1]: [<Selector xpath='//title' data=u'<title>Open Directory - Computers: Progr'>]

In [2]: sel.xpath('//title').extract()
Out[2]: [u'<title>Open Directory - Computers: Programming: Languages: Python: Books</title>']

In [3]: sel.xpath('//title/text()')
Out[3]: [<Selector xpath='//title/text()' data=u'Open Directory - Computers: Programming:'>]

In [4]: sel.xpath('//title/text()').extract()
Out[4]: [u'Open Directory - Computers: Programming: Languages: Python: Books']

In [5]: sel.xpath('//title/text()').re('(\w+):')
Out[5]: [u'Computers', u'Programming', u'Languages', u'Python']
```

##Extracting the data

现在我们尝试从网页中提取一些真正的数据。

你可以在控制台输入`response.body`，检查源代码中的`XPaths`是否与预期相同。然而，检查HTML源代码是件很枯燥的事情。为了使事情变得简单，我们使用类似Firebug的Firefox扩展插件。更多信息请查看[Using Firebug for scraping](http://doc.scrapy.org/en/latest/topics/firebug.html#topics-firebug)和[Using Firefox for scraping](http://doc.scrapy.org/en/latest/topics/firefox.html#topics-firefox)。

检查源代码后，你会发现我们需要的数据在`<ul>`元素中，事实上是第二个`<ul>`。

我们可以通过如下命令选出每个站点中的`<li>`元素: 

```
sel.xpath('//ul/li')
```
站点的描述信息：
```
sel.xpath('//ul/li/text()').extract()
```
站点的标题：
```
sel.xpath('//ul/li/a/text()').extract()
```
站点的链接：
```
sel.xpath('//ul/li/a/@href').extract()
```
正如我们前面说的那样，每一个`.xpath`会返回一个selectors的列表，所以我们可以结合`.xpath()`去挖掘更深的节点。我们将会用到这些特性，所以:
```
sites = sel.xpath('//ul/li')
for site in sites:
    title = site.xpath('a/text()').extract()
    link = site.xpath('a/@href').extract()
    desc = site.xpath('text()').extract()
    print title, link, desc
```
我们把这些代码添加到爬虫中：
```
from scrapy.spider import Spider
from scrapy.selector import Selector

class DmozSpider(Spider):
    name = "dmoz"
    allowed_domains = ["dmoz.org"]
    start_urls = [
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/",
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"
    ]

    def parse(self, response):
        sel = Selector(response)
        sites = sel.xpath('//ul/li')
        for site in sites:
            title = site.xpath('a/text()').extract()
            link = site.xpath('a/@href').extract()
            desc = site.xpath('text()').extract()
            print title, link, desc
```
我们通过scrapy.selector将Selector类导入及初始化一个Selector实例。现在可以指定我们的XPaths，如在shell中做的那样。我们尝试重新抓取dmoz.org站点，你将会在你的输出平台看到站点的一些信息，输入如下的命令：
```
scrapy crawl dmoz
```

##Using our item

Item对象是用户自定义的python字典，你可以获取它们每个字段的值(即之前定义的类的属性)，它使用了标准的字典语法，如下所示:
```
>>> item = DmozItem()
>>> item['title'] = 'Example title'
>>> item['title']
'Example title'
```
Spiders希望将其抓取的数据存放到`Item`对象中。为了返回我们抓取的数据，Spider的最终代码应当是这样:
```
from scrapy.spider import Spider
from scrapy.selector import Selector

from tutorial.items import DmozItem

class DmozSpider(Spider):
    name = "dmoz"
    allowed_domains = ["dmoz.org"]
    start_urls = [
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/",
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"
    ]

    def parse(self, response):
        sel = Selector(response)
        sites = sel.xpath('//ul/li')
        items = []
        for site in sites:
            item = DmozItem()
            item['title'] = site.xpath('a/text()').extract()
            item['link'] = site.xpath('a/@href').extract()
            item['desc'] = site.xpath('text()').extract()
            items.append(item)
        return items
```
再次抓取dmoz.org站点的信息：
```
[dmoz] DEBUG: Scraped from <200 http://www.dmoz.org/Computers/Programming/Languages/Python/Books/>
     {'desc': [u' - By David Mertz; Addison Wesley. Book in progress, full text, ASCII format. Asks for feedback. [author website, Gnosis Software, Inc.\n],
      'link': [u'http://gnosis.cx/TPiP/'],
      'title': [u'Text Processing in Python']}
[dmoz] DEBUG: Scraped from <200 http://www.dmoz.org/Computers/Programming/Languages/Python/Books/>
     {'desc': [u' - By Sean McGrath; Prentice Hall PTR, 2000, ISBN 0130211192, has CD-ROM. Methods to build XML applications fast, Python tutorial, DOM and SAX, new Pyxie open source XML processing library. [Prentice Hall PTR]\n'],
      'link': [u'http://www.informit.com/store/product.aspx?isbn=0130211192'],
      'title': [u'XML Processing with Python']}
```

#Storing the scraped data

保存抓取的信息的最简单方法就是使用[Feed exports](http://doc.scrapy.org/en/latest/topics/feed-exports.html#topics-feed-exports)，使用如下的命令：
```
scrapy crawl dmoz -o items.json -t json
```
所有抓取的items将以JSON格式被保存在新生成的`items.json`文件中。

在小型的项目中（如这个教程中的例子），这些已经足够。然而，如果你想用抓取的items做更复杂的事情，你可以写一个[Item Pipeline](http://doc.scrapy.org/en/latest/topics/item-pipeline.html#topics-item-pipeline)(条目管道)。在项目创建的时候，一个专门用于条目管道的占位符文件随着items一起被建立，在`tutorial/pipelines.py`中。如果你只需要存取这些抓取后的items的话，就不需要去实现任何的条目管道。


<big>注：</big>整个Scrapy的入门教程写得比较杂乱，包含了翻译部分和自己写的测试小例。

<td></td>
<big>参考文章</big>

[Scrapy at a glance](http://doc.scrapy.org/en/latest/intro/overview.html)       
[Scrapy入门教程](http://www.cnblogs.com/txw1958/archive/2012/07/16/scrapy-tutorial.html)  
[聚焦爬虫：定向抓取系统的实现方法](http://www.biaodianfu.com/mplementation-of-targeted-crawling-system.html)  
[开源python网络爬虫框架Scrapy](http://lujiesky.blog.51cto.com/332319/1328176)  
[使用scrapy进行大规模抓取(一)](http://www.yakergong.net/blog/archives/500)  
[Python网络爬虫（12）：爬虫框架Scrapy的第一个爬虫示例入门教程](http://blog.csdn.net/pleasecallmewhy/article/details/19642329)  
[快速构建实时抓取集群](http://www.searchtb.com/2011/07/%E5%BF%AB%E9%80%9F%E6%9E%84%E5%BB%BA%E5%AE%9E%E6%97%B6%E6%8A%93%E5%8F%96%E9%9B%86%E7%BE%A4.html?spm=0.0.0.0.oD8o9v)   
[python爬虫框架scrapy实例详解](http://www.pythontab.com/html/2013/pythonhexinbiancheng_0814/541.html)   
[Scrapy 轻松定制网络爬虫](http://blog.pluskid.org/?p=366)   
[Scrapinghub](https://github.com/scrapinghub)  
[使用python，scrapy写（定制）爬虫的经验，资料，杂](http://www.kankanews.com/ICkengine/archives/94817.shtml)  