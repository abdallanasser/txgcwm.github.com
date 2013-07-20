---
layout: post
title: "将Emacs配置成一个C/C++的IDE编程环境"
date: 2013-07-20 14:47
comments: true
categories: 
---
在Linux环境下编程，首先要选择开发工具，大部分程序员都是使用VIM和EMACS这两大神器。虽说它们只是编辑器，但由于其超强的可定制性，已成为广大linux工作者的首选。使用`sudo apt-get install emacs`来安装Emaces。


#Emacs的基本操作和组合键
##模式键定义

四个模式键：C---Ctrl；M---Alt；s---Super(Win)；S---Shift

比如：

C-x：表示按下ctrl键，然后按下x键。

C-x c C-c：表示按下ctrl，然后按下x键，松开后再按下c键。

C-x k：表示按下ctrl，同时按下x和k键。
<!--more-->

##基本组合键

C-x C-c：退出Emacs。

C-x C-s：保存当前buffer。

C-x C-f：打开和新建文件。

C-n：光标移到下一行。

C-p：光标移到上一行。

C-k：删除一行。

M-x：执行命令。


#启动时的大小和屏幕中的位置

关于修改Emacs启动大小和屏幕中的位置有两种方法：1、修该~/.Xdefault文件，然后运行`xrdb ~/.Xdefault`；2、在~/.emacs文件中进行修改。按照第二种方法作如下设置：
```
;;设置启动的大小和屏幕中的位置
(setq default-frame-alist
	'((height . 35)(width . 100)(menubar-lines . 20)(tool-bar-lines . 0)))
```
以上语句表示Emacs在启动后其高度为35，宽度为100，显示在屏幕的x=20，y=0处。


#Emacs的基本常规设定

按照一般的习惯，.emacs文件中一般不会放太多的设置信息，一般放一些emacs的搜索路径信息。这里将emacs的配置文件（即lisp脚本）都放在~/.emacs.d/emacs的文件夹中。因此首先添加一个emacs的搜索路径：
```
;;;; 添加Emacs搜索路径
(add-to-list 'load-path "~/.emacs.d/emacs")
(add-to-list 'load-path "~/.emacs.d/emacs/ecb-2.40")
(add-to-list 'load-path "~/.emacs.d/emacs/codepilot")
(add-to-list 'load-path "~/.emacs.d/emacs/emacs-eclim")
(add-to-list 'load-path "~/.emacs.d/emacs/icicles")
(add-to-list 'load-path "~/.emacs.d/emacs/gnuserv")
```
然后加载我们对emacs的设置脚本，在.emacs中添加如下语句：
```
;;;;读取脚本
(load "base.el")
(load "cyexpand.el")
(load "cykbd.el")
(load "addon.el")

;;编程的配置
(load "cycode.el")
```
对emacs的基本设置，即base.el文件（在~/.emacs.d/emacs中），base.el文件中的部分内容如下：
```
;;显示时间
;;(display-time)
(display-time-mode 1);;启用时间显示设置，在minibuffer上面的那个杠上
(setq display-time-24hr-format t);;时间使用24小时制
(setq display-time-day-and-date t);;时间显示包括日期和具体时间
;;(setq display-time-use-mail-icon t);;时间栏旁边启用邮件设置
;;(setq display-time-interval 10);;时间的变化频率，单位多少来着？


;;显示列号
(setq column-number-mode t)
;;没列左边显示行号,按f3显示/隐藏行号
(require 'setnu)
(setnu-mode t)
;;(global-set-key[f3] (quote setnu-mode))

;;显示标题栏 %f 缓冲区完整路径 %p 页面百分数 %l 行号
(setq frame-title-format "%f")

;;=======================================================================
;;缓冲区
;;=====================================================================
;;设定行距
(setq default-line-spaceing 4)
;;页宽
(setq default-fill-column 60)
;;缺省模式 text-mode
;;(setq default-major-mode 'text-mode)
;;设置删除记录
(setq kill-ring-max 200)
;;以空行结束
;;(setq require-final-newline t)
;;开启语法高亮。
(global-font-lock-mode 1)
;;高亮显示区域选择
(transient-mark-mode t)
;;页面平滑滚动,scroll-margin 3 靠近屏幕边沿3行开始滚动，正好可以看到上下文
;;(setq scroll-margin 3 scroll-consrvatively 10000)
;;高亮显示成对括号
(show-paren-mode t)
(setq show-paren-style 'parentheses)
;;鼠标指针避光标
(mouse-avoidance-mode 'animate)
;;粘贴于光标处,而不是鼠标指针处
(setq mouse-yank-at-point t)
```
设置默认工作目录，即启动emacs后所在的目录，在base.el中加上下面一句：
```
;;设置默认工作目录
(setq default-directory "/srv") 
```

