---
layout: post
title: "Linux下PDF文件的操作与转换"
date: 2013-07-07 11:21
comments: true
categories: [Shell, Unix/Linux]
keywords:
---
在Linux中常常涉及到多种文档格式（如doc、txt、html、rtf等等），为了方便文件传递，就可能需要在各种格式之间进行转换。下面介绍几个命令行下的工具，用于将pdf文件转换成其它我们需要的文件格式。

#Pdftk

如果说PDF是电子纸张，那么pdftk就是电子起钉器、打孔机、粘合剂、解密指环和X光镜片。pdftk是一个简单的工具，可以对PDF文档进行各种日常操作，让你简单而自由地操作PDF。它不需要Acrobat，并且可以运行在Linux,Windows,Mac OS X,FreeBSD和Solaris上。在Debian/Ubuntu中你可以通过apt安装pdftk:

    $ sudo aptitude install pdftk

<!--more-->

将两个或更多个PDF合并成一个新文档：

    $ pdftk 1.pdf 2.pdf 3.pdf cat output 123.pdf

或者使用句柄:

    $ pdftk A=1.pdf B=2.pdf cat A B output 12.pdf

或者使用通配符:

    $ pdftk *.pdf cat output combined.pdf

将多个PDF中选定的页面分离出来并形成一个新文档：

    $ pdftk A=one.pdf B=two.pdf cat A1-7 B1-5 A8 output combined.pdf

将PDF的第一页顺时针旋转90度：

    $ pdftk in.pdf cat 1E 2-end output out.pdf

将整个PDF文档的页面旋转180度：

    $ pdftk in.pdf cat 1-endS output out.pdf

用128位强度（默认）对一个PDF进行加密，保留所有权利（默认）：

    $ pdftk mydoc.pdf output mydoc.128.pdf owner_pw foopass

同上，唯一例外的是需要密码才能打开这个PDF：

    $ pdftk mydoc.pdf output mydoc.128.pdf owner_pw foo user_pw baz

同上，例外的是允许打印(在PDF被打开以后)：

    $ pdftk mydoc.pdf output mydoc.128.pdf owner_pw foo user_pw baz allow printing

加密一个PDF：

    $ pdftk secured.pdf input_pw foopass output unsecured.pdf

合并两个文件，其中一个是加密的 (输出是不加密的)：

    $ pdftk A=secured.pdf mydoc.pdf input_pw A=foopass cat output combined.pdf

解压PDF页面流，以便可以在文本编辑器中编辑PDF代码：

    $ pdftk mydoc.pdf output mydoc.clear.pdf uncompress

修复一个PDF被破坏的XREF表和流长度 (如果可能的话)：

    $ pdftk broken.pdf output fixed.pdf

将单个PDF文档拆分成一个个页面，并且将相关数据报告到doc_data.txt：

    $ pdftk mydoc.pdf burst

报告PDF文档的元数据、书签和页面标签：

    $ pdftk mydoc.pdf dump_data output report.txt


#Poppler

Poppler是一个基于xpdf-3.0代码基础的PDF渲染库。 Poppler-utils软件包包括了pdftops (PDF到PostScript的转换器), pdfinfo (PDF文档信息提取器), pdfimages (PDF图像提取器), pdftohtml (PDF到HTML的转换器), pdftotext (PDF到text的转换器), 以及pdffonts (PDF字体分析器)。Debian/Ubuntu用户可以通过apt安装poppler:

    $ sudo aptitude install poppler-utils

将可移植文档格式(PDF)文件转换成纯文本：

    $ pdftotext example.pdf example.txt

如果文本文件未指定, pdftotext将file.pdf转换成file.txt。如果文本文件是?-’，则文本会被送到标准输出。

转换第3到7页(包括3和7)使用:

    $ pdftotext -f 3 -l 7 example.pdf example.txt

只提取第3页：

    $ pdftotext -f 3 -l 3 example.pdf example.txt

下面的命令可以维持原始的物理布局并按阅读顺序输出文本。如果不想插入页面分隔符你可以设置-nopgbrk选项。如果PDF文件有密码保护，可以设置-opw (拥有者密码)或者-upw (用户密码)选项。

    $ pdftotext -layout example.pdf example.txt

pdftohtml是一个将pdf文档转换成html的程序，它在当前工作目录中产生输出。pdf文件转换成html:

    $ pdftohtml file.pdf file.html

如果你想要看到图形，需要使用-c(也就是“complex”) 选项:

    $ pdftohtml -c file.pdf file.html
 
    
#Pdfimages

Pdfimages从可移植文档格式(PDF)文件中提取图片，保存为可移植像素图(PPM), 可移植位图(PBM), 或者JPEG文件。Pdfimages读取PDF文件，扫描一个或多个页面，并将每一个图像写入一个名为image-root-nnn.xxx的PPM、PBM或者JPEG文件，其中nnn是图像编号，xxx是图像类型(.ppm, .pbm, .jpg)。Pdfimages从PDF文件提取原始图像数据，不做任何额外的变化。任何PDF内容流里的旋转，剪切，颜色反转等动作都被忽略。

从example.pdf提取所有的图像，图像会被保存为PPM格式：

    $ pfdimages example.pdf exampleimage

使用-j选项将图像保存为JPG格式：

    $ pfdimages -j example.pdf exampleimage

使用-f和-l选项制定起始页和结束页。为了扫描第3至7页(包括3和7)使用：

    $ pfdimages -f 3 -l 7 example.pdf exampleimage

只扫描指定的某一页使用:

    $ pfdimages -f 3 -l 3 example.pdf exampleimage

如果PDF文件有密码保护使用-opw和-upw选项:
-opw 拥有者密码
-upw 用户密码


#ImageMagick

如果要将PDF转换到图像，首先你的机器上必须已经安装ImageMagick。要在Debian/Ubuntu上安装ImageMagick可以运行下面的命令：

    $ sudo aptitude install imagemagick

要将pdf文件转换成图像使用‘convert‘命令:

    $ convert doc.pdf doc.jpeg

转换成tiff

    $ convert doc.pdf doc.tiff
