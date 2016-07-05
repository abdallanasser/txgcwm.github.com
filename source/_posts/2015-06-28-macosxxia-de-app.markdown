---
layout: post
title: "Mac OS X下的App"
date: 2015-06-28 00:16
comments: true
categories: [MAC OS X札记]
tags: []
keywords: 
description: 
---
#基本常识

平常接触的大部分 App其实是一个文件夹结构，只不过Mac OS X 让它看起来是一个单独的文件而已。通过右键点击一个 App，在菜单中选择 Show Contents，则可以浏览 App 的内部结构。

- _CodeSignature、CodeResources，一般为 Mac App Store 上架程序所包含，里面含有数字签名，以防止非法篡改。

- Frameworks，一般放置了此程序所使用的第三方 Framework (使用的 Apple Framework 都包含在你的系统里)，那些支持 Growl 提醒的程序，在这个文件夹下必然包含一个 Growl Framework。某种程度上，可以理解为 Windows 程序中的 dll 动态链接库。

- Info.plist，包含了一个程序的基本信息（比如最低系统版本要求、版本号、Copyright等等标识），也可能包含程序的类型信息（比如这个文件如果含有一个 LSUIElement 并且值为 TRUE 的片段，则这个程序在执行后，不会在 Dock 上显示图标或图标下有表示此程序正在运行的小亮点。当然，通过修改一个程序的 plist，添加 LSUIElement，则可以让一个程序运行时不在 Dock 上显示图标）。plist 是一个标准的 XML 文档，可以用任何文本编辑器修改。MacOS 文件夹则是包含了此应用程序的真正可执行文件（类似 Windows 下的 exe 文件），当然一些程序可能包含不只一个可执行文件。PkgInfo 是一个可选的8个字节长度的文件，可保存程序类型和创建者签名（当然这些可以写在 Info.plist 中），这个文件通常包含四字节的程序类型信息（通常为 APPL）和四个字节的签名信息（比如 System Preferences.app 的 PkgInfo 就是 APPLsprf）。
     
- Resources，顾名思义，就是资源文件，包含图标、图片、语言包以及其它各种文件，这个没有严格的限制。

<!--more-->
#安装方式

安装方式常见的有：一、拖拽一个 App 文件到 Applications 文件夹完成安装；二、后缀为 .pkg 文件是通过 Mac OS X Installer 解开 pkg 文件，按照 pkg 文件中的 BOM 文件的指令将 pkg 文件中的内容安装到系统不同的位置上去；三、.mpkg 格式的安装文件和 .pkg 安装文件过程类似，只不过 .mpkg 指向的是一组 .pkg 文件的组合而已；四、通过 MacPorts 的终端安装。


#App 的卸载

安装程序之前，要仔细阅读程序提供者的资料或者 App 的说明文档，这些文档中，一般都会含有如何卸载 App 的指南。很多程序（比如 Adobe Creative Suite，Microsoft Office）都会带有相应的卸载程序。XCode 这类，则会提供一个终端命令。

通过 Google 搜索，一般都可以找到如何卸载程序的方法。关键字很简单 Mac OS X ****(应用程序名) Uninstall / Remove，一般都会找到你想要的答案。

通过第三方的卸载软件，比如 Clean My Mac、AppZapper (光枪)，都可以做到准完美卸载。

通过手动使用终端 find 命令，或者系统内置的 spotlight 搜索应用程序名，找到相关文件删除进行卸载。注意观察一个 App 的运行方式，记住一些 App 常用的路径名称，可以帮助你完美卸载一个程序。


#Mac OS X App 常用的文件夹

/Applications，这个不必多说，99% 的应用程序在下载后都会有一个直接提示让你拖拽 App 到 /Applications 文件夹。其实这个不是强制的位置，大部分 App 可以在任何权限适合的文件夹下运行。

~/Library/，用来存放用户偏好设置、App 偏好设置、缓存、App 数据文件等。

~/Library/Preferences/，这个文件夹下是各个程序的偏好设置文件和数据记录文件。卸载一个 App 时，这里一般都会有一个以上的相关 plist 文件，这些 plist 文件一般以 com.***(应用程序提供商).***(应用程序名称).plist 的格式出现，所以按照应用程序名称或者提供商名称，可以很容易的找到应用程序遗留文件。

~/Library/LaunchAgents/ ，此文件夹一般存放一些应用程序的附加程序（比如 Folx 能够感知 Safari 下载动作，1Password 能够感知登录输入密码动作），都是靠这里的 plist 文件来配置。

~Library/Application\ Support/，一般用来存放跟应用程序相关的支持数据、应用程序的附加程序（比如 Helper 程序、插件等等）、应用程序的备份文件 （比如 MacJournal 的所有日志备份文件等），一般都是跟应用程序（或者开发商）同名的文件夹。

~Library/Internet\ Plug-Ins/，用来放置与 Safari 有关的 App 插件。

~/Library/Contextual\ Menu\ Items/，用来放置一个 App向系统添加上下文菜单（右键菜单）。

~/Library/Input\ Methods/， 是此用户安装的输入法程序。

~/Library/PreferencePanes/，所有第三方的系统偏好设置安装在这里。

~/Library/Services/，很多程序会向右键或者服务菜单添加项目，则它们会把菜单项拷贝到这里。

~/Library/Widgets/，安装过的 Dashboard Widget 小应用都会在这里找到。

~/Library/Receipts/，很多应用程序在安装后会在这里留下 Receipt 存根或者 BOM 文件，对于帮助完整卸载 App 很有帮助。一部分 ~/Library 下介绍过的文件夹在 /Library 下都能够找到相对应的目录，区别在于 /Library表示全局级别的配置，换句话说，同样的配置从 ~/Library 拷贝到 /Library 相应的文件夹下则会影响这个 App 在所有用户中的运行状态、运行方式。当然，/Library 下有 ~/Library 下不存在的文件夹，也需要注意：/Library/LaunchDaemons 文件夹的作用与/Library/LaunchAgents/ （~/Library/LaunchAgents/）类似，只不过LaunchAgents 一般代表了有用户界面的后台自动运行程序，而 Daemons 则代表了那些没有用户界面的后台运行程序。但一定要注意，/Library 下的所有更改将会波及所有用户，必须非常小心，否则会造成难以预料的后果。

/System/Library，是系统级别应用程序配置、数据的所在地，除非特别明白每一个项目的作用，否则不要进行任何修改，一旦误操作，将会对系统产生致命后果。

大部分符合 Apple 应用程序规范的 App，基本都会在上述文件夹中的某一些内部留下痕迹，所以只要牢记这些文件夹以及每个文件夹的作用，手工完全清除 App 是非常方便且安全的。