#C/C++的配置

C/C++的配置主要是cycode.el文件。开发时很重要的一步就是调试，所以首先就是增加图形化调试界面：
```
;;==============================================================
;;gdb-UI配置
;;==============================================================
(setq gdb-many-windows t)
(load-library "multi-gud.el")
(load-library "multi-gdb-ui.el")
```
上面加载了两个lisp的脚本文件，这两个文件是直接在网上下载的图形化调试文件。

为了能高效的浏览和编辑代码，需要安装cedet插件。从官网下载cedet后，在~/.emacs.d/emacs目录中解压，根据解压出来文件夹中的INSTALL文件说明的方法安装cedet即可。有一点需要注意就是安装完成后不能删除安装后的文件，也就是需要保留解压后的文件夹。安装完成后，用下面的语句将我们需要的一些东西包含进来。
```
;;==================================================
;;cedet插件设置
;;==================================================
(add-to-list 'load-path "~/.emacs.d/emacs/cedet-1.1/speedbar")
(add-to-list 'load-path "~/.emacs.d/emacs/cedet-1.1/eieio")
(add-to-list 'load-path "~/.emacs.d/emacs/cedet-1.1/semantic")
```
然后就可进行有关cedet的设置，这里仅以一个代码折叠和展开为例：
```
;;代码折叠
;;(require 'semantic-tag-folding nil 'noerror)
(global-semantic-tag-folding-mode 1)
;;折叠和打开整个buffer的所有代码
(define-key semantic-tag-folding-mode-map (kbd "C--") 'semantic-tag-folding-fold-all)
(define-key semantic-tag-folding-mode-map (kbd "C-=") 'semantic-tag-folding-show-all)
;;折叠和打开单个buffer的所有代码
(define-key semantic-tag-folding-mode-map (kbd "C-_") 'semantic-tag-folding-fold-block)
(define-key semantic-tag-folding-mode-map (kbd "C-+") 'semantic-tag-folding-show-block)
```

