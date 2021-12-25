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

    ```
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

    ```
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

    ```
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

    ```
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

      ```
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

      ```
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

      ```
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

