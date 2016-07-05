---
layout: post
title: "Linux shell图形界面dialog"
date: 2015-07-11 01:03
comments: true
categories: [Shell]
tags: []
keywords: 
description: 
---
`Liunx`下的`dialog`是一个可以创建对话框的工具，每个对话框提供的输出有两种形式：1、将所有输出到`stderr`，不显示到屏幕；2、使用退出状态码，`OK`为0，`NO`为1，`ESC`为255。


#通用选项（`common options`）

这个选项用来设置`dialog box`的背景、颜色和标题等。

`--title <title>`：指定将在对话框的上方显示的标题字符串。   
`--colors`：解读嵌入式`\ Z`的对话框中的特殊文本序列，序列由下面的字符`0-7`, `b`，`B`, `u`, `U`等组成，恢复正常的设置使用`\Zn`。              
`--no-shadow`：禁止阴影出现在每个对话框的底部。   
`--shadow`：出现阴影效果。    
`--insecure`：输入部件的密码时，使用星号来代表每个字符。     
`--no-cancel`：设置在输入框、菜单和复选框中不显示`cancel`项。   
`--clear`：完成清屏操作，在框体显示结束后，清除框体，这个参数只能单独使用，不能和别的参数联合使用。   
`--ok-label <str>`：覆盖使用`OK`按钮标签，换做其它字符。  
`--cancel-label <str>`：功能同上。  
`--backtitle <backtitle>`：指定的`backtitle`字符串显示在背景顶端。    
`--begin <y> <x>`：指定对话框左上角在屏幕上的坐标。    
`--timeout <secs>`：超时（返回的错误代码），如果用户在指定的时间内没有给出相应动作，就按超时处理。   
`--defaultno`：使的是默认值`yes/no`，使用`no`。   
`--sleep <secs>`   
`--stderr`：以标准错误方式输出。   
`--stdout`：以标准方式输出。   
`--default-item <str>`：设置在一份清单、表格或菜单中的默认项目，通常在框中的第一项是默认的。   

<!--more-->
#窗体类型：

常见的对话框控件选项如下所示：

`--calendar`：提供了一个日历，让你可以选择日期。   
`--checklist`：允许你显示一个选项列表，每个选项都可以被单独的选择(复选框)。   
`--from`：允许建立一个带标签的文本字段，并要求填写。   
`--fselect`：提供一个路径，让你选择浏览的文件。   
`--gauge`：显示一个表，呈现出完成的百分比，就是显示出进度。   
`--infobox`：显示消息后，（没有等待响应）对话框立刻返回，但不清除屏幕(信息框)。   
`--inputbox`：让用户输入文本(输入框)。   
`--inputmenu`：提供一个可供用户编辑的菜单（可编辑的菜单框）。   
`--menu`：显示一个列表供用户选择(菜单框)。   
`--msgbox`：显示一条消息，并要求用户选择一个确定按钮(消息框)。   
`--pause`：显示一个表格用来显示一个指定的暂停期的状态。   
`--passwordbox`：显示一个输入框，它隐藏文本。         
`--passwordfrom`：显示一个来源于标签并且隐藏的文本字段。   
`--radiolist`：提供一个菜单项目组，只有一个项目，可以选择(单选框)。   
`--tailbox`：在一个滚动窗口文件中使用`tail`命令来显示文本。     
`--tailboxbg`：跟`tailbox`类似，但是在`background`模式下操作。   
`--textbox`：在带有滚动条的文本框中显示文件的内容(文本框)。   
`--timebox`：提供一个窗口，选择小时、分钟、秒。   
`--yesno`：提供一个带有`yes`和`no`按钮的简单信息框(是/否框)。   


#命令示例

##消息框

格式：
```
dialog --msgbox text height width
```
例子：
```
$ dialog --title TESTING --msgbox "this is a test" 10 20
```
 
##yesno框

格式：
```
dialog --yesno text height width
```

例子：
```
$ dialog --title "yes/no" --no-shadow --yesno "Delete the file /tmp/canjian.txt?" 10 30
```
 
##输入框
格式：
```
dialog --inputbox text height width
```
例子：
```
$ dialog --title "Input your name" --inputbox "Please input your name:" 10 30  2> /tmp/name.txt
```
这里的`2>`是将错误信息输出重定向到`/tmp/name.txt`文件中。

##密码框

格式：
```
dialog --passwordbox text height width [init]
```
例子：
```
$ dialog --title "Password" --passwordbox "Please give a password for the new user:" 10 35
```
密码暴露出来不安全，所以通常我们会加上一个安全选项`--insecure`，将每个字符用`*`来显示。
```
$ dialog --title "Password" --insecure --passwordbox "Please give a password for the new user:" 10 30
```

##文本框
格式：
```
dialog --textbox file height width
```
例子：
```
$ dialog --title "The fstab" --textbox /etc/fstab 17 40
```

##菜单框
格式：
```
dialog --menu text height width menu-height tag1 item1 tag2 item2 …
```

