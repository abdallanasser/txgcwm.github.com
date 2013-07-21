---
layout: post
title: "Octopress添加中文标签功能"
date: 2013-07-21 11:02
comments: true
categories: [Octopress, Unix/Linux]
---
Octopress有自带的分类，详情请见 [官方文档](http://octopress.org/docs/plugins/category-generator/) 。`_config.yml`中配置项如下：
```
category_dir: blog/categories
category_title_prefix: "Category: "
```
然后添加类似`categories: [Ruby&Rails]`或`categories: [Ruby&Rails，C/C++]`的分类标签配置到每个`_posts/*.markdown`文件头中，示例如下:
```
---
layout: post
title: "Octopress添加中文标签功能"
date: 2013-07-21 11:02
comments: true
categories: [Ruby&Rails,Octopress]
---
```
<!--more-->

#添加分类侧边栏并支持中文

尽管Octopress有自带的分类，但它并不支持中文，如果你在文章中定义了中文分类，那么点击的时候会链接到404页面。事实上，这个分类功能是通过plugins/category_generator.rb来实现，所以只要对该文件进行适当的修改和作一些其它的配置就可以提供中文分类的支持。

+ category_generator.rb的修改我直接使用 [这个](https://github.com/denjones/denjones.github.com/blob/source/plugins/category_generator.rb) 文件作了替换，然后作一些细微的修改。

SPRabbit(超科学兔耳中队)的 [修改方法](http://blog.sprabbit.com/blog/2012/03/23/octopress/) 是重新定义分类标签在文章中的格式，例如用`中文分类标签名{英文别名}`这样的格式来定义标签。于是在文章中显示的是中文分类，但实际链接到英文别名上。这种方法虽然定义标签麻烦些，但可定制性强。

由于书写很麻烦，所以很不喜欢以上重新定义标签的方式，在 [这里](http://khaos.github.io/blog/2012/12/06/using-chinese-category-tags-in-octopress/) 找到了另外一种更改方式。它同样是修改category_generator.rb文件来达到目的，利用了stringex包的to_url函数将中文分类标签的链接名和category_dir下的目录名都转换成相应的拼音，这样无论在本地还是GitHub上都没有问题。事实上，Octopress系统在利用rake new_[post|page]命令创建含有中文名的文章时也采用了这样的技巧。

找到`def write_category_indexes`中定义category目录的部分：
```
self.write_category_index(File.join(dir, category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase), category)
```
将其修改为：
```
self.write_category_index(File.join(dir, category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').to_url.downcase), category)
```
再找到`def category_links(categories)`中定义中文分类网页标签的部分：
```
"<a class='category' href='/#{dir}/#{item.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase}/'>#{item}</a>"
```
将其修改为：
```
"<a class='category' href='/#{dir}/#{item.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').to_url.downcase}/'>#{item}</a>"
```
注意，上面两处的修改就是在相应的地方加上to_url函数进行地址的转换。如果不想折腾的话，你也可以直接到 [这里](https://github.com/txgcwm/txgcwm.github.com/blob/source/plugins/category_generator.rb) 下载我更改后的category_generator.rb插件。


+ 在plugins目录中创建category_list_tag.rb文件，文件内容如下：
```
require 'stringex'

module Jekyll
  class CategoryListTag < Liquid::Tag
    def render(context)
      html = ""
      categories = context.registers[:site].categories.keys
	  category_dir = context.registers[:site].config['category_dir']
      categories.sort.each do |category|
        posts_in_category = context.registers[:site].categories[category].size	
        category_url = File.join(category_dir, category.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').to_url.downcase)
        html << "<li class='category'><a href='/#{category_url}/'>#{category} (#{posts_in_category})</a></li>\n"
      end
      html
    end
  end
end

Liquid::Template.register_tag('category_list', Jekyll::CategoryListTag)
```
在实际使用（rake generate/rake preview）的时候，若blog整体采用了非ascii码的编码格式（比如utf-8）就会出现类似这样的错误：
```
Liquid error: incompatible encoding regexp match (ascii-8bit regexp with utf-8 string)
```
其实是由于插件文件plugins/category_list_tag.rb本身是ascii编码所致:
```
$ chardet category_list_tag.rb
category_list_tag.rb: ascii (confidence: 1.00)
```
category_list_tag.rb中很多地方用到了ruby的正则表达式，而ruby的正则表达式在匹配的时候，默认是按照“代码源文件”的编码格式(在这里是ascii)进行匹配的，而如果blog是utf-8编码的话就会出现上述错误。有两种解决办法：

1. 将category_list_tag.rb转成utf-8格式。
2. 更改category_list_tag.rb中所有的正则表达式声明，加上`u`选项（`u`的意思就是以utf-8编码格式来进行匹配）。例如，若原正则表达式是`/regexp/`, 则改成`/regexp/u`。

在我实际处理问题的时候采用了第二种方法，category_list_tag.rb文件中的更改网上大多采用以下的方式：
```
category_url = File.join(category_dir, category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').to_url.downcase)
```
更改成如下形式（只是简单增加了`u`选项）：
```
category_url = File.join(category_dir, category.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').to_url.downcase)
```

+ 添加source/_includes/custom/asides/category_list.html文件，内容可到 [这里](https://github.com/txgcwm/txgcwm.github.com/blob/source/source/_includes/custom/asides/category_list.html) 查看。

+ 修改_config.yml文件，在default_asides项中添加custom/asides/category_list.html，值之间以逗号隔开。
```
default_asides: [asides/recent_posts.html, custom/asides/category_list.html]
```

`_posts/*.markdown`文件头中添加categories标签示例：
```
---
layout: post
title: "使用libevent编写Linux服务"
date: 2013-07-18 19:01
comments: true
categories: [C/C++, 开源库, Unix/Linux]
---
```

到此为止，Octopress中添加分类侧边栏并使其支持中文的修改设置已经完毕。


#参考文章

+ [Octopress博客设置](http://www.cnblogs.com/oec2003/archive/2013/05/31/3109577.html)
+ [Octopress博客分类添加中文支持](http://ikeepu.com/bar/10393365)
+ [Octopress易筋经，中文分类标签](http://khaos.github.io/blog/2012/12/06/using-chinese-category-tags-in-octopress/)
+ [关于在64位 Windows 7 中部署中文化的Octopress](http://blog.sprabbit.com/blog/2012/03/23/octopress/)
+ [Liquid Error About Regexp Match When Using Octopress-tagcloud](http://pfmiles.github.io/blog/liquid-error-about-regexp-match-when-using-octopress-tagcloud/)