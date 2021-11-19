#### 日常记录

##### 全局变量的问题

- 全局变量可以在函数外面声明，但是不能在函数外面声明后定义，我们可以在声明的时候定义，但是不能在声明之后在定义，这样就会出错。如果声明了一个map，如果没有定义，我们可以写一个全局函数，然后在函数内初始化map，这样就可以完成先声明后定义

  ```c++
  map<string, int> uCode;
  void cretemap(map<string, int> &uCode) {
  	uCode["liyunliang"] = 1;
  }
  int main(){
  	createmap(uCode);
  	map<string, int>::iterator iter = uCode.find("liyunliang");
  	cout << iter.first << "  " << iter.secomd << endl;
  	return 0;
  }
  ```

- 如果这样写就是错误的

  ```c++
  map<string, int> uCode;
  uCode["liyunliang"] = 1;
  int main(){
  	map<string, int>::iterator iter = uCode.find("liyunliang");
  	cout << iter.first << "  " << iter.secomd << endl;
  	return 0;
  }
  ```

  - 这样编译器就会将上面的两行都看成是单独的声明，这样就会出错，第二行中uCode就会报错不是一个类型名

##### atoi和itoa问题

- 字符串和数字的转化，有的时候数字很大不能用int、longlong等来存储，我们可以转换为字符串来存储，数字转换为字符串可以用sprintf和snprintf，字符串转为数字可以使用atoi和atoll这函数族。
- 具体的转换为数字123转换为字符串就是"123"，并不会根据ASCII值进行一些转换，这种转换就是为了存储，字符串123转换为数字，存储起来就是123。
- 数字转为字符串，例如longlong是8个字节，而8个字节最多能表示的数字为18,446,744,073,709,551,616，其有20位数字，如果转换为字符串，设置char str[21]就够了，因为其最多能表示21为数字。如果字符串转换为数字，字符串超过20位，转换为数字就会出现数字不对的问题，因为已经超过longlong的最大表示范围了，不能在大了，最后结果就是实际的数字在内存中的存储，截取8个字节的值表示成的数字。剩余的不会表示出来。

##### 栈上和堆区创建对象

- 在栈上创建对象不要加括号，不加括号编译器也会去寻找没有参数的构造函数，如果我们自己定义了没有参数的构造函数，就不会生成默认的构造函数。加了括号就相当于一个函数声明。而对于用new创建的对象加不加括号都是去调用默认的构造函数。对于内置类型如int，new int不会初始化，加了括号才会初始化。

  ```c
  class Test
  {
  public:
  　　Test() {}
  　　Test(int a) {}
  }
  1、栈上创建对象
  　　1.1 无括号
  　　　　Test a; // 调用默认构造函数，栈上分配内存创建对象
  　　1.2 有括号
  　　　　Test a(); // 无任何意义，声明一个返回值为Test对象的无参函数
  　　1.3 有括号+参数
  　　　　Test a(2); // 调用构造函数Test(int a)，栈上分配内存创建对象
  
  2、堆上创建对象
  　　2.1 无括号
  　　　　Test *a = new Test; // 调用默认构造函数（若由编译器生成则成员不初始化），堆上分配内存创建对象
  　　2.2 有括号
  　　　　Test *a = new Test(); // 调用默认构造函数（若由编译器生成则成员初始化），堆上分配内存创建对象
  　　2.3 有括号+参数
  　　　　Test *a = new Test(2); // 调用构造函数Test(int a)，堆上分配内存创建对象
  　　2.4 系统内置类型
  　　　　new int;// 分配内存，未初始化
  　　　　new int();// 分配内存，初始化为0
  　　　　new int(2);// 分配内存，初始化为2
  ```

- 直接使用类名+括号的形式是产生临时对象，没有变量名来接收，使用方法按照上面来看是Test()、Test(2)，其没有变量名称来接受，适合作为值传递传递给形参，这样创建了一个临时对象，形参接受了，我们可以通过形参来操作这个临时对象。仿函数就是这样的。具体使用看谓词函数。

##### 对于续行符的理解

- c语言中把一个预处理指示写成多行要用“\”续行，因为根据定义，一条预处理指示只能由一个逻辑代码行组成。
- 而把C代码写成多行则不必使用续行符，因为换行在C代码中只不过是一种空白字符，在做语法解析时所有空白字符都被丢弃了。因为c代码并不是用换行来表示一条语句的结束，而是用；来表示一条语句的结束，下一条语句的开始，所以c代码有好多行，但是只有一个分号，也就相当于一行代码语句，就相当于一个逻辑代码行
- 而对于没有分号的编码语言，其是以换行作为一个逻辑代码行来结束的，所以一行命令太长要拆分成多行的时候，就要用续行符来表明，在击回车键之前输入“\”，即可实现多行命令输入。这种续行的写法要求“\”后面紧跟换行符，中间不能有任何其他的字符。
- 需要换行符的编程语言一般的有shell，python，Makefile等，没有分号来表示结束，只是以当前行来表示结束

##### volatile

- volatile 关键字是一种类型修饰符，用它声明的类型变量表示可以被某些编译器未知的因素更改，比如：操作系统、硬件或者其它线程等。遇到这个关键字声明的变量，编译器对访问该变量的代码就不再进行优化，从而可以提供对特殊地址的稳定访问。声明时语法：**int volatile vInt;** 当要求使用 volatile 声明的变量的值的时候，系统总是重新从它所在的内存读取数据，即使它前面的指令刚刚从该处读取过数据。而且读取的数据立刻被保存。

  ```c
  volatile int i=10;
  int a = i;
  ...
  // 其他代码，并未明确告诉编译器，对 i 进行过操作
  int b = i;
  ```

- volatile 指出 i 是随时可能发生变化的，每次使用它的时候必须从 i的地址中读取，因而编译器生成的汇编代码会重新从i的地址读取数据放在 b 中。而优化做法是，由于编译器发现两次从 i读数据的代码之间的代码没有对 i 进行过操作，它会自动把上次读的数据放在 b 中。而不是重新从 i 里面读。这样以来，如果 i是一个寄存器变量或者表示一个端口数据就容易出错，所以说 volatile 可以保证对特殊地址的稳定访问。

- 其实不只是内嵌汇编操纵栈"这种方式属于编译无法识别的变量改变，另外更多的可能是多线程并发访问共享变量时，一个线程改变了变量的值，怎样让改变后的值对其它线程 visible。

  - 中断服务程序中修改的供其它程序检测的变量需要加 volatile；
  - 多任务环境下各任务间共享的标志应该加 volatile；
  - 存储器映射的硬件寄存器通常也要加 volatile 说明，因为每次对它的读写都可能由不同意义；

- 有些变量是用 volatile 关键字声明的。当两个线程都要用到某一个变量且该变量的值会被改变时，应该用 volatile 声明，该关键字的作用是防止优化编译器把变量从内存装入 CPU 寄存器中。如果变量被装入寄存器，那么两个线程有可能一个使用内存中的变量，一个使用寄存器中的变量，这会造成程序的错误执行。volatile 的意思是让编译器每次操作该变量时一定要从内存中真正取出，而不是使用已经存在寄存器中的值

- 一般的对象编译器可能会将其的拷贝放在寄存器中用以加快指令的执行速度

##### 网络字节序问题

- 网络字节序是大端，在程序中htonl转换之后写进文件，在之后在用的时候记得转换会本地字节序

##### 引用的理解

- 引用其实就是给一个变量起一个别名，这个别名就可以当作那个变量来使用

  ```
  int a = 2;
  int &b = a;
  int &c = b;
  cout << c << endl;
  运行结果2
  ```

  - 引用就是一个别名，在定义时引用变量前面加上&，在使用时不用加&，直接使用。所以上面的c能直接输出，&只是一个符号表示引用，将两个符号绑定在一起。所以引用变量可以直接当作变量来使用，不用加&符号。

- 函数返回引用是左值，所以可以连续赋值。

  - 引用为了减少数据的复制，现在函数的返回值是引用，说明调用函数最后的结果和某个值绑定了成为引用，理解为函数调用结果就是上面的b或者c，所以b和c可以赋值，可以输出。所以函数返回值为引用。我们可以通过这个来修改其引用的变量的值。

  - 函数返回引用就是调用函数后函数的返回值和某些值绑定了，这种绑定只是没有明确的引用变量，但是调用函数这个过程的返回值其实就是引用变量，完全可以把调用函数当作上面的b来使用，可以cout << get_val(s, 0)这样来使用，把函数调用的结果当作b，没有明确的b

  - vector容器中的front和end方法就是返回的引用。我们可以通过vector.front() = 2这样来修改vector容器中首个元素的值。

  - 而且函数的调用也可以直接作为b，给引用c赋值，c也得是引用变量。

    ```c++
    char &get_val(string &str,string::size_type ix)
    {
         return str[ix];
    }
    使用语句调用:
    string s("123456");
    cout<<s<<endl;
    get_val(s,0)='a';
    cout<<s<<endl;
           
    char &ch = get_val(s,0);
    ch = ‘A’;
    ```

##### 谓词函数

- 一元谓词函数：如果一元函数返回一个BOOL类型的值，则该函数称为谓词。 二元函数：接受2个参数的函数，如f(x,y)。 二元谓词函数：如果二元函数返回一个BOOL值，则该函数称为二元谓词。 之所以给返回布尔类型的函数对象专门命名，是因为谓词是用来为算法判断服务的。

- 谓词可以是一个仿函数，也可以是一个回调函数。回调函数即是函数指针，函数体里面通过函数指针调用函数。

- 一元谓词实例，仿函数实现

  ```c++
  #include<iostream>
  #include<vector>
  #include<algorithm>
  using namespace std;
   
  class ValidScore
  {
  public:
      bool operator()(int val)
      {
          return val >= 60;
      }
  };
   
  int main()
  {
      vector<int> v = { 20,30,50,70,90 };
      auto iter = find_if(v.begin(), v.end(), ValidScore());
      if (iter == v.end())
      {
          cout << "没有找到及格的分数" << endl;
      }
      else
      {
          cout << "找到及格的分数: " << *iter << endl;
      }
   
      getchar();
      return 0;
  }
  ```

  - 仿函数就是重载了()的一个类，上面的ValidScore()实际上就是调用了构造函数，如果构造函数有参数的话也可以在参数里面传进去，这就相当于传入了一个类对象，只是这个类对象没有明确的名字，我们最终想要的就是类里面重载了()的成员函数，可以不用实例化对象直接传进去，也可以实例化一个对象传进去，类似于int swap(int a, int b)函数，我们可以定义两个变量int x = 1, y = 2,然后调用函数swap(x, y),也可以不实例化一个对象直接传进去swap(1, 2),只是这样的交换没有意义，因为没有变量来接受，没有实质的意义，但是上面的临时类对象，我们用的就是其中的成员函数，其也不用返回，也不用变量来接受查看结果，所以上面写法是对的。回调函数传入时只需要写上函数名字就可以了，不用写()，不需要写入参数，我们传入的就是函数指针，并没有真正的调用函数，真正的调用函数在函数体里面。

- 二元谓词函数，仿函数实现

  ```c++
  #include<iostream>
  #include<vector>
  #include<algorithm>
  using namespace std;
   
  class MyCompare
  {
  public:
      bool operator()(int v1, int v2)
      {
          return v1 > v2;
      }
  };
   
  int main()
  {
      vector<int> v = { 20,30,70,90,50 };
      sort(v.begin(), v.end(), MyCompare());        //从大到小排列
      for_each(v.begin(), v.end(), [](int val) {
          cout << val << " ";
      });
   
      getchar();
      return 0;
  }
  ```

##### 仿函数

- 如果一个类将`()`运算符重载为成员函数，这个类就称为函数对象类，这个类的对象就是函数对象。函数对象是一个对象，但是使用的形式看起来像函数调用，实际上也执行了函数调用，因而得名。又名仿函数

- 为什么要有仿函数

  - 我们先从一个非常简单的问题入手，来了解为什么要有仿函数。假设我们现在有一个数组，数组中存有任意数量的数字，我们希望能够统计出这个数组中大于 10 的数字的数量，你的代码很可能是这样的：

    ```
    #include <iostream>
    using namespace std;
    
    int RecallFunc(int *start, int *end, bool (*pf)(int)) {
        int count=0;
        for(int *i = start; i != end+1; i++) {
        	count = pf(*i) ? count+1 : count;
        }
        return count;
    }
    
    bool IsGreaterThanTen(int num) {
    	return num>10 ? true : false;
    }
    
    int main() {
    	int a[5] = {10,100,11,5,19};
        int result = RecallFunc(a, a+4, IsGreaterThanTen);
        cout<<result<<endl;
        return 0;
    }
    
    ```

  - RecallFunc() 函数的第三个参数是一个函数指针，用于外部调用，而 IsGreaterThanTen() 函数通常也是外部已经定义好的，它只接受一个参数的函数。如果此时希望将判定的阈值也作为一个变量传入，变为如下函数就不可行了：

    ```
    bool IsGreaterThanThreshold(int num, int threshold) {
    	return num>threshold ? true : false;
    }
    ```

  - 虽然这个函数看起来比前面一个版本更具有一般性，但是它不能满足已经定义好的函数指针参数的要求，因为函数指针参数的类型是bool (*)(int)，与函数bool IsGreaterThanThreshold(int num, int threshold)的类型不相符。如果一定要完成这个任务，按照以往的经验，我们可以考虑如下可能途径：
    （1）阈值作为函数的局部变量。局部变量不能在函数调用中传递，故不可行；
    （2）函数传参。这种方法我们已经讨论过了，多个参数不适用于已定义好的 RecallFunc() 函数。
    （3）全局变量。我们可以将阈值设置成一个全局变量。这种方法虽然可行，但不优雅，且容易引入 Bug，比如全局变量容易同名，造成命名空间污染。

  - 那么有什么好的处理方法呢？仿函数应运而生。

- 仿函数的定义

  仿函数（Functor）又称为函数对象（Function Object）是一个能行使函数功能的类。仿函数的语法几乎和我们普通的函数调用一样，不过作为仿函数的类，都必须重载 operator() 运算符。因为调用仿函数，实际上就是通过类对象调用重载后的 operator() 运算符。

  如果编程者要将某种“操作”当做算法的参数，一般有两种方法：
  （1）一个办法就是先将该“操作”设计为一个函数，再将函数指针当做算法的一个参数。上面的实例就是该做法；
  （2）将该“操作”设计为一个仿函数（就语言层面而言是个 class），再以该仿函数产生一个对象，并以此对象作为算法的一个参数。

  很明显第二种方法会更优秀，因为第一种方法扩展性较差，当函数参数有所变化，则无法兼容旧的代码，具体在第一小节已经阐述。正如上面的例子，在我们写代码时有时会发现有些功能代码，会不断地被使用。为了复用这些代码，实现为一个公共的函数是一个解决方法。不过函数用到的一些变量，可能是公共的全局变量。引入全局变量，容易出现同名冲突，不方便维护。

  这时就可以使用仿函数了，写一个简单类，除了维护类的基本成员函数外，只需要重载 operator() 运算符 。这样既可以免去对一些公共变量的维护，也可以使重复使用的代码独立出来，以便下次复用。而且相对于函数更优秀的性质，仿函数还可以进行依赖、组合与继承等，这样有利于资源的管理。如果再配合模板技术和 Policy 编程思想，则更加威力无穷，大家可以慢慢体会。Policy 表述了泛型函数和泛型类的一些可配置行为（通常都具有被经常使用的缺省值）。

  STL 中也大量涉及到仿函数，有时仿函数的使用是为了函数拥有类的性质，以达到安全传递函数指针、依据函数生成对象、甚至是让函数之间有继承关系、对函数进行运算和操作的效果。比如 STL 中的容器 set 就使用了仿函数 less ，而 less 继承的 binary_function，就可以看作是对于一类函数的总体声明，这是函数做不到的。

  ```
  // less的定义
  template<typename _Tp> struct less : public binary_function<_Tp, _Tp, bool> {
        bool operator()(const _Tp& __x, const _Tp& __y) const
        { return __x < __y; }
  };
   
  // set 的申明
  template<typename _Key, typename _Compare = std::less<_Key>,typename _Alloc = std::allocator<_Key>> class set;
  
  ```

  接收仿函数的地方用了泛型编程，可以接受任意类型，包括我们写的一些类，所以一些算法能接受我们自己写的类作为参数传进来，就是用了这种技巧，而且在调用函数模板的时候不用<>指明类型，其会根据传进来的参数自己推导。
  - 仿函数中的变量可以是 static 的，同时仿函数还给出了 static 的替代方案，仿函数内的静态变量可以改成类的私有成员，这样可以明确地在析构函数中清除所用内容，如果用到了指针，那么这个是不错的选择。有人说这样的类已经不是仿函数了，但其实，封装后从外界观察，可以明显地发现，它依然有函数的性质。

- 仿函数实例

  ```
  class StringAppend {
  public:
      explicit StringAppend(const string& str) : ss(str){}
      void operator() (const string& str) const {
           cout << str << ' ' << ss << endl;
      }
  private:
      const string ss;
  };
  
  int main() {
      StringAppend myFunctor2("and world!");
      myFunctor2("Hello");
  }
  ```

  - 这个例子应该可以让您体会到仿函数的一些作用：它既能像普通函数一样传入给定数量的参数，还能存储或者处理更多我们需要的有用信息。于是仿函数提供了第四种解决方案：成员变量。成员函数可以很自然地访问成员变量，从而可以解决第一节“1.为什么要有仿函数”中提到的问题：计算出数组中大于指定阈值的数字数量。

  ```c++
  #include <iostream>
  using namespace std;
  
  class IsGreaterThanThresholdFunctor {
  public:
  	explicit IsGreaterThanThresholdFunctor(int t):threshold(t){}
  	bool operator() (int num) const {
  		return num > threshold ? true : false;
  	}
  private:
  	const int threshold;
  };
  
  int RecallFunc(int *start, int *end, IsGreaterThanThresholdFunctor myFunctor) {
  	int count = 0;
  	for (int *i = start; i != end + 1; i++) {
  		count = myFunctor(*i) ? count + 1 : count;
  	}
  	return count;
  }
  
  int main() {
  	int a[5] = {10,100,11,5,19};
  	int result = RecallFunc(a, a + 4, IsGreaterThanThresholdFunctor(10));
  	cout << result << endl;
  }
  
  ```

  - 上面是一个具体的实例，其中RecallFunc函数使用的形参中是一个具体的类，没有用到泛型编程，所以要写一个具体的类名，这是我们写例子用的，可以写成泛型编程，这样我们写的任何类名都能传进去来接收。后面的IsGreaterThanThresholdFunctor(10)是我们创建的一个临时的类对象。

##### fopen文件指针的问题

- fopen是建立FILE * 指针和文件的联系，所以每次打开文件FILE*都会重新建立联系，文件的内部位置指针都会置为文件开头。所以fseek移动位置指针，然后调用函数，函数里面重新打开这个文件，这样在函数内指针还是在开头。

##### strcpy 、memset、memcpy和字符串数组

```c
void *memset(void *s, int c, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
char *strcpy(char *dest, const char *src);
char *strncpy(char *dest, const char *src, size_t n);
```

- memcpy是内存拷贝函数，指针就是地址，所以我们在传递参数时不一定非要用指针，可以直接用&来获取地址

- strcpy只能复制字符串，而memcpy可以复制任意内容，例如字符数组、整型、结构体、类等。strcpy会将\0一起拷贝进去。

- strcpy和strncpy会自动拷贝\0，但是为了安全，需要手动方式自行添加`\0` 结束符，一般拷贝了n个的话，将最后一个设置为0即\0

  ```c
  strncpy(info.path, buffer, sizeof(info.path));
  info.path[sizeof(info.path) - 1] = 0;
  将buffer拷贝进info.path中，将最后一个设置为0,最后一个为info.path[sizeof(info.path)-1],而不是sizeof(info.path)
  strncpy遇到\0就会停止，但是如果n比较大，就会拷贝不到\0,所以将最后一个手动置为0是安全的。
  ```

- strcpy不需要指定长度，它遇到被复制字符的串结束符"\0"才结束，如果空间不够，就会引起内存溢出。memcpy则是根据其第3个参数决定复制的长度。

- 通常在复制字符串时用strcpy，而需要复制其他类型数据时则一般用memcpy，由于字符串是以“\0”结尾的，所以对于在数据中包含“\0”的数据只能用memcpy。

- strcpy的参数必须是char *的，所以strcpy只能拷贝字符串，memcpy的参数是void *，所以memcpy可以拷贝任意的数据类型

- char和unsigned都可以定义字符数组，其都可以通过%s打印出来，两者基本没有区别，但是unsigned不能使用strcpy函数拷贝，char类型能用strcpy函数拷贝，unsigned char可以使用memcpy函数拷贝，如果形参是char *类型的，不能用unsigned char 类型的实参赋值，unsigned char 和char的互相转换都是错误的，所以不能这个赋值，除非形参中的指针参数是void\*的，这样就可以将任意类型的传进去，不论是unsigned char或者是char，因为其会在内部转化。所以memcpy函数可以拷贝任意类型的char或者unsigned char，因为其参数是void\*的，除了不能这样互相赋值外，其他的unsigned char和char都是相同的，都可以通过%s打印出来。如果需要转化，必须要用强转才行。例如将unsigned char赋值给char 可以使用强转，char = （char *）unsigned char

  ```
  char* cJSON_strdup(const char* str)
  {
        size_t len;
        char* copy;
  
        len = strlen(str) + 1;
        if (!(copy = (char*)cJSON_malloc(len))) return 0;
        memcpy(copy,str,len);
        return copy;
  }
  ```

  - 此函数的只要作用是复制字符串，不能传入unsigned char类型的数组，如果传入的话报错：从类型 ‘unsigned char*’ 到类型 ‘const char*’ 的转换无效，即unsigned char不能转换为char类型，如果上面的函数需要传入unsigned char类型的数据时，可以强制转换为char*的

    ```
    int main(){
    	unsigned char str[512] = "aabbcc";
    	char * arr = NULL;
    	arr = cJSON_strdup((char*)str);
    	printf("%s", arr);
    }
    
    运行结果aabbcc
    ```

    - 所以当使用unsigned char给char赋值时要用强转就可以，上面的程序中可以使用arr指向函数返回值，因为函数返回一个字符串指针，左边是一个指针，又边也是一个指针，所以可以赋值

  - 此函数使用时可以设置一个指针char * str = NULL；然后让这个指针指向返回值，因为这个函数的返回值为一个字符串指针，所以可以写为str = cJSON_strdup(str);这样写是正确的。

- 字符数组当做字符串时，在定义时可以用字符串即char *类型的数据命令，但是如果在定义的时候没有赋值，以后只能一个一个字符的赋值

  ```c
  typedef struct __MSG_SYS_CONFIG_INFO
  {
  	unsigned int id;
  	unsigned int state; 
  	char path[512]; 
  	unsigned char sum[32]; 
  	CFG_ACTION ctlRule;
  	CFG_ACTION protRule;
  }__attribute__((packed)) MSG_SYS_CONFIG_INFO;
  ```

  - 在结构体中定义的数组path，我们一般定义一个结构体变量时不赋值，所以以后只能一个一个的赋值
  - 但是我们明显看到path是字符数组，即char *类型的，一个一个的赋值很麻烦，我们可以用memcpy将char * 拷贝到path中

