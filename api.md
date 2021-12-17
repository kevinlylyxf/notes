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

###### std::function,std::bind

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

##### 回调函数

- [深入c++回调，里面包含各种解释，前面包含链接，可以查看一下解释](https://cloud.tencent.com/developer/article/1519851)

- [回调函数理解包括同步和异步](https://bot-man-jl.github.io/articles/?post=2017/Callback-Explained)

##### 信号处理和signal

- [Linux信号处理原理与实现](https://mp.weixin.qq.com/s/rcpK-UEYIy628b77IG-obA)
  - signal是异步函数，将回调函数注册到内核态，当进程收到对应的信号时，由内核态来调用对应的信号处理函数。内核态和当前进程在一起，组成当前整个的程序，只是内核态是由系统内核维护的一些函数，内核态也有进程

