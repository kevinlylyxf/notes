### c

##### 线程池

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>
#include <assert.h>
/*
*线程池里所有运行和等待的任务都是一个CThread_worker
*由于所有任务都在链表里，所以是一个链表结构
*/
typedef struct worker
{
    /*回调函数，任务运行时会调用此函数，注意也可声明成其它形式*/
    void *(*process) (void *arg);
    void *arg;/*回调函数的参数*/
    struct worker *next;
} CThread_worker;

/*线程池结构*/
typedef struct
{
    pthread_mutex_t queue_lock;
    pthread_cond_t queue_ready;
    /*链表结构，线程池中所有等待任务*/
    CThread_worker *queue_head;
    /*是否销毁线程池*/
    int shutdown;
    pthread_t *threadid;
    /*线程池中允许的活动线程数目*/
    int max_thread_num;
    /*当前等待队列的任务数目*/
    int cur_queue_size;
} CThread_pool;

int pool_add_worker (void *(*process) (void *arg), void *arg);
void *thread_routine (void *arg);

static CThread_pool *pool = NULL;
void pool_init (int max_thread_num)
{
    pool = (CThread_pool *) malloc (sizeof (CThread_pool));
    pthread_mutex_init (&(pool->queue_lock), NULL);
    pthread_cond_init (&(pool->queue_ready), NULL);
    pool->queue_head = NULL;
    pool->max_thread_num = max_thread_num;
    pool->cur_queue_size = 0;
    pool->shutdown = 0;
    pool->threadid =
        (pthread_t *) malloc (max_thread_num * sizeof (pthread_t));
    int i = 0;
    for (i = 0; i < max_thread_num; i++)
    { 
        pthread_create (&(pool->threadid[i]), NULL, thread_routine,
                NULL);
    }
}

/*向线程池中加入任务*/
int pool_add_worker (void *(*process) (void *arg), void *arg)
{
    /*构造一个新任务*/
    CThread_worker *newworker =
        (CThread_worker *) malloc (sizeof (CThread_worker));
    newworker->process = process;
    newworker->arg = arg;
    newworker->next = NULL;/*别忘置空*/
    pthread_mutex_lock (&(pool->queue_lock));
    /*将任务加入到等待队列中*/
    CThread_worker *member = pool->queue_head;
    if (member != NULL)
    {
        while (member->next != NULL)
            member = member->next;
        member->next = newworker;
    }
    else
    {
        pool->queue_head = newworker;
    }
    assert (pool->queue_head != NULL);
    pool->cur_queue_size++;
    pthread_mutex_unlock (&(pool->queue_lock));
    /*好了，等待队列中有任务了，唤醒一个等待线程；
    注意如果所有线程都在忙碌，这句没有任何作用*/
    pthread_cond_signal (&(pool->queue_ready));
    return 0;
}

/*销毁线程池，等待队列中的任务不会再被执行，但是正在运行的线程会一直
把任务运行完后再退出*/
int pool_destroy ()
{
    if (pool->shutdown)
        return -1;/*防止两次调用*/
    pool->shutdown = 1;
    /*唤醒所有等待线程，线程池要销毁了*/
    pthread_cond_broadcast (&(pool->queue_ready));
    /*阻塞等待线程退出，否则就成僵尸了*/
    int i;
    for (i = 0; i < pool->max_thread_num; i++)
        pthread_join (pool->threadid[i], NULL);
    free (pool->threadid);
    /*销毁等待队列*/
    CThread_worker *head = NULL;
    while (pool->queue_head != NULL)
    {
        head = pool->queue_head;
        pool->queue_head = pool->queue_head->next;
        free (head);
    }
    /*条件变量和互斥量也别忘了销毁*/
    pthread_mutex_destroy(&(pool->queue_lock));
    pthread_cond_destroy(&(pool->queue_ready));
    
    free (pool);
    /*销毁后指针置空是个好习惯*/
    pool=NULL;
    return 0;
}

//非常重要的任务接口函数，各子线程统一调用这个函数，而这个函数内部检查调用任务队列中的实际任务函数指针。
void * thread_routine (void *arg)
{
    printf ("starting thread 0x%x/n", pthread_self ());
    while (1)
    {
        pthread_mutex_lock (&(pool->queue_lock));
        /*如果等待队列为0并且不销毁线程池，则处于阻塞状态; 注意
        pthread_cond_wait是一个原子操作，等待前会解锁，唤醒后会加锁*/
        while (pool->cur_queue_size == 0 && !pool->shutdown)
        {
            printf ("thread 0x%x is waiting/n", pthread_self ());
            pthread_cond_wait (&(pool->queue_ready), &(pool->queue_lock));
        }
        /*线程池要销毁了*/
        if (pool->shutdown)
        {
            /*遇到break,continue,return等跳转语句，千万不要忘记先解锁*/
            pthread_mutex_unlock (&(pool->queue_lock));
            printf ("thread 0x%x will exit/n", pthread_self ());
            pthread_exit (NULL);
        }
        printf ("thread 0x%x is starting to work/n", pthread_self ());
        /*assert是调试的好帮手*/
        assert (pool->cur_queue_size != 0);
        assert (pool->queue_head != NULL);
        
        /*等待队列长度减去1，并取出链表中的头元素*/
        pool->cur_queue_size--;
        CThread_worker *worker = pool->queue_head;
        pool->queue_head = worker->next;
        pthread_mutex_unlock (&(pool->queue_lock));
        /*调用回调函数，执行任务*/
        (*(worker->process)) (worker->arg);
        free (worker);
        worker = NULL;
    }
    /*这一句应该是不可达的*/
    pthread_exit (NULL);
}

测试代码
void * myprocess (void *arg)
{
    printf ("threadid is 0x%x, working on task %d/n", pthread_self (),*(int *) arg);
    sleep (1);/*休息一秒，延长任务的执行时间*/
    return NULL;
}

int main (int argc, char **argv)
{
    pool_init (3);/*线程池中最多三个活动线程*/
    
    /*连续向池中投入10个任务*/
    int *workingnum = (int *) malloc (sizeof (int) * 10);
    int i;
    for (i = 0; i < 10; i++)
    {
        workingnum[i] = i;
        pool_add_worker (myprocess, &workingnum[i]);
    }
    /*等待所有任务完成*/
    sleep (5);  //这句可能出问题，偷懒写法。
    /*销毁线程池*/
    pool_destroy ();
    free (workingnum);
    return 0;
}

将上述所有代码放入threadpool.c文件中
gcc -o threadpool threadpool.c -lpthread
starting thread 0xb7df6b90
thread 0xb7df6b90 is waiting
starting thread 0xb75f5b90
thread 0xb75f5b90 is waiting
starting thread 0xb6df4b90
thread 0xb6df4b90 is waiting
thread 0xb7df6b90 is starting to work
threadid is 0xb7df6b90, working on task 0
thread 0xb75f5b90 is starting to work
threadid is 0xb75f5b90, working on task 1
thread 0xb6df4b90 is starting to work
threadid is 0xb6df4b90, working on task 2
thread 0xb7df6b90 is starting to work
threadid is 0xb7df6b90, working on task 3
thread 0xb75f5b90 is starting to work
threadid is 0xb75f5b90, working on task 4
thread 0xb6df4b90 is starting to work
threadid is 0xb6df4b90, working on task 5
thread 0xb7df6b90 is starting to work
threadid is 0xb7df6b90, working on task 6
thread 0xb75f5b90 is starting to work
threadid is 0xb75f5b90, working on task 7
thread 0xb6df4b90 is starting to work
threadid is 0xb6df4b90, working on task 8
thread 0xb7df6b90 is starting to work
threadid is 0xb7df6b90, working on task 9
thread 0xb75f5b90 is waiting
thread 0xb6df4b90 is waiting
thread 0xb7df6b90 is waiting
thread 0xb75f5b90 will exit
thread 0xb6df4b90 will exit
thread 0xb7df6b90 will exit
```



##### umask

- 在linux)系统中，我们创建一个新的文件或者目录的时候，这些新的文件或目录都会有默认的访问权限，umask命令与文件和目录的默认访问权限有关。若用户创建一个文件，则文件的默认访问权限为 -rw-rw-rw- ，创建目录的默认权限 drwxrwxrwx ，而umask值则表明了需要从默认权限中去掉哪些权限来成为最终的默认权限值。

- umask值的含义和使用，在shell中可以查看umask值

  ```
  hadoop@sench-pc:~$ umask 
  0002
  
  umask 命令显示的为umask的数字值，还可以使用命令 umask -S 来显示umask的符号值：
  hadoop@sench-pc:~$ umask -S
  u=rwx,g=rwx,o=rx
  ```

  - 可以看到umask值为0002，其中第一个0与特殊权限有关，可以暂时不用理会，后三位002则与普通权限(rwx)有关，其中002中第一个0与用户(user)权限有关，表示从用户权限减0，也就是权限不变，所以文件的创建者的权限是默认权限(rw)，第二个0与组权限（group）有关，表示从组的权限减0，所以群组的权限也保持默认权限（rw），最后一位2则与系统中其他用户（others）的权限有关，由于w=2，所以需要从其他用户默认权限（rw）减去2，也就是去掉写（w）权限，则其他人的权限为rw - w = r，则创建文件的最终默认权限为 -rw-rw-r-- 。同理，目录的默认权限为 drwxrwxrwx ，则d rwx rwx rwx - 002 = (d rwx rwx rwx) - (- --- --- -w-) = d rwx rwx r-x，所以用户创建目录的默认访问权限为 drwxrwxr-x

- 更改umask值，可以通过命令 umask 值 的方式来更改umask值，比如我要把umask值改为027，则使用命令 umask 027 即可。改成027后，用户权限不变，群组权限减掉2，也就是去掉写（w）权限，其他用户减7，也就是去掉读写执行权限(rwx)，所以其他用户没有访问权限。可以看到文件的默认访问权限变为了 -rw-r----- ，目录test的默认访问权限变为了 drwxr-x--- 。这种方式并不能永久改变umask值，只是改变了当前会话的umask值，打开一个新的terminal输入umask命令，可以看到umask值仍是默认的002。要想永久改变umask值，则可以修改文件/etc/bashrc，在文件中添加一行 umask 027 。

- c语言中umask函数

  ```
  mode_t umask(mode_t mask);
  ```

  - umask()会将系统umask值设成参数mask&0777后的值, 然后将先前的umask值返回。在使用open()建立新文件时, 该参数mode 并非真正建立文件的权限, 而是(mode&~umask)的权限值。
  - 例如，在建立文件时指定文件权限为0666, 通常umask 值默认为022, 则该文件的真正权限则为0666&～022＝0644, 也就是rw-r--r--返回值此调用不会有错误值返回. 返回值为原先系统的umask 值。

##### stdout,stderr

```
#include <stdio.h>
extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;
```

- 错误流 stderr 是非缓冲的。输出流 stdout 是行缓冲的，如果它指向一个终端。不完全的行只有在调用 fflush(3) 或 exit(3)，或者打印了新行符之后才会显示。这样可能带来无法预料的结果，尤其是调试输出时。标准流 (或任何其他流) 的缓冲模式可以用函数 setbuf(3) 或 setvbuf(3)来切换。注意当 stdin 与一个终端关联时，也许终端驱动中存在输入缓冲，与 stdio 缓冲完全无关。
- 对于stdout，信息输出时总是先送入缓冲区（行间缓存），然后再输出到屏幕；而对stderr，信息是不经过缓冲区直接输入到屏幕的。因此，向stdout输出的信息是可以被重定向的，输出到stderr的信息则不能被重定向。
- 其中的重定向表示的是当执行程序的时候重定向到文件中./a.out > test.txt，对于输出到stdout中的可以重定向，对于输出到stderr中的不可以重定向，虽然重定向了，但是错误依然在屏幕上输出，文件里面没有stderr里面的输出

##### erron

- errno 是记录系统的最后一次错误代码。代码是一个int型的值，在errno.h中定义。查看错误代码errno是调试程序的一个重要方法。当linux C api函数发生异常时,一般会将errno变量(需include errno.h)赋一个整数值,不同的值表示不同的含义,可以通过查看该值推测出错的原因。在实际编程中用这一招解决了不少原本看来莫名其妙的问题。

  ```
  A common mistake is to do
  
  if (somecall() == -1) {
  	printf("somecall() failed\n");
  	if (errno == ...) { ... }
  }
  
  where  errno  no longer needs to have the value it had upon return from somecall() (i.e., it may have been changed by the printf(3)).  If the value of errno should be preserved across a library call, it must be saved:
  
  if (somecall() == -1) {
  	int errsv = errno;
  	printf("somecall() failed\n");
  	if (errsv == ...) { ... }
  }
  ```

##### perror

- 函数perror()用于抛出最近的一次系统错误信息

  ```
  void perror(char *string);
  ```

- perror()用来将上一个函数发生错误的原因输出到标准错误(stderr)。参数string所指的字符串会先打印出，后面再加上错误原因字符串，此错误原因依照全局变量errno 的值来决定要输出的字符串。

- 在库函数中有个errno变量，每个errno值对应着以字符串表示的错误类型。当你调用"某些"函数出错时，该函数已经重新设置了errno的值。perror函数只是将你输入的一些信息和现在的errno所对应的错误一起输出。

- errno是一个int类型的值，但是每一个错误类型系统对应着一个错误字符串，当用perror输出时，会直接输出这个错误对应的字符串

  ```
  【实例】打开一个不存在的文件并输出错误信息。
  #include <stdio.h>
  #include <assert.h>
  #include <stdlib.h>
  int main( void )
  {
      FILE *fp;
      fp = fopen( "test.txt", "w" );/*打开文件*/
      assert( fp ); /*断言不为空*/
      fclose( fp );/*关闭*/
      fp = fopen( "nulltest.txt", "r" );/*打开一个不存在的文件*/
      if ( NULL == fp )
      {
          /*显示最近一次错误信息*/
          perror("fopen( \"nulltest.txt\", \"r\" )");
      }
      return 0;
  }
  运行结果：
  fopen( "nulltest.txt", "r" ):No such file or directory
  ```

  - 程序先定义一个文件指针fp，之后创建文件 test.txt，断言文件打开成功，然后关闭该文件，再以只读的方式打开文件nulltest.txt，判断该文件指针是否问空，如果为空则使用 perror() 输出错误信息。perror()用来将上一个函数发生错误的原因 输出到标准设备(stderr)。函数参数string所指的字符串会先打印出， 后面再加上错误原因字符串。此错误原因依照全局变量error的值来决定要输出的字符串。

##### assert

- 对于断言，相信大家都不陌生，大多数编程语言也都有断言这一特性。简单地讲，断言就是对某种假设条件进行检查。在 C 语言中，断言被定义为宏的形式（assert(expression)），而不是函数，其原型定义在<assert.h>文件中。其中，assert 将通过检查表达式 expression 的值来决定是否需要终止执行程序。也就是说，如果表达式 expression 的值为假（即为 0），那么它将首先向标准错误流 stderr 打印一条出错信息，然后再通过调用 abort 函数终止程序运行；否则，assert 无任何作用。

- 默认情况下，assert 宏只有在 Debug 版本（内部调试版本）中才能够起作用，而在 Release 版本（发行版本）中将被忽略。当然，也可以通过定义宏或设置编译器参数等形式来在任何时候启用或者禁用断言检查（不建议这么做）。同样，在程序投入运行后，最终用户在遇到问题时也可以重新起用断言。这样可以快速发现并定位软件问题，同时对系统错误进行自动报警。对于在系统中隐藏很深，用其他手段极难发现的问题也可以通过断言进行定位，从而缩短软件问题定位时间，提高系统的可测性。

  ```
  void *MemCopy(void *dest, const void *src, size_t len)
  {
      assert(dest != NULL && src !=NULL);
      char *tmp_dest = (char *)dest;
      char *tmp_src = (char *)src;
      while(len --)
              *tmp_dest ++ = *tmp_src ++;
      return dest;
  }
  ```

  - 通过“assert(dest !=NULL&&src !=NULL)”语句既完成程序的测试检查功能（即只要在调用该函数的时候为 dest 与 src 参数错误传入 NULL 指针时都会引发 assert），与此同时，对 MemCopy 函数的代码量也进行了大幅度瘦身，不得不说这是一个两全其美的好办法。

- 实际上，在编程中我们经常会出于某种目的（如把 assert 宏定义成当发生错误时不是中止调用程序的执行，而是在发生错误的位置转入调试程序，又或者是允许用户选择让程序继续运行等）需要对 assert 宏进行重新定义。

  - 但值得注意的是，不管断言宏最终是用什么样的方式进行定义，其所定义宏的主要目的都是要使用它来对传递给相应函数的参数进行确认检查。如果违背了这条宏定义原则，那么所定义的宏将会偏离方向，失去宏定义本身的意义。与此同时，为不影响标准 assert 宏的使用，最好使用其他的名字。例如，下面的示例代码就展示了用户如何重定义自己的宏 ASSERT：

    ```
    /*使用断言测试*/
    #ifdef DEBUG
    /*处理函数原型*/
    void Assert(char * filename, unsigned int lineno);
    #define ASSERT(condition)\
    if(condition)\
        NULL; \
    else\
        Assert(__FILE__ , __LINE__)
    /*不使用断言测试*/
    #else
    #define ASSERT(condition) NULL
    #endif
    void Assert(char * filename, unsigned int lineno)
    {
        fflush(stdout);
        fprintf(stderr,"\nAssert failed： %s, line %u\n",filename, lineno);
        fflush(stderr);
        abort();
    }
    ```

    - 如果定义了 DEBUG，ASSERT 将被扩展为一个if语句，否则执行“#define ASSERT(condition) NULL”替换成 NULL。
    - 这里需要注意的是，因为在编写 C 语言代码时，在每个语句后面加一个分号“；”已经成为一种约定俗成的习惯，因此很有可能会在“Assert（`__FILE__，__LINE__`）”调用语句之后习惯性地加上一个分号。实际上并不需要这个分号，因为用户在调用 ASSERT 宏时，已经给出了一个分号。面对这种问题，我们可以使用“do{}while(0)”结构进行处理，如下面的代码所示：

    ```
    #define ASSERT(condition)\
    do{   \
        if(condition)\
           NULL; \
        else\
           Assert(__FILE__ , __LINE__);\
    }while(0)
    现在，将不再为分号“；”而担心了，调用示例如下：
    void Test(unsigned char *str)
    {
        ASSERT(str != NULL);
        /*函数处理代码*/
    }
    int main(void)
    {
        Test(NULL);
        return 0;
    }
    ```

    - 很显然，因为调用语句“Test（NULL）”为参数 str 错误传入一个 NULL 指针的原因，所以 ASSERT 宏会自动检测到这个错误，同时根据宏 `__FILE__` 和 `__LINE__` 所提供的文件名和行号参数在标准错误输出设备 stderr 上打印一条错误消息，然后调用 abort 函数中止程序的执行。运行结果如图 1 所示。
    - 如果这时候将自定义 ASSERT 宏替换成标准 assert 宏结果会是怎样的呢？如下面的示例代码所示：

    ```
    void Test(unsigned char *str)
    {
        assert(str != NULL);
        /*函数处理代码*/
    }
    ```

    - 毋庸置疑，标准 assert 宏同样会自动检测到这个 NULL 指针错误。与此同时，标准 assert 宏除给出以上信息之外，还能够显示出已经失败的测试条件。运行结果如图 2 所示。

      ![](http://c.biancheng.net/uploads/allimg/180906/2-1PZ615193Dc.jpg)

    - 从上面的示例中不难发现，对标准的 assert 宏来说，自定义的 ASSERT 宏将具有更大的灵活性，可以根据自己的需要打印输出不同的信息，同时也可以对不同类型的错误或者警告信息使用不同的断言，这也是在工程代码中经常使用的做法。当然，如果没有什么特殊需求，还是建议使用标准 assert 宏。

##### unlink

```c
int unlink(const char *pathname);

