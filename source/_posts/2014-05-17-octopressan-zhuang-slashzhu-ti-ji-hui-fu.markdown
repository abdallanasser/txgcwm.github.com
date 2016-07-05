---
layout: post
title: "Octopress安装Slash主题及恢复"
date: 2014-05-17 16:14
comments: true
categories: [Octopress]
---
输入以下的指令，就能立马体验Slash。
```
$ cd octopress
$ git clone git://github.com/tommy351/Octopress-Theme-Slash.git .themes/slash
$ rake install['slash']
$ rake generate
```

安装完之后，我就后悔了，虽然主题看起来更好看，可没有之前使用的那般便利，幸好我没有直接将它上传到`github`上，只是执行`rake preview`指令提前在本机上运行了一下。不过还是有遗憾的，一些配置因安装新的主题被覆盖了，所以在安装之前提前备份是非常有必要的工作。

新的主题安装在`.themes`目录下，可以看到新安装的主题，也能看到`Octopress`默认的主题`classic`。
```
$ ls .themes/
classic  slash
```

<!--more-->
既然不喜欢，就得恢复到原来的主题，使用以下的指令即可。
```
$ rake install['classic']
$ rake generate
```

今天查阅资料最大的收获是知道了`Octopress生成静态文件后直接发布`的命令：
```
$ rake gen_deploy
```

<big>参考文章</big>   

[Octopress-Theme-Slash](http://zespia.tw/Octopress-Theme-Slash/index_tw.html)  
[技术博客利器——Octopress](http://fancyoung.com/blog/octopress-study/)  