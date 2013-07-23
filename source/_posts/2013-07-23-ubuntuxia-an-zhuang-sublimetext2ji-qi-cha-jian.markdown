---
layout: post
title: "Ubuntu下安装SublimeText2及其插件"
date: 2013-07-23 22:33
comments: true
categories: [IDE, Unix/Linux]
---

Sublime Text 2是一个轻量、简洁、高效、跨平台的编辑器，方便的配色以及兼容vim快捷键等各种优点博得了很多前端开发人员的喜爱。Sublime Text 2基本上是共享软件，免费版和收费版基本无区别，只是偶尔会弹框让你去购买，这个基本不影响使用。


#软件安装

Ubuntu下安装Sublime Text 2有两种方式：指令安装和直接下载安装。

##指令安装
```
$ sudo add-apt-repository ppa:webupd8team/sublime-text-2
$ sudo apt-get update
$ sudo apt-get install sublime-text-2
```
<!--more-->

##直接下载安装

从 [这里](http://www.sublimetext.com/2)下载所需要的版本，然后解压文件到安装目录。
```
$ sudo tar -jxvf Sublime\ Text\ 2.0.1.tar.bz2 -C /usr/local/
```


#在applications菜单中创建快捷方式

```
$ sudo gedit /usr/share/applications/sublimetext.desktop 

[Desktop Entry]
Encoding=UTF-8
Name=Sublime Text
Comment=Sublime Text
Exec=/usr/local/SublimeText/sublime_text
Icon=/usr/local/SublimeText/Icon/48x48/sublime_text.png
Terminal=false
StartupNotify=true
Type=Application
Categories=Application;Development;
```


#安装插件

安装Sublime text 2插件也有两种方法：直接安装和使用Package Control组件安装。

##直接安装

可以直接下载安装包解压缩到Packages目录（菜单->preferences->packages）。


##使用Package Control组件安装

也可以先安装package control组件，然后直接在线安装：

+ 按Ctrl + `调出console ，其中`是键盘左上角那个符号。
+ 粘贴以下代码到底部命令行并回车。
``` 
import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print 'Please restart Sublime Text to finish installation'
```
+ 重启Sublime Text 2。
+ 如果在Perferences->package settings中看到package control这一项，则安装成功。 如果这种方法不能安装成功，可以到 [这里](http://wbond.net/sublime_packages/package_control/installation) 下载文件手动安装。

用Package Control安装插件的方法：a、按下`Ctrl+Shift+P`调出命令面板；b、输入`install`调出Install Package选项并回车，然后在列表中选中要安装的插件。 