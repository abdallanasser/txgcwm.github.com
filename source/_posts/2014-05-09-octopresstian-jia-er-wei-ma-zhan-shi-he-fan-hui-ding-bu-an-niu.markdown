---
layout: post
title: "Octopress添加二维码展示和返回顶部按钮"
date: 2014-05-09 22:37
comments: true
categories: [Octopress]
---
#二维码展示

在关于页面或边栏可以展示个人博客的二维码，方便移动终端扫描访问，插件主页点击[这里](https://github.com/sailor79/Octopress-dynamic-QR-Code-aside)。
```
<section>
	<h1>QR-Code<abbr title="The word 'QR Code' is a registered trademark of DENSO WAVE INCORPORATED. It applies only for the word 'QR Code', not for image.">&trade;</abbr></h1>
	<a href="{{ site.url }}{{ page.url }}"><img src="http://chart.apis.google.com/chart?chs=180x180&cht=qr&chld=|0&chco=165B94&chl={{ site.url }}{{ page.url }}" alt="post-qrcode"></a>
</section>
```
在侧边栏显示，则将`qrcode.html`放入`source/_includes/custom/asides/`中，在`_config.yml`中`default_asides`添加`custom/asides/qrcode.html`即可显示。或者将`qrcode.html`代码添加到想展示页面的HTML文件中。

<!--more-->

#滑动返回顶部按钮

文章较长的情况，通常希望有一个返回顶部的按钮。如下方法实现了在页面右下方添加一个返回顶部的图片按钮，点击后可以滑动的返回顶部。

##方法一

首先创建`source/javascripts/top.js`，实现滑动返回顶部效果，添加如下代码：
```
function goTop(acceleration, time) {
	acceleration = acceleration || 0.1;
	time = time || 16;

	var x1 = 0;
	var y1 = 0;
	var x2 = 0;
	var y2 = 0;
	var x3 = 0;
	var y3 = 0;

	if (document.documentElement) {
		x1 = document.documentElement.scrollLeft || 0;
		y1 = document.documentElement.scrollTop || 0;
	}

	if (document.body) {
		x2 = document.body.scrollLeft || 0;
		y2 = document.body.scrollTop || 0;
	}

	var x3 = window.scrollX || 0;
	var y3 = window.scrollY || 0;

	var x = Math.max(x1, Math.max(x2, x3));
	var y = Math.max(y1, Math.max(y2, y3));

	var speed = 1 + acceleration;
	window.scrollTo(Math.floor(x / speed), Math.floor(y / speed));

	if(x > 0 || y > 0) {
		var invokeFunction = "goTop(" + acceleration + ", " + time + ")";
		window.setTimeout(invokeFunction, time);
	}
}
```

接着创建`source/_includes/custom/totop.html`，设置返回顶部按钮样式和位置，代码如下：
```
<!--返回顶部开始-->
<div id="full" style="width:0px; height:0px; position:fixed; right:180px; bottom:150px; z-index:100; text-align:center; background-color:transparent; cursor:pointer;">
	<a href="#" onclick="goTop();return false;"><img src="/images/top.png" border=0 alt="返回顶部"></a>
</div>
<script src="/javascripts/top.js" type="text/javascript"></script>
<!--返回顶部结束-->
```

然后还需要将返回顶部的图片放入`source/images`，命名为`top.png`，或修改`totop.html`中的图片路径。

最后还需要在`source/_layouts/default.html`中添加`{ % include custom/totop.html % }`（这个在很多教程里都没有提到，对于一个不懂前端的人摸索了好久才整出来）。

##方法二

对于方式一，滑动按钮一直存在着，在顶部的时候看着也不爽，所以使用了另外的一种方式。相关的HTML代码很简单，在`source/_include/custom/footer.html`中添加如下代码：

```
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>

<script type="text/javascript">
$(document).ready(function(){

	// hide #back-top first
	$("#back-top").hide();
	
	// fade in #back-top
	$(function () {
		$(window).scroll(function () {
			if ($(this).scrollTop() > 100) {
				$('#back-top').fadeIn();
			} else {
				$('#back-top').fadeOut();
			}
		});

		// scroll body to 0px on click
		$('#back-top a').click(function () {
			$('body,html').animate({
				scrollTop: 0
			}, 800);
			return false;
		});
	});

});
</script>

<style type="text/css">
#back-top {
	position: fixed;
	bottom: 50px;
	right: 100px;
}

#back-top a {
	width: 80px;
	display: block;
	text-align: center;
	font: 11px/100% Arial, Helvetica, sans-serif;
	text-transform: uppercase;
	text-decoration: none;
	color: #bbb;

	/* transition */
	-webkit-transition: 1s;
	-moz-transition: 1s;
	transition: 1s;
}
#back-top a:hover {
	color: #000;
}

/* arrow icon (span tag) */
#back-top span {
	width: 80px;
	height: 80px;
	display: block;
	margin-bottom: 7px;
	background: #ddd url(/images/top.png) no-repeat center center;

	/* rounded corners */
	-webkit-border-radius: 15px;
	-moz-border-radius: 15px;
	border-radius: 15px;

	/* transition */
	-webkit-transition: 1s;
	-moz-transition: 1s;
	transition: 1s;
}
#back-top a:hover span {
	background-color: #888;
}
</style>

<p id="back-top">
	<a href="#top"><span></span></a>
</p>

<p>
  Copyright &copy; {{ site.time | date: "%Y" }} - {{ site.author }} -
  <span class="credit">Powered by <a href="http://octopress.org">Octopress</a></span>
</p>
```


#参考文章

[Octopress主题样式修改](http://blog.csdn.net/lcliliil/article/details/13727007)  
[用 JavaScript 实现变速回到顶部](http://www.neoease.com/javascript-go-top/)  
[jQuery 跟随浏览器窗口的回到顶部按钮](http://www.neoease.com/fixed-go-top-button-to-browser-window-with-jquery/)  
[给Octpress博客添加返回顶部按钮](http://ibillxia.github.io/blog/2013/06/30/add-a-back-to-top-button-on-ur-octpress-blog/)  
[Animated Scroll to Top](http://webdesignerwall.com/tutorials/animated-scroll-to-top)  