unlink() deletes a name from the file system.  If that name was the last link to a file and no processes have the file open the file is deleted and the space it was using is made available for reuse.
unlink() 从文件系统中删除一个名称。 如果该名称是文件的最后一个链接，并且没有进程打开该文件，则该文件将被删除，并且它正在使用的空间可供重用。
```

- 如果pathname是一个链接文件，则删除这个链接文件。如果是一个文件，则删除这个文件。
- remove可以删除文件和目录，如果是一个文件的话调用的是unlink函数，如果是一个目录的话调用的是rmdir函数，其是在内部实现的

##### fcntl

```c
int fcntl(int fd, int cmd, ... /* arg */ );
```

- [函数介绍](https://blog.csdn.net/u012349696/article/details/50791364)

- [另一种介绍，里面由printf的宏定义打印调试信息的写法](https://blog.csdn.net/rikeyone/article/details/88828154)

- 第三个参数arg是可选的，由第二个参数cmd决定

  ```
  int fcntl(int fd, int cmd);
  int fcntl(int fd, int cmd, int arg);
  int fcntl(int fd, int cmd, struct flock *lock);
  ```

- fcntl函数的作用

  ```
  1. 复制一个现有的描述符(cmd=F_DUPFD). 
  2. 获得／设置文件描述符标记(cmd=F_GETFD或F_SETFD). 
  3. 获得／设置文件状态标记(cmd=F_GETFL或F_SETFL). 
  4. 获得／设置异步I/O所有权(cmd=F_GETOWN或F_SETOWN). 
  5. 获得／设置记录锁(cmd=F_GETLK , F_SETLK或F_SETLKW).
  ```

- fcntl函数设置文件非阻塞步骤

  ```c++
  static int make_socket_non_blocking (int sfd)
  {
    int flags, s;
    flags = fcntl (sfd, F_GETFL, 0);
    if (flags == -1) {
        perror ("fcntl");
        return -1;
    }
    flags |= O_NONBLOCK;
    s = fcntl (sfd, F_SETFL, flags);
    if (s == -1) {
        perror ("fcntl");
        return -1;
    }
    return 0;
  }
  ```

  - 设置为非阻塞是对于文件来说的，对于文件的属性设置是在open函数打开文件时设置的，所以文件的属性例如O_NONBLOCK在open函数中可以看到。而fcntl这样做是改变函数的标志的。

##### lseek

```c
off_t lseek(int fd, off_t offset, int whence);
lseek - reposition read/write file offset
```

- 函数执行成功返回当前的偏移量和文件开头的字节数，所以可以用这个函数获取文件大小，将文件读写的位置移动到最末尾，然后获取返回值，这个返回值就是文件头与文件尾之间的字节数，也就是文件大小。

- 另一个函数fseek

  ```
  int fseek(FILE *stream, long offset, int whence);
  ```

  - 这个函数是对lseek函数封装后实现的，这个函数的操作对象是FILE *， lseek函数的操作对象是fd文件描述符

### c++

##### std::function,std::bind

- std::function本质是一种类模板，是对通用、多态的函数封装。std::function的实例可以对**任何可以调用的目标实体**进行存储、复制、和调用操作，这些目标实体包括**普通函数、Lambda表达式、函数指针、以及其它函数对象**等。std::function对象是对C++中现有的可调用实体的一种类型安全的包裹（我们知道像函数指针这类可调用实体，是类型不安全的）。

- 通常std::function是一个函数对象类，它包装其它任意的函数对象，被包装的函数对象具有类型为T1, …,TN的N个参数，并且返回一个可转换到R类型的值。std::function使用 模板转换构造函数接收被包装的函数对象；特别是，闭包类型可以隐式地转换为std::function。std::function统一和简化了相同类型可调用实体的使用方式，使得编码变得更简单。

- 通过std::function对C++中各种可调用实体（普通函数、Lambda表达式、函数指针、以及其它函数对象等）的封装，形成一个新的可调用的std::function对象；让我们不再纠结那么多的可调用实体。一切变的简单粗暴。

- std::function函数原型

  ```
  template< class R, class... Args >
  class function<R(Args...)>
  ```

  - R是返回值类型，Args是函数的参数类型，实例一个std::function对象很简单，就是将可调用对象的返回值类型和参数类型作为模板参数传递给std::function模板类。比如：

    ```
    std::function<void()> f1;
    std::function<int (int , int)> f2;
    ```

  - 在这里，f1和f2本质是一个对象，只不过重载了其函数调用操作符，所以使用的时候可以直接像函数一样调用。另外重载了赋值操作符，这样可以将可调用的函数实体赋值给它，其函数调用操作符重载函数里间接的调用赋值时传进来的调用实体。

  ```c++
  #include <iostream>
  #include <functional>
   
  using namespace std;
   
  std::function<bool(int, int)> fun;
  //普通函数
  bool compare_com(int a, int b)
  {
      return a > b;
  }
  
  //lambda表达式
  auto compare_lambda = [](int a, int b){<!-- --> return a > b;};
  
  //仿函数，其实就是重载类的函数调用运算符()的类
  class Compare_class
  {
  public:
      bool operator()(int a, int b)
      {
          return a > b;
      }  
  };
  
  //类成员函数
  class Compare
  {
  public:
      bool compare_member(int a, int b)
      {
          return a > b;
      }
      static bool compare_static_member(int a, int b)
      {
          return a > b;
      }
  };
  
  int main()
  {
      bool result;
      fun = compare_com;
      result = fun(10, 1);
      cout << "普通函数输出, result is " << result << endl;
   
      fun = compare_lambda;
      result = fun(10, 1);
      cout << "lambda表达式输出, result is " << result << endl;
   
      fun = Compare_class();
      result = fun(10, 1);
      cout << "仿函数输出, result is " << result << endl;
      
     	fun = Compare::compare_static_member;
      result = fun(10, 1);
      cout << "类静态成员函数输出, result is " << result << endl;
   
      //类普通成员函数比较特殊，需要使用bind函数，并且需要实例化对象，成员函数要加取地址符
      Compare temp;
      fun = std::bind(&Compare::compare_member, temp, std::placeholders::_1, std::placeholders::_2);
      result = fun(10, 1);
      cout << "类普通成员函数输出, result is " << result << endl;
  }
  ```

  - std::function对象最大的用处就是在**实现函数回调**，使用者需要注意，它不能被用来检查相等或者不相等，但是可以与NULL或者nullptr进行比较。

- function和typedef结合使用定义函数类型回调应用

  - 用typedef给std:funtion起别名，得到一种函数对象类型，可以修饰函数的参数，表明该形参是一个回调函数，也可以作为类的成员，由外部传入，在类的成员函数里调用。

    ```c++
    typedef std::function<void(std::string)> CallBack;
    Class MessageProcessor {<!-- -->
    private:
        CallBack callback_;
    public:
        MessageProcessor(Callback callback):callback_(callback){<!-- -->}
        void ProcessMessage(const std::string& msg) {<!-- -->
            callback_(msg);
        }
    };
    ```

- std::bind使用

  - std::bind函数将可调用对象(用法中所述6类)和可调用对象的参数进行绑定，返回新的可调用对象(std::function类型，参数列表可能改变)，返回的新的std::function可调用对象的参数列表根据bind函数实参中std::placeholders::_x从小到大对应的参数确定。

    ```c++
    #include <iostream>
    using namespace std;
    class A
    {<!-- -->
    public:
        void fun_3(int k,int m)
        {<!-- -->
            cout<<k<<" "<<m<<endl;
        }
    };
     
    void fun(int x,int y,int z)
    {<!-- -->
        cout<<x<<"  "<<y<<"  "<<z<<endl;
    }
     
    void fun_2(int &a,int &b)
    {<!-- -->
        a++;
        b++;
        cout<<a<<"  "<<b<<endl;
    }
     
    int main(int argc, const char * argv[])
    {<!-- -->
        auto f1 = std::bind(fun,1,2,3); //表示绑定函数 fun 的第一，二，三个参数值为： 1 2 3
        f1(); //print:1  2  3
     
        auto f2 = std::bind(fun, placeholders::_1,placeholders::_2,3);
        //表示绑定函数 fun 的第三个参数为 3，而fun 的第一，二个参数分别有调用 f2 的第一，二个参数指定
        f2(1,2);//print:1  2  3
     
        auto f3 = std::bind(fun,placeholders::_2,placeholders::_1,3);
        //表示绑定函数 fun 的第三个参数为 3，而fun 的第一，二个参数分别有调用 f3 的第二，一个参数指定
        //注意： f2  和  f3 的区别。
        f3(1,2);//print:2  1  3
     
     
        int n = 2;
        int m = 3;
     
        auto f4 = std::bind(fun_2, n,placeholders::_1);
        f4(m); //print:3  4
     
        cout<<m<<endl;//print:4  说明：bind对于不事先绑定的参数，通过std::placeholders传递的参数是通过引用传递的
        cout<<n<<endl;//print:2  说明：bind对于预先绑定的函数参数是通过值传递的
         //成员函数的绑定，比较常用，作为回调。
        A a;
        auto f5 = std::bind(&A::fun_3, a,placeholders::_1,placeholders::_2);
        f5(10,20);//print:10 20
     
        std::function<void(int,int)> fc = 			    std::bind(&A::fun_3,a,std::placeholders::_1,std::placeholders::_2);
        fc(10,20);//print:10 20
     
        return 0;
    }
    ```

  - 其中bind类成员函数时，要实例化一个对象，将这个实例化对象也要传进去，否则找不到成员函数的地址，因为成员函数在内存中只保留了一份，而且不能通过类直接访问，必须要通过类的实例化对象来访问，bind的第一个参数&A::fun_3，表示和哪个成员函数绑定，里面怎么实现的暂时不知道，这么写就可以了

- bind绑定成员函数的作用

  ```c++
  #include <iostream>
  #include <functional>
  using namespace std;
   
  class A
  {
  public:
      A() :m_a(0){}
      ~A(){}
   
      virtual void SetA(const int& a){ cout << "A:" << this << endl;  m_a = a; }
      int GetA()const { return m_a; }
  protected:
      int m_a;
  };
  class B: public A
  {
  public:
      B():A(){;}
      ~B(){;}
      virtual void SetA(const int& a){ cout << "B:" << this << endl; m_a = a; }
  private:
  };
   
  int main(void)
  {
      A a;
      cout << "A:" << &a << endl;//0
      function<void(const int&)> func1 = std::bind(&A::SetA, a, std::placeholders::_1);
      func1(1);
      cout << a.GetA() << endl;//0
      function<void(const int&)> func2 = std::bind(&A::SetA, &a, std::placeholders::_1);
      func2(2);
      cout << a.GetA() << endl;//2
   
      cout << "---------" << endl;
      A* pa = new B();
      cout << "B:" << pa << endl;//0
      function<void(const int&)> func3 = std::bind(&A::SetA, pa, std::placeholders::_1);
      func3(3);
      cout << pa->GetA() << endl;//3
      function<void(const int&)> func4 = std::bind(&A::SetA, *pa, std::placeholders::_1);
      func4(4);
      cout << pa->GetA() << endl;//3
      delete pa;
      system("pause");
      return 0;
  }
  
  由输出可以看出：
  
  1、func1调用时产生了一个临时对象，然后调用临时对象的SetA；
  2、func2调用的是a.SetA，改变了对象a中m_a的值；
  3、func3调用的是pa->SetA，输出B:0060A4A8，调用的时B的SetA改变了pa->m_a；
  4、func4调用时产生了一个临时对象，然后调用临时对象的A::SetA；
  结论：std::bind中第二个参数应该是对象的指针，且std::bind支持虚函数。
  ```

  - 使用这种绑定成员函数，我们可以不通过实例化的类对象来访问成员函数，直接使用bind绑定的function对象来访问和修改成员函数，我们还可以绑定一些参数，这样在访问的时候就不需要输入很多参数，使用更加方便
  - 其次我们要知道使用bind最后就是为了使用回调，将bind之后的函数作为参数传递给另一个函数，实际的问题是，类B实现一个功能，类A采用组合的形式，将类B作为其成员以图获取B的能力，类B提供了注册回调的接口给类A，在类B完成某项功能的时候，可以调用A的接口，完成A自己的处理工作或者需求。简单理解就是类A里面的接口注册到了类B里面，这样类B就可以使用类A的回调函数来完成类A要处理的功能。这里面类A是要实例化的一个对象，这种绑定作为回调函数只能通过bind这种回调函数形式来实现，而不能直接将类A的成员函数直接注册到类B里面。最重要的理解是回调，把A的函数作为回调函数给B，这样B就可以调用A的函数，只是这种实现方法是通过bind成员函数这种方法实现的

##### tuple

- C++11 标准新引入了一种类模板，命名为 tuple（中文可直译为元组）。tuple 最大的特点是：实例化的对象可以存储任意数量、任意类型的数据。

- tuple 的应用场景很广泛，例如当需要存储多个不同类型的元素时，可以使用 tuple；当函数需要返回多个数据时，可以将这些数据存储在 tuple 中，函数只需返回一个 tuple 对象即可。

- tuple对象的创建

  - 类的构造函数

    ```
    1) 默认构造函数
    constexpr tuple();
    2) 拷贝构造函数
    tuple (const tuple& tpl);
    3) 移动构造函数
    tuple (tuple&& tpl);
    4) 隐式类型转换构造函数
    template <class... UTypes>
        tuple (const tuple<UTypes...>& tpl); //左值方式
    template <class... UTypes>
        tuple (tuple<UTypes...>&& tpl);      //右值方式
    5) 支持初始化列表的构造函数
    explicit tuple (const Types&... elems);  //左值方式
    template <class... UTypes>
        explicit tuple (UTypes&&... elems);  //右值方式
    6) 将pair对象转换为tuple对象
    template <class U1, class U2>
        tuple (const pair<U1,U2>& pr);       //左值方式
    template <class U1, class U2>
        tuple (pair<U1,U2>&& pr);            //右值方式
        
    #include <iostream>     // std::cout
    #include <tuple>        // std::tuple
    using std::tuple;
    int main()
    {
        std::tuple<int, char> first;                             // 1)   first{}
        std::tuple<int, char> second(first);                     // 2)   second{}
        std::tuple<int, char> third(std::make_tuple(20, 'b'));   // 3)   third{20,'b'}
        std::tuple<long, char> fourth(third);                    // 4)的左值方式, fourth{20,'b'}
        std::tuple<int, char> fifth(10, 'a');                    // 5)的右值方式, fifth{10.'a'}
        std::tuple<int, char> sixth(std::make_pair(30, 'c'));    // 6)的右值方式, sixth{30,''c}
        return 0;
    }
    ```

  - make_tuple()函数

    - make_tuple() 函数，它以模板的形式定义在 <tuple> 头文件中，功能是创建一个 tuple 右值对象（或者临时对象）。

      ```
      auto first = std::make_tuple (10,'a');   // tuple < int, char >
      const int a = 0; int b[3];
      auto second = std::make_tuple (a,b);     // tuple < int, int* >
      ```

- tuple常用函数

  | 函数或类模板                     | 描 述                                                        |
  | -------------------------------- | ------------------------------------------------------------ |
  | tup1.swap(tup2) swap(tup1, tup2) | tup1 和 tup2 表示类型相同的两个 tuple 对象，tuple 模板类中定义有一个 swap() 成员函数，<tuple> 头文件还提供了一个同名的 swap() 全局函数。  swap() 函数的功能是交换两个 tuple 对象存储的内容。 |
  | get<num>(tup)                    | tup 表示某个 tuple 对象，num 是一个整数，get() 是 <tuple> 头文件提供的全局函数，功能是返回 tup 对象中第 num+1 个元素。 |
  | tuple_size<type>::value          | tuple_size 是定义在 <tuple> 头文件的类模板，它只有一个成员变量 value，功能是获取某个 tuple 对象中元素的个数，type 为该tuple 对象的类型。 |
  | tuple_element<I, type>::type     | tuple_element 是定义在 <tuple> 头文件的类模板，它只有一个成员变量 type，功能是获取某个 tuple 对象第 I+1 个元素的类型。 |
  | forward_as_tuple<args...>        | args... 表示 tuple 对象存储的多个元素，该函数的功能是创建一个 tuple 对象，内部存储的 args... 元素都是右值引用形式的。 |
  | tie(args...) = tup               | tup 表示某个 tuple 对象，tie() 是 <tuple> 头文件提供的，功能是将 tup 内存储的元素逐一赋值给 args... 指定的左值变量。 |
  | tuple_cat(args...)               | args... 表示多个 tuple 对象，该函数是 <tuple> 头文件提供的，功能是创建一个 tuple 对象，此对象包含 args... 指定的所有 tuple 对象内的元素。 |

  - tuple 模板类对赋值运算符 = 进行了重载，使得同类型的 tuple 对象可以直接赋值。此外，tuple 模板类还重载了 ==、!=、<、>、>=、<= 这几个比较运算符，同类型的 tuple 对象可以相互比较（逐个比较各个元素）。

  ```
  #include <iostream>
  #include <tuple>
  int main()
  {
      int size;
      //创建一个 tuple 对象存储 10 和 'x'
      std::tuple<int, char> mytuple(10, 'x');
      //计算 mytuple 存储元素的个数
      size = std::tuple_size<decltype(mytuple)>::value;
      //输出 mytuple 中存储的元素
      std::cout << std::get<0>(mytuple) << " " << std::get<1>(mytuple) << std::endl;
      //修改指定的元素
      std::get<0>(mytuple) = 100;
      std::cout << std::get<0>(mytuple) << std::endl;
      //使用 makde_tuple() 创建一个 tuple 对象
      auto bar = std::make_tuple("test", 3.1, 14);
      //拆解 bar 对象，分别赋值给 mystr、mydou、myint
      const char* mystr = nullptr;
      double mydou;
      int myint;
      //使用 tie() 时，如果不想接受某个元素的值，实参可以用 std::ignore 代替
      std::tie(mystr, mydou, myint) = bar;
      //std::tie(std::ignore, std::ignore, myint) = bar;  //只接收第 3 个整形值
      //将 mytuple 和 bar 中的元素整合到 1 个 tuple 对象中
      auto mycat = std::tuple_cat(mytuple, bar);
      size = std::tuple_size<decltype(mycat)>::value;
      std::cout << size << std::endl;
      return 0;
  }
  
  10 x
  100
  5
  ```


##### getline

- ```
  template< class CharT, class Traits, class Allocator >
  std::basic_istream<CharT,Traits>& getline( std::basic_istream<CharT,Traits>& input,
                                             std::basic_string<CharT,Traits,Allocator>& str,
                                             CharT delim );
  (1)	
  template< class CharT, class Traits, class Allocator >
  std::basic_istream<CharT,Traits>& getline( std::basic_istream<CharT,Traits>&& input,
                                             std::basic_string<CharT,Traits,Allocator>& str,
                                             CharT delim );
  (1)	(since C++11)
  template< class CharT, class Traits, class Allocator >
  std::basic_istream<CharT,Traits>& getline( std::basic_istream<CharT,Traits>& input,
                                             std::basic_string<CharT,Traits,Allocator>& str );
  (2)	
  template< class CharT, class Traits, class Allocator >
  std::basic_istream<CharT,Traits>& getline( std::basic_istream<CharT,Traits>&& input,
                                             std::basic_string<CharT,Traits,Allocator>& str );
  (2)	(since C++11)
  ```

  - Parameters
    - input -  the stream to get data from
    - str - the string to put the data into
    - delim - the delimiter character
  - return value
    - input

- ```
  string str,stemp;//str是读入的字符串，stemp是暂存分割开的小字符串
  vector<string> v;
  int main()
  {
      cin>>str;
      stringstream ss(str);
  
      while(getline(ss,stemp,'/'))//getline的第三个参数是终止字符，到当前字符终止
      {
          if(!stemp.empty()) v.push_back(stemp);
      }
  
      for (auto i:v)
          cout<<i<<endl;
  }
  ```

  - stringstream的特点是，你读入了前面的一部分字符串，对应的字符串流中就会减去那一部分，所以可以使用while来一直循环读入，getline的第一个参数可以是stringstream类

  - 上面这种也可是使用for循环来做

    ```
    std::istringstream input2;
    input2.str("a;b;c;d");
    for (std::string line; std::getline(input2, line, ';'); ) {
        std::cout << line << '\n';
    }
    ```

    - 上面这个for循环中，初始化了一个string变量，循环条件为getline函数是否有返回，如果input2这个流中一直有东西，其一直在向line中写入，以分号分割，当流中没有东西之后函数返回一个空，相当于跳出循环，这样就能循环得到以指定字符分割的字符串，然后存入到指定的vector中，这样就能分割出来了

### system

##### 用户态内核态

- 当申请外部资源时用户态会向内核态转变，其中申请外部资源包括
  - 系统调用
  - 中断
  - 异常
- 主板上能看到的设备基本都是外部资源，当需要的时候就会向内核态转变，其中包括内存条，网卡，磁盘，usb外设等
- 其中系统调用包括几类
  - 进程，exit，fork
  - 文件
  - 设备
  - 信息，cpu信息，设备信息，一般以get开头
  - 通信特指进程间通信，pipe， mmap
- man syscalls可以看到全部的系统调用
- epoll，select，signal等都是系统调用，因为其要感知系统的变化，用户态是不能完成的，只能通过系统的设计来实现
  - 例如signal就是一个系统调用，而且是一个异步函数，当代码中使用signal时就是将回调函数注册到内核态，由内核态来调用对应的信号处理函数，如果是杀死进程，当系统收到键盘的信号时，就在内核态操作，因为内核态杀死进程很方便。内核态那一部分空间是不变的，其上的程序一直存在，用户空间的内存是变化的，这涉及到虚拟内存的知识，内核态和当前用户空间的程序组成当前的整个运行状态。signal是异步函数，当使用这个函数时，就相当于开启了一个线程一直在干这个事，只不过这个线程目前是操作系统实现的，具体是不是线程不知道。
  - epoll是系统调用，因为epoll是感知文件描述符的变化，如果文件描述符变化，内核感知到，这样就能做后续的处理了
- 内核态其实也就是一堆函数，我们去调用，有一些是需要到内核态返回数据的，例如read函数就是将磁盘上的数据读取到用户态申请的缓存里面，这是同步的。但是还有一些异步的函数，当我们调用之后，内核态中有线程就会一直在等着干这个事，例如signal。
- 可以将内核态就看作是一堆系统调用的函数，当我们需要的时候就去调用，就跟我们自己写的函数一样，当调用的时候就会转到函数入口处执行，只不过自己写的在用户空间内存上，系统的在内核空间内存上。总的来说就是一堆函数，在用户空间调用内核态的函数时，我们也能知道这个函数执行是不是成功，因为其会从栈上返回。如果内核态和用户态完全隔离，这个程序就没法设计了。目前简单的理解就是将内核态里面的一些系统调用当作一些普通函数在使用。就是这些调用涉及到内核态和用户态之间的切换，会消耗资源
- 用户空间能拿到内核态的处理结果，这个系统调用和普通的调用一样，我们用户空间的数据能传递到这个系统调用的函数里面，处理的结果也能返回，其实就是一些栈区函数调用。在系统调用的时候就是保存当前栈，然后将函数需要的东西传进去，跳转到调用函数处执行，执行完毕后返回值（这个返回值一般有当前栈上面的数据接收，就是设置变量来保存返回的临时值）当前栈区就能判断这个返回值，进行下一步操作。
- 例如键盘输入的一些东西实在内核缓冲区，当时我们可以使用getchar等函数拿到用户空间，并将值赋值给当前的一个变量，这样我们就可以使用键盘输入的这个值了
- 一些设计的算法只是一堆数据层面的操作，不会涉及到系统调用，我们只是在处理这个数据，涉及到的系统调用只会有磁盘上的一些操作，因为其要存储一些东西和取用一些东西

##### 回调函数

- [深入c++回调，里面包含各种解释，前面包含链接，可以查看一下解释](https://cloud.tencent.com/developer/article/1519851)

- [回调函数理解包括同步和异步](https://bot-man-jl.github.io/articles/?post=2017/Callback-Explained)

- c语言异步回调

  - 回调，特别是在封装接口的时候，回调显得特别重要，我们首先假设有两个程序员在写代码，A程序员写底层驱动接口，B程序员写上层应用程序，然而此时底层驱动接口A有一个数据d需要传输给B，此时有两种方式：

    - A将数据d存储好放在接口函数中，B自己想什么时候去读就什么时候去读，这就是我们经常使用的函数调用，此时主动权是B。
    - A实现回调机制，当数据变化的时候才将通知B，你可以来读取数据了，然后B在用户层的回调函数中读取速度d，完成OK。此时主动权是A。

  - 很明显第一种方法太低效了，B根本就不知道什么时候该去调用接口函数读取数据d。而第二种方式由于B的读取数据操作是依赖A的，只有A叫B读数据，那么B才能读数据。也即是实现了中断读取。

  - 那么回调是怎么实现的呢，其实回调函数就是一个通过函数指针调用的函数。如果用户层B把函数的指针（地址）作为参数传递给底层驱动A，当这个指针在A中被用为调用它所指向的函数时，我们就说这是回调函数。

  - 是在A中被调用，这里看到尽管函数是在B中，但是B却不是自己调用这个函数，而是将这个函数的函数指针通过A的接口函数传自A中了，由A来操控执行，这就是回调的意义所在。

  - A程序员的代码

    ```c++
    //-----------------------底层实现A-----------------------------
    typedef void (*pcb)(int a); //函数指针定义，后面可以直接使用pcb，方便
    typedef struct parameter{
        int a ;
        pcb callback;
    }parameter; 
    
    void* callback_thread(void *p1)//此处用的是一个线程
    {
        //do something
        parameter* p = (parameter*)p1 ;
        while(1)
        {
            printf("GetCallBack print! \n");
            sleep(3);//延时3秒执行callback函数
            p->callback(p->a);//函数指针执行函数，这个函数来自于应用层B
        }
    }
    
    //留给应用层B的接口函数
    extern SetCallBackFun(int a, pcb callback)
    {
        printf("SetCallBackFun print! \n");
        parameter *p = malloc(sizeof(parameter)) ; 
        p->a  = 10;
        p->callback = callback;
    
        //创建线程
        pthread_t thing1;
        pthread_create(&thing1,NULL,callback_thread,(void *) p);
        pthread_join(thing1,NULL);
    }
    ```

    - 上面的代码就是底层接口程序员A写的全部代码，留出接口函数SetCallBackFun即可
    - 下面再实现应用者B的程序，B负责调用SetCallBackFun函数，以及增加一个函数，并将此函数的函数指针通过SetCallBackFun(int a, pcb callback)的第二个参数pcb callback 传递下去。

    ```c++
    //-----------------------应用者B-------------------------------
    void fCallBack(int a)       // 应用者增加的函数，此函数会在A中被执行
    {
        //do something
        printf("a = %d\n",a);
        printf("fCallBack print! \n");
    }
    
    
    int main(void)
    {
        SetCallBackFun(4,fCallBack);
    
        return 0;
    }
    
    先会打印A程序的                 printf("GetCallBack print! \n");
    然后等待3秒钟才会打印应用者B的    printf("fCallBack print! \n");
    ```

- c++实现异步回调

  - 静态成员函数实现回调

    ```c++
    //-------------
    class xiabo2_C{
    public:
        typedef int (*pcb)(int a);
        typedef struct parameter{
            int a ;
            pcb callback;
        }parameter; 
        xiabo2_C():m_a(1){
    
        }
        //普通函数
        void GetCallBack(parameter* p)  // 写回调者实现的回调函数
        {
            m_a = 2;
            //do something
            while(1)
            {
                printf("GetCallBack print! \n");
                _sleep(2000);
                p->callback(p->a);
            }
        }
        int SetCallBackFun(int a, pcb callback)
        {
            printf("SetCallBackFun print! \n");
            parameter *p = new parameter ; 
            p->a  = 10;
            p->callback = callback;
            GetCallBack(p);
            return 0;
        }
    
    public:
        int m_a;
    };
    
    class xiabo2Test_C{
    public:
        xiabo2Test_C():m_b(1){
    
        }
        static int fCallBack(int a)         // 应用者实现的回调函数，静态成员函数，但是不能访问类中非静态成员了，破坏了类的结构
        {
            //do something
            //m_b = a;      // 不能访问类中非静态成员了，破坏了类的结构,应用者使用很麻烦
            printf("a = %d\n",a);
            printf("fCallBack print! \n");
            return 0;
        }
    public:
        int m_b;
    };
    int main(void ){
        //test_statichunc();
        xiabo2_C xiabo2;
        xiabo2.SetCallBackFun(5,xiabo2Test_C::fCallBack);
        getchar();
        return 0;
    }
    ```

    - 虽然这种方法实现了回调，但是应用者那是1万个不情愿，尼玛为了用个回调，我类类里面的非静态成员什么都不能用了，还不如不回调呢

  - 非静态成员函数实现回调

    ```c++
    //-------------------
    template<typename Tobject,typename Tparam>
    class xiabo3_C{
        typedef void (Tobject::*Cbfun)(Tparam* );
    public:
        bool Exec(Tparam* pParam);
        void Set(Tobject *pInstance,Cbfun pFun,Tparam* pParam);
    
    private:
        Cbfun pCbfun;
        Tobject* m_pInstance;
    };
    
    template<typename Tobject,typename Tparam>
    void xiabo3_C<Tobject,Tparam>::Set(Tobject *pInstance,Cbfun pFun,Tparam* pParam){
        printf("Set print!\n");
        m_pInstance = pInstance;
        (pInstance->*pFun)(pParam);     //可以直接在这里回调传过来的函数指针
        pCbfun = pFun;
    }
    template<typename Tobject,typename Tparam>
    bool xiabo3_C<Tobject,Tparam>::Exec(Tparam* pParam){
        printf("Exec print!\n");
        (m_pInstance->*pCbfun)(pParam);//也可以在这里回调传过来的函数指针
        return true;
    }
    
    class xiabo3Test_C{
    public:
        xiabo3Test_C():m_N(13){
    
        }
        void fCallBack(int *p){
            printf("fCallBack : Sum = m_N + *p = %d\n",*p + m_N);
            printf("fCallBack print! I am a member function! I can access all the member ,HaHa\n");
        }
    
    private:
        int m_N;
    };
    int main(void ){
        xiabo3_C<xiabo3Test_C,int> xiabo3;
        xiabo3Test_C xiabo3Test;
        int p = 13;
        xiabo3.Set(&xiabo3Test,&xiabo3Test_C::fCallBack,&p); //
        xiabo3.Exec(&p);
        getchar();
        return 0;
    }
    ```

    - 上面可以看出成员函数Exec和Set都仅仅是个函数，那万一我需要的是线程呢？问题又来了，创建线程的线程Wrapper又不能是非静态成员函数，例如下面这样写就不行

      ```c++
      class  xiabo4_C{
      public:
          xiabo4_C():m_N(1){
      
          }
          void funThreadAlgorithm(void);
          void CreatAlgorithmThread(void);
      public:
      
      private:
          int m_N;
      };
      void xiabo4_C::funThreadAlgorithm(void){
      }
      void xiabo4_C::CreatAlgorithmThread(void){
          HANDLE handle1 = CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)funThreadAlgorithm,0,0,NULL);  
          CloseHandle(handle1);//!!error  
      }
      ```

    - 当然我们可以将线程的Wrapper改成static成员函数就可以，但是代价是不能访问类中的非静态成员。

      ```c++
      class  xiabo4_C{
      public:
          xiabo4_C():m_N(1){
      
          }
          static void funThreadAlgorithm(void);
          void CreatAlgorithmThread(void);
      public:
      
      private:
          int m_N;
      };
      void xiabo4_C::funThreadAlgorithm(void){
          while(1)
          {
              _sleep(3000);
              printf("I am a static meeber function! I can not access the member\n");
          }
      }
      void xiabo4_C::CreatAlgorithmThread(void){
          HANDLE handle1 = CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)funThreadAlgorithm,0,0,NULL);  
          CloseHandle(handle1);
      }
      ```

    - 上述代码就实现了静态成员函数用于线程wrapper，但是又想要两全其美怎么办，仔细分析，之所以不能将非静态成员函数用于线程wrapper，那是因为没有为线程wrapper提供this指针。那么既然是这样，我们在创建线程的时候将对象的this指针传入线程wrapper中，然后线程wrapper就可以调用非静态成员函数啦！

    - 因为这是异步回调，重新起了一个线程来执行线程函数，在这个线程里面不能直接调用这个函数，所以在起线程的时候要将this指针当作参数传进去，相当于将这个类对象传进去线程里面，在线程里面来找到类里面要执行的线程函数。这样就能成功。
    
      ```c++
      //--------------
      //类中定义线程，并实现回调
      //A程序员
      template<typename Tobject,typename Tparam>
      class  xiabo5_C{
      public:
          struct ThreadParam{
              xiabo5_C* pthis;
              Tparam a ;
          };//根据线程参数自定义结构
          typedef void (Tobject::*Cbfun)(Tparam );
      public:
          xiabo5_C():m_N(1){
      
          }
          void print(void){
              printf("print : m_N = %d \n",m_N);
         }
          //非静态实现
          void CreateCallbackThread(Tobject *pInstance,Cbfun pFun,Tparam a );
          static void funCallbackThread(ThreadParam* p);  //非静态成员函数实现线程Wrapper
          void ThreadFunc(Tparam a );  //线程执行函数
      
      private:
          int m_N;
          Cbfun pCbfun;
          Tobject* m_pInstance;
      };
      template<typename Tobject,typename Tparam>
      void xiabo5_C<Tobject,Tparam>:: CreateCallbackThread(Tobject *pInstance,Cbfun pFun,Tparam a ){
          ThreadParam* p = new ThreadParam;
          p->pthis = this;
          p->a     = a;
          m_pInstance = pInstance;
          pCbfun = pFun;
      
          HANDLE handle2 = CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)funCallbackThread,p,0,NULL);   
          CloseHandle(handle2);
      }
      template<typename Tobject,typename Tparam>
      void xiabo5_C<Tobject,Tparam>::funCallbackThread(ThreadParam* p){
          printf("I am a static meeber function! I can not access the member\n");
          printf("But I can call a member func ,I can instigate ThreadFunc ,ThreadFunc can access all member\n");
          printf("ThreadParam p->a = %d, p->b = %d \n",p->a);
          p->pthis->ThreadFunc(p->a);
      }
      template<typename Tobject,typename Tparam>
      void xiabo5_C<Tobject,Tparam>::ThreadFunc(Tparam a ){
          printf("ThreadFunc : I am ThreadFunc,I am a member function! I can access all the member ,HaHa...\n");
          printf("ThreadFunc : m_N = %d \n",m_N);
          while(1)
          {
              Sleep(2000);
              (m_pInstance->*pCbfun)(a);
          }
      }
      //B程序员
      class xiabo5Test_C{
      public:
          xiabo5Test_C():m_N(55){
      
          }
          void fCallBack(int p){
              printf("fCallBack : Sum = m_N + *p = %d\n",p + m_N);
              printf("fCallBack print! I am a member function! I can access all the member ,HaHa...\n");
          }
      public:
      
      private:
          int m_N;
      };
      
      
      int main(void ){
          //类中定义线程，并实现回调
          xiabo5_C<xiabo5Test_C,int> xiabo5;
          xiabo5Test_C xiabo5Test;
          int p = 45;
          xiabo5.CreateCallbackThread(&xiabo5Test,&xiabo5Test_C::fCallBack,p);
      
      
          xiabo5_C<xiabo5Test_C,int> xiabo51;
          xiabo5Test_C xiabo5Test1;
          int p1 = -45;
          xiabo51.CreateCallbackThread(&xiabo5Test1,&xiabo5Test_C::fCallBack,p1);
      
          getchar();
          return 0;
      }
      ```
    
      

##### 信号处理和signal

- [Linux信号处理原理与实现](https://mp.weixin.qq.com/s/rcpK-UEYIy628b77IG-obA)
  - signal是异步函数，将回调函数注册到内核态，当进程收到对应的信号时，由内核态来调用对应的信号处理函数。内核态和当前进程在一起，组成当前整个的程序，只是内核态是由系统内核维护的一些函数，内核态也有进程

##### popen

```c++
FILE *popen(const char *command, const char *type);
int pclose(FILE *stream);
```

- 函数说明：popen()会调用fork()产生子进程，然后从子进程中调用/bin/sh -c 来执行参数command 的指令。
- 参数type 可使用 "r"代表读取，"w"代表写入。依照此type 值，popen()会建立管道连到子进程的标准输出设备或标准输入设备，然后返回一个文件指针。随后进程便可利用此文件指针来读取子进程的输出设备或是写入到子进程的标准输入设备中。
- 此外，所有使用文件指针(FILE*)操作的函数也都可以使用，除了fclose()以外。
- 返回值：若成功则返回文件指针, 否则返回NULL, 错误原因存于errno 中.

```c++
int xshellExecute(const char *cmd, vector<string> &resvec) 
{
	#define LINE_SIZE (1024)
	
    int retval = -1;
	FILE * pp = NULL; 
	char tmp[LINE_SIZE + 1]; // -- 设置一个合适的长度，以存储每一行输出
	
	resvec.clear();
#ifndef WIN32
	pp = popen(cmd, "r"); // -- 建立管道
	if (!pp) {
		perror("[xshellExecute-error]");
		DbgPrint("[-] xshellExecute cant run \"%s\"\n", cmd);
        goto DONE;
    }    
	// -- while()  
    while((!feof(pp)) && (fgets(tmp, LINE_SIZE, pp) != NULL)) {
        tmp[LINE_SIZE] = 0;
		if (tmp[strlen(tmp) - 1] == '\n') {
            tmp[strlen(tmp) - 1] = '\0'; // -- 去除换行符
        }
        resvec.push_back(tmp);
    }
	
    retval = pclose(pp); // -- 关闭管道
#endif
DONE:	
    return retval;
}

