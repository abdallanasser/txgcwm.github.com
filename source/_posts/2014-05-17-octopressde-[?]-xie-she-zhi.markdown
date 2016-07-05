---
layout: post
title: "Octopress的一些设置"
date: 2014-05-17 17:13
comments: true
categories: [Octopress]
tags: [Octopress, 博客恢复, SEO]
keywords: Seo, Octopress
description: Octopress的SEO技巧，在新电脑上恢复博客内容。
---

#从新电脑上恢复博客内容

如果电脑重装了系统，或者要在另一台电脑上编写博客，找到博客仓库的`url`，执行以下的指令：
```
$ git clone -b source (url) octopress   #把source 克隆到本地octopress目录上

$ cd octopress
$ git clone (url) _deploy   #克隆master分支，它存放着博客内容。

$ gem install bundler
$ bundle install
$ rake install
$ rake setup_github_pages
```

#网站提交到搜索引擎

博客上写出的文章当然希望有人能看到，而且希望更多的人看到，这就需要让自己的博客可以在搜索引擎里面检索到，那么就需要将个人博客提交到搜索引擎，让它来抓取，所以首先要到各个搜索引擎提交自己的博客地址，[免费收录网站搜索引擎登录口大全--搜索引擎网站收录地址大全](http://urlc.cn/tool/addurl.html)和[国内外各大免费搜索引擎、导航网址提交入口--搜索引擎网站收录地址大全](http://tool.lusongsong.com/addurl.html)这两个地方收录了国内外各大搜索引擎的地址。

提交到搜索引擎后就能搜索到你的文章，但还需要做的是为你的网站文章添加描述信息、关键字，来帮助用户准确的搜索到。关键字和描述是指网页`head`部分的元标签`meta`，是给搜索引擎看的，以此希望用户可以比较容易找到。例如：
```
<meta name="description" content="残剑是一个关注IT技术的博客">
<meta name="keywords" content="IT, 编程, 码农的自嘲">
```

首先为每篇文章添加描述和关键字，本文的文件头如下：
```
---
layout: post
title: "Octopress的一些设置"
date: 2014-05-17 17:13
comments: true
categories: [Octopress]
tags: [Octopress, 博客恢复, SEO]
keywords: Seo, Octopress
description: Octopress的SEO技巧，在新电脑上恢复博客内容。
---
```

<!--more-->
这样就可以为文章添加关键字和描述，使搜索引擎更容易搜到你的文章。还可以为你的博客首页添加描述和关键字，在`source/index.html`文件顶部添加即可,方法如上。

如果你没有为文章添加描述，Octopress会自动以文章的前150个字符作为描述，为每一篇文章都添加描述，Octopress模板实现以上功能的代码在`source/_includes/head.html`中：
```
{% capture description %}{% if page.description %}{{ page.description }}{% else %}{{ content | raw_content }}{% endif %}{% endcapture %}
  <meta name="description" content="{{ description | strip_html | condense_spaces | truncate:150 }}">
{% if page.keywords %}<meta name="keywords" content="{{ page.keywords }}">{% endif %}
```

在使用`rake new_post`的时候，我们当然希望在文件的开头加入tags、keywords、description这些选项，那么就需要修改`Rakefile`文件。
```
# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your post: ")
  end
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  mkdir_p "#{source_dir}/#{posts_dir}"
  filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: []"
	post.puts "tags: []"
	post.puts "keywords: " 
	post.puts "description: "
    post.puts "---"
  end
end
```

#为博客添加背景图片

Octopress支持SASS语法，改造Octopress主题基本是通过修改`sass/custom`下以scss为后缀名的文件来完成，大多数的改造是在`_styles.scss`这个文件中来实现。我的配置如下：
```
// This File is imported last, and will override other styles in the cascade
// Add styles here to make changes without digging in too much


/* ----- main layout ----- */
html { background: #262C33 url("/images/bg.png"); }

body { font-size: 1.2em; }

body > div { background-image: none; }

body > div > div { background-image: none; }

/* ----- header ----- */
body > header{
    background: none;
    padding: 1.6em 0 1em 0
}

body > header h1{
    font-size: 2.8em;
    padding-left: 20px;
    text-shadow: rgba(0, 0, 0, 0.8) 0 0 8px;
}

body > header h2{
    font-size: 1em;
    letter-spacing: 1px;
    margin-top: 0em;
    padding-left: 20px;
}

body > nav {
    padding-top: .15em;
    padding-bottom: .15em;
}

body > nav a{
    font-size: 1.2em;
    line-height: 1.4em;
}

body > nav form .search{
    padding: .2em .3em;
}

/* ----- Content ----- */
#content .blog-index article h1 {
    font-size: 2em;
    font-weight: normal;
}

#content .blog-index article h1, #content .blog-index article h1 a, article header h1, article header h1 a{
    color: #555555 !important;
}

h1 { font-size: 1.8em; }

h1 span{
    font-weight: normal;
    color: #E0841B;
}

article h2, article h3, article header h1{
    font-weight: normal;
}

.blog-index article h1 a:hover{ text-decoration: none; }

article p {
    text-align:justify;
    margin-bottom: 1em;
}

/* ----- Sidebar ----- */
aside.sidebar section h1 { letter-spacing: 0.1em; }

aside.sidebar a { text-decoration: none; }

.toggle-sidebar{display: none;}

ul#gh_repos > li > a{
    display: block;
    font-weight: bold;
    margin-bottom: 0.4em;
}

aside.sidebar{
    -moz-border-radius-topright: 0.4em;
    -webkit-border-radius: 0 0.4em 0 0;
    border-radius: 0 0.4em 0 0;
}

/* ----- Footer ----- */
body > footer{
    -moz-border-radius: 0;
    -webkit-border-radius: 0;
    border-radius:0;
    margin-bottom: 0;
}

/* ----- 404 ----- */
.notfound404 article{
    margin-left: 0 !important;
}

/* ----- Media queries ----- */
@media only screen and (min-width: 1040px) {
 
    body > nav {
      -moz-border-radius: 0.4em;
      -webkit-border-radius: 0.4em;
      border-radius:0.4em;
      margin-bottom: 2em;
    }

    body > footer{
        -moz-border-radius-bottomleft: 0.4em;
        -moz-border-radius-bottomright: 0.4em;
        -webkit-border-radius: 0 0 0.4em 0.4em;
        border-radius: 0 0 0.4em 0.4em;
    }

    #main{
        -moz-border-radius-topleft: 0.4em;
        -moz-border-radius-topright: 0.4em;
        -webkit-border-radius: 0.4em 0.4em 0 0;
        border-radius: 0.4em 0.4em 0 0;
    }

    #content{
        -moz-border-radius-topleft: 0.4em;
        -webkit-border-radius: 0.4em 0 0 0;
        border-radius: 0.4em 0 0 0;
    }

    #content .blog-index a[rel="full-article"]{
        -webkit-border-radius: 6px;
        -moz-border-radius: 6px;
        border-radius: 6px;
    }
}
```

<big>参考文章</big>  

[octopress博客搭建和个性化配置](http://blog.csdn.net/grunmin/article/details/14127653)   
[Octopress添加统计与SEO](http://blog.csdn.net/lcliliil/article/details/13727927)   
[Octopress技巧之设置关键字和描述](http://www.cnblogs.com/hswg/archive/2013/01/15/2860952.html)   
[Octopress - SEO for Octopress website](http://larrynung.github.io/2013/11/21/octopress-seo-for-octopress-website/)   
[Octopress主题改造](http://shanewfx.github.io/blog/2012/08/13/improve-blog-theme/)  
[调整octopress主题小结](http://colors4.us/blog/2012/09/05/octopress-theme-adjusting/)   