为了使用更方便（即对上面cedet插件的一个补充），需要再安装一个ecb插件。下载ecb后解压到~/.emacs.d/emacs目录中即可，然后加上下面两句：
```
;;==============================================================
;;ecb配置
;;==============================================================
;;(require 'ecb)
;;开启ecb用,M-x:ecb-activate
(require 'ecb-autoloads)
;;自动启动ecb并且不显示每日提示
;;(require 'ecb)
;;(setq ecb-auto-activate t)
(setq ecb-tip-of-the-day nil)
```
为了实现自动补全功能，需要安装auto-complete和yasnippet这两个插件。auto-complete下载后放到~/.emacs.d/emacs目录中解压，然后进入解压后的目录输入make命令即可；yasnippet下载后解压到~/.emacs.d/emacs目录中即可。下面是关于这两个插件的配置：
```
;;==========================================================
;;YASnippet的配置
;;==========================================================
(require 'yasnippet)    ;;not yasnippet-bundle
(yas/initialize)
(yas/load-directory "~/.emacs.d/emacs/yasnippet-0.6.1c/snippets")
```
装完插件后，作一些综合的配置：
```
;;配置Semantic搜索范围
(setq semanticdb-project-roots
	  (list
	   (expand-file-name "/")))
;;自定义补全命令，如果单词在中间就补全，否则就tab
(defun my-indent-or-complete()
  (interactive)
  (if (looking-at "\\>")
	  (hippie-expand nil)
	  (indent-for-tab-command))
  )
;;补全快捷键，ctrl+tab用senator补全，不显示列表
;;alt+/补全，显示列表让选择
(global-set-key [(control tab)] 'my-indent-or-complete)
(define-key c-mode-base-map [(meta ?/)] 'semantic-ia-complete-symbol-menu)
(autoload 'senator-try-expand-semantic "senator")
(setq hippie-expand-try-functions-list
	  '(
		senator-try-expand-semantic
		try-expand-dabbrev
		try-expand-dabbrev-visible
		try-expand-dabbrev-all-buffers
		try-expand-dabbrev-from-kill
		try-expand-list
		try-expand-list-all-buffers
		try-expand-line
		try-expand-line-all-buffers
		try-complete-file-name-partially
		try-complete-file-name
		try-expand-whole-kill
		)
	  )
```


#键绑定

为了使用emacs更方便，需要一些键绑定（即自己定义一些组合键），这也是emacs配置中必不可少的一步。自定义组合键放在cykbd.el文件中。根据一般的习惯用f1来表示帮助，即man命令：
```
(global-set-key [f1] 'manual-entry)
(global-set-key [C-f1] 'info )
```
f3-f5的一些绑定：
```
;;f3为查找字符串,alt+f3关闭当前缓冲区
(global-set-key [f3] 'grep-find)
(global-set-key [M-f3] 'kill-this-buffer)

;;.emacs中设一个speedbar的快捷键
(global-set-key [(f4)] 'speedbar-get-focus)
;;ctrl-f4,激活,ecb
(global-set-key [C-f4] 'ecb-activate)

;;F5显示/隐藏工具栏 方便调试
(global-set-key [f5] 'tool-bar-mode)
;;ctrl-F5显示/隐藏菜单栏 ;; M-x menu-bar-open
(global-set-key [C-f5] 'menu-bar-mode)
```
f6为gdb调试，f7调用make来对原文件进行编译：
```
(global-set-key [f6] 'gdb)

;;  C-f7, 设置编译命令; f7, 保存所有文件然后编译当前窗口文件
(defun du-onekey-compile ()
  "Save buffers and start compile"
  (interactive)
  (save-some-buffers t)
  (switch-to-buffer-other-window "*compilation*")
  (compile compile-command))
  
(setq-default compile-command "make")    
(global-set-key [C-f7] 'compile)
 (global-set-key [f7] 'du-onekey-compile)
```

