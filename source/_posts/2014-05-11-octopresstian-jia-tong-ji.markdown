---
layout: post
title: "Octopress添加统计"
date: 2014-05-11 01:00
comments: true
categories: [Octopress]
---
Octopress模板里面默认带了Google Analytics工具，只需要注册Google Analytics， 获得一个`google_analytics_tracking_id`，添加到`_config.yml`中对应位置，并对网站进行验证即可，这样就可以通过Google Analytics分析网站的流量了，而且可以使用Google站长工具对网站进行更全面的分析，进行SEO。

对自己的网站进行验证，只需将网站提供的用于验证的代码添加到`source/_includes/head.html`的`head`标签之间（注意：如果该文件已有`{ % include google_analytics.html % }`这句，那么这步就不需要了），网站部署到网上后，过几分钟即可验证通过，其它需要验证的也同样操作。

除了Google的统计工具，还有就是国内使用很广的CNZZ了，注册后添加并验证你的网站就可以添加统计代码了，选好自己喜欢的样式获得代码，可添加到`source/_includes/custom/footer.html`中，即可查看每天博客的流量，进行相应的优化了。

百度站长工具和百度统计的使用方法和CNZZ类似 ，统计代码也可以添加到`source/_includes/custom/footer.html`中。

<big>参考文章</big>  

[Octopress添加统计与SEO](http://blog.csdn.net/lcliliil/article/details/13727927)  
[使用Google Analytics统计工具](http://blog.dofa.org/blog/2014/03/10/add-statistics-for-octopress/)  