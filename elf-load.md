### 动态连接器

- 动态链接器是操作系统的一部分，负责按照[可执行程序](https://zh.wikipedia.org/wiki/可执行程序)[运行时](https://zh.wikipedia.org/wiki/运行时)的需要装入与链接[共享库](https://zh.wikipedia.org/wiki/共享库)。装入是指把共享库在永久存储上的内容复制到内存，链接是指填充跳转表（jump table）与重定位指针。
- 当[应用程序](https://zh.wikipedia.org/wiki/应用程序)需要使用[动态链接库](https://zh.wikipedia.org/wiki/动态链接库)里的[函数](https://zh.wikipedia.org/wiki/函数)时，由ld.so负责加载。搜索[动态链接库](https://zh.wikipedia.org/wiki/动态链接库)的顺序依此是
  - [环境变量](https://zh.wikipedia.org/wiki/环境变量)LD_AOUT_LIBRARY_PATH（[a.out](https://zh.wikipedia.org/wiki/A.out)格式）、LD_LIBRARY_PATH（[ELF](https://zh.wikipedia.org/wiki/ELF)格式）；在[Linux](https://zh.wikipedia.org/wiki/Linux)中，LD_PRELOAD指定的目录具有最高优先权[[1\]](https://zh.wikipedia.org/wiki/动态连接器#cite_note-找出并保护程序的入口-1)。
  - [缓存](https://zh.wikipedia.org/wiki/缓存)文件/etc/ld.so.cache。此为上述环境变量指定目录的二进制索引文件。更新缓存的命令是[ldconfig](https://zh.wikipedia.org/w/index.php?title=Ldconfig&action=edit&redlink=1)。
  - 默认目录，先在/lib中寻找，再到/usr/lib中寻找。

