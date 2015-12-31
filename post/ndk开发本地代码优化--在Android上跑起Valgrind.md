## ndk开发本地代码优化--在Android上跑起Valgrind

承接上一篇[《ndk开发本地代码优化--Linux本地代码优化》](./ndk开发本地代码优化--在Android上跑起Valgrind.md)，重点讲解了如何通过`Valgrind`工具分析Linux上的程序的`内存泄露`问题、`函数热点`问题。Android基于Linux内核而来，如果将`Valgrind`工具移植到Android平台，是不是可以像在Linux上一样，通过几条简单的命令，就可以检测出Android上运行的native程序的问题呢？答案是肯定的。  

Android上的程序分两种：  

* 一种是native程序，即在终端可调用执行的程序，如/system/bin目录下的一堆命令行工具，这一类native程序可以用移植到Android上的`Valgrind`工具分析，移植到Android上的`Valgrind`工具也就是一个native程序；  
* 另一种就是我们平常开发的App应用，App应用包括基于Framework用java写的一套上层逻辑，这一部分的优化可以考虑使用`Traceview`等工具，App应用还可能包括用C/C++编写的一些native库，这一部分native库的分析可以用移植到Android上的`Valgrind`工具；  

综上所述，Android上的`Valgrind`工具可以用来分析`纯native的程序`和`App应用中的native库`。本文先介绍如何交叉编译`Valgrind`工具到Android，然后介绍`纯native的程序`的分析优化过程，`App应用中的native库`分析优化留待下一篇。  

### Valgrind交叉编译

ndk本身就提供了交叉编译工具链，详见目录`$NDK_HOME/toolchains`：  

![image](../img/Valgrind05.png)

包括`arm`、`aarch64`(64位ARM架构)、`mipsel`（32位mips架构）、`mips64el`（64位mips架构）、`x86`、`x86_64`（64位X86架构）六种架构的编译工具链，其中每一种架构都有多种编译器可供选择，如`arm`架构可供选择的编译器有`gcc-4.8`、`gcc-4.9`、`clang-3.5`、`clang-3.6`、`clang-3.4-obfuscator`，其中`clang-3.4-obfuscator`是我自己定制的支持native代码混淆的clang编译器。  