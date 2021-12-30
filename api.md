### c

##### umask

- 在linux)系统中，我们创建一个新的文件或者目录的时候，这些新的文件或目录都会有默认的访问权限，umask命令与文件和目录的默认访问权限有关。若用户创建一个文件，则文件的默认访问权限为 -rw-rw-rw- ，创建目录的默认权限 drwxrwxrwx ，而umask值则表明了需要从默认权限中去掉哪些权限来成为最终的默认权限值。

- umask值得含义和使用，在shell中可以查看umask值

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

  ```
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

    ```
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

    ```
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

  ```
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



### 设计模式

#### 创建型模式

- 创建型模式关注点是如何创建对象，其核心思想是要把对象的创建和使用相分离，这样使得两者能相对独立地变换。
- 创建型模式包括：
  - 工厂方法：Factory Method
  - 抽象工厂：Abstract Factory
  - 建造者：Builder
  - 原型：Prototype
  - 单例：Singleton

##### 工厂方法

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

- 简单工厂

  ```c++
  #include <iostream> 
  #include <stdlib.h> 
  
  using namespace std;
  
  typedef enum ProductType
  {
  	TypeA,
  	TypeB,
  	TypeC
  }ProductType_t;
  
  /* 产品抽象基类 */
  class Product
  {
  public:
  	virtual void printf() = 0;
  };
  class ProductA : public Product
  {
  public:
  	void printf()
  	{
  		cout<<"Create productA"<<endl;
  	}
  };
  class ProductB : public Product
  {
  public:
  	void printf()
  	{
  		cout<<"Create productB"<<endl;
  	}
  
  };
  class ProductC : public Product
  {
  public:
  	void printf()
  	{
  		cout<<"Create productC"<<endl;
  	}
  
  };
  
  /* 工厂类 */
  class Factory
  {
  public:
  	Product* CreateProduct(ProductType_t type);
  };
  
  Product* Factory::CreateProduct(ProductType_t type)
  {
  	Product *a = NULL;
  	
  	switch (type)
  	{
  		case TypeA:
  			a = new ProductA();
  		break;
  		case TypeB:
  			a = new ProductB();
  		break;
  		case TypeC:
  			a = new ProductC();
  		break;
  		default:
  		break;
  	}
  	return a;
  }
  
  int main(int argc, char **argv)
  {
  	Factory productCreator;
  	
  	Product *productA;
  	Product *productB;
  	Product *productC; 
  
  	productA = productCreator.CreateProduct(TypeA);
  	productB = productCreator.CreateProduct(TypeB);
  	productC = productCreator.CreateProduct(TypeC);
  	if(productA != NULL)
  	{
  		productA->printf();
  		delete productA;
  		productA=NULL;
  	}
  	if(productB != NULL)
  	{
  		productB->printf();
  		delete productB;
  		productB=NULL;
  	}
  	if(productC != NULL)
  	{
  		productC->printf();
  		delete productC;
  		productC=NULL;
  	}
  	return 0;
  }
  ```

- 工厂方法

```c++

#include <iostream> 
#include <stdlib.h> 

using namespace std;


/* 产品抽象基类 */
class Product
{
public:
	virtual void printf() = 0;
};
class ProductA : public Product
{
public:
	void printf()
	{
		cout<<"Create productA"<<endl;
	}
};
class ProductB : public Product
{
public:
	void printf()
	{
		cout<<"Create productB"<<endl;
	}

};
class ProductC : public Product
{
public:
	void printf()
	{
		cout<<"Create productC"<<endl;
	}

};

/* 工厂类 */
class Factory
{
public:
	virtual Product* CreateProduct()=0;
};

class FactoryA:public Factory
{
public:
	Product *CreateProduct()
	{
		return new ProductA();
	}
};
class FactoryB:public Factory
{
public:
	Product *CreateProduct()
	{
		return new ProductB();
	}
};

class FactoryC:public Factory
{
public:
	Product *CreateProduct()
	{
		return new ProductC();
	}
};


int main(int argc, char **argv)
{
	Factory *factoryA;
	Factory *factoryB;
	Factory *factoryC;
	Product *productA;
	Product *productB;
	Product *productC; 

	factoryA = new FactoryA(); 
	if(factoryA != NULL)
	{
		productA = factoryA->CreateProduct(); 
		if (productA != NULL)
		{
			productA->printf();
			delete productA;
			productA = NULL;
		}
		delete factoryA;
		factoryA = NULL;
	}
	
	factoryB = new FactoryB(); 
	if(factoryB != NULL)
	{
		productB = factoryB->CreateProduct(); 
		if (productB != NULL)
		{
			productB->printf();
			delete productB;
			productB = NULL;
		}
		delete factoryA;
		factoryA = NULL;
	}
	
	factoryC = new FactoryC(); 
	if(factoryC != NULL)
	{
		productC = factoryC->CreateProduct(); 
		if (productC != NULL)
		{
			productC->printf();
			delete productC;
			productC = NULL;
		}
		delete factoryC;
		factoryC = NULL;
	}
	return 0;
}

Create productA
Create productB
Create productC
```

##### 抽象工厂

