---
layout: post
title: "Ubuntu上安装LaTeX"
date: 2013-08-07 00:53
comments: true
categories: [Unix/Linux]
---
LaTeX（音译“拉泰赫”）是一种基于TeX的排版系统，由美国计算机学家莱斯利·兰伯特（Leslie Lamport）在20世纪80年代初期开发，利用这种格式，即使使用者没有排版和程序设计的知识也可以充分发挥由TeX所提供的强大功能，能在几天甚至几小时内生成很多具有书籍质量的印刷品。

可以在Ubuntu安装很多LaTeX的分发版，其中一个是TeX Live，使用下面的命令可以在Ubuntu上安装Tex Live（软件有好几百M，需要慢慢等待）。
```
$ sudo apt-get install texlive-full
```
要编辑LaTeX文档需要一个编辑器，你可以找到很多编辑器，这里推荐使用Texmaker。
```    
$ sudo apt-get install texmaker
``` 
<!--more-->

`apt-cache search cjk`找到相关宏包安装：
```
sudo apt-get install cjk-latex latex-cjk-chinese
```
安装喜欢的中文字体：
```
sudo apt-get install xfonts-wqy ttf-wqy-microhei ttf-wqy-zenhei
```
安装英文字体：
```
$ apt-cache search 'courier new'
ttf-mscorefonts-installer - Installer for Microsoft TrueType core fonts

$ sudo apt-get install ttf-mscorefonts-installer
```
需要更新字体缓存：
```
$ fc-cache
```
为了使整个系统下的用户的字体列缓存都更新，建议使用root权限执行:
```
$ sudo fc-cache -f -s -v
```
使用fc-list查看可用的字体：
```
$ fc-list
```
或者只查看中文的字体：
```
$ fc-list ：lang=zh
```
如果能看到想要的中文字体，就可以了。

新增一个test.tex名字的文件，内容如下：
```
% dependencies: xelatex, xecjk package，Courier New字体，wenquanyi中文字体，也可以设置其他的中英文字体
% Usage: xelatex filename[.tex]

\documentclass[11pt]{article}
\usepackage{xeCJK}
\setmainfont{Courier New} % 设置英文衬线字体
% \setmonofont{} % 设置英文等宽字体，等宽英文字体大全：http://zh.wikipedia.org/wiki/%E7%AD%89%E5%AE%BD%E5%AD%97%E4%BD%93
% \setsansfont{} % 设置英文无衬线字体
\setCJKmainfont{WenQuanYi Micro Hei} % 设置缺省中文字体
%\setCJKfamilyfont{WenQuanYi Micro Hei} % 与setCJKmainfon t等同，http://bbs.ctex.org/forum.php?mod=viewthread&tid=51057
\parindent 2em   %段首缩进
 
\begin{document}
\section{举例}
\begin{verbatim}
标点。
\end{verbatim}
 
汉字Chinese数学$x=y$空格
\end{document}
```
再用xelatex编译，就可以生成pdf文档了。
```
$ xelatex filename.tex
```

<big>参考文章</big>   

[ku10.04下 tevlive-xetex 、texmaker 、ctex宏包 安装成功](http://forum.ubuntu.org.cn/viewtopic.php?t=274400)   
[natty narwahl 源安装 texlive2009 及 中文配置教程总结](http://forum.ubuntu.com.cn/viewtopic.php?f=35&t=331555)   
[LaTeX技巧345：modernCV-xelatex中文支持简历](http://blog.sina.com.cn/s/blog_5e16f1770100lgs5.html)   
[LaTeX Resume Templates](http://linuxandfriends.com/latex-resume-templates/)   
[xelatex+xeCJK在ubuntu Linux中显示中文](http://www.cnblogs.com/bamboo-talking/archive/2013/01/07/2848914.html)   
[LaTeX中文排版（使用XeTeX）](http://linux-wiki.cn/wiki/zh-hans/LaTeX%E4%B8%AD%E6%96%87%E6%8E%92%E7%89%88%EF%BC%88%E4%BD%BF%E7%94%A8XeTeX%EF%BC%89)   
[用 org-mode 写 LaTeX](http://mathslinux.org/?p=58)   
[在 Ubuntu 上安装 LaTeX](http://www.oschina.net/question/12_63776)   
[LaTeX使用--XeLaTeX入门基础（一）](http://blog.csdn.net/yming0221/article/details/7616846)   