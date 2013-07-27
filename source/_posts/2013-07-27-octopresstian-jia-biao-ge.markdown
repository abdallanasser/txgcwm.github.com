---
layout: post
title: "Octopress添加表格"
date: 2013-07-27 15:08
comments: true
categories: [Octopress]
---
Markdown语法为“方便在网上读文章、写文章、修改文章更容易”这一目标而生。它不是HTML的替代品，也不是为了终结HTML。它的语法非常简单，只相当于HTML标签的一个非常非常小的子集。它并非是为了更容易输入HTML标签而创造一种新语法。HTML是一种适合发表的格式；而Markdown是一种书写格式。正因如此，Markdown的格式化语法仅需解决用纯文本表达的问题。

下面的这个例子是在一篇Markdown文章中添加一个HTML表格：
```
<table>
    <tr>
        <td>Column1</td>
        <td>Column2</td>
    </tr>
    <tr>
        <td>foo</td>
        <td>foo</td>
    </tr>
</table>    
```
<!--more-->

<table>
    <tr>
        <td>Column1</td>
        <td>Column2</td>
    </tr>
    <tr>
        <td>foo</td>
        <td>foo</td>
    </tr>
</table>   
 
也可以使用markdown的扩展语法添加一个表格：

```
Column1     | Column2      
----------- | ------------ 
foo         | foo
```

但使用html语法做一个表格很麻烦，而且看起来也不是很美观。使用markdown语法做出来的表格却没有边框。所以需要重新做一些设定，以下为设置和更改的方法。

Step 1. 在source/stylesheets/目录下增加data-table.css文件，添加如下内容：
```
* + table {
    border-style:solid;
    border-width:1px;
    border-color:#e7e3e7;
}
 
* + table th, * + table td {
    border-style:dashed;
    border-width:1px;
    border-color:#e7e3e7;
    padding-left: 3px;
    padding-right: 3px;
}
 
* + table th {
    border-style:solid;
    font-weight:bold;
    background: url("/images/noise.png?1330434582") repeat scroll left top #F7F3F7;
}
 
* + table th[align="left"], * + table td[align="left"] {
    text-align:left;
}
 
* + table th[align="right"], * + table td[align="right"] {
    text-align:right;
}
 
* + table th[align="center"], * + table td[align="center"] {
    text-align:center;
}
```

Step 2. 添加link到head.html中，在source/_includes/head.html文件中插入如下语句：
```
<link href="/stylesheets/data-table.css" media="screen, projection" rel="stylesheet" type="text/css" />
```

重新设定后，表格样式如下：

Column1     | Column2      
----------- | ------------ 
foo         | foo
<br></br>

<big>参考文章:</big>   
[Octopress Table Stylesheet](http://samwize.com/2012/09/24/octopress-table-stylesheet/)  
[Markdown语法](http://jhjguxin.github.io/blog/2012/04/24/markdownyu-fa/)