##linux网络编程
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


---
## 多线程编程
- 判断线程是否相等不能用线程ID，需要使用pthread_equal. int pthread_equal(pthread_t t1, pthread_t t2);相等返回非0，不相等返回0；
- pthread_create,















