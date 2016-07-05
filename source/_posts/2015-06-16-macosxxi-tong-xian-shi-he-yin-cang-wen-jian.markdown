---
layout: post
title: "MAC OS X系统显示和隐藏文件"
date: 2015-06-16 01:02
comments: true
categories: [MAC OS X札记]
tags: []
keywords: 
description: 
---
苹果Mac OS X操作系统下，隐藏文件是否显示有很多种设置方法，最简单的要算在Mac终端输入命令。

显示Mac隐藏文件的命令：
```
defaults write com.apple.finder AppleShowAllFiles -bool true
```

隐藏Mac隐藏文件的命令：
```
defaults write com.apple.finder AppleShowAllFiles -bool false
```

或者

显示Mac隐藏文件的命令：
```
defaults write com.apple.finder AppleShowAllFiles  YES
```

隐藏Mac隐藏文件的命令：
```
defaults write com.apple.finder AppleShowAllFiles  NO
```
<!--more-->
输完单击Enter键，退出终端，重新启动Finder就可以。

重启Finder：
```
鼠标单击窗口左上角的苹果标志-->强制退出-->Finder-->重新启动
```

但是对于熟悉Unix的码农来说，直接输入以下命令就好。
```
$ ls -a
```