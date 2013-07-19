---
layout: post
title: "Ubuntu下编译vlc-android源代码"
date: 2013-07-19 21:18
comments: true
categories: 
---

在编译源码前，需要先安装Android的SDK、NDK以及一些必需的软件，具体安装方法这里就不再详述了，网上可以找到很多相应的文章。安装软件可以执行以下指令：
```
$ apt-get install  apache-ant(or ant)  autoconf automake autopoint  libtool  gawk (or nawk)
gcc  g++  pkg-config  cmake  patch subversion git
```
ant工具在最后编译android源码生成apk文件会用到，所以需要安装。如果手动安装了ant，需要在环境变量中配置好ant的 path，或者在编译前执行命令`export PATH=$PATH:/xxx/ant/bin`，保证可以在执行编译的命令行中执行ant命令即可。
<!--more-->

#环境变量配置

配置ANDROID_SDK（请把path改为自己的路径）
```
$ export ANDROID_SDK=/path/to/android-sdk
```
配置ANDROID_NDK
```
$ export ANDROID_NDK=/path/to/android-ndk
```
配置PATH变量
```
$ export PATH=$PATH:$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools
```
配置NEON相关信息（一般编译的时候，会编译NO_NEON和支持NEON两种包出来）
```
$ export NO_NEON=1
```
如果设备不支持NEON技术，请务必配置此项；如果机器支持NEON技术，可以不用配置此项。关于NEON的简单信息：根据维基百科英文版ARM架构中的介绍，Cortex-A8架构的设备均支持NEON技术，而在Cortex-A9架构的设备中则是可选的，更多信息请参考 [NEON](http://www.arm.com/zh/products/processors/technologies/neon.php) 和 [ARM architecture](http://en.wikipedia.org/wiki/ARM_architecture#Advanced_SIMD_.28NEON.29) 。 

配置ABI
```
$ export ANDROID_ABI=armeabi-v7a
```

#获取源码
```
$ git clone git://git.videolan.org/vlc-ports/android.git
```
#编译源码

下载完成后，进入android文件夹执行`sh compile.sh`，开始自动编译。如果编译过程中遇到错误：
```
checking host system type… Invalid configuration `arm-linux-androideabi’: system 
`androideabi’ not recognized
```
请在重新编译之前执行以下操作：1. 到 [这里](http://git.savannah.gnu.org/gitweb/?p=config.git;a=tree)下载最新的config.guess和config.sub文件；2. 将下载的文件拷贝到/usr/share/misc目录下；3. 重新启动编译。

最后提示BUILD SUCESSFUL，说明编译成功了，在android/vlc-android/bin目录下会生成一个apk文件，可以直接拿来安装。如果想自己调整界面部分，或者添加、修改其它功能，可以直接把项目导入eclipse进行开发。


#出错处理

如果编译过程中提示缺少某一软件的错误，请根据错误提示安装对应的工具，或者在执行编译之前就把之前提到的工具全部安装好。

出错信息：
```
 CC     posix/plugin.lo
../../src/posix/plugin.c: In function 'module_Load':
../../src/posix/plugin.c:50:50: warning: unused parameter 'lazy' [-Wunused-parameter]
  CC     posix/thread.lo
../../src/posix/thread.c:85:5: warning: #warning Monotonic clock not available. Expect timing issues. [-Wcpp]
../../src/posix/thread.c: In function 'vlc_cancel':
../../src/posix/thread.c:830:5: error: implicit declaration of function 'pthread_cancel' [-Werror=implicit-function-declaration]
../../src/posix/thread.c: In function 'vlc_savecancel':
../../src/posix/thread.c:847:5: error: implicit declaration of function 'pthread_setcancelstate' [-Werror=implicit-function-declaration]
../../src/posix/thread.c:847:39: error: 'PTHREAD_CANCEL_DISABLE' undeclared (first use in this function)
../../src/posix/thread.c:847:39: note: each undeclared identifier is reported only once for each function it appears in
../../src/posix/thread.c: In function 'vlc_restorecancel':
../../src/posix/thread.c:867:9: error: 'PTHREAD_CANCEL_DISABLE' undeclared (first use in this function)
../../src/posix/thread.c: In function 'vlc_testcancel':
../../src/posix/thread.c:884:5: error: implicit declaration of function 'pthread_testcancel' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

make[3]: *** [posix/thread.lo] Error 1
make[3]: Leaving directory `/srv/android/vlc/android/src'
make[2]: *** [all] Error 2
make[2]: Leaving directory `/srv/android/vlc/android/src'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/srv/android/vlc/android'
make: *** [all] Error 2
```

解决方法：
进入下载的android vlc目录，执行以下指令。
```
$ cd vlc
$ git reset --hard origin
$ git pull origin master
$ git checkout -b android ${TESTED_HASH}
$ git am ../patches/*
```

注：在老的git版本中git checkout并没有-B的选项，所以一开始执行的时候并没有下载android版本的vlc代码，故使用`git checkout -b android ${TESTED_HASH}`。


出错信息：
```
BUILD FAILED
/usr/local/android-sdk-linux/tools/ant/build.xml:517: Unable to resolve project target 'android-15'

Total time: 3 seconds
make: *** [vlc-android/bin/VLC-debug.apk] Error 1
rm android-libs/libmedia.c android-libs/libutils.c android-libs/libstagefright.c android-libs/libbinder.c
```

解决方法：
进入到android-sdk-linux/tools目录，执行`./android`下载Android 4.0.3（API15）的相关文件。


出错信息：
```
curl -f -L -- "http://git.xiph.org/?p=speex.git;a=snapshot;h=HEAD;sf=tgz" > "../../contrib/tarballs/speex-git.tar.gz"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   814  100   814    0     0    226      0  0:00:03  0:00:03 --:--:-- 23941
../../contrib/src/speex/rules.mak:20: .sum-speex not implemented
touch .sum-speex
touch -r .sum-speex .sum-speexdsp
rm -Rf speex-git
mkdir -p speex-git
zcat "../../contrib/tarballs/speex-git.tar.gz" | (cd speex-git && tar xv --strip-components=1)

gzip: ../../contrib/tarballs/speex-git.tar.gz: not in gzip format
tar: This does not look like a tar archive
tar: Exiting with failure status due to previous errors
make: *** [speex] Error 2
```

解决方法：
将`http://git.xiph.org/?p=speex.git;a=snapshot;h=HEAD;sf=tgz`输入到浏览器地址栏中就会开始下载你所需要的文件，然后将相应下载的压缩文件存放于contrib/tarballs/目录下，将名字改成speex-git.tar.gz。若碰到其它的库文件有类似的错误，可采用该办法。 