- memset将指针变量 s 所指向的前 n 字节的内存单元用一个“整数” c 替换，注意 c 是 int 型。s 是 void* 型的指针变量，所以它可以为任何类型的数据进行初始化。
  - 定义变量时一定要进行初始化，尤其是数组和结构体这种占用内存大的[数据结构](http://c.biancheng.net/data_structure/)。在使用数组的时候经常因为没有初始化而产生“烫烫烫烫烫烫”这样的野值，俗称“乱码”。
  - 每种类型的变量都有各自的初始化方法，memset() 函数可以说是初始化内存的“万能函数”，通常为新申请的内存进行初始化工作。它是直接操作内存空间，mem即“内存”（memory）的意思
  - memset() 的作用是在一段内存块中填充某个给定的值。因为它只能填充一个值，所以该函数的初始化为原始初始化，无法将变量初始化为程序中需要的数据。用memset初始化完后，后面程序中再向该内存空间中存放需要的数据。
  - memset 一般使用“0”初始化内存单元，而且通常是给数组或结构体进行初始化。一般的变量如 char、int、float、double 等类型的变量直接初始化即可，没有必要用 memset。如果用 memset 的话反而显得麻烦。
  - 数组也可以直接进行初始化，但 memset 是对较大的数组或结构体进行清零初始化的最快方法，因为它是直接对内存进行操作的。
  - 虽然参数 c 要求是一个整数，但是整型和字符型是互通的。但是赋值为 '\0' 和 0 是等价的，因为字符 '\0' 在内存中就是 0。所以在 memset 中初始化为 0 也具有结束标志符 '\0' 的作用，所以通常我们就写“0”。
  
- 在用字符串的函数时要注意有没有\0，如果没有就不能使用strcmp和strcpy这样的函数，因为没有结尾不知道在哪里结束，所以会出现错误，不知道字符串到哪里了。

##### strcpy和strncpy以及strlen和sizeof的问题以及字符串循环打印的问题

- strlen是一个函数，求的是字符串的实际长度，它求得方法是从开始到遇到第一个'\0',如果你只定义没有给它赋初值，这个结果是不定的，它会从arr首地址一直找下去，直到遇到'\0'停止。 而sizeof()返回的是变量声明后所占的内存数，不是实际长度，此外sizeof不是函数，仅仅是一个操作符，strlen是函数。

- strlen结果为去掉\0之后的实际字符数量，sizeof求得是字符串占用得内存数，如果定义arr[10]，用sizeof(arr)，求得结果为10，不管里面有没有字符，也不管有几个，求出来得结果就是占用得内存数10

- strcpy会追加结束标记\0，strncpy()不会向dest追加结束标记'\0'，所以strncpy使用时其中得n要明白清楚，n为要复制得字节数，使用strlen和sizeof结果不一样

  ```
  char * strncpy(char *dest, const char *src, size_t n);
  ```

- strlen和sizeof在用于字符串指针时，sizeof为指针得大小4个字节，而strlen为字符串本身得长度，并不是4个字节

- 在使用strcpy和strncpy以及memcpy函数的时候，dest要有明确的地址，不能只申请一个指针，指针要指向明确的地址才能行，否则会出现段错误。例如char * str = NULL; strcpy(str, "aabbcc");这样就会出现段错误，因为str没有空间可以容纳字符串，其只是一个指针

- 如果字符串太大，循环打印的问题：strncpy和memcpy函数都可以设置拷贝多少个字节，所以我们可以每次都拷贝固定字节，然后每次拷贝完，src指针都往后移固定字节，这样就能循环打印了，字符串指针就是字符数组，所以可以往后移固定字节src+100，这样就能行。

##### sprintf和snprintf

- ```
  int printf(const char *format, ...);
  int fprintf(FILE *stream, const char *format, ...);
  int sprintf(char *str, const char *format, ...);
  int snprintf(char *str, size_t size, const char *format, ...);
  ```

- sprintf和snprintf中的format和printf中的格式控制符一样，函数是用来向字符串写东西的，包括数字、字符都能写进去，且能控制写进去的字符形式例如以十进制十六进制，strcpy只能拷贝字符串

- snprintf 函数操作的对象 不限于字符串 ：虽然目的对象是字符串，但是源对象可以是字符串、也可以是任意基本类型的数据。这个函数主要用来实现 （字符串或基本数据类型）向 字符串 的转换 功能。如果源对象是字符串，并且指定 %s 格式符，也可实现字符串拷贝功能。

- 对于非字符串类型的数据的复制来说，strcpy 和 snprintf 一般就无能为力了，可是对 memcpy 却没有什么影响。但是，对于基本数据类型来说，尽管可以用 memcpy 进行拷贝，由于有赋值运算符可以方便且高效地进行同种或兼容类型的数据之间的拷贝，所以这种情况下 memcpy 几乎不被使用。memcpy 的长处是用来实现（通常是内部实现居多）对结构或者数组的拷贝，其目的是或者高效，或者使用方便，甚或两者兼有。

- \0只是一个字符串结束的标志并不会输出，就像printf输出字符串一样，检测到\0就会停止，所以\0没有在输出里面，同理，sprintf拼接两个字符串时，第一个字符串写进去到\0结束，但是并不会将\0写进去，所以后续的可以直接写进去。按照目前情况来看我们是在用字符串的时候会去掉\0例如printf的时候，但是在一些生成字符串的函数里面在结尾会自动加上\0，这个要注意。所以sprintf会在后面加上\0，否则就不能正确读取了。

##### goto和变量的定义问题

- int a；这就是变量的定义，变量只有定义和赋值。函数有声明和定义，函数没有赋值说法。

- goto语句之后不能有变量的定义。在汇编语言中,程序的数据段定义和代码段定义是分开的,数据段定义(数据段不包含堆栈段)必须在代码运行前分配完毕.所以,一个函数(在汇编中称为过程)的代码,永远是在数据段定义后才执行的,goto语句是代码段内容,不可能出现在数据段中,函数会先把需要的变量定义之后(也就是在数据段定义),才开始执行代码,因此无论这个goto在哪里,总是跳不过变量定义.

- C89 规定，所有局部变量都必须定义在函数开头，在定义好变量之前不能有其他的执行语句。C99 标准取消这这条限制。取消限制带来的另外一个好处是，可以在 [for 循环](http://c.biancheng.net/view/172.html)的控制语句中定义变量。这时局部变量和上面的goto有区别。goto之后就不能有变量的定义了。但是如果没有goto语句，局部变量在C99标准下只要在使用前在哪里定义都可以。但是不能放到goto后面定义

- 在局部变量里面可以定义变量，例如if和for语句内可以定义变量，其是内部的只能在函数内部使用，不管for和if外面有没有goto语句

  ```
  int a = 2;
  if (a != 2) goto DONE;
  int b = 3;
  printf("$d\n", b);
  这个写法是错误的，a和b在同一层，所以不能在定义变量b之前有goto语句
  
  int a = 2;
  if (a != 2) goto DONE;
  if (a == 2) {
  	int b = 3;
  	printf("$d\n", b);
  }这种写法是正确的，b是在内部定义的，和a没有在同一层，所以变量b不受前面goto语句的影响，同理，if换成for也是一样的。只要是变量没有在同一层就可以定义局部变量。但是在局部里面如果有goto，只能在goto之前定义变量。
  
  ```

  

- 在打开一个文件我们想创建一个buffer将数据都读入到buffer中，但是我们不知道文件的大小，不能直接定义数组的长度。所以我们可以先计算文件的大小，在计算文件大小的语句中不能有goto，否则会报错，然后在得到文件大小的语句之后在创建buffer，这样就能读入成功了。

##### 动态数组和malloc、calloc、realloc函数

```c
 #include <stdlib.h>
 void *calloc(size_t nmemb, size_t size);
 void *malloc(size_t size);
 void free(void *ptr);
 void *realloc(void *ptr, size_t size);
```

- strlen计算数组的长度，没有\0，例如string，计算出来是6不是7

- 在实际的编程中，往往会发生这种情况，即所需的内存空间取决于实际输入的数据，而无法预先确定。对于这种问题，用静态数组的办法很难解决。为了解决上述问题，C语言提供了一些内存管理函数，这些内存管理函数结合指针可以按需要动态地分配内存空间，来构建动态数组，也可把不再使用的空间回收待用，为有效地利用内存资源提供了手段。

- 在这种情况下我们可以先创建一个空指针，在得到想要的空间大小数据后然后在按照大小申请空间。这样就避免了声明一个固定大小的数组，这个数组而且不能改变大小。先创建指针在申请内存有效避免了在goto语句之后不能有变量定义的问题。也可以使用string类型中的resize来改变内存的大小。

- realloc() 对 ptr 指向的内存重新分配 size 大小的空间，size 可比原来的大或者小，还可以不变（如果你无聊的话）。当 [malloc()](http://c.biancheng.net/cpp/html/137.html)、[calloc()](http://c.biancheng.net/cpp/html/134.html) 分配的内存空间不够用时，就可以用 realloc() 来调整已分配的内存。

  - 指针 ptr 必须是在动态内存空间分配成功的指针，形如如下的指针是不可以的：int *i; int a[2]；会导致运行时错误，可以简单的这样记忆：用 malloc()、calloc()、realloc() 分配成功的指针才能被 realloc() 函数接受。
  - 如果 size 的值为 0，那么 ptr 指向的内存空间就会被释放，但是由于没有开辟新的内存空间，所以会返回空指针；类似于调用 [free()](http://c.biancheng.net/cpp/html/135.html)。
  - 如果 ptr 为 NULL，它的效果和 malloc() 相同，即分配 size 字节的内存空间。

- calloc() 在内存中动态地分配 num 个长度为 size 的连续空间，并将每一个字节都初始化为 0。所以它的结果是分配了 num*size 个字节长度的内存空间，并且每个字节的值都是0。

  - 函数的返回值类型是 void *，void 并不是说没有返回值或者返回空指针，而是返回的指针类型未知。所以在使用 calloc() 时通常需要进行强制类型转换，将 void 指针转换成我们希望的类型

    ```c
    char *ptr = (char *)calloc(10, 10);  // 分配100个字节的内存空间
    ```

  - calloc() 与 [malloc()](http://c.biancheng.net/cpp/html/137.html) 的一个重要区别是：calloc() 在动态分配完内存后，自动初始化该内存空间为零，而 malloc() 不初始化，里边数据是未知的垃圾数据。

##### 结构体最后定义大小为0的数组

- 这是个广泛使用的常见技巧，常用来构成缓冲区。比起指针，用空数组有这样的优势：(1)、不需要初始化，数组名直接就是所在的偏移；(2)、不占任何空间，指针需要占用int长度空间，空数组不占任何空间。“这个数组不占用任何内存”，意味着这样的结构节省空间；“该数组的内存地址就和它后面的元素地址相同”，意味着无需初始化，数组名就是后面元素的地址，直接就能当指针使用。

- 这样的写法最适合制作动态buffer，因为可以这样分配空间malloc(sizeof(structXXX) + buff_len); 直接就把buffer的结构体和缓冲区一块分配了。用起来也非常方便，因为现在空数组其实变成了buff_len长度的数组了。这样的好处是：(1)、一次分配解决问题，省了不少麻烦。为了防止内存泄露，如果是分两次分配(结构体和缓冲区)，那么要是第二次malloc失败了，必须回滚释放第一个分配的结构体。这样带来了编码麻烦。其次，分配了第二个缓冲区以后，如果结构里面用的是指针，还要为这个指针赋值。同样，在free这个buffer的时候，用指针也要两次free。如果用空数组，所有问题一次解决。(2)、小内存的管理是非常困难的，如果用指针，这个buffer的struct部分就是小内存了，在系统内存在多了势必严重影响内存管理的性能。要是用空数组把struct和实际数据缓冲区一次分配大块问题，就没有这个问题。如此看来，用空数组既简化编码，又解决了小内存碎片问题提高了性能。

- 结构体最后使用0或1长度数组的原因：主要是为了方便的管理内存缓冲区(其实就是分配一段连续的内存，减少内存的碎片化)，如果直接使用指针而不使用数组，那么，在分配内存缓冲区时，就必须分配结构体一次，然后再分配结构体内的指针一次，(而此时分配的内存已经与结构体的内存不连续了，所有要分别管理即申请和释放)而如果使用数组，那么只需要一次就可以全部分配出来，反过来，释放时也是一样，使用数组，一次释放。使用指针，得先释放结构体内的指针，再释放结构体，还不能颠倒顺序。

- 结构体中最后一个成员为[1]长度数组的用法：与长度为[0]数组的用法相同，改写为[1]是出于可移植性的考虑。有些编译器不支持[0]数组，可将其改成[]或[1].

- char c[0]中的c并不是指针，是一个偏移量，这个偏移量指向的是a、b后面紧接着的空间，所以它其实并不占用任何空间。所以，上面的struct pppoe_tag的最后一个成员如果用char *tag_data定义，除了会占用多个字节的指针变量外，用起来会比较不方便：方法一，创建时，可以首先为struct pppoe_tag分配一块内存，再为tag_data分配内存，这样在释放时，要首先释放tag_data占用的内存，再释放pppoe_tag占用的内存；方法二，创建时，直接为struct pppoe_tag分配一块struct pppoe_tag大小加上tag_data的内存，从例一的行可以看出，tag_data的内容要进行初始化，要让tag_data指向 strct pppoe_tag后面的内存。

- 最后的大小为零的数组即可变长部分可按数组的方式访问，可以理解为原来是可边长的数组，但是长度不定，用大小为0的数组来标记，在实际使用时分配这个数组的大小，这时候就可以将数组当成正常的数组来使用了，结构体里面套了一个数组。

- 最后一个只是一个数组，按照数组的方式存储和访问。

  ```c
  typedef struct __FILE_SCAN_ITEM_STOR
  {
  	unsigned short length;
  	unsigned char m_bHashCode[32]; // -- INTEGRITY_LENGTH=20
  	unsigned char m_bIsHashCodeValid;
  	unsigned int m_appId;
  	unsigned char m_bRawMode; // -- 没有经过 __isCheckFile 过滤的
  	unsigned char m_bIsExecuteFile;
  	unsigned char m_bScript;
  	unsigned char m_bCalulateHashFailed; 
  	unsigned char m_uErrorCode;
  	unsigned int psize;
  	unsigned int modtime;
  	unsigned char guid[36];
  	char path[0]; // -- utf8
  }__attribute__((packed)) FILE_SCAN_ITEM_STOR;
  ```

- 实际使用方法，上面中path是可变长数组，length记录着结构体大小和可变长数组的总大小，减去结构体的大小就是数组的大小，所以在读取文件的时候，用length-sizeof（结构体）就是后面的长度，将这个长度的内存读到buffer中就得到了这个path。将这个buffer在赋值给变量就可以使用了。在往文件中写的时候，用length记录，将结构体先写入，在把path写入就可以。length就是一个记录，用length就可以正确读取了

- 一般我们用数组大小为0的数组是得到数组指针，我们可以用结构体访问数组得到，例如上面FILE_SCAN_ITEM_STOR stor;stor.path,这个就是数组指针，指向数组第一个元素，或者如果结构体里面嵌套一个结构体，这个用嵌套的结构体指针+1就是后面的内容指针。

##### bool类型和0、1

- 原生的c语言不支持bool类型，若需要使用bool类型可以借用int类型自己定义一下

  ```c
  typedef int bool;
  #define TRUE 1
  #define FALSE 0
  ```

- 上面的int也可以用char类型定义，这样节省空间，c++里面支持bool类型，c++中的bool类型占用一个字节

- C99标准中新增的头文件中引入了bool类型，与C++中的bool兼容。该头文件为stdbool.h

  ```c++
  #ifndef _STDBOOL_H
  #define _STDBOOL_H
   
  #ifndef __cplusplus
   
  #define bool	_Bool
  #define true	1
  #define false	0
   
  #else /* __cplusplus */
   
  /* Supporting <stdbool.h> in C++ is a GCC extension.  */
  #define _Bool	bool
  #define bool	bool
  #define false	false
  #define true	true
   
  #endif /* __cplusplus */
  ```

  - 代码中的_Bool是C99标准为bool类型引入的新的关键字，sizeof(_Bool)的值为1，表面其为bool类型。既然为bool类型，那么0表示为假，其他任何值都表示为真

- bool类型用%d来打印，如果为真输出1，为假输出0，bool类型赋值时，如果是真的可以用任何非0值来赋值，如果为假，用0来赋值，bool类型也可以使用true和false来赋值

- int类型的值也可以使用true和false来赋值，true就代表1，false就代表0

##### signal函数

```c
void (*signal(int sig, void (*func)(int)))(int);
```

- 此函数的理解分为两个部分，中间部分signal( int sig, void (*func)(int))，表明signal函数有2个参数，第一个是int，第二个是无返回值，带一个int参数的函数指针

- 外围部分void   (*signal(xxx))   (int)，表明signal函数返回的是一个函数指针，无返回值，有一个int参数

- 总的来说就是signal函数有两个参数，然后signal函数返回一个函数指针，这个函数指针没有返回值，带有一个int参数。

- **func** -- 一个指向函数的指针。它可以是一个由程序定义的函数，也可以是下面预定义函数之一：

  | SIG_DFL | 默认的信号处理程序。 |
  | ------- | -------------------- |
  | SIG_IGN | 忽视信号。           |

- signal函数把信号作为参数传递给func信号处理函数，接着signal函数返回指针，并且又指向信号处理函数，就开始执行。

##### stringstream和snprintf

```c++
int snprintf ( char * str, size_t size, const char * format, ... );
```

- snprintf的作用为将可变参数按照format格式化成字符串并赋值到str中，其中format和printf中的格式化控制一样，都是一个家族的函数，其作用有将数字变量转换为字符串，连接多个字符串，也可以将数字和字符串一起格式化到str中，也可以将数字转换为16进制或者8进制的字符串。

- 如果格式化后的字符串长度小于等于 size，则会把字符串全部复制到 str 中，并给其后添加一个字符串结束符 **\0**；如果格式化后的字符串长度大于 size，超过 size 的部分会被截断，只将其中的 (size-1) 个字符复制到 str 中，并给其后添加一个字符串结束符 **\0**，返回值为欲写入的字符串长度。

  ```
  int main() {
  	int a = 345;
  	char * str = "my name is";
  	char s[128] = {0};
  	snprintf(s, sizeof(s), "%s %d", str, a);
  	printf("%s", s);
  	return 0;
  }
  my name is 345
  ```

  - snprintf的主要功能就是将一些数据拼接到一起存放到字符串中，其中数据是按照format格式来组织的，这其实跟printf中的格式控制符一样，%s和%d就是占位符，最后会被实际的数据替换掉，其中的空格也是存在的，如果格式控制符中没有空格，输出的也就没有"%s%d"，这样就没有，所以数据是按照双引号里面的格式来组织存储到字符串str中的，其实就是将各个数据拿到一起，转换为字符串，最后就是一个字符串，所以可以混合拼接，字符串和数据变量拼接在一起。

  ```c++
  snprintf(log_desc, sizeof(log_desc), "modify <%s> password.",user_info.username)
  snprintf(log_desc, sizeof(log_desc), "modify password.")
  ```

- snprintf中format也可以没有格式，例如第二个，就是将这个字符串拷贝到log_desc，如果有格式就有格式，按照格式拼接好字符串然后放进去

- **<sstream>** 定义了三个类：istringstream、ostringstream 和 stringstream，分别用来进行流的输入、输出和输入输出操作。其和iostream、fstream类一样，都是系统定义好的一个类

- <sstream> 主要用来进行数据类型转换，由于 <sstream> 使用 string 对象来代替字符数组（snprintf 方式），避免了缓冲区溢出的危险；而且，因为传入参数和目标对象的类型会被自动推导出来，所以不存在错误的格式化符号的问题。简单说，相比 C 编程语言库的数据类型转换，<sstream> 更加安全、自动和直接。

  - snprintf最后保存在char *类型的数据中，stringstream最后保存数据是string类型

- stringstream用法

  - 数据类型转化，将 int 类型转换为 string 类型的过程。string也可以转换为int。snprintf只能存成字符串。

    ```
    stringstream sstream;
    string strResult;
    int nValue = 1000;
    
    // 将int类型的值放入输入流中
    sstream << nValue;
    // 从sstream中抽取前面插入的int类型的值，赋给string类型
    sstream >> strResult;
    
    cout << "[cout]strResult is: " << strResult << endl;
    printf("[printf]strResult is: %s\n", strResult.c_str());
    
    运行结果
    [cout]strResult is：1000
    [printf]strResult is: 1000
    ```

    - 可以看到1000被转换为string类型存放到strResult中
    - cout可以直接输出string类型，printf不能直接输出，需要转换为char *来输出

  - 字符串拼接

    ```
    stringstream sstream;
     
    // 将多个字符串放入 sstream 中
    sstream << "first" << " " << "string,";
    sstream << " second string";
    cout << "strResult is: " << sstream.str() << endl;
     
    // 清空 sstream
    sstream.str("");
    sstream << "third string";
    cout << "After clear, strResult is: " << sstream.str() << endl;
    
    运行结果：
    strResult is: first string， second string
    After clear, strResult is: third string
    ```

    - 可以使用 str() 方法，将 stringstream 类型转换为 string 类型；
    - 可以将多个字符串放入 stringstream 中，实现字符串的拼接目的；
    - 如果想清空 stringstream，必须使用 sstream.str(""); 方式；clear() 方法适用于进行多次数据类型转换的场景

  - 清空 stringstream 有两种方法：clear() 方法以及 str("") 方法，这两种方法对应不同的使用场景。str("") 方法的使用场景，在上面的示例中已经介绍过了，这里介绍 clear() 方法的使用场景。多次数据类型转换必须要用clear，如果不进行数据转换，只是在stringstream中存放数据用str也可以，例如上面

    ```
    stringstream sstream;
    int first, second;
     
    // 插入字符串
    sstream << "456";
    // 转换为int类型
    sstream >> first;
    cout << first << endl;
     
    // 在进行多次类型转换前，必须先运行clear()
    sstream.clear();
     
    // 插入bool值
    sstream << true;
    // 转换为int类型
    sstream >> second;
    cout << second << endl;
    
    输出结果：
    456
    1
    ```

    - 多次数据类型转换，必须使用 clear() 方法清空 stringstream，不使用 clear() 方法或使用 str("") 方法，都不能得到数据类型转换的正确结果，不适用clear结果为 456   4197008，使用str("")结果为456 0

##### 函数默认值问题

- 参数默认值需要在函数原型中声明，但是并不需要在函数定义中指明。
- 如果为函数的某一个参数设置了默认值，那么这个参数后面的所有参数都需要设置默认值。 这个规定应该是为了防止省略函数中间的某一个参数，而导致编译器无法解析的情况。

##### 指针参数和内存的问题

- 如果一个接口返回指针，说明这个接口里面在堆区申请了空间，所以才会返回指针，否则接口就会出错
- 指针作为形参，并不一定要传入指针变量，可以用取地址符来获取地址，指针本身表示的就是地址。所以可以定义一个非指针变量，然后用取地址符来获取地址传入。这样在函数里面也能根据这个指针修改所指向的值
- 指针要有指向，而且指向的要有地址，不能只申请一个指针变量，int * num，然后将这个num指针当作变量传入到函数中，然后在函数中改变指针指向的值。因为num指针没有实际指向的内存，这样就会出现段错误
- 最主要的是不能只申请一个指针变量，要让指针变量指向有内存，所以如果一个函数返回的是指针，我们可以申请一个指针变量来接收这个返回值，这样是正确的，因为函数内部申请了内存，这样我们可以用指针指向这块区域，不会出现段错误。

##### Json

- JSON作为数据传输的格式，有几个显著的优点：

  - JSON只允许使用UTF-8编码，不存在编码问题；
  - JSON只允许使用双引号作为key，特殊字符用`\`转义，格式简单；
  - 浏览器内置JSON支持，如果把数据用JSON发送给浏览器，可以用JavaScript直接处理。

- JSON适合表示层次结构，因为它格式简单，仅支持以下几种数据类型：

  - 键值对：`{"key": value}`
  - 数组：`[1, 2, 3]`
  - 字符串：`"abc"`
  - 数值（整数和浮点数）：`12.34`
  - 布尔值：`true`或`false`
  - 空值：`null`

  ```
  {
      "id": 1,       
      "name": "Java核心技术",
      "author": {
          "firstName": "Abc",
          "lastName": "Xyz"
      },
      "isbn": "1234567",
      "tags": ["Java", "Network"]
  }
  ```

- 在 JSON 中，使用以下两种方式来表示数据：

  - Object（对象）：键/值对（名称/值）的集合，使用花括号`{ }`定义。在每个键/值对中，以键开头，后跟一个冒号`:`，最后是值。多个键/值对之间使用逗号`,`分隔，例如`{"name":"C语言中文网","url":"http://c.biancheng.net"}`；
  - Array（数组）：值的有序集合，使用方括号`[ ]`定义，数组中每个值之间使用逗号`,`进行分隔。

  ```
  {
      "Name":"C语言中文网",
      "Url":"http://c.biancheng.net/",
      "Tutorial":"JSON",
      "Article":[
          "JSON 是什么？",
          "JSONP 是什么？",
          "JSON 语法规则"
      ]
  }
  
  所有 JSON 数据需要包裹在一个花括号中，类似于 JavaScript 中的对象。
  ```

- JSON 数据是以键/值对（名称/值）的形式书写的，键表示数据的名称，需要以字符串的形式定义（在双引号中定义），后面紧跟一个冒号，最后是值

- JSON 中的值可以是以下数据类型：

  - 数字（整数或浮点数）；

  - 字符串（需要在双引号中定义）；

  - 布尔值（true 或 false）；

  - 数组（在方括号中定义）；

  - 对象（在花括号中定义）；

  - null（空）。

    ```
    {
        "number":123,
        "float":3.14,
        "string":"C语言中文网",
        "bool":true,
        "array":[
            "employees",
            {"name":"peter", "age": 18},
            {"name":"Anna", "age": 16}
        ],
        "object":{
            "name":"C语言中文网",
            "url":"http://c.biancheng.net/"
        }
    }
    ```

- 在使用 JSON 时，有以下几点需要注意：

  - JSON 是一段包裹在花括号中的数据，数据由若干键/值对组成；
  - 键和值之间使用冒号分隔；
  - 不同的键/值对之间使用逗号分隔；
  - 键需要以字符串的形式定义（即使用双引号包裹，注意：不能使用单引号）；
  - 值可以是数字、字符串、布尔值、数组、对象、null；
  - 键必须是唯一的，不能重复，否则后定义的键/值对会覆盖前面定义的键/值对；
  - JSON 中不可以使用八进制或十六进制表示数字。

- json数据类型

  - 字符串：JSON 中的字符串需要使用双引号定义（注意：不能使用单引号），字符串中可以包含零个或多个 Unicode 字符。另外，JSON 的字符串中也可以包含一些转义字符，例如：

    - `\\`反斜线本身；

    - `\/`正斜线；

    - `\"`双引号

    - `\b`退格；

    - `\f`换页；

    - `\n`换行；

    - `\r`回车；

    - `\t`水平制表符；

    - `\u`四位的十六进制数字。

      ```
      {
          "name":"C语言中文网",
          "url":"http://c.biancheng.net/",
          "title":"JSON 数据类型"
      }
      ```

  - 数字：JSON 中不区分整型和浮点型，只支持使用 IEEE-754 双精度浮点格式来定义数字。此外，JSON 中不能使用八进制和十六进制表示数字，但可以使用 e 或 E 来表示 10 的指数。

    ```
    {
        "number_1" : 210,
        "number_2" : -210,
        "number_3" : 21.05,
        "number_4" : 1.0E+2
    }
    ```

  - 布尔值：JSON 中的布尔值与 JavaScript、PHP、Java 等编程语言中相似，有两个值，分别为 true（真）和 false（假）

    ```
    {
        "message" : true,
        "pay_succeed" : false
    }
    ```

    

  - 空：null（空）是 JSON 中的一个特殊值，表示没有任何值，当 JSON 中的某些键没有具体值时，就可以将其设置为 null

    ```
    {
        "id" : 1,
        "visibility" : true,
        "popularity" : null
    }
    ```

  - 对象：JSON 中，对象由花括号`{ }`以及其中的若干键/值对组成，一个对象中可以包含零个或多个键/值对，每个键/值对之间需要使用逗号`,`分隔

    ```
    {
        "author": {
            "name": "C语言中文网",
            "url": "http://c.biancheng.net/"
        }
    }
    ```

  - 数组：JSON 中，数组由方括号`[ ]`和其中的若干值组成，值可以是 JSON 中支持的任意类型，每个值之间使用逗号`,`进行分隔

    ```
    {
        "course" : [
            "JSON 教程",
            "JavaScript 教程",
            "HTML 教程",
            {
                "website" : "C语言中文网",
                "url" : "http://c.biancheng.net"
            },
            [
                3.14,
                true
            ],
            null
        ]
    }
    ```

    - 在 JSON 中使用对象类型时，有以下几点需要注意：

      - 对象必须包裹在花括号`{ }`中；
      - 对象中的内容需要以键/值对的形式编写；
      - 键必须是字符串类型，即使用双引号`" "`将键包裹起来；
      - 值可以是任意 JSON 中支持的数据类型（例如字符串、数字、对象、数组、布尔值、null 等）；
      - 键和值之间使用冒号进行分隔；
      - 不同键/值对之间使用逗号进行分隔；
      - 对象中的最后一个键/值对末尾不需要添加逗号。

      ```
      // 键/值对中，键必须使用双引号定义，值若是字符串类型也必须使用双引号定义
      {
          "name": "C语言中文网",
          "age": 18,
          "url": "http://c.biancheng.net/",
          "course": {
              "title": "JSON教程",
              "list": [
                  "JSON是什么？",
                  "JSON语法规则",
                  "JSON数据类型"    // 这个地方不能添加逗号，因为它是数组中最后一个值
              ]    // 这个地方也不能添加逗号，因为它是对象中最后一个键/值对
          }    // 这个地方也不可以有逗号，因为它也是对象的最后一个键/值对
      }
      ```

    - 在 JSON 中使用数组时，有以下几点需要注意：

      - 数组必须使用方括号`[ ]`定义；
      - 数组的内容由若干值组成；
      - 每个值之间需要使用逗号`,`进行分隔；
      - 最后一个值末尾不需要添加逗号；
      - 数组中的值可以是 JSON 中的任何类型，例如字符串、数字、对象、数组、布尔值、null 等。

- json注释：JSON 是一种纯粹的数据交换格式，其简单、灵活的特性使得 JSON 适合被用于各种不同的场景，例如在配置文件中、在接口返回的数据中都会用到 JSON 格式。然而 JSON 却有一个非常明显的缺点，那就是 JSON 不能像编程语言那样添加注释，JSON 中的任何内容都会看作数据的一部分。之所以不允许添加注释，是因为 JSON 主要是用来存储数据的，过多的注释会对数据的可读性造成影响，同时也会造成数据体积变大，进而影响数据传输、解析的速度。

  - 想要在 JSON 中添加注释，我们可以在要添加注释键/值对的前面（或后面）添加一个同名的键，并在键名中添加一个特殊字符加以区分，例如`@`、`#`、`?`、`_`、`/`等，然后在与键对应的值中定义注释的内容。在键名中添加特殊字符时，应尽量避免`:`、`{`、`}`、`[`、`]`等 JSON 中常用的字符。

    ```
    {
        "@name": "网站名称",
        "name": "C语言中文网",
        "_url": "网址",
        "url": "http://c.biancheng.net/",
        "course": "JSON 教程",
        "@charge": "0=收费; 1=免费",
        "charge": 1,
        "#list": "教程目录",
        "list": [
            "JSON数据类型",
            "JSON对象",
            "JSON数组"
        ],
        "message": {
            "code": 0,
            "message": "OK",
            "#data": {
                "#id": "用户ID",
                "#type": "0=正常; 1=异常",
                "#name": "姓名",
                "#createTime": "创建时间(yyyy-MM-dd)"
            },
            "data": {
                "id": "12345",
                "type": 0,
                "name": "我的名字",
                "createTime": "2020-05-20"
            }
        }
    } 
    ```

  - 除了可以在键名中添加特殊字符外，也可以直接以“comment”、“_comment” 或 “__comment”作为键名来定义注释

    ```
    {
        "_comment": "C语言中文网（http://c.biancheng.net/）—— 一个在线学习编程的网站",
        "course": {
            "name": "JSON 教程",
            "url": "http://c.biancheng.net/json/index.html"
        }
    }
    ```

- JSON5 是由开发人员创建并在 GitHub上发布的 JSON 的非官方标准，可以将它看作是 JSON 的升级版。JSON5 主要是通过引入部分 ECMAScript5.1 的特性来扩展 JSON 语法，减少 JSON 的某些限制，同时兼容现有的 JSON 格式。

  - 与 JSON 相比，JSON5 做出了如下改变：
    - 在对象或数组的末尾（即最后一个键/值对或值），可以添加逗号；
    - 字符串可以使用单引号定义；
    - 字符串中可以包含转义字符，并且可以跨越多行；
    - 可以定义十六进制的数字；
    - 数字可以包含前导或后导的小数点；
    - 数字前可以添加一个加、减号来表示正负数；
    - 可以使用`//`来定义单行注释，使用`/* ... */`来定义多行注释。

- JSON 数据可以存储在 .json 格式的文件中（与 .txt 格式类似，都属于纯文本文件），也可以将 JSON 数据以字符串的形式存储在数据库、Cookie、Session 中。
- 与 XML 相比，JSON 具有以下优点：
  - 结构简单、紧凑：与 XML 相比，JSON 遵循简单、紧凑的风格，有利于程序员编辑和阅读，而 XML 相对比较复杂；
  - 更快：JSON 的解析速度比 XML 更快（因为 XML 与 HTML 很像，在解析大型 XML 文件时需要消耗额外的内存），存储同样的数据，JSON 格式所占的存储空间更小；
  - 可读性高：JSON 的结构有利于程序员阅读。
- 任何事物都不可能十全十美，JSON 也不例外，比如：
  - 只有一种数字类型：JSON 中只支持 IEEE-754 双精度浮点格式，因此您无法使用 JSON 来存储许多编程语言中多样化的数字类型；
  - 没有日期类型：在 JSON 中您只能通过日期的字符串（例如：1970-01-01）或者时间戳（例如：1632366361）来表示日期；
  - 没有注释：在 JSON 中无法添加注释；
  - 冗长：虽然 JSON 比 XML 更加简洁，但它并不是最简洁的数据交换格式，对于数据量庞大或用途特殊的服务，您需要使用更加高效的数据格式。

#### 从c到c++

- 类的成员变量称为属性（Property），将类的成员函数称为方法（Method）。

- 为了解决合作开发时的命名冲突问题，[C++](http://c.biancheng.net/cplus/) 引入了命名空间（Namespace）的概念。

  - 
    
    ```c++
    namespace name{
        //variables, functions, classes
    }
    name是命名空间的名字，它里面可以包含变量、函数、类、typedef、#define 等，最后由{ }包围。
    使用变量、函数时要指明它们所在的命名空间。::是一个新符号，称为域解析操作符，在C++中用来指明要使用的命名空间。
    Li::fp = fopen("one.txt", "r");  //使用小李定义的变量 fp
    Han::fp = fopen("two.txt", "rb+");  //使用小韩定义的变量 fp
    
    除了直接使用域解析操作符，还可以采用 using 关键字声明
    using Li::fp;
    fp = fopen("one.txt", "r");  //使用小李定义的变量 fp
    Han :: fp = fopen("two.txt", "rb+");  //使用小韩定义的变量 fp
    在代码的开头用using声明了 Li::fp，它的意思是，using 声明以后的程序中如果出现了未指明命名空间的 fp，就使用 Li::fp；但是若要使用小韩定义的 fp，仍然需要 Han::fp。
      
    using 声明不仅可以针对命名空间中的一个变量，也可以用于声明整个命名空间
    using namespace Li;
    fp = fopen("one.txt", "r");  //使用小李定义的变量 fp
    Han::fp = fopen("two.txt", "rb+");  //使用小韩定义的变量 fp
    ```

- 前置双冒号的含义：这样可以确保从全局命名空间进行解析，而不是从当前所在的命名空间开始。例如，如果您有两个不同的类，称为Configuration，那么：

  ```c
  class Configuration; // class 1, in global namespace
  namespace MyApp
  {
      class Configuration; // class 2, different from class 1
      function blah()
      {
          // resolves to MyApp::Configuration, class 2
          Configuration::doStuff(...)
          // resolves to top-level Configuration, class 1
          ::Configuration::doStuff(...)
      }
  }
  
  基本上，它允许您遍历到全局名称空间，因为您的名称可能会被另一个名称空间内的新定义(在本例中是MyApp)所破坏。
  ```

  - ::运算符被称为作用域解析运算符，仅此而已，它解析作用域。因此，通过在类型名前面加上这个前缀，它告诉编译器在全局命名空间中查找该类型。

    ```c
    int count = 0;
    
    int main(void) {
      int count = 0;
      ::count = 1;  // set global count to 1
      count = 2;    // set local count to 2
      return 0;
    ```

  - 没有在命名空间中定义的变量或者函数就是全局命名空间，在一个命名空间中明确使用全局的变量时，可以使用::来指明是全局的

  - std::cout和::std::cout的区别。只有::std::cout才真正明确你所指的对象，但幸运的是，没有人会创建自己的类/结构或名称空间，称为"std"，也没有人会创建任何称为"cout"的东西，因此在实践中只使用std::cout是可以的。::表示从全局空间中查找，全局空间包含命令空间，所以::std表示全局空间中的std命名空间，这样写比较稳妥，但是直接写std::cout也是正确的

- 和C语言一样，C++ 头文件仍然以`.h`为后缀，它们所包含的类、函数、宏等都是全局范围的。后来 C++ 引入了命名空间的概念，计划重新编写库，将类、函数、宏等都统一纳入一个命名空间，这个命名空间的名字就是`std`。std 是 s[tan](http://c.biancheng.net/ref/tan.html)dard 的缩写，意思是“标准命名空间”。C++ 开发人员想了一个好办法，保留原来的库和头文件，它们在 C++ 中可以继续使用，然后再把原来的库复制一份，在此基础上稍加修改，把类、函数、宏等纳入命名空间 std 下，就成了新版 C++ 标准库。这样共存在了两份功能相似的库，使用了老式 C++ 的程序可以继续使用原来的库，新开发的程序可以使用新版的 C++ 库。

  - 为了避免头文件重名，新版 C++ 库也对头文件的命名做了调整，去掉了后缀`.h`，所以老式 C++ 的`iostream.h`变成了`iostream`，`fstream.h`变成了`fstream`。而对于原来C语言的头文件，也采用同样的方法，但在每个名字前还要添加一个`c`字母，所以C语言的`stdio.h`变成了`cstdio`，`stdlib.h`变成了`cstdlib`。
  - 可以发现，对于不带`.h`的头文件，所有的符号都位于命名空间 std 中，使用时需要声明命名空间 std；对于带`.h`的头文件，没有使用任何命名空间，所有符号都位于全局作用域。这也是 C++ 标准所规定的。
  - 不过现实情况和 C++ 标准所期望的有些不同，对于原来C语言的头文件，即使按照 C++ 的方式来使用，即`#include <cstdio>`这种形式，那么符号可以位于命名空间 std 中，也可以位于全局范围中
  - 将 std 直接声明在所有函数外部，这样虽然使用方便，但在中大型项目开发中是不被推荐的，这样做增加了命名冲突的风险，我推荐在函数内部声明 std。

- cout 和 cin 都是 C++ 的内置对象，而不是关键字。C++ 库定义了大量的类（Class），程序员可以使用它们来创建对象，cout 和 cin 就分别是 ostream 和 istream 类的对象，只不过它们是由标准库的开发者提前创建好的，可以直接拿来使用。这种在 C++ 中提前创建好的对象称为内置对象。

- C89 规定，所有局部变量都必须定义在函数开头，在定义好变量之前不能有其他的执行语句。C99 标准取消这这条限制。取消限制带来的另外一个好处是，可以在 [for 循环](http://c.biancheng.net/view/172.html)的控制语句中定义变量

- 在 C++ 中使用 cout 输出 bool 变量的值时还是用数字 1 和 0 表示，而不是 true 或 false。也可以使用 true 或 false 显式地对 bool 变量赋值

- c++中的const

  ```c
  const int m = 10;
  int n = m;
  在C语言中，编译器会先到 m 所在的内存取出一份数据，再将这份数据赋给 n；而在C++中，编译器会直接将 10 赋给 n，没有读取内存的过程，和int n = 10;的效果一样。C++ 中的常量更类似于#define命令，是一个值替换的过程，只不过#define是在预处理阶段替换，而常量是在编译阶段替换。
  ```

  - C语言对 const 的处理和普通变量一样，会到内存中读取数据；C++ 对 const 的处理更像是编译时期的`#define`，是一个值替换的过程。
  - C语言中的 const 变量在多文件编程时的表现和普通变量一样，除了不能修改，没有其他区别。C++ 对 const 的特性做了调整，C++ 规定，全局 const 变量的作用域仍然是当前文件，但是它在其他文件中是不可见的，这和添加了`static`关键字的效果类似。由于 C++ 中全局 const 变量的可见范围仅限于当前源文件，所以可以将它放在头文件中，这样即使头文件被包含多次也不会出错

- 用 new[] 分配的内存需要用 delete[] 释放

  ```c
  int *p = new int;  //分配1个int型的内存空间
  delete p;  //释放内存
  建议使用 new 和 delete 来管理内存，它们可以使用C++的一些新特性，最明显的是可以自动调用构造函数和析构函数
  ```

- 函数调用是有时间和空间开销的。如果函数体代码比较多，需要较长的执行时间，那么函数调用机制占用的时间可以忽略；如果函数只有一两条语句，那么大部分的时间都会花费在函数调用机制上，这种时间开销就就不容忽视。为了消除函数调用的时空开销，C++ 提供一种提高效率的方法，即在编译时将函数调用处用函数体替换，类似于C语言中的宏展开。这种在函数调用处直接嵌入函数体的函数称为内联函数（Inline Function），又称内嵌函数或者内置函数。指定内联函数的方法很简单，只需要在函数定义处增加 inline 关键字

  - 要在函数定义处添加 inline 关键字，在函数声明处添加 inline 关键字虽然没有错，但这种做法是无效的，编译器会忽略函数声明处的 inline 关键字。

  - 在编写C++代码时我推荐使用内联函数来替换带参数的宏。
  - 和宏一样，内联函数可以定义在头文件中（不用加 static 关键字），并且头文件被多次`#include`后也不会引发重复定义错误。这一点和非内联函数不同，非内联函数是禁止定义在头文件中的，它所在的头文件被多次`#include`后会引发重复定义错误。
  - 内联函数在编译时会将函数调用处用函数体替换，编译完成后函数就不存在了，所以在链接时不会引发重复定义错误。这一点和宏很像，宏在预处理时被展开，编译时就不存在了。从这个角度讲，内联函数更像是编译期间的宏。
  - 内联函数主要有两个作用，一是消除函数调用时的开销，二是取代带参数的宏。不过我更倾向于后者，取代带参数的宏更能凸显内联函数存在的意义。
  - 在多文件编程中，我们通常将函数的定义放在源文件中，将函数的声明放在头文件中，希望调用函数时，引入对应的头文件即可，我们鼓励这种将函数定义和函数声明分开的做法。但这种做法不适用于内联函数，将内联函数的声明和定义分散到不同的文件中会出错
  - 内联函数虽然叫做函数，在定义和声明的语法上也和普通函数一样，但它已经失去了函数的本质。函数是一段可以重复使用的代码，它位于虚拟地址空间中的代码区，也占用可执行文件的体积，而内联函数的代码在编译后就被消除了，不存在于虚拟地址空间中，没法重复使用。
  - 在多文件编程时，我建议将内联函数的定义直接放在头文件中，并且禁用内联函数的声明（声明是多此一举）。

- C++规定，默认参数只能放在形参列表的最后，而且一旦为某个形参指定了默认值，那么它后面的所有形参都必须有默认值。默认参数并非编程方面的重大突破，而只是提供了一种便捷的方式。在以后设计类时你将发现，通过使用默认参数，可以减少要定义的析构函数、方法以及方法重载的数量。

  - C++ 规定，在给定的作用域中只能指定一次默认参数。所以声明和定义中的默认形参要分开

- 函数重载：参数列表不同包括参数的个数不同、类型不同或顺序不同，仅仅参数名称不同是不可以的。函数返回值也不能作为重载的依据。函数重载过程中要避免二义性

#### 类和对象

- 在创建对象时，class 关键字可要可不要，但是出于习惯我们通常会省略掉 class 关键字，但是结构体中的struct在没有typedef的情况下不能省略

- 在栈上和堆上创建类对象

  ```c
  Student stu;
  Student *pStu = &stu;//此时在栈上创建对象
  
  Student *pStu = new Student;
  在栈上创建出来的对象都有一个名字，比如 stu，使用指针指向它不是必须的。但是通过 new 创建出来的对象就不一样了，它在堆上分配内存，没有名字，只能得到一个指向它的指针，所以必须使用一个指针变量来接收这个指针，否则以后再也无法找到这个对象了，更没有办法使用它。也就是说，使用 new 在堆上创建出来的对象是匿名的，没法直接使用，必须要用一个指针指向它，再借助指针来访问它的成员变量或成员函数。
  ```

- 有了对象指针后，可以通过箭头`->`来访问对象的成员变量和成员函数，这和通过[结构体指针](http://c.biancheng.net/view/246.html)来访问它的成员类似
- 类的成员变量和普通变量一样，也有数据类型和名称，占用固定长度的内存。但是，在定义类的时候不能对成员变量赋值，因为类只是一种数据类型或者说是一种模板，本身不占用内存空间，而变量的值则需要内存来存储。
- 在类体中和类体外定义成员函数是有区别的：在类体中定义的成员函数会自动成为内联函数，在类体外定义的不会。当然，在类体内部定义的函数也可以加 inline 关键字，但这是多余的。
- 内联函数一般不是我们所期望的，它会将函数调用处用函数体替代，所以我建议在类体内部对成员函数作声明，而在类体外部进行定义，这是一种良好的编程习惯，实际开发中大家也是这样做的。
- 如果你既希望将函数定义在类体外部，又希望它是内联函数，那么可以在定义函数时加 inline 关键字

##### 类成员的访问权限以及类的封装

- [C++](http://c.biancheng.net/cplus/)通过 public、protected、private 三个关键字来控制成员变量和成员函数的访问权限，它们分别表示公有的、受保护的、私有的，被称为成员访问限定符。所谓访问权限，就是你能不能使用该类中的成员。
- C++ 中的 public、private、protected 只能修饰类的成员，不能修饰类，C++中的类没有共有私有之分。
- 在类的内部（定义类的代码内部），无论成员被声明为 public、protected 还是 private，都是可以互相访问的，没有访问权限的限制。
- 在类的外部（定义类的代码之外），只能通过对象访问成员，并且通过对象只能访问 public 属性的成员，不能访问 private、protected 属性的成员。
- 类的声明和成员函数的定义都是类定义的一部分，在实际开发中，我们通常将类的声明放在头文件中，而将成员函数的定义放在源文件中。
- 成员变量大都以`m_`开头，这是约定成俗的写法，不是语法规定的内容。以`m_`开头既可以一眼看出这是成员变量，又可以和成员函数中的形参名字区分开。
- private 关键字的作用在于更好地隐藏类的内部实现，该向外暴露的接口（能通过对象访问的成员）都声明为 public，不希望外部知道、或者只在类内部使用的、或者对外部没有影响的成员，都建议声明为 private。
- 根据C++软件设计规范，实际项目开发中的成员变量以及只在类内部使用的成员函数（只被成员函数调用的成员函数）都建议声明为 private，而只将允许通过对象调用的成员函数声明为 public。
- 给成员变量赋值的函数通常称为 set 函数，它们的名字通常以`set`开头，后跟成员变量的名字；读取成员变量的值的函数通常称为 get 函数，它们的名字通常以`get`开头，后跟成员变量的名字。
- 声明为 private 的成员和声明为 public 的成员的次序任意，既可以先出现 private 部分，也可以先出现 public 部分。如果既不写 private 也不写 public，就默认为 private。
- 类可以看做是一种复杂的数据类型，也可以使用 sizeof 求得该类型的大小。从运行结果可以看出，在计算类这种类型的大小时，只计算了成员变量的大小，并没有把成员函数也包含在内。对象的大小只受成员变量的影响，和成员函数没有关系。
- 编译器会将成员变量和成员函数分开存储：分别为每个对象的成员变量分配内存，但是所有对象都共享同一段函数代码

##### 类其实也是一种作用域

- 类其实也是一种作用域，每个类都会定义它自己的作用域。在类的作用域之外，普通的成员只能通过对象（可以是对象本身，也可以是对象指针或对象引用）来访问，静态成员既可以通过对象访问，又可以通过类访问，而 typedef 定义的类型只能通过类来访问。

  ```c++
  #include<iostream>
  using namespace std;
  class A{
  public:
      typedef int INT;
      static void show();
      void work();
  };
  void A::show(){ cout<<"show()"<<endl; }
  void A::work(){ cout<<"work()"<<endl; }
  int main(){
      A a;
      a.work();  //通过对象访问普通成员
      a.show();  //通过对象访问静态成员
      A::show();  //通过类访问静态成员
      A::INT n = 10;  //通过类访问 typedef 定义的类型
      return 0;
  }
  ```

- 特别注意typedef定义的类型，如果typedef定义的是一个类，也是通过类来访问。

- 一个类就是一个作用域的事实能够很好的解释为什么我们在类的外部定义成员函数时必须同时提供类名和函数名。在类的外部，类内部成员的名字是不可见的。

- 一旦遇到类名，定义的剩余部分就在类的作用域之内了，这里的剩余部分包括参数列表和函数体。结果就是，我们可以直接使用类的其他成员而无需再次授权了。

  ```c++
  #include<iostream>
  using namespace std;
  class A{
  public:
      typedef char* PCHAR;
  public:
      void show(PCHAR str);
  private:
      int n;
  };
  void A::show(PCHAR str){
      cout<<str<<endl;
      n = 10;
  }
  int main(){
      A obj;
      obj.show("http://c.biancheng.net");
      return 0;
  }
  始终PCHAR不用再次写类了，因为可以用前面的授权。
  ```

  - 我们在定义 show() 函数时用到了类 A 中定义的一种类型 PCHAR，因为前面已经指明了当前正位于 A 类的作用域中，所以不用再使用`A::PCHAR`这样的冗余形式。同理，编译器也知道函数体中用到的变量 n 也位于 A 类的作用域。

  - 另一方面，函数的返回值类型出现在函数名之前，当成员函数定义在类的外部时，返回值类型中使用的名字都位于类的作用域之外，此时必须指明该名字是哪个类的成员。修改上面的 show() 函数，让它的返回值类型为 PCHAR

    ```c++
    PCHAR A::show(PCHAR str){
        cout<<str<<endl;
        n = 10;
        return str;
    }
    这种写法是错误的。因为返回值类型 PCHAR 出现在类名之前，所以事实上它是位于 A 类的作用域之外的。这种情况下要想使用 PCHAR 作为返回值类型，就必须指明哪个类定义了它，正确的写法如下所示：
    A::PCHAR A::show(PCHAR str){
        cout<<str<<endl;
        n = 10;
        return str;
    }
    ```

##### 对象的内存模型

- 类是创建对象的模板，不占用内存空间，不存在于编译后的可执行文件中；而对象是实实在在的数据，需要内存来存储。对象被创建时会在栈区或者堆区分配内存。
- 编译器会将成员变量和成员函数分开存储：分别为每个对象的成员变量分配内存，但是所有对象都共享同一段函数代码
- 类可以看做是一种复杂的数据类型，也可以使用 sizeof 求得该类型的大小。从运行结果可以看出，在计算类这种类型的大小时，只计算了成员变量的大小，并没有把成员函数也包含在内。对象的大小只受成员变量的影响，和成员函数没有关系。
- 成员函数的调用
  - 成员函数最终被编译成与对象无关的全局函数，如果函数体中没有成员变量，那问题就很简单，不用对函数做任何处理，直接调用即可。
  - 如果成员函数中使用到了成员变量该怎么办呢？成员变量的作用域不是全局，不经任何处理就无法在函数内部访问。
  - C++规定，编译成员函数时要额外添加一个参数，把当前对象的指针传递进去，通过指针来访问成员变量。
  - 通过传递对象指针就完成了成员函数和成员变量的关联。这与我们从表明上看到的刚好相反，通过对象调用成员函数时，不是通过对象找函数，而是通过函数找对象。
  - 这一切都是隐式完成的，对程序员来说完全透明，就好像这个额外的参数不存在一样。

##### 构造函数

- 在[C++](http://c.biancheng.net/cplus/)中，有一种特殊的成员函数，它的名字和类名相同，没有返回值，不需要用户显式调用（用户也不能调用），而是在创建对象时自动执行。这种特殊的成员函数就是构造函数（Constructor）。
- 构造函数必须是 public 属性的，否则创建对象时无法调用
- 构造函数没有返回值，因为没有变量来接收返回值，即使有也毫无用处，这意味着：
  - 不管是声明还是定义，函数名前面都不能出现返回值类型，即使是 void 也不允许；
  - 函数体中不能有 return 语句。
  - 构造函数也是在类体内声明，类体外定义
- 和普通成员函数一样，构造函数是允许重载的。一个类可以有多个重载的构造函数，创建对象时根据传递的实参来判断调用哪一个构造函数。
- 构造函数的调用是强制性的，一旦在类中定义了构造函数，那么创建对象时就一定要调用，不调用是错误的。如果有多个重载的构造函数，那么创建对象时提供的实参必须和其中的一个构造函数匹配；反过来说，创建对象时只有一个构造函数会被调用。
- 构造函数在实际开发中会大量使用，它往往用来做一些初始化工作，例如对成员变量赋值、预先打开文件等。
- 如果用户自己没有定义构造函数，那么编译器会自动生成一个默认的构造函数，只是这个构造函数的函数体是空的，也没有形参，也不执行任何操作。
- 一个类必须有构造函数，要么用户自己定义，要么编译器自动生成。一旦用户自己定义了构造函数，不管有几个，也不管形参如何，编译器都不再自动生成。
- 调用没有参数的构造函数也可以省略括号，在栈上创建对象可以写作`Student stu`，不能写括号，写括号是一个函数定义。在堆上创建对象可以写作`Student *pstu = new Student()`或`Student *pstu = new Student`，它们都会调用构造函数 Student()。调用的是默认构造函数。默认构造函数有（）。
- 定义构造函数时并没有在函数体中对成员变量一一赋值，其函数体为空（当然也可以有其他语句），而是在函数首部与函数体之间添加了一个冒号`:`，后面紧跟`m_name(name), m_age(age), m_score(score)`语句，这个语句的意思相当于函数体内部的`m_name = name; m_age = age; m_score = score;`语句，也是赋值的意思。
- 使用构造函数初始化列表并没有效率上的优势，仅仅是书写方便，尤其是成员变量较多时，这种写法非常简单明了。
- 初始化列表可以用于全部成员变量，也可以只用于部分成员变量
- 成员变量的初始化顺序与初始化列表中列出的变量的顺序无关，它只与成员变量在类中声明的顺序有关
- 构造函数初始化列表还有一个很重要的作用，那就是初始化 const 成员变量。初始化 const 成员变量的唯一方法就是使用初始化列表

##### 析构函数

- 创建对象时系统会自动调用构造函数进行初始化工作，同样，销毁对象时系统也会自动调用一个函数来进行清理工作，例如释放分配的内存、关闭打开的文件等，这个函数就是析构函数。
- 析构函数（Destructor）也是一种特殊的成员函数，没有返回值，不需要程序员显式调用（程序员也没法显式调用），而是在销毁对象时自动执行。构造函数的名字和类名相同，而析构函数的名字是在类名前面加一个`~`符号。
- 析构函数没有参数，不能被重载，因此一个类只能有一个析构函数。如果用户没有定义，编译器会自动生成一个默认的析构函数。
- [C++](http://c.biancheng.net/cplus/) 中的 new 和 delete 分别用来分配和释放内存，它们与C语言中 malloc()、free() 最大的一个不同之处在于：用 new 分配内存时会调用构造函数，用 delete 释放内存时会调用析构函数。构造函数和析构函数对于类来说是不可或缺的，所以在C++中我们非常鼓励使用 new 和 delete。
- 析构函数在对象被销毁时调用，而对象的销毁时机与它所在的内存区域有关。在所有函数之外创建的对象是全局对象，它和全局变量类似，位于内存分区中的全局数据区，程序在结束执行时会调用这些对象的析构函数。在函数内部创建的对象是局部对象，它和局部变量类似，位于栈区，函数执行结束时会调用这些对象的析构函数。new 创建的对象位于堆区，通过 delete 删除时才会调用析构函数；如果没有 delete，析构函数就不会被执行。

##### 成员对象和封闭类

- 一个类的成员变量如果是另一个类的对象，就称之为“成员对象”。包含成员对象的类叫封闭类（enclosed class）。

  ```c
  类名::构造函数名(参数表): 成员变量1(参数表), 成员变量2(参数表), ...
  {
      //TODO:
  }
  对于基本类型的成员变量，“参数表”中只有一个值，就是初始值，在调用构造函数时，会把这个初始值直接赋给成员变量。例如int
  但是对于成员对象，“参数表”中存放的是构造函数的参数，它可能是一个值，也可能是多个值，它指明了该成员对象如何被初始化。这个值也是参数表中的值。
  ```

- 封闭类对象生成时，先执行所有成员对象的构造函数，然后才执行封闭类自己的构造函数。成员对象构造函数的执行次序和成员对象在类定义中的次序一致，与它们在构造函数初始化列表中出现的次序无关。
- 当封闭类对象消亡时，先执行封闭类的析构函数，然后再执行成员对象的析构函数，成员对象析构函数的执行次序和构造函数的执行次序相反，即先构造的后析构，这是 C++ 处理此类次序问题的一般规律。

##### this指针

- this 是 [C++](http://c.biancheng.net/cplus/) 中的一个关键字，也是一个 const [指针](http://c.biancheng.net/c/80/)，它指向当前对象，通过它可以访问当前对象的所有成员。所谓当前对象，是指正在使用的对象。例如对于`stu.show();`，stu 就是当前对象，this 就指向 stu。
- this 只能用在类的内部，通过 this 可以访问类的所有成员，包括 private、protected、public 属性的。
- this 是一个指针，要用`->`来访问成员变量或成员函数。
- this 虽然用在类的内部，但是只有在对象被创建以后才会给 this 赋值，并且这个赋值的过程是编译器自动完成的，不需要用户干预，用户也不能显式地给 this 赋值
- this 是 const 指针，它的值是不能被修改的，一切企图修改该指针的操作，如赋值、递增、递减等都是不允许的。
- this 只能在成员函数内部使用，用在其他地方没有意义，也是非法的。
- 只有当对象被创建后 this 才有意义，因此不能在 static 成员函数中使用（后续会讲到 static 成员）。

##### static成员变量和成员函数

- 在[C++](http://c.biancheng.net/cplus/)中，我们可以使用静态成员变量来实现多个对象共享数据的目标。静态成员变量是一种特殊的成员变量，它被关键字`static`修饰

- static 成员变量属于类，不属于某个具体的对象，即使创建多个对象，也只为 m_total 分配一份内存，所有对象使用的都是这份内存中的数据。当某个对象修改了 m_total，也会影响到其他对象。

- static 成员变量必须在类声明的外部初始化type class::name = value;

- static 成员变量既可以通过对象来访问，也可以通过类来访问

- static 成员变量不占用对象的内存，而是在所有对象之外开辟内存，即使不创建对象也可以访问。

- 初始化时可以赋初值，也可以不赋值。如果不赋值，那么会被默认初始化为 0。全局数据区的变量都有默认的初始值 0，而动态数据区（堆区、栈区）变量的默认值是不确定的，一般认为是垃圾值。

- 静态成员变量既可以通过对象名访问，也可以通过类名访问，但要遵循 private、protected 和 public 关键字的访问权限限制

- 在类中，static 除了可以声明[静态成员变量](http://c.biancheng.net/view/2227.html)，还可以声明静态成员函数。普通成员函数可以访问所有成员（包括成员变量和成员函数），静态成员函数只能访问静态成员。

- 编译器在编译一个普通成员函数时，会隐式地增加一个形参 this，并把当前对象的地址赋值给 this，所以普通成员函数只能在创建对象后通过对象来调用，因为它需要当前对象的地址。而静态成员函数可以通过类来直接调用，编译器不会为它增加形参 this，它不需要当前对象的地址，所以不管有没有创建对象，都可以调用静态成员函数。

- 普通成员变量占用对象的内存，静态成员函数没有 this [指针](http://c.biancheng.net/c/80/)，不知道指向哪个对象，无法访问对象的成员变量，也就是说静态成员函数不能访问普通成员变量，只能访问静态成员变量。

- 静态成员函数与普通成员函数的根本区别在于：普通成员函数有 this 指针，可以访问类中的任意成员；而静态成员函数没有 this 指针，只能访问静态成员（包括静态成员变量和静态成员函数）。

- 和静态成员变量类似，静态成员函数在声明时要加 static，在定义时不能加 static。静态成员函数可以通过类来调用（一般都是这样做），也可以通过对象来调用

- 静态成员函数不能访问类里面的非成员变量和非成员函数，所以我们可以在类里面可以定义一个静态成员函数写一个返回静态类对象，然后用静态类对象来访问成员变量，这样整个类对象在程序运行期间都是一样的，这样就不用在用到类时重复声明了。

  ```c++
  class XSecSystem:public XThread
  {
  protected:
  	XUIServer m_uiServer;
  	XAsynWLUpdateThread m_wlUpdateThread;
  	XSecMsgThread m_secMsgThread;
  	XAuditThread m_auditThread;
  	XTaskMgr m_taskMgr;
  	XDataBase m_xdb;
  	XEventEx m_event;
  	SwitchMgr m_switchMgr;
  	
  	static XSecSystem & system();
  	static XDataBase & getXdb();
  	
  XSecSystem & XSecSystem::system()
  {
  	static XSecSystem g_secSystem;//返回一个静态类对象
  	return g_secSystem;
  }
  XDataBase & XSecSystem::getXdb()
  {
  	return system().m_xdb;//getXdb是静态成员函数，system()也是静态成员函数，静态成员函数只能调用静态成员函数和静态成员变量，system返回一个静态对象，所以通过这个对象可以访问这个类里面的成员变量和成员函数，此种设计只是一个跳板
  }
      
  在使用时，XSecSystem::getXdb().db()->QuerySecuritySettings(&arr)
  ```
  
  ```c++
  class XUIMgr
  {
  protected:
      XUIClientOps m_uiOps;
      BOOL __test()
  	{
          return TRUE;
  	}
  	XUIMgr();
  public:
  	virtual ~XUIMgr();
  	static XUIMgr & mgr()
  	{
  		static XUIMgr __mgr;
          return __mgr;
  	}	
      static void log(char * op_username, unsigned int op_class, unsigned int op_time, unsigned int op_result, char * fmtStr, ...);
      XUIClientOps * clientOps()
      {
          return &m_uiOps;
      }
  	static BOOL initialize()
  	{
  		return XUIMgr::mgr().__test();
  	}
  };
  
  XUIMgr::XUIMgr()
  {
  	XUICLIENT_OPS * ops = NULL;
  	ops = createUIClientOps();
  	m_uiOps.setOps(ops);
  	return;
  }
  scheme.h中有extern XUIMgr * g_mgr；
  g_mgr的定义g_mgr = &XUIMgr::mgr();通过静态成员函数来得到一个静态类，然后通过这个静态类在访问类中的成员函数和成员变量
      
  XUIClientOps * client = g_mgr->clientOps();通过g_mgr来访问里面的成员函数clientOps，得到里面的类XUIClientOps，然后调用里面的方法。可以用临时变量client，不用每次用到里面的类就写上g_mgr->clientOps()，这样比较麻烦，虽然每次得到的都是同一个类对象
  ```
  
- 静态对象在编译时就放在了全局静态区，这种方法只是将那个静态对象拿到，方便后续的使用，而且这个静态对象就一个，使用时不用重复定义，拿到这个直接用就可以

- 这样做的好处是持久化了一些我们想要的东西，而且我们想用的就是一个，不会每次都申请一个新的使用，其保存在内存中。不会丢失，除非关闭软件或者断电

- static对象在编译的时候就放到了内存中，在全局静态区，跟运行的时候没什么关系，运行的时候只是使用他

##### const成员变量和成员函数

- const 成员变量的用法和普通 const 变量的用法相似，只需要在声明时加上 const 关键字。初始化 const 成员变量只有一种方法，就是通过构造函数的初始化列表

- const 成员函数可以使用类中的所有成员变量，但是不能修改它们的值，这种措施主要还是为了保护数据而设置的。const 成员函数也称为常成员函数。

- 我们通常将 get 函数设置为常成员函数。读取成员变量的函数的名字通常以`get`开头，后跟成员变量的名字，所以通常将它们称为 get 函数。

- 常成员函数需要在声明和定义的时候在**函数头部的结尾**加上 const 关键字

  ```c
  char *getname() const;
  char * Student::getname() const{}
  ```

- 最后再来区分一下 const 的位置：

  - 函数开头的 const 用来修饰函数的返回值，表示返回值是 const 类型，也就是不能被修改，例如`const char * getname()`。
  - 函数头部的结尾加上 const 表示常成员函数，这种函数只能读取成员变量的值，而不能修改成员变量的值，例如`char * getname() const`。

- 在 [C++](http://c.biancheng.net/cplus/) 中，const 也可以用来修饰对象，称为常对象。一旦将对象定义为常对象之后，就只能调用类的 const 成员（包括 const 成员变量和 const 成员函数）了。

  ```c
  const  class  object(params);
  一旦将对象定义为常对象之后，不管是哪种形式，该对象就只能访问被 const 修饰的成员了（包括 const 成员变量和 const 成员函数），因为非 const 成员可能会修改对象的数据（编译器也会这样假设），C++禁止这样做。
  ```

##### 友员函数和友员类

- 在 [C++](http://c.biancheng.net/cplus/) 中，一个类中可以有 public、protected、private 三种属性的成员，通过对象可以访问 public 成员，只有本类中的函数可以访问本类的 private 成员。现在，我们来介绍一种例外情况——友元（friend）。借助友元（friend），可以使得其他类中的成员函数以及全局范围内的函数访问当前类的 private 成员。
- 在当前类以外定义的、不属于当前类的函数也可以在类中声明，但要在前面加 friend 关键字，这样就构成了友元函数。友元函数可以是不属于任何类的非成员函数，也可以是其他类的成员函数。
- 友元函数可以访问当前类中的所有成员，包括 public、protected、private 属性的。
- 友元函数不同于类的成员函数，在友元函数中不能直接访问类的成员，必须要借助对象
- 成员函数在调用时会隐式地增加 this [指针](http://c.biancheng.net/c/80/)，指向调用它的对象，从而使用该对象的成员；而 show() 是非成员函数，没有 this 指针，编译器不知道使用哪个对象的成员，要想明确这一点，就必须通过参数传递对象（可以直接传递对象，也可以传递对象指针或对象引用），并在访问成员时指明对象。
-  一个函数可以被多个类声明为友元函数，这样就可以访问多个类中的 private 成员。
- 不仅可以将一个函数声明为一个类的“朋友”，还可以将整个类声明为另一个类的“朋友”，这就是友元类。友元类中的所有成员函数都是另外一个类的友元函数。
- 关于友元，有两点需要说明：
  - 友元的关系是单向的而不是双向的。如果声明了类 B 是类 A 的友元类，不等于类 A 是类 B 的友元类，类 A 中的成员函数不能访问类 B 中的 private 成员。
  - 友元的关系不能传递。如果类 B 是类 A 的友元类，类 C 是类 B 的友元类，不等于类 C 是类 A 的友元类。
- 除非有必要，一般不建议把整个类声明为友元类，而只将某些成员函数声明为友元函数，这样更安全一些。

#### 引用

- 参数的传递本质上是一次赋值的过程，赋值就是对内存进行拷贝。所谓内存拷贝，是指将一块内存上的数据复制到另一块内存上。

- 对于像 char、bool、int、float 等基本类型的数据，它们占用的内存往往只有几个字节，对它们进行内存拷贝非常快速。而数组、结构体、对象是一系列数据的集合，数据的数量没有限制，可能很少，也可能成千上万，对它们进行频繁的内存拷贝可能会消耗很多时间，拖慢程序的执行效率。

- C/[C++](http://c.biancheng.net/cplus/) 禁止在函数调用时直接传递数组的内容，而是强制传递数组指针。而对于结构体和对象没有这种限制，调用函数时既可以传递指针，也可以直接传递内容；为了提高效率，我曾建议传递指针

- C++ 中，我们有了一种比指针更加便捷的传递聚合类型数据的方式，那就是引用（Reference）

- 引用（Reference）是 C++ 相对于C语言的又一个扩充。引用可以看做是数据的一个别名，通过这个别名和原来的名字都能够找到这份数据。

- 引用必须在定义的同时初始化，并且以后也要从一而终，不能再引用其它数据，这有点类似于常量（const 变量）。

- 引用在定义时需要添加`&`，在使用时不能添加`&`，使用时添加`&`表示取地址

- 不希望通过引用来修改原始的数据，那么可以在定义时添加 const 限制

  ```c
  const type &name = value;
  或者
  type const &name = value;
  只有指针有顶层和底层的说法，引用没有
  ```

- 引用作为函数参数：在定义或声明函数时，我们可以将函数的形参指定为引用的形式，这样在调用函数时就会将实参和形参绑定在一起，让它们都指代同一份数据。如此一来，如果在函数体中修改了形参的数据，那么实参的数据也会被修改，从而拥有“在函数内部影响函数外部数据”的效果。

- 按引用传参在使用形式上比指针更加直观。在以后的 C++ 编程中，我鼓励读者大量使用引用，它一般可以代替指针（当然指针在C++中也不可或缺），C++ 标准库也是这样做的。

- 引用作为函数返回值：在将引用作为函数返回值时应该注意一个小问题，就是不能返回局部数据（例如局部变量、局部对象、局部数组等）的引用，因为当函数调用完成后局部数据就会被销毁，有可能在下次使用时数据就不存在了，C++ 编译器检测到该行为时也会给出警告。int &func(){}

- 变量是要占用内存的，虽然我们称 r 为变量，但是通过`&r`获取到的却不是 r 的地址，而是 a 的地址，这会让我们觉得 r 这个变量不占用独立的内存，它和 a 指代的是同一份内存。int &r = a;

- 其实引用只是对指针进行了简单的封装，它的底层依然是通过指针实现的，引用占用的内存和指针占用的内存长度一样，在 32 位环境下是 4 个字节，在 64 位环境下是 8 个字节，之所以不能获取引用的地址，是因为编译器进行了内部转换

  ```
  int a = 99;
  int &r = a;
  r = 18;
  cout<<&r<<endl;
  编译时会被转换成如下的形式：
  int a = 99;
  int *r = &a;
  *r = 18;
  cout<<r<<endl;
  使用&r取地址时，编译器会对代码进行隐式的转换，使得代码输出的是 r 的内容（a 的地址），而不是 r 的地址，这就是为什么获取不到引用变量的地址的原因。也就是说，不是变量 r 不占用内存，而是编译器不让获取它的地址。
  ```

  

- C++ 的发明人 Bjarne Stroustrup 也说过，他在 C++ 中引入引用的直接目的是为了让代码的书写更加漂亮，尤其是在[运算符重载](http://c.biancheng.net/cpp/biancheng/cpp/rumen_10/)中，不借助引用有时候会使得运算符的使用很麻烦。

- 引用必须在定义时初始化，并且以后也要从一而终，不能再指向其他数据；而指针没有这个限制，指针在定义时不必赋值，以后也能指向任意数据。

- 可以有 const 指针，但是没有 const 引用

- 指针可以有多级，但是引用只能有一级

- 指针和引用的自增（++）自减（--）运算意义不一样。对指针使用 ++ 表示指向下一份数据，对引用使用 ++ 表示它所指代的数据本身加 1；自减（--）也是类似的道理

- 其实 C++ 代码中的大部分内容都是放在内存中的，例如定义的变量、创建的对象、字符串常量、函数形参、函数体本身、`new`或`malloc()`分配的内存等，这些内容都可以用`&`来获取地址，进而用指针指向它们。除此之外，还有一些我们平时不太留意的临时数据，例如表达式的结果、函数的返回值等，它们可能会放在内存中，也可能会放在寄存器中。一旦它们被放到了寄存器中，就没法用`&`获取它们的地址了，也就没法用指针指向它们了。

- 寄存器离 CPU 近，并且速度比内存快，将临时数据放到寄存器是为了加快程序运行。但是寄存器的数量是非常有限的，容纳不下较大的数据，所以只能将较小的临时数据放在寄存器中。int、double、bool、char 等基本类型的数据往往不超过 8 个字节，用一两个寄存器就能存储，所以这些类型的临时数据通常会放到寄存器中；而对象、结构体变量是自定义类型的数据，大小不可预测，所以这些类型的临时数据通常会放到内存中。

- 诸如 100、200+34、34.5*23、3+7/3 等不包含变量的表达式称为常量表达式（Constant expression）。常量表达式由于不包含变量，没有不稳定因素，所以在编译阶段就能求值。编译器不会分配单独的内存来存储常量表达式的值，而是将常量表达式的值和代码合并到一起，放到虚拟地址空间中的代码区。从汇编的角度看，常量表达式的值就是一个立即数，会被“硬编码”到指令中，不能寻址。

- 在 GCC 下，引用不能指代任何临时数据，不管它保存到哪里；

  ```c
  int m = 100, n = 36;
      int &r1 = m + n;
      int &r2 = m + 28;
  这些代码是错误的，引用不能指代临时数据，m+n在函数内产生的数据是临时数据
  ```

- 参数是引用类型，只能传递变量，不能传递常量或者表达式

- 引用不能绑定到临时数据，这在大多数情况下是正确的，但是当使用 const 关键字对引用加以限定后，引用就可以绑定到临时数据了。这是因为将常引用绑定到临时数据时，编译器采取了一种妥协机制：编译器会为临时数据创建一个新的、无名的临时变量，并将临时数据放入该临时变量中，然后再将引用绑定到该临时变量。注意，临时变量也是变量，所有的变量都会被分配内存。**const** int &r1 = m + n;

- 我们知道，将引用绑定到一份数据后，就可以通过引用对这份数据进行操作了，包括读取和写入（修改）；尤其是写入操作，会改变数据的值。而临时数据往往无法寻址，是不能写入的，即使为临时数据创建了一个临时变量，那么修改的也仅仅是临时变量里面的数据，不会影响原来的数据，这样就使得引用所绑定到的数据和原来的数据不能同步更新，最终产生了两份不同的数据，失去了引用的意义。

  ```c
  void swap(int &r1, int &r2){
      int temp = r1;
      r1 = r2;
      r2 = temp;
  }
  如果编译器会为 r1、r2 创建临时变量，那么函数调用swap(10, 20)就是正确的，但是 10 不会变成 20，20 也不会变成 10，所以这种调用是毫无意义的。所以引用形参传进去的是变量，不能为常量。
    总起来说，不管是从“引用的语义”这个角度看，还是从“实际应用的效果”这个角度看，为普通引用创建临时变量都没有任何意义，所以编译器不会这么做。
  ```

- const 引用和普通引用不一样，我们只能通过 const 引用读取数据的值，而不能修改它的值，所以不用考虑同步更新的问题，也不会产生两份不同的数据，为 const 引用创建临时变量反而会使得引用更加灵活和通用。

  ```c
  bool isOdd(const int &n){  //改为常引用
      if(n/2 == 0){
          return false;
      }else{
          return true;
      }
  }
  由于在函数体中不会修改 n 的值，所以可以用 const 限制 n，这样一来，下面的函数调用就都是正确的了：
  int a = 100;
  isOdd(a);  //正确
  isOdd(a + 9);  //正确
  isOdd(27);  //正确
  ```

- 概括起来说，将引用类型的形参添加 const 限制的理由有三个：
  - 使用 const 可以避免无意中修改数据的编程错误；
  - 使用 const 能让函数接收 const 和非 const 类型的实参，否则将只能接收非 const 类型的实参；
  - 使用 const 引用能够让函数正确生成并使用临时变量。
- 当引用的类型和数据的类型不一致时，如果它们的类型是相近的，并且遵守「数据类型的自动转换」规则，那么编译器就会创建一个临时变量，并将数据赋值给这个临时变量（这时候会发生自动类型转换），然后再将引用绑定到这个临时的变量，这与「将 const 引用绑定到临时数据时」采用的方案是一样的。否则不能引用类型不同的数据。
- 总结起来说，给引用添加 const 限定后，不但可以将引用绑定到临时数据，还可以将引用绑定到类型相近的数据，这使得引用更加灵活和通用，它们背后的机制都是临时变量。

#### 嵌套类和局部类

- 嵌套类 ：在一个类的内部定义另一个类，我们称之为嵌套类（nested class），或者嵌套类型。之所以引入这样一个嵌套类，往往是因为外围类需要使用嵌套类对象作为底层实现，并且该嵌套类只用于外围类的实现，且同时可以对用户隐藏该底层实现。例如迭代器就是通过嵌套类来实现的。

  - 一个类可以定义在另一个类的内部，前者称为嵌套类，嵌套类是一个独立的类，和外层类基本没什么关系,它通过提供新的类型类作用域来避免名称混乱

  - 嵌套类必须声明在类的内部，但是可以定义在类的内部或者外部。在外层类之外定义一个嵌套类时，必须以外层类的名字限定嵌套类的名字。

  - 嵌套类的名字只在外围类可见。

  - 类的私有成员只有类的成员和友元可以访问，因此外围类不可以访问嵌套类的私有成员。嵌套类可以访问外围类的成员（通过对象、指针或者引用）。

  - 一个好的嵌套类设计：嵌套类应该设成私有。嵌套类的成员和方法可以设为 public 。

  - 嵌套类可以直接访问外围类的静态成员、类型名（ typedef ）、枚举值。

  - 如果嵌套类声明在一个类的私有部分，则只有嵌套类的外部类可以知道它。上面的类就是这种情况。

    如果嵌套类声明在一个类的保护部分，对于后者是可见的，对于外界是不可见的。派生类知道该嵌套类，并且可以直接创建这种类型的对象。

    如果嵌套类声明在一个类的公有部分，则允许后者，后者的派生类以及外部世界使用。然后在外部使用时，必须加上外部类的外部类作用域限制符,如： 使用NestedClass 时，应该这样定义 OutClass::NestedClass nestedInstance

  - 嵌套结构和枚举的作用域于此相同。许多程序员使用公有的枚举提供客户使用的类常量。

  - 在外部类中声明嵌套类并没有赋予外部类任何对嵌套类的访问权限，也没有赋予任何嵌套类对于外部类的访问权限。与一般类的访问控制相同（私有，公有，保护）。

  - 虽然嵌套类在外围类内部定义，但它是一个独立的类，基本上与外围类不相关。它的成员不属于外围类，同样，外围类的成员也不属于该嵌套类。嵌套类的出现只是告诉外围类有一个这样的类型成员供外围类使用。并且，外围类对嵌套类成员的访问没有任何特权，嵌套类对外围类成员的访问也同样如此，它们都遵循普通类所具有的标号访问控制。

  - 若不在嵌套类内部定义其成员，则其定义只能写到与外围类相同的作用域中，且要用外围类进行限定，不能把定义写在外围类中。例如，嵌套类的静态成员就是这样的一个例子。

  - 嵌套类可以直接引用外围类的静态成员、类型名和枚举成员（假定这些成员是公有的）。类型名是一个typedef名字、枚举类型名、或是一个类名。

    ![](https://img-blog.csdnimg.cn/20190612192718712.png)

- 嵌套类主要注意权限和定义时要写上外层类即可，因为类本身也是一种作用域，例如在类A中有一个类B

  ```c++
  class A {
  private：
  	class B；
  	B * m_b;
  }
  
  class A::B {
  
  }
  
  这个嵌套类B如果只是一个前向声明，并没有完整的定义，后续我们只能定义一个指针或者引用，如果class B在这里直接写的完整的定义就可以创建类的对象了。
  后面可以先定义完class B,然后在用到m_b的时候，new一个B就可以使用了，就可以用这个指针访问类里面的方法和属性了。
  ```

  - 嵌套类一般声明为私有的，可以在头文件中声明这个类，class就代表声明，这个和使用B的对象不一样，这个是声明一个类。头文件中声明好要定义这个类时，要写上外层类A，说明这个类B在类A的作用域内。
  - 在比如类B里面有一个方法，我们只是定义这个方法时要A::B::foo,不能直接写B::foo

- 前向声明。在C++中，类需要先定义（类的定义就是指完整的类，就是我们平常写的class A，里面写上方法和属性），而后才能被实例化，但是实际存在一种场景是：两个类需要相互引用或相互成为类中的子对象成员时，就无法先定义使用，在编译环节就出现错误导致编译失败，这时就需要用到前向声明，此外，前向声明的类不能被实例化

  - 类似于函数的声明和定义，C++里类的声明和定义也是可以分开的。我们可以先声明而暂时不定义它，这种声明就称为类的前置声明。`class Screen`，这个前置声明在代码里引入了名字Screen，并指示Screen是一个类类型。对于类类型Screen来说，在它声明之后定义之前是一个不完全类型，所谓不完全类型就是我们知道Screen是一个类类型，但是我们不知道它到底包含了哪些成员。
  - 不完全类型只能在非常有限的情况下使用：
    1. 只能定义指向这种不完全类型的指针或引用
    2. 只能声明（但是不可以定义）以不完全类型作为参数或者返回类型的函数
    3. 定义一个类对象是完整的知道里面的方法和属性，而定义一个指针和引用，不需要知道完整的类。在后续知道类的完整定义后，可以直接new一个，让指针指向类。
  - 前向声明的好处
    - 节约编译时间，我们平时在写代码时会使用#include来包含其他头文件，然后调用这个头文件提供的一些类，如果该头文件里包含了很多其他没有被使用到的类，那么编译时会被一起编译，这样就会浪费一些不必要的时间，而使用前置声明，编译器就只编译我们需要用到的类，这样就会节约一点编译时间
    - 处理两个类相互依赖的问题，假设有两个类，叫A和B，如果A里要用到B的成员函数，B里要用到A的成员函数，如果每一个头文件里面都引用另一个头文件，就会产生循环依赖。改用前置声明，就会避免这样的问题，不过写法有一定的限制，只能定义指针或引用，而且不能通过指针或引用来调用类的方法，因为此时该类类型是不完全类型，还不知道里面定义了哪些方法。
  - 类前置声明的坏处
    - 前置声明隐藏了依赖关系，头文件改动时，用户的代码会跳过必要的重新编译过程。
    - 前置声明可能会被库的后续更改所破坏。前置声明函数或模板有时会妨碍头文件开发者变动其 API.例如扩大形参类型，加个自带默认参数的模板形参等等。
    - 前置声明来自命名空间std:: 的 symbol 时，其行为未定义。
    - 很难判断什么时候该用前置声明，什么时候该用 #include 。极端情况下，用前置声明代替 includes 甚至都会暗暗地改变代码的含义.
  - 类的前置声明既有优点又有缺点，我们使用时可以根据具体情况去选择。这里再引用下Google C++ Style里的关于前置声明的使用说明，

    - 尽量避免前置声明那些定义在其他项目中的实体.
    - 函数：总是使用#include.
    - 类模板：优先使用#include
  - 但是如果出现类的互相依赖，使用前置声明还是一个比较好的解决办法，或者通过重新对类进行设计，来避免互相依赖。

#### 继承与派生

- 继承可以理解为一个类从另一个类获取成员变量和成员函数的过程。例如类 B 继承于类 A，那么 B 就拥有 A 的成员变量和成员函数。
- 以下是两种典型的使用继承的场景：
  -  当你创建的新类与现有的类相似，只是多出若干成员变量或成员函数时，可以使用继承，这样不但会减少代码量，而且新类会拥有基类的所有功能。
  - 当你需要创建多个类，它们拥有很多相似的成员变量或成员函数时，也可以使用继承。可以将这些类的共同成员提取出来，定义为基类，然后从基类继承，既可以节省代码，也方便后续修改成员。

##### 三种继承方式

- 继承方式包括 public（公有的）、private（私有的）和 protected（受保护的），此项是可选的，如果不写，那么默认为 private
- 继承方式限定了基类成员在派生类中的访问权限，类成员的访问权限由高到低依次为 public --> protected --> private，我们在《[C++类成员的访问权限以及类的封装](http://c.biancheng.net/view/2217.html)》一节中讲解了 public 和 private：public 成员可以通过对象来访问，private 成员不能通过对象访问。
- protected 成员和 private 成员类似，也不能通过对象访问。但是当存在继承关系时，protected 和 private 就不一样了：基类中的 protected 成员可以在派生类中使用，而基类中的 private 成员不能在派生类中使用
- **public继承方式**
  - 基类中所有 public 成员在派生类中为 public 属性；
  - 基类中所有 protected 成员在派生类中为 protected 属性；
  - 基类中所有 private 成员在派生类中不能使用。
- **protected继承方式**
  - 基类中的所有 public 成员在派生类中为 protected 属性；
  - 基类中的所有 protected 成员在派生类中为 protected 属性；
  - 基类中的所有 private 成员在派生类中不能使用。
- **private继承方式**
  - 基类中的所有 public 成员在派生类中均为 private 属性；
  - 基类中的所有 protected 成员在派生类中均为 private 属性；
  - 基类中的所有 private 成员在派生类中不能使用。
- 基类成员在派生类中的访问权限不得高于继承方式中指定的权限。例如，当继承方式为 protected 时，那么基类成员在派生类中的访问权限最高也为 protected，高于 protected 的会降级为 protected，但低于 protected 不会升级。再如，当继承方式为 public 时，那么基类成员在派生类中的访问权限将保持不变。也就是说，继承方式中的 public、protected、private 是用来指明基类成员在派生类中的最高访问权限的。
- 不管继承方式如何，基类中的 private 成员在派生类中始终不能使用（不能在派生类的成员函数中访问或调用）。
- 由于 private 和 protected 继承方式会改变基类成员在派生类中的访问权限，导致继承关系复杂，所以实际开发中我们一般使用 public。
- 在派生类中访问基类 private 成员的唯一方法就是借助基类的非 private 成员函数，如果基类没有非 private 成员函数，那么该成员在派生类中将无法访问。

##### 继承时名字遮蔽问题

- 如果派生类中的成员（包括成员变量和成员函数）和基类中的成员重名，那么就会遮蔽从基类继承过来的成员。所谓遮蔽，就是在派生类中使用该成员（包括在定义派生类时使用，也包括通过派生类对象访问该成员）时，实际上使用的是派生类新增的成员，而不是从基类继承来的。
- 基类成员和派生类成员的名字一样时会造成遮蔽，这句话对于成员变量很好理解，对于成员函数要引起注意，不管函数的参数如何，只要名字一样就会造成遮蔽。换句话说，基类成员函数和派生类成员函数不会构成重载，如果派生类有同名函数，那么就会遮蔽基类中的所有同名函数，不管它们的参数是否一样。

##### 基类和派生类的构造函数

- 前面我们说基类的成员函数可以被继承，可以通过派生类的对象访问，但这仅仅指的是普通的成员函数，类的构造函数不能被继承。构造函数不能被继承是有道理的，因为即使继承了，它的名字和派生类的名字也不一样，不能成为派生类的构造函数，当然更不能成为普通的成员函数。

- 在设计派生类时，对继承过来的成员变量的初始化工作也要由派生类的构造函数完成，但是大部分基类都有 private 属性的成员变量，它们在派生类中无法访问，更不能使用派生类的构造函数来初始化。

- 这种矛盾在[C++](http://c.biancheng.net/cplus/)继承中是普遍存在的，解决这个问题的思路是：在派生类的构造函数中调用基类的构造函数。

  ```c
  Student::Student(char *name, int age, float score): People(name, age), m_score(score){ } //People(name, age)就是调用基类的构造函数，并将 name 和 age 作为实参传递给它，m_score(score)是派生类的参数初始化表，它们之间以逗号,隔开。
  也可以将基类构造函数的调用放在参数初始化表后面，但是不管它们的顺序如何，派生类构造函数总是先调用基类构造函数再执行其他代码（包括参数初始化表以及函数体中的代码）
  ```

- 派生类构造函数中只能调用直接基类的构造函数，不能调用间接基类的。C++ 这样规定是有道理的，因为我们在 C 中调用了 B 的构造函数，B 又调用了 A 的构造函数，相当于 C 间接地（或者说隐式地）调用了 A 的构造函数，如果再在 C 中显式地调用 A 的构造函数，那么 A 的构造函数就被调用了两次，相应地，初始化工作也做了两次，这不仅是多余的，还会浪费CPU时间以及内存，毫无益处，所以 C++ 禁止在 C 中显式地调用 A 的构造函数。 

- 通过派生类创建对象时必须要调用基类的构造函数，这是语法规定。换句话说，定义派生类构造函数时最好指明基类构造函数；如果不指明，就调用基类的默认构造函数（不带参数的构造函数）；如果没有默认构造函数，那么编译失败。请看下面的例子：

- 和构造函数类似，析构函数也不能被继承。与构造函数不同的是，在派生类的析构函数中不用显式地调用基类的析构函数，因为每个类只有一个析构函数，编译器知道如何选择，无需程序员干涉。

- 另外析构函数的执行顺序和构造函数的执行顺序也刚好相反：

  - 创建派生类对象时，构造函数的执行顺序和继承顺序相同，即先执行基类构造函数，再执行派生类构造函数。
  - 而销毁派生类对象时，析构函数的执行顺序和继承顺序相反，即先执行派生类析构函数，再执行基类析构函数。

##### 向上转型

- 类其实也是一种数据类型，也可以发生数据类型转换，不过这种转换只有在基类和派生类之间才有意义，并且只能将派生类赋值给基类，包括将派生类对象赋值给基类对象、将派生类[指针](http://c.biancheng.net/c/80/)赋值给基类指针、将派生类引用赋值给基类引用，这在 C++ 中称为向上转型（Upcasting）。相应地，将基类赋值给派生类称为向下转型（Downcasting）。
- A 是基类， B 是派生类，a、b 分别是它们的对象，由于派生类 B 包含了从基类 A 继承来的成员，因此可以将派生类对象 b 赋值给基类对象 a。通过运行结果也可以发现，赋值后 a 所包含的成员变量的值已经发生了变化。
- 赋值的本质是将现有的数据写入已分配好的内存中，对象的内存只包含了成员变量，所以对象之间的赋值是成员变量的赋值，成员函数不存在赋值问题。运行结果也有力地证明了这一点，虽然有`a=b;`这样的赋值过程，但是 a.display() 始终调用的都是 A 类的 display() 函数。换句话说，对象之间的赋值不会影响成员函数，也不会影响 this 指针。虽然调用的成员函数不会变，但是成员函数里面调用的成员变量的值是会变化的。
- 将派生类对象赋值给基类对象时，会舍弃派生类新增的成员
- 这种转换关系是不可逆的，只能用派生类对象给基类对象赋值，而不能用基类对象给派生类对象赋值。理由很简单，基类不包含派生类的成员变量，无法对派生类的成员变量赋值。同理，同一基类的不同派生类对象之间也不能赋值。
- 将派生类指针赋值给基类指针。与对象变量之间的赋值不同的是，对象指针之间的赋值并没有拷贝对象的成员，也没有修改对象本身的数据，仅仅是改变了指针的指向。
  - 将派生类指针赋值给基类指针时，通过基类指针只能使用派生类的成员变量，但不能使用派生类的成员函数
  - 编译器虽然通过指针的指向来访问成员变量，但是却不通过指针的指向来访问成员函数：编译器通过指针的类型来访问成员函数。对于 pa，它的类型是 A，不管它指向哪个对象，使用的都是 A 类的成员函数
  - 编译器通过指针来访问成员变量，指针指向哪个对象就使用哪个对象的数据；编译器通过指针的类型来访问成员函数，指针属于哪个类的类型就使用哪个类的函数。

#### 多态与虚函数

- “多态（polymorphism）”指的是同一名字的事物可以完成不同的功能。多态可以分为编译时的多态和运行时的多态。前者主要是指函数的重载（包括运算符的重载）、对重载函数的调用，在编译时就能根据实参确定应该调用哪个函数，因此叫编译时的多态；而后者则和继承、虚函数等概念有关，是本章要讲述的内容。本教程后面提及的多态都是指运行时的多态。

- 通过基类指针只能访问派生类的成员变量，但是不能访问派生类的成员函数。此处说的是从基类继承下来的成员变量可以访问，派生类单独声明的成员变量是不可以访问的，因为内存模型的关系，从基类继承下来的变量所占空间和基类是相同的，所以基类访问的成员变量就是访问派生类的成员变量，但是单独声明的不可以
- 为了消除这种尴尬，让基类指针能够访问派生类的成员函数，[C++](http://c.biancheng.net/cplus/) 增加了**虚函数（Virtual Function）**。使用虚函数非常简单，只需要在函数声明前面增加 virtual 关键字。
- 有了虚函数，基类指针指向基类对象时就使用基类的成员（包括成员函数和成员变量），指向派生类对象时就使用派生类的成员。换句话说，基类指针可以按照基类的方式来做事，也可以按照派生类的方式来做事，它有多种形态，或者说有多种表现方式，我们将这种现象称为**多态（Polymorphism）**。
- 多态是面向对象编程的主要特征之一，C++中虚函数的唯一用处就是构成多态。
- C++提供多态的目的是：可以通过基类指针对所有派生类（包括直接派生和间接派生）的成员变量和成员函数进行“全方位”的访问，尤其是成员函数。如果没有多态，我们只能访问成员变量。
- 引用在本质上是通过指针的方式实现的，既然借助指针可以实现多态，那么我们就有理由推断：借助引用也可以实现多态。
- 不过引用不像指针灵活，指针可以随时改变指向，而引用只能指代固定的对象，在多态性方面缺乏表现力，所以以后我们再谈及多态时一般是说指针。本例的主要目的是让读者知道，除了指针，引用也可以实现多态。
- 虚函数的注意事项：
  - 只需要在虚函数的声明处加上 virtual 关键字，函数定义处可以加也可以不加。
  - 为了方便，你可以只将基类中的函数声明为虚函数，这样所有派生类中具有遮蔽关系的同名函数都将自动成为虚函数
  - 当在基类中定义了虚函数时，如果派生类没有定义新的函数来遮蔽此函数，那么将使用基类的虚函数。
  - 只有派生类的虚函数覆盖基类的虚函数（函数原型相同）才能构成多态（通过基类[指针](http://c.biancheng.net/c/80/)访问派生类函数）。例如基类虚函数的原型为`virtual void func();`，派生类虚函数的原型为`virtual void func(int);`，那么当基类指针 p 指向派生类对象时，语句`p -> func(100);`将会出错，而语句`p -> func();`将调用基类的函数。
  - 构造函数不能是虚函数。对于基类的构造函数，它仅仅是在派生类构造函数中被调用，这种机制不同于继承。也就是说，派生类不继承基类的构造函数，将构造函数声明为虚函数没有什么意义。
  - 析构函数可以声明为虚函数，而且有时候必须要声明为虚函数
- 构成多态的条件：
  - 必须存在继承关系；
  - 继承关系中必须有同名的虚函数，并且它们是覆盖关系（函数原型相同）。
  - 存在基类的指针，通过该指针调用虚函数。

##### 虚析构函数

- 构造函数不能是虚函数，因为派生类不能继承基类的构造函数，将构造函数声明为虚函数没有意义。

- C++ 中的构造函数用于在创建对象时进行初始化工作，在执行构造函数之前对象尚未创建完成，虚函数表尚不存在，也没有指向虚函数表的指针，所以此时无法查询虚函数表，也就不知道要调用哪一个构造函数。

- 本例中定义了两个类，基类 Base 和派生类 Derived，它们都有自己的构造函数和析构函数。在构造函数中，会分配 100 个 char 类型的内存空间；在析构函数中，会把这些内存释放掉。pb、pd 分别是基类指针和派生类指针，它们都指向派生类对象，最后使用 delete 销毁 pb、pd 所指向的对象。

  ```c
  Base *pb = new Derived();
  delete pb;
  cout<<"-------------------"<<endl;
  Derived *pd = new Derived();
  delete pd;
  从运行结果可以看出，语句delete pb;只调用了基类的析构函数，没有调用派生类的析构函数；而语句delete pd;同时调用了派生类和基类的析构函数。
  不调用派生类的析构函数会导致 name 指向的 100 个 char 类型的内存空间得不到释放；除非程序运行结束由操作系统回收，否则就再也没有机会释放这些内存。这是典型的内存泄露。
  
  ```

  - 为什么`delete pb;`不会调用派生类的析构函数呢？因为这里的析构函数是非虚函数，通过指针访问非虚函数时，编译器会根据指针的类型来确定要调用的函数；也就是说，指针指向哪个类就调用哪个类的函数，这在前面的章节中已经多次强调过。pb 是基类的指针，所以不管它指向基类的对象还是派生类的对象，始终都是调用基类的析构函数。
  - 为什么`delete pd;`会同时调用派生类和基类的析构函数呢？pd 是派生类的指针，编译器会根据它的类型匹配到派生类的析构函数，在执行派生类的析构函数的过程中，又会调用基类的析构函数。派生类析构函数始终会调用基类的析构函数，并且这个过程是隐式完成的

- 在实际开发中，一旦我们自己定义了析构函数，就是希望在对象销毁时用它来进行清理工作，比如释放内存、关闭文件等，如果这个类又是一个基类，那么我们就必须将该析构函数声明为虚函数，否则就有内存泄露的风险。也就是说，大部分情况下都应该将基类的析构函数声明为虚函数。析构函数正常写就可以，不用写成一样的名字。每个类的析构函数就是～类名。系统会自动调用子类的析构函数。例如上面示例，此时pd可以声明为Base *pd = new Derived();此时一样会调用子类的构造函数。上面示例中没有用虚析构函数，所以那样写。

##### 纯虚函数和抽象类

- 可以将虚函数声明为纯虚函数，语法格式为  ： virtual 返回值类型 函数名 (函数参数) = 0;
- 包含纯虚函数的类称为抽象类（Abstract Class）。之所以说它抽象，是因为它无法实例化，也就是无法创建对象。原因很明显，纯虚函数没有函数体，不是完整的函数，无法调用，也无法为其分配内存空间。
- 抽象类通常是作为基类，让派生类去实现纯虚函数。派生类必须实现纯虚函数才能被实例化。
- 通过抽象基类的指针可以指向子类。类似于向上转型。虽然抽象基类不能被实例，但是仍然能定义指针。

##### 虚函数表

- 编译器之所以能通过指针指向的对象找到虚函数，是因为在创建对象时额外地增加了虚函数表。
- 如果一个类包含了虚函数，那么在创建该类的对象时就会额外地增加一个数组，数组中的每一个元素都是虚函数的入口地址。不过数组和对象是分开存储的，为了将对象和数组关联起来，编译器还要在对象中安插一个指针，指向数组的起始位置。这里的数组就是虚函数表（Virtual function table），简写为`vtable`。

#### 运算符重载

- 实际上，我们已经在不知不觉中使用了运算符重载。例如，`+`号可以对不同类型（int、float 等）的数据进行加法操作；`<<`既是位移运算符，又可以配合 cout 向控制台输出数据。[C++](http://c.biancheng.net/cplus/) 本身已经对这些运算符进行了重载。

- 运算符重载其实就是定义一个函数，在函数体内实现想要的功能，当用到该运算符时，编译器会自动调用这个函数。也就是说，运算符重载是通过函数实现的，它本质上是函数重载。

  ```c
  返回值类型 operator 运算符名称 (形参表列){
      //TODO:
  }
  operator是关键字，专门用于定义重载运算符的函数。我们可以将operator 运算符名称这一部分看做函数名，对于上面的代码，函数名就是operator+。
  ```

- 运算符重载函数除了函数名有特定的格式，其它地方和普通函数并没有区别。

- 定义复数类，通过运算符重载，用+实现复数的加法运算

  ```c
  #include <iostream>
  using namespace std;
  class complex{
  public:
      complex();
      complex(double real, double imag);
  public:
      //声明运算符重载
      complex operator+(const complex &A) const;
      void display() const;
  private:
      double m_real;  //实部
      double m_imag;  //虚部
  };
  complex::complex(): m_real(0.0), m_imag(0.0){ }
  complex::complex(double real, double imag): m_real(real), m_imag(imag){ }
  //实现运算符重载
  complex complex::operator+(const complex &A) const{
      complex B;
      B.m_real = this->m_real + A.m_real;
      B.m_imag = this->m_imag + A.m_imag;
      return B;
  }
  void complex::display() const{
      cout<<m_real<<" + "<<m_imag<<"i"<<endl;
  }
  int main(){
      complex c1(4.3, 5.8);
      complex c2(2.4, 3.7);
      complex c3;
      c3 = c1 + c2;
      c3.display();
      return 0;
  }//运行结果6.7 + 9.5i
  在上面的类中实现operate+成员函数的时候，定义了一个对象complex B；最后返回return B；这是可以的且正确的，类似于定义了一个int a；最后return a；这是完全正确的。我们说的临时变量是针对指针和引用来说的，因为临时变量随着函数的调用结束会释放，最后指针和引用找不到实际的地址，就会出错。但是其他的一些数据类型能返回且能让函数接收，相当于用临时数据为变量赋值。int a = 10；此时变量a里面的值就是10，不用去通过地址在找10。
  
  我们在 complex 类中重载了运算符+，该重载只对 complex 对象有效。当执行c3 = c1 + c2;语句时，编译器检测到+号左边（+号具有左结合性，所以先检测左边）是一个 complex 对象，就会调用成员函数operator+()，也就是转换为下面的形式
    c3 = c1.operator+(c2);
  
  更加简练的形式
    complex complex::operator+(const complex &A)const{
      return complex(this->m_real + A.m_real, this->m_imag + A.m_imag);
  }
  return 语句中的complex(this->m_real + A.m_real, this->m_imag + A.m_imag)会创建一个临时对象，这个对象没有名称，是一个匿名对象。在创建临时对象过程中调用构造函数，return 语句将该临时对象作为函数返回值。
  
  ```

- 运算符重载函数不仅可以作为类的成员函数，还可以作为全局函数。更改上面的代码，在全局范围内重载`+`，实现复数的加法运算：

  ```c
  friend complex operator+(const complex &A, const complex &B);
  全局函数要在类中声明为友元函数。运算符重载函数不是 complex 类的成员函数，但是却用到了 complex 类的 private 成员变量，所以必须在 complex 类中将该函数声明为友元函数。
  complex operator+(const complex &A, const complex &B){
      complex C;
      C.m_real = A.m_real + B.m_real;
      C.m_imag = A.m_imag + B.m_imag;
      return C;
  }
  
  当执行c3 = c1 + c2;语句时，编译器检测到+号两边都是 complex 对象，就会转换为类似下面的函数调用：
  c3 = operator+(c1, c2);
  ```

- 虽然运算符重载所实现的功能完全可以用函数替代，但运算符重载使得程序的书写更加人性化，易于阅读。运算符被重载后，原有的功能仍然保留，没有丧失或改变。通过运算符重载，扩大了C++已有运算符的功能，使之能用于对象。

##### 运算符重载的规则

- 并不是所有的运算符都可以重载。能够重载的运算符包括：
  \+ - * / % ^ & | ~ ! = < > += -= *= /= %= ^= &= |=  << >> <<= >>= == != <= >= && || ++ -- , ->* -> () []  new new[] delete delete[]

  - 上述运算符中，`[]`是下标运算符，`()`是函数调用运算符。自增自减运算符的前置和后置形式都可以重载。长度运算符`sizeof`、条件运算符`: ?`、成员选择符`.`和域解析运算符`::`不能被重载。

- 重载不能改变运算符的优先级和结合性

- 重载不会改变运算符的用法，原有有几个操作数、操作数在左边还是在右边，这些都不会改变。例如`~`号右边只有一个操作数，`+`号总是出现在两个操作数之间，重载后也必须如此。

- 运算符重载函数不能有默认的参数，否则就改变了运算符操作数的个数，这显然是错误的。

- 运算符重载函数既可以作为类的成员函数，也可以作为全局函数。将运算符重载函数作为类的成员函数时，二元运算符的参数只有一个，一元运算符不需要参数。之所以少一个参数，是因为这个参数是隐含的。

- 将运算符重载函数作为全局函数时，二元操作符就需要两个参数，一元操作符需要一个参数，而且其中必须有一个参数是对象，好让编译器区分这是程序员自定义的运算符，防止程序员修改用于内置类型的运算符的性质。

  ```c
  int operator + (int a,int b){
      return (a-b);
  }
  +号原来是对两个数相加，现在企图通过重载使它的作用改为两个数相减， 如果允许这样重载的话，那么表达式4+3的结果是 7 还是 1 呢？显然，这是绝对禁止的。
  如果有两个参数，这两个参数可以都是对象，也可以一个是对象，一个是C ++内置类型的数据
  complex operator+(int a, complex &c){
      return complex(a+c.real, c.imag);
  }
  ```

- 箭头运算符`->`、下标运算符`[ ]`、函数调用运算符`( )`、赋值运算符`=`只能以成员函数的形式重载。

##### 重载数学运算符

- 示例

  ```c
  Complex operator+(const Complex &c1, const Complex &c2){
      Complex c;
      c.m_real = c1.m_real + c2.m_real;
      c.m_imag = c1.m_imag + c2.m_imag;
      return c;
  }全局函数重载+
  
  Complex & Complex::operator+=(const Complex &c){
      this->m_real += c.m_real;
      this->m_imag += c.m_imag;
      return *this;
  }成员函数重载+=
  ```

- 在上节的例子中，我们以全局函数的形式重载了 +、-、*、/、==、!=，以成员函数的形式重载了 +=、-=、*=、/=，而没有一股脑都写成全局函数或者成员函数，这样做是有原因的

- 转换构造函数

  ```c
  class Complex{
  public:
      Complex(): m_real(0.0), m_imag(0.0){ }
      Complex(double real, double imag): m_real(real), m_imag(imag){ }
      Complex(double real): m_real(real), m_imag(0.0){ }  //转换构造函数
      friend Complex operator+(const Complex &c1, const Complex &c2);
      
   Complex c3 = 28.23 + c1;这句话是正确的。
   它说明 Complex 类型可以和 double 类型相加，这很奇怪，因为我们并没有对针对这两个类型重载 +，这究竟是怎么做到的呢？
   其实，编译器在检测到 Complex 和 double（小数默认为 double 类型）相加时，会先尝试将 double 转换为 Complex，或者反过来将 Complex 转换为 double（只有类型相同的数据才能进行 + 运算），如果都转换失败，或者都转换成功（产生了二义性），才报错。本例中，编译器会先通过构造函数Complex(double real);将 double 转换为 Complex，再调用重载过的 + 进行计算，整个过程类似于下面的形式：
   也就是说，小数被转换成了匿名的 Complex 对象。在这个转换过程中，构造函数Complex(double real);起到了至关重要的作用，如果没有它，转换就会失败，Complex 也不能和 double 相加。
   Complex(double real);在作为普通构造函数的同时，还能将 double 类型转换为 Complex 类型，集合了“构造函数”和“类型转换”的功能，所以被称为「转换构造函数」。换句话说，转换构造函数用来将其它类型（可以是 bool、int、double 等基本类型，也可以是数组、指针、结构体、类等构造类型）转换为当前类类型。
  ```

- 为什么要以全局函数的形式重载+，我们定义的`operator+`是一个全局函数（一个友元函数），而不是成员函数，这样做是为了保证 + 运算符的操作数能够被对称的处理；换句话说，小数（double 类型）在 + 左边和右边都是正确的。

  - 如果将`operator+`定义为成员函数，根据“+ 运算符具有左结合性”这条原则，`Complex c2 = c1 + 15.6;`会被转换为下面的形式：Complex c2 = c1.operator+(Complex(15.6));这就是通过对象调用成员函数，是正确的。而对于`Complex c3 = 28.23 + c1;`，编译器会尝试转换为不同的形式：Complex c3 = (28.23).operator+(c1);很显然这是错误的，因为 double 类型并没有以成员函数的形式重载 +。也就是说，以成员函数的形式重载 +，只能计算`c1 + 15.6`，不能计算`28.23 + c1`，这是不对称的

  - 编译器明明可以把 28.23 先转换成 Complex 类型再相加呀，也就是下面的形式：Complex c3 = Complex(28.23).operator+(c1);

    为什么就是不转换呢？没错，编译器不会转换，原因在于，C++ 只会对成员函数的参数进行类型转换，而不会对调用成员函数的对象进行类型转换。

- 为什么要以成员函数的形式重载+=。我们首先要明白，运算符重载的初衷是给类添加新的功能，方便类的运算，它作为类的成员函数是理所应当的，是首选的。不过，类的成员函数不能对称地处理数据，程序员必须在（参与运算的）所有类型的内部都重载当前的运算符。以上面的情况为例，我们必须在 Complex 和 double 内部都重载 + 运算符，这样做不但会增加运算符重载的数目，还要在许多地方修改代码，这显然不是我们所希望的

  - 采用全局函数能使我们定义这样的运算符，它们的参数具有逻辑的对称性。与此相对应的，把运算符定义为成员函数能够保证在调用时对第一个（最左的）运算对象不出现类型转换，也就是上面提到的「C++ 不会对调用成员函数的对象进行类型转换」。

- C++ 规定，箭头运算符`->`、下标运算符`[ ]`、函数调用运算符`( )`、赋值运算符`=`只能以成员函数的形式重载。

##### 重载<<和>>

- 在[C++](http://c.biancheng.net/cplus/)中，标准库本身已经对左移运算符`<<`和右移运算符`>>`分别进行了重载，使其能够用于不同数据的输入输出，但是输入输出的对象只能是 C++ 内置的数据类型（例如 bool、int、double 等）和标准库所包含的类类型（例如 string、complex、ofstream、ifstream 等）。

- 如果我们自己定义了一种新的数据类型，需要用输入输出运算符去处理，那么就必须对它们进行重载。本节以前面的 complex 类为例来演示输入输出运算符的重载。

- 要达到的目标是让复数的输入输出和 int、float 等基本类型一样简单。假设 num1、num2 是复数，那么输出形式就是：cout << num1 << num2 << endl;输入形式cin >> num1 >> num2;

- cout 是 ostream 类的对象，cin 是 istream 类的对象，要想达到这个目标，就必须以全局函数（友元函数）的形式重载`<<`和`>>`，否则就要修改标准库中的类，这显然不是我们所期望的。

- 重载输入运算符

  ```
  istream & operator>>(istream &in, complex &A){
      in >> A.m_real >> A.m_imag;
      return in;
  }以全局函数的形式重载>>，使它能够读入两个 double 类型的数据，并分别赋值给复数的实部和虚部
  istream 表示输入流，cin 是 istream 类的对象，只不过这个对象是在标准库中定义的。之所以返回 istream 类对象的引用，是为了能够连续读取复数
  
  参数列表中istream &in理解：运算符两边是对象，此时只是声明一个对象，因为cin是类istream的对象，所以在运行时将cin绑定上去。istream就是一个类，在这种写法中，跟其他的类一样，最后是要绑定对象的，cin是istream的对象。
  ```

  - 当输入`1.45 2.34↙`后，这两个小数就分别成为对象 c 的实部和虚部了。`cin>> c;`这一语句其实可以理解为：operator<<(cin , c);
  - 理解：以前>>操作符只能输入标准类型的数据，现在如果是自定义类型的话，此时调用重载的运算符，就会执行里面的语句，现在的语句是in >> A.m_real >> A.m_imag;相当于运行了一个操作符>>就实现了写多个数据的功能，但是这个在外面看是一样的。只是一个操作符，但是功能增强了。但是在键盘上输入时要写上两个数字，理解为原来cin>>a;假设a是一个int形的，此时我们在键盘上输入一个int形数据就可以，系统就会读入，这是内核实现的。如果a为一个复杂类型。里面需要几个数据我们就需要从键盘上输入几个数据，此时都会读入到a复杂类型里面。从代码看还是一句cin>>a,但是读入的数据都进入里面了。
  - 在运行时cin>>A,系统检测到A的类型就会去调用明确类型A里面的重载运算符。

- 重载输出运算符

  ```c
  ostream & operator<<(ostream &out, complex &A){
      out << A.m_real <<" + "<< A.m_imag <<" i ";
      return out;
  }
  
  我们在写代码时cout << a;a为复数类的一个对象，此时系统就会调用复数类里面的重载运算符<<，然后根据重载运算符里面的代码实现内容。我们只是cout << a,但是我们输出了我们想要的内容，这就是运算符重载。
  ```

- 运算符重载就是按我们的想法去干一些东西，当我们调用运算符时就是执行代码里面的东西，运算符两边都是对象，所以形参里面参与运算的对象。这两个参数最后就是操作符两边的对象。

##### 重载[]

- [C++](http://c.biancheng.net/cplus/) 规定，下标运算符`[ ]`必须以成员函数的形式进行重载。该重载函数在类中的声明格式如下：

  ```c
  返回值类型 & operator[ ] (参数);
  
  或者：
  
  const 返回值类型 & operator[ ] (参数) const;
  
  使用第一种声明方式，[ ]不仅可以访问元素，还可以修改元素。使用第二种声明方式，[ ]只能访问而不能修改元素。在实际开发中，我们应该同时提供以上两种形式，这样做是为了适应 const 对象，因为通过 const 对象只能调用 const 成员函数，如果不提供第二种形式，那么将无法访问 const 对象的任何元素。
  ```

- 重载[]只是为了访问数组，没有别的功能，其返回值也是数组的元素。

  ```c
  int& Array::operator[](int i){
      return m_p[i];
  } //m_p是指针
  
  const int & Array::operator[](int i) const{
      return m_p[i];
  }  //返回值是通过指针操作数组里面的值，返回。
  ```

- 重载的形式是上面的形式，在实际使用时i在括号里面arr[i]，此时会转换为arr.operator\[ ](i);

##### 重载++和--

```c
stopwatch operator++();  //++i，前置形式
stopwatch operator++(int);//i++，后置形式  stoppwatch是类名

stopwatch stopwatch::operator++(int n){
    stopwatch s = *this;
    run();
    return s;
}//运算符重载会直接调用整个步骤，不会只调用一部分，解释在后面。在后置自增时，先保存当前值，然后自增，在将保存的值返回去。在下次使用时，变量自增了，此时在将当前值保存起来，然后再自增，在返回保存的值，这样就能达到先使用当前值然后再自增的效果。
```

- operator++() 函数实现自增的前置形式，直接返回 run() 函数运行结果即可。
- operator++ (int n) 函数实现自增的后置形式，返回值是对象本身，但是之后再次使用该对象时，对象自增了，所以在该函数的函数体中，先将对象保存，然后调用一次 run() 函数，之后再将先前保存的对象返回。在这个函数中参数n是没有任何意义的，它的存在只是为了区分是前置形式还是后置形式。

##### 重载new和delete

- 内存管理运算符 new、new[]、delete 和 delete[] 也可以进行重载，其重载形式既可以是类的成员函数，也可以是全局函数。一般情况下，内建的内存管理运算符就够用了，只有在需要自己管理内存时才会重载。
- 如果类中没有定义 new 和 delete 的重载函数，那么会自动调用内建的 new 和 delete 运算符。

##### 重载()

- 在 [C++](http://c.biancheng.net/cplus/) 中，类型的名字（包括类的名字）本身也是一种运算符，即类型强制转换运算符。

- 类型强制转换运算符是单目运算符，也可以被重载，但只能重载为成员函数，不能重载为全局函数。经过适当重载后，`(类型名)对象`这个对对象进行强制类型转换的表达式就等价于`对象.operator 类型名()`，即变成对运算符函数的调用。

  ```c
  class Complex
  {
      double real, imag;
  public:
      Complex(double r = 0, double i = 0) :real(r), imag(i) {};
      operator double() { return real; }  //重载强制类型转换运算符 double
  };
  int main()
  {
      Complex c(1.2, 3.4);
      cout << (double)c << endl;  //输出 1.2
      double n = 2 + c;  //等价于 double n = 2 + c. operator double()
      cout << n;  //输出 3.2
  }
  ```

##### 注意事项

- 必要时需要重载赋值运算符=，以避免两个对象内部的[指针](http://c.biancheng.net/c/80/)指向同一片存储空间。
- <<和>>是在 iostream 中被重载，才成为所谓的“流插入运算符”和“流提取运算符”的。
- 类型的名字可以作为强制类型转换运算符，也可以被重载为类的成员函数。它能使得对象被自动转换为某种类型。

#### 面向对象进阶

##### 拷贝构造函数

- 严格来说，对象的创建包括两个阶段，首先要分配内存空间，然后再进行初始化：

  - 分配内存很好理解，就是在堆区、栈区或者全局数据区留出足够多的字节。这个时候的内存还比较“原始”，没有被“教化”，它所包含的数据一般是零值或者随机值，没有实际的意义。
  - 初始化就是首次对内存赋值，让它的数据有意义。注意是首次赋值，再次赋值不叫初始化。初始化的时候还可以为对象分配其他的资源（打开文件、连接网络、动态分配内存等），或者提前进行一些计算（根据价格和数量计算出总价、根据长度和宽度计算出矩形的面积等）等。说白了，初始化就是调用构造函数。

- 很明显，这里所说的拷贝是在初始化阶段进行的，也就是用其它对象的数据来初始化新对象的内存。

- 当以拷贝的方式初始化一个对象时，会调用一个特殊的构造函数，就是拷贝构造函数（Copy Constructor）。

  ```c
  Student(const Student &stu);  //拷贝构造函数（声明）
  
  //拷贝构造函数（定义）
  Student::Student(const Student &stu){
      this->m_name = stu.m_name;
      this->m_age = stu.m_age;
      this->m_score = stu.m_score;
  }
  
  Student stu1("小明", 16, 90.5);
  Student stu2 = stu1;  //调用拷贝构造函数
  Student stu3(stu1);  //调用拷贝构造函数
  等于号和小括号都是调用拷贝构造函数，这其中仅限于在初始化时是这样的。如果赋值的话用=就是调用赋值构造函数，赋值构造函数是用重载=来实现的
  ```

- 拷贝构造函数只有一个参数，它的类型是当前类的引用，而且一般都是 const 引用。

- 为什么必须是当前类的引用：如果拷贝构造函数的参数不是当前类的引用，而是当前类的对象，那么在调用拷贝构造函数时，会将另外一个对象直接传递给形参，这本身就是一次拷贝，会再次调用拷贝构造函数，然后又将一个对象直接传递给了形参，将继续调用拷贝构造函数……这个过程会一直持续下去，没有尽头，陷入死循环。

- 为什么是const引用：拷贝构造函数的目的是用其它对象的数据来初始化当前对象，并没有期望更改其它对象的数据，添加 const 限制后，这个含义更加明确了。另外一个原因是，添加 const 限制后，可以将 const 对象和非 const 对象传递给形参了，因为非 const 类型可以转换为 const 类型。如果没有 const 限制，就不能将 const 对象传递给形参，因为 const 类型不能转换为非 const 类型，这就意味着，不能使用 const 对象来初始化当前对象了。

- 默认拷贝构造函数：如果程序员没有显式地定义拷贝构造函数，那么编译器会自动生成一个默认的拷贝构造函数。这个默认的拷贝构造函数很简单，就是使用“老对象”的成员变量对“新对象”的成员变量进行一一赋值。对于简单的类，默认拷贝构造函数一般是够用的，我们也没有必要再显式地定义一个功能类似的拷贝构造函数。但是当类持有其它资源时，如动态分配的内存、打开的文件、指向其他数据的[指针](http://c.biancheng.net/c/80/)、网络连接等，默认拷贝构造函数就不能拷贝这些资源，我们必须显式地定义拷贝构造函数，以完整地拷贝对象的所有数据

##### 到底什么时候会调用拷贝构造函数

- 当以拷贝的方式初始化对象时会调用拷贝构造函数。这里有两个关键点，分别是「以拷贝的方式」和「初始化对象」。

- 初始化对象是指，为对象分配内存后第一次向内存中填充数据，这个过程会调用构造函数。对象被创建后必须立即被初始化，换句话说，只要创建对象，就会调用构造函数。

- 初始化和赋值都是将数据写入内存中，并且从表面上看起来，初始化在很多时候都是以赋值的方式来实现的，所以很容易混淆

  ```c
  int a = 100;  //以赋值的方式初始化
  a = 200;  //赋值
  a = 300;  //赋值
  int b;  //默认初始化
  b = 29;  //赋值
  b = 39;  //赋值
  ```

  - 在定义的同时进行赋值叫做初始化（Initialization），定义完成以后再赋值（不管在定义的时候有没有赋值）就叫做赋值（Assignment）。初始化只能有一次，赋值可以有多次。
  - 对于基本类型的数据，我们很少会区分「初始化」和「赋值」这两个概念，即使将它们混淆，也不会出现什么错误。但是对于类，它们的区别就非常重要了，因为初始化时会调用构造函数（以拷贝的方式初始化时会调用拷贝构造函数），而赋值时会调用重载过的赋值运算符。

- 在实际编程中，具体有哪些情况是以拷贝的方式来初始化对象

  - 将其他对象作为实参

    ```c
    Student stu1("小明", 16, 90.5);  //普通初始化
    Student stu2(stu1);  //以拷贝的方式初始化
    ```

  - 在创建对象的时候同时赋值

    ```c
    Student stu1("小明", 16, 90.5);  //普通初始化
    Student stu2 = stu1;  //以拷贝的方式初始化
    ```

  - 函数的形参为类类型

    ```c
    如果函数的形参为类类型（也就是一个对象），那么调用函数时要将另外一个对象作为实参传递进来赋值给形参，这也是以拷贝的方式初始化形参对象
    void func(Student s){
        //TODO:
    }
    Student stu("小明", 16, 90.5);  //普通初始化
    func(stu);  //以拷贝的方式初始化
    //func() 函数有一个 Student 类型的形参 s，将实参 stu 传递给形参 s 就是以拷贝的方式初始化的过程。
    ```

  - 函数返回值为类类型

    ```c
    当函数的返回值为类类型时，return 语句会返回一个对象，不过为了防止局部对象被销毁，也为了防止通过返回值修改原来的局部对象，编译器并不会直接返回这个对象，而是根据这个对象先创建出一个临时对象（匿名对象），再将这个临时对象返回。而创建临时对象的过程，就是以拷贝的方式进行的，会调用拷贝构造函数。
    Student func(){
        Student s("小明", 16, 90.5);
        return s;
    }
    Student stu = func();
    理论上讲，运行代码后会调用两次拷贝构造函数，一次是返回 s 对象时，另外一次是创建 stu 对象时。
    在较老的编译器上，你或许真的能够看到调用两次拷贝构造函数，例如 iPhone 上的 C/C++ 编译器。但是在现代编译器上，只会调用一次拷贝构造函数，或者一次也不调用，例如在 VS2010 下会调用一次拷贝构造函数，在 GCC、Xcode 下一次也不会调用。这是因为，现代编译器都支持返回值优化技术，会尽量避免拷贝对象，以提高程序运行效率
    ```

##### 深拷贝和浅拷贝

- 对于基本类型的数据以及简单的对象，它们之间的拷贝非常简单，就是按位复制内存

- 对于简单的类，默认的拷贝构造函数一般就够用了，我们也没有必要再显式地定义一个功能类似的拷贝构造函数。但是当类持有其它资源时，例如动态分配的内存、指向其他数据的[指针](http://c.biancheng.net/c/80/)等，默认的拷贝构造函数就不能拷贝这些资源了，我们必须显式地定义拷贝构造函数，以完整地拷贝对象的所有数据。

  ```c
  Array::Array(const Array &arr){  //拷贝构造函数
      this->m_len = arr.m_len;
      this->m_p = (int*)calloc( this->m_len, sizeof(int) );
      memcpy( this->m_p, arr.m_p, m_len * sizeof(int) );
  }
  本例中我们显式地定义了拷贝构造函数，它除了会将原有对象的所有成员变量拷贝给新对象，还会为新对象再分配一块内存，并将原有对象所持有的内存也拷贝过来。这样做的结果是，原有对象和新对象所持有的动态内存是相互独立的，更改一个对象的数据不会影响另外一个对象，本例中我们更改了 arr2 的数据，就没有影响 arr1。
  ```

- 这种将对象所持有的其它资源一并拷贝的行为叫做深拷贝，我们必须显式地定义拷贝构造函数才能达到深拷贝的目的。

- 深拷贝的例子比比皆是，除了上面的变长数组类，我们在《[C++ throw关键字](http://c.biancheng.net/view/2332.html)》一节中使用的动态数组类也需要深拷贝；此外，标准模板库（[STL](http://c.biancheng.net/stl/)）中的 string、vector、stack、set、map 等也都必须使用深拷贝。

- 浅拷贝中就是将指针地址直接赋值了，导致两个对象指向了同一块空间。所以一个对象的操作会影响另一个对象。

- 如果一个类拥有指针类型的成员变量，那么绝大部分情况下就需要深拷贝，因为只有这样，才能将指针指向的内容再复制出一份来，让原有对象和新生对象相互独立，彼此之间不受影响。如果类的成员变量没有指针，一般浅拷贝足以。

- 另外一种需要深拷贝的情况就是在创建对象时进行一些预处理工作，比如统计创建过的对象的数目、记录对象创建的时间等

##### 重载=赋值运算符

- 在定义的同时进行赋值叫做初始化（Initialization），定义完成以后再赋值（不管在定义的时候有没有赋值）就叫做赋值（Assignment）。初始化只能有一次，赋值可以有多次。

- 当以拷贝的方式初始化一个对象时，会调用拷贝构造函数；当给一个对象赋值时，会调用重载过的赋值运算符。

- 即使我们没有显式的重载赋值运算符，编译器也会以默认地方式重载它。默认重载的赋值运算符功能很简单，就是将原有对象的所有成员变量一一赋值给新对象，这和默认拷贝构造函数的功能类似。

- 对于简单的类，默认的赋值运算符一般就够用了，我们也没有必要再显式地重载它。但是当类持有其它资源时，例如动态分配的内存、打开的文件、指向其他数据的[指针](http://c.biancheng.net/c/80/)、网络连接等，默认的赋值运算符就不能处理了，我们必须显式地重载它，这样才能将原有对象的所有数据都赋值给新对象。

  ```c
  Array &Array::operator=(const Array &arr){  //重载赋值运算符
      if( this != &arr){  //判断是否是给自己赋值
          this->m_len = arr.m_len;
          free(this->m_p);  //释放原来的内存
          this->m_p = (int*)calloc( this->m_len, sizeof(int) );
          memcpy( this->m_p, arr.m_p, m_len * sizeof(int) );
      }
      return *this;
  }operator=() 的返回值类型为Array &，这样不但能够避免在返回数据时调用拷贝构造函数，还能够达到连续赋值的目的。下面的语句就是连续赋值
    if( this != &arr)语句的作用是「判断是否是给同一个对象赋值」：如果是，那就什么也不做；如果不是，那就将原有对象的所有成员变量一一赋值给新对象，并为新对象重新分配内存
      return *this表示返回当前对象（新对象）。
  operator=() 的形参类型为const Array &，这样不但能够避免在传参时调用拷贝构造函数，还能够同时接收 const 类型和非 const 类型的实参
  ```

- 当我们决定是否要为一个类显式地定义拷贝构造函数和赋值运算符时，一个基本原则是首先确定这个类是否需要一个析构函数。通常，对析构函数的需求要比拷贝构造函数和赋值运算符的需求更加明显。如果一个类需要定义析构函数，那么几乎可以肯定这个类也需要一个拷贝构造函数和一个赋值运算符。

- Array 类就是一个典型的例子。这个类在构造函数中动态地分配了一块内存，并用一个成员变量（指针变量）指向它，默认的析构函数不会释放这块内存，所以我们需要显式地定义一个析构函数来释放内存。

- 如果一个类需要一个拷贝构造函数，几乎可以肯定它也需要一个赋值运算符；反之亦然。然而，无论需要拷贝构造函数还是需要复制运算符，都不必然意味着也需要析构函数。

##### 转换构造函数

- C++ 允许我们自定义类型转换规则，用户可以将其它类型转换为当前类类型，也可以将当前类类型转换为其它类型。这种自定义的类型转换规则只能以类的成员函数的形式出现，换句话说，这种转换规则只适用于类。

- 将其它类型转换为当前类类型需要借助转换构造函数（Conversion constructor）。转换构造函数也是一种构造函数，它遵循构造函数的一般规则。转换构造函数只有一个参数。

- `Complex(double real);`就是转换构造函数，它的作用是将 double 类型的参数 real 转换成 Complex 类的对象，并将 real 作为复数的实部，将 0 作为复数的虚部。这样一来，`a = 25.5;`整体上的效果相当于：a.Complex(25.5);

- 在进行数学运算、赋值、拷贝等操作时，如果遇到类型不兼容、需要将 double 类型转换为 Complex 类型时，编译器会检索当前的类是否定义了转换构造函数，如果没有定义的话就转换失败，如果定义了的话就调用转换构造函数。

- 转换构造函数也是构造函数的一种，它除了可以用来将其它类型转换为当前类类型，还可以用来初始化对象，这是构造函数本来的意义

  ```c
  Complex c1(26.4);  //创建具名对象
  Complex c2 = 240.3;  //以拷贝的方式初始化对象
  Complex(15.9);  //创建匿名对象
  c1 = Complex(46.9);  //创建一个匿名对象并将它赋值给 c1
  
  在以拷贝的方式初始化对象时，编译器先调用转换构造函数，将 240.3 转换为 Complex 类型（创建一个 Complex 类的匿名对象），然后再拷贝给 c2。
  ```

- 需要注意的是，为了获得目标类型，编译器会“不择手段”，会综合使用内置的转换规则和用户自定义的转换规则，并且会进行多级类型转换，例如：

  - 编译器会根据内置规则先将 int 转换为 double，再根据用户自定义规则将 double 转换为 Complex（int --> double --> Complex）；
  - 编译器会根据内置规则先将 char 转换为 int，再将 int 转换为 double，最后根据用户自定义规则将 double 转换为 Complex（char --> int --> double --> Complex）。

##### 类型转换函数

- 转换构造函数能够将其它类型转换为当前类类型（例如将 double 类型转换为 Complex 类型），但是不能反过来将当前类类型转换为其它类型（例如将 Complex 类型转换为 double 类型）。

- [C++](http://c.biancheng.net/cplus/) 提供了类型转换函数（Type conversion function）来解决这个问题。类型转换函数的作用就是将当前类类型转换为其它类型，它只能以成员函数的形式出现，也就是只能出现在类中。

  ```c
  operator type(){
      //TODO:
      return data;
  }
  operator 是 C++ 关键字，type 是要转换的目标类型，data 是要返回的 type 类型的数据。
  因为要转换的目标类型是 type，所以返回值 data 也必须是 type 类型。既然已经知道了要返回 type 类型的数据，所以没有必要再像普通函数一样明确地给出返回值类型。这样做导致的结果是：类型转换函数看起来没有返回值类型，其实是隐式地指明了返回值类型。
  ```

  - 类型转换函数也没有参数，因为要将当前类的对象转换为其它类型，所以参数不言而喻。实际上编译器会把当前对象的地址赋值给 this [指针](http://c.biancheng.net/c/80/)，这样在函数体内就可以操作当前对象了。

    ```c
    operator double() const { return m_real; }  //类型转换函数
    Complex c1(24.6, 100);
    double f = c1;  //相当于 double f = Complex::operator double(&c1);
    ```

- 类型转换函数和运算符的重载非常相似，都使用 operator 关键字，因此也把类型转换函数称为类型转换运算符。

- 转换构造函数和类型转换函数的作用是相反的：转换构造函数会将其它类型转换为当前类类型，类型转换函数会将当前类类型转换为其它类型。如果没有这两个函数，Complex 类和 int、double、bool 等基本类型的四则运算、逻辑运算都将变得非常复杂，要编写大量的运算符重载函数。

- 但是，如果一个类同时存在这两个函数，就有可能产生二义性

  - f = 12.5 + c1;有两种转换方案：
    - 第一种方案是先将 12.5 转换为 Complex 类型再运算，这样得到的结果也是 Complex 类型，再调用类型转换函数就可以赋值给 f 了。
    - 第二种方案是先将 c1 转换为 double 类型再运算，这样得到的结果也是 double 类型，可以直接赋值给 f。

- 解决二义性问题的办法也很简单粗暴，要么只使用转换构造函数，要么只使用类型转换函数。实践证明，用户对转换构造函数的需求往往更加强烈，这样能增加编码的灵活性，例如，可以将一个字符串字面量或者一个字符数组直接赋值给 string 类的对象，可以将一个 int、double、bool 等基本类型的数据直接赋值给 Complex 类的对象。

- 那么，如果我们想把当前类类型转换为其它类型怎么办呢？很简单，增加一个普通的成员函数即可，例如，string 类使用 c_str() 函数转换为 C 风格的字符串，complex 类使用 real() 和 imag() 函数来获取复数的实部和虚部。

##### 类型转换的本质

- 在 C/C++ 中，不同的数据类型之间可以相互转换：无需用户指明如何转换的称为自动类型转换（隐式类型转换），需要用户显式地指明如何转换的称为强制类型转换（显式类型转换）
- 隐式类型转换利用的是编译器内置的转换规则，或者用户自定义的转换构造函数以及类型转换函数（这些都可以认为是已知的转换规则），例如从 int 到 double、从派生类到基类、从`type *`到`void *`、从 double 到 Complex 等。
- `type *`是一个具体类型的指针，例如`int *`、`double *`、`Student *`等，它们都可以直接赋值给`void *`指针。而反过来是不行的，必须使用强制类型转换才能将`void *`转换为`type *`，例如，malloc() 分配内存后返回的就是一个`void *`指针，我们必须进行强制类型转换后才能赋值给指针变量。
- 诸如数字、文字、符号、图形、音频、视频等数据都是以二进制形式存储在内存中的，它们并没有本质上的区别，那么，00010000 该理解为数字 16 呢，还是图像中某个像素的颜色呢，还是要发出某个声音呢？如果没有特别指明，我们并不知道。也就是说，内存中的数据有多种解释方式，使用之前必须要确定。这种「确定数据的解释方式」的工作就是由数据类型（Data Type）来完成的。例如`int a;`表明，a 这份数据是整数，不能理解为像素、声音、视频等。
- 所谓数据类型转换，就是对数据所占用的二进制位做出重新解释。如果有必要，在重新解释的同时还会修改数据，改变它的二进制位。对于隐式类型转换，编译器可以根据已知的转换规则来决定是否需要修改数据的二进制位；而对于强制类型转换，由于没有对应的转换规则，所以能做的事情仅仅是重新解释数据的二进制位，但无法对数据的二进制位做出修正。这就是隐式类型转换和强制类型转换最根本的区别。这里说的修改数据并不是修改原有的数据，而是修改它的副本（先将原有数据拷贝到另外一个地方再修改）。
- 修改数据的二进制位非常重要，它能把转换后的数据调整到正确的值，所以这种修改时常会发生，例如：
  -  整数和浮点数在内存中的存储形式大相径庭，将浮点数 f 赋值给整数 i 时，不能原样拷贝 f 的二进制位，也不能截取部分二进制位，必须先将 f 的二进制位读取出来，以浮点数的形式呈现，然后直接截掉小数部分，把剩下的整数部分再转换成二进制形式，拷贝到 i 所在的内存中。
  - short 一般占用两个字节，int 一般占用四个字节，将 short 类型的 s 赋值给 int 类型的 i 时，如果仅仅是将 s 的二进制位拷贝给 i，那么 i 最后的两个字节会原样保留，这样会导致赋值结束后 i 的值并不等于 s 的值，所以这样做是错误的。正确的做法是，先给 s 添加 16 个二进制位（两个字节）并全部置为 0，然后再拷贝给 i 所在的内存。
  - [Complex 类型](http://c.biancheng.net/view/vip_2341.html)占用 16 个字节，double 类型占用 8 个字节，将 double 类型的数据赋值给 Complex 类型的变量（对象）时，必须调用转换构造函数，否则剩下的 8 个字节就不知道如何填充了。
- 隐式类型转换必须使用已知的转换规则，虽然灵活性受到了限制，但是由于能够对数据进行恰当地调整，所以更加安全（几乎没有风险）。强制类型转换能够在更大范围的数据类型之间进行转换，例如不同类型指针（引用）之间的转换、从 const 到非 const 的转换、从 int 到指针的转换（有些编译器也允许反过来）等，这虽然增加了灵活性，但是由于不能恰当地调整数据，所以也充满了风险，程序员要小心使用。

##### 四种类型转换运算符

- 隐式类型转换是安全的，显式类型转换是有风险的，C语言之所以增加强制类型转换的语法，就是为了强调风险，让程序员意识到自己在做什么。但是，这种强调风险的方式还是比较粗放，粒度比较大，它并没有表明存在什么风险，风险程度如何。再者，C风格的强制类型转换统一使用`( )`，而`( )`在代码中随处可见，所以也不利于使用文本检索工具（例如 Windows 下的 Ctrl+F、Linux 下的 grep 命令、Mac 下的 Command+F）定位关键代码。

- 为了使潜在风险更加细化，使问题追溯更加方便，使书写格式更加规范，[C++](http://c.biancheng.net/cplus/) 对类型转换进行了分类，并新增了四个关键字来予以支持，它们分别是：

  | 关键字           | 说明                                                         |
  | ---------------- | ------------------------------------------------------------ |
  | static_cast      | 用于良性转换，一般不会导致意外发生，风险很低。               |
  | const_cast       | 用于 const 与非 const、volatile 与非 volatile 之间的转换。   |
  | reinterpret_cast | 高度危险的转换，这种转换仅仅是对二进制位的重新解释，不会借助已有的转换规则对数据进行调整，但是可以实现最灵活的 C++ 类型转换。 |
  | dynamic_cast     | 借助 RTTI，用于类型安全的向下转型（Downcasting）。           |

- 这四个关键字的语法格式都是一样的，具体为：xxx_cast<newType>(data)

- static_cast 只能用于良性转换，这样的转换风险较低，一般不会发生什么意外，例如：

  - 原有的自动类型转换，例如 short 转 int、int 转 double、const 转非 const、向上转型等；
  - void [指针](http://c.biancheng.net/c/80/)和具体类型指针之间的转换，例如`void *`转`int *`、`char *`转`void *`等；
  - 有转换构造函数或者类型转换函数的类与其它类型之间的转换，例如 double 转 Complex（调用转换构造函数）、Complex 转 double（调用类型转换函数）。

- 需要注意的是，static_cast 不能用于无关类型之间的转换，因为这些转换都是有风险的，例如：

  - 两个具体类型指针之间的转换，例如`int *`转`double *`、`Student *`转`int *`等。不同类型的数据存储格式不一样，长度也不一样，用 A 类型的指针指向 B 类型的数据后，会按照 A 类型的方式来处理数据：如果是读取操作，可能会得到一堆没有意义的值；如果是写入操作，可能会使 B 类型的数据遭到破坏，当再次以 B 类型的方式读取数据时会得到一堆没有意义的值。

  - int 和指针之间的转换。将一个具体的地址赋值给指针变量是非常危险的，因为该地址上的内存可能没有分配，也可能没有读写权限，恰好是可用内存反而是小概率事件。

    ```c
    //下面是正确的用法
        int m = 100;
        Complex c(12.5, 23.8);
        long n = static_cast<long>(m);  //宽转换，没有信息丢失
        char ch = static_cast<char>(m);  //窄转换，可能会丢失信息
        int *p1 = static_cast<int*>( malloc(10 * sizeof(int)) );  //将void指针转换为具体类型指针
        void *p2 = static_cast<void*>(p1);  //将具体类型指针，转换为void指针
        double real= static_cast<double>(c);  //调用类型转换函数
       
        //下面的用法是错误的
        float *p3 = static_cast<float*>(p1);  //不能在两个具体类型的指针之间进行转换
        p3 = static_cast<float*>(0X2DF9);  //不能将整数转换为指针类型
    
    ```

- const_cast 比较好理解，它用来去掉表达式的 const 修饰或 volatile 修饰。换句话说，const_cast 就是用来将 const/volatile 类型转换为非 const/volatile 类型。

- dynamic_cast 用于在类的继承层次之间进行类型转换，它既允许向上转型（Upcasting），也允许向下转型（Downcasting）。向上转型是无条件的，不会进行任何检测，所以都能成功；向下转型的前提必须是安全的，要借助 RTTI 进行检测，所有只有一部分能成功。dynamic_cast 与 static_cast 是相对的，dynamic_cast 是“动态转换”的意思，static_cast 是“静态转换”的意思。dynamic_cast 会在程序运行期间借助 RTTI 进行类型转换，这就要求基类必须包含虚函数；static_cast 在编译期间完成类型转换，能够更加及时地发现错误。

- dynamic_cast 的语法格式为：dynamic_cast <newType> (expression)

  - newType 和 expression 必须同时是指针类型或者引用类型。换句话说，dynamic_cast 只能转换指针类型和引用类型，其它类型（int、double、数组、类、结构体等）都不行。

  - 对于指针，如果转换失败将返回 NULL；对于引用，如果转换失败将抛出`std::bad_cast`异常。

- 向上转型时，只要待转换的两个类型之间存在继承关系，并且基类包含了虚函数（这些信息在编译期间就能确定），就一定能转换成功。因为向上转型始终是安全的，所以 dynamic_cast 不会进行任何运行期间的检查，这个时候的 dynamic_cast 和 static_cast 就没有什么区别了。

  - Derived *pd1 = **new** Derived(35, 78); Base \*： = dynamic_cast<Derived\*>(pd1);向上转型就是让子类的对象指针转换为基类，注意只能是指针，向下转型有风险，但是也类似

- reinterpret 是“重新解释”的意思，顾名思义，reinterpret_cast 这种转换仅仅是对二进制位的重新解释，不会借助已有的转换规则对数据进行调整，非常简单粗暴，所以风险很高。

  - reinterpret_cast 可以认为是 static_cast 的一种补充，一些 static_cast 不能完成的转换，就可以用 reinterpret_cast 来完成，例如两个具体类型指针之间的转换、int 和指针之间的转换（有些编译器只允许 int 转指针，不允许反过来）。

    ```c
    	char str[]="http://c.biancheng.net";
        float *p1 = reinterpret_cast<float*>(str);
        cout<<*p1<<endl;
        //将 int 转换为 int*
        int *p = reinterpret_cast<int*>(100);
        //将 A* 转换为 int*
        p = reinterpret_cast<int*>(new A(25, 96));
        cout<<*p<<endl;
    ```

  - 可以想象，用一个 float 指针来操作一个 char 数组是一件多么荒诞和危险的事情，这样的转换方式不到万不得已的时候不要使用。将`A*`转换为`int*`，使用指针直接访问 private 成员刺穿了一个类的封装性，更好的办法是让类提供 get/set 函数，间接地访问成员变量。

#### 异常

- 异常规范是 C++98 新增的一项功能，但是后来的 C++11 已经将它抛弃了，不再建议使用。

- 运行时错误是指程序在运行期间发生的错误，例如除数为 0、内存分配失败、数组越界、文件不存在等。[C++](http://c.biancheng.net/cplus/) 异常（Exception）机制就是为解决运行时错误而引入的。

- 运行时错误如果放任不管，系统就会执行默认的操作，终止程序运行，也就是我们常说的程序崩溃（Crash）。C++ 提供了异常（Exception）机制，让我们能够捕获运行时错误，给程序一次“起死回生”的机会，或者至少告诉用户发生了什么再终止程序。

  ```c
  int main(){
      string str = "http://c.biancheng.net";
      char ch1 = str[100];  //下标越界，ch1为垃圾值
      cout<<ch1<<endl;
      char ch2 = str.at(100);  //下标越界，抛出异常
      cout<<ch2<<endl;
      return 0;
  }
  at() 是 string 类的一个成员函数，它会根据下标来返回字符串的一个字符。与[ ]不同，at() 会检查下标是否越界，如果越界就抛出一个异常；而[ ]不做检查，不管下标是多少都会照常访问。
  上面的代码中，下标 100 显然超出了字符串 str 的长度。由于第 6 行代码不会检查下标越界，虽然有逻辑错误，但是程序能够正常运行。而第 8 行代码则不同，at() 函数检测到下标越界会抛出一个异常，这个异常可以由程序员处理，但是我们在代码中并没有处理，所以系统只能执行默认的操作，也即终止程序执行。
  ```

- 捕获异常

  ```c++
  try{
      // 可能抛出异常的语句
  }catch(exceptionType variable){
      // 处理异常的语句
  }
  ```

  - `try`和`catch`都是 C++ 中的关键字，后跟语句块，不能省略`{ }`。try 中包含可能会抛出异常的语句，一旦有异常抛出就会被后面的 catch 捕获。从 try 的意思可以看出，它只是“检测”语句块有没有异常，如果没有发生异常，它就“检测”不到。catch 是“抓住”的意思，用来捕获并处理 try 检测到的异常；如果 try 语句块没有检测到异常（没有异常抛出），那么就不会执行 catch 中的语句。
  - catch 关键字后面的`exceptionType variable`指明了当前 catch 可以处理的异常类型，以及具体的出错信息。

- ```c++
  int main(){
      string str = "http://c.biancheng.net";
    
      try{
          char ch1 = str[100];
          cout<<ch1<<endl;
      }catch(exception e){
          cout<<"[1]out of bound!"<<endl;
      }
      try{
          char ch2 = str.at(100);
          cout<<ch2<<endl;
      }catch(exception &e){  //exception类位于<exception>头文件中
          cout<<"[2]out of bound!"<<endl;
      }
      return 0;
  }
  
  运行结果
  (
  [2]out of bound!c
  ```

  - 可以看出，第一个 try 没有捕获到异常，输出了一个没有意义的字符（垃圾值）。因为`[ ]`不会检查下标越界，不会抛出异常，所以即使有错误，try 也检测不到。换句话说，发生异常时必须将异常明确地抛出，try 才能检测到；如果不抛出来，即使有异常 try 也检测不到。所谓抛出异常，就是明确地告诉程序发生了什么错误。
  - 第二个 try 检测到了异常，并交给 catch 处理，执行 catch 中的语句。需要说明的是，异常一旦抛出，会立刻被 try 检测到，并且不会再执行异常点（异常发生位置）后面的语句。本例中抛出异常的位置是第 17 行的 at() 函数，它后面的 cout 语句就不会再被执行，所以看不到它的输出。
  - 检测到异常后程序的执行流会发生跳转，从异常点跳转到 catch 所在的位置，位于异常点之后的、并且在当前 try 块内的语句就都不会再执行了；即使 catch 语句成功地处理了错误，程序的执行流也不会再回退到异常点，所以这些语句永远都没有执行的机会了。

- 执行完 catch 块所包含的代码后，程序会继续执行 catch 块后面的代码，就恢复了正常的执行流。

- 不明确地抛出异常就检测不到异常。抛出（Throw）--> 检测（Try） --> 捕获（Catch）

- 异常可以发生在当前的 try 块中，也可以发生在 try 块所调用的某个函数中，或者是所调用的函数又调用了另外的一个函数，这个另外的函数中发生了异常。这些异常，都可以被 try 检测到。发生异常后，程序的执行流会沿着函数的调用链往前回退，直到遇见 try 才停止。在这个回退过程中，调用链中剩下的代码（所有函数中未被执行的代码）都会被跳过，没有执行的机会了。

##### 异常类型以及多级catch匹配

- `exceptionType`是异常类型，它指明了当前的 catch 可以处理什么类型的异常；`variable`是一个变量，用来接收异常信息。当程序抛出异常时，会创建一份数据，这份数据包含了错误信息，程序员可以根据这些信息来判断到底出了什么问题，接下来怎么处理。

- 异常既然是一份数据，那么就应该有数据类型。[C++](http://c.biancheng.net/cplus/) 规定，异常类型可以是 int、char、float、bool 等基本类型，也可以是[指针](http://c.biancheng.net/c/80/)、数组、字符串、结构体、类等聚合类型。C++ 语言本身以及标准库中的函数抛出的异常，都是 exception 类或其子类的异常。也就是说，抛出异常时，会创建一个 exception 类或其子类的对象。

- `exceptionType variable`和函数的形参非常类似，当异常发生后，会将异常数据传递给 variable 这个变量，这和函数传参的过程类似。当然，只有跟 exceptionType 类型匹配的异常数据才会被传递给 variable，否则 catch 不会接收这份异常数据，也不会执行 catch 块中的语句。换句话说，catch 不会处理当前的异常。

- 可以将 catch 看做一个没有返回值的函数，当异常发生后 catch 会被调用，并且会接收实参（异常数据）。

- 如果不希望 catch 处理异常数据，也可以将 variable 省略掉

  ```c++
  try{
      // 可能抛出异常的语句
  }catch(exceptionType){
      // 处理异常的语句
  }
  这样只会将异常类型和 catch 所能处理的类型进行匹配，不会传递异常数据了。
  ```

- 一个try后面可以跟多个catch。当异常发生时，程序会按照从上到下的顺序，将异常类型和 catch 所能接收的类型逐个匹配。一旦找到类型匹配的 catch 就停止检索，并将异常交给当前的 catch 处理（其他的 catch 不会被执行）。如果最终也没有找到匹配的 catch，就只能交给系统处理，终止程序的运行。

  ```c++
  class Base{ };
  class Derived: public Base{ };
  int main(){
      try{
          throw Derived();  //抛出自己的异常类型，实际上是创建一个Derived类型的匿名对象
          cout<<"This statement will not be executed."<<endl;
      }catch(int){
          cout<<"Exception type: int"<<endl;
      }catch(char *){
          cout<<"Exception type: cahr *"<<endl;
      }catch(Base){  //匹配成功（向上转型）
          cout<<"Exception type: Base"<<endl;
      }catch(Derived){
          cout<<"Exception type: Derived"<<endl;
      }
      return 0;
  }
  运行结果
  Exception type: Base
  
  
  ```

  - 在 catch 中，我们只给出了异常类型，没有给出接收异常信息的变量。
  - 我们定义了一个基类 Base，又从 Base 派生类出了 Derived。抛出异常时，我们创建了一个 Derived 类的匿名对象，也就是说，异常的类型是 Derived。
  - 我们期望的是，异常被`catch(Derived)`捕获，但是从输出结果可以看出，异常提前被`catch(Base)`捕获了，这说明 catch 在匹配异常类型时发生了[向上转型（Upcasting）](http://c.biancheng.net/view/2284.html)。

- C/C++ 中存在多种多样的类型转换，以普通函数（非模板函数）为例，发生函数调用时，如果实参和形参的类型不是严格匹配，那么会将实参的类型进行适当的转换，以适应形参的类型，这些转换包括：

  - 算数转换：例如 int 转换为 float，char 转换为 int，double 转换为 int 等。
  - 向上转型：也就是派生类向基类的转换，请猛击《[C++向上转型（将派生类赋值给基类）](http://c.biancheng.net/view/2284.html)》了解详情。
  - const 转换：也即将非 const 类型转换为 const 类型，例如将 char * 转换为 const char *。
  - 数组或函数指针转换：如果函数形参不是引用类型，那么数组名会转换为数组指针，函数名也会转换为函数指针。
  - 用户自定的类型转换。
  - catch 在匹配异常类型的过程中，也会进行类型转换，但是这种转换受到了更多的限制，仅能进行「向上转型」、「const 转换」和「数组或函数指针转换」，其他的都不能应用于 catch。

##### throw

- 使用 throw 关键字来显式地抛出异常

  ```c++
  throw exceptionData;
  exceptionData 是“异常数据”的意思，它可以包含任意的信息，完全有程序员决定。exceptionData 可以是 int、float、bool 等基本类型，也可以是指针、数组、字符串、结构体、类等聚合类型
  
  char str[] = "http://c.biancheng.net";
  char *pstr = str;
  class Base{};
  Base obj;
  throw 100;  //int 类型
  throw str;  //数组类型
  throw pstr;  //指针类型
  throw obj;  //对象类型
  ```

  ```c++
  //自定义的异常类型
  class OutOfRange{
  public:
      OutOfRange(): m_flag(1){ };
      OutOfRange(int len, int index): m_len(len), m_index(index), m_flag(2){ }
  public:
      void what() const;  //获取具体的错误信息
  private:
      int m_flag;  //不同的flag表示不同的错误
      int m_len;  //当前数组的长度
      int m_index;  //当前使用的数组下标
  };
  void OutOfRange::what() const {
      if(m_flag == 1){
          cout<<"Error: empty array, no elements to pop."<<endl;
      }else if(m_flag == 2){
          cout<<"Error: out of range( array length "<<m_len<<", access index "<<m_index<<" )"<<endl;
      }else{
          cout<<"Unknown exception."<<endl;
      }
  }
  
  //实现动态数组
  class Array{
  public:
      Array();
      ~Array(){ free(m_p); };
  public:
      int operator[](int i) const;  //获取数组元素
      int push(int ele);  //在末尾插入数组元素
      int pop();  //在末尾删除数组元素
      int length() const{ return m_len; };  //获取数组长度
  private:
      int m_len;  //数组长度
      int m_capacity;  //当前的内存能容纳多少个元素
      int *m_p;  //内存指针
  private:
      static const int m_stepSize = 50;  //每次扩容的步长
  };
  Array::Array(){
      m_p = (int*)malloc( sizeof(int) * m_stepSize );
      m_capacity = m_stepSize;
      m_len = 0;
  }
  int Array::operator[](int index) const {
      if( index<0 || index>=m_len ){  //判断是否越界
          throw OutOfRange(m_len, index);  //抛出异常（创建一个匿名对象）
      }
      return *(m_p + index);
  }
  int Array::push(int ele){
      if(m_len >= m_capacity){  //如果容量不足就扩容
          m_capacity += m_stepSize;
          m_p = (int*)realloc( m_p, sizeof(int) * m_capacity );  //扩容
      }
      *(m_p + m_len) = ele;
      m_len++;
      return m_len-1;
  }
  int Array::pop(){
      if(m_len == 0){
           throw OutOfRange();  //抛出异常（创建一个匿名对象）
      }
      m_len--;
      return *(m_p + m_len);
  }
  //打印数组元素
  void printArray(Array &arr){
      int len = arr.length();
      //判断数组是否为空
      if(len == 0){
          cout<<"Empty array! No elements to print."<<endl;
          return;
      }
      for(int i=0; i<len; i++){
          if(i == len-1){
              cout<<arr[i]<<endl;
          }else{
              cout<<arr[i]<<", ";
          }
      }
  }
  int main(){
      Array nums;
      //向数组中添加十个元素
      for(int i=0; i<10; i++){
          nums.push(i);
      }
      printArray(nums);
      //尝试访问第20个元素
      try{
          cout<<nums[20]<<endl;
      }catch(OutOfRange &e){
          e.what();
      }
      //尝试弹出20个元素
      try{
          for(int i=0; i<20; i++){
              nums.pop();
          }
      }catch(OutOfRange &e){
          e.what();
      }
      printArray(nums);
      return 0;
  }
  ```

- Array 类实现了动态数组，它的主要思路是：在创建对象时预先分配出一定长度的内存（通过 malloc() 分配），内存不够用时就再扩展内存（通过 realloc() 重新分配）。Array 数组只能在尾部一个一个地插入（通过 push() 插入）或删除（通过 pop() 删除）元素。
- 我们通过重载过的`[ ]`运算符来访问数组元素，如果下标过小或过大，就会抛出异常；在抛出异常的同时，我们还记录了当前数组的长度和要访问的下标。
- 在使用 pop() 删除数组元素时，如果当前数组为空，也会抛出错误。
- 基本思路就是在检测到异常之后抛出异常，但是throw抛出的不一定是什么类型的，所以我们可以将任意类型抛出然后catch接住，然后处理一些东西。例如上述检测到数组越界之后，抛出一个OutOfRange类，然后catch接住这个类，然后执行类里面的方法。

##### exception类

- [C++](http://c.biancheng.net/cplus/)语言本身或者标准库抛出的异常都是 exception 的子类，称为标准异常（S[tan](http://c.biancheng.net/ref/tan.html)dard Exception）。你可以通过下面的语句来捕获所有的标准异常：

  ```c++
  try{
      //可能抛出异常的语句
  }catch(exception &e){
      //处理异常的语句
  }
  之所以使用引用，是为了提高效率。如果不使用引用，就要经历一次对象拷贝（要调用拷贝构造函数）的过程。
  ```

- exception 类位于 <exception> 头文件中，它被声明为：

  ```c++
  class exception{
  public:
      exception () throw();  //构造函数
      exception (const exception&) throw();  //拷贝构造函数
      exception& operator= (const exception&) throw();  //运算符重载
      virtual ~exception() throw();  //虚析构函数
      virtual const char* what() const throw();  //虚函数
  }
  ```

  - 这里需要说明的是 what() 函数。what() 函数返回一个能识别异常的字符串，正如它的名字“what”一样，可以粗略地告诉你这是什么异常。不过C++标准并没有规定这个字符串的格式，各个编译器的实现也不同，所以 what() 的返回值仅供参考。

- exception类的直接派生类

  | logic_error       | 逻辑错误。                                                   |
  | ----------------- | ------------------------------------------------------------ |
  | runtime_error     | 运行时错误。                                                 |
  | bad_alloc         | 使用 new 或 new[ ] 分配内存失败时抛出的异常。                |
  | bad_typeid        | 使用 typeid 操作一个 NULL [指针](http://c.biancheng.net/c/80/)，而且该指针是带有虚函数的类，这时抛出 bad_typeid 异常。 |
  | bad_cast          | 使用 dynamic_cast 转换失败时抛出的异常。                     |
  | ios_base::failure | io 过程中出现的异常。                                        |
  | bad_exception     | 这是个特殊的异常，如果函数的异常列表里声明了 bad_exception 异常，当函数内部抛出了异常列表中没有的异常时，如果调用的 unexpected() 函数中抛出了异常，不论什么类型，都会被替换为 bad_exception 类型。 |

-  logic_error 的派生类： 

  | 异常名称         | 说  明                                                       |
  | ---------------- | ------------------------------------------------------------ |
  | length_error     | 试图生成一个超出该类型最大长度的对象时抛出该异常，例如 vector 的 resize 操作。 |
  | domain_error     | 参数的值域错误，主要用在数学函数中，例如使用一个负值调用只能操作非负数的函数。 |
  | out_of_range     | 超出有效范围。                                               |
  | invalid_argument | 参数不合适。在标准库中，当利用string对象构造 bitset 时，而 string 中的字符不是 0 或1 的时候，抛出该异常。 |

- runtime_error 的派生类： 

  | 异常名称        | 说  明                           |
  | --------------- | -------------------------------- |
  | range_error     | 计算结果超出了有意义的值域范围。 |
  | overflow_error  | 算术计算上溢。                   |
  | underflow_error | 算术计算下溢。                   |

- 上面的异常名称都是类。

#### 模板

- 泛型程序设计（generic programming）是一种算法在实现时不指定具体要操作的数据的类型的程序设计方法。所谓“泛型”，指的是算法只要实现一遍，就能适用于多种数据类型。泛型程序设计方法的优势在于能够减少重复代码的编写。

##### 函数模板

- 我们知道，数据的值可以通过函数参数传递，在函数定义时数据的值是未知的，只有等到函数调用时接收了实参才能确定其值。这就是值的参数化。

- 在[C++](http://c.biancheng.net/cplus/)中，数据的类型也可以通过参数来传递，在函数定义时可以不指明具体的数据类型，当发生函数调用时，编译器可以根据传入的实参自动推断数据类型。这就是类型的参数化。

- 值（Value）和类型（Type）是数据的两个主要特征，它们在C++中都可以被参数化。

- 所谓函数模板，实际上是建立一个通用函数，它所用到的数据的类型（包括返回值类型、形参类型、局部变量类型）可以不具体指定，而是用一个虚拟的类型来代替（实际上是用一个标识符来占位），等发生函数调用时再根据传入的实参来逆推出真正的类型。这个通用函数就称为函数模板（Function Template）。

- 在函数模板中，数据的值和类型都被参数化了，发生函数调用时编译器会根据传入的实参来推演形参的值和类型。换个角度说，函数模板除了支持值的参数化，还支持类型的参数化。

- 函数模板返回值也可以是T，在函数调用时，我们根据传入的实参来推断类型，函数调用正常来根据实参来调用，函数模板会自动推断T的类型，不用管别的。

- 一但定义了函数模板，就可以将类型参数用于函数定义和函数声明了。说得直白一点，原来使用 int、float、char 等内置类型的地方，都可以用类型参数来代替。所以在函数模板不用<>来指定T类型。

- `template`是定义函数模板的关键字，它后面紧跟尖括号`<>`，尖括号包围的是类型参数（也可以说是虚拟的类型，或者说是类型占位符）。`typename`是另外一个关键字，用来声明具体的类型参数，这里的类型参数就是`T`。从整体上看，`template<typename T>`被称为模板头。

- 模板头中包含的类型参数可以用在函数定义的各个位置，包括返回值、形参列表和函数体

- 类型参数的命名规则跟其他标识符的命名规则一样，不过使用 T、T1、T2、Type 等已经成为了一种惯例。

  ```
  template <typename 类型参数1 , typename 类型参数2 , ...> 返回值类型  函数名(形参列表){
    //在函数体中可以使用类型参数
  }
  类型参数可以有多个，它们之间以逗号,分隔。类型参数列表以< >包围，形式参数列表以( )包围。
  typename关键字也可以使用class关键字替代，它们没有任何区别。C++ 早期对模板的支持并不严谨，没有引入新的关键字，而是用 class 来指明类型参数，但是 class 关键字本来已经用在类的定义中了，这样做显得不太友好，所以后来 C++ 又引入了一个新的关键字 typename，专门用来定义类型参数。不过至今仍然有很多代码在使用 class 关键字，包括 C++ 标准库、一些开源程序等。
  ```

- 函数模板也可以提前声明，不过声明时需要带上模板头，并且模板头和函数定义（声明）是一个不可分割的整体，它们可以换行，但中间不能有分号。

##### 类模板

- 一但声明了类模板，就可以将类型参数用于类的成员函数和成员变量了。换句话说，原来使用 int、float、char 等内置类型的地方，都可以用类型参数来代替。

  ```c++
  template<typename 类型参数1 , typename 类型参数2 , …> class 类名{
      //TODO:
  };
  定义类时的分号不能丢
  ```

- 上面的代码仅仅是类的声明，我们还需要在类外定义成员函数。在类外定义成员函数时仍然需要带上模板头，格式为：

  ```c++
  template<typename 类型参数1 , typename 类型参数2 , …>
  返回值类型 类名<类型参数1 , 类型参数2, ...>::函数名(形参列表){
    //TODO:
  }
  
  template<typename T1, typename T2>  //模板头
  T1 Point<T1, T2>::getX() const /*函数头*/ {
      return m_x;
  }
  
  除了 template 关键字后面要指明类型参数，类名 Point 后面也要带上类型参数，只是不加 typename 关键字了。另外需要注意的是，在类外定义成员函数时，template 后面的类型参数要和类声明时的一致。
  ```

- 使用类模板创建对象

  - 使用类模板创建对象时，需要指明具体的数据类型

    ```c++
    Point<int, int> p1(10, 20);
    Point<int, float> p2(10, 15.5);
    Point<float, char*> p3(12.4, "东经180度");
    与函数模板不同的是，类模板在实例化时必须显式地指明数据类型，编译器不能根据给定的数据推演出数据类型。
    ```

  - 使用对象[指针](http://c.biancheng.net/c/80/)的方式来实例化

    ```c++
    Point<float, float> *p1 = new Point<float, float>(10.6, 109.3);
    Point<char*, char*> *p = new Point<char*, char*>("东经180度", "北纬210度");
    ```

  - 需要注意的是，赋值号两边都要指明具体的数据类型，且要保持一致。下面的写法是错误的：

    ```c++
    //赋值号两边的数据类型不一致
    Point<float, float> *p = new Point<float, int>(10.6, 109);
    //赋值号右边没有指明数据类型
    Point<float, float> *p = new Point(10.6, 109);
    ```

##### 函数模板的重载

- 当需要对不同的类型使用同一种算法（同一个函数体）时，为了避免定义多个功能重复的函数，可以使用模板。然而，并非所有的类型都使用同一种算法，有些特定的类型需要单独处理，为了满足这种需求，C++ 允许对函数模板进行重载，程序员可以像重载常规函数那样重载模板定义。

- 在《[C++函数模板](http://c.biancheng.net/view/2317.html)》一节中我们定义了 Swap() 函数用来交换两个变量的值，一种方案是使用指针，另外一种方案是使用引用

  ```c++
  //方案①：使用指针
  template<typename T> void Swap(T *a, T *b){
      T temp = *a;
      *a = *b;
      *b = temp;
  }
  //方案②：使用引用
  template<class T> void Swap(T &a, T &b){
      T temp = a;
      a = b;
      b = temp;
  }
  ```

  - 这两种方案都可以交换 int、float、char、bool 等基本类型变量的值，但是却不能交换两个数组。
  - 对于方案①，调用函数时传入的是数组指针，或者说是指向第 0  个元素的指针，这样交换的仅仅是数组的第 0 个元素，而不是整个数组。
  - 对于方案②，假设传入的是一个长度为 5 的 int 类型数组（该数组的类型是 int [5]），那么 T 的真实类型为`int [5]`，`T temp`会被替换为`int [5] temp`，这显然是错误的。另外一方面，语句`a=b;`尝试对数组 a 赋值，而数组名是常量，它的值不允许被修改，所以也会产生错误。总起来说，方案②会有两处语法错误。

- 交换两个数组唯一的办法就是逐个交换所有的数组元素

  ```c++
  template<typename T> void Swap(T a[], T b[], int len){
      T temp;
      for(int i=0; i<len; i++){
          temp = a[i];
          a[i] = b[i];
          b[i] = temp;
      }
  }
  ```

##### 函数模板的实参推断

- 在使用类模板创建对象时，程序员需要显式的指明实参（也就是具体的类型）

  ```c++
  template<typename T1, typename T2> class Point;
  我们可以在栈上创建对象，也可以在堆上创建对象：
  Point<int, int> p1(10, 20);  //在栈上创建对象
  Point<char*, char*> *p = new Point<char*, char*>("东京180度", "北纬210度");  //在堆上创建对象
  因为已经显式地指明了 T1、T2 的具体类型，所以编译器就不用再自己推断了，直接拿来使用即可。
  ```

- 而对于函数模板，调用函数时可以不显式地指明实参（也就是具体的类型）

  ```c++
  //函数声明
  template<typename T> void Swap(T &a, T &b);
  //函数调用
  int n1 = 100, n2 = 200;
  Swap(n1, n2);
  float f1 = 12.5, f2 = 56.93;
  Swap(f1, f2);
  虽然没有显式地指明 T 的具体类型，但是编译器会根据 n1 和 n2、f1 和 f2 的类型自动推断出 T 的类型。这种通过函数实参来确定模板实参（也就是类型参数的具体类型）的过程称为模板实参推断。
  在模板实参推断过程中，编译器使用函数调用中的实参类型来寻找类型参数的具体类型。
  ```

- 对于普通函数（非模板函数），发生函数调用时会对实参的类型进行适当的转换，以适应形参的类型。这些转换包括：

  - 算数转换：例如 int 转换为 float，char 转换为 int，double 转换为 int 等。
  - 派生类向基类的转换：也就是向上转型
  - const 转换：也即将非 const 类型转换为 const 类型，例如将 char * 转换为 const char *。
  - 数组或函数指针转换：如果函数形参不是引用类型，那么数组名会转换为数组指针，函数名也会转换为函数指针。
  - 用户自定的类型转换。

- 而对于函数模板，类型转换则受到了更多的限制，仅能进行「const 转换」和「数组或函数指针转换」，其他的都不能应用于函数模板

  ```c++
  template<typename T> void func1(T a, T b);
  template<typename T> void func2(T *buffer);
  template<typename T> void func3(const T &stu);
  template<typename T> void func4(T a);
  template<typename T> void func5(T &a);
  它们具体的调用形式为：
  func1(12.5, 30);  //Error
  func2(name);  //name的类型从 int [20] 换转换为 int *，所以 T 的真实类型为 int
  func3(stu1);  //非const转换为const，T 的真实类型为 Student
  func4(name);  //name的类型从 int [20] 换转换为 int *，所以 T 的真实类型为 int *
  func5(name);  //name的类型依然为 int [20]，不会转换为 int *，所以 T 的真实类型为 int [20]
  
  可以发现，当函数形参是引用类型时，数组不会转换为指针
  ```

  - 请读者注意 name，它本来的类型是`int [20]`：

    - 对于`func2(name)`和`func4(name)`，name 的类型会从 int [20] 转换为 int *，也即将数组转换为指针，所以 T 的类型分别为 int * 和 int。

    - 对于`func5(name)`，name 的类型依然为 int [20]，不会转换为 int *，所以 T 的类型为 int [20]。

      ```c++
      template<typename T> void func(T &a, T &b);
      如果它的具体调用形式为：
      int str1[20];
      int str2[10];
      func(str1, str2);
      由于 str1、str2 的类型分别为 int [20] 和 int [10]，在函数调用过程中又不会转换为指针，所以编译器不知道应该将 T 实例化为 int [20] 还是 int [10]，导致调用失败。
      ```

- 函数模板的实参推断是指「在函数调用过程中根据实参的类型来寻找类型参数的具体类型」的过程，这在大部分情况下是奏效的，但是当类型参数的个数较多时，就会有个别的类型无法推断出来，这个时候就必须显式地指明实参。

  ```c++
  template<typename T1, typename T2> void func(T1 a){
      T2 b;
  }
  func(10);  //函数调用
  func() 有两个类型参数，分别是 T1 和 T2，但是编译器只能从函数调用中推断出 T1 的类型来，不能推断出 T2 的类型来，所以这种调用是失败的，这个时候就必须显式地指明 T1、T2 的具体类型。
  「为函数模板显式地指明实参」和「为类模板显式地指明实参」的形式是类似的，就是在函数名后面添加尖括号< >
  func<int, int>(10);
  ```

  - 显式指明的模板实参会按照从左到右的顺序与对应的模板参数匹配：第一个实参与第一个模板参数匹配，第二个实参与第二个模板参数匹配，以此类推。只有尾部（最右）的类型参数的实参可以省略，而且前提是它们可以从传递给函数的实参中推断出来。

- 显示指明实参时可以应用正常的类型转换。上面我们提到，函数模板仅能进行「const 转换」和「数组或函数指针转换」两种形式的类型转换，但是当我们显式地指明类型参数的实参（具体类型）时，就可以使用正常的类型转换（非模板函数可以使用的类型转换）了。

  ```c++
  template<typename T> void func(T a, T b);
  func(10, 23.5);  //Error
  func<float>(20, 93.7);  //Correct
  在第二种调用形式中，我们已经显式地指明了 T 的类型为 float，编译器不会再为「T 的类型到底是 int 还是 double」而纠结了，所以可以从容地使用正常的类型转换了。
  ```

##### 模版的显示具体化

- C++ 没有办法限制类型参数的范围，我们可以使用任意一种类型来实例化模板。但是模板中的语句（函数体或者类体）不一定就能适应所有的类型，可能会有个别的类型没有意义，或者会导致语法错误。

  ```
  template<class T> const T& Max(const T& a, const T& b){
      return a > b ? a : b;
  }
  ```

  - 请读者注意`a > b`这条语句，`>`能够用来比较 int、float、char 等基本类型数据的大小，但是却不能用来比较结构体变量、对象以及数组的大小，因为我们并没有针对结构体、类和数组重载`>`。
  - 该函数模板虽然可以用于指针，但比较的是地址大小，而不是指针指向的数据，所以也没有现实的意义。
  - 除了`>`，`+``-``*``/``==``<`等运算符也只能用于基本类型，不能用于结构体、类、数组等复杂类型。总之，编写的函数模板很可能无法处理某些类型，我们必须对这些类型进行单独处理。
  - 模板是一种泛型技术，它能接受的类型是宽泛的、没有限制的，并且对这些类型使用的算法都是一样的（函数体或类体一样）。但是现在我们希望改变这种“游戏规则”，让模板能够针对某种具体的类型使用不同的算法（函数体或类体不同），这在 C++ 中是可以做到的，这种技术称为模板的**显示具体化（Explicit Specialization）**。

- 函数模版的显示具体化

  ```
  typedef struct{
      string name;
      int age;
      float score;
  } STU;
  //函数模板
  template<class T> const T& Max(const T& a, const T& b);
  //函数模板的显示具体化（针对STU类型的显示具体化）
  template<> const STU& Max<STU>(const STU& a, const STU& b);
  //重载<<
  ostream & operator<<(ostream &out, const STU &stu);
  int main(){
      int a = 10;
      int b = 20;
      cout<<Max(a, b)<<endl;
     
      STU stu1 = { "王明", 16, 95.5};
      STU stu2 = { "徐亮", 17, 90.0};
      cout<<Max(stu1, stu2)<<endl;
      return 0;
  }
  template<class T> const T& Max(const T& a, const T& b){
      return a > b ? a : b;
  }
  template<> const STU& Max<STU>(const STU& a, const STU& b){
      return a.score > b.score ? a : b;
  }
  ostream & operator<<(ostream &out, const STU &stu){
      out<<stu.name<<" , "<<stu.age <<" , "<<stu.score;
      return out;
  }
  ```

  - 要想获取两份数据中较大的一份，必然会涉及到对两份数据的比较。对于 int、float、char 等基本类型的数据，直接比较它们本身的值即可，而对于 STU 类型的数据，直接比较它们本身的值不但会有语法错误，而且毫无意义，这就要求我们设计一套不同的比较方案，从语法和逻辑上都能行得通，所以本例中我们比较的是两名学生的成绩（score）。
  - 不同的比较方案最终导致了算法（函数体）的不同，我们不得不借助模板的显示具体化技术对 STU 类型进行单独处理
  - `Max<STU>`中的`STU`表明了要将类型参数 T 具体化为 STU 类型，原来使用 T 的位置都应该使用 STU 替换，包括返回值类型、形参类型、局部变量的类型。
  - Max 只有一个类型参数 T，并且已经被具体化为 STU 了，这样整个模板就不再有类型参数了，类型参数列表也就为空了，所以模板头应该写作`template<>`。
  - 另外，`Max<STU>`中的`STU`是可选的，因为函数的形参已经表明，这是 STU 类型的一个具体化，编译器能够逆推出 T 的具体类型。简写后的函数声明为：template<> const STU& Max(const STU& a, const STU& b);
  - 在 C++ 中，对于给定的函数名，可以有非模板函数、模板函数、显示具体化模板函数以及它们的重载版本，在调用函数时，显示具体化优先于常规模板，而非模板函数优先于显示具体化和常规模板。

- 类模版的显示具体化，在《[C++类模板](http://c.biancheng.net/view/2318.html)》一节中我们定义了一个 Point 类，用来输出不同类型的坐标。在输出结果中，横坐标 x 和纵坐标 y 是以逗号`,`为分隔的，但是由于个人审美的不同，我希望当 x 和 y 都是字符串时以`|`为分隔，是数字或者其中一个是数字时才以逗号`,`为分隔。为了满足我这种奇葩的要求，可以使用显示具体化技术对字符串类型的坐标做特殊处理。

  ```
  //类模板
  template<class T1, class T2> class Point{
  public:
      Point(T1 x, T2 y): m_x(x), m_y(y){ }
  public:
      T1 getX() const{ return m_x; }
      void setX(T1 x){ m_x = x; }
      T2 getY() const{ return m_y; }
      void setY(T2 y){ m_y = y; }
      void display() const;
  private:
      T1 m_x;
      T2 m_y;
  };
  template<class T1, class T2>  //这里要带上模板头
  void Point<T1, T2>::display() const{
      cout<<"x="<<m_x<<", y="<<m_y<<endl;
  }
  //类模板的显示具体化（针对字符串类型的显示具体化）
  template<> class Point<char*, char*>{
  public:
      Point(char *x, char *y): m_x(x), m_y(y){ }
  public:
      char *getX() const{ return m_x; }
      void setX(char *x){ m_x = x; }
      char *getY() const{ return m_y; }
      void setY(char *y){ m_y = y; }
      void display() const;
  private:
      char *m_x;  //x坐标
      char *m_y;  //y坐标
  };
  //这里不能带模板头template<>
  void Point<char*, char*>::display() const{
      cout<<"x="<<m_x<<" | y="<<m_y<<endl;
  }
  int main(){
      ( new Point<int, int>(10, 20) ) -> display();
      ( new Point<int, char*>(10, "东京180度") ) -> display();
      ( new Point<char*, char*>("东京180度", "北纬210度") ) -> display();
      return 0;
  }
  x=10, y=20
  x=10, y=东京180度
  x=东京180度 | y=北纬210度
  ```

  - `Point<char*, char*>`表明了要将类型参数 T1、T2 都具体化为`char*`类型，原来使用 T1、T2 的位置都应该使用`char*`替换。Point 类有两个类型参数 T1、T2，并且都已经被具体化了，所以整个类模板就不再有类型参数了，模板头应该写作`template<>`。
  - 当在类的外部定义成员函数时，普通类模板的成员函数前面要带上模板头，而具体化的类模板的成员函数前面不能带模板头。

- 部分显示具体化，在上面的显式具体化例子中，我们为所有的类型参数都提供了实参，所以最后的模板头为空，也即`template<>`。另外 C++ 还允许只为一部分类型参数提供实参，这称为部分显式具体化。部分显式具体化只能用于类模板，不能用于函数模板。

  ```c++
  //类模板
  template<class T1, class T2> class Point{
  public:
      Point(T1 x, T2 y): m_x(x), m_y(y){ }
  public:
      T1 getX() const{ return m_x; }
      void setX(T1 x){ m_x = x; }
      T2 getY() const{ return m_y; }
      void setY(T2 y){ m_y = y; }
      void display() const;
  private:
      T1 m_x;
      T2 m_y;
  };
  template<class T1, class T2>  //这里需要带上模板头
  void Point<T1, T2>::display() const{
      cout<<"x="<<m_x<<", y="<<m_y<<endl;
  }
  //类模板的部分显示具体化
  template<typename T2> class Point<char*, T2>{
  public:
      Point(char *x, T2 y): m_x(x), m_y(y){ }
  public:
      char *getX() const{ return m_x; }
      void setX(char *x){ m_x = x; }
      T2 getY() const{ return m_y; }
      void setY(T2 y){ m_y = y; }
      void display() const;
  private:
      char *m_x;  //x坐标
      T2 m_y;  //y坐标
  };
  template<typename T2>  //这里需要带上模板头
  void Point<char*, T2>::display() const{
      cout<<"x="<<m_x<<" | y="<<m_y<<endl;
  }
  int main(){
      ( new Point<int, int>(10, 20) ) -> display();
      ( new Point<char*, int>("东京180度", 10) ) -> display();
      ( new Point<char*, char*>("东京180度", "北纬210度") ) -> display();
      return 0;
  }
  x=10, y=20
  x=东京180度 | y=10
  x=东京180度 | y=北纬210度
  ```

  - 模板头`template<typename T2>`中声明的是没有被具体化的类型参数；类名`Point<char*, T2>`列出了所有类型参数，包括未被具体化的和已经被具体化的。
  - 类名后面之所以要列出所有的类型参数，是为了让编译器确认“到底是第几个类型参数被具体化了”，如果写作`template<typename T2> class Point<char*>`，编译器就不知道char*代表的是第一个类型参数，还是第二个类型参数。

##### 模版中的非类型参数

- 模板是一种泛型技术，目的是将数据的类型参数化，以增强 C++ 语言（强类型语言）的灵活性。C++ 对模板的支持非常自由，模板中除了可以包含类型参数，还可以包含非类型参数

  ```
  template<typename T, int N> class Demo{ };
  template<class T, int N> void func(T (&arr)[N]);
  ```

  - T 是一个类型参数，它通过`class`或`typename`关键字指定。N 是一个非类型参数，用来传递数据的值，而不是类型，它和普通函数的形参一样，都需要指明具体的类型。类型参数和非类型参数都可以用在函数体或者类体中。
  - 当调用一个函数模板或者通过一个类模板创建对象时，非类型参数会被用户提供的、或者编译器推断出的值所取代。

- 函数模版中使用非类型参数

  ```
  我们通过 Swap() 函数来交换两个数组的值
  template<typename T> void Swap(T a[], T b[], int len);
  形参 len 用来指明要交换的数组的长度，调用 Swap() 函数之前必须先通过sizeof求得数组长度再传递给它。
  多出来的形参 len 给编码带来了不便，我们可以借助模板中的非类型参数将它消除，
  template<typename T, unsigned N> void Swap(T (&a)[N], T (&b)[N]){
      T temp;
      for(int i=0; i<N; i++){
          temp = a[i];
          a[i] = b[i];
          b[i] = temp;
      }
  }
  T (&a)[N]表明 a 是一个引用，它引用的数据的类型是T [N]，也即一个数组；T (&b)[N]也是类似的道理。分析一个引用和分析一个指针的方法类似，编译器总是从它的名字开始读取，然后按照优先级顺序依次解析
  调用 Swap() 函数时，需要将数组名字传递给它：
  int a[5] = { 1, 2, 3, 4, 5 };
  int b[5] = { 10, 20, 30, 40, 50 };
  Swap(a, b);
  编译器会使用数组类型int来代替类型参数T，使用数组长度5来代替非类型参数N。
  ```

- 类模版使用非类型参数

  ```c++
  C/C++ 规定，数组一旦定义后，它的长度就不能改变了；换句话说，数组容量不能动态地增大或者减小。这样的数组称为静态数组（Static array）。静态数组有时候会给编码代码不便，我们可以通过自定义的 Array 类来实现动态数组（Dynamic array）。所谓动态数组，是指数组容量能够在使用的过程中随时增大或减小。
  template<typename T, int N>
  class Array{
  public:
      Array();
      ~Array();
  public:
      T & operator[](int i);  //重载下标运算符[]
      int length() const { return m_length; }  //获取数组长度
      bool capacity(int n);  //改变数组容量
  private:
      int m_length;  //数组的当前长度
      int m_capacity;  //当前内存的容量（能容乃的元素的个数）
      T *m_p;  //指向数组内存的指针
  };
  template<typename T, int N>
  Array<T, N>::Array(){
      m_p = new T[N];
      m_capacity = m_length = N;
  }
  template<typename T, int N>
  Array<T, N>::~Array(){
      delete[] m_p;
  }
  template<typename T, int N>
  T & Array<T, N>::operator[](int i){
      if(i<0 || i>=m_length){
          cout<<"Exception: Array index out of bounds!"<<endl;
      }
      return m_p[i];
  }
  template<typename T, int N>
  bool Array<T, N>::capacity(int n){
      if(n > 0){  //增大数组
          int len = m_length + n;  //增大后的数组长度
          if(len <= m_capacity){  //现有内存足以容纳增大后的数组
              m_length = len;
              return true;
          }else{  //现有内存不能容纳增大后的数组
              T *pTemp = new T[m_length + 2 * n * sizeof(T)];  //增加的内存足以容纳 2*n 个元素
              if(pTemp == NULL){  //内存分配失败
                  cout<<"Exception: Failed to allocate memory!"<<endl;
                  return false;
              }else{  //内存分配成功
                  memcpy( pTemp, m_p, m_length*sizeof(T) );
                  delete[] m_p;
                  m_p = pTemp;
                  m_capacity = m_length = len;
              }
          }
      }else{  //收缩数组
          int len = m_length - abs(n);  //收缩后的数组长度
          if(len < 0){
              cout<<"Exception: Array length is too small!"<<endl;
              return false;
          }else{
              m_length = len;
              return true;
          }
      }
  }
  int main(){
      Array<int, 5> arr;
      //为数组元素赋值
      for(int i=0, len=arr.length(); i<len; i++){
          arr[i] = 2*i;
      }
     
      //第一次打印数组
      for(int i=0, len=arr.length(); i<len; i++){
          cout<<arr[i]<<" ";
      }
      cout<<endl;
     
      //扩大容量并为增加的元素赋值
      arr.capacity(8);
      for(int i=5, len=arr.length(); i<len; i++){
          arr[i] = 2*i;
      }
      //第二次打印数组
      for(int i=0, len=arr.length(); i<len; i++){
          cout<<arr[i]<<" ";
      }
      cout<<endl;
      //收缩容量
      arr.capacity(-4);
      //第三次打印数组
      for(int i=0, len=arr.length(); i<len; i++){
          cout<<arr[i]<<" ";
      }
      cout<<endl;
      return 0;
  }
  0 2 4 6 8
  0 2 4 6 8 10 12 14 16 18 20 22 24
  0 2 4 6 8 10 12 14 16
  ```

  - Array 是一个类模板，它有一个类型参数`T`和一个非类型参数`N`，T 指明了数组元素的类型，N 指明了数组长度。
  - capacity() 成员函数是 Array 类的关键，它使得数组容量可以动态地增加或者减小。传递给它一个正数时，数组容量增大；传递给它一个负数时，数组容量减小。
  - 之所以能通过`[ ]`来访问数组元素，是因为在 Array 类中以成员函数的形式重载了`[ ]`运算符，并且返回值是数组元素的引用。如果直接返回数组元素的值，那么将无法给数组元素赋值。

- 非类型参数的类型不能随意指定，它受到了严格的限制，只能是一个整数，或者是一个指向对象或函数的指针（也可以是引用）。引用和指针在本质上是一样的

  - 当非类型参数是一个整数时，传递给它的实参，或者由编译器推导出的实参必须是一个常量表达式，例如`10`、`2 * 30`、`18 + 23 - 4`等，但不能是`n`、`n + 10`、`n + m`等（n 和 m 都是变量）。
  - 当非类型参数是一个指针（引用）时，绑定到该指针的实参必须具有静态的生存期；换句话说，实参必须存储在虚拟地址空间中的静态数据区。局部变量位于栈区，动态创建的对象位于堆区，它们都不能用作实参。

##### 模版的多文件编程

- 基于传统的编程思维，初学者往往也会将模板（函数模板和类模板）的声明和定义分散到不同的文件中，以期达到「模块化编程」的目的。但事实证明这种做法是不对的，程序员惯用的做法是将模板的声明和定义都放到头文件中。
- 模板并不是真正的函数或类，它仅仅是用来生成函数或类的一张“图纸”，在这个生成过程中有三点需要明确：
  - 模板的实例化是按需进行的，用到哪个类型就生成针对哪个类型的函数或类，不会提前生成过多的代码；
  - 模板的实例化是由编译器完成的，而不是由链接器完成的；
  - 在实例化过程中需要知道模板的所有细节，包含声明和定义。
- 不能将模板的声明和定义分散到多个文件中」的根本原因是：模板的实例化是由编译器完成的，而不是由链接器完成的，这可能会导致在链接期间找不到对应的实例。

##### 类模版与继承

- 类模板和类模板之间、类模板和类之间可以互相继承。它们之间的派生关系有以下四种情况。

  - 类模版从类模版派生

    ```c++
    template <class T1, class T2>
    class A
    {
        Tl v1; T2 v2;
    };
    template <class T1, class T2>
    class B : public A <T2, T1>
    {
        T1 v3; T2 v4;
    };
    template <class T>
    class C : public B <T, T>
    {
        T v5;
    };
    int main()
    {
        B<int, double> obj1;
        C<int> obj2;
        return 0;
    }
    ```

  - 其余类似

##### 类模版与友元

- 类模版与函数模版在作为友元时模版头要写上，函数或者类前面在写上friend

##### 类模板的静态成员

- 类模板中可以定义静态成员，从该类模板实例化得到的所有类都包含同样的静态成员。

  ```c++
  #include <iostream>
  using namespace std;
  template <class T>
  class A
  {
  private:
      static int count;
  public:
      A() { count ++; }
      ~A() { count -- ; };
      A(A &) { count ++ ; }
      static void PrintCount() { cout << count << endl; }
  };
  template<> int A<int>::count = 0;
  template<> int A<double>::count = 0;
  int main()
  {
      A<int> ia;
      A<double> da;
      ia.PrintCount();
      da.PrintCount();
      return 0;
  }
  1
  1
  ```

  - 对静态成员变量在类外部加以声明是必需的
  - A<int> 和 A<double> 是两个不同的类。虽然它们都有静态成员变量 count，但是显然，A<int> 的对象 ia 和 A<double> 的对象 da 不会共享一份 count。

#### 输入输出流

- C++ 又可以称为“带类的 C”，即可以理解为 C++ 是 C 语言的基础上增加了面向对象（类和对象）

- C 语言的这套 I/O 解决方案也适用于 C++ 程序，但 C++ 并没有“偷懒”，它自己独立开发了一套全新的 I/O 解决方案，其中就包含大家一直使用的 cin 和 cout。前面章节中，我们一直在用 cin 接收从键盘输入的数据，用 cout 向屏幕上输出数据（这 2 个过程又统称为“标准 I/O”）。除此之外，C++ 也对从文件中读取数据和向文件中写入数据做了支持（统称为“文件 I/O”）。

- 本质上来说，C++ 的这套 I/O 解决方案就是一个包含很多类的类库（作为 C++ 标准库的组成部分），这些类常被称为“流类”。

  ![img](http://c.biancheng.net/uploads/allimg/180831/1-1PS1153301321.jpg)

- 其中，图中的箭头代表各个类之间的派生关系。比如，ios 是所有流类的基类，它派生出 istream 和 ostream。特别需要指出的是，为了避免多继承的二义性，从 ios 派生出 istream 和 ostream 时，均使用了 virtual 关键字（虚继承）。

  - istream：常用于接收从键盘输入的数据；
  - ostream：常用于将数据输出到屏幕上；
  - ifstream：用于读取文件中的数据；
  - ofstream：用于向文件中写入数据；
  - iostream：继承自 istream 和 ostream 类，因为该类的功能兼两者于一身，既能用于输入，也能用于输出；
  - fstream：兼 ifstream 和 ofstream 类功能于一身，既能读取文件中的数据，又能向文件中写入数据。

- 在前面章节的学习中，只要涉及输入或者输出数据，我们立马想到的就是 cin 和 cout。其实，cin 就是 istream 类的对象，cout 是 ostream 类的对象，它们都声明在 <iostream> 头文件中，这也解释了“为什么在 C++ 程序中引入 <iostream> 就可以使用 cin 和 cout”（当然使用 cin 和 cout，还需要声明 std 命名空间）。

- <iostream> 头文件中还声明有 2 个 ostream 类对象，分别为 cerr 和 clog。它们的用法和 cout 完全一样，但 cerr 常用来输出警告和错误信息给程序的使用者，clog 常用来输出程序执行过程中的日志信息（此部分信息只有程序开发者看得到，不需要对普通用户公开）。

- cout、cerr 和 clog 之间的区别如下：

  1. cout 除了可以将数据输出到屏幕上，通过重定向（后续会讲），还可以实现将数据输出到指定文件中；而 cerr 和 clog 都不支持重定向，它们只能将数据输出到屏幕上；
  2. cout 和 clog 都设有缓冲区，即它们在输出数据时，会先将要数据放到缓冲区，等缓冲区满或者手动换行（使用换行符 '\n' 或者 endl）时，才会将数据全部显示到屏幕上；而 cerr 则不设缓冲区，它会直接将数据输出到屏幕上。

- 类似 cin、cout、cerr 和 clog 这样，它们都是 C++ 标准库的开发者创建好的，可以直接拿来使用，这种在 C++ 中提前创建好的对象称为内置对象。

- istream 和 ostream 类提供了很多实用的函数，cin、cout、cerr 和 clog 作为类对象，当然也能调用。

- cin输入流对象常用方法

  | 成员方法名        | 功能                                                         |
  | ----------------- | ------------------------------------------------------------ |
  | getline(str,n,ch) | 从输入流中接收 n-1 个字符给 str 变量，当遇到指定 ch 字符时会停止读取，默认情况下 ch 为 '\0'。 |
  | get()             | 从输入流中读取一个字符，同时该字符会从输入流中消失。         |
  | gcount()          | 返回上次从输入流提取出的字符个数，该函数常和 get()、getline()、ignore()、peek()、read()、readsome()、putback() 和 unget() 联用。 |
  | peek()            | 返回输入流中的第一个字符，但并不是提取该字符。               |
  | putback(c)        | 将字符 c 置入输入流（缓冲区）。                              |
  | ignore(n,ch)      | 从输入流中逐个提取字符，但提取出的字符被忽略，不被使用，直至提取出 n 个字符，或者当前读取的字符为 ch。 |
  | operator>>        | 重载 >> 运算符，用于读取指定类型的数据，并返回输入流对象本身。 |

- cout、cerr 和 clog 对象常用的一些成员方法以及它们的功能：

  | 成员方法名 | 功能                                             |
  | ---------- | ------------------------------------------------ |
  | put()      | 输出单个字符。                                   |
  | write()    | 输出指定的字符串。                               |
  | tellp()    | 用于获取当前输出流指针的位置。                   |
  | seekp()    | 设置输出流指针的位置。                           |
  | flush()    | 刷新输出流缓冲区。                               |
  | operator<< | 重载 << 运算符，使其用于输出其后指定类型的数据。 |

##### 输出单个字符

- [C++](http://c.biancheng.net/cplus/) 程序中一般用 ostream 类的 cout 输出流对象和 << 输出运算符实现输出，并且 cout 输出流在内存中有相应的缓冲区。但有时用户还有特殊的输出需求，例如只输出一个字符，这种情况下可以借助该类提供的 put() 成员方法实现。
- put() 方法专用于向输出流缓冲区中添加单个字符，其语法格式如下：ostream＆put(char c);其中，参数 c 为要输出的字符。
- 可以看到，该函数会返回一个 ostream 类的引用对象，可以理解返回的是 cout 的引用。这意味着，我们可以像下面这样使用 put() 函数：cout.put(c1).put(c2).put(c3);因为 cout.put(c1) 向输出流缓冲区中添加 c1 字符的同时，返回一个引用形式的 cout 对象，所以可以继续用此对象调用 put(c2)，依次类推。 

##### 输出字符串

- write() 成员方法专用于向输出流缓冲区中添加指定的字符串，初学者可以简单的理解为输出指定的字符串。其语法格式如下：

  ostream＆write（const char * s，streamsize n）;

  其中，s 用于指定某个长度至少为 n 的字符数组或字符串；n 表示要输出的前 n 个字符。

  可以看到，该函数会返回一个 ostream 类的引用对象，可以理解返回的是 cout 的引用。这意味着，我们可以像下面这样使用 write() 方法：

  cout.write(c1, 1).write(c2, 2).write(c3, 3);

##### cout.tellp()和cout.seekp()方法详解

- 无论是使用 cout 输出普通数据，用 cout.put() 输出指定字符，还是用 cout.write() 输出指定字符串，数据都会先放到输出流缓冲区，待缓冲区刷新，数据才会输出到指定位置（屏幕或者文件中）。

- 当数据暂存于输出流缓冲区中时，我们仍可以对其进行修改。ostream 类中提供有 tellp() 和 seekp() 成员方法，借助它们就可以修改位于输出流缓冲区中的数据。

- tellp() 成员方法用于获取当前输出流缓冲区中最后一个字符所在的位置，其语法格式如下：streampos tellp();tellp() 不需要传递任何参数，会返回一个 streampos 类型值。事实上，streampos 是 fpos 类型的别名，而 fpos 通过自动类型转换，可以直接赋值给一个整形变量（即 short、int 和 long）。也就是说，在使用此函数时，我们可以用一个整形变量来接收该函数的返回值。

  - 当输出流缓冲区中没有任何数据时，该函数返回的整形值为 0；当指定的输出流缓冲区不支持此操作，或者操作失败时，该函数返回的整形值为 -1。

- seekp() 方法用于指定下一个进入输出缓冲区的字符所在的位置。举个例子，假设当前输出缓冲区中存有如下数据：http://c.biancheng.net/cplus/，借助 tellp() 方法得知，最后一个 '/' 字符所在的位置是 29。此时如果继续向缓冲区中存入数据，则下一个字符所在的位置应该是 30，但借助 seekp() 方法，我们可以手动指定下一个字符存放的位置。

  - 比如通过 seekp() 指定下一个字符所在的位置为 23，即对应 "cplus/" 部分中字符 'c' 所在的位置。此时若再向缓冲区中存入 "python/"，则缓冲区中存储的数据就变成了：

    http://c.biancheng.net/python/

    显然，新的 "python/" 覆盖了原来的 "cplus/"。

##### cout格式化输出

- C++ 通常使用 cout 输出数据，和 printf() 函数相比，cout 实现格式化输出数据的方式更加多样化。一方面，cout 作为 ostream 类的对象，该类中提供有一些成员方法，可实现对输出数据的格式化；另一方面，为了方面用户格式化输出数据，C++ 标准库专门提供了一个 <iomanip> 头文件，该头文件中包含有大量的格式控制符（严格意义上称为“流操纵算子”），使用更加方便。

- 《[C++输入流和输出流](http://c.biancheng.net/view/7559.html)》一节中，已经针对 cout 讲解了一些常用成员方法的用法。除此之外，ostream 类中还包含一些可实现格式化输出的成员方法，这些成员方法都是从 ios 基类（以及 ios_base 类）中继承来的，cout（以及 cerr、clog）也能调用。

- ostream 类中可实现格式化输出的常用成员方法

  | 成员函数          | 说明                                                         |
  | ----------------- | ------------------------------------------------------------ |
  | flags(fmtfl)      | 当前格式状态全部替换为 fmtfl。注意，fmtfl 可以表示一种格式，也可以表示多种格式。 |
  | precision(n)      | 设置输出浮点数的精度为 n。                                   |
  | width(w)          | 指定输出宽度为 w 个字符。                                    |
  | fill(c)           | 在指定输出宽度的情况下，输出的宽度不足时用字符 c 填充（默认情况是用空格填充）。 |
  | setf(fmtfl, mask) | 在当前格式的基础上，追加 fmtfl 格式，并删除 mask 格式。其中，mask 参数可以省略。 |
  | unsetf(mask)      | 在当前格式的基础上，删除 mask 格式。                         |
  - 对于表 1 中 flags() 函数的 fmtfl 参数、setf() 函数中的 fmtfl 参数和 mask 参数以及 unsetf() 函数 mask 参数，可以选择表 2 中列出的这些值。

    | 标 志           | 作 用                                                        |
    | --------------- | ------------------------------------------------------------ |
    | ios::boolapha   | 把 true 和 false 输出为字符串                                |
    | ios::left       | 输出数据在本域宽范围内向左对齐                               |
    | ios::right      | 输出数据在本域宽范围内向右对齐                               |
    | ios::internal   | 数值的符号位在域宽内左对齐，数值右对齐，中间由填充字符填充   |
    | ios::dec        | 设置整数的基数为 10                                          |
    | ios::oct        | 设置整数的基数为 8                                           |
    | ios::hex        | 设置整数的基数为 16                                          |
    | ios::showbase   | 强制输出整数的基数（八进制数以 0 开头，十六进制数以 0x 打头） |
    | ios::showpoint  | 强制输出浮点数的小点和尾数 0                                 |
    | ios::uppercase  | 在以科学记数法格式 E 和以十六进制输出字母时以大写表示        |
    | ios::showpos    | 对正数显示“+”号                                              |
    | ios::scientific | 浮点数以科学记数法格式输出                                   |
    | ios::fixed      | 浮点数以定点格式（小数形式）输出                             |
    | ios::unitbuf    | 每次输出之后刷新所有的流                                     |

  - 当调用 unsetf() 或者 2 个参数的 setf() 函数时，为了提高编写代码的效率，可以给 mask 参数传递如下 3 个组合格式：

    - ios::adjustfield：等价于 ios::left | ios::right | ios::internal；
    - ios::basefield：等价于 ios::dec | ios::oct | ios::hex；
    - ios::floatfield：等价于 ios::scientific | ios::fixed。

-  <iomanip> 头文件中定义的一些常用的格式控制符，它们都可用于格式化输出。

  | 流操纵算子          | 作  用                                                       |        |
  | ------------------- | ------------------------------------------------------------ | ------ |
  | *dec                | 以十进制形式输出整数                                         | 常用   |
  | hex                 | 以十六进制形式输出整数                                       |        |
  | oct                 | 以八进制形式输出整数                                         |        |
  | fixed               | 以普通小数形式输出浮点数                                     |        |
  | scientific          | 以科学计数法形式输出浮点数                                   |        |
  | left                | 左对齐，即在宽度不足时将填充字符添加到右边                   |        |
  | *right              | 右对齐，即在宽度不足时将填充字符添加到左边                   |        |
  | setbase(b)          | 设置输出整数时的进制，b=8、10 或 16                          |        |
  | setw(w)             | 指定输出宽度为 w 个字符，或输入字符串时读入 w 个字符。注意，该函数所起的作用是一次性的，即只影响下一次 cout 输出。 |        |
  | setfill(c)          | 在指定输出宽度的情况下，输出的宽度不足时用字符 c 填充（默认情况是用空格填充） |        |
  | setprecision(n)     | 设置输出浮点数的精度为 n。  在使用非 fixed 且非 scientific 方式输出的情况下，n 即为有效数字最多的位数，如果有效数字位数超过 n，则小数部分四舍五人，或自动变为科学计 数法输出并保留一共 n 位有效数字。  在使用 fixed 方式和 scientific 方式输出的情况下，n 是小数点后面应保留的位数。 |        |
  | setiosflags(mask)   | 在当前格式状态下，追加 mask 格式，mask 参数可选择表 2 中的所有值。 |        |
  | resetiosflags(mask) | 在当前格式状态下，删除 mask 格式，mask 参数可选择表 2 中的所有值。 |        |
  | boolapha            | 把 true 和 false 输出为字符串                                | 不常用 |
  | *noboolalpha        | 把 true 和 false 输出为 0、1                                 |        |
  | showbase            | 输出表示数值的进制的前缀                                     |        |
  | *noshowbase         | 不输出表示数值的进制.的前缀                                  |        |
  | showpoint           | 总是输出小数点                                               |        |
  | *noshowpoint        | 只有当小数部分存在时才显示小数点                             |        |
  | showpos             | 在非负数值中显示 +                                           |        |
  | *noshowpos          | 在非负数值中不显示 +                                         |        |
  | uppercase           | 十六进制数中使用 A~E。若输出前缀，则前缀输出 0X，科学计数法中输出 E |        |
  | *nouppercase        | 十六进制数中使用 a~e。若输出前缀，则前缀输出 0x，科学计数法中输出 e。 |        |
  | internal            | 数值的符号（正负号）在指定宽度内左对齐，数值右对 齐，中间由填充字符填充。 |        |
  - “流操纵算子”一栏带有星号 * 的格式控制符，默认情况下就会使用。例如在默认情况下，整数是用十进制形式输出的，等效于使用了 dec 格式控制符。

    ```c
     //以十六进制输出整数
        cout << hex << 16 << endl;
        //删除之前设定的进制格式，以默认的 10 进制输出整数
        cout << resetiosflags(ios::basefield)<< 16 << endl;
        double a = 123;
        //以科学计数法的方式输出浮点数
        cout << scientific << a << endl;
        //删除之前设定的科学计数法的方法
        cout << resetiosflags(ios::scientific) << a << endl;
        return 0;
    }
    
    10
    16
    1.230000e+02
    123
    ```

  - 如果两个相互矛盾的标志同时被设置，如先设置 setiosflags(ios::fixed)，然后又设置 setiosflags(ios::scientific)，那么结果可能就是两个标志都不起作用。因此，在设置了某标志，又要设置其他与之矛盾的标志时，就应该用 resetiosflags 清除原先的标志。

##### 对输入输出重定向

- cout 和 cerr、clog 的一个区别是，cout 允许被重定向，而 cerr 和 clog 都不支持。值得一提的是，cin 也允许被重定向。

- 那么，什么是重定向呢？在默认情况下，cin 只能接收从键盘输入的数据，cout 也只能将数据输出到屏幕上。但通过重定向，cin 可以将指定文件作为输入源，即接收文件中早已准备好的数据，同样 cout 可以将原本要输出到屏幕上的数据转而写到指定文件中。

- freopen()函数实现重定向

  - freopen() 定义在`<stdio.h>`头文件中，是 C 语言标准库中的函数，专门用于重定向输入流（包括 scanf()、gets() 等）和输出流（包括 printf()、puts() 等）。值得一提的是，该函数也可以对 C++ 中的 cin 和 cout 进行重定向。

    ```c
     string name, url;
        //将标准输入流重定向到 in.txt 文件
        freopen("in.txt", "r", stdin);
        cin >> name >> url;
        //将标准输出重定向到 out.txt文件
        freopen("out.txt", "w", stdout); 
        cout << name << "\n" << url;
        return 0;
    }
    执行此程序之前，我们需要找到当前程序文件所在的目录，并手动创建一个 in.txt 文件，其包含的内容如下：
    C++
    http://c.biancheng.net/cplus/
    
    创建好 in.txt 文件之后，可以执行此程序，其执行结果为：
        <--控制台中，既不需要手动输入，也没有任何输出
    
    与此同时，in.txt 文件所在目录下会自动生成一个 out.txt 文件，其包含的内容和 in.txt 文件相同：
    C++
    http://c.biancheng.net/cplus/
    
    显然，通过 2 次调用 freopen() 函数，分别对输入流和输出流重定向，使得 cin 不再接收由键盘输入的数据，而是直接从 in.txt 文件中获取数据；同样，cout 也不再将数据输出到屏幕上，而是写入到 out.txt 文件中。
    ```

- rdbuf()函数实现重定向

  - rdbuf() 函数定义在`<ios>`头文件中，专门用于实现 C++ 输入输出流的重定向。值得一提的是，ios 作为 istream 和 ostream 类的基类，rdbuf() 函数也被继承，因此 cin 和 cout 可以直接调用该函数实现重定向。

  - rdbuf() 函数的语法格式有 2 种，分别为：

    ```
    streambuf * rdbuf() const;
    streambuf * rdbuf(streambuf * sb);
    ```

  - streambuf 是 C++ 标准库中用于表示缓冲区的类，该类的指针对象用于代指某个具体的流缓冲区。

  - 第一种语法格式仅是返回一个指向当前流缓冲区的指针；第二种语法格式用于将 sb 指向的缓冲区设置为当前流的新缓冲区，并返回一个指向旧缓冲区的对象。

    ```c
     //打开 in.txt 文件，等待读取
        ifstream fin("in.txt");
        //打开 out.txt 文件，等待写入
        ofstream fout("out.txt");
        streambuf *oldcin;
        streambuf *oldcout;
        char a[100];
        //用 rdbuf() 重新定向，返回旧输入流缓冲区指针
        oldcin = cin.rdbuf(fin.rdbuf());
        //从input.txt文件读入
        cin >> a;
        //用 rdbuf() 重新定向，返回旧输出流缓冲区指针
        oldcout = cout.rdbuf(fout.rdbuf());
        //写入 out.txt
        cout << a << endl;
        //还原标准输入输出流
        cin.rdbuf(oldcin); // 恢复键盘输入
        cout.rdbuf(oldcout); //恢复屏幕输出
        //打开的文件，最终需要手动关闭
        fin.close();
        fout.close();
        return 0;
    }
    ```

- 通过控制台实现重定向

  - 打开控制台（Windows 系统下指的是 CMD命令行窗口，Linux 系统下指的是 Shell 终端）
  - 在控制台中使用 > 或者 < 实现重定向的方式，DOS、windows、Linux 以及 UNIX 都能自动识别。

##### 管理输出缓冲区

- 有了缓冲机制，操作系统就可以将程序的多个输出操作组合成单一的系统级写操作。由于设备的写操作可能很耗时，允许操作系统将多个输出操作组合为单一的设备写操作可以带来很大的性能提升。
- 导致缓冲刷新（数据真正写到输出设备或文件）的原因有很多：
  - 程序正常结束，作为 main() 函数的 return 操作的一部分，缓冲刷新被执行。
  - 缓冲区满时，需要刷新缓冲，而后新的数据才能继续写入缓冲区。
  - 我们可以使用操纵符如 endl 来显式刷新缓冲区。
  - 在每个输出操作之后，我们可以用操作符 unitbuf 设置流的内部状态，来清空缓冲区。默认情况下，对 cerr 是设置 unitbuf 的，因此写到 cerr 的内容都是立即刷新的。
  - 一个输出流可能被关联到另一个流。在这种情况下，当读写被关联的流时，关联到的流的缓冲区会被刷新。例如，默认情况下，cin 和 cerr 都关联到 cout。因此，读 cin 或写 cerr 都会导致 cout 的缓冲区被刷新。
- 我们已经使用过操作符 endl，它完成换行并刷新缓冲区的工作。IO 库中还有两个类似的操纵符：
  - flush 和 ends。flush 刷新缓冲区，但不输出任何额外的字符；
  - ends向缓冲区插入一个空字符，然后刷新缓冲区。

- cout 所属 ostream 类中还提供有 flush() 成员方法，它和 flush 操纵符的功能完全一样，仅在使用方法上（ cout.flush() ）有区别。

```c
cout << "hi!" << endl;  //输出hi和一个换行，然后刷新缓冲区
cout << "hi!" << flush;  //输出hi，然后刷新缓冲区，不附加任何额外字符
cout << "hi!" << ends;  //输出hi和一个空字符，然后刷新缓冲区
```

- 如果想在每次输出操作后都刷新缓冲区，我们可以使用 unitbuf 操作符，它告诉流在接下来的每次写操作之后都进行一次 flush 操作。而 nounitbuf 操作符则重置流， 使其恢复使用正常的系统管理的缓冲区刷新机制：

  - ```c
    cout << unitbuf;  //所有输出操作后都会立即刷新缓冲区
    //任何输出都立即刷新，无缓冲
    cout << nounitbuf;  //回到正常的缓冲方式
    ```

  - 如果程序异常终止，输出缓冲区是不会被刷新的。当一个程序崩溃后，它所输出的数据很可能停留在输出缓冲区中等待打印。

  - 当调试一个已经崩溃的程序时，需要确认那些你认为已经输出的数据确实已经刷新了。否则，可能将大量时间浪费在追踪代码为什么没有执行上，而实际上代码已经执行了，只是程序崩溃后缓冲区没有被刷新，输出数据被挂起没有打印而已。

- 当一个输入流被关联到一个输出流时，任何试图从输入流读取数据的操作都会先刷新关联的输出流。标准库将 cout 和 cin 关联在一起

  - 交互式系统通常应该关联输入流和输出流。这意味着所有输出，包括用户提示信息，都会在读操作之前被打印出来。

  - tie() 函数可以用来绑定输出流，它有两个重载的版本：

    ```c
    ostream* tie ( ) const; //返回指向绑定的输出流的指针。
    ostream* tie ( ostream* os ); //将 os 指向的输出流绑定的该对象上，并返回上一个绑定的输出流指针。
    第一个版本不带参数，返冋指向出流的指针。如果本对象当前关联到一个输出流，则返回的就是指向这个流的指针，如果对象未关联到流，则返回空指针。
    tie() 的第二个版本接受一个指向 ostream 的指针，将自己关联到此 ostream，即，x.tie(&o) 将流 x 关联到输出流 o。
    cin.tie(&cout);  //仅仅是用来展示，标准库已经将 cin 和 cout 关联在一起
    //old_tie 指向当前关联到 cin 的流（如果有的话）
    ostream *old_tie = cin.tie(nullptr);  // cin 不再与其他流关联
    //将 cin 与 cerr 关联，这不是一个好主意，因为 cin 应该关联到 cout
    cin.tie(&cerr);  //读取 cin 会刷新 cerr 而不是 cout
    cin.tie(old_tie);  //重建 cin 和 cout 间的正常关联
    ```

##### 读取单个字符

- get() 是 istream 类的成员函数，它有多种重载形式，最简单最常用的一种：int get();此函数从输入流中读入一个字符，返回值就是该字符的 ASCII 码。如果碰到输入的末尾，则返回值为 EOF。EOF 是 End of File 的缩写。istream 类中从输入流（包括文件）中读取数据的成员函数，在把输入数据都读取完后再进行读取，就会返回 EOF。EOF 是在 iostream 类中定义的一个整型常量，值为 -1。
- get() 函数不会跳过空格、制表符、回车等特殊字符，所有的字符都能被读入

##### 读入一行字符串

- getline() 是 istream 类的成员函数，它有如下两个重载版本：

  ```
  istream & getline(char* buf, int bufSize);
  istream & getline(char* buf, int bufSize, char delim);
  ```

- 第一个版本从输入流中读取 bufSize-1 个字符到缓冲区 buf，或遇到`\n`为止（哪个条件先满足就按哪个执行）。函数会自动在 buf 中读入数据的结尾添加`\0`。
- 第二个版本和第一个版本的区别在于，第一个版本是读到`\n`为止，第二个版本是读到 delim 字符为止。`\n`或 delim 都不会被读入 buf，但会被从输入流中取走。

##### 跳过指定字符

- ignore() 是 istream 类的成员函数，它的原型是：

  ```
  istream & ignore(int n =1, int delim = EOF);
  ```

- 此函数的作用是跳过输入流中的 n 个字符，或跳过 delim 及其之前的所有字符，哪个条件先满足就按哪个执行。两个参数都有默认值，因此 cin.ignore() 就等效于 cin.ignore(1, EOF)， 即跳过一个字符。

- 该函数常用于跳过输入中的无用部分，以便提取有用的部分。例如，输入的电话号码形式是`Tel:63652823`，`Tel:`就是无用的内容

##### 查看输入流中的下一个字符

- peek() 是 istream 类的成员函数，它的原型是：int peek();此函数返回输入流中的下一个字符，但是并不将该字符从输入流中取走——相当于只是看了一眼下一个字符，因此叫 peek。

- cin.peek() 不会跳过输入流中的空格、回车符。在输入流已经结束的情况下，cin.peek() 返回 EOF。

- 在输入数据的格式不同，需要预先判断格式再决定如何输入时，peek() 就能起到作用。

- 例题：编写一个日期格式转换程序，输入若干个日期，每行一个，要求全部转换为“mm-dd-yyyy”格式输出。输入的日期格式可以是“2011.12.24”（中式格式），也可以是“Dec 24 2011”（西式格式）

  - 编写这个程序时，如果输入的是中式格式，就用 cin>>year（假设 year 是 int 类型变量）读取年份，然后再读取后面的内容；如果输入是西式格式，就用 cin>>sMonth（假设 sMonth 是 string 类型对象）读取月份，然后读取后面的内容。

  - 可是，如果没有将数据从输入流中读取出来，就无法判断输入到底是哪种格式。即便用 cin.get() 读取一个字符后再作判断，也很不方便。例如，在输入为`2011.12.24`的情况下，读取第一个字符`2`后就知道是格式一，问题是输入流中的已经被读取了，剩下的表示年份的部分只有`011`，如何将这个`011`和前面读取的`2`奏成一个整数 2011，也是颇费周折的事情。使用 peek() 函数很容易解决这个问题。

    ```c
    #include <iostream>
    #include <iomanip>
    #include <string>
    using namespace std;
    string Months[12] = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug", "Sep","Oct","Nov","Dec" };
    int main()
    {
        int c;
        while((c = cin.peek()) != EOF) { //取输入流中的第一个字符进行查看
             int year,month,day;
             if(c >= 'A' && c <= 'Z') { //美国日期格式
                string sMonth;
                cin >> sMonth >> day >> year;
                for(int i = 0;i < 12; ++i)  //查找月份
                       if(sMonth == Months[i]) {
                        month = i + 1;
                        break;
                    }
            }
            else { //中国日期格式
                cin >> year ;
                cin.ignore() >> month ; //用ignore跳过 "2011.12.3"中的'.'
                cin.ignore() >> day;
            }
            cin.ignore();   //跳过行末 '\n'
            cout<< setfill('0') << setw(2) << month ;//设置填充字符'\0'，输出宽度2
            cout << "-" << setw(2) << day << "-" << setw(4) << year << endl;
        }
        return 0;
    }
    ```

  - istream 还有一个成员函数 istream & putback(char c)，可以将一个字符插入输入流的最前面。对于上面的例题，也可以在用 get() 函数读取一个字符并判断是中式格式还是西式格式时，将刚刚读取的字符再用 putback() 成员函数放回流中，然后再根据判断结果进行不同方式的读入。

##### cin判断输入结束

- cin 可以用来从键盘输入数据；将标准输入重定向为文件后，cin 也可以用来从文件中读入数据。在输入数据的多少不确定，且没有结束标志的情况下，该如何判断输入数据已经读完了呢？
- 在控制台中输入特殊的控制字符就表示输入结束了：
  - 在 Windows 系统中，通过键盘输入时，按 Ctrl+Z 组合键后再按回车键，就代表输入结束。
  - 在 UNIX/Linux/Mac OS 系统中，Ctrl+D 代表输入结束。
- 不管是文件末尾，还是 Ctrl+Z 或者 Ctrl+D，它们都是结束标志；cin 在正常读取时返回 true，遇到结束标志时返回 false，我们可以根据 cin 的返回值来判断是否读取结束。
- 此种情况用在while循环读入时，我们不知道什么时候结束，所以要用一个结束标志。回车只是刷新缓冲区的，我们每次输入刷新缓冲区，但是读入一直在读入，所以要找一个结束标志。

##### 处理输入输出错误

- 当处理输入输出时，我们必须预计到其中可能发生的错误并给出相应的处理措施。

  - 当我们输入时，可能会由于人的失误（错误理解了指令、打字错误、允许自家的小猫在键盘上散步等）、文件格式不符、错误估计了情况等原因造成读取失败。
  - 当我们输出时，如果输出设备不可用、队列满或者发生了故障等，都会导致写入失败。

- 发生输入输出错误的可能情况是无限的！但 C++ 将所有可能的情况归结为四类，称为流状态（stream state）。每种流状态都用一个 iostate 类型的标志位来表示。

  | 标志位  | 意义                                                         |
  | ------- | ------------------------------------------------------------ |
  | badbit  | 发生了（或许是物理上的）致命性错误，流将不能继续使用。       |
  | eofbit  | 输入结束（文件流的物理结束或用户结束了控制台流输入，例如用户按下了 Ctrl+Z 或 Ctrl+D 组合键。 |
  | failbit | I/O 操作失败，主要原因是非法数据（例如，试图读取数字时遇到字母）。流可以继续使用，但会设置 failbit 标志。 |
  | goodbit | 一切止常，没有错误发生，也没有输入结束。                     |
  - ios_base 类定义了以上四个标志位以及 iostate 类型，但是 ios 类又派生自 ios_base 类，所以可以使用 ios::failbit 代替 ios_base::failbit 以节省输入。

- 一旦流发生错误，对应的标志位就会被设置，我们可以通过下表列出的函数检测流状态。

  | 检测函数 | 对应的标志位 | 说明                                                         |
  | -------- | ------------ | ------------------------------------------------------------ |
  | good()   | goodbit      | 操作成功，没有发生任何错误。                                 |
  | eof()    | eofbit       | 到达输入末尾或文件尾。                                       |
  | fail()   | failbit      | 发生某些意外情况（例如，我们要读入一个数字，却读入了字符 'x'）。 |
  | bad()    | badbit       | 发生严重的意外（如磁盘读故障）。                             |

- 不幸的是，fail() 和 bad() 之间的区别并未被准确定义，程序员对此的观点各种各样。但是，基本的思想很简单：

  - 如果输入操作遇到一个简单的格式错误，则使流进入 fail() 状态，也就是假定我们（输入操作的用户）可以从错误中恢复。

  - 如果错误真的非常严重，例如发生了磁盘故障，输入操作会使得流进入 bad() 状态。也就是假定面对这种情况你所能做的很有限，只能退出输入。

    ```c
    int i = 0;
    cin >> i;
    if(!cin){  //只有输入操作失败，才会跳转到这里
        if(cin.bad()){  //流发生严重故障，只能退出函数
            error("cin is bad!");  //error是自定义函数，它抛出异常，并给出提示信息
        }
        if(cin.eof()){  //检测是否读取结束
            //TODO:
        }
        if(cin.fail()){  //流遇到了一些意外情况
            cin.clear(); //清除/恢复流状态
            //TODO:
        }
    }
    ```

  - 请注意我们在处理 fail() 时所使用的 cin.clear()。当流发生错误时，我们可以进行错误恢复。为了恢复错误，我们显式地将流从 fail() 状态转移到其他状态，从而可以继续从中读取字符。clear() 就起到这样的作用——执行 cin.clear() 后，cin 的状态就变为 good()。

- 与 istream—样，ostream 也有四个状态：good()、fail()、eof() 和 bad()。不过，对于本教程的读者来说，输出错误要比输入错误少得多，因此通常不对 ostream 进行状态检测。如果程序运行环境中输出设备不可用、队列满或者发生故障的概率很高，我们就可以像处理输入操作那样，在每次输出操作之后都检测其状态。

#### 文件操作

- 重定向后的 cin 和 cout 可分别用于读取文件中的数据和向文件中写入数据。除此之外，C++ 标准库中还专门提供了 3 个类用于实现文件操作，它们统称为文件流类，这 3 个类分别为：这 3 个文件流类都位于 <fstream> 头文件中

  - ifstream：专用于从文件中读取数据；
  - ofstream：专用于向文件中写入数据；
  - fstream：既可用于从文件中读取数据，又可用于向文件中写入数据。

- ifstream 类和 fstream 类是从 istream 类派生而来的，因此 ifstream 类拥有 istream 类的全部成员方法。同样地，ofstream 和 fstream 类也拥有 ostream 类的全部成员方法。这也就意味着，istream 和 ostream 类提供的供 cin 和 cout 调用的成员方法，也同样适用于文件流。并且这 3 个类中有些成员方法是相同的，比如 operator <<()、operator >>()、peek()、ignore()、getline()、get() 等。

- 和 <iostream> 头文件中定义有 ostream 和 istream 类的对象 cin 和 cout 不同，<fstream> 头文件中并没有定义可直接使用的 fstream、ifstream 和 ofstream 类对象。因此，如果我们想使用该类操作文件，需要自己创建相应类的对象。

- 为什么 C++ 标准库不提供现成的类似 fin 或者 fout 的对象呢？其实很简单，文件输入流和输出流的输入输出设备是硬盘中的文件，硬盘上有很多文件，到底应该使用哪一个呢？所以，C++ 标准库就把创建文件流对象的任务交给用户了。

- fstream 类拥有 ifstream 和 ofstream 类中所有的成员方法

  | 成员方法名        | 适用类对象                                                   | 功  能                                     |
  | ----------------- | ------------------------------------------------------------ | ------------------------------------------ |
  | open()            | fstream ifstream ofstream                                    | 打开指定文件，使其与文件流对象相关联。     |
  | is_open()         | 检查指定文件是否已打开。                                     |                                            |
  | close()           | 关闭文件，切断和文件流对象的关联。                           |                                            |
  | swap()            | 交换 2 个文件流对象。                                        |                                            |
  | operator>>        | fstream ifstream                                             | 重载 >> 运算符，用于从指定文件中读取数据。 |
  | gcount()          | 返回上次从文件流提取出的字符个数。该函数常和 get()、getline()、ignore()、peek()、read()、readsome()、putback() 和 unget() 联用。 |                                            |
  | get()             | 从文件流中读取一个字符，同时该字符会从输入流中消失。         |                                            |
  | getline(str,n,ch) | 从文件流中接收 n-1 个字符给 str 变量，当遇到指定 ch 字符时会停止读取，默认情况下 ch 为 '\0'。 |                                            |
  | ignore(n,ch)      | 从文件流中逐个提取字符，但提取出的字符被忽略，不被使用，直至提取出 n 个字符，或者当前读取的字符为 ch。 |                                            |
  | peek()            | 返回文件流中的第一个字符，但并不是提取该字符。               |                                            |
  | putback(c)        | 将字符 c 置入文件流（缓冲区）。                              |                                            |
  | operator<<        | fstream ofstream                                             | 重载 << 运算符，用于向文件中写入指定数据。 |
  | put()             | 向指定文件流中写入单个字符。                                 |                                            |
  | write()           | 向指定文件中写入字符串。                                     |                                            |
  | tellp()           | 用于获取当前文件输出流指针的位置。                           |                                            |
  | seekp()           | 设置输出文件输出流指针的位置。                               |                                            |
  | flush()           | 刷新文件输出流缓冲区。                                       |                                            |
  | good()            | fstream ofstream ifstream                                    | 操作成功，没有发生任何错误。               |
  | eof()             | 到达输入末尾或文件尾。                                       |                                            |

#### 多文件编程

- 多文件编程中代码的划分原则是：将变量、函数或者类的声明部分存放在 .h 文件，对应的实现部分放在 .cpp 文件中。值得一提得是，此规律适用于大部分场景，但本节要讲的 const 常量是一个例外。

- 用 const 修饰的变量必须在定义的同时进行初始化操作（除非用 extern 修饰，本节后续会讲解）。与此同时，C++ 中 const 关键字的功能有 2 个，除了表明其修饰的变量为常量外，还将所修饰变量的可见范围限制为当前文件。这意味着，除非 const 常量的定义和 main 主函数位于同一个 .cpp 文件，否则该 const 常量只能在其所在的 .cpp 文件中使用。

- 如何定义 const 常量，才能在其他文件中使用呢？接下来给读者介绍 3 种在 C++ 多文件编程中定义 const 常量的方法。

  - 将const常量定义在头文件中

  - 借助extern先声明在定义const常量。const 常量的定义也可以遵循“声明在 .h 文件，定义在 .cpp 文件”，借助 extern 关键字即可

    ```c
    //demo.h
    #ifndef _DEMO_H
    #define _DEMO_H
    extern const int num;  //声明 const 常量
    #endif
    //demo.cpp
    #include "demo.h"   //一定要引入该头文件
    const int num =10;  //定义 .h 文件中声明的 num 常量
    //main.cpp
    #include <iostream>
    #include "demo.h"
    int main() {
        std::cout << num << std::endl;
        return 0;
    }
    ```

  - C++ const 关键字会限定变量的可见范围为当前文件，即无法在其它文件中使用该常量。而 extern 关键字会 const 限定可见范围的功能，它可以使 const 常量的可见范围恢复至整个项目。

  - 在变量或者函数之前加上`extern`关键字表明这是一个声明, 其定义可能在其他文件处,

- 内联函数（用 inline 修饰的函数）是需要编译器在编译阶段根据其定义将它内联展开的（类似宏展开），而并非像普通函数那样先声明再链接。这就意味着，编译器必须在编译时就找到内联函数的完整定义。显然，把内联函数的定义放进一个头文件中是非常明智的做法。

### c++11

#### auto关键字

- 在之前的 C++ 版本中，auto 关键字用来指明变量的存储类型，它和 static 关键字是相对的。auto 表示变量是自动存储的，这也是编译器的默认规则，所以写不写都一样，一般我们也不写，这使得 auto 关键字的存在变得非常鸡肋。

- C++11 赋予 auto 关键字新的含义，使用它来做自动类型推导。也就是说，使用了 auto 关键字以后，编译器会在编译期间自动推导出变量的类型，这样我们就不用手动指明变量的数据类型了。

- auto 仅仅是一个占位符，在编译器期间它会被真正的类型所替代。或者说，C++ 中的变量必须是有明确类型的，只是这个类型是由编译器自己推导出来的。

  ```c++
  auto n = 10;
  auto f = 12.8;
  auto p = &n;
  auto url = "http://c.biancheng.net/cplus/";
  第 1 行中，10 是一个整数，默认是 int 类型，所以推导出变量 n 的类型是 int。
  第 2 行中，12.8 是一个小数，默认是 double 类型，所以推导出变量 f 的类型是 double。
  第 3 行中，&n 的结果是一个 int* 类型的指针，所以推导出变量 p 的类型是 int*。
  第 4 行中，由双引号""包围起来的字符串是 const char* 类型，所以推导出变量 url 的类型是 const char*，也即一个常量指针。
  
  我们也可以连续定义多个变量
  int n = 20;
  auto *p = &n, m = 99;
  先看前面的第一个子表达式，&n 的类型是 int*，编译器会根据 auto *p 推导出 auto 为 int。后面的 m 变量自然也为 int 类型，所以把 99 赋值给它也是正确的。
  这里我们要注意，推导的时候不能有二义性。在本例中，编译器根据第一个子表达式已经推导出 auto 为 int 类型，那么后面的 m 也只能是 int 类型，如果写作m=12.5就是错误的，因为 12.5 是double 类型，这和 int 是冲突的。
  还有一个值得注意的地方是：使用 auto 类型推导的变量必须马上初始化，这个很容易理解，因为 auto 在 C++11 中只是“占位符”，并非如 int 一样的真正的类型声明。
  ```

  ```c++
  auto 除了可以独立使用，还可以和某些具体类型混合使用，这样 auto 表示的就是“半个”类型，而不是完整的类型。
  int  x = 0;
  auto *p1 = &x;   //p1 为 int *，auto 推导为 int
  auto  p2 = &x;   //p2 为 int*，auto 推导为 int*
  auto &r1  = x;   //r1 为 int&，auto 推导为 int
  auto r2 = r1;    //r2 为  int，auto 推导为 int
  第 2 行代码中，p1 为 int* 类型，也即 auto * 为 int *，所以 auto 被推导成了 int 类型。
  第 3 行代码中，auto 被推导为 int* 类型，前边的例子也已经演示过了。
  第 4 行代码中，r1 为 int & 类型，auto 被推导为 int 类型。
  第 5 行代码是需要重点说明的，r1 本来是 int& 类型，但是 auto 却被推导为 int 类型，这表明当=右边的表达式是一个引用类型时，auto 会把引用抛弃，直接推导出它的原始类型。
  
  auto 和 const 的结合：
  int  x = 0;
  const  auto n = x;  //n 为 const int ，auto 被推导为 int
  auto f = n;      //f 为 const int，auto 被推导为 int（const 属性被抛弃）
  const auto &r1 = x;  //r1 为 const int& 类型，auto 被推导为 int
  auto &r2 = r1;  //r1 为 const int& 类型，auto 被推导为 const int 类型
  第 2 行代码中，n 为 const int，auto 被推导为 int。
  第 3 行代码中，n 为 const int 类型，但是 auto 却被推导为 int 类型，这说明当=右边的表达式带有 const 属性时， auto 不会使用 const 属性，而是直接推导出 non-const 类型。
  第 4 行代码中，auto 被推导为 int 类型，这个很容易理解，不再赘述。
  第 5 行代码中，r1 是 const int & 类型，auto 也被推导为 const int 类型，这说明当 const 和引用结合时，auto 的推导将保留表达式的 const 类型。
  ```

- 最后我们来简单总结一下 auto 与 const 结合的用法：

  - 当类型不为引用时，auto 的推导结果将不保留表达式的 const 属性；
  - 当类型为引用时，auto 的推导结果将保留表达式的 const 属性。

- auto的限制

  - auto 不能在函数的参数中使用。这个应该很容易理解，我们在定义函数的时候只是对参数进行了声明，指明了参数的类型，但并没有给它赋值，只有在实际调用函数的时候才会给参数赋值；而 auto 要求必须对变量进行初始化，所以这是矛盾的。

  - auto 不能作用于类的非静态成员变量（也就是没有 static 关键字修饰的成员变量）中。

  - auto 关键字不能定义数组

  -  auto 不能作用于模板参数

    ```c++
    template <typename T>
    class A{
        //TODO:
    };
    int  main(){
        A<int> C1;
        A<auto> C2 = C1;  //错误
        return 0;
    }
    ```

- auto的应用

  - auto 的一个典型应用场景是用来定义 stl 的迭代器。我们在使用 stl 容器的时候，需要使用迭代器来遍历容器里面的元素；不同容器的迭代器有不同的类型，在定义迭代器时必须指明。而迭代器的类型有时候比较复杂，书写起来很麻烦

    ```c++
    int main(){
        vector< vector<int> > v;
        vector< vector<int> >::iterator i = v.begin();
        return 0;
    }
    
    int main(){
        vector< vector<int> > v;
        auto i = v.begin();  //使用 auto 代替具体的类型
        return 0;
    }
    auto 可以根据表达式 v.begin() 的类型（begin() 函数的返回值类型）来推导出变量 i 的类型。
    ```

  - auto 的另一个应用就是当我们不知道变量是什么类型，或者不希望指明具体类型的时候，比如泛型编程中

    ```c++
    #include <iostream>
    using namespace std;
    class A{
    public:
        static int get(void){
            return 100;
        }
    };
    class B{
    public:
        static const char* get(void){
            return "http://c.biancheng.net/cplus/";
        }
    };
    template <typename T>
    void func(void){
        auto val = T::get();
        cout << val << endl;
    }
    int main(void){
        func<A>();
        func<B>();
        return 0;
    }
    本例中的模板函数 func() 会调用所有类的静态函数 get()，并对它的返回值做统一处理，但是 get() 的返回值类型并不一样，而且不能自动转换。这种要求在以前的 C++ 版本中实现起来非常的麻烦，需要额外增加一个模板参数，并在调用时手动给该模板参数赋值，用以指明变量 val 的类型。
    但是有了 auto 类型自动推导，编译器就根据 get() 的返回值自己推导出 val 变量的类型，就不用再增加一个模板参数了。
    
    下面的代码演示了不使用 auto 的解决办法：
    #include <iostream>
    using namespace std;
    class A{
    public:
        static int get(void){
            return 100;
        }
    };
    class B{
    public:
        static const char* get(void){
            return "http://c.biancheng.net/cplus/";
        }
    };
    template <typename T1, typename T2>  //额外增加一个模板参数 T2
    void func(void){
        T2 val = T1::get();
        cout << val << endl;
    }
    int main(void){
        //调用时也要手动给模板参数赋值
        func<A, int>();
        func<B, const char*>();
        return 0;
    }
    ```

#### decltype

- decltype 是 [C++](http://c.biancheng.net/cplus/)11 新增的一个关键字，它和 auto 的功能一样，都用来在编译时期进行自动类型推导。decltype 是“declare type”的缩写，译为“声明类型”。

- 既然已经有了 auto 关键字，为什么还需要 decltype 关键字呢？因为 auto 并不适用于所有的自动类型推导场景，在某些特殊情况下 auto 用起来非常不方便，甚至压根无法使用，所以 decltype 关键字也被引入到 C++11 中。

- auto 和 decltype 关键字都可以自动推导出变量的类型，但它们的用法是有区别的：

  ```c++
  auto varname = value;
  decltype(exp) varname = value;
  auto 根据=右边的初始值 value 推导出变量的类型，而 decltype 根据 exp 表达式推导出变量的类型，跟=右边的 value 没有关系。
  另外，auto 要求变量必须初始化，而 decltype 不要求。这很容易理解，auto 是根据变量的初始值来推导出变量类型的，如果不初始化，变量的类型也就无法推导了c
  ```

- 原则上讲，exp 就是一个普通的表达式，它可以是任意复杂的形式，但是我们必须要保证 exp 的结果是有类型的，不能是 void；例如，当 exp 调用一个返回值类型为 void 的函数时，exp 的结果也是 void 类型，此时就会导致编译错误。

  ```c++
  int a = 0;
  decltype(a) b = 1;  //b 被推导成了 int
  decltype(10.8) x = 5.5;  //x 被推导成了 double
  decltype(x + 100) y;  //y 被推导成了 double
  ```

- 当程序员使用 decltype(exp) 获取类型时，编译器将根据以下三条规则得出结果：

  - 如果 exp 是一个不被括号`( )`包围的表达式，或者是一个类成员访问表达式，或者是一个单独的变量，那么 decltype(exp) 的类型就和 exp 一致，这是最普遍最常见的情况。

  - 如果 exp 是函数调用，那么 decltype(exp) 的类型就和函数返回值的类型一致。需要注意的是，exp 中调用函数时需要带上括号和参数，但这仅仅是形式，并不会真的去执行函数代码。

  - 如果 exp 是一个左值，或者被括号`( )`包围，那么 decltype(exp) 的类型就是 exp 的引用；假设 exp 的类型为 T，那么 decltype(exp) 的类型就是 T&。

    ```c++
    exp 是左值，或者被( )包围：
    using namespace std;
    class Base{
    public:
        int x;
    };
    int main(){
        const Base obj;
        //带有括号的表达式
        decltype(obj.x) a = 0;  //obj.x 为类的成员访问表达式，符合推导规则一，a 的类型为 int
        decltype((obj.x)) b = a;  //obj.x 带有括号，符合推导规则三，b 的类型为 int&。
        //加法表达式
        int n = 0, m = 0;
        decltype(n + m) c = 0;  //n+m 得到一个右值，符合推导规则一，所以推导结果为 int
        decltype(n = n + m) d = c;  //n=n+m 得到一个左值，符号推导规则三，所以推导结果为 int&
        return 0;
    }
    ```

  - 左值和右值：左值是指那些在表达式执行结束后依然存在的数据，也就是持久性的数据；右值是指那些在表达式执行结束后不再存在的数据，也就是临时性的数据。有一种很简单的方法来区分左值和右值，对表达式取地址，如果编译器不报错就为左值，否则为右值。

- decltype的实际应用

  - auto 的语法格式比 decltype 简单，所以在一般的类型推导中，使用 auto 比使用 decltype 更加方便

  - auto 只能用于类的静态成员，不能用于类的非静态成员（普通成员），如果我们想推导非静态成员的类型，这个时候就必须使用 decltype 了。下面是一个模板的定义：

    ```c++
    #include <vector>
    using namespace std;
    template <typename T>
    class Base {
    public:
        void func(T& container) {
            m_it = container.begin();
        }
    private:
        typename T::iterator m_it;  //注意这里,传入一个容器的时候也得带上类型vector<int>，所以这个是正确的
    };
    int main()
    {
        const vector<int> v;
        Base<const vector<int>> obj;
        obj.func(v);
        return 0;
    }
    单独看 Base 类中 m_it 成员的定义，很难看出会有什么错误，但在使用 Base 类的时候，如果传入一个 const 类型的容器，编译器马上就会弹出一大堆错误信息。原因就在于，T::iterator并不能包括所有的迭代器类型，当 T 是一个 const 容器时，应当使用 const_iterator。
    
    要想解决这个问题，在之前的 C++98/03 版本下只能想办法把 const 类型的容器用模板特化单独处理，增加了不少工作量，看起来也非常晦涩。但是有了 C++11 的 decltype 关键字，就可以直接这样写：
    template <typename T>
    class Base {
    public:
        void func(T& container) {
            m_it = container.begin();
        }
    private:
        decltype(T().begin()) m_it;  //注意这里
    ```

#### auto和decltype的区别

- 「cv 限定符」是 const 和 volatile 关键字的统称：

  - const 关键字用来表示数据是只读的，也就是不能被修改；
  - volatile 和 const 是相反的，它用来表示数据是可变的、易变的，目的是不让 CPU 将数据缓存到寄存器，而是从原始的内存中读取。

- 在推导变量类型时，auto 和 decltype 对 cv 限制符的处理是不一样的。decltype 会保留 cv 限定符，而 auto 有可能会去掉 cv 限定符。以下是 auto 关键字对 cv 限定符的推导规则：

  - 如果表达式的类型不是指针或者引用，auto 会把 cv 限定符直接抛弃，推导成 non-const 或者 non-volatile 类型。

  - 如果表达式的类型是指针或者引用，auto 将保留 cv 限定符。

    ```c++
    /非指针非引用类型
    const int n1 = 0;
    auto n2 = 10;
    n2 = 99;  //赋值不报错
    decltype(n1) n3 = 20;
    n3 = 5;  //赋值报错
    //指针类型
    const int *p1 = &n1;
    auto p2 = p1;
    *p2 = 66;  //赋值报错
    decltype(p1) p3 = p1;
    *p3 = 19;  //赋值报错
    在 C++ 中无法将一个变量的完整类型输出，我们通过对变量赋值来判断它是否被 const 修饰；如果被 const 修饰那么赋值失败，如果不被 const 修饰那么赋值成功。虽然这种方案不太直观，但也是能达到目的的。
    n2 赋值成功，说明不带 const，也就是 const 被 auto 抛弃了，这验证了 auto 的第一条推导规则。p2 赋值失败，说明是带 const 的，也就是 const 没有被 auto 抛弃，这验证了 auto 的第二条推导规则。
    n3 和 p3 都赋值失败，说明 decltype 不会去掉表达式的 const 属性。
    ```

- 当表达式的类型为引用时，auto 和 decltype 的推导规则也不一样；decltype 会保留引用类型，而 auto 会抛弃引用类型，直接推导出它的原始类型。

  ```c++
  int main() {
      int n = 10;
      int &r1 = n;
      //auto推导
      auto r2 = r1;
      r2 = 20;
      cout << n << ", " << r1 << ", " << r2 << endl;
      //decltype推导
      decltype(r1) r3 = n;
      r3 = 99;
      cout << n << ", " << r1 << ", " << r3 << endl;
      return 0;
  }
  10, 10, 20
  99, 99, 99
  从运行结果可以发现，给 r2 赋值并没有改变 n 的值，这说明 r2 没有指向 n，而是自立门户，单独拥有了一块内存，这就证明 r 不再是引用类型，它的引用类型被 auto 抛弃了。
  给 r3 赋值，n 的值也跟着改变了，这说明 r3 仍然指向 n，它的引用类型被 decltype 保留了。
  ```

#### 返回值类型后置

- 在泛型编程中，可能需要通过参数的运算来得到返回值的类型

  ```c++
  template <typename R, typename T, typename U>
  R add(T t, U u)
  {
      return t+u;
  }
  int a = 1; float b = 2.0;
  auto c = add<decltype(a + b)>(a, b);
  
  其中R的类型要根据t和u计算得出。
  ```

- 返回类型后置语法是通过 auto 和 decltype 结合起来使用的。上面的 add 函数，使用新的语法可以写成：

  ```c++
  template <typename T, typename U>
  auto add(T t, U u) -> decltype(t + u)
  {
      return t + u;
  }
  
  为了进一步说明这个语法，再看另一个例子：
  int& foo(int& i);
  float foo(float& f);
  template <typename T>
  auto func(T& val) -> decltype(foo(val))
  {
      return foo(val);
  }
  在这个例子中，使用 decltype 结合返回值后置语法很容易推导出了 foo(val) 可能出现的返回值类型，并将其用到了 func 上。
  ```

- 返回值类型后置语法，是为了解决函数返回值类型依赖于参数而导致难以确定返回值类型的问题。有了这种语法以后，对返回值类型的推导就可以用清晰的方式（直接通过参数做运算）描述出来，而不需要像 C++98/03 那样使用晦涩难懂的写法。

#### using定义别名

- 使用 typedef 重定义类型是很方便的，但它也有一些限制，比如，无法重定义一个模板。想象下面这个场景：

  ```c++
  typedef std::map<std::string, int> map_int_t;
  // ...
  typedef std::map<std::string, std::string> map_str_t;
  // ...
  ```

  - 我们需要的其实是一个固定以 std::string 为 key 的 map，它可以映射到 int 或另一个 std::string。然而这个简单的需求仅通过 typedef 却很难办到。

  - 因此，在 C++98/03 中往往不得不这样写：

    ```c++
    template <typename Val>
    struct str_map
    {
        typedef std::map<std::string, Val> type;
    };
    // ...
    str_map<int>::type map1;
    // ...
    一个虽然简单但却略显烦琐的 str_map 外敷类是必要的。这明显让我们在复用某些泛型代码时非常难受。
    ```

  - 现在，在 C++11 中终于出现了可以重定义一个模板的语法

    ```c++
    template <typename Val>
    using str_map_t = std::map<std::string, Val>;
    // ...
    str_map_t<int> map1;
    
    这里使用新的 using 别名语法定义了 std::map 的模板别名 str_map_t。比起前面使用外敷模板加 typedef 构建的 str_map，它完全就像是一个新的 map 类模板，因此，简洁了很多。
    ```

- typedef 的定义方法和变量的声明类似：像声明一个变量一样，声明一个重定义类型，之后在声明之前加上 typedef 即可。这种写法凸显了 C/C++ 中的语法一致性，但有时却会增加代码的阅读难度。比如重定义一个函数指针时：

  ```c++
  typedef void (*func_t)(int, int);
  与之相比，using 后面总是立即跟随新标识符（Identifier），之后使用类似赋值的语法，把现有的类型（type-id）赋给新类型：
  using func_t = void (*)(int, int);
  从上面的对比中可以发现，C++11 的 using 别名语法比 typedef 更加清晰。因为 typedef 的别名语法本质上类似一种解方程的思路。而 using 语法通过赋值来定义别名，和我们平时的思考方式一致。
  ```

- 下面再通过一个对比示例，看看新的 using 语法是如何定义模板别名的。

  ```c++
  /* C++98/03 */
  template <typename T>
  struct func_t
  {
      typedef void (*type)(T, T);
  };
  // 使用 func_t 模板
  func_t<int>::type xx_1;
  /* C++11 */
  template <typename T>
  using func_t = void (*)(T, T);
  // 使用 func_t 模板
  func_t<int> xx_2;
  
  using 语法和 typedef 一样，并不会创造新的类型。也就是说，上面示例中 C++11 的 using 写法只是 typedef 的等价物。虽然 using 重定义的 func_t 是一个模板，但 func_t<int> 定义的 xx_2 并不是一个由类模板实例化后的类，而是 void(*)(int, int) 的别名。
      
  using 重定义的 func_t 是一个模板，但它既不是类模板也不是函数模板（函数模板实例化后是一个函数），而是一种新的模板形式：模板别名（alias template）。
  ```

  - 通过 using 定义模板别名的语法，只是在普通类型别名语法的基础上增加 template 的参数列表。使用 using 可以轻松地创建一个新的模板别名，而不需要像 C++98/03 那样使用烦琐的外敷模板。

#### for循环

- C++ 11 标准中，除了可以沿用前面介绍的用法外，还为 for 循环添加了一种全新的语法格式

  ```
  for (declaration : expression){
      //循环体
  }
  ```

  - declaration：表示此处要定义一个变量，该变量的类型为要遍历序列中存储元素的类型。需要注意的是，C++ 11 标准中，declaration参数处定义的变量类型可以用 auto 关键字表示，该关键字可以使编译器自行推导该变量的数据类型。

  - expression：表示要遍历的序列，常见的可以为事先定义好的普通数组或者容器，还可以是用 {} 大括号初始化的序列。

  - C++ 98/03 中 for 循环的语法格式相比较，此格式并没有明确限定 for 循环的遍历范围，这是它们最大的区别，即旧格式的 for 循环可以指定循环的范围，而 C++11 标准增加的 for 循环，只会逐个遍历 expression 参数处指定序列中的每个元素。

    ```c++
    int main() {
        char arc[] = "http://c.biancheng.net/cplus/11/";
        //for循环遍历普通数组
        for (char ch : arc) {
            cout << ch;
        }
        cout << '!' << endl;
        vector<char>myvector(arc, arc + 23);
        //for循环遍历 vector 容器
        for (auto ch : myvector) {
            cout << ch;
        }
        cout << '!';
        return 0;
    }
    http://c.biancheng.net/cplus/11/ !
    http://c.biancheng.net/!
    ```

  - 程序中在遍历 myvector 容器时，定义了 auto 类型的 ch 变量，当编译器编译程序时，会通过 myvector 容器中存储的元素类型自动推导出 ch 为 char 类型。注意，这里的 ch 不是迭代器类型，而表示的是 myvector 容器中存储的每个元素。

  - 仔细观察程序的输出结果，其中第一行输出的字符串和 "!" 之间还输出有一个空格，这是因为新格式的 for 循环在遍历字符串序列时，不只是遍历到最后一个字符，还会遍历位于该字符串末尾的 '\0'（字符串的结束标志）。之所以第二行输出的字符串和 "!" 之间没有空格，是因为 myvector 容器中没有存储 '\0'。

- 新语法格式的 for 循环还支持遍历用`{ }`大括号初始化的列表

  ```
  int main() {
      for (int num : {1, 2, 3, 4, 5}) {
          cout << num << " ";
      }
      return 0;
  }
  1 2 3 4 5
  ```

- 另外值得一提的是，在使用新语法格式的 for 循环遍历某个序列时，如果需要遍历的同时修改序列中元素的值，实现方案是在 declaration 参数处定义引用形式的变量。

  ```
  		char arc[] = "abcde";
      vector<char>myvector(arc, arc + 5);
      //for循环遍历并修改容器中各个字符的值
      for (auto &ch : myvector) {
          ch++;
      }
      //for循环遍历输出容器中各个字符
      for (auto ch : myvector) {
          cout << ch;
      }
  ```

  - declaration 参数既可以定义普通形式的变量，也可以定义引用形式的变量，应该如何选择呢？其实很简单，如果需要在遍历序列的过程中修改器内部元素的值，就必须定义引用形式的变量；反之，建议定义`const &`（常引用）形式的变量（避免了底层复制变量的过程，效率更高），也可以定义普通变量。

#### c++11列表初始化

```c++
//初始化列表
int i_arr[3] = { 1, 2, 3 };  //普通数组
struct A
{
    int x;
    struct B
    {
        int i;
        int j;
    } b;
} a = { 1, { 2, 3 } };  //POD类型
//拷贝初始化（copy-initialization）
int i = 0;
class Foo
{
    public:
    Foo(int) {}
} foo = 123;  //需要拷贝构造函数
//直接初始化（direct-initialization）
int j(0);
Foo bar(123);
```

- 这些不同的初始化方法，都有各自的适用范围和作用。最关键的是，这些种类繁多的初始化方法，没有一种可以通用所有情况。

- 为了统一初始化方式，并且让初始化行为具有确定的效果，C++11 中提出了列表初始化（List-initialization）的概念。

- POD 类型即 plain old data 类型，简单来说，是可以直接使用 memcpy 复制的对象。

- 对于普通数组和 POD 类型，C++98/03 可以使用初始化列表（initializer list）进行初始化

  ```c++
  int i_arr[3] = { 1, 2, 3 };
  long l_arr[] = { 1, 3, 2, 4 };
  struct A
  {
      int x;
      int y;
  } a = { 1, 2 };
  ```

  - 但是这种初始化方式的适用性非常狭窄，只有上面提到的这两种数据类型可以使用初始化列表。

- 在 C++11 中，初始化列表的适用性被大大增加了。它现在可以用于任何类型对象的初始化

  ```c++
  class Foo
  {
  public:
      Foo(int) {}
  private:
      Foo(const Foo &);
  };
  int main(void)
  {
      Foo a1(123);
      Foo a2 = 123;  //error: 'Foo::Foo(const Foo &)' is private
      Foo a3 = { 123 };
      Foo a4 { 123 };
      int a5 = { 3 };
      int a6 { 3 };
      return 0;
  }
  ```

  - a3、a4 使用了新的初始化方式来初始化对象，效果如同 a1 的直接初始化。

  - a5、a6 则是基本数据类型的列表初始化方式。可以看到，它们的形式都是统一的。

  - 这里需要注意的是，a3 虽然使用了等于号，但它仍然是列表初始化，因此，私有的拷贝构造并不会影响到它。

  - a4 和 a6 的写法，是 C++98/03 所不具备的。在 C++11 中，可以直接在变量名后面跟上初始化列表，来进行对象的初始化。

  - 这种变量名后面跟上初始化列表方法同样适用于普通数组和 POD 类型的初始化

    ```c++
    int i_arr[3] { 1, 2, 3 };  //普通数组
    struct A
    {
        int x;
        struct B
        {
            int i;
            int j;
        } b;
    } a { 1, { 2, 3 } };  //POD类型
    没有了=号
    ```

    - 在初始化时，`{}`前面的等于号是否书写对初始化行为没有影响。

- new 操作符等可以用圆括号进行初始化的地方，也可以使用初始化列表：

  ```
  int* a = new int { 123 };
  double b = double { 12.12 };
  int* arr = new int[3] { 1, 2, 3 };
  ```

  - 指针 a 指向了一个 new 操作符返回的内存，通过初始化列表方式在内存初始化时指定了值为 123。
  - b 则是对匿名对象使用列表初始化后，再进行拷贝初始化。
  - 这里让人眼前一亮的是 arr 的初始化方式。堆上动态分配的数组终于也可以使用初始化列表进行初始化了。

- 列表初始化还可以直接使用在函数的返回值上

  ```
  struct Foo
  {
      Foo(int, double) {}
  };
  Foo func(void)
  {
      return { 123, 321.0 };
  }
  ```

  - 这里的 return 语句就如同返回了一个 Foo(123, 321.0)。

#### constexpr

- 常量表达式，指的就是由多个（≥1）常量组成的表达式。换句话说，如果表达式中的成员都是常量，那么该表达式就是一个常量表达式。这也意味着，常量表达式一旦确定，其值将无法修改。

- 实际开发中，我们经常会用到常量表达式。以定义数组为例，数组的长度就必须是一个常量表达式

  ```c
  // 1)
  int url[10];//正确
  // 2)
  int url[6 + 4];//正确
  // 3)
  int length = 6;
  int url[length];//错误，length是变量
  ```

  - 上述代码演示了 3 种定义 url 数组的方式，其中第 1、2 种定义 url 数组时，长度分别为 10 和 6+4，显然它们都是常量表达式，可以用于表示数组的长度；第 3 种 url 数组的长度为 length，它是变量而非常量，因此不是一个常量表达式，无法用于表示数组的长度。
  - 常量表达式的应用场景还有很多，比如匿名枚举、switch-case 结构中的 case 表达式等

- C++ 程序的执行过程大致要经历编译、链接、运行这 3 个阶段。值得一提的是，常量表达式和非常量表达式的计算时机不同，非常量表达式只能在程序运行阶段计算出结果；而常量表达式的计算往往发生在程序的编译阶段，这可以极大提高程序的执行效率，因为表达式只需要在编译阶段计算一次，节省了每次程序运行时都需要计算一次的时间。

- 对于用 C++ 编写的程序，性能往往是永恒的追求。那么在实际开发中，如何才能判定一个表达式是否为常量表达式，进而获得在编译阶段即可执行的“特权”呢？除了人为判定外，C++11 标准还提供有 constexpr 关键字。

- constexpr 关键字的功能是使指定的常量表达式获得在程序编译阶段计算出结果的能力，而不必等到程序运行阶段。C++ 11 标准中，constexpr 可用于修饰普通变量、函数（包括模板函数）以及类的构造函数。

- constexpr修饰普通变量

  - C++11 标准中，定义变量时可以用 constexpr 修饰，从而使该变量获得在编译阶段即可计算出结果的能力。值得一提的是，使用 constexpr 修改普通变量时，变量必须经过初始化且初始值必须是一个常量表达式

    ```c++
    int main()
    {
        constexpr int num = 1 + 2 + 3;
        int url[num] = {1,2,3,4,5,6};
        couts<< url[1] << endl;
        return 0;
    }
    执行结果为2
    读者可尝试将 constexpr 删除，此时编译器会提示“url[num] 定义中 num 不可用作常量”。
    ```

  - 使用 constexpr 修饰 num 变量，同时将 "1+2+3" 这个常量表达式赋值给 num。由此，编译器就可以在编译时期对 num 这个表达式进行计算，因为 num 可以作为定义数组时的长度。

  - 另外需要重点提出的是，当常量表达式中包含浮点数时，考虑到程序编译和运行所在的系统环境可能不同，常量表达式在编译阶段和运行阶段计算出的结果精度很可能会受到影响，因此 C++11 标准规定，浮点常量表达式在编译阶段计算的精度要至少等于（或者高于）运行阶段计算出的精度。

- constexpr修饰函数

  - constexpr 还可以用于修饰函数的返回值，这样的函数又称为“常量表达式函数”。

  - constexpr 并非可以修改任意函数的返回值。换句话说，一个函数要想成为常量表达式函数，必须满足如下 4 个条件。

    - 整个函数的函数体中，除了可以包含 using 指令、typedef 语句以及 static_assert 断言外，只能包含一条 return 返回语句。

      ```c++
      constexpr int display(int x) {
          int ret = 1 + 2 + x;
          return ret;
      }
      这个函数是无法通过编译的，因为该函数的返回值用 constexpr 修饰，但函数内部包含多条语句。
      如下是正确的定义 display() 常量表达式函数的写法：
      constexpr int display(int x) {
          //可以添加 using 执行、typedef 语句以及 static_assert 断言
          return 1 + 2 + x;
      }
      ```

    - 该函数必须有返回值，即函数的返回值类型不能是 void。

    - 函数在使用之前，必须有对应的定义语句。我们知道，函数的使用分为“声明”和“定义”两部分，普通的函数调用只需要提前写好该函数的声明部分即可（函数的定义部分可以放在调用位置之后甚至其它文件中），但常量表达式函数在使用前，必须要有该函数的定义。普通函数在调用时，只需要保证调用位置之前有相应的声明即可；而常量表达式函数则不同，调用位置之前必须要有该函数的定义，否则会导致程序编译失败。

    -  return 返回的表达式必须是常量表达式

      ```c++
      int num = 3;
      constexpr int display(int x){
          return num + x;
      }
      int main()
      {
          //调用常量表达式函数
          int a[display(3)] = { 1,2,3,4 };
          return 0;
      }
      该程序无法通过编译，编译器报“display(3) 的结果不是常量”的异常。
      常量表达式函数的返回值必须是常量表达式的原因很简单，如果想在程序编译阶段获得某个函数返回的常量，则该函数的 return 语句中就不能包含程序运行阶段才能确定值的变量。
      ```

- constexpr修饰类的构造函数

  - 对于 C++ 内置类型的数据，可以直接用 constexpr 修饰，但如果是自定义的数据类型（用 struct 或者 class 实现），直接用 constexpr 修饰是不行的。

  - 当我们想自定义一个可产生常量的类型时，正确的做法是在该类型的内部添加一个常量构造函数

    ```c++
    //自定义类型的定义
    constexpr struct myType {
        const char* name;
        int age;
        //其它结构体成员
    };
    int main()
    {
        constexpr struct myType mt { "zhangsan", 10 };
        cout << mt.name << " " << mt.age << endl;
        return 0;
    }
    上面这种方法是错误的，编译器会抛出“constexpr不能修饰自定义类型”的异常。
    
    //自定义类型的定义
    struct myType {
        constexpr myType(char *name,int age):name(name),age(age){};
        const char* name;
        int age;
        //其它结构体成员
    };
    int main()
    {
        constexpr struct myType mt { "zhangsan", 10 };
        cout << mt.name << " " << mt.age << endl;
        return 0;
    }
    ```

  - 在 myType 结构体中自定义有一个构造函数，借助此函数，用 constexpr 修饰的 myType 类型的 my 常量即可通过编译。

  - constexpr 修饰类的构造函数时，要求该构造函数的函数体必须为空，且采用初始化列表的方式为各个成员赋值时，必须使用常量表达式。

  - constexpr 可用于修饰函数，而类中的成员方法完全可以看做是“位于类这个命名空间中的函数”，所以 constexpr 也可以修饰类中的成员函数，只不过此函数必须满足前面提到的 4 个条件。

    ```
    class myType {
    public:
        constexpr myType(const char *name,int age):name(name),age(age){};
        constexpr const char * getname(){
            return name;
        }
        constexpr int getage(){
            return age;
        }
    private:
        const char* name;
        int age;
        //其它结构体成员
    };
    int main()
    {
        constexpr struct myType mt { "zhangsan", 10 };
        constexpr const char * name = mt.getname();
        constexpr int age = mt.getage();
        cout << name << " " << age << endl;
        return 0;
    }
    ```

    

  - C++11 标准中，不支持用 constexpr 修饰带有 virtual 的成员方法。

- constexpr修饰模板函数

  - C++11 语法中，constexpr 可以修饰模板函数，但由于模板中类型的不确定性，因此模板函数实例化后的函数是否符合常量表达式函数的要求也是不确定的。

  - 针对这种情况下，C++11 标准规定，如果 constexpr 修饰的模板函数实例化结果不满足常量表达式函数的要求，则 constexpr 会被自动忽略，即该函数就等同于一个普通函数。

    ```
    //自定义类型的定义
    struct myType {
        const char* name;
        int age;
        //其它结构体成员
    };
    //模板函数
    template<typename T>
    constexpr T dispaly(T t){
        return t;
    }
    int main()
    {
        struct myType stu{"zhangsan",10};
        //普通函数
        struct myType ret = dispaly(stu);
        cout << ret.name << " " << ret.age << endl;
        //常量表达式函数
        constexpr int ret1 = dispaly(10);
        cout << ret1 << endl;
        return 0;
    }
    ```

    - 当模板函数中以自定义结构体 myType 类型进行实例化时，由于该结构体中没有定义常量表达式构造函数，所以实例化后的函数不是常量表达式函数，此时 constexpr 是无效的；
    - 第 23 行代码处，模板函数的类型 T 为 int 类型，实例化后的函数符合常量表达式函数的要求，所以该函数的返回值就是一个常量表达式。

#### constexpr和const的区别

```c++
void dis_1(const int x){
    //错误，x是只读的变量
    array <int,x> myarr{1,2,3,4,5};
    cout << myarr[1] << endl;
}
void dis_2(){
    const int x = 5;
    array <int,x> myarr{1,2,3,4,5};
    cout << myarr[1] << endl;
}
```

- dis_1() 和 dis_2() 函数中都包含一个 const int x，但 dis_1() 函数中的 x 无法完成初始化 array 容器的任务，而 dis_2() 函数中的 x 却可以。这是因为，dis_1() 函数中的“const int x”只是想强调 x 是一个只读的变量，其本质仍为变量，无法用来初始化 array 容器；而 dis_2() 函数中的“const int x”，表明 x 是一个只读变量的同时，x 还是一个值为 5 的常量，所以可以用来初始化 array 容器。C++ 11标准中，为了解决 const 关键字的双重语义问题，保留了 const 表示“只读”的语义，而将“常量”的语义划分给了新添加的 constexpr 关键字。因此 C++11 标准中，建议将 const 和 constexpr 的功能区分开，即凡是表达“只读”语义的场景都使用 const，表达“常量”语义的场景都使用 constexpr。在上面的实例程序中，dis_2() 函数中使用 const int x 是不规范的，应使用 constexpr 关键字。

- “只读”和“不允许被修改”之间并没有必然的联系

  ```
  int main()
  {
      int a = 10;
      const int & con_b = a;
      cout << con_b << endl;
      a = 20;
      cout << con_b << endl;
  }
  10
  20
  可以看到，程序中用 const 修饰了 con_b 变量，表示该变量“只读”，即无法通过变量自身去修改自己的值。但这并不意味着 con_b 的值不能借助其它变量间接改变，通过改变 a 的值就可以使 con_b 的值发生变化。
  ```

- 在大部分实际场景中，const 和 constexpr 是可以混用的

  ```
  const int a = 5 + 4;
  constexpr int a = 5 + 4;
  它们是完全等价的，都可以在程序的编译阶段计算出结果
  ```

- 但在某些场景中，必须明确使用 constexpr

  ```
  constexpr int sqr1(int arg){
      return arg*arg;
  }
  const int sqr2(int arg){
      return arg*arg;
  }
  int main()
  {
      array<int,sqr1(10)> mylist1;//可以，因为sqr1时constexpr函数
      array<int,sqr2(10)> mylist1;//不可以，因为sqr2不是constexpr函数
      return 0;
  }
  ```

  - 其中，因为 sqr2() 函数的返回值仅有 const 修饰，而没有用更明确的 constexpr 修饰，导致其无法用于初始化 array 容器（只有常量才能初始化 array 容器）。

- 总的来说在 C++ 11 标准中，const 用于为修饰的变量添加“只读”属性；而 constexpr 关键字则用于指明其后是一个常量（或者常量表达式），编译器在编译程序时可以顺带将其结果计算出来，而无需等到程序运行阶段，这样的优化极大地提高了程序的执行效率。

#### lambda匿名函数

- lambda 源自希腊字母表中第 11 位的 λ，在计算机科学领域，它则是被用来表示一种匿名函数。所谓匿名函数，简单地理解就是没有名称的函数，又常被称为 lambda 函数或者 lambda 表达式。

- 定义一个 lambda 匿名函数很简单，可以套用如下的语法格式

  ```c++
  [外部变量访问方式说明符] (参数) mutable noexcept/throw() -> 返回值类型
  {
     函数体;
  };
  因为是匿名函数lambda表达式一般用auto变量接收或直接使用，所以有最后的分号
  ```

  -  [外部变量方位方式说明符] [ ] 方括号用于向编译器表明当前是一个 lambda 表达式，其不能被省略。在方括号内部，可以注明当前 lambda 函数的函数体中可以使用哪些“外部变量”。所谓外部变量，指的是和当前 lambda 表达式位于同一作用域内的所有局部变量。
  - (参数)和普通函数的定义一样，lambda 匿名函数也可以接收外部传递的多个参数。和普通函数不同的是，如果不需要传递参数，可以连同 () 小括号一起省略；
  - mutable,此关键字可以省略，如果使用则之前的 () 小括号将不能省略（参数个数可以为 0）。默认情况下，对于以值传递方式引入的外部变量，不允许在 lambda 表达式内部修改它们的值（可以理解为这部分变量都是 const 常量）。而如果想修改它们，就必须使用 mutable 关键字。注意，对于以值传递方式引入的外部变量，lambda 表达式修改的是拷贝的那一份，并不会修改真正的外部变量；
  - noexcept/throw(),可以省略，如果使用，在之前的 () 小括号将不能省略（参数个数可以为 0）。默认情况下，lambda 函数的函数体中可以抛出任何类型的异常。而标注 noexcept 关键字，则表示函数体内不会抛出任何异常；使用 throw() 可以指定 lambda 函数内部可以抛出的异常类型。值得一提的是，如果 lambda 函数标有 noexcept 而函数体内抛出了异常，又或者使用 throw() 限定了异常类型而函数体内抛出了非指定类型的异常，这些异常无法使用 try-catch 捕获，会导致程序执行失败（本节后续会给出实例）。
  - -> 返回值类型,指明 lambda 匿名函数的返回值类型。值得一提的是，如果 lambda 函数体内只有一个 return 语句，或者该函数返回 void，则编译器可以自行推断出返回值类型，此情况下可以直接省略`-> 返回值类型`。
  - 函数体,和普通函数一样，lambda 匿名函数包含的内部代码都放置在函数体中。该函数体内除了可以使用指定传递进来的参数之外，还可以使用指定的外部变量以及全局范围内的所有全局变量。

- 对于 lambda 匿名函数的使用，令多数初学者感到困惑的就是 [外部变量] 的使用。其实很简单，无非表 1 所示的这几种编写格式。

  | 外部变量格式      | 功能                                                         |
  | ----------------- | ------------------------------------------------------------ |
  | []                | 空方括号表示当前 lambda 匿名函数中不导入任何外部变量。       |
  | [=]               | 只有一个 = 等号，表示以值传递的方式导入所有外部变量；        |
  | [&]               | 只有一个 & 符号，表示以引用传递的方式导入所有外部变量；      |
  | [val1,val2,...]   | 表示以值传递的方式导入 val1、val2 等指定的外部变量，同时多个变量之间没有先后次序； |
  | [&val1,&val2,...] | 表示以引用传递的方式导入 val1、val2等指定的外部变量，多个变量之间没有前后次序； |
  | [val,&val2,...]   | 以上 2 种方式还可以混合使用，变量之间没有前后次序。          |
  | [=,&val1,...]     | 表示除 val1 以引用传递的方式导入外，其它外部变量都以值传递的方式导入。 |
  | [this]            | 表示以值传递的方式导入当前的 this 指针。                     |
  - 注意，单个外部变量不允许以相同的传递方式导入多次。例如 [=，val1] 中，val1 先后被以值传递的方式导入了 2 次，这是非法的。

  - 为什么要有这个引入外部变量这个东西，因为在同一级作用域下有很多变量，例如函数调用前定义的一些变量，如果我们在匿名函数中使用就需要引入进来，如果不需要就不需要引进，一般如果我们需要修改以前定义的变量，就要引入进来。其和后面()是两回事，后面的是我们调用函数传进来的参数。

- 虽然 lambda 匿名函数没有函数名称，但我们仍可以为其手动设置一个名称

  ```
  	auto display = [](int a,int b) -> void{cout << a << " " << b;};
      //调用 lambda 函数
      display(10,20);
  ```

  - 函数调用要有()，虽然定义匿名函数的时候没有写，但是其确实是函数，所以需要加括号表明其是一个函数。

- 值传递和引用传递的区别

  ```
  //全局变量
  int all_num = 0;
  int main()
  {
      //局部变量
      int num_1 = 1;
      int num_2 = 2;
      int num_3 = 3;
      cout << "lambda1:\n";
      auto lambda1 = [=]{
          //全局变量可以访问甚至修改
          all_num = 10;
          //函数体内只能使用外部变量，而无法对它们进行修改
          cout << num_1 << " "
               << num_2 << " "
               << num_3 << endl;
      };
      lambda1();
      cout << all_num <<endl;
      cout << "lambda2:\n";
      auto lambda2 = [&]{
          all_num = 100;
          num_1 = 10;
          num_2 = 20;
          num_3 = 30;
          cout << num_1 << " "
               << num_2 << " "
               << num_3 << endl;
      };
      lambda2();
      cout << all_num << endl;
      return 0;
  }
  ```

  - lambda1 匿名函数是以 [=] 值传递的方式导入的局部变量，这意味着默认情况下，此函数内部无法修改这 3 个局部变量的值，但全局变量 all_num 除外。相对地，lambda2 匿名函数以 [&] 引用传递的方式导入这 3 个局部变量，因此在该函数的内部不就可以访问这 3 个局部变量，还可以任意修改它们。同样，也可以访问甚至修改全局变量。

  - 如果我们想在 lambda1 匿名函数的基础上修改外部变量的值，可以借助 mutable 关键字

    ```
    auto lambda1 = [=]() mutable{
        num_1 = 10;
        num_2 = 20;
        num_3 = 30;
        //函数体内只能使用外部变量，而无法对它们进行修改
        cout << num_1 << " "
             << num_2 << " "
             << num_3 << endl;
    };
    ```

    - 由此，就可以在 lambda1 匿名函数中修改外部变量的值。但需要注意的是，这里修改的仅是 num_1、num_2、num_3 拷贝的那一份的值，真正外部变量的值并不会发生改变。

#### 右值引用

- 在 C++ 或者 C 语言中，一个表达式（可以是字面量、变量、对象、函数的返回值等）根据其使用场景不同，分为左值表达式和右值表达式。

- 值得一提的是，左值的英文简写为“lvalue”，右值的英文简写为“rvalue”。很多人认为它们分别是"left value"、"right value" 的缩写，其实不然。lvalue 是“loactor value”的缩写，可意为存储在内存中、有明确存储地址（可寻址）的数据，而 rvalue 译为 "read value"，指的是那些可以提供数据值的数据（不一定可以寻址，例如存储于寄存器中的数据）。

- 可位于赋值号（=）左侧的表达式就是左值；反之，只能位于赋值号右侧的表达式就是右值。C++ 中的左值也可以当做右值使用

  ```
  int a = 5;
  5 = a; //错误，5 不能为左值
  
  int b = 10; // b 是一个左值
  a = b; // a、b 都是左值，只不过将 b 可以当做右值使用
  ```

- 有名称的、可以获取到存储地址的表达式即为左值；反之则是右值。

  - 以上面定义的变量 a、b 为例，a 和 b 是变量名，且通过 &a 和 &b 可以获得他们的存储地址，因此 a 和 b 都是左值；反之，字面量 5、10，它们既没有名称，也无法获取其存储地址（字面量通常存储在寄存器中，或者和代码存储在一起），因此 5、10 都是右值。 

- 右值引用
  - 其实 C++98/03 标准中就有引用，使用 "&" 表示。但此种引用方式有一个缺陷，即正常情况下只能操作 C++ 中的左值，无法对右值添加引用。

    ```
    int num = 10;
    int &b = num; //正确
    int &c = 10; //错误
    编译器允许我们为 num 左值建立一个引用，但不可以为 10 这个右值建立引用。因此，C++98/03 标准中的引用又称为左值引用。
    ```

  - 虽然 C++98/03 标准不支持为右值建立非常量左值引用，但允许使用常量左值引用操作右值。也就是说，常量左值引用既可以操作左值，也可以操作右值

    ```
    int num = 10;
    const int &b = num;
    const int &c = 10;
    右值往往是没有名称的，因此要使用它只能借助引用的方式。这就产生一个问题，实际开发中我们可能需要对右值进行修改（实现移动语义时就需要），显然左值引用的方式是行不通的。
    ```

  - C++11 标准新引入了另一种引用方式，称为右值引用，用 "&&" 表示。

  - 和声明左值引用一样，右值引用也必须立即进行初始化操作，且只能使用右值进行初始化

    ```
    int num = 10;
    //int && a = num;  //右值引用不能初始化为左值
    int && a = 10;
    ```

  - 和常量左值引用不同的是，右值引用还可以对右值进行修改

    ```
    int && a = 10;
    a = 100;
    cout << a << endl;
    运行结果
    100
    ```

  - C++ 语法上是支持定义常量右值引用的
  
    ```
    const int&& a = 10;//编译器不会报错
    ```
  
    - 但这种定义出来的右值引用并无实际用处。一方面，右值引用主要用于移动语义和完美转发，其中前者需要有修改右值的权限；其次，常量右值引用的作用就是引用一个不可修改的右值，这项工作完全可以交给常量左值引用完成。

#### 移动构造函数

- 右值引用主要用于实现移动（move）语义和完美转发

- 移动语义

  - 在 C++ 11 标准之前（C++ 98/03 标准中），如果想用其它对象初始化一个同类的新对象，只能借助类中的复制（拷贝）构造函数。拷贝构造函数的实现原理很简单，就是为新对象复制一份和其它对象一模一样的数据。

  - 需要注意的是，当类中拥有指针类型的成员变量时，拷贝构造函数中需要以深拷贝（而非浅拷贝）的方式复制该指针成员。

    ```
    class demo{
    public:
       demo():num(new int(0)){
          cout<<"construct!"<<endl;
       }
       //拷贝构造函数
       demo(const demo &d):num(new int(*d.num)){
          cout<<"copy construct!"<<endl;
       }
       ~demo(){
          cout<<"class destruct!"<<endl;
       }
    private:
       int *num;
    };
    demo get_demo(){
        return demo();
    }
    int main(){
        demo a = get_demo();
        return 0;
    }
    
    new int(*d.num),括号里面就是初始化int的初始值，此语句最后返回一个指针。
    return demo()；demo()会产生一个临时的类对象，只需要写上类名()就可以
    ```

  - 我们为 demo 类自定义了一个拷贝构造函数。该函数在拷贝 d.num 指针成员时，必须采用深拷贝的方式，即拷贝该指针成员本身的同时，还要拷贝指针指向的内存资源。否则一旦多个对象中的指针成员指向同一块堆空间，这些对象析构时就会对该空间释放多次，这是不允许的。

  - 程序中定义了一个可返回 demo 对象的 get_demo() 函数，用于在 main() 主函数中初始化 a 对象，其整个初始化的流程包含以下几个阶段：

    1. 执行 get_demo() 函数内部的 demo() 语句，即调用 demo 类的默认构造函数生成一个匿名对象；
    2. 执行 return demo() 语句，会调用拷贝构造函数复制一份之前生成的匿名对象，并将其作为 get_demo() 函数的返回值（函数体执行完毕之前，匿名对象会被析构销毁）；
    3. 执行 a = get_demo() 语句，再调用一次拷贝构造函数，将之前拷贝得到的临时对象复制给 a（此行代码执行完毕，get_demo() 函数返回的对象会被析构）；
    4. 程序执行结束前，会自行调用 demo 类的析构函数销毁 a。

  - 目前多数编译器都会对程序中发生的拷贝操作进行优化，因此如果我们使用 VS 2017、codeblocks 等这些编译器运行此程序时，看到的往往是优化后的输出结果：

    ```
    construct!
    class destruct!
    ```

  - 而同样的程序，如果在 Linux 上使用`g++ demo.cpp -fno-elide-constructors`命令运行（其中 demo.cpp 是程序文件的名称），就可以看到完整的输出结果：

    ```
    construct!                <-- 执行 demo()
    copy construct!       <-- 执行 return demo()
    class destruct!         <-- 销毁 demo() 产生的匿名对象
    copy construct!       <-- 执行 a = get_demo()
    class destruct!         <-- 销毁 get_demo() 返回的临时对象
    class destruct!         <-- 销毁 a
    ```

  - 如上所示，利用拷贝构造函数实现对 a 对象的初始化，底层实际上进行了 2 次拷贝（而且是深拷贝）操作。当然，对于仅申请少量堆空间的临时对象来说，深拷贝的执行效率依旧可以接受，但如果临时对象中的指针成员申请了大量的堆空间，那么 2 次深拷贝操作势必会影响 a 对象初始化的执行效率。

  - 此问题一直存留在以 C++ 98/03 标准编写的 C++ 程序中。由于临时变量的产生、销毁以及发生的拷贝操作本身就是很隐晦的（编译器对这些过程做了专门的优化），且并不会影响程序的正确性，因此很少进入程序员的视野。

  - 那么当类中包含指针类型的成员变量，使用其它对象来初始化同类对象时，怎样才能避免深拷贝导致的效率问题呢？C++11 标准引入了解决方案，该标准中引入了右值引用的语法，借助它可以实现移动语义。

- 移动构造函数(移动语义的具体实现)

  - 所谓移动语义，指的就是以移动而非深拷贝的方式初始化含有指针成员的类对象。简单的理解，移动语义指的就是将其他对象（通常是临时对象）拥有的内存资源“移为已用”。

  - 以前面程序中的 demo 类为例，该类的成员都包含一个整形的指针成员，其默认指向的是容纳一个整形变量的堆空间。当使用 get_demo() 函数返回的临时对象初始化 a 时，我们只需要将临时对象的 num 指针直接浅拷贝给 a.num，然后修改该临时对象中 num 指针的指向（通常另其指向 NULL），这样就完成了 a.num 的初始化。

  - 事实上，对于程序执行过程中产生的临时对象，往往只用于传递数据（没有其它的用处），并且会很快会被销毁。因此在使用临时对象初始化新对象时，我们可以将其包含的指针成员指向的内存资源直接移给新对象所有，无需再新拷贝一份，这大大提高了初始化的执行效率。

    ```
    class demo{
    public:
        demo():num(new int(0)){
            cout<<"construct!"<<endl;
        }
        demo(const demo &d):num(new int(*d.num)){
            cout<<"copy construct!"<<endl;
        }
        //添加移动构造函数
        demo(demo &&d):num(d.num){
            d.num = NULL;
            cout<<"move construct!"<<endl;
        }
        ~demo(){
            cout<<"class destruct!"<<endl;
        }
    private:
        int *num;
    };
    demo get_demo(){
        return demo();
    }
    int main(){
        demo a = get_demo();
        return 0;
    }
    ```

  - 可以看到，在之前 demo 类的基础上，我们又手动为其添加了一个构造函数。和其它构造函数不同，此构造函数使用右值引用形式的参数，又称为移动构造函数。并且在此构造函数中，num 指针变量采用的是浅拷贝的复制方式，同时在函数内部重置了 d.num，有效避免了“同一块对空间被释放多次”情况的发生。

  - 在 Linux 系统中使用`g++ demo.cpp -o demo.exe -std=c++0x -fno-elide-constructors`命令执行此程序，输出结果为：

    ```
    construct!
    move construct!
    class destruct!
    move construct!
    class destruct!
    class destruct!
    ```

  - 通过执行结果我们不难得知，当为 demo 类添加移动构造函数之后，使用临时对象初始化 a 对象过程中产生的 2 次拷贝操作，都转由移动构造函数完成。

  - 我们知道，非 const 右值引用只能操作右值，程序执行结果中产生的临时对象（例如函数返回值、lambda 表达式等）既无名称也无法获取其存储地址，所以属于右值。当类中同时包含拷贝构造函数和移动构造函数时，如果使用临时对象初始化当前类的对象，编译器会优先调用移动构造函数来完成此操作。只有当类中没有合适的移动构造函数时，编译器才会退而求其次，调用拷贝构造函数。

  - 在实际开发中，通常在类中自定义移动构造函数的同时，会再为其自定义一个适当的拷贝构造函数，由此当用户利用右值初始化类对象时，会调用移动构造函数；使用左值（非右值）初始化类对象时，会调用拷贝构造函数。

  - 默认情况下，左值初始化同类对象只能通过拷贝构造函数完成，如果想调用移动构造函数，则必须使用右值进行初始化。C++11 标准中为了满足用户使用左值初始化同类对象时也通过移动构造函数完成的需求，新引入了 std::move() 函数，它可以将左值强制转换成对应的右值，由此便可以使用移动构造函数。

#### std::move函数

- 移动构造函数的调用时机是：用同类的右值对象初始化新对象。那么，用当前类的左值对象（有名称，能获取其存储地址的实例对象）初始化同类对象时，是否就无法调用移动构造函数了呢？当然不是，C++11 标准中已经给出了解决方案，即调用 move() 函数。

- move 本意为 "移动"，但该函数并不能移动任何数据，它的功能很简单，就是将某个左值强制转化为右值。

  ```
  move( arg )
  ```

  - arg 表示指定的左值对象。该函数会返回 arg 对象的右值形式。

- move函数的使用

  ```c++
  	movedemo demo;
      cout << "demo2:\n";
      movedemo demo2 = demo;
      //cout << *demo2.num << endl;   //可以执行
      cout << "demo3:\n";
      movedemo demo3 = std::move(demo);
      //此时 demo.num = NULL，因此下面代码会报运行时错误
      //cout << *demo.num << endl;
  ```

  - move是将左值强制转换为右值，所以move函数的返回值不需要变量来接收
  - 上面的=其实就是拷贝的意思，如果类中有移动构造函数就要用移动构造函数，但是移动构造函数的赋值要用右值，所以使用move将左值强制转换为右值。拷贝构造函数和移动构造函数本质上都是用其他对象初始化一个类对象，所以都是赋值，只不过在拷贝的时候有一个是左值一个是右值。

#### 引用限定符

- 左值和右值的区分也同样适用于类对象，本节中将左值的类对象称为左值对象，将右值的类对象称为右值对象。

- 默认情况下，对于类中用 public 修饰的成员函数，既可以被左值对象调用，也可以被右值对象调用

  ```
  class demo {
  public:
      demo(int num):num(num){}
      int get_num(){
          return this->num;
      }
  private:
      int num;
  };
  int main() {
      demo a(10);
      cout << a.get_num() << endl;
      cout << move(a).get_num() << endl;
      return 0;
  }
  ```

  - demo 类中的 get_num() 成员函数既可以被 a 左值对象调用，也可以被 move(a) 生成的右值 demo 对象调用，运行程序会输出两个 10。

- 某些场景中，我们可能需要限制调用成员函数的对象的类型（左值还是右值），为此 C++11 新添加了引用限定符。所谓引用限定符，就是在成员函数的后面添加 "&" 或者 "&&"，从而限制调用者的类型（左值还是右值）。

  ```
  class demo {
  public:
      demo(int num):num(num){}
      int get_num()&{
          return this->num;
      }
  private:
      int num;
  };
  int main() {
      demo a(10);
      cout << a.get_num() << endl;          // 正确
      //cout << move(a).get_num() << endl;  // 错误
      return 0;
  }
  和之前的程序相比，我们仅在 get_num() 成员函数的后面添加了 "&"，它可以限定调用该函数的对象必须是左值对象。因此第 16 行代码中，move(a) 生成的右值对象是不允许调用 get_num() 函数的。
  
  class demo {
  public:
      demo(int num):num(num){}
      int get_num()&&{
          return this->num;
      }
  private:
      int num;
  };
  int main() {
      demo a(10);
      //cout << a.get_num() << endl;      // 错误
      cout << move(a).get_num() << endl;  // 正确
      return 0;
  }
  和先前程序不同的是，get_num() 函数后根有 "&&" 限定符，它可以限定调用该函数的对象必须是一个右值对象。
  ```

- const 也可以用于修饰类的成员函数，我们习惯称为常成员函数

- const 和引用限定符修饰类的成员函数时，都位于函数的末尾。C++11 标准规定，当引用限定符和 const 修饰同一个类的成员函数时，const 必须位于引用限定符前面。

- 需要注意的一点是，当 const && 修饰类的成员函数时，调用它的对象只能是右值对象；当 const & 修饰类的成员函数时，调用它的对象既可以是左值对象，也可以是右值对象。无论是 const && 还是 const & 限定的成员函数，内部都不允许对当前对象做修改操作。

  ```
  class demo {
  public:
      demo(int num,int num2) :num(num),num2(num2) {}
      //左值和右值对象都可以调用
      int get_num() const &{
          return this->num;
      }
      //仅供右值对象调用
      int get_num2() const && {
          return this->num2;
      }
  ```

#### 完美转发及其实现

- C++11 标准为 C++ 引入右值引用语法的同时，还解决了一个 C++ 98/03 标准长期存在的短板，即使用简单的方式即可在函数模板中实现参数的完美转发。

- 首先解释一下什么是完美转发，它指的是函数模板可以将自己的参数“完美”地转发给内部调用的其它函数。所谓完美，即不仅能准确地转发参数的值，还能保证被转发参数的左、右值属性不变。

  ```
  template<typename T>
  void function(T t) {
      otherdef(t);
  }
  ```

  - 如上所示，function() 函数模板中调用了 otherdef() 函数。在此基础上，完美转发指的是：如果 function() 函数接收到的参数 t 为左值，那么该函数传递给 otherdef() 的参数 t 也是左值；反之如果 function() 函数接收到的参数 t 为右值，那么传递给 otherdef() 函数的参数 t 也必须为右值。
  - 显然，function() 函数模板并没有实现完美转发。一方面，参数 t 为非引用类型，这意味着在调用 function() 函数时，实参将值传递给形参的过程就需要额外进行一次拷贝操作；另一方面，无论调用 function() 函数模板时传递给参数 t 的是左值还是右值，对于函数内部的参数 t 来说，它有自己的名称，也可以获取它的存储地址，因此它永远都是左值，也就是说，传递给 otherdef() 函数的参数 t 永远都是左值。总之，无论从那个角度看，function() 函数的定义都不“完美”。

- 读者可能会问，完美转发这样严苛的参数传递机制，很常用吗？C++98/03 标准中几乎不会用到，但 C++11 标准为 C++ 引入了右值引用和移动语义，因此很多场景中是否实现完美转发，直接决定了该参数的传递过程使用的是拷贝语义（调用拷贝构造函数）还是移动语义（调用移动构造函数）。

- 参数的每一次使用都是一个拷贝过程，实参到形参是一个拷贝，形参到函数体里面的使用又是一次拷贝，完美转发决定了参数的拷贝使用的是拷贝语义还是移动语义

- 为了方便用户更快速地实现完美转发，C++ 11 标准中允许在函数模板中使用右值引用来实现完美转发。

- C++11 标准中规定，通常情况下右值引用形式的参数只能接收右值，不能接收左值。但对于函数模板中使用右值引用语法定义的参数来说，它不再遵守这一规定，既可以接收右值，也可以接收左值（此时的右值引用又被称为“万能引用”）。

  ```
  template <typename T>
  void function(T&& t) {
      otherdef(t);
  }
  
  otherdef是一个函数
  ```

  - 此模板函数的参数 t 既可以接收左值，也可以接收右值。但仅仅使用右值引用作为函数模板的参数是远远不够的，还有一个问题继续解决，即如果调用 function() 函数时为其传递一个左值引用或者右值引用的实参

    ```
    int n = 10;
    int & num = n;
    function(num); // T 为 int&
    int && num2 = 11;
    function(num2); // T 为 int &&
    ```

  - 由 function(num) 实例化的函数底层就变成了 function(int & & t)，同样由 function(num2) 实例化的函数底层则变成了 function(int && && t)。要知道，C++98/03 标准是不支持这种用法的，而 C++ 11标准为了更好地实现完美转发，特意为其指定了新的类型匹配规则，又称为引用折叠规则（假设用 A 表示实际传递参数的类型）：

    - 当实参为左值或者左值引用（A&）时，函数模板中 T&& 将转变为 A&（A& && = A&）；说的是函数模板，不是实际的参数
    - 当实参为右值或者右值引用（A&&）时，函数模板中 T&& 将转变为 A&&（A&& && = A&&）。
    - 读者只需要知道，在实现完美转发时，只要函数模板的参数类型为 T&&，则 C++ 可以自行准确地判定出实际传入的实参是左值还是右值。

- 通过将函数模板的形参类型设置为 T&&，我们可以很好地解决接收左、右值的问题。但除此之外，还需要解决一个问题，即无论传入的形参是左值还是右值，对于函数模板内部来说，形参既有名称又能寻址，因此它都是左值。那么如何才能将函数模板接收到的形参连同其左、右值属性，一起传递给被调用的函数呢？C++11 标准的开发者已经帮我们想好的解决方案，该新标准还引入了一个模板函数 forword<T>()，我们只需要调用该函数，就可以很方便地解决此问题。仍以 function 模板函数为例，如下演示了该函数模板的用法：

  ```
  //重载被调用函数，查看完美转发的效果
  void otherdef(int & t) {
      cout << "lvalue\n";
  }
  void otherdef(const int & t) {
      cout << "rvalue\n";
  }
  //实现完美转发的函数模板
  template <typename T>
  void function(T&& t) {
      otherdef(forward<T>(t));
  }
  int main()
  {
      function(5);
      int  x = 1;
      function(x);
      return 0;
  }
  
  rvalue
  lvalue
  ```

  - forword() 函数模板用于修饰被调用函数中需要维持参数左、右值属性的参数。

- 总的来说，在定义模板函数时，我们采用右值引用的语法格式定义参数类型，由此该函数既可以接收外界传入的左值，也可以接收右值；其次，还需要使用 C++11 标准库提供的 forword() 模板函数修饰被调用函数中需要维持左、右值属性的参数。由此即可轻松实现函数模板中参数的完美转发。

 
