### 文件操作
- 字母全部大写在c语言中表示宏定义 O_CREAT,ulimit -a 可以查看系统的限制，例如文件描述符fd·
- open fopen write close read fwrite fclose fread
- opendir readdir closedir stat lstat getpwuid getgrgid
### 阻塞与非阻塞IO
- 用户态内核态
- fcntl IO感知
- select 多路复用 nfds文件描述符数量
多进程的接口 fork wait exec
