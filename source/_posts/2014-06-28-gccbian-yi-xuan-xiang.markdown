---
layout: post
title: "GCC编译选项"
date: 2014-06-28 11:28
comments: true
categories: [C/C++]
tags: []
keywords: 
description: 
---
GCC的使用方法：
```
gcc [-c│-S│-E] [-std=standard]
    [-g] [-pg] [-Olevel]
    [-Wwarn...] [-pedantic]
    [-Idir...] [-Ldir...]
    [-Dmacro[=defn]...] [-Umacro]
    [-foption...] [-mmachine-option...]
    [-o outfile] infile...
```
---
#常用选项

* --help
* --target-help：显示gcc帮助说明，是显示目标机器特定的命令行选项。
* --version：显示gcc版本号和版权信息 。
* -o outfile：输出到指定的文件。
* -x language：指明使用的编程语言，允许的语言包括：c、c++、assembler、none，none意味着恢复默认行为，即根据文件的扩展名猜测源文件的语言。
* -v：打印较多信息，显示编译器调用的程序。
* -###：与-v类似，但选项被引号括住，并且不执行命令。
* -E：仅作预处理，不进行编译、汇编和链接。
* -S：仅编译到汇编语言，不进行汇编和链接。
* -c：编译、汇编到目标代码，不进行链接。
* -pipe：使用管道代替临时文件。
* -combine：将多个源文件一次性传递给汇编器。

---

#其它选项

* -l library/-llibrary：进行链接时搜索名为library的库。
* -Idir：把dir加入到搜索头文件的路径列表中。
* -Ldir：把dir加入到搜索库文件的路径列表中。
* -Dname：预定义一个名为name的宏，值为1。
* -Dname=definition：预定义名为name，值为definition的宏。
* -ggdb
* -ggdblevel：为调试器gdb生成调试信息，level可以为1～3，默认值为2。
* -g
* -glevel：生成操作系统本地格式的调试信息，-g和-ggdb并不太相同，-g会生成gdb之外的信息，level取值同上。
* -s：去除可执行文件中的符号表和重定位信息，用于减小可执行文件的大小。
* -M：告诉预处理器输出一个适合make的规则，用于描述各目标文件的依赖关系。对于每个源文件，预处理器输出一个make规则，该规则的目标项(target)是源文件对应的目标文件名，依赖项(dependency)是源文件中#include引用的所有文件。生成的规则可以是单行，但如果太长，就用\换行符续成多行。规则显示在标准输出，不产生预处理过的C程序。
* -C：告诉预处理器不要丢弃注释，配合-E选项使用。
* -P：告诉预处理器不要产生#line命令，配合-E选项使用。
* -static：在支持动态链接的系统上，阻止连接共享库。
* -nostdlib：不连接系统标准启动文件和标准库文件，只把指定的文件传递给连接器。

<!--more-->
---

#Warnings        

* -Wall：会打开一些很有用的警告选项，建议编译时加此选项。
* -W
* -Wextra：打印一些额外的警告信息。
* -w：禁止显示所有警告信息。
* -Wshadow：当一个局部变量遮盖住了另一个局部变量或者全局变量时，给出警告，-Wall并不会打开此项。
* -Wpointer-arith：对函数指针或者void *类型的指针进行算术操作时给出警告，-Wall并不会打开此项。
* -Wcast-qual：当强制转化丢掉了类型修饰符时给出警告，-Wall并不会打开此项。
* -Waggregate-return：如果定义或调用了返回结构体或联合体的函数，编译器就发出警告。
* -Winline：无论是声明为inline或者是指定了-finline-functions选项，如果某函数不能内联，编译器都将发出警告。
* -Werror：把警告当作错误，出现任何警告就放弃编译。
* -Wunreachable-code：如果编译器探测到永远不会执行到的代码，就给出警告。
* -Wcast-align：一旦某个指针类型强制转换导致目标所需的地址对齐增加时，编译器就发出警告。
* -Wundef：当一个没有定义的符号出现在#if中时，给出警告。
* -Wredundant-decls：如果在同一个可见域内某定义多次声明，编译器就发出警告，即使这些重复声明有效并且毫无差别。