```

##### mmap

- [详细介绍，里面有关于page cache即页缓存的说明](https://zhuanlan.zhihu.com/p/67894878)

  ```c
  void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
  ```

  - length为文件中映射到内存的部分的长度
  - offset：文件映射的偏移量，通常设置为0，代表从文件最前方开始对应，offset必须是page size大小的整数倍。
  - mmap返回值相当于一个char\*，我们可以对这个char*进行操作，读就是正常的读使用strcpy这种操作内存的读取数据，我们根据偏移量就可以得到想读的内容，写的时候是直接在这块内存上写入东西，最后映射到磁盘上也会进行相应的变化，但是写的时候要注意会不会越界什么的，如果访问的区域超过了length的大小，就会越界产生段错误。所以在下面的例子中，使用strcpy拷贝内存上的数据时，尽量使用strncpy这种可以控制大小的，要不然没有\0，函数不知道读到那里结束，就会一直读下去就会产生段错误。
  - 用写操作访问这块内存时会直接覆盖原来的内容，因为这块内存现在被写入了一些东西，映射回磁盘就是改了之后的数据。

- read函数读取文件时，会将磁盘上的文件缓存到page cache(也是内存中的地址)中，然后在进行系统调用，从page cache拷贝到内核缓冲区中，然后在从内核缓冲区拷贝到用户缓冲区中，这样就会有多次的数据拷贝。read并不是直接读取数据到用户缓冲区的。因为用户空间和内存空间是分开的，我们只能在内核空间中将数据拷贝到内核缓冲区中，并不能直接拷贝到用户缓冲区中，他们两者是隔开的

- mmap()在数据加载到page cache的过程中，会触发大量的page fault和建立页表映射的操作，开销并不小。另一方面，随着硬件性能的发展，内存拷贝消耗的时间已经大大降低了。所以啊，很多情况下，mmap()的性能反倒是比不过read()和write()的。

- 以上说明mmap系统调用是将用户空间中的一部分内存直接进行页表的映射，相当于直接进行修改了，不用通过read函数在进行操作了。

- ```c
  //打开文件
  	fd = open("testdata",O_RDWR);
  	//创建mmap
  	start = (char *)mmap(NULL,128,PROT_READ|PROT_WRITE,MAP_SHARED,fd,0);
  	//读取文件	
  	strcpy(buf,start);
  	printf("%s\n",buf);
  	//写入文件
  	strcpy(start,"Write to file!\n");
   
  	munmap(start,128); //取消映射
  	close(fd);
  ```

- 取消映射函数

  ```c
  int munmap(void *addr, size_t length);
  ```

##### dup

```
/* Standard file descriptors.  */
#define STDIN_FILENO    0       /* Standard input.  */
#define STDOUT_FILENO   1       /* Standard output.  */
#define STDERR_FILENO   2       /* Standard error output.  */