将f8为对buffer的一些常用操作：
```
;;目的是开一个shell的小buffer，用于更方便地测试程序(也就是运行程序了)，我经常会用到。
;;f8就是另开一个buffer然后打开shell，C-f8则是在当前的buffer打开shell,shift+f8清空eshell
(defun open-eshell-other-buffer ()
  "Open eshell in other buffer"
  (interactive)
  (split-window-vertically)
  (eshell))
(defun my-eshell-clear-buffer ()
  "Eshell clear buffer."
  (interactive)
  (let ((eshell-buffer-maximum-lines 0))
    (eshell-truncate-buffer)))
(global-set-key [(f8)] 'open-eshell-other-buffer)
(global-set-key [C-f8] 'eshell)
(global-set-key [S-f8] 'my-eshell-clear-buffer)
```
f9-f11的一些绑定：
```
;;设置[C-f9]为调用dired命令
(global-set-key [C-f9] 'dired)
(global-set-key [f9] 'other-window);f9在其他窗口之间旋转

;;设置F10为撤销
(global-set-key [C-f10] 'undo)

;;设置F11快捷键指定Emacs 的日历系统
(global-set-key [C-f11] 'calendar) 
```
用f12查看函数定义：
```
;;设置C-F12 快速察看日程安排
;;F12调到函数定义
(global-set-key [f12] 'semantic-ia-fast-jump)
(global-set-key [C-f12] 'list-bookmarks)
;;shift-f12跳回去
(global-set-key [S-f12]
	(lambda ()
	(interactive)
	(if (ring-empty-p (oref semantic-mru-bookmark-ring ring))
	(error "Semantic Bookmark ring is currently empty"))
	(let* ((ring (oref semantic-mru-bookmark-ring ring))
	(alist (semantic-mrub-ring-to-assoc-list ring))
	(first (cdr (car alist))))
	(if (semantic-equivalent-tag-p (oref first tag)
	(semantic-current-tag))
	(setq frist (cdr (car (cdr alist)))))
	(semantic-mrub-switch-tags first))))
```
对ecb的键绑定：
```
;;==================ecb的配置=================================
;;为了ecb窗口的切换
(global-set-key [M-left] 'windmove-left)
(global-set-key [M-right] 'windmove-right)
(global-set-key [M-up] 'windmove-up)
(global-set-key [M-down] 'windmove-down)
;;隐藏和显示ecb窗口
(global-set-key [f11] 'ecb-hide-ecb-windows)
(global-set-key [S-f11] 'ecb-show-ecb-windows)
```
对窗口的一些键绑定：
```
;;关闭当前窗口,alt+4
(global-set-key (kbd "M-4") 'delete-window)
;;(global-set-key (kbd "M-4") 'kill-this-buffer)
;;关闭其他窗口,alt+1
(global-set-key (kbd "M-1") 'delete-other-windows)
;;水平分割窗口,alt+2
(global-set-key (kbd "M-2") 'split-window-vertically)
;;垂直分割窗口,alt+3
(global-set-key (kbd "M-3") 'split-window-horizontally)
;;切换到其他窗口，alt+0
(global-set-key (kbd "M-0") 'other-window)
;;显示缓冲区完整名称
(global-set-key (kbd "M-5") 'display-buffer-name)
```

#Emacs的扩展配置

为了使emacs更符合个人的习惯，增加了一个cyexpand.el配置文件，其部分设置如下：
```
;; 编码设置
(require 'coding-settings)

;; `mode-line'显示格式
(require 'mode-line-settings)

;; 各种语言开发方面的设置,这个设置牵涉到太多配置....
(require 'dev-settings)


;; 显示行号
(require 'linum-settings)

;; color theme Emacs主题,很多face文件
(require 'color-theme-settings)

(require 'ahei-face)
(require 'color-theme-ahei)
(require 'face-settings)

;; 高亮当前行
(require 'hl-line-settings)

;; 字体配置
(require 'font-settings)
;; diff
(require 'diff-settings)
;; Emacs的diff: ediff,有个my-fontest-win的文件很关键
(require 'ediff-settings)

;; 在buffer中方便的查找字符串: color-moccur
(require 'moccur-settings)
;; Emacs超强的增量搜索Isearch配置
(require 'isearch-settings)

;; 增加更丰富的高亮
(require 'generic-x)

;; spell check
(setq-default ispell-program-name "aspell")

;; Emacs中的包管理器
(require 'package)
(package-initialize)

;; 在Emacs里面使用shell
(require 'term-settings)
(require 'multi-term-settings)

;; 可以把光标由方块变成一个小长条
(require 'bar-cursor)
```

到此为止，已经将emacs打造成了开发C/C++的简易IDE。在使用过程中只需要会配置base.el、cycode.el、cykbd.el、cyexpand.el这四个文件即可，相关配置文件和插件可以到 [这里]（https://github.com/txgcwm/emacs.d）下载。