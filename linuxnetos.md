#linux网络编程
- 函数指针
   - 定义方法，将函数名换成指针,void myfun(int x), void(\*func)(int),func是一个指针，通过这个指针就能用这个函数，typedef定义一个新类型，typedef void(\*func)(int),此时func是一个新类型代表一个指向函数的指针，在用时需要通过func fun来定义一个对象，通过对象对函数进行操作，在函数指针作为参数时，直接将函数名传进去进行了。函数指针在定义时说明了函数参数，函数返回类型，没有说明函数名，所以可以将函数指针指向不同的函数，但是函数的参数类型和返回类型必须要一样，来调用不同的函数实现不同的方法。
   - 回调函数，就是函数指针的一种用法，回调函数就是一个通过函数指针调用的函数。如果你把函数的指针（地址）作为参数传递给另一个函数，当这个指针被用来调用其所指向的函数时，我们就说这是回调函数。回调函数不是由该函数的实现方直接调用，而是在特定的事件或条件发生时由另外的一方调用的，用于对该事件或条件进行响应。
   - 回调函数，只管实现，不管调用，epoll使用回调函数
      - 回调函数在什么场景有用？我要在特定时候执行一个任务，至于是什么时候我自己都不知道。比如某一时间到了或者某一事件发生或者某一中断触发。
      - 回调函数怎么起作用？把我要执行的这个任务写成一个函数，将这个函数和某一时间或者事件或者中断建立关联。当这个关联完成的时候，这个函数华丽的从普通函数变身成为回调函数。
      - 回调函数什么时候执行？当该回调函数关心的那个时间或者事件或者中断触发的时候，回调函数将被执行。一般是触发这个时间、事件或中断的程序主体（通常是个函数或者对象）观察到有一个关注这个东东的回调函数的时候，这个主体负责调用这个回调函数。
      - 回调函数有什么好处？最大的好处是你的程序变成异步了。也就是你不必再调用这个函数的时候一直等待这个时间的到达、事件的发生或中断的发生（万一一直不发生，你的程序会怎么样？）。再此期间你可以做做别的事情，或者四处逛逛。当回调函数被执行时，你的程序重新得到执行的机会，此时你可以继续做必要的事情了。
   - [epoll](https://blog.csdn.net/zxh2075/article/details/79308157)
##基础知识理解
- 在创建好socket并accept后，新建一个子进程进行操作，当在父进程中close()accept返回的sockfd时连接不会断开，因为父子进程同时打开了这个socket，inode变为2，只有变为0才会关闭，在父进程中关了就相当于父进程不连接了，子进程自己去连接
- getchar是干掉回车\n，scanf输入时会在末尾加入回车
- int sprintf(char \*str, const char \*format, ...);将format中的字符写到str中
- strlen和sizeof不一样，strlen是字符数组，sizeof可以是类类型，在服务器端send时需要使用strlen(buff)，因为存在分包和粘包的情况
- int kill(pid_t pid, int sig);给进程发信号，linux系统有64个信号，使用kill -l查看
- ctrl + c发送的是SIGINT信号2，signal函数signal(,)里面两个参数，第一个是kill -l的，第二个是捕获之后要干的事情，一般为一个函数
- argc和argv，argument count的缩写，表示传入main函数的参数个数，argv是argument vector的缩写，arg[0]是程序的名称，包含了程序的完整路径，剩下的是传进去的参数。
## socket编程
- void bzero(void \*s, size_t n);n为字节数，一般为sizeof()
- void \*memset(void \*s, int c, size_t n);
- struct sockaddr, struct sockaddr_in, in代表internet
```c++
struct sockaddr_in {
    short int sin_family; Internet地址族，AF_INET
    unsigned short int sin_port; 端口号
    struct in_addr sin_addr; Internet地址
    unsigned char sin_zero[8]; 添0和struct sockaddr 一样大小
}
struct in_addr {
    unsigned long s_addr; 如果ina是一个sockaddr_in结构，ina.sin_addr.s_addr就是四个字节的IP地址
}
```
- 主机字节序&网络字节序，32网络字节序是0-7bit先传输，最后是34-31bit，主机字节序是电脑上存储的大端小端模式。其相关的转换函数:h代表主机，to代表转换到，n代表网络，s代表short数据，l代表long, struct sockaddr_in中的sin_port和sin_addr是网络字节序  
```c++
uint32_t htonl(uint32_t hostlong);
uint16_t htons(uint16_t hostshort);
uint32_t ntohl(uint32_t netlong);
uint16_t ntohs(uint16_t netshort);
```
- IP地址转换，in_addr_t inet_addr(const char \*ip);将数字和点表示的IP地址转换成无符号长整形，ina.sin_addr.s_addr = inet_addr("10.1.54.69"),反过来将网络字节序转换为数字和点表示的，char \*inet_ntoa(struct in_addr in);cout << inet_ntoa(ina.sin_addr),inet_ntoa()返回一个字符指针，指向static类型，所以多次调用时要另外保存一下。
- int socket(int domain, int type, int protocol); AF_INET,SOCK_STREAM,0，返回socket描述符
- int bind(int sockfd, const struct sockaddr \*addr, socklen_t addrlen);0成功，-1失败，addrlen表示结构体大小，复制或传输时使用，bind自动设置IP地址和端口，my_addr.sin_port = 0;my_addr.sin_addr.s_addr = htonl(INADDR_ANY);
```c++
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#define _INT_PORT 9257

int main(void)
{
    int sockfd;                                             // 定义套接字
    struct sockaddr_in my_addr;                             // 定义存储本地地址信息的结构体
    sockfd = socket(PF_INET, SOCK_STREAM, 0);               // 创建套接字
    
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(_INT_PORT);
    my_addr.sin_addr.s_addr = inet_addr("132.241.5.10");
    
    bzero(&(my_addr.sin_zero), sizeof(my_addr.sin_zero));
    if(bind(sockfd, (struct sockaddr *)&my_addr,sizeof(struct sockaddr_in)) == -1){         // 绑定套接字
        fprintf(stderr, "Bind socket error, %s\n", perror(errno));
        exit(errno);
    }
}
```
- connect函数，int connect(int sockfd, const struct sockaddr \*addr, socklen_t addrlen);addr代表服务器的IP地址和端口，0成功，-1失败
- listen，int listen(int sockfd, int backlog);backlog 是未经过处理的连接请求队列可以容纳的最大数目,一般设置为5-10，0成功，-1失败
- accept, int accept(int sockfd, struct sockaddr \*addr, socklen_t \*addrlen);accept 调用时,服务器端的程序会一直阻塞到有一个客户程序发出了连接. accept 成功时返回最后的服务器端的文件描述符,这个时候服务器端可以通过该描述符进行send() 和 recv()操作. 失败时返回-1
```c++
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#define SET_PORT 3490
int main(void)
{
    int sockfd, new_fd;
    struct sockaddr_in my_addr;
    struct sockaddr_in their_addr;
    int sin_size;
    
    sockfd = socket(PF_INET, SOCK_STREAM, 0);
    
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(_INT_PORT);
    my_addr.sin_addr.s_addr = INADDR_ANY;
    
    bzero(&(my_addr.sin_zero),sizeof(my_addr.sin_zero));
    bind(sockfd, (struct sockaddr *)&my_addr,sizeof(struct sockaddr));// 绑定套接字
    
    listen(sockfd, 10);                                                     // 监听套接字
    
    sin_size = sizeof(struct sockaddr_in);
    new_fd = accept(sockfd, &their_addr, &sin_size);                        // 接收套接字
}
```
- ![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/linuxnetos/tcp.png)
- ssize_t send(int sockfd, const void \*buf, size_t len, int flags);返回实际发送的字节数
- ssize_t recv(int sockfd, void \*buf, size_t len, int flags);返回实际读入缓冲的数据的字节数
---
```c++
server.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <errno.h>

#define SERVADDR_PORT 8800

const char *LOCALIP = "127.0.0.1";

int main(int argc, char const *argv[])
{
    // 定义变量存储生成或接收的套接字描述符
    int listenfd, recvfd;
    // 定义一个数据结构用来存储套接字的协议,ip,端口等地址结构信息
    struct sockaddr_in servaddr, clientaddr;
    // 定义接收的套接字的数据结构的大小
    unsigned int cliaddr_len, recvLen;
    char recvBuf[1024];

    //创建用于帧听的套接字
    listenfd = socket(AF_INET, SOCK_STREAM, 0);

    // 给套接字数据结构赋值,指定ip地址和端口号
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(SERVADDR_PORT);
    servaddr.sin_addr.s_addr = inet_addr(LOCALIP);

    // 绑定套接字
    if(bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) == -1){
        fprintf(stderr, "绑定套接字失败,%s\n", strerror(errno));
        exit(errno);
    }

    // 监听请求
    if(listen(listenfd, 10) == -1){
        fprintf(stderr, "绑定套接字失败,%s\n", strerror(errno));
        exit(errno);
    }

    cliaddr_len = sizeof(struct sockaddr);

    // 等待连接请求
    while (1){
        // 接受由客户机进程调用connet函数发出的连接请求
        recvfd = accept(listenfd, (struct sockaddr *)&clientaddr, &cliaddr_len);
        printf("接收到请求套接字描述符: %d\n", recvfd);

        while(1){
            // 在已建立连接的套接字上接收数据
            if((recvLen = recv(recvfd, recvBuf, 1024, 0)) == -1){
                fprintf(stderr,"接收数据错误, %s\n",strerror(errno));
            }
            printf("%s", recvBuf);
        }
    }
    close(recvfd);
    return 0;
}
```
```c++
client.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <string.h>
extern int errno;

#define SERVERPORT 8800

int main(int argc, char const *argv[])
{
    // 定义变量存储本地套接字描述符
    int clifd;
    // 设置本地ip地址
    const char serverIp[] = "127.0.0.1";
    // 定义套接字结构存储套接字的ip,port等信息
    struct sockaddr_in cliaddr_in;
    // 定义发送,接收缓冲区大小
    char sendBuf[1024], recvBuf[1024];

    // 创建套接字
    if((clifd = socket(AF_INET, SOCK_STREAM, 0)) == -1){
        fprintf(stderr, "创建套接字失败,%s\n", strerror(errno));
        exit(errno);
    }

    // 填充 服务器端结构体信息
    cliaddr_in.sin_family = AF_INET;
    cliaddr_in.sin_addr.s_addr = inet_addr(serverIp);
    cliaddr_in.sin_port = htons(SERVERPORT);

    // 请求连接服务器进程
    if(connect(clifd, (struct sockaddr *)&cliaddr_in, sizeof(struct sockaddr)) == -1){
        fprintf(stderr,"请求连接服务器失败, %s\n", strerror(errno));
        exit(errno);
    }
    strcpy(sendBuf, "hi,hi, severs!\n");
    // 发送打招呼消息
    if(send(clifd, sendBuf, 1024, 0) == -1){
        fprintf(stderr, "send message error:(, %s\n", strerror(errno));
        exit(errno);
    }
    // 阻塞等待输入,发送消息
    while(1){
        fgets(sendBuf, 1024, stdin);
        if(send(clifd, sendBuf, 1024, 0) == -1){
            fprintf(stderr, "send message error:(, %s\n", strerror(errno));
        }
    }
    close(clifd);
    return 0;
}
```
---
## 五种I/O模式
- IO操作并不直接操作磁盘而是和内存进行交互，即在内存中设置buffer来进行操作，buffer很小，数据很大时就需要多次操作buffer，但是这是内核自动操作的。
- select函数，int select(int nfds, fd_set \*readfds, fd_set \*writefds, fd_set \*exceptfds, struct timeval \*timeout);read的集合，写的集合，异常的集合。变成ready的方式，无阻塞的read或者足够小的写。没有集合去监控可以设置为NULL
   - FD_ZERO()  clears  a set.   FD_SET()  and  FD_CLR() respectively add and remove a given file descriptor from a set.  FD_ISSET() tests to see if a file descriptor is part of the set; this is useful after select() returns.
   - nfds应该是3个集合中最大的加1，表示遍历到这不遍历了
   - timeout设置为NULL将会无限期阻塞 timeval结构体struct timeval { long tv_sec;/* seconds */ long tv_usec; /* microseconds */ };两个设置为0是不阻塞直接返回，设置为>0就是阻塞时间到了就返回。
   - 返回值，-1代表错误，0代表超时返回，正数代表成功。
   - 有事件发生后，使用FD_ISSET来判断事件的发生，在进行后续的IO操作
- 数组作为函数的参数会退化为指针，所以数组要当函数参数传递时，要传进去数组的大小，查看影响范围，指针不知道影响范围  
- poll函数，int poll(struct pollfd \*fds, nfds_t nfds, int timeout);
   - struct pollfd {
               int   fd;         /* file descriptor */
               short events;     /* requested events */
               short revents;    /* returned events */
           };
   - 其中events和revents是bit mask，有一些全是大写字母的bit mask，revents是返回的，当有事件发生时系统内核设置revents，revents有3个值，所以要查看是哪个需要将revents&POLLERR == POLLERR这样，要不然得写很多循环一个一个判断。  
[epoll理解](https://zhuanlan.zhihu.com/p/159135478)
- epoll
   - 边缘触发(ET)和水平触发(LT)，边缘触发只响应一次，水平触发响应好多次
   - epoll_create函数 int epoll_create(int size);  int epoll_create1(int flags);返回不epfd如果不用需要close关掉
   - epoll_ctl函数 int epoll_ctl(int epfd, int op, int fd, struct epoll_event \*event);epfd是epoll_create创建后返回的，op是操作有三个位掩码，fd是需要检测的，0成功，-1失败
   - epoll_wait函数 int epoll_wait(int epfd, struct epoll_event \*events, int maxevents, int timeout);
   - 结构体
```c++
typedef union epoll_data {
     void    *ptr;
     int      fd;
     uint32_t u32;
     uint64_t u64;
 } epoll_data_t;

 struct epoll_event {
     uint32_t     events;    /* Epoll events */
     epoll_data_t data;      /* User data variable */
 };
```
```c++
#define MAX_EVENTS 10
struct epoll_event ev, events[MAX_EVENTS];
int listen_sock, conn_sock, nfds, epollfd;

/* Code to set up listening socket, 'listen_sock',
   (socket(), bind(), listen()) omitted */

epollfd = epoll_create1(0);
if (epollfd == -1) {
    perror("epoll_create1");
    exit(EXIT_FAILURE);
}

ev.events = EPOLLIN;
ev.data.fd = listen_sock;
if (epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &ev) == -1) {
    perror("epoll_ctl: listen_sock");
    exit(EXIT_FAILURE);
}

for (;;) {
    nfds = epoll_wait(epollfd, events, MAX_EVENTS, -1);//将返回的事件放到events里面
    if (nfds == -1) {
        perror("epoll_wait");
        exit(EXIT_FAILURE);
    }

    for (n = 0; n < nfds; ++n) {
        if (events[n].data.fd == listen_sock) { //如果监听的listen套接字返回了，就执行下面的说明要bind，否则执行 else里面do_use_fd
            conn_sock = accept(listen_sock,
                               (struct sockaddr *) &addr, &addrlen);
            if (conn_sock == -1) {
                perror("accept");
                exit(EXIT_FAILURE);
            }
            setnonblocking(conn_sock);
            ev.events = EPOLLIN | EPOLLET;
            ev.data.fd = conn_sock;
            if (epoll_ctl(epollfd, EPOLL_CTL_ADD, conn_sock, //将accpet套接字加入到epoll实例中，conn_sock每次都是不一样的，所以用一个变量就可以
                        &ev) == -1) {
                perror("epoll_ctl: conn_sock");
                exit(EXIT_FAILURE);
            }
        } else {
            do_use_fd(events[n].data.fd);
        }
    }
}
```

---
## 多线程编程
- fork, pid_t fork(void);子进程和父进程基本一样，包括fork之前定义的数据，子进程和父进程不同的在man手册里有显示，子进程不会继承父进程内存锁
- top可以查看僵尸进程,Z是僵尸进程，ps -aux | grep Z
- wait, pid_t wait(int \*wstatus); wait函数阻塞自己，收集子进程的信息，回收子进程资源，当参数为NULL时不管如何死的，如何有参数就是可以观察如何死的
- exec一组函数，用新的进程替代当前进程，进程ID不会改变
- 父进程中的数据子进程会继承，但是其不是一样的，相当于赋值了一份，叫一个名字，但是相互不影响
- 进程是一个一个执行的，cpu时间片
- 原子操作:不可被中断的一个或一系列操作
- 进程间通信，共享内存
   - shmget，int shmget(key_t key, size_t size, int shmflg);
   - shmat，  void \*shmat(int shmid, const void \*shmaddr, int shmflg);
   - ftok, key_t ftok(const char \*pathname, int proj_id);
- 判断线程是否相等不能用线程ID，需要使用pthread_equal. int pthread_equal(pthread_t t1, pthread_t t2);相等返回非0，不相等返回0；
- pthread_create,
---
- pthread_create.int pthread_create(pthread_t \*thread, const pthread_attr_t \*attr,void \*(\*start_routine) (void \*), void \*arg);void \*(\*start_routine)(void \*),是线程函数，线程创建之后要执行的，后面的arg是给线程函数的参数，用来初始化的，arrt是用来创建线程属性的，NULL表示默认的线程属性，arg可以是结构体
- 线程函数的写法
```
void *sell_ticket(void *arg)
{
    for(int i=0; i<20; i++)
    {
        if(ticket_sum>0)
        {
            sleep(1);
            cout<<"sell the "<<20-ticket_sum+1<<"th"<<endl;
            ticket_sum--;
        }
    }
    return 0;
}
```
- 线程结束，可以调用pthread_exit(),或者线程函数return，如果其他线程调用exit也会牵连到
- int pthread_join(pthread_t thread, void \*\*retval);此函数会等待新创建的线程执行完线程函数，会一直阻塞着等待结束，此函数可以放在return 0前面，return 0 返回后主线程就结束了，引发错误
---
## 一些函数
- fseek, int fseek(FILE \*stream, long offset, int whence);whence选项有SEEK_SET,SEEK_CUR, SEEK_END
- ftell，long ftell(FILE \*stream); fseek函数将指针设置到末尾，ftell函数获取当前的文件的大小。
- rewind, void rewind(FILE \*stream);将文件指针放在开始处
- fopen, FILE \*fopen(const char \*pathname, const char \*mode); mode为r，r+， w， w+这类
- fread, size_t fread(void \*ptr, size_t size, size_t nmemb, FILE \*stream); 
- fwrite，size_t fwrite(const void \*ptr, size_t size, size_t nmemb, FILE \*stream);
- open
- read
- write
- opendir
- readdir
- flock，int flock(int fd, int operation);operation包括 LOCK_SH, LOCK_EX, LOCK_UN,成功0，-1失败
---
## IPC
- 管道pipe，int pipe(int pipefd[2]);适用于有血缘关系的进程，例如父子进程。
- popen函数，前面说到，用pipe函数就能创建管道，但是它比较原始。我们需要自己创建子进程、自己创建管道、创建完管道获得管道的文件描述符后需要自己关闭管道两端的某些接口，popen函数封装好了
- mmap
- atoi
- fstat
--- 
## 信号量
- man 7 sem_overview可以查看信号量介绍
- int sem_init(sem_t \*sem, int pshared, unsigned int value);
- PV操作是一种实现进程互斥与同步的有效方法
- sem_post,int sem_post(sem_t \*sem);解锁操作，信号灯加1
- int sem_wait(sem_t \*sem);线程调用sem_wait取获取这个信号灯，第一个线程一看，有1个，他就拿到了，然后可以继续后继操作，此时信号灯自动减1，变成0个。那么第二个线程调用sem_wait时就会阻塞
- int sem_destroy(sem_t \*sem);清理信号量
- int semget(key_t key, int nsems, int semflg);
- semget,semctl.semop是系统v的接口，意思是旧的，sem_init,sem_post,sem_wait这些是新的POISX的接口
- 信号量使用时可以让一个线程等着另一个线程使用post加1，而这个线程阻塞着
---
## 消息队列
- 消息队列，Unix的通信机制之一，可以理解为是一个存放消息（数据）容器。将消息写入消息队列，然后再从消息队列中取消息，一般来说是先进先出的顺序。可以解决两个进程的读写速度不同（处理数据速度不同），系统耦合等问题，而且消息队列里的消息哪怕进程崩溃了也不会消失。
- ftok函数生成键值，msgget函数创建消息队列，msgsnd函数往消息队列发送消息，msgrcv函数从消息队列读取消息,msgctl函数进行删除消息队列
- int msgget(key_t key, int msgflg);创建消息队列
- int msgsnd(int msqid, const void \*msgp, size_t msgsz, int msgflg);msgp是一个数据结构体，发送的数据存放在里面
   - struct msgbuf {
               long mtype;       /* message type, must be > 0 */
               char mtext[1];    /* message data */char数组里面的值可以修改
           };
- ssize_t msgrcv(int msqid, void \*msgp, size_t msgsz, long msgtyp, int msgflg);
- int msgctl(int msqid, int cmd, struct msqid_ds \*buf);
---
## 信号与时间
- raise
- signal，可以选择屏蔽信号，杀死信号，执行信号函数，默认是杀死信号，signal是一个捕鼠夹子，到了才会执行函数，没有信号就异步执行下面的程序
- pause
- alarm，发送一个SIGALRM信号，延迟几秒钟
- 时间
- getitimer, setitimer，间隔一段时间
---
## 读写锁
- 
---
## 共享内存
- int shmget(key_t key, size_t size, int shmflg);只要key相等，shmget返回的id就相等
- key_t ftok(const char \*pathname, int proj_id);返回的是key
- void \*shmat(int shmid, const void \*shmaddr, int shmflg);shmaddr一般为NULL，一般返回共享内存的地址
- 上面三个函数用来设置一块共享内存，设置完后所有的进程都可以访问，放在fork前面
- ipcs可以查看共享内存 ipcrm可以删除共享内存
- shmget函数有权限问题，需要在shmflg后面加权限 |0666，可以读写
- attr表示属性
- 线程的互斥锁可以在线程中使用，但是需要设置属性，pthread_mutexattr_搜索线程互斥锁在进程中的使用
- 程序中最慢的就是IO操作，上锁就是不让其他线程同时访问重要的文件，可以在print之前解锁
- 要仔细查看解锁是在哪里解的，break之后也需要解锁，不访问这个函数了，但是break之后需要将锁解掉
- 线程互斥锁的初始化，pthread_mutex_init(),
## 条件变量
- pthread_cond_t
- pthread_cond_wait,wait就是等待，等待条件的成立，条件成立后用signal给cond发送信号就可以，没有信号就一直在wait那等着int pthread_cond_wait(pthread_cond_t \*cond, pthread_mutex_t \*mutex),条件变量用于某个线程需要在某种条件成立时才去保护它将要操作的临界区，这种情况从而避免了线程不断轮询检查该条件是否成立而降低效率的情况，这是实现了效率提高。在条件满足时，自动退出阻塞，再加锁进行操作。
- pthread_cond_signal,激发条件有两种形式，pthread_cond_signal()激活一个等待该条件的线程，存在多个等待线程时按入队顺序激活其中一个；而pthread_cond_broadcast()则激活所有等待线程。
- 必须和一个互斥锁配合，以防止多个线程同时请求pthread_cond_wait
- 条件变量用于某个线程需要在某种条件成立时才去保护它将要操作的临界区，这种情况从而避免了线程不断轮询检查该条件是否成立而降低效率的情况，这是实现了效率提高。在条件满足时，自动退出阻塞，再加锁进行操作。
- 互斥锁锁住的是共享变量即全局变量，在函数外定义的变量是全局变量，main函数也是函数，其里面定义的也是局部变量。
- 在条件变量等待时，当前进程挂起，此时要把锁丢掉，要不然别的进程也不能用，此操作是通过pthread_cond_wait()函数自动实现的，不同解锁，因为此函数有一个互斥锁参数，传进去线程阻塞，但是锁被解开
- 条件变量都用互斥锁进行保护，条件变量状态的改变都应该先锁住互斥锁，pthread_cond_wait()需要传入一个已经加锁的互斥锁，该函数把调用线程加入等待条件的调用列表中，然后释放互斥锁，在条件满足从而离开pthread_cond_wait()时，mutex将被重新加锁，这两个函数是原子操作。
---
- 指向数组的指针强转为指向结构体的指针。在buffer中只能是char类型的，但是传送信息的时候有可能是struct类型的，强转后就相当于可以通过强转之后的指针操作数组里的内容让其按结构体数据类型发送和接受
struct msgHdr{
    int fd;                     // 套接字描述符
    ushort tip;                 // 0 进入聊天室,    1 离开聊天室    2 发送消息
    ushort onLineNum;           // 在线人数
};
struct msgHdr \*sendMsgHdr, recvMsgHdr = (struct msgHdr \*)recvbuf; recvMsgHdr->fd = dealfd;
- 相当于数组大小没变，但是前几个字节的类型变为结构体类型了，结构体可以通过结构体方法取用和设置。
- 在线程创建中，最后一个参数不一样创建出来的线程也不一样，