int dup(int oldfd);
int dup2(int oldfd, int newfd);  
dup2() makes newfd be the copy of oldfd, closing newfd first if necessary  dup2() 使 newfd 成为 oldfd 的副本，必要时先关闭 newfd
```

- 一般在程序实现重定向都会用到dup2函数。将标准输入，标准输出，标准错误输出重定向到其他文件。

  ```
  int fd = open("temp", O_RDWR | O_CREAT, 0644);
  int fd1;
  dup2(1, fd1); //fd1保存标准输出文件描述符，临时保存标准输出文件描述符，如果要恢复要使用这个
  dup2(fd, 1);   //将标准输出文件描述符1复制为fd，此时1和fd都指向"temp"文件
  printf("xixihaha\n");//将该句输出到文件"temp"中
  dup2(fd1, 1);   //将描述符1改回为标准输出描述符
  printf("ooo\n");//这句输出在终端上
  ```

  - 最开始我的思路是这样子的，但是结果缺大相径庭，两条语句都输出在了终端上，没有重定向到文件"temp"中，检查完逻辑关系之后，发现没有什么大问题，那就只有一种可能就是缓冲区的问题了，经过下面这段代码的验证证实了我的想法。

  - 可能进行dup2之后的printf打印的东西不是行缓冲，不是遇到换行符’\n’刷新缓冲区，我的猜想可能是与文件操作相同，用的是全缓冲，只有当写满时才能刷新缓冲区

    ```
    int fd = open("temp", O_RDWR | O_CREAT, 0644); //打开一个文件
    int fd1;   
    dup2(1, fd1);   //fd1保存标准输出文件描述符
    dup2(fd, 1);    //将标准输出文件描述符1复制为fd，此时1和fd都指向"temp"文件
    printf("xixihaha\n");  //将该句输出到文件"temp"中
    fflush(stdout);        //清空缓冲区
    dup2(fd1, 1);         //将描述符1改回为标准输出描述符
    printf("ooo\n");      //这句输出在终端上
    close(fd1);
    ```


##### stat、lstat、fstat

- ```
  stat, fstat, lstat, fstatat - get file status
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <unistd.h>
  
  int stat(const char *pathname, struct stat *buf);
  int fstat(int fd, struct stat *buf);
  int lstat(const char *pathname, struct stat *buf);
  
  stat()用来将参数file_name 所指的文件状态, 复制到参数buf 所指的结构中。
  stat 和lstat的区别：当文件是一个符号链接时，lstat返回的是该符号链接本身的信息；而stat返回的是该链接指向的文件的信息。
  ```

- ```
  struct stat {
                 dev_t     st_dev;         /* ID of device containing file */
                 ino_t     st_ino;         /* inode number */
                 mode_t    st_mode;        /* file type and mode */
                 nlink_t   st_nlink;       /* number of hard links */
                 uid_t     st_uid;         /* user ID of owner */
                 gid_t     st_gid;         /* group ID of owner */
                 dev_t     st_rdev;        /* device ID (if special file) */
                 off_t     st_size;        /* total size, in bytes */
                 blksize_t st_blksize;     /* blocksize for filesystem I/O */
                 blkcnt_t  st_blocks;      /* number of 512B blocks allocated */
  
                 /* Since Linux 2.6, the kernel supports nanosecond
                    precision for the following timestamp fields.
                    For the details before Linux 2.6, see NOTES. */
  
                 struct timespec st_atim;  /* time of last access */
                 struct timespec st_mtim;  /* time of last modification */
                 struct timespec st_ctim;  /* time of last status change */
  
             #define st_atime st_atim.tv_sec      /* Backward compatibility */
             #define st_mtime st_mtim.tv_sec
             #define st_ctime st_ctim.tv_sec
             };
             
  The following mask values are defined for the file type of the st_mode field:
  
             S_IFMT     0170000   bit mask for the file type bit field
  
             S_IFSOCK   0140000   socket
             S_IFLNK    0120000   symbolic link
             S_IFREG    0100000   regular file
             S_IFBLK    0060000   block device
             S_IFDIR    0040000   directory
             S_IFCHR    0020000   character device
             S_IFIFO    0010000   FIFO
             
  Because tests of the above form are common, additional macros are defined by POSIX to allow the test of the file type in st_mode to be written more
         concisely:
  
             S_ISREG(m)  is it a regular file?
  
             S_ISDIR(m)  directory?
  
             S_ISCHR(m)  character device?
  
             S_ISBLK(m)  block device?
  
             S_ISFIFO(m) FIFO (named pipe)?
  
             S_ISLNK(m)  symbolic link?  (Not in POSIX.1-1996.)
  
             S_ISSOCK(m) socket?  (Not in POSIX.1-1996.)
  
  ```

- stat64系列函数包括stat64,fstat64,lstat64。由于stat系列函数只能获取32位长度的文件的属性，所以[glibc](https://so.csdn.net/so/search?q=glibc&spm=1001.2101.3001.7020)又提供了stat64系列函数，用于获取64位长度的文件的属性。其中结构体也是stat64

  ```
  使用stat64需要添加宏定义_GNU_SOURCE
  
  #ifndef _GNU_SOURCE
  	#define _GNU_SOURCE
  #endif
  
  int isFolder(const char *path)
  {
  	struct stat64 st;
   
  	if(0 != stat64(path, &st)){
  		return 0;
  	}
  	
  	if(S_ISDIR(st.st_mode)){
  		return 1;
  	}else{
  		return 0;
  	}
  }
  
  int isLink(const char *path)
  {
  	struct stat64 st;
  	
  	if(0 != lstat64(path, &st)){
  		return 0;
  	}
  	
  	if(S_ISLNK(st.st_mode)){
  		return 1;
  	}else{
  		return 0;
  	}
  }
  ```

  

###### 多次打开同一文件与O_APPEND

- 重复打开同一文件读取

  - 一个进程中两次打开同一个文件，然后分别读取，看结果会怎么样
  - 结果无非2种情况：一种是fd1和fd2分别读，第二种是接续读。经过实验验证，证明了结果是fd1和fd2分别读。
  - 分别读说明：我们使用open两次打开同一个文件时，fd1和fd2所对应的文件指针是不同的2个独立的指针。文件指针是包含在动态文件的文件管理表中的，所以可以看出linux系统的进程中不同fd对应的是不同的独立的文件管理表。

- 重复打开同一文件写入

  - 一个进程中2个打开同一个文件，得到fd1和fd2.然后看是分别写还是接续写？
  - 正常情况下我们有时候需要分别写，有时候又需要接续写，所以这两种本身是没有好坏之分的。关键看用户需求
  - 默认情况下应该是：分别写（实验验证过的）

  - 有时候我们希望接续写而不是分别写？办法就是在open时加O_APPEND标志即可

- O_APPEND的实现原理和其原子操作性说明

  - O_APPEND为什么能够将分别写改为接续写？关键的核心的东西是文件指针。分别写的内部原理就是2个fd拥有不同的文件指针，并且彼此只考虑自己的位移。但是O_APPEND标志可以让write和read函数内部多做一件事情，就是移动自己的文件指针的同时也去把别人的文件指针同时移动。（也就是说即使加了O_APPEND，fd1和fd2还是各自拥有一个独立的文件指针，但是这两个文件指针关联起来了，一个动了会通知另一个跟着动）
  - O_APPEND对文件指针的影响，对文件的读写是原子的。
  - 原子操作的含义是：整个操作一旦开始是不会被打断的，必须直到操作结束其他代码才能得以调度运行，这就叫原子操作。每种操作系统中都有一些机制来实现原子操作，以保证那些需要原子操作的任务可以运行。



### IO模型

- 读常规文件是不会阻塞的，不管读多少字节，read一定会在有限的时间内返回。从终端设备或网络读则不一定，如果从终端输入的数据没有换行符，调用read读终端设备就会阻塞，如果网络上没有接收到数据包，调用read从网络读就会阻塞，至于会阻塞多长时间也是不确定的，如果一直没有数据到达就一直阻塞在那里。同样，写常规文件是不会阻塞的，而向终端设备或网络写则不一定。
  - 终端设备例如鼠标和键盘，如果read是阻塞的读取，读取键盘的时候没有数据阻塞在这里，鼠标就不能响应，反过来一样，如果设置为非阻塞的，当键盘没数据时直接返回，响应鼠标的数据，这样就能响应所有的终端设备，linux下一切皆文件，终端设备和socket都是文件，所以会有这样的问题，但是常规文件是实实在在的文件放在那里，想写就写，想读就读，没有阻塞等待数据一说。
  - 可以通过fcntl设置文件为非阻塞。

##### IO多路复用

###### epoll

- ET和LT模式
  - 对于采用LT工作模式的文件描述符，当epoll_wait检测到其上有事件发生并将此事件通知应用程序后，应用程序可以不立即处理此事件，直到该事件被处理。而对于ET工作模式的文件描述符，当epoll_wait检测到其上有事件发生并将此事件通知应用程序后，应用程序必须立即处理此事件，因为后续的epoll_wait将不会再向应用程序通知这一事件，可见，ET模式在很大程度上降低了同一个epoll事件被重复触发的次数。
  - LT水平触发模式下，发送端发送helloword，接收端recv只接受五位时，仅仅读取了hello，下一次调用epoll_wait时，未处理完的事件还会被再次触发，将剩下的world读取。
  - ET边缘触发模式下，发送端发送helloword，接收端recv时，仅仅读取了hello，下一次调用epoll_wait时，未处理完的事件不会被再次触发（通知应用程序），每次必须将就绪文件描述符上的事件处理完成。
  - LT 是默认的工作方式
  - ET模式内核实现时，内核事件表底层是红黑树,其拥有的链表会将rdlist中就绪的文件描述符通过txlist拷贝给用户空间，并且rdlist会被清空。
  - LT模式内核实现时，将rdlist中的就绪文件描述符通过txlist拷贝给用户空间，rdlist也会被清空，但是会将未处理的或处理未完成的文件描述符又返回给rdlist，以便下次继续访问。
  - LT是事件处理完删除，ET是通知后就删除。
  - 这就相当于ET模式下，通知完之后就从epoll实例中删除了，后续就不通知了，LT模式下除非自己手动从epoll实例中删除，否则会一直在epoll实例中会一直通知
  - 在使用epoll时会创建一个epoll实例，然后用epoll_ctl函数将自己需要关注的事件注册到epoll实例中，epoll_wait函数会返回就绪的我们关注的事件，如果事ET模式就自己删除了，LT模式下不会自己删除
  - ET模式下每次write或read需要循环write或read直到返回EAGAIN错误。以读操作为例，这是因为ET模式只在socket描述符状态发生变化时才触发事件，如果不一次把socket内核缓冲区的数据读完，会导致socket内核缓冲区中即使还有一部分数据，该socket的可读事件也不会被触发。根据上面的讨论，若ET模式下使用阻塞IO，则程序一定会阻塞在最后一次write或read操作，因此说ET模式下一定要使用非阻塞IO。

### IPC进程间通信

- ipcs/ipcrm命令 是linux/uinx上提供关于一些进程间通信方式的信息，包括共享内存，消息队列，信号
- 多进程间通信常用的技术手段包括共享内存、消息队列、信号量等等，Linux系统下自带的ipcs命令是一个极好的工具，可以帮助我们查看当前系统下以上三项的使用情况，从而利于定位多进程通信中出现的通信问题。

##### 共享内存

- 

##### 管道

- [管道的详细介绍](https://zhuanlan.zhihu.com/p/58489873)

- mkfifo

  ```c
  int mkfifo(const char *pathname, mode_t mode);
  ```

  - pathname必须不存在，如果存在管道创建不成功。
  - mkfifo返回的是一个文件描述符，可以使用read，write来操作，fread，fwrite不行
  - 如果read读取的话，管道里没有数据，是会阻塞的，所以需要进行处理

###### 匿名管道

- 当我们在一般语境下提起管道这个词时，说的就是匿名管道。匿名管道在两个有亲缘关系的进程（即存在父子或兄弟关系的进程）之间创建，本质上是由内核管理的一小块内存缓冲区，默认大小由系统中的PIPE_BUF常量指定（默认为一页，即4096字节）。它的一端连接一个进程的输出，用于写入数据；另一端连接另一个进程的输入，用于读出数据。管道是半双工工作的，也就是可以A进程读B进程写，也可以B进程读A进程写，但是A、B两个进程不能同时读写。

- 匿名管道在父进程中通过系统调用int pipe(int fd[2])创建。fd[]为两个文件描述符的数组，其中fd[0]固定为管道的读端，fd[1]固定为管道的写端，不能弄反。在父进程fork出子进程之后，使用管道的两方分别关闭fd[0]和fd[1]，就可以操作管道了。如下图所示，父进程关闭fd[1]，从管道读数据；子进程关闭fd[0]，向管道写数据。

  <img src="http://imgconvert.csdnimg.cn/aHR0cHM6Ly91cGxvYWQtaW1hZ2VzLmppYW5zaHUuaW8vdXBsb2FkX2ltYWdlcy8xOTUyMzAtNzQ0YTY2MjM0MWI3OWY0NC5wbmc?x-oss-process=image/format,png" style="zoom:50%;" />

- 管道的读写用最基本的read()/write()系统调用来实现。注意当管道读取端没有关闭且管道已满时，write()会被阻塞；而当管道写入端没有关闭且管道为空时，read()会被阻塞。当然，如果管道的读写两端都被关闭，管道就会消失。

- 在 Linux 中，管道的实现并没有使用专门的数据结构，而是借助了文件系统的file结构和VFS的索引节点inode。通过将两个 file 结构指向同一个临时的 VFS 索引节点，而这个 VFS 索引节点又指向一个物理页面而实现的。

- 有两个 file 数据结构，但它们定义文件操作例程地址是不同的，其中一个是向管道中写入数据的例程地址，而另一个是从管道中读出数据的例程地址。这样，用户程序的系统调用仍然是通常的文件操作，而内核却利用这种抽象机制实现了管道这一特殊操作。

  <img src="http://imgconvert.csdnimg.cn/aHR0cHM6Ly91cGxvYWQtaW1hZ2VzLmppYW5zaHUuaW8vdXBsb2FkX2ltYWdlcy8xOTUyMzAtYjczMDhjMDYzMmY1YjA2Zi5wbmc?x-oss-process=image/format,png" style="zoom:67%;" />

  - 注意两个file结构的操作f_op是不同的，这样就可以巧妙地通过普通的文件操作来实现对管道的操作了。

- 管道实现的源代码在fs/pipe.c中，在pipe.c中有很多函数，其中有两个函数比较重要，即管道读函数pipe_read()和管道写函数pipe_wrtie()。管道写函数通过将字节复制到 VFS 索引节点指向的物理内存而写入数据，而管道读函数则通过复制物理内存中的字节而读出数据。当然，内核必须利用一定的机制同步对管道的访问，为此，内核使用了锁、等待队列和信号。

  - 当写进程向管道中写入时，它利用标准的库函数write()，系统根据库函数传递的文件描述符，可找到该文件的 file 结构。file 结构中指定了用来进行写操作的函数（即写入函数）地址，于是，内核调用该函数完成写操作。写入函数在向内存中写入数据之前，必须首先检查 VFS 索引节点中的信息，同时满足如下条件时，才能进行实际的内存复制工作：
    - 内存中有足够的空间可容纳所有要写入的数据；
    - 内存没有被读程序锁定。
  - 如果同时满足上述条件，写入函数首先锁定内存，然后从写进程的地址空间中复制数据到内存。否则，写入进程就休眠在 VFS 索引节点的等待队列中，接下来，内核将调用调度程序，而调度程序会选择其他进程运行。写入进程实际处于可中断的等待状态，当内存中有足够的空间可以容纳写入数据，或内存被解锁时，读取进程会唤醒写入进程，这时，写入进程将接收到信号。当数据写入内存之后，内存被解锁，而所有休眠在索引节点的读取进程会被唤醒。
  - 管道的读取过程和写入过程类似。但是，进程可以在没有数据或内存被锁定时立即返回错误信息，而不是阻塞该进程，这依赖于文件或管道的打开模式。反之，进程可以休眠在索引节点的等待队列中等待写入进程写入数据。当所有的进程完成了管道操作之后，管道的索引节点被丢弃，而共享数据页也被释放。

- 管道读写总共有4096个字节，可以一直写4096个字节，然后等着读，匿名管道的底层是一个环形结构。具体实现目前不需要管。

###### 命名管道

- 由于基于fork机制，所以管道只能用于父进程和子进程之间，或者拥有相同祖先的两个子进程之间 (有亲缘关系的进程之间)。为了解决这一问题，Linux提供了FIFO方式连接进程。FIFO又叫做命名管道(named PIPE)。
- FIFO (First in, First out)为一种特殊的文件类型，它在文件系统中有对应的路径。当一个进程以读(r)的方式打开该文件，而另一个进程以写(w)的方式打开该文件，那么内核就会在这两个进程之间建立管道，所以FIFO实际上也由内核管理，不与硬盘打交道。之所以叫FIFO，是因为管道本质上是一个先进先出的队列数据结构，最早放入的数据被最先读出来，从而保证信息交流的顺序。FIFO只是借用了文件系统(file system,命名管道是一种特殊类型的文件，因为Linux中所有事物都是文件，它在文件系统中以文件名的形式存在。)来为管道命名。写模式的进程向FIFO文件中写入，而读模式的进程从FIFO文件中读出。当删除FIFO文件时，管道连接也随之消失。FIFO的好处在于我们可以通过文件的路径来识别管道，从而让没有亲缘关系的进程之间建立连接

###### 管道的使用

- 对于匿名管道来说，函数的创建如下

  ```
  int pipe(int fd[2]) 提供一个单向数据流，该函数返回两个文件描述符，fd[0]和fd[1]，前者用来打开读，后者用来打开写。
  ```

  - 一个进程（它将成为父进程）创建一个管道后调用fork派生一个自身的副本，父进程关闭这个管道的读出端，子进程关闭该管道的写入端，这样就在父子进程间形成了一个单向数据流

  - 函数pipe返回的文件描述符是已经打开的，我们不能在用函数open打开这个文件描述符，只需要关闭父进程的读出端和子进程的写入端，相当于数据就可以从父进程流向子进程，也可以相反，由子进程流向父进程。

  - 若需要一个双向的数据流，就得创建两个管道，每个方向一个，示例如下

    ```c++
    #include <iostream>
    #include <unistd.h>
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <wait.h>
    
    using namespace std;
    
    int main()
    {
        const char* parent_talk[] = {"Hello", 
                              "Can you tell me current data and time",
                              "I have to go, Bye",
                              NULL};
        const char* child_talk[] = {"Hi",
                             "No problem:",
                             "Bye",
                             NULL};
    
        int fd1[2], fd2[2];
        int res1 = pipe(fd1);
        int res2 = pipe(fd2);
        if(res1 < 0){
            printf("create pipe1 error\n");
            exit(1);
        }
    
        if(res2 < 0){
            printf("create pipe2 error\n");
            exit(1);
        }
    
    
        pid_t pid;
        pid = fork();
    
        if(pid == 0){
            close(fd1[1]);
            close(fd2[0]);
            char buffer[256];
    
            int i = 0;
            const char *child = child_talk[i];
            while(child){
                read(fd1[0], buffer, 256);
                printf("Parent:> %s\n", buffer);
                if(i == 1){
                    time_t t;
                    time(&t);
                    sprintf(buffer, "%s%s", child, ctime(&t));
                    write(fd2[1], buffer, strlen(buffer) + 1);
                }else{
                    write(fd2[1], child, strlen(child) + 1);
                }
    
                ++i;
                child = child_talk[i];
            }
    
            close(fd1[0]);
            close(fd2[1]);
        }else if(pid > 0){
            char buffer[256];
            close(fd1[0]);
            close(fd2[1]);
    
            int i = 0;
            const char *parent = parent_talk[i];
            while(parent){
                write(fd1[1], parent, strlen(parent) + 1);
                read(fd2[0], buffer, 256);
                printf("Child:> %s\n", buffer);
                ++i;
                parent = parent_talk[i];
            }
    
            close(fd2[0]);
            close(fd1[1]);
    
            int status;
            wait(&status);
        }else{
            printf("create child error\n");
        }
    
        return 0;
    }
    ```

- 有名管道的创建，函数如下

  ```
  int mkfifo(const char *pathname, mode_t mode) ，该函数隐含指定权限为O_CREAT | O_EXCL，即就是mkfifo要么创建一个新的fifo，要么返回错误（因为所指定名字的fifo已经存在），若不想创建新的fifo，就直接用open打开一个已经存在的fiffo。
  ```

  - FIFO不能打开既用来读又用来写，因为FIFO是半双工的，所以如果两端都能通信，也需要创建两个FIFO，下面是两端通信的示例

    ```
    //头文件
    #include <iostream>
    #include <unistd.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <fcntl.h>
    #include <sys/stat.h>
    #include <string.h>
    
    using namespace std;
    
    const char *write_fifo_name = "write_fifo";
    const char *read_fifo_name = "read_fifo";
    
    //服务器端的代码：
    
    #include "utility.h"
    
    int main()
    {
        int write_fd, read_fd;
    
        int res = mkfifo(write_fifo_name, O_CREAT|O_EXCL|0600);
        if(res == -1){
            printf("mkfifo error.\n");
            exit(1);
        }
    
        write_fd = open(write_fifo_name, O_WRONLY);  //只写方式打开写管道
        if(write_fd == -1){    //以只写方式打开文件失败
            printf("open write fifo error.\n");
            unlink(write_fifo_name);   //解除文件的连接
            exit(1);
        }
    
        printf("waiting Client Connecct.....\n");
        while((read_fd = open(read_fifo_name, O_RDONLY)) == -1){   //一直等待，直到打开读文件成功
            sleep(1);
        }
        printf("client connect ok.\n");
    
        char sendbuf[256];
        char recvbuf[256];
    
        //进行服务器和客户端的通信
        while(1){
            printf("Ser:>");
            scanf("%s", sendbuf);   //输入服务器端的信息
            if(strncmp(sendbuf, "quit", 4) == 0){   //比较是否要退出，若服务器端请求退出，则先解除文件再退出
                unlink(write_fifo_name);  //解除文件
                write(write_fd, sendbuf, strlen(sendbuf) + 1);   //告诉客户端服务器端要退出
                break;
            }
            write(write_fd, sendbuf, strlen(sendbuf) + 1);  //将服务器端的信息写入发送缓冲区
            read(read_fd, recvbuf, 256);   //读取接收缓冲区的客户端发送的数据
            printf("Cli:>%s\n", recvbuf);
        }
    
        return 0;
    }
    
    //客户端的代码：
    #include "utility.h"
    
    int main()
    {
        int write_fd, read_fd;
    
        int res = mkfifo(read_fifo_name, O_CREAT|O_EXCL|0600);
        if(res == -1){
            printf("make read fifo error.\n");
            exit(1);
        }       
    
        read_fd = open(write_fifo_name, O_RDONLY);   //只读方式打开写管道
        if(read_fd == -1){     //打开写管道失败，就无法读取服务器端发来的数据
            printf("server error.\n");
            unlink(read_fifo_name);   //断开写连接
            exit(1);
        }
    
        write_fd = open(read_fifo_name, O_WRONLY);   //以只写方式打开读管道，准备写入客户端要发送的数据
        if(write_fd == -1){
            printf("client connect server error.\n");
            exit(1);
        }
    
        char sendbuf[256];
        char recvbuf[256];
        while(1){
            read(read_fd, recvbuf, 256);    //客户端首先读取服务器端发来的数据
            printf("Ser:>%s\n", recvbuf);
            printf("Cli:>");
            scanf("%s", sendbuf);     //客户端写入自己要发送给服务器端的数据
            if(strncmp(sendbuf, "quit", 4) == 0){   //若是客户端要退出，则解除读管道，发送消息告诉服务器端客户端要退出
                unlink(read_fifo_name);   //解除连接
                write(write_fd, sendbuf, strlen(sendbuf) + 1);   //写入要退出的数据
                break;
            }
            write(write_fd, sendbuf, strlen(sendbuf) + 1);    //将数据写入到要发送给服务器端的缓冲区中
        }
        return 0;
    }
    ```

  - mkfifo创建的FIFO需要用open函数打开，在打开的时候就要确定是以读或者写的方式打开，客户端和服务器端都创建了一个FIFO，然后用open函数打开对方的FIFO，然后在进行读或者写。

- 最后来简单的说一说管道和有名管道的区别：

  - 有名管道可以进行无亲缘关系的进程间通信，但是管道只能用于有亲缘关系的进程间通信。
  - 创建并打开一个管道只需要pipe函数就够了，但是创建并打开FIFO需要在调用mkfifo后再调用open函数。
  - 管道在所有进程最终都关闭它之后自动消失，但是FIFO只有在调用unlink后才能从文件系统中删除。

- pipe函数返回的是两个文件描述符fd[]，一个数组，直接就打开了，需要关闭一个，而mkfifo只是创建了这个文件，我们还需要自己用open函数打开，open函数返回文件描述符，这样最后我们只需要关闭open返回的这个文件描述符就可以了，因为open确定了以都或者写的方式打开，这样就能确定FIFO的数据流向。

- 管道在所有进程都关闭这个管道的情况下会消失，FIFO需要用unlink在文件系统中删除。FIFO需要两个进程都关闭自己进程用open打开的文件描述符就可以消失，一端关闭是不会消失的，因为一端关闭我们也可以重新打开，并不是一端关闭就是关闭了。

  - 如果两端都需要关闭，可以协商在写入端关闭之前写入数据，然后对方在读到数据之后也就关闭了，读端关闭是不能写入的，所以两端关闭只能由写入端来确定。

### 设计模式

#### 创建型模式

- 创建型模式关注点是如何创建对象，其核心思想是要把对象的创建和使用相分离，这样使得两者能相对独立地变换。
- 创建型模式包括：
  - 工厂方法：Factory Method
  - 抽象工厂：Abstract Factory
  - 建造者：Builder
  - 原型：Prototype
  - 单例：Singleton

##### 简单工厂

- 简单工厂模式是一种创建型设计模式，其主要目的是通过一个工厂类，根据客户端的请求来创建不同类型的对象。简单工厂模式属于工厂模式的一种，它封装了对象的创建过程，使得客户端代码不需要直接实例化具体的产品类，从而达到解耦的目的。

- 简单工厂模式包含以下几个主要角色：

  - **产品接口（Product Interface）：** 定义了产品的通用接口，产品类们实现这个接口。

    ```c++
    class Product {
    public:
        virtual void display() = 0;
        virtual ~Product() {}
    };
    ```

  - **具体产品（Concrete Products）：** 实现了产品接口的具体产品类。

    ```c++
    class ConcreteProductA : public Product {
    public:
        void display() override {
            // 具体产品 A 的实现
        }
    };
    
    class ConcreteProductB : public Product {
    public:
        void display() override {
            // 具体产品 B 的实现
        }
    };
    ```

  - **简单工厂类（Simple Factory）：** 负责根据客户端的请求创建不同类型的产品对象。这个类通常包含一个静态方法用于对象的创建。

    ```c++
    class SimpleFactory {
    public:
        static Product* createProduct(char productType) {
            switch (productType) {
                case 'A':
                    return new ConcreteProductA();
                case 'B':
                    return new ConcreteProductB();
                default:
                    return nullptr; // 可以根据需求返回默认产品或抛出异常
            }
        }
    };
    ```

  - **客户端（Client）：** 使用简单工厂类来创建具体的产品对象。

    ```c++
    int main() {
        Product* productA = SimpleFactory::createProduct('A');
        if (productA) {
            productA->display();
            delete productA;
        }
    
        Product* productB = SimpleFactory::createProduct('B');
        if (productB) {
            productB->display();
            delete productB;
        }
    
        return 0;
    }
    ```

  - 在这个例子中，客户端通过简单工厂类的静态方法 `createProduct` 来获取具体的产品对象，而不需要直接调用具体产品的构造函数。这样的做法使得客户端与具体产品的实现细节解耦，对于客户端而言，只需要知道产品接口和简单工厂的接口即可。

- 一般情况下工厂类中都会有一个static静态方法来创建具体的产品，产品有一个基类，然后这个静态方法返回的是基类的指针指向子类，而基类中都会有一些虚函数，子类实现虚函数这样就可以形成多态。这样就可以弄成，接口相同，实现的细节不同，相当于一个工厂建造了很多产品，但是产品的接口都是一样的。

- 使用简单工厂的主要意义在于，生产出来的产品接口都是一样的，这样可以通过这些公共接口简单化一些操作。

- 简单工厂模式通常在以下情况下被使用：
  1. 创建对象的逻辑相对简单：*简单工厂模式适用于对象的创建逻辑相对简单，不涉及复杂的逻辑判断或多个步骤的情况。如果对象的创建过程较为复杂，可能需要考虑使用其他工厂模式，比如工厂方法模式。
  2. 客户端不需要知道具体产品的类名：简单工厂模式通过工厂类来负责具体产品的创建，客户端只需知道产品的接口或抽象类，而无需知道具体产品的类名。这有助于降低客户端与具体产品的耦合。
  3. 对象的创建频率不高： 如果对象的创建频率很高，而且具体产品的类型经常变化，简单工厂模式可能会导致工厂类变得复杂且难以维护。在这种情况下，工厂方法模式可能更适合，因为它允许通过子类化来动态扩展工厂。
  4. 对于产品的种类有限制： 当具体产品的种类相对固定，不容易频繁变动时，简单工厂模式是一种简单且有效的选择。

- 简单工厂模式中也可以不设计工厂类，但是这样一般不太好，下面是一个不设计工厂类的例子

  ```c++
  #include <iostream>
  
  class Product {
  public:
      virtual void display() const = 0;
      static Product* createProduct(int type);
  
      virtual ~Product() = default;
  };
  
  class ConcreteProductA : public Product {
  public:
      void display() const override {
          std::cout << "Concrete Product A" << std::endl;
      }
  };
  
  class ConcreteProductB : public Product {
  public:
      void display() const override {
          std::cout << "Concrete Product B" << std::endl;
      }
  };
  
  Product* Product::createProduct(int type) {
      switch (type) {
          case 1:
              return new ConcreteProductA();
          case 2:
              return new ConcreteProductB();
          default:
              return nullptr;
      }
  }
  
  int main() {
      // 使用静态方法创建产品
      Product* productA = Product::createProduct(1);
      Product* productB = Product::createProduct(2);
  
      // 使用产品
      if (productA) {
          productA->display();
          delete productA;
      }
  
      if (productB) {
          productB->display();
          delete productB;
      }
  
      return 0;
  }
  ```

  - 在产品基类中写一个static函数来创建产品
  - 在这个例子中，`Product` 类包含一个静态方法 `createProduct`，它根据传入的参数创建相应的产品对象。在 `main` 函数中，我们使用这个静态方法创建了两个不同类型的产品，并调用了它们的 `display` 方法。
  - 这种做法可能违反了设计模式的一些原则，特别是开闭原则和单一职责原则。正式的简单工厂模式建议使用独立的工厂类，以提高代码的可维护性和灵活性。

- 尽管简单工厂模式在某些情况下很有用，但需要注意的是，它有一些缺点，比如扩展性较差。如果系统中需要添加新的产品，可能需要修改工厂类的代码，这违反了开闭原则。在更复杂的应用中，可能需要考虑使用其他工厂模式，如工厂方法模式或抽象工厂模式。

###### FEED例子

- FEED中写了一个基类Field，基类中有一个static函数，然后根据不同的数据类型来创建子类，子类来实现Output和GetMaxSize纯虚函数，目的是根据不同的类型来向pBuffer中拼写字符，所有的目的都是一个，通过Output来向传入的pBuffer中拼写字符，子类具体实现这个函数就可以了，然后我们就可以写一个for循环来通过类来调用这个函数，传入的pBuffer是一个，这样就可以拼写好pBuffer中的内容。

- 基类Field

  ```c++
  class Field
  {
  public:
    static Field * CreateField(TiXmlElement * pXML, MessageText *pMessage);
  
    static const std::string & GetUnavailableFieldString();
    static void SetUnavailableFieldString(const std::string strNA);
  
  public:
    virtual ~Field();
  
    virtual unsigned int Output(u8 *pBuffer) const = 0;
    virtual unsigned int GetMaxSize() const = 0;
  
    void setFunction(std::string s)
    {
      m_szFunction = s;
    }
    std::string getFunction()
    {
      return m_szFunction;
    }
  
  protected:
    static std::string  s_strDefaultText;
    std::string m_szFunction;
  };
  ```

- 具体的中间子类

  ```c++
  class FieldRecord : public Field
  {
  public:
    FieldRecord(TiXmlElement *pXML, MessageText *pMessage);
  
  protected:
    const Record ** m_ppRecord;
  };
  
  class FieldOffset : public FieldRecord
  {
  public:
    FieldOffset(TiXmlElement *pXML, MessageText *pMessage);
  
  protected:
    int m_nOffset;
  };
  ```

- 具体的实际类，关于类型的类，这种类型有很多，每个类型都会有一个类

  ```c++
  class FieldU64 : public FieldOffset
  {
  public:
    FieldU64(TiXmlElement *pXML, MessageText *pMessage);
  
    unsigned int Output(u8 *pBuffer) const;
    unsigned int GetMaxSize() const;
  };
  ```

- 在实际的使用时，每一个具体的类都会有自己独特的字段和数据，但是都是通过Output来调用的。这样我们就可以写一个for循环，通过多态来实现向一个字符串里面拼写不同类型的数据，所有的类都是通过指向基类的指针调用的，但是多态最终用的是子类的实现方式。

##### 工厂方法

- 工厂方法模式（Factory Method Pattern）是一种创建型设计模式，其主要目的是定义一个用于创建对象的接口，但将实际的实例化工作延迟到子类。这样，客户端代码就可以在不同的子类中选择实例化的具体对象，从而实现了解耦。

- 以下是工厂方法模式的主要参与者：

  - **抽象产品（Abstract Product）：** 定义了产品的接口，是所有具体产品类的共同基类。

    ```c++
    class Product {
    public:
        virtual void display() = 0;
        virtual ~Product() {}
    };
    ```

  - **具体产品（Concrete Product）：** 实现了抽象产品接口的具体产品类。

    ```c++
    class ConcreteProductA : public Product {
    public:
        void display() override {
            // 具体产品 A 的实现
        }
    };
    
    class ConcreteProductB : public Product {
    public:
        void display() override {
            // 具体产品 B 的实现
        }
    };
    ```

  - **抽象工厂（Abstract Factory）：** 声明了一个创建产品对象的接口，由具体工厂类实现。

    ```c++
    class Factory {
    public:
        virtual Product* createProduct() = 0;
        virtual ~Factory() {}
    };
    ```

  - **具体工厂（Concrete Factory）：** 实现了抽象工厂接口的具体工厂类，负责创建具体产品的实例。

    ```c++
    class ConcreteFactoryA : public Factory {
    public:
        Product* createProduct() override {
            return new ConcreteProductA();
        }
    };
    
    class ConcreteFactoryB : public Factory {
    public:
        Product* createProduct() override {
            return new ConcreteProductB();
        }
    };
    ```

  - 客户端代码可以通过与抽象工厂和抽象产品进行交互，而不直接依赖于具体的产品类。具体的工厂类负责实际的对象创建，使得系统更加灵活，可以根据需求选择不同的工厂类来创建不同的产品。

  - 以下是一个简单的示例，演示了工厂方法模式的用法：

    ```c++
    int main() {
        Factory* factoryA = new ConcreteFactoryA();
        Product* productA = factoryA->createProduct();
        if (productA) {
            productA->display();
            delete productA;
        }
        delete factoryA;
    
        Factory* factoryB = new ConcreteFactoryB();
        Product* productB = factoryB->createProduct();
        if (productB) {
            productB->display();
            delete productB;
        }
        delete factoryB;
    
        return 0;
    }
    ```

##### 抽象工厂

- 抽象工厂模式（Abstract Factory Pattern）是一种创建型设计模式，它提供一个接口，用于创建一系列相关或相互依赖的对象，而无需指定它们的具体类。抽象工厂模式是工厂模式的一种扩展，旨在处理一组相关的产品，形成产品族。

- 抽象工厂模式的主要优点在于它能够确保一组相关的产品被一起创建，使得客户端代码不必关心具体产品的创建细节。它还支持产品族的概念，即一组相关的产品，而不仅仅是一个单一的产品。

- 抽象工厂模式和工厂方法不太一样，它要解决的问题比较复杂，不但工厂是抽象的，产品是抽象的，而且有多个产品需要创建，因此，这个抽象工厂会对应到多个实际工厂，每个实际工厂负责创建多个实际产品

- 使用抽象工厂模式时，客户端代码通过与抽象工厂和抽象产品进行交互，实现了与具体产品的解耦。这种方式使得系统更易于扩展，可以方便地引入新的产品系列。

- 以下是抽象工厂模式的主要角色：

  - **抽象工厂（Abstract Factory）：** 声明了一组用于创建产品的抽象方法，每个方法对应一个产品族。

    ```c++
    class AbstractFactory {
    public:
        virtual AbstractProductA* createProductA() = 0;
        virtual AbstractProductB* createProductB() = 0;
        virtual ~AbstractFactory() {}
    };
    ```

  - **具体工厂（Concrete Factory）：** 实现了抽象工厂接口的具体工厂类，负责创建一组相关的产品。

    ```c++
    class ConcreteFactory1 : public AbstractFactory {
    public:
        AbstractProductA* createProductA() override {
            return new ProductA1();
        }
    
        AbstractProductB* createProductB() override {
            return new ProductB1();
        }
    };
    
    class ConcreteFactory2 : public AbstractFactory {
    public:
        AbstractProductA* createProductA() override {
            return new ProductA2();
        }
    
        AbstractProductB* createProductB() override {
            return new ProductB2();
        }
    };
    ```

  - **抽象产品（Abstract Product）：** 声明了一组产品的抽象接口，每个具体产品实现这些接口。

    ```c++
    class AbstractProductA {
    public:
        virtual void display() = 0;
        virtual ~AbstractProductA() {}
    };
    
    class AbstractProductB {
    public:
        virtual void show() = 0;
        virtual ~AbstractProductB() {}
    };
    ```

  - **具体产品（Concrete Product）：** 实现了抽象产品接口的具体产品类。

    ```c++
    class ProductA1 : public AbstractProductA {
    public:
        void display() override {
            // 具体产品 A1 的实现
        }
    };
    
    class ProductB1 : public AbstractProductB {
    public:
        void show() override {
            // 具体产品 B1 的实现
        }
    };
    
    class ProductA2 : public AbstractProductA {
    public:
        void display() override {
            // 具体产品 A2 的实现
        }
    };
    
    class ProductB2 : public AbstractProductB {
    public:
        void show() override {
            // 具体产品 B2 的实现
        }
    };
    ```

  - 简单示例

    ```c++
    #include <iostream>
    
    // 抽象产品 A - 按钮
    class AbstractButton {
    public:
        virtual void display() = 0;
        virtual ~AbstractButton() {}
    };
    
    // 具体产品 A1 - 按钮
    class WindowsButton : public AbstractButton {
    public:
        void display() override {
            std::cout << "Windows Button\n";
        }
    };
    
    // 具体产品 A2 - 按钮
    class MacOSButton : public AbstractButton {
    public:
        void display() override {
            std::cout << "MacOS Button\n";
        }
    };
    
    // 抽象产品 B - 窗口
    class AbstractWindow {
    public:
        virtual void show() = 0;
        virtual ~AbstractWindow() {}
    };
    
    // 具体产品 B1 - 窗口
    class WindowsWindow : public AbstractWindow {
    public:
        void show() override {
            std::cout << "Windows Window\n";
        }
    };
    
    // 具体产品 B2 - 窗口
    class MacOSWindow : public AbstractWindow {
    public:
        void show() override {
            std::cout << "MacOS Window\n";
        }
    };
    
    // 抽象工厂
    class AbstractFactory {
    public:
        virtual AbstractButton* createButton() = 0;
        virtual AbstractWindow* createWindow() = 0;
        virtual ~AbstractFactory() {}
    };
    
    // 具体工厂 1
    class WindowsFactory : public AbstractFactory {
    public:
        AbstractButton* createButton() override {
            return new WindowsButton();
        }
    
        AbstractWindow* createWindow() override {
            return new WindowsWindow();
        }
    };
    
    // 具体工厂 2
    class MacOSFactory : public AbstractFactory {
    public:
        AbstractButton* createButton() override {
            return new MacOSButton();
        }
    
        AbstractWindow* createWindow() override {
            return new MacOSWindow();
        }
    };
    
    int main() {
        // 使用 Windows 工厂
        AbstractFactory* windowsFactory = new WindowsFactory();
        AbstractButton* windowsButton = windowsFactory->createButton();
        AbstractWindow* windowsWindow = windowsFactory->createWindow();
    
        windowsButton->display();
        windowsWindow->show();
    
        delete windowsButton;
        delete windowsWindow;
        delete windowsFactory;
    
        // 使用 MacOS 工厂
        AbstractFactory* macosFactory = new MacOSFactory();
        AbstractButton* macosButton = macosFactory->createButton();
        AbstractWindow* macosWindow = macosFactory->createWindow();
    
        macosButton->display();
        macosWindow->show();
    
        delete macosButton;
        delete macosWindow;
        delete macosFactory;
    
        return 0;
    }
    ```

    - 在这个例子中，`AbstractFactory` 定义了创建按钮和窗口的接口，而 `WindowsFactory` 和 `MacOSFactory` 分别实现了这个接口，用于创建相应的具体产品。

  - 抽象工厂主要是实现了多个产品线，相当于有多个产品基类，而工厂方法只有一个产品基类。抽象工厂中的抽象工厂类中有两个虚函数，每个虚函数生成一个产品，一般情况下这两个产品来自于不同的产品基类。这样就有一个额外的概念，相当于一个工厂生产出来了两个产品，这两个产品就有一种绑定到一起的概念。

##### 工厂方法总结

###### 工厂方法和抽象工厂区别

- 关注点不同：
  - 工厂方法模式： 关注一个产品等级结构，即一个抽象产品和其多个具体实现。每个具体工厂类负责创建特定的产品。
  - 抽象工厂模式： 关注多个产品等级结构，即多个抽象产品和每个抽象产品的多个具体实现。一个抽象工厂负责创建一整套产品。
- 产品等级结构数量：
  - 工厂方法模式： 通常只有一个抽象产品和多个具体产品，形成单一的产品等级结构。
  - 抽象工厂模式： 通常涉及多个抽象产品和每个抽象产品的多个具体产品，形成多个产品等级结构。
- 创建对象的方式：
  - 工厂方法模式： 每个具体工厂类负责创建一种具体产品。客户端代码通过与抽象工厂和抽象产品交互，选择并使用具体工厂创建具体产品。
  - 抽象工厂模式： 一个抽象工厂负责创建一整套产品，每个具体工厂类负责创建一种产品族。客户端代码通过与抽象工厂和抽象产品交互，选择并使用具体工厂创建整套产品。
- 扩展性：
  - 工厂方法模式： 更容易扩展，因为每个具体工厂类只负责创建一种产品，添加新产品时只需要添加对应的具体工厂和产品。
  - 抽象工厂模式： 扩展相对较复杂，因为每个抽象工厂类负责创建一整套产品，添加新产品时需要修改抽象工厂及其所有具体工厂的接口和实现。
- 用途：
  - 工厂方法模式： 适用于只有一个抽象产品等级结构，但存在多个具体产品实现的情况。
  - 抽象工厂模式： 适用于有多个抽象产品等级结构，每个产品族都有多个具体产品实现的情况。

###### 关于产品的说明

- 同一产品基类的产品，产品接口应该都是一样的，都是实现的基类中的纯虚函数。
- 既然是工厂方法，生产出来的产品应该看着一样，这样才是工厂，所以产品的接口都是一样的
- 虽然产品的接口一样，但是我们可以在每个具体的产品类中添加其他的字段，然后在new的时候给这个字段赋值，然后通过这个统一的接口根据每个具体类的数据产生不同的行为
- 实际的例子就是FEED中根据配置的数据类型不同，产生很多个类，这些类都是从一个基类中继承，每个类中的方法都一样是OutPut，但是每个类的字段可以不一样，我们在实例化的时候就可以区分，然后根据每个类中不同的字段值，实现OutPut这个方法，相当于最终都要调用OutPut这个方法，但是这个方法的实现在每个类中不同，多态来实现的。

###### 其他总结

- 定义一个用于创建对象的接口，让子类决定实例化哪一个类。Factory Method使一个类的实例化延迟到其子类。

- 工厂模式，指的是封装对象的创建过程，并将创建过程和操作过程分离，用户（创建者）无需关心具体过程，就像一个工厂生产产品一样，以便批量管理对象的创建，提高程序的可以维护性和扩展性。

- 工厂模式根据“产品制造过程”（对象创建）不同，分为简单工厂模式 (Simple Factory) 、工厂方法模式 (Factory Method) 、抽象工厂模式 (Abstract Factory)
  - 简单工厂模式，由创建对象类根据传入的类型参数确定对象种类实例。简单工厂模式是工厂模式中最简单的模式，但该模式并未能体现出工厂模式的精髓。
  - 工厂方法模式，声明一个创建对象的抽象方法基类，子类继承基类，由子类创建具体对象类实例。与简单工厂模式不同，工厂方法模式的对象实例化过程由子类实现。
  - 抽象工厂模式，提供一个创建一系列相关或相互依赖对象的接口，而无需指定它们具体的类。简单工厂和工厂方法只能创建同一类对象，抽象工厂可以创建一系列相关的对象。

- 三种工厂模式特点

  | 工厂模式 | 特点                                                       |
  | -------- | ---------------------------------------------------------- |
  | 简单工厂 | 针对一种类型实例对象，违背“开闭原则”                       |
  | 工厂方法 | 针对一种类型实现对象，但改正了简单工厂违背“开闭原则”的不足 |
  | 抽象工厂 | 针对多种类型实例对象                                       |

- 优点

  - 对“职责”分离，用户不需关心创建过程
  - 外界与具体类隔离，降低耦合性
  - “工厂方法”修正了“简单工厂”不符合“开闭原则”的不足
  - “抽象工厂”综合了“简单工厂”和“工厂方法”特点，支持相关联的一系列类型对象创建

- 不足

  - 简单工厂
    - 扩展性差，增加新“产品”时，需要修改工厂内部逻辑
    - 违背“开放—封闭”原则（OCP）
    - 采用静态工厂方法，无法被子类继承
    - 只能创建单一“产品”
  - 工厂方法
    - 只能创建单一“产品”
    - 一定程度增加开放工作量，每增加一个 产品，就需要增加一个子工厂
  - 抽象工厂
    - 适合生产已有种类“产品”集合，扩展新种类“产品”比较困难，因为会涉及抽象工厂类和子类的更改

- 用途

  - 解耦，把对象的创建和使用的过程分开
  - 减少代码重复量
  - 降低代码维护成本
  - 对象的实例化前期工作比较繁琐复杂，如需初始化参数、读取配置文件、查询数据库等
  - 类本身存在多个子类，这些类的创建过程在业务中容易发生改变，或者对类的调用容易发生改变

- 适用场景

  - 简单工厂适用于工厂类负责创建的对象比较少的场合
  - 工厂方法适用于类不知道它所必须创建对象的类，或一个类期望由子类来创建的对象的场合
  - 抽象工厂适用于需要创建的对象是一系列相互关联或相互依赖的产品族的场合
  - 如果存在着多个等级结构（多个抽象类），且各个等级结构中的实现类之间存在着一定的关联或者约束，则考虑使用抽象工厂模式
  - 各个等级结构中的实现类之间不存在关联或约束，则考虑使用多个独立的工厂（简单工厂/工厂方法）来对产品进行创建

##### 原型

- 原型模式（Prototype Pattern），是一种创建型设计模式，指的是以原型实例指定待创建对象的种类，并通过拷贝（克隆）原型对象来创建新的对象。原型模式的核心和关键字是“对象拷贝”。

- 原型模式和拷贝构造函数区别

  - 原型模式实现的是一个clone接口，注意是接口，也就是基于多态的clone虚函数。也就是说原型模式能够通过基类指针来复制派生类对象。拷贝构造函数完不成这样的任务。

  - 原型模式的核心是克隆，构造函数只是克隆的一个办法而已。

- 原型模式由抽象原型（Abstract Prototype ）、具体原型（Concrete Prototype ）、客户（Client）三个要素组成。

  - 抽象原型（Abstract Prototype ）, 声明一个抽象原型父类，定义自身实例拷贝接口
  - 具体原型（Concrete Prototype ）， 继承Abstract Prototype 类，实现抽象接口，返回拷贝对象
  - 客户（Client），客户调具体原型对象方法创建一个新的对象，严格来说客户不属于原型模式的一部分

- 原型模式作用

  - 原型模式的功能与拷贝构造函数一样，都是用于创建新对象。但原型模式可以动态获取当前对象运行时的状态。
  - 原型模式能够通过基类指针来复制派生类对象。

- 优点

  - 效率高、资源开销小，使用原型模式创建对象比直接new一个对象效率要高，而且资源开销小，因为原型模式拷贝对象是一个本地方法过程，直接操作内存中的二进制流 。
  - 使用便捷，简化对象创建过程，隐藏拷贝细节，用户无需知道创建细节。
  - 动态过程，可以动态创建程序运行过程属性发生变化的对象，且创建的对象与运行对象互不干扰。

- 不足

  - 违背开闭原则，原型模式需要为每一个类实现一个拷贝方法，由于拷贝方法在类内部实现，如需对类进行改造时，则需要修改原有代码（框架），违背了开闭原则。
  - 增加系统复杂度，在实现深拷贝时需要写较复杂的代码；如果对象之间存在多重嵌套引用，那么每一层对象对应的类必须支持深拷贝，才能实现深拷贝。
  - 避开了构造函数的约束

- 适用

  - 资源优化，待创建对象资源开销大（数据、内存资源），通过原型模式拷贝已有对象，降低资源开销，提高效率。
  - 待创建对象类型不确定，待创建对象类型没法静态确认，只能在执行期间确定。
  - 对象副本，程序运行过程，某个状态下需要一个对象副本；而对象属性有可能在运行过程改变，使用new来创建显然不适合。
  - 简单对象处理，处理一些比较简单的对象，对象直接区别小，只是某些属性不同；使用原型模式来获得对象省去重新new对象的资源开销，提高效率。
  - 简化复杂的对象创建过程，一个复杂的对象创建，构造函数需对各种参数初始化，用户需理解每一个参数的含义；使用原型模式直接拷贝一个对象，简化对象复杂的创建过程，减少开发者工作量。
  - 对象被多个对象访问修改，一个对象被其他多个对象访问，而且各个调用者可能都需要修改该对象，考虑使用原型模块拷贝出多个对象提供调用者访问。
  - 解耦，一个系统应该独立于它的产品创建、构成和表示时

- 大体步骤

  - 抽象原型父类`Prototye`声明对象拷贝（克隆）接口`Clone`，已经提供对象属性修改接口`SetAddr`和属性输出接口`ShowAttr`
  - 具体原型`ConcretePrototye`实现抽象原型拷贝接口`Clone`
  - 用户`client`调用具体原型对象拷贝接口`Clone`创建一个对象

- 过程

  - 第一步，声明抽象原型类`Prototye`

    ```c++
    /* prototye.h */
    #ifndef _PROTOTYE_H_
    #define _PROTOTYE_H_
    
    #include <stdbool.h>
    #include <string>
    
    using namespace std;
    
    class Prototye
    {
    public:
    	Prototye(string str);
    	void ShowAttr();
    	void SetAttr(string);
    	virtual Prototye *Clone()=0;
    private:
    	string m_attr;
    };
    #endif
    ```

  - 第二步，抽象原型类`Prototye`方法实现

    ```c++
    /* prototye.cpp */
    #include <iostream>
    #include "prototye.h"
    
    using namespace std;
    
    Prototye::Prototye(string str)
    {
    	m_attr = str;
    }
    
    void Prototye::ShowAttr()
    {
    	cout << m_attr << endl;
    }
    
    void Prototye::SetAttr(string str)
    {
    	m_attr = str;
    }
    
    ```

  - 第三步，声明具体原型类`ConcretePrototye.h`，继承抽象父类

    ```c++
    /* concrete_prototye.h */
    #ifndef _CONCRETE_PROTOTYE_H_
    #define _CONCRETE_PROTOTYE_H_
    
    #include <string>
    #include "prototye.h"
    
    class ConcretePrototye:public Prototye
    {
    public:
    	ConcretePrototye(string attr);
    	virtual Prototye *Clone();	
    };
    #endif
    ```
    
  - 第四步，具体原型类`ConcretePrototye`方法实现

    ```c++
    /* concrete_prototye.cpp */
    #include "concrete_prototye.h"
    
    ConcretePrototye::ConcretePrototye(string attr):Prototye(attr)
    {	
    }
    
    Prototye *ConcretePrototye::Clone()
    {
    	ConcretePrototye *p = new ConcretePrototye("");
    	*p = *this;
    	return p;
    }
    ```
    
  - 第五步，客户调用不同子类对象实现指定排序功能

    ```c++
    /* client.cpp */
    #include <iostream>
    #include "concrete_prototye.h"
    
    using namespace std;
    
    int main(int argc, char **arv)
    {
    	/* 创建一个原型对象0 */
    	ConcretePrototye *pConcretePrototye0 = new ConcretePrototye("Init");
    
    	cout << "pConcretePrototye0属性:";
    	pConcretePrototye0->ShowAttr();
    	
    	/* 修改原型属性 */
    	pConcretePrototye0->SetAttr("Second");	
    	cout << "pConcretePrototye0属性:";
    	pConcretePrototye0->ShowAttr();
    
    	/* 通过原型对象0拷贝(克隆)一个对象1 */
    	ConcretePrototye *pConcretePrototye1 = (ConcretePrototye*)pConcretePrototye0->Clone();
    	cout << "pConcretePrototye1属性:";
    	pConcretePrototye1->ShowAttr();	/* 对象1和对象0的属性是一样的 */
    
    	delete pConcretePrototye0;
    	delete pConcretePrototye1;
    }
    ```

- 上面的clone函数中使用了赋值构造函数，一般情况下拷贝构造函数除了上面new一个新的对象出来，然后在用赋值构造函数赋值，也可以用拷贝构造函数来拷贝这个对象的值

  ```c++
  #include <iostream>
  #include <string>
  
  class Prototype {
  public:
      virtual Prototype* clone() const = 0;
      virtual void printInfo() const = 0;
      virtual ~Prototype() = default;
  };
  
  class ConcretePrototype : public Prototype {
  private:
      std::string data;
  
  public:
      ConcretePrototype(const std::string& value) : data(value) {}
  
      // 使用拷贝构造函数实现克隆
      ConcretePrototype(const ConcretePrototype& other) : data(other.data) {}
  
      // 实现 clone 方法
      ConcretePrototype* clone() const override {
          return new ConcretePrototype(*this);  // 调用拷贝构造函数
      }
  
      // 实现 printInfo 方法
      void printInfo() const override {
          std::cout << "Data: " << data << std::endl;
      }
  };
  
  int main() {
      // 创建原型对象
      ConcretePrototype original("Hello, Prototype!");
  
      // 克隆原型对象
      Prototype* cloned = original.clone();
  
      // 打印信息
      std::cout << "Original object:" << std::endl;
      original.printInfo();
  
      std::cout << "\nCloned object:" << std::endl;
      cloned->printInfo();
  
      // 释放资源
      delete cloned;
  
      return 0;
  }
  ```

  - 上面中的clone中使用`*this`来调用拷贝构造函数，在类内调用拷贝构造函数时直接用类名就可以，和在外面new一样。

- 原型模式也绕不开拷贝构造和赋值构造，因为其要弄一个和当前对象一模一样的，要不就拷贝一个，要不就赋值一个

  - 如果没有自己写，就用系统默认的拷贝构造或者赋值构造，如果涉及到指针的话就得自己写一个了。

- 原型模式拷贝出来的对象都在堆上，因为在栈上这个拷贝出来的对象就丢了。

- 原型模式与构造函数

  - 相同点
    - 功能相同，都是用于对象拷贝，以创建一个对象
  - 不同点
    - 原理不同，原型模式通过虚函数多态原理，通过基类指针复制派生类对象。
    - 功能范围不同，原型模式可以动态获取对象属性；构造函数只能静态创建对象。

##### 单例

- 单例模式（Singleton）的目的是为了保证在一个进程中，某个类有且仅有一个实例。

- 优点

  - 单例模式会阻止其他对象实例化其单例对象的副本，确保唯一实例受控访问
  - 只有一个实例对象，节约系统内存资源
  - 单例模式具有一定的伸缩性，类可以灵活更改实例化过程
  - 允许可变数目的实例
  - 单一实例对象，无多个实例对象共享资源的占用问题

- 不足

  - 单例模式不存在抽象层，导致单列类不便于功能扩展
  - 单例类“职责”（功能）综合，一定程度上违背设计模式的“单一职责原则”
  - 单例模式导致模块之间耦合度提高
  - 滥用单例将带来一些负面问题，如为了节省资源将数据库连接池对象设计为的单例类，可能会导致共享连接池对象的程序过多而出现连接池溢出；如果实例化的对象长时间不被利用，系统会认为是垃圾而被回收，这将导致对象状态的丢失

- 单例模式一般用于对象实例被其他多个模块访问的公共场合>，典型的应用场合有：

  - 需要频繁实例化、销毁对象的场合
  - 创建对象时耗时或者消耗资源过多的对象
  - 存在状态的工具类对象
  - 频繁访问数据库、文件等耗时操作的对象
  - 日志模块输出
  - 应用配置
  - 线程池操作
  - 任务管理器
  - 资源回收器
  - 单例模式不适用于对象可变化的场景，因为对于随不同场景变化的对象，单例模式不能保存彼此对象间的状态信息，可能引起数据错误。

- 实现

  - 构造函数声明为private，禁止类外部通过new关键字实例化对象
  - 拷贝构造函数同样声明为private，禁止拷贝构造函数实例化对象
  - 赋值运算符函数声明成private，禁止通过赋值运算符函数实例化对象
  - 析构函数声明为private，禁止析构函数释放new关键字建立的堆上对象
  - 在类内部定义一个唯一实例对象，并声明为static
  - 定义一个全局访问节点，即定义一个static方法返回唯一的实例对象

- 单例模式实现

  ```c++
  class Singleton
  {
  public:
  	static Singleton& GetObject()
  	{
  		static Singleton Object;
  		return Object;
  	}
  	void printf()
  	{
  		cout<<"to do"<<endl;
  	}
  private:
  	Singleton(){}	/* 禁止构造函数实例化对象 */
  	Singleton(Singleton const &);/* 禁止拷贝构造函数实例化对象 */
  	Singleton& operator=(Singleton const &);/* 禁止赋值实例化对象 */
  };
  
  int main(int argc, char **argv)
  {
  	Singleton &a = Singleton::GetObject();
  	a.printf();
  	return 0;
  }
  
  上面static对象用的是对象的形式，也可以用指针的形式，因为static对象是在全局区，数据也不会丢失
  #include <iostream>
  
  class Singleton {
  private:
      // 私有的构造函数，防止外部实例化
      Singleton() {}
  
      // 静态私有的指针，指向唯一的实例
      static Singleton* instance;
  
  public:
      // 公有的方法，提供全局访问点
      static Singleton* getInstance() {
          // 如果实例不存在，创建一个新实例
          if (!instance) {
              instance = new Singleton();
          }
          return instance;
      }
  
      // 业务方法
      void doSomething() {
          std::cout << "Singleton is doing something." << std::endl;
      }
  };
  
  // 静态成员变量需要在类外初始化
  Singleton* Singleton::instance = nullptr;
  
  int main() {
      // 获取单例实例
      Singleton* singletonInstance = Singleton::getInstance();
  
      // 调用单例的业务方法
      singletonInstance->doSomething();
  
      return 0;
  }
  ```

- 根据类的对象实例化过程的不同，单例模式又分为“懒汉式单例”和”饿汉式单例“。

- 饿汉式单例指的是定义类的时候或者程序初始时执行实例化对象，使用的时候可以直接使用，无需创建。饿汉式单例，需要注意的是，采用new关键字生成的堆上对象，必须声明一个public类型的方法来主动释放对象，因为析构函数声明为private，不会在类外被调用。

  ```c++
  #include <iostream> 
  #include <stdlib.h> 
  
  using namespace std;
  
  class Singleton
  {
  public:
  	static Singleton* GetObject();
  	void printf()
  	{
  		cout<<"to do"<<endl;
  	}
  	void DestoryObject()
  	{
  		delete m_Object;
  		cout<<"exe destory fun"<<endl;
  	}
  private:
  	static Singleton *m_Object;
  	Singleton()/* 禁止构造函数实例化对象 */
  	{
  		cout<<"exe constructor fun"<<endl;
  	}	
  	~Singleton()/* 禁止析构函数释放对象 */
  	{
  		cout<<"exe destructor fun"<<endl;
  	}
  	Singleton(Singleton const &);/* 禁止拷贝构造函数实例化对象 */
  	Singleton& operator=(Singleton const &);/* 禁止赋值实例化对象 */
  };
  
  Singleton* Singleton::m_Object = new Singleton();
  Singleton* Singleton::GetObject()
  {
  	return m_Object;
  }
  
  不主动调销毁函数：
  int main(int argc, char **argv)
  {
  	Singleton *a = Singleton::GetObject();
  	a->printf();
  	return 0;
  }
  
  exe constructor fun
  to do
  
  很明显，程序退出后并未执行析构函数，这就造成内存泄漏。
  
  主动调销毁函数：
  int main(int argc, char **argv)
  {
  	Singleton *a = Singleton::GetObject();
  	a->printf();
  	a->DestoryObject();
  	return 0;
  }
  
  exe constructor fun
  to do
  exe destructor fun
  exe destory fun
  ```

- 懒汉式单例指的是首次需使用类对象时才实例化对象。懒汉式单例是线程不安全的，因此在实例化时应该加锁处理。

- 与饿汉式单例一样，采用new关键字生成的堆上对象，必须声明一个public类型的方法来主动释放对象，因为析构函数声明为private，不会在类外被调用。

  ```c++
  class Singleton
  {
  public:
  	static Singleton& GetObject();
  	void printf()
  	{
  		cout<<"to do"<<endl;
  	}
  	void DestoryObject()
  	{
  		delete m_Object;
  		cout<<"exe destory fun"<<endl;
  	}
  private:
  	static Singleton *m_Object;
  	Singleton(){}	/* 禁止构造函数实例化对象 */
  	~Singleton(){}  /* 禁止析构函数释放对象 */
  	Singleton(Singleton const &);/* 禁止拷贝构造函数实例化对象 */
  	Singleton& operator=(Singleton const &);/* 禁止赋值实例化对象 */
  };
  
  Singleton& Singleton::GetObject()
  {
  	if (m_Object == NULL)
  	{
  		m_Object = new Singleton();
  	}
  	return m_Object;
  }
  
  
  
  线程安全的懒汉式单例实现：
  
  class Singleton
  {
  public:
  	static Singleton& GetObject();
  	void printf()
  	{
  		cout<<"to do"<<endl;
  	}
  	void DestoryObject()
  	{
  		delete m_Object;
  		cout<<"exe destory fun"<<endl;
  	}
  private:
  	static Singleton *m_Object;
  	static pthread_mutex_t m_mutex;
  	Singleton()/* 禁止构造函数实例化对象 */
  	{
  		pthread_mutex_init(&m_mutex);
  	}	
  	Singleton(Singleton const &);/* 禁止拷贝构造函数实例化对象 */
  	~Singleton(){}  /* 禁止析构函数释放对象 */
  	Singleton& operator=(Singleton const &);/* 禁止赋值实例化对象 */
  };
  
  Singleton& Singleton::GetObject()
  {
  	if (m_Object == NULL)
  	{
  		pthread_mutex_lock(&m_mutex);
  		m_Object = new Singleton();
  		pthread_mutex_lock(&m_mutex);
  	}
  	return m_Object;
  }
  
  ```

- 饿汉式单例，适用于访问量大的场景，或者多个线程需要访问实例对象的场景；是一种“空间换时间”的方法

- 懒汉式单例，适用于访问量少的场景；是一种以“时间换空间”的方法

- 饿汉式单例是在定义类的时候直接在源文件中实例化一个类对象，这样程序一开始就会有这个对象，而懒汉式单例则是在调用GetObject的时候才会实例化一个对象。

#### 行为型模式

##### 策略

- 定义一系列的算法，把它们一个个封装起来，并且使它们可相互替换。本模式使得算法可独立于使用它的客户而变化。

- 策略模式：Strategy，是指，定义一组算法，并把其封装到一个对象中。然后在运行时，可以灵活的使用其中的一个算法。策略模式的本质是:分离算法，选择实现。

- 策略模式仅仅封装算法并提供接口，并不决定在何时、何地、使用何种算法；客户通过抽象接口访问具体算法

- 策略模式将算法的责任和算法本身进行解耦，将算法的使用权由不同的对象管理，客户不关心算法的具体实现

- 策略模式由环境角色（Context）、抽象策略（Abstract Strategy）、具体策略（Concrete Strategy）、客户（Client）四个要素组成。

  - 环境角色（Context）， 持有一个对Abstract Strategy的引用，最终由客户端调用
  - 抽象策略（Abstract Strategy）, 声明一个公共抽象接口，由不同算法类实现该接口；通过该接口，Context可以调用不同的算法
  - 具体策略（Concrete Strategy）， 继承Abstract Strategy类，并实现抽象接口，提供具体算法
  - 客户（Client），客户通过调用Context调用策略算法，严格来说客户不属于策略模式的一部分

- 策略模式作用

  - 让算法和对象分离，使得算法可以独立于使用它的客户而变化
  - 客户端可以根据外部条件来选择不同策略来解决不同问题
  - 替换`“if-else”`或者`“switch-case”`臃肿逻辑代码

- 策略模式优点

  - 灵活性好，提供管理相关算法族的方法，策略类（算法）可自由切换，而不影响客户使用。
  - 易扩展，新增策略（算法）时，只需要添加一个具体的策略类即可，不需改动原有代码和代码框架，符合“开闭原则“。
  - 代码结构清晰，可以避免使用多重条件转移语句（`“if-else”`、`“switch-case”`），逻辑性强，可读性和可维护性好。

- 策略模式不足

  - 暴露所有策略类，客户端必须知道所有的策略类，才能根据具体场景选择使用一个策略类。
  - 导致产生众多策略类和对象，策略模式导致成产生众多策略类和对象，可通过亨元模式弥补该不足。

- 使用场景

  - 一个需要多种算法处理的场景，并需要动态选择其中一个算法
  - 一个有多种相似类的场景，类之间的区别仅仅是行为不同，可考虑使用策略模式使得对象动态选择一个行为
  - 需要屏蔽算法规则的场景，不希望将算法相关数据结构、算法实现过程、算法原理等暴露给用户
  - 重构历史遗留代码，以if-else、switch-case语句实现的，将算法行为和算法实现混合在一起的，或者多种行为混合一起的等维护性差的遗留代码，考虑使用策略模式重构

- 实例情况

  - 抽象策略类Strategy声明具体策略类访问接口AlgorithmInterface
  - 环境角色Context提供算法访问方法ContextInterface
  - 具体策略类ConcreteStrategyA、ConcreteStrategyB、ConcreteStrategyB分别实现三个不同行为（算法）具体方法AlgorithmInterface
  - 用户client调用Context方法选择三个策略类行为（算法）

- 实现过程

  - 第一步，声明抽象策略类`Strategy`

    ```c++
    /* strategy.h */
    #ifndef _STRATEGY_H_
    #define _STRATEGY_H_
    
    class Strategy
    {
    public:
         virtual void AlgorithmInterface() = 0;	/* 抽象接口 */
    };
    #endif
    ```

  - 第二步，声明环境角色类

    ```c++
    /* context.h */
    #ifndef _CONTEXT_H_
    #define _CONTEXT_H_
    
    #include "strategy.h"
    
    class Context
    {
    public:
         Context(Strategy *strategy);
         void ContextInterface();
    private:
         Strategy *m_strategy;
    };
    #endif
    ```

  - 第三步，环境角色方法实现

    ```c++
    /* context.cpp */
    #include "context.h"
    #include <iostream>
    
    using namespace std;
    
    Context::Context(Strategy *strategy)
    {
    	m_strategy = strategy;
    }
    
    void Context::ContextInterface()
    {
    	cout << "Call Context::ContextInterface()" << endl;	
    	m_strategy->AlgorithmInterface();
    }
    ```

  - 第四步，声明具体策略类

    ```c++
    /* concrete_strategy.h */
    #ifndef _CONCRETE_STRATEGY_H_
    #define _CONCRETE_STRATEGY_H_
    
    #include "strategy.h"
    
    class ConcreteStrategyA : public Strategy
    {
    public:
         void AlgorithmInterface();
    };
    
    class ConcreteStrategyB : public Strategy
    {
    public:
         void AlgorithmInterface();
    };
    
    class ConcreteStrategyC : public Strategy
    {
    public:
         void AlgorithmInterface();
    };
    #endif
    ```

  - 第五步，具体策略类方法实现

    ```c++
    /* concrete_strategy.cpp */
    #include "concrete_strategy.h"
    #include <iostream>
    
    using namespace std;
    
    void ConcreteStrategyA::AlgorithmInterface()
    {
    	/* todo */
        cout<<"Call ConcreteStrategyA::AlgorithmInterface()"<<endl;
    }
    
    void ConcreteStrategyB::AlgorithmInterface()
    {
    	/* todo */
        cout<<"Call ConcreteStrategyB::AlgorithmInterface()"<<endl;
    }
    
    void ConcreteStrategyC::AlgorithmInterface()
    {
    	/* todo */
        cout<<"Call ConcreteStrategyC::AlgorithmInterface()"<<endl;
    }
    ```

  - 第六步，客户调用具体策略算法

    ```c++
    /* client.cpp */
    #include "strategy.h"
    #include "context.h"
    #include "concrete_strategy.h"
    
    int main(int argc, char **arv)
    {
    	Strategy *strategyA = new ConcreteStrategyA;
    	Context *contextA = new Context(strategyA);
    	contextA->ContextInterface();
    	delete strategyA;
    	delete contextA;
    	
    	Strategy *strategyB = new ConcreteStrategyB;
    	Context *contextB = new Context(strategyB);
    	contextB->ContextInterface();
    	delete strategyB;
    	delete contextB;
    	
    	Strategy *strategyC = new ConcreteStrategyC;
    	Context *contextC = new Context(strategyC);
    	contextC->ContextInterface();
    	delete strategyC;
    	delete contextC;
    	return 0;
    }
    ```

  - 执行结果

    ```c++
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/strategy$ g++ -o client client.cpp concrete_strategy.cpp context.cpp 
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/strategy$ ./client
    Call Context::ContextInterface()
    Call ConcreteStrategyA::AlgorithmInterface()
    Call Context::ContextInterface()
    Call ConcreteStrategyB::AlgorithmInterface()
    Call Context::ContextInterface()
    Call ConcreteStrategyC::AlgorithmInterface()
    ```

##### 模板

- 定义一个操作中的算法的骨架，而将一些步骤延迟到子类中，使得子类可以不改变一个算法的结构即可重定义该算法的某些特定步骤。

- 模板方法（Template Method）是一个比较简单的模式。它的主要思想是，定义一个操作的一系列步骤，对于某些暂时确定不下来的步骤，就留给子类去实现好了，这样不同的子类就可以定义出不同的步骤。

- 模板模式由抽象类（Abstract Class）、具体子类（Concrete Class）、客户（Client）三个要素组成。

  - 抽象类（Abstract Class）, 声明一个公共抽象模板父类，不变的算法由父类实现，差异部分由子类实现
  - 具体子类（Concrete Class）， 继承Abstract Class类，并实现抽象接口和差异部分
  - 客户（Client），客户通过切换不同的子类实现不同的功能，严格来说客户不属于模板模式的一部分

- 模板模式作用

  - 子类可以不改变一个模板的结构的情况下，可重新定义模板中的内容或者某些特定步骤。

- 模板模式优点

  - 提高代码复用性，模板模式将类共同部分代码抽象出来放在的父类中，由子类只需实现差异部分，减少子类重复代码。
  - 易扩展，新增功能时，通过子类实现来拓展，不需改动原有代码和代码框架，符合“开闭原则“。
  - 灵活性好，所有子类实现的是同一套算法模型，在使用模板的地方，通过切换不同的子类实现不同的功能，符合“里氏替换原则”。
  - 维护性好，模板模式行为由父类控制，子类实现。

- 模板模式不足

  - 降低代码可读性，模板方式与常规程序设计习惯不同，子类执行的结果影响了父类的结果，会增加代码阅读的难度， 不易理解代码逻辑。
  - 耦合性高，子类无法影响父类公用模块代码。
  - 增加系统复杂度，新增不同的功能都需要一个新的子类来实现，导致子类的数目增加，增加了系统实现的复杂度。

- 使用场景

  - 多个子类具有共同的方法，逻辑、算法等基本相同的场景，可以把共同部分抽象出来
  - 复杂算法分解；不变部分或者核心算法由设计为模板方法，相关细节功能、可变行为由子类实现
  - 需要控制子类扩展场景；模板模式在特定的点调用子类的方法，使得只允许在这些子类上进行扩展。
  - 重构历史遗留代码；利用模板方法重构代码，把共同的代码抽象出来放在父类中，然后通过构造函数约束其行为。

- 实例

  - 实现一个排序算法，可以对整型、浮点型、字符等各种类型数据进行排序，还可以选择排序类型。
  - 步骤
    - 抽象父类`Sort`声明和实现排序算法，这一部分是共同的、不会改变的
    - 子类`IntSort`、`FlotaSort`分别实现整型数据和单精度浮点型数据排序
    - 子类还可以决定排序方式（升序排序/降序排序），而不影响父类
    - 用户`client`调用子类实例选择一种排序算法

- 实现过程

  - 第一步，声明抽象模板类`Sort`

    ```c++
    /* sort.h */
    #ifndef _SORT_H_
    #define _SORT_H_
    
    #include <stdbool.h>
    
    class Sort
    {
    public:
    	virtual ~Sort();
    	virtual void Swap(int)=0;	/* 交互数据 */
    	virtual bool Judge(int)=0;  /* 数据判断方式（排序方式）*/
    	void SortRun();				/* 排序算法框架 */
    protected:
    	Sort();
        int m_Size;
    };
    #endif
    ```

  - 第二步，抽象类`Sort`方法实现

    ```c++
    /* sort.cpp */
    #include "sort.h"
    
    Sort::Sort()
    {
    	m_Size = 0;
    }
    
    Sort::~Sort()
    {
    }
    
    void Sort::SortRun()
    {
    	int i = 0,j = 0;
    	for (j=0; j<m_Size-1; j++)
    	{
    		for (i=0; i<m_Size-1-j; i++)
    		{
    			if (Judge(i))
    			{
    				Swap(i);
    			}
    		}
    	}
    }
    
    ```

  - 第三步，声明整型数据排序子类`InstSort`，继承抽象父类

    ```c++
    /* int_sort.h */
    #ifndef _INT_SORT_H_
    #define _INT_SORT_H_
    
    #include <stdbool.h>
    #include "sort.h"
    
    class IntSort:public Sort
    {
    public:
    	IntSort();
    	virtual ~IntSort();
    
    	void Swap(int);		/* 重写int型数据交互方法 */
    	bool Judge(int);	/* 重写int型数据判断方法 */
    	void SortData(int*, int);
    private:
    	int *m_pArray;
    };
    #endif
    
    ```

  - 第四步，整型数据排序子类`InstSort`方法实现，实现排序数据类型和排序方式

    ```c++
    /* int_sort.cpp */
    
    #include <iostream>
    #include "int_sort.h"
    
    using namespace std;
    
    IntSort::IntSort()
    {
    }
    
    IntSort::~IntSort()
    {
    }
    
    void IntSort::Swap(int index)
    {
    	int temp;
    	
    	temp = m_pArray[index];
        m_pArray[index] = m_pArray[index+1];
        m_pArray[index+1] = temp;
    }
    
    bool IntSort::Judge(int index)
    {
    	return m_pArray[index] > m_pArray[index+1];	/* 从小到大排序 */
    }
    
    void IntSort::SortData(int *array, int size)
    {
    	this->m_pArray = array;
    	this->m_Size = size;
    	this->SortRun();
    
    	cout<<"int型数据从小到大排序: ";
    	for(int i = 0; i < m_Size; i++)
    	{
    		cout << m_pArray[i] << " ";	
    	}
    	cout<<endl;
    }
    
    ```

  - 第五步，声明单精度浮点型数据排序子类`FloatSort`，继承抽象父类

    ```c++
    /* float_insort.h */
    
    #ifndef _FLOAT_SORT_H_
    #define _FLOAT_SORT_H_
    
    #include <stdbool.h>
    #include "sort.h"
    
    class FloatSort:public Sort
    {
    public:
    	FloatSort();
    	virtual ~FloatSort();
    
    	void Swap(int);		/* 重写float型数据交互方法 */
    	bool Judge(int);	/* 重写float型数据判断方法 */
    	void SortData(float*, int);
    private:
    	float *m_pArray;
    };
    #endif
    
    ```

  - 第六步，单精度浮点型数据排序子类`FloatSort`方法实现，实现排序数据类型和排序方式

    ```c++
    /* float_sort.cpp */
    
    #include <iostream>
    #include "float_sort.h"
    
    using namespace std;
    
    FloatSort::FloatSort()
    {
    }
    
    FloatSort::~FloatSort()
    {
    }
    
    void FloatSort::Swap(int index)
    {
    	float temp;
    	
    	temp = m_pArray[index];
        m_pArray[index] = m_pArray[index+1];
        m_pArray[index+1] = temp;
    }
    
    bool FloatSort::Judge(int index)
    {
    	return m_pArray[index] < m_pArray[index+1];	/* 从大到小排序 */
    }
    
    void FloatSort::SortData(float *array, int size)
    {
    	this->m_pArray = array;
    	this->m_Size = size;
    	this->SortRun();
    
    	cout<<"float型数据从大到小排序: ";
    	for(int i = 0; i < m_Size; i++)
    	{
    		cout << m_pArray[i] << " ";	
    	}
    	cout<<endl;
    }
    
    ```

  - 第七步，客户调用不同子类对象实现指定排序功能

    ```c++
    /* client.cpp */
    #include "sort.h"
    #include "int_sort.h"
    #include "float_sort.h"
    
    int main(int argc, char **arv)
    {
    	int intArray[] = {1, 0, 3, 2, 5, 4, 7};
        int size = sizeof intArray / sizeof intArray[0];
        IntSort *intSort = new IntSort;
        intSort->SortData(intArray, size);
    	delete intSort;
    
    	float flaotArray[] = {1.0, 0.3, 1.2, 1.1, 5.4, 2.5, 3.3};
        size = sizeof flaotArray / sizeof flaotArray[0];
        FloatSort *floatSort = new FloatSort;
        floatSort->SortData(flaotArray, size);
    	delete floatSort;
    }
    
    ```

  - 执行结果

    ```
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/template$ make
    g++    -c -o float_sort.o float_sort.cpp
    g++    -c -o int_sort.o int_sort.cpp
    g++    -c -o client.o client.cpp
    g++    -c -o sort.o sort.cpp
    g++  float_sort.o  int_sort.o  client.o  sort.o   -o output/client1.00
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/template$ ls
    client.cpp  float_sort.cpp  float_sort.h  int_sort.cpp  int_sort.h  Makefile  Makefile.bak  output  sort.cpp  sort.h
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/template$ ./output/client1.00 
    int型数据从小到大排序: 0 1 2 3 4 5 7 
    float型数据从大到小排序: 5.4 3.3 2.5 1.2 1.1 1 0.3 
    ```

    

##### 观察者模式

- 定义对象间的一种一对多的依赖关系，当一个对象的状态发生改变时，所有依赖于它的对象都得到通知并被自动更新。

- 观察者模式（Observer）又称发布-订阅模式（Publish-Subscribe：Pub/Sub）。它是一种通知机制，让发送通知的一方（被观察方）和接收通知的一方（观察者）能彼此分离，互不影响。

- 观察者模式由抽象观察者（Abstract Observer）、具体观察者（Concrete Observer）、抽象主题（Abstract Subject）、具体主题（Concrete Subject） 四个要素组成。

  - **抽象观察者（Abstract Observer）**，声明一个具体观察者需获取主题发生改变时通知信号的统一更新方法接口
  - **具体观察者（Concrete Observer）**，维护一个指向`Concrete Subject`对象的引用；存储与主题相关的状态，实现抽象观察者中的方法
  - **抽象主题（Abstract Subject）**, 提供维护观察者对象集合的操作方法接口，如增加、删除观察者操作
  - **具体主题（Concrete Subject）**， 将有关状态存入具体的观察者对象；具体主题状态改变时，通知所有已注册的观察者；实现抽象主题中的方法
  
- 优点

  - 解耦，被观察者和观察者之间建立一个抽象的耦合，被观察者无需知道具体观察者，所有观察者遵循一个共同抽象接口即可；符合“依赖倒转原则”原则。
  - 消息同步，观察者模式实现了“消息广播”功能。

- 不足

  - 通知消息延迟，被观察者对象如果存在较多的直接或者间接观察者，观察者收到的通知消息将会花费一定的时间。
  - 不支持循环依赖，如果观察者与被观察者之间存在循环依赖关系，被观察者会触发它们之间进行循环调用，导致系统崩溃。
  - 多线程调用隐患，如果被观察者的通知消息是通过另一线程异步发送的话，系统必须保证该发送过程是以“自恰”的方式进行。
    - 自洽，某个理论体系或者数学模型的内在逻辑一致，不含悖论。对于计算机软件，自恰定义为：一个计算机软件，在各个模块，各个函数，各个功能之间对相同问题，没有不同的看法。
  - 只知道结果不知道过程，观察者只能知道被观察者发生了变化，但观察者模式未提供相应的机制使得观察者知道被观察者的目标对象是怎么发生变化的。

- 适用场景

  - 对象关联场景，一个或者多个对象依赖一个对象，一个对象状态的更新，需要其他对象同步更新，而且其他对象的数量动态可变的
  - 事件触发场景，一个对象触发其他对象发送变化
  - 一个对象变化必须通知其它对象，但该对象又不知道这些具体对象，即这些对象是紧密耦合的
  - 跨系统消息传输
  - 重构历史遗留代码，将符合上述场景的代码以观察者模式重构
  - 数据传输，同时支持本地UI显示、网页显示、数据库更新、Debug日志输出等

- 注意

  - 避免观察者与被观察者存在循环依赖关系
  - 多线程异步通知

- 实例

  - 实现一个“数据传输模型”，数据被分别被GUI对象、数据库存储对象、Debug日志输出对象使用。
  - 整体步骤
    - 抽象观察者Observer声明数据更新接口Update
    - 抽象主题Subject声明观察者操作方法Attach、Detach，及通知接口Notify
    - 具体主题（被观察者）实现抽象主题方法，并增加一个数据改变方法Change
    - 分别实现ConcreteObserverGui、ConcreteObserverDb、ConcreteObserverDebug三个观察者及其方法
    - 用户client调用被观察者对象修改数据，并通知观察者更新数据

- 过程

  - 第一步，声明抽象观察者类`Observe`

    ```c++
    /* observe.h */
    #ifndef _OBSERVER_H_
    #define _OBSERVER_H_
    
    #include <stdbool.h>
    #include <string>
    
    class Observer
    {
    public:
    	virtual void Update(std::string &)= 0;
    };
    #endif
    ```

  - 第二步，声明抽象主题类`Subject`

    ```c++
    /* Subject.h */
    #ifndef _SUBJECT_H_
    #define _SUBJECT_H_
    
    #include <stdbool.h>
    
    class Subject
    {
    public:
    	virtual void Attach(Observer *) = 0;
    	virtual void Detach(Observer *) = 0;
    	virtual void Notify() = 0;
    };
    #endif
    ```

  - 第三步，声明具体主题类`ConcreteSubject`，继承抽象主题类

    ```c++
    /* concrete_subject.h */
    #ifndef _CONCRETE_SUBJECT_H_
    #define _CONCRETE_SUBJECT_H_
    
    #include <stdbool.h>
    #include <list>
    #include "observer.h"
    #include "subject.h"
    
    class ConcreteSubject : public Subject
    {
    public:
         void Attach(Observer *pObserver);
         void Detach(Observer *pObserver);
         void Notify();
     	 void ChangeData(std::string);
    private:
         std::list<Observer *> m_ObserverList;
         std::string m_Data;
    };
    #endif
    
    ```

  - 第四步，具体主题类`ConcreteSubject`方法实现

    ```c++
    /* concrete_subject.cpp */
    #include "concrete_subject.h"
    #include "concrete_observer.h"
    
    void ConcreteSubject::Attach(Observer *pObserver)
    {
    	m_ObserverList.push_back(pObserver);
    }
    
    void ConcreteSubject::Detach(Observer *pObserver)
    {
    	m_ObserverList.remove(pObserver);
    }
    
    void ConcreteSubject::Notify()
    {
    	std::list<Observer *>::iterator it = m_ObserverList.begin();
    	
    	for(; it != m_ObserverList.end(); it++)
    	{
    		(*it)->Update(m_Data);	/* 更新所有观察者 */
    	}
    }
    
    void ConcreteSubject::ChangeData(std :: string str)
    {
    	m_Data = str;
    }
    ```

  - 第五步，声明具体观察者类`ConcreteObserverGui`、`ConcreteObserverDb`、`ConcreteObserverDebug`，继承抽象观察者类

    ```c++
    /* concrete_observer.h */
    #ifndef _CONCRETE_OBSERVER_H_
    #define _CONCRETE_OBSERVER_H_
    
    #include <stdbool.h>
    #include "observer.h"
    #include "subject.h"
    
    class ConcreteObserverGui:public Observer
    {
    public:
    	ConcreteObserverGui(Subject *pSubject);
    	void Update(std::string &);
    private:
    	Subject *m_pSubjectGui;
    };
    
    class ConcreteObserverDb:public Observer
    {
    public:
    	ConcreteObserverDb(Subject *pSubject);
    	void Update(std::string &);
    private:
    	Subject *m_pSubjectDb;
    };
    
    class ConcreteObserverDebug:public Observer
    {
    public:
    	ConcreteObserverDebug(Subject *pSubject);
    	void Update(std::string &);
    private:
    	Subject *m_pSubjectDebug;
    };
    #endif
    
    ```

  - 第六步，具体观察者类方法实现

    ```c++
    /* concrete_observer.cpp */
    
    #include <iostream>
    #include "concrete_observer.h"
    
    using namespace std;
    
    ConcreteObserverGui::ConcreteObserverGui(Subject *pSubject)
    {
    	m_pSubjectGui = pSubject;
    }
    
    void ConcreteObserverGui::Update(string &data)
    {
    	cout << "GUI更新数据:"<<data<<endl;
    }
    
    ConcreteObserverDb::ConcreteObserverDb(Subject *pSubject)
    {
    	m_pSubjectDb = pSubject;
    }
    
    void ConcreteObserverDb::Update(string &data)
    {
    	cout << "数据库更新数据:"<<data<<endl;
    }
    
    ConcreteObserverDebug::ConcreteObserverDebug(Subject *pSubject)
    {
    	m_pSubjectDebug = pSubject;
    }
    
    void ConcreteObserverDebug::Update(string &data)
    {
    	cout << "Debug日志输出数据:"<<data<<endl;
    }
    
    ```

  - 第七步，客户调用被观察者对象更新数据，并通知观察者

    ```c++
    /* client.cpp */
    #include <iostream>
    #include "concrete_subject.h"
    #include "concrete_observer.h"
    
    int main(int argc, char **arv)
    {
    	/* 创建被观察者 */
    	ConcreteSubject *pSubject = new ConcreteSubject();
    	/* 创建观察者 */
    	Observer *pObserverGui = new ConcreteObserverGui(pSubject);
    	Observer *pObserverDb = new ConcreteObserverDb(pSubject);
    	Observer *pObserverDebug = new ConcreteObserverDebug(pSubject);
    
    	/* 添加观察者 */
    	pSubject->Attach(pObserverGui);
    	pSubject->Attach(pObserverDb);
    	pSubject->Attach(pObserverDebug);
    	pSubject->ChangeData("Hello Word");
    	pSubject->Notify();
    
    	std::cout << "删除Debug观察者"<<std::endl;
     	pSubject->Detach(pObserverDebug);
    	std::cout << "再次更新数据"<<std::endl;
    	pSubject->ChangeData("Hello Acuity");
     	pSubject->Notify();
    	delete pObserverGui;
    	delete pObserverDb;
    	delete pObserverDebug;
    	delete pSubject;
    }
    
    ```

  - 执行结果

    ```c
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/observer$ make
    g++    -c -o concrtee_observer.o concrtee_observer.cpp
    g++    -c -o client.o client.cpp
    g++    -c -o concrete_subject.o concrete_subject.cpp
    g++  concrtee_observer.o  client.o  concrete_subject.o   -o output/client1.00
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/observer$ ./output/client1.00 
    GUI更新数据:Hello Word
    数据库更新数据:Hello Word
    Debug日志输出数据:Hello Word
    删除Debug观察者
    再次更新数据
    GUI更新数据:Hello Acuity
    数据库更新数据:Hello Acuity
    
    ```

    

  ```c++
  /**
   * Observer Design Pattern
   *
   * Intent: Lets you define a subscription mechanism to notify multiple objects
   * about any events that happen to the object they're observing.
   *
   * Note that there's a lot of different terms with similar meaning associated
   * with this pattern. Just remember that the Subject is also called the
   * Publisher and the Observer is often called the Subscriber and vice versa.
   * Also the verbs "observe", "listen" or "track" usually mean the same thing.
   */
  
  #include <iostream>
  #include <list>
  #include <string>
  
  class IObserver {
   public:
    virtual ~IObserver(){};
    virtual void Update(const std::string &message_from_subject) = 0;
  };
  
  class ISubject {
   public:
    virtual ~ISubject(){};
    virtual void Attach(IObserver *observer) = 0;
    virtual void Detach(IObserver *observer) = 0;
    virtual void Notify() = 0;
  };
  
  /**
   * The Subject owns some important state and notifies observers when the state
   * changes.
   */
  
  class Subject : public ISubject {
   public:
    virtual ~Subject() {
      std::cout << "Goodbye, I was the Subject.\n";
    }
  
    /**
     * The subscription management methods.
     */
    void Attach(IObserver *observer) override {
      list_observer_.push_back(observer);
    }
    void Detach(IObserver *observer) override {
      list_observer_.remove(observer);
    }
    void Notify() override {
      std::list<IObserver *>::iterator iterator = list_observer_.begin();
      HowManyObserver();
      while (iterator != list_observer_.end()) {
        (*iterator)->Update(message_);
        ++iterator;
      }
    }
  
    void CreateMessage(std::string message = "Empty") {
      this->message_ = message;
      Notify();
    }
    void HowManyObserver() {
      std::cout << "There are " << list_observer_.size() << " observers in the list.\n";
    }
  
    /**
     * Usually, the subscription logic is only a fraction of what a Subject can
     * really do. Subjects commonly hold some important business logic, that
     * triggers a notification method whenever something important is about to
     * happen (or after it).
     */
    void SomeBusinessLogic() {
      this->message_ = "change message message";
      Notify();
      std::cout << "I'm about to do some thing important\n";
    }
  
   private:
    std::list<IObserver *> list_observer_;
    std::string message_;
  };
  
  class Observer : public IObserver {
   public:
    Observer(Subject &subject) : subject_(subject) {
      this->subject_.Attach(this);
      std::cout << "Hi, I'm the Observer \"" << ++Observer::static_number_ << "\".\n";
      this->number_ = Observer::static_number_;
    }
    virtual ~Observer() {
      std::cout << "Goodbye, I was the Observer \"" << this->number_ << "\".\n";
    }
  
    void Update(const std::string &message_from_subject) override {
      message_from_subject_ = message_from_subject;
      PrintInfo();
    }
    void RemoveMeFromTheList() {
      subject_.Detach(this);
      std::cout << "Observer \"" << number_ << "\" removed from the list.\n";
    }
    void PrintInfo() {
      std::cout << "Observer \"" << this->number_ << "\": a new message is available --> " << this->message_from_subject_ << "\n";
    }
  
   private:
    std::string message_from_subject_;
    Subject &subject_;
    static int static_number_;
    int number_;
  };
  
  int Observer::static_number_ = 0;
  
  void ClientCode() {
    Subject *subject = new Subject;
    Observer *observer1 = new Observer(*subject);
    Observer *observer2 = new Observer(*subject);
    Observer *observer3 = new Observer(*subject);
    Observer *observer4;
    Observer *observer5;
  
    subject->CreateMessage("Hello World! :D");
    observer3->RemoveMeFromTheList();
  
    subject->CreateMessage("The weather is hot today! :p");
    observer4 = new Observer(*subject);
  
    observer2->RemoveMeFromTheList();
    observer5 = new Observer(*subject);
  
    subject->CreateMessage("My new car is great! ;)");
    observer5->RemoveMeFromTheList();
  
    observer4->RemoveMeFromTheList();
    observer1->RemoveMeFromTheList();
  
    delete observer5;
    delete observer4;
    delete observer3;
    delete observer2;
    delete observer1;
    delete subject;
  }
  
  int main() {
    ClientCode();
    return 0;
  }
  
  Hi, I'm the Observer "1".
  Hi, I'm the Observer "2".
  Hi, I'm the Observer "3".
  There are 3 observers in the list.
  Observer "1": a new message is available --> Hello World! :D
  Observer "2": a new message is available --> Hello World! :D
  Observer "3": a new message is available --> Hello World! :D
  Observer "3" removed from the list.
  There are 2 observers in the list.
  Observer "1": a new message is available --> The weather is hot today! :p
  Observer "2": a new message is available --> The weather is hot today! :p
  Hi, I'm the Observer "4".
  Observer "2" removed from the list.
  Hi, I'm the Observer "5".
  There are 3 observers in the list.
  Observer "1": a new message is available --> My new car is great! ;)
  Observer "4": a new message is available --> My new car is great! ;)
  Observer "5": a new message is available --> My new car is great! ;)
  Observer "5" removed from the list.
  Observer "4" removed from the list.
  Observer "1" removed from the list.
  Goodbye, I was the Observer "5".
  Goodbye, I was the Observer "4".
  Goodbye, I was the Observer "3".
  Goodbye, I was the Observer "2".
  Goodbye, I was the Observer "1".
  Goodbye, I was the Subject.
  ```

  