例子：
```
$ dialog --title "Pick a choice" --menu "Choose one" 12 35 5 1 "say hello to everyone" 2 "thanks for your support" 3 "exit"
```
 
##Fselect框(文件选框)
格式：
```
dialog --fselect filepath height width
```
例子：
```
$ dialog --title "Pick one file" --fselect /root/ 7 40
```

##复选框
格式：
```
dialog --checklist "Test" height width menu-height tag1 item1 tag2 item2 …
```

例子：
```
$ dialog --backtitle "Checklist" --checklist "Test" 20 50 10 Memory Memory_Size 1 Dsik Disk_Size 2
```
##显示日历
格式：
```
dialog --calendar "Date" height width day month year
```
例子：

显示当前日期
```
$ dialog --title "Calendar" --calendar "Date" 5 50
```
显示指定日期
```
$ dialog --title "Calendar" --calendar "Date" 5 50 1 2 2013
```
##进度框架
格式：
```
dialog --gauge text height width  [<percent>]
```
例子：

固定进度显示
```
$ dialog --title "installation pro" --gauge "installation" 10 30 10
``` 
实时动度进度
```
$ for i in {1..100} ;do echo $i;done | dialog --title "installation pro" --gauge "installation" 10 30
```
 
编辑一个gauge.sh的脚本，内容如下：
```
#!/bin/bash  

declare -i PERCENT=0
(
    for I in /etc/*;
    do
        if [ $PERCENT -le 100 ];then
            cp -r $I /tmp/test 2> /dev/null
            echo "XXX" 
            echo "Copy the file $I ..." 
            echo "XXX" 
            echo $PERCENT  
        fi
        
        let PERCENT+=1
        sleep 0.1
    done
) | dialog --title "coping" --gauge "starting to copy files..." 6 50 0
```

##from框架(表单)
格式：
```
dialog --form text height width formheight [ label y x item y x flen ilen ] ...
```
其中：`flen`表示`field length`，定义了选定字段中显示的长度；`ilen`表示`input-length`, 定义了在外地输入的数据允许的长度。使用`up/down`（或`ctrl/ N`，`ctrl/ P`）在使用领域之间移动，使用`tab`键在窗口之间切换。

例子：
```
$ dialog --title "Add a user" --form "Please input the infomation of new user:" 12 40 4 \
  "Username:" 1  1 "" 1  15  15  0 \
  "Full name:" 2  1 "" 2  15  15  0 \
  "Home Dir:" 3  1 "" 3  15  15  0 \
  "Shell:"    4   1 "" 4  15  15  0
```
 
#综合应用示例
```
#! /bin/bash

yesno() 
{
	dialog --title "First screen" --backtitle "Test Program" --clear --yesno \
		"Start this test program or not ? \nThis decesion have to make by you." 16 51

	# yes is 0, no is 1 , esc is 255
	result=$?
	if [ $result -eq 1 ] ; then
		exit 1;
	elif [ $result -eq 255 ]; then
		exit 255;
	fi

	username;
}

username() 
{
	cat /dev/null >/tmp/test.username
	dialog --title "Second screen" --backtitle "Test Program" --clear --inputbox \
		"Please input your username (default: hello) " 16 51 "hello" 2>/tmp/test.username

	result=$?
	if [ $result -eq 1 ] ; then
		yesno;
	elif [ $result -eq 255 ]; then
		exit 255;
	fi

	password;
}

password() 
{
	cat /dev/null >/tmp/test.password
	dialog  --insecure --title "Third screen" --backtitle "Test Program" --clear --passwordbox \
		"Please input your password (default: 123456) " 16 51 "123456" 2>/tmp/test.password

	result=$?
	if [ $result -eq 1 ] ; then
		username;
	elif [ $result -eq 255 ]; then
		exit 255;
	fi

	occupation;
}

occupation() 
{
	cat /dev/null >/tmp/test.occupation
	dialog --title "Forth screen" --backtitle "Test Program" --clear --menu \
		"Please choose your occupation: (default: IT)" 16 51 3 \
		IT "The worst occupation" \
		CEO "The best occupation" \
		Teacher "Not the best or worst"  2>/tmp/test.occupation

	result=$?
	if [ $result -eq 1 ] ; then
		password;
	elif [ $result -eq 255 ]; then
		exit 255;
	fi

	finish;
}

finish() 
{
	dialog --title "Fifth screen" --backtitle "Test Program" --clear --msgbox \
		"Congratulations! The test program has finished!\n Username: $(cat /tmp/test.username)\n Password: $(cat /tmp/test.password)\n Occupation: $(cat /tmp/test.occupation)" 16 51

	result=$?
	if [ $result -eq 1 ] ; then
		occupation
	elif [ $result -eq 255 ]; then
		exit 255;
	fi
}

yesno;
```

<br></br>
[Linux下的dialog工具使用方法](http://blog.csdn.net/shenwanjiang111/article/details/42047901)