- 提供一个创建一系列相关或相互依赖对象的接口，而无需指定它们具体的类。
- 抽象工厂模式和工厂方法不太一样，它要解决的问题比较复杂，不但工厂是抽象的，产品是抽象的，而且有多个产品需要创建，因此，这个抽象工厂会对应到多个实际工厂，每个实际工厂负责创建多个实际产品：

```c++

#include <iostream> 
#include <stdlib.h> 

using namespace std;

/* 产品A抽象基类 */
class ProductA
{
public:
	virtual void printf() = 0;
};

/* 产品类A0 */
class ProductA0 : public ProductA
{
public:
	void printf()
	{
		cout<<"Create productA0"<<endl;
	}
};

/* 产品类A1 */
class ProductA1 : public ProductA
{
public:
	void printf()
	{
		cout<<"Create productA1"<<endl;
	}
};

/* 产品B抽象基类 */
class ProductB
{
public:
	virtual void printf() = 0;
};

/* 产品类B0 */
class ProductB0 : public ProductB
{
public:
	void printf()
	{
		cout<<"Create productB0"<<endl;
	}
};

/* 产品类B1 */
class ProductB1 : public ProductB
{
public:
	void printf()
	{
		cout<<"Create productB1"<<endl;
	}
};

/* 工厂类 */
class Factory
{
public:
	virtual ProductA* CreateProductA()=0;
	virtual ProductB* CreateProductB()=0;
};

/* 工厂类0，专门生产0类产品 */
class Factory0:public Factory
{
public:
	ProductA *CreateProductA()
	{
		return new ProductA0();
	}
	ProductB *CreateProductB()
	{
		return new ProductB0();
	}
};

/* 工厂类1，专门生产1类产品 */
class Factory1:public Factory
{
public:
	ProductA *CreateProductA()
	{
		return new ProductA1();
	}
	ProductB *CreateProductB()
	{
		return new ProductB1();
	}
};

int main(int argc, char **argv)
{
	Factory *factory0;
	Factory *factory1;
	ProductA *productA0;
	ProductA *productA1;
	ProductB *productB0; 
	ProductB *productB1;

	factory0 = new Factory0(); 
	if(factory0 != NULL)
	{
		productA0 = factory0->CreateProductA(); 
		if (productA0 != NULL)
		{
			productA0->printf();
			delete productA0;
			productA0 = NULL;
		}

		productB0 = factory0->CreateProductB(); 
		if (productB0 != NULL)
		{
			productB0->printf();
			delete productB0;
			productB0 = NULL;
		}
		delete factory0;
		factory0 = NULL;
	}
	
	factory1 = new Factory1(); 
	if(factory1 != NULL)
	{
		productA1 = factory1->CreateProductA(); 
		if (productA1 != NULL)
		{
			productA1->printf();
			delete productA1;
			productA1 = NULL;
		}

		productB1 = factory1->CreateProductB(); 
		if (productB1 != NULL)
		{
			productB1->printf();
			delete productB1;
			productB1 = NULL;
		}
		delete factory1;
		factory1 = NULL;
	}
	return 0;
}

Create productA0
Create productB0
Create productA1
Create productB1
```

##### 原型

- 原型模式（Prototype Pattern），是一种创建型设计模式，指的是以原型实例指定待创建对象的种类，并通过拷贝（克隆）原型对象来创建新的对象。原型模式的核心和关键字是“对象拷贝”。

- 原型模式由抽象原型（Abstract Prototype ）、具体原型（Concrete Prototype ）、客户（Client）三个要素组成。

  - 抽象原型（Abstract Prototype ）, 声明一个抽象原型父类，定义自身实例拷贝接口
  - 具体原型（Concrete Prototype ）， 继承Abstract Prototype 类，实现抽象接口，返回拷贝对象
  - 客户（Client），客户调具体原型对象方法创建一个新的对象，严格来说客户不属于原型模式的一部分

- 原型模式作用

  - 原型模式的功能与拷贝构造函数一样，都是用于创建新对象。但原型模式可以动态获取当前对象运行时的状态。

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

  - 执行结果

    ```
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/prototye$ make
    g++    -c -o prototye.o prototye.cpp
    g++    -c -o client.o client.cpp
    g++    -c -o concrtee_prototye.o concrtee_prototye.cpp
    g++  prototye.o  client.o  concrtee_prototye.o   -o output/client1.00
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/prototye$ ./output/client1.00 
    pConcretePrototye0属性:Init
    pConcretePrototye0属性:Second
    pConcretePrototye1属性:Second
    acuity@ubuntu:/mnt/hgfs/LSW/STHB/design/prototye$ 
    ```

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

  ```
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
  ```

- 根据类的对象实例化过程的不同，单例模式又分为“懒汉式单例”和”饿汉式单例“。

- 饿汉式单例指的是定义类的时候或者程序初始时执行实例化对象，使用的时候可以直接使用，无需创建。饿汉式单例，需要注意的是，采用new关键字生成的堆上对象，必须声明一个public类型的方法来主动释放对象，因为析构函数声明为private，不会在类外被调用。

  ```
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

  ```
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

  
