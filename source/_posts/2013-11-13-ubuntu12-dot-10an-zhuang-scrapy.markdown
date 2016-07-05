---
layout: post
title: "Ubuntu12.10安装Scrapy"
date: 2013-11-13 15:59
comments: true
categories: [网络爬虫]
---

根据官网[Ubuntu packages](http://doc.scrapy.org/en/latest/topics/ubuntu.html#topics-ubuntu)上的方法安装Scrapy，然后创建一个教程目录，却出现了一些问题，如下所示。

```
$ scrapy startproject tutorial  
Traceback (most recent call last):  
  File "/usr/bin/scrapy", line 4, in <module>  
    execute()  
  File "/usr/lib/pymodules/python2.7/scrapy/cmdline.py", line 121, in execute  
    cmds = _get_commands_dict(settings, inproject)  
  File "/usr/lib/pymodules/python2.7/scrapy/cmdline.py", line 45, in _get_commands_dict
    cmds = _get_commands_from_module('scrapy.commands', inproject)  
  File "/usr/lib/pymodules/python2.7/scrapy/cmdline.py", line 28, in _get_commands_from_module  
    for cmd in _iter_command_classes(module):  
  File "/usr/lib/pymodules/python2.7/scrapy/cmdline.py", line 19, in _iter_command_classes  
    for module in walk_modules(module_name):  
  File "/usr/lib/pymodules/python2.7/scrapy/utils/misc.py", line 66, in walk_modules
    submod = __import__(fullpath, {}, {}, [''])  
  File "/usr/lib/pymodules/python2.7/scrapy/commands/deploy.py", line 13, in <module>
    from w3lib.form import encode_multipart  
  File "/usr/lib/python2.7/dist-packages/w3lib/form.py", line 2, in <module>
    if six.PY2:  
AttributeError: 'module' object has no attribute 'PY2'  
```
<!--more-->

从网上找到了一个答案，需要利用pip去安装。

```
$ pip install Scrapy  
Requirement already satisfied (use --upgrade to upgrade): Scrapy in   /usr/lib/pymodules/python2.7   
Requirement already satisfied (use --upgrade to upgrade): Twisted>=8.0 in   /usr/lib/python2.7/dist-packages (from Scrapy)  
Requirement already satisfied (use --upgrade to upgrade): w3lib>=1.2 in   /usr/lib/python2.7/dist-packages (from Scrapy)  
Requirement already satisfied (use --upgrade to upgrade): queuelib in   /usr/lib/python2.7/dist-packages (from Scrapy)   
Requirement already satisfied (use --upgrade to upgrade): lxml in    /usr/lib/python2.7/dist-packages (from Scrapy)   
Requirement already satisfied (use --upgrade to upgrade): pyOpenSSL in    /usr/lib/python2.7/dist-packages (from Scrapy)   
Downloading/unpacking six>=1.4.1 (from w3lib>=1.2->Scrapy)   
  Downloading six-1.4.1.tar.gz   
  Running setup.py egg_info for package six   
    
Installing collected packages: six   
  Found existing installation: six 1.1.0   
    Uninstalling six:   
Exception:   
Traceback (most recent call last):   
  File "/usr/lib/python2.7/dist-packages/pip/basecommand.py", line 104, in main  
    status = self.run(options, args)   
  File "/usr/lib/python2.7/dist-packages/pip/commands/install.py", line 250, in run   
    requirement_set.install(install_options, global_options)   
  File "/usr/lib/python2.7/dist-packages/pip/req.py", line 1129, in install   
    requirement.uninstall(auto_confirm=True)   
  File "/usr/lib/python2.7/dist-packages/pip/req.py", line 486, in uninstall   
    paths_to_remove.remove(auto_confirm)   
  File "/usr/lib/python2.7/dist-packages/pip/req.py", line 1431, in remove   
    renames(path, new_path)   
  File "/usr/lib/python2.7/dist-packages/pip/util.py", line 263, in renames   
    shutil.move(old, new)   
  File "/usr/lib/python2.7/shutil.py", line 302, in move   
    os.unlink(src)   
OSError: [Errno 13] Permission denied: '/usr/share/pyshared/six-1.1.0.egg-info'   

Storing complete log in /home/txgcwm/.pip/pip.log   
```

借助新得立把six给卸载掉，然后重新安装。

```
$ sudo pip install Scrapy  
Downloading/unpacking Scrapy   
  Downloading Scrapy-0.20.0.tar.gz (745Kb): 745Kb downloaded   
  Running setup.py egg_info for package Scrapy   
    
    no previously-included directories found matching 'docs/build'   
Requirement already satisfied (use --upgrade to upgrade): Twisted>=10.0.0 in    /usr/lib/python2.7/dist-packages (from Scrapy)   
Downloading/unpacking w3lib>=1.2 (from Scrapy)   
  Downloading w3lib-1.5.tar.gz   
  Running setup.py egg_info for package w3lib   
    
Requirement already satisfied (use --upgrade to upgrade): queuelib in    /usr/lib/python2.7/dist-packages (from Scrapy)   
Requirement already satisfied (use --upgrade to upgrade): lxml in    /usr/lib/python2.7/dist-packages (from Scrapy)   
Requirement already satisfied (use --upgrade to upgrade): pyOpenSSL in    /usr/lib/python2.7/dist-packages (from Scrapy)   
Downloading/unpacking cssselect>=0.9 (from Scrapy)   
  Downloading cssselect-0.9.1.tar.gz   
  Running setup.py egg_info for package cssselect   
    
    no previously-included directories found matching 'docs/_build'   
Downloading/unpacking six>=1.4.1 (from w3lib>=1.2->Scrapy)   
  Running setup.py egg_info for package six   
    
Installing collected packages: Scrapy, w3lib, cssselect, six   
  Running setup.py install for Scrapy    
    changing mode of build/scripts-2.7/scrapy from 644 to 755   
    
    no previously-included directories found matching 'docs/build'   
    changing mode of /usr/local/bin/scrapy to 755   
  Running setup.py install for w3lib   
    
  Running setup.py install for cssselect   
    
    no previously-included directories found matching 'docs/_build'   
  Running setup.py install for six   
    
Successfully installed Scrapy w3lib cssselect six   
Cleaning up...   
```

创立一个项目。

``` 
$ sudo scrapy startproject tutorial   
```