---

#Optimization        

* -O0：禁止编译器进行优化，默认为此项。
* -O
* -O1：尝试优化编译时间和可执行文件大小。
* -O2：更多的优化，会尝试几乎全部的优化功能，但不会进行“空间换时间”的优化方法。
* -O3：在-O2的基础上再打开一些优化选项：-finline-functions， -funswitch-loops和-fgcse-after-reload。
* -Os：对生成文件大小进行优化，它会打开-O2开的全部选项，除了那些增加文件大小的。
* -finline-functions：把所有简单的函数内联进调用者，编译器会探索式地决定哪些函数足够简单，值得做这种内联。
* -fstrict-aliasing：施加最强的别名规则（aliasing rules）。

---

#Standard        

* -ansi：支持符合ANSI标准的C程序，这样就会关闭GNU C中某些不兼容ANSI C的特性。
* -std=c89
* -iso9899:1990：指明使用标准ISO C90作为标准来编译程序。
* -std=c99
* -std=iso9899:1999：指明使用标准ISO C99作为标准来编译程序。
* -std=c++98：指明使用标准C++98作为标准来编译程序。
* -std=gnu9x
* -std=gnu99：使用ISO C99，再加上GNU的一些扩展。
* -fno-asm：不把asm, inline或typeof当作关键字，因此这些词可以用做标识符，用__asm__， __inline__和__typeof__能够替代它们，-ansi隐含声明了-fno-asm。
* -fgnu89-inline：告诉编译器在C99模式下看到inline函数时使用传统的GNU句法。

---

#C options        

* -fsigned-char
* -funsigned-char：把char定义为有/无符号类型，如同signed char/unsigned char。
* -traditional：尝试支持传统C编译器的某些方面。
* -fno-builtin
* -fno-builtin-function：不接受没有__builtin_前缀的函数作为内建函数。
* -trigraphs：支持ANSI C的三联符（ trigraphs），-ansi选项隐含声明了此选项。
* -fsigned-bitfields
* -funsigned-bitfields：如果没有明确声明`signed'或`unsigned'修饰符，这些选项用来定义有符号位域或无符号位域，缺省情况下位域是有符号的，因为它们继承的基本整数类型（如int）是有符号的。
* -Wstrict-prototypes：如果函数的声明或定义没有指出参数类型，编译器就发出警告。
* -Wmissing-prototypes：如果没有预先声明就定义了全局函数，编译器就发出警告，即使函数定义自身提供了函数原形也会产生这个警告，这个选项的目的是检查没有在头文件中声明的全局函数。
* -Wnested-externs：如果某extern声明出现在函数内部，编译器就发出警告。

---

#C++ options        

* -ffor-scope：从头开始执行程序，也允许进行重定向。
* -fno-rtti：关闭对dynamic_cast和typeid的支持，如果不需要这些功能，关闭它会节省一些空间。
* -Wctor-dtor-privacy：当一个类没有用时给出警告，因为构造函数和析构函数会被当作私有的。
* -Wnon-virtual-dtor：当一个类有多态性，而又没有虚析构函数时，发出警告，-Wall会开启这个选项。
* -Wreorder：如果代码中的成员变量的初始化顺序和它们实际执行时初始化顺序不一致，给出警告。
* -Wno-deprecated：使用过时的特性时不要给出警告。
* -Woverloaded-virtual：如果函数的声明隐藏住了基类的虚函数，就给出警告。

---

#Machine Dependent Options (Intel)       

* -mtune=cpu-type：为指定类型的CPU生成代码，cpu-type可以是：i386，i486，i586，pentium，i686，pentium4等等。
* -msse
* -msse2
* -mmmx
* -mno-sse
* -mno-sse2
* -mno-mmx：使用或者不使用MMX，SSE，SSE2指令。
* -m32
* -m64：生成32位/64位机器上的代码。
* -mpush-args
* -mno-push-args：（不）使用 push 指令来进行存储参数，默认是使用。
* -mregparm=num：当传递整数参数时，控制所使用寄存器的个数。