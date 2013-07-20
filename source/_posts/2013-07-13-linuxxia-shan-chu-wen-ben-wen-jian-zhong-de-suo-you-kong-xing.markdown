---
layout: post
title: "Linux下删除文本文件中的所有空行"
date: 2013-07-13 22:20
comments: true
categories: [Shell, Unix/Linux]
---

很多情况下文本文件中会出现许多空行，这些都是我们不想要的。大多时候我们会选择手工删除，这样显然太麻烦，况且当文件行数很多的时候，其麻烦程度是不能忍受的。所以需要一个工具，可以达到删除所有空行的目的，并且最好还能一次处理多个文件。以下是Linux下的一个脚本文件，支持一次处理多个文件。

```
#!/bin/bash


TEMP_F="del.lines.$$"

usage()
{
	echo "Usage: $0 filename [filename...]"
	exit -1
}

if [ $# -eq 0 ] ; then
	usage
fi

while [ $# -gt 0 ]
do
	FILE_NAME=$1

	case $1 in 
		--help)
			usage
		;;

		*)
			if [ -f $1 ] ; then
				sed '/^$/d' $FILE_NAME > $TEMP_F
				mv $TEMP_F $FILE_NAME
			else
				echo "$0 can not find this file: $1"
			fi		
		;;
	esac

	shift
done
```
<!--more-->
