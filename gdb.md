- 在编译时使用-g选项编译源文件，即可生成满足GDB要求的可执行文件。

- gdb 可执行文件  就可以使用gdb调试。

  | 调试指令           | 作用                                                         |
  | ------------------ | ------------------------------------------------------------ |
  | break  xxx   b xxx | 在源代码指定的某一行设置断点，其中 xxx 用于指定具体打断点的位置。 |
  | run    r           | 执行被调试的程序，其会自动在第一个断点处暂停执行。           |
  | continue    c      | 当程序在某一断点处停止运行后，使用该指令可以继续执行，直至遇到下一个断点或者程序结束。 |
  | next    n          | 令程序一行代码一行代码的执行。                               |
  | print xxx    p xxx | 打印指定变量的值，其中 xxx 指的就是某一变量名。              |
  | list   l           | 显示源程序代码的内容，包括各行代码所在的行号。默认显示10行，按回车显示剩下的。 |
  | quit    q          | 终止调试                                                     |

- 在进行 run 或者 start 指令启动目标程序之前，还可能需要做一些必要的准备工作，大致包括以下几个方面：

  - 如果启动 GDB 调试器时未指定要调试的目标程序，或者由于各种原因 GDB 调试器并为找到所指定的目标程序，这种情况下就需要再次手动指定；file 命令+可执行文件
  - 有些 C 或者 C++ 程序的执行，需要接收一些参数（程序中用 argc 和 argv[] 接收）启动时--args ， 启动后set args a.txt，启动后 run a.txt或者直接set args --test
  - 目标程序在执行过程中，可能需要临时设置 PATH 环境变量；path
  - 默认情况下，GDB 调试器将启动时所在的目录作为工作目录，但很多情况下，该目录并不符合要求，需要在启动程序手动为 GDB 调试器指定工作目录。cd 
  - 默认情况下，GDB 调试器启动程序后，会接收键盘临时输入的数据，并将执行结果会打印在屏幕上。但 GDB 调试器允许对执行程序的输入和输出进行重定向，使其从文件或其它终端接收输入，或者将执行结果输出到文件或其它终端。run > a.txt

##### 断点设置

###### break设置断点

- break常用的语法格式有两种，其中打断点的位置有几种表示方法：
  - linenum     linenum 是一个整数，表示要打断点处代码的行号。要知道，程序中各行代码都有对应的行号，可通过执行 l（小写的 L）命令看到。
  - filename:linenum     filename 表示源程序文件名；linenum 为整数，表示具体行数。整体的意思是在指令文件 filename 中的第 linenum 行打断点。
  - \+ offset  \- offset   offset 为整数（假设值为 2），+offset 表示以当前程序暂停位置（例如第 4 行）为准，向后数 offset 行处（第 6 行）打断点；-offset 表示以当前程序暂停位置为准，向前数 offset 行处（第 2 行）打断点。
  - function    function 表示程序中包含的函数的函数名，即 break 命令会在该函数内部的开头位置打断点，程序会执行到该函数第一行代码处暂停。
  - filename:function     filename 表示远程文件名；function 表示程序中函数的函数名。整体的意思是在指定文件 filename 中 function 函数的开头位置打断点。
  - 两种格式第二种 break  location if cond，cond为某个表达式，表达式为真，程序暂停设断点，反之，程序继续运行
    -  第二种格式中，... 可以是上面所有参数的值，用于指定打断点的具体位置；cond 为某个表达式。整体的含义为：每次程序执行到 ... 位置时都计算 cond 的值，如果为 True，则程序在该位置暂停；反之，程序继续执行。
  
- tbreak 命令可以看到是 break 命令的另一个版本，tbreak 和 break 命令的用法和功能都非常相似，唯一的不同在于，使用 tbreak 命令打的断点仅会作用 1 次，即使程序暂停之后，该断点就会自动消失。
- rbreak 命令的作用对象是 C、C++ 程序中的函数，它会在指定函数的开头位置打断点。break regex其中 regex 为一个正则表达式，程序中函数的函数名只要满足 regex 条件，tbreak 命令就会其内部的开头位置打断点。值得一提的是，tbreak 命令打的断点和 break 命令打断点的效果是一样的，会一直存在，不会自动消失。会匹配所有的并把所有的打上断点

###### watch监控变量值的变化设置观察断点

- 借助观察断点可以监控程序中某个变量或者表达式的值，只要发生改变，程序就会停止执行。相比普通断点，观察断点不需要我们预测变量（表达式）值发生改变的具体位置。

  - 所谓表达式，就是包含多个变量的式子，比如 a+b 就是一个表达式，其中 a、b 为变量。

- watch cond，cond指的是要监控的变量或表达式

  - 此表达式也可以是我们平常所说的表达式，例如i > 999

    ```
    1	#include <stdio.h>
    2	using namespace std;
    3	int main(int argc, char *argv[])
    4	{
    5	    int i = 1;
    6	    while(1){
    7	        i += 1;
    8	    }
    9	    return 0;
    10	}
    
    例如上面的程序调试时
    watch i > 999
    停止的时候打印i的值是1000
    ```

- rwatch 命令：只要程序中出现读取目标变量（表达式）的值的操作，程序就会停止运行；

- awatch 命令：只要程序中出现读取目标变量（表达式）的值或者改变值的操作，程序就会停止运行。

- info watchpoints 查看当前建立的观察点的数量

- 值得一提的是，对于使用 watch（rwatch、awatch）命令监控 C、C++ 程序中变量或者表达式的值，有以下几点需要注意：

  - 当监控的变量（表达式）为局部变量（表达式）时，一旦局部变量（表达式）失效，则监控操作也随即失效；
  - 如果监控的是一个指针变量（例如 *p），则 watch *p 和 watch p 是有区别的，前者监控的是 p 所指数据的变化情况，而后者监控的是 p 指针本身有没有改变指向
  - 这 3 个监控命令还可以用于监控数组中元素值的变化情况，例如对于 a[10] 这个数组，watch a 表示只要 a 数组中存储的数据发生改变，程序就会停止执行。

- watch设置条件断点和普通断点一样

  ```
  watch expr if cond
  ```

  - 参数 expr 表示要观察的变量或表达式；参数 cond 用于代指某个表达式。
  - 上面的意思是如果cond成立，设置观察断点，否则不设置观察断点。这样我们可以简单的设置当某个变量为我们想要的值时，我们在设置观察断点，让程序在变量变化的位置暂停。

###### catch设置捕捉断点

- 捕捉断点的作用是，监控程序中某一事件的发生，例如程序发生某种异常时、某一动态库被加载时等等，一旦目标时间发生，则程序停止执行。用捕捉断点监控某一事件的发生，等同于在程序中该事件发生的位置打普通断点。

- 建立捕捉断点的方式很简单，就是使用 catch 命令，其基本格式为：

  ```
  (gdb) catch event
  ```

  - 其中，event 参数表示要监控的具体事件。对于使用 GDB 调试 C、C++ 程序，常用的 event 事件类型如表 1 所示。

    | event 事件                    | 含 义                                                        |
    | ----------------------------- | ------------------------------------------------------------ |
    | throw [exception]             | 当程序中抛出 exception 指定类型异常时，程序停止执行。如果不指定异常类型（即省略 exception），则表示只要程序发生异常，程序就停止执行。 |
    | catch [exception]             | 当程序中捕获到 exception 异常时，程序停止执行。exception 参数也可以省略，表示无论程序中捕获到哪种异常，程序都暂停执行。 |
    | load [regexp] unload [regexp] | 其中，regexp 表示目标动态库的名称，load 命令表示当 regexp 动态库加载时程序停止执行；unload 命令表示当 regexp 动态库被卸载时，程序暂停执行。regexp 参数也可以省略，此时只要程序中某一动态库被加载或卸载，程序就会暂停执行。 |

  - 注意上面的event分两种，一种是throw 一种是catch，含义为一个是抛出异常的时候程序就停止，一个是捕捉到异常的时候程序停止，具体的书写方法

    ```
    (gdb) catch catch int
    (gdb) catch throw int  
    ```

    - 两者不一样，注意要这么写。
    - exception是具体的异常，如c++中throw 100

- 注意，当前 GDB 调试器对监控 C++ 程序中异常的支持还有待完善，使用 catch 命令时，有以下几点需要说明：

  1. 对于使用 catch 监控指定的 event 事件，其匹配过程需要借助 libstdc++ 库中的一些 SDT 探针，而这些探针最早出现在 GCC 4.8 版本中。也就是说，想使用 catch 监控指定类型的 event 事件，系统中 GCC 编译器的版本最低为 4.8，但即便如此，catch 命令是否能正常发挥作用，还可能受到系统中其它因素的影响。
  2. 当 catch 命令捕获到指定的 event 事件时，程序暂停执行的位置往往位于某个系统库（例如 libstdc++）中。这种情况下，通过执行 up 命令，即可返回发生 event 事件的源代码处。
  3. catch 无法捕获以交互方式引发的异常。

- tcatch 命令和 catch 命令的用法完全相同，唯一不同之处在于，对于目标事件，catch 命令的监控是永久的，而 tcatch 命令只监控一次，也就是说，只有目标时间第一次触发时，tcath 命令才会捕获并使程序暂停，之后将失效。

- GDB condition命令condition 命令的功能是：既可以为现有的普通断点、观察断点以及捕捉断点添加条件表达式，也可以对条件断点的条件表达式进行修改。if不可以为捕捉断点设置条件。
  - condition bnum expression 用于为 bnum 编号的断点添加或修改 expression 条件表达式
  - condition bnum 用于删除 bnum 编号断点的条件表达式，使其变成普通的无条件断点。
  - 参数 bnum 用于代指目标断点的编号；参数 expression 表示为断点添加或修改的条件表达式。info break可以查看断点的类型以及编号

###### 禁用和删除断点

- info break[n]，n为可选项，为某个断点的编号。可以查看当前调试环境中存在的所有断点，包括普通断点、观察断点以及捕捉断点。info watchpoint用来查询观察断点，这是专有的命令，普通断点和捕捉断点没有。
- clear 命令可以删除指定位置处的所有断点clear location参数 location 通常为某一行代码的行号或者某个具体的函数名。当 location 参数为某个函数的函数名时，表示删除位于该函数入口处的所有断点。
- delete 命令（可以缩写为 d ）通常用来删除所有断点，也可以删除指定编号的各类型断点。不加编号就是删除所有断点。
- 禁用断点可以使用 disable 命令。没有参数表示禁用所有断点。enable激活断点，不指定参数表示激活所有断点。

##### GDB单步调试程序

- GDB 调试器共提供了 3 种可实现单步调试程序的方法，即使用 next、step 和 until 命令，next和step可以指定执行几行，例如 n 2     s 2

- next 是最常用来进行单步调试的命令，其最大的特点是当遇到包含调用函数的语句时，无论函数内部包含多少行代码，next 指令都会一步执行完。也就是说，对于调用的函数来说，next 命令只会将其视作一行代码。

  ```
  (gdb) next count
  ```

  - 参数 count 表示单步执行多少行代码，默认为 1 行。

- 当 step 命令所执行的代码行中包含函数时，会进入该函数内部，并在函数第一行代码处停止执行。step 命令可以缩写为 s 命令

  ```
  (gdb) step count
  ```

  - 参数 count 表示一次执行的行数，默认为 1 行。

- until 命令可以简写为 u 命令，有 2 种语法格式until   until location    不带参数的 until 命令，可以使 GDB 调试器快速运行完当前的循环体，并运行至循环体外停止。注意，until 命令并非任何情况下都会发挥这个作用，只有当执行至循环体尾部（最后一行代码）时，until 命令才会发生此作用；反之，until 命令和 next 命令的功能一样，只是单步执行程序。until 命令还可以后跟某行代码的行号，以指示 GDB 调试器直接执行至指定位置后停止。

  ```
  1、(gdb) until
  2、(gdb) until location
  ```

  - 其中，参数 location 为某一行代码的行号。
  - 实际验证until在循环最后一行是可以跳出循环的，但是如果循环在main函数里面好像不太行，不知道为什么，注意一下。

##### GDB断点调试

- 通过在程序的适当位置打断点，观察程序执行至该位置时某些变量（或表达式）的值，进而不断缩小导致程序出现异常或 Bug 的语句的搜索范围，并最终找到，整个过程就称为断点调试。

| 命令                                    | 功能                                                         |
| --------------------------------------- | ------------------------------------------------------------ |
| run（r）                                | 启动或者重启一个程序。                                       |
| list（l）                               | 显示带有行号的源码。                                         |
| continue（c）                           | 让暂停的程序继续运行。                                       |
| next（n）                               | 单步调试程序，即手动控制代码一行一行地执行。不会退出循环体。 |
| step（s）                               | 如果有调用函数，进入调用的函数内部；否则，和 next 命令的功能一样。 |
| until（u） until location（u location） | 当你厌倦了在一个循环体内单步跟踪时，单纯使用 until 命令，可以运行程序直到退出循环体。 until n 命令中，n 为某一行代码的行号，该命令会使程序运行至第 n 行代码处停止。 |
| finish（fin）                           | 结束当前正在执行的函数，并在跳出函数后暂停程序的执行。       |
| return（return）                        | 结束当前调用函数并返回指定值，到上一层函数调用处停止程序执行。 |
| jump（j）                               | 使程序从当前要执行的代码处，直接跳转到指定位置处继续执行后续的代码。 |
| print（p）                              | 打印指定变量的值。                                           |
| quit（q）                               | 退出 GDB 调试器。                                            |

- 实际调试时，在某个函数中调试一段时间后，可能不需要再一步步执行到函数返回处，希望直接执行完当前函数，这时可以使用 finish 命令。与 finish 命令类似的还有 return 命令，它们都可以结束当前执行的函数。finish 命令和 return 命令的区别是，finish 命令会执行函数到正常退出；而 return 命令是立即结束执行当前函数并返回，也就是说，如果当前函数还有剩余的代码未执行完毕，也不会执行了。除此之外，return 命令还有一个功能，即可以指定该函数的返回值。例如return 5，指定函数返回值。

##### 查看变量的值

- 查看变量的类型ptype命令。

  ```
  ptype[/FLAGS] TYPE | EXPRESSION
  
  Available FLAGS are:
    /r    print in "raw" form; do not substitute typedefs
    /m    do not print methods defined in a class
    /M    print methods defined in a class
    /t    do not print typedefs defined in a class
    /T    print typedefs defined in a class
    /o    print offsets and sizes of fields in a struct (like pahole)
  ```

- Printf：在 GDB 调试程序的过程中，输出或者修改指定变量或者表达式的值。其可以输出变量的值，也可以修改变量的值。例如p result = 10

- Display：用于调试阶段查看某个变量或表达式的值，它们的区别是，使用 display 命令查看变量或表达式的值，每当程序暂停执行（例如单步执行）时，GDB 调试器都会自动帮我们打印出来，而 print 命令则不会。使用 1 次 print 命令只能查看 1 次某个变量或表达式的值，而同样使用 1 次 display 命令，每次程序暂停执行时都会自动打印出目标变量或表达式的值。因此，当我们想频繁查看某个变量或表达式的值从而观察它的变化情况时，使用 display 命令可以一劳永逸。

  - 常用命令格式display expr ， expr表示要查看的目标变量或表达式

  - display/fmt expr ，参数fmt用于指定输出变量或者表达式的格式。display和/fmt之间不要有空格。以/x为例，应写为display/x expr

    | /fmt | 功 能                                |
    | ---- | ------------------------------------ |
    | /x   | 以十六进制的形式打印出整数。         |
    | /d   | 以有符号、十进制的形式打印出整数。   |
    | /u   | 以无符号、十进制的形式打印出整数。   |
    | /o   | 以八进制的形式打印出整数。           |
    | /t   | 以二进制的形式打印出整数。           |
    | /f   | 以浮点数的形式打印变量或表达式的值。 |
    | /c   | 以字符形式打印变量或表达式的值。     |

对于使用 display 命令查看的目标变量或表达式，都会被记录在一张列表（称为自动显示列表）中。通过执行info dispaly命令，可以打印出这张表。对于不需要再打印值的变量或表达式，可以将其删除或者禁用。undisplay num , delete display num，num可以是变量的名称也可以是info dispaly查出来的num编号。enable display num激活当前处于禁用状态的变量或表达式

- print 命令还有更高级的功能和用法，例如以指定的格式输出变量或者表达式的值、输出数组中指定区间内的所有元素。print [options --] [/fmt] expr  ，options 参数和 /fmt 或者 expr 之间，必须用`--`（ 2 个 - 字符）分隔。当 print 命令不指定任何 options 参数时，print 和 /fmt 之间不用添加空格，例如以十六进制的形式输出 num 整形变量的值，执行命令为 (gdb) print/x num。

| options 参数           | 功 能                                                        |
| ---------------------- | ------------------------------------------------------------ |
| -address on\|off       | 查看某一指针变量的值时，是否同时打印其占用的内存地址，默认值为 on。该选项等同于单独执行 set print address on\|off 命令。 |
| -array on\|off         | 是否以便于阅读的格式输出数组中的元素，默认值为 off。该选项等同于单独执行 set printf array on\|off 命令。 |
| -array-indexes on\|off | 对于非字符类型数组，在打印数组中每个元素值的同时，是否同时显示每个元素对应的数组下标，默认值为 off。该选项等同于单独执行 set print array-indexes on\|off 命令。 |
| -pretty on\|off        | 以便于阅读的格式打印某个结构体变量的值，默认值为 off。该选项等同于单独执行 set print pretty on\|off 命令。 |

- GDB 调试器还支持使用`@`和`::`运算符
  - `@`运算符用于输出数组中指定区域的元素 print first@len  参数 first 用于指定数组查看区域内的首个元素的值；参数 len 用于指令自 first 元素开始查看的元素个数。 print array[0]@2
  - 当程序中包含多个作用域不同但名称相同的变量或表达式时，可以借助`::`运算符明确指定要查看的目标变量或表达式print file::variable
    ，print function::variable 其中 file 用于指定具体的文件名，funciton 用于指定具体所在函数的函数名，variable 表示要查看的目标变量或表达式。例如函数中全局变量和局部变量同名时，用文件名指出全局变量，函数名指出局部变量。

##### 调试多线程

| 调试命令                            | 功 能                                                        |
| ----------------------------------- | ------------------------------------------------------------ |
| info threads                        | 查看当前调试环境中包含多少个线程，并打印出各个线程的相关信息，包括线程编号（ID）、线程名称等。 |
| thread id                           | 将线程编号为 id 的线程设置为当前线程。                       |
| thread apply id... command          | id... 表示线程的编号；command 代指 GDB 命令，如 next、continue 等。整个命令的功能是将 command 命令作用于指定编号的线程。当然，如果想将 command 命令作用于所有线程，id... 可以用 all 代替。 |
| break location thread id            | 在 location 指定的位置建立普通断点，并且该断点仅用于暂停编号为 id 的线程。 |
| set scheduler-locking off\|on\|step | 默认情况下，当程序中某一线程暂停执行时，所有执行的线程都会暂停；同样，当执行 continue 命令时，默认所有暂停的程序都会继续执行。该命令可以打破此默认设置，即只继续执行当前线程，其它线程仍停止执行。 |

- 使用 GDB 调试多线程程序时，同一时刻我们调试的焦点都只能是某个线程，被称为当前线程。整个调试过程中，GDB 调试器总是会从当前线程的角度为我们打印调试信息。GDB 调试器为了方便用户快速识别出当前线程，执行 info thread 命令后，Id 列（ID号）前标有 * 号的线程即为当前线程。我们输入的调试命令并不仅仅作用于当前线程，例如 continue、next 等，默认情况下它们作用于所有线程。

- thread id将线程编号为id的线程设置为当前线程。就是看其他线程的默认调试信息。调试器默认只输出当前线程的调试信息，修改后就可以查看其他线程了。

- 设置线程锁set scheduler-locking mode
  - off：不锁定线程，任何线程都可以随时执行；
  - on：锁定线程，只有当前线程或指定线程可以运行；
  - step：当单步执行某一线程时，其它线程不会执行，同时保证在调试过程中当前线程不会发生改变。但如果该模式下执行 continue、until、finish 命令，则其它线程也会执行，并且如果某一线程执行过程遇到断点，则 GDB 调试器会将该线程作为当前线程。
  
- 对于调试多线程程序，GDB 默认采用的是 all-stop 模式，即只要有一个线程暂停执行，所有线程都随即暂停。这种调试模式可以适用于大部分场景的需要，借助适当数量的断点，我们可以清楚地监控到各个线程的具体执行过程。但在某些场景中，我们可能需要调试个别的线程，并且不想在调试过程中，影响其它线程的运行。这种情况下，可以将 GDB 的调试模式由 all-stop 模式更改为 non-stop 模式，该模式下调试多线程程序，当某一线程暂停运行时，其它线程仍可以继续执行。non-stop 模式下可以进行 all-stop 模式无法做到的调试工作，例如：
  - 保持其它线程继续执行的状态下，单独调试某个线程；
  - 在所有线程都暂停执行的状态下，单步调试某个线程；
  - 单独执行多个线程等等。
  
  另外还有一点和 all-stop 模式不同的是，在 all-stop 模式下，continue、next、step 命令的作用对象并不是当前线程，而是所有的线程；但在 non-stop 模式下，continue、next、step 命令只作用于当前线程。在 non-stop 模式下，如果想要 continue 命令作用于所有线程，可以为 continue 命令添加一个 -a 选项，即执行 continue -a 或者 c -a 命令，即可实现令所有线程继续执行的目的。set non-stop mode，mode有on和off两个选项。non-stop 模式和 all-stop 模式的不同。在 all-stop 模式下，当某一线程暂停执行时，GDB 调试器会自行将其切换为当前线程；而在 non-stop 模式下不会。这也就解释了上面实例中，当 thread1_job 因断点暂停时当前线程仍为 main.exe 主线程。

##### 后台执行调试命令

- command&，意思是不用等调试执行结束，其后台执行（异步），直接就可以执行下一条调试信息。后台执行命令异步调试程序的方法，多用于 non-stop 模式中。虽然 all-stop 模式中也可以使用，但在前一个异步命令未执行完毕前，仍旧不能执行其它命令。
- 对于在后台处于执行状态的线程，可以使用 interrupt 命令将其中断。在 all-stop 模式下，interrupt 命令作用于所有线程，即该命令可以令整个程序暂停执行；而在 non-stop 模式下，interrupt 命令仅作用于当前线程。 如果想另其作用于所有线程，可以执行 interrupt -a 命令。

##### 调用GDB的方式

- 直接使用 gdb 指令启动 GDB 调试器

  ```
  gdb
  ```

  - 此方式启动的 GDB 调试器，由于事先未指定要调试的具体程序，因此需启动后借助 file 或者 exec-file 命令指定

- 调试尚未执行的程序

  ```
  gdb program
  ```

  - 其中，program 为可执行文件的文件名，例如上节创建好的 main.exe。

- 调试正在执行的程序

  - 在某些情况下，我们可能想调试一个当前已经启动的程序，但又不想重启该程序，就可以借助 GDB 调试器实现。

  - 也就是说，GDB 可以调试正在运行的 C、C++ 程序。要知道，每个 C 或者 C++ 程序执行时，操作系统会使用 1 个（甚至多个）进程来运行它，并且为了方便管理当前系统中运行的诸多进程，每个进程都配有唯一的进程号（PID）。

  - 如果需要使用 GDB 调试正在运行的 C、C++ 程序，需要事先找到该程序运行所对应的进程号。查找方式很简单，执行如下命令即可：

    ```
    pidof 文件名
    ```

  - 可以看到，当前正在执行的 main.exe 对应的进程号为 1830。在此基础上，可以调用 GDB 对该程序进行调试，调用指令有以下 3 种形式：

    ```
    \1) gdb attach PID
    \2) gdb 文件名 PID
    \3) gdb -p PID
    ```

  - 注意，当 GDB 调试器成功连接到指定进程上时，程序执行会暂停

  - 注意，当调试完成后，如果想令当前程序进行执行，消除调试操作对它的影响，需手动将 GDB 调试器与程序分离，分离过程分为 2 步：

    1. 执行 detach 指令，使 GDB 调试器和程序分离；
    2. 执行 quit（或 q）指令，退出 GDB 调试。

- 调试执行异常崩溃的程序

  - 调试core.dump文件，如后面所述

- 在启动 GDB 调试器时常用的指令参数，以及它们各自的功能。

  | 参 数                 | 功 能                                                        |
  | --------------------- | ------------------------------------------------------------ |
  | -pid number -p number | 调试进程 ID 为 number 的程序。                               |
  | -symbols file -s file | 仅从指定 file 文件中读取符号表。                             |
  | -q -quiet -silent     | 取消启动 GDB 调试器时打印的介绍信息和版权信息                |
  | -cd directory         | 以 directory 作为启动 GDB 调试器的工作目录，而非当前所在目录。 |
  | --args 参数1 参数2... | 向可执行文件传递执行所需要的参数。                           |

###### gdb调试正在运行中的进程

- 有时会遇到一种很特殊的调试需求，对当前正在运行的其它进程进行调试（正是我今天遇到的情形）。这种情况有可能发生在那些无法直接在调试器中运行的进程身上，例如有的进程 只能在系统启动时运行。另外如果需要对进程产生的子进程进行调试的话，也只能采用这种方式。GDB可以对正在执行的程序进行调度，它允许开发人员中断程序 并查看其状态，之后还能让这个程序正常地继续执行。

- GDB提供了两种方式来调试正在运行的进程：一种是在GDB命令行上指定进程的PID，另一种是在GDB中使用“attach”命令。

  ```
  gdb /usr/system/INTEG/dpr/V10.6.115/bin/build_main 24450
  或者先进入gdb然后使用attach命令pid来调试
  ```

##### 调试多进程程序

- attach PID号

  - 无论父进程还是子进程，都可以借助 attach 命令启动 GDB 调试它。attach 命令用于调试正在运行的进程，要知道对于每个运行的进程，操作系统都会为其配备一个独一无二的 ID 号。在得知目标子进程 ID 号的前提下，就可以借助 attach 命令来启动 GDB 对其进行调试。

  - 这里还需要解决一个问题，很多场景中子进程的执行时间都是一瞬而逝的，这意味着，我们可能还未查到它的进程 ID 号，该进程就已经执行完了，何谈借助 attach 命令对其调试呢？对于 C、C++ 多进程程序，解决该问题最简单直接的方法是，在目标进程所执行代码的开头位置，添加一段延时执行的代码。

    ```
    #include <stdio.h>
    #include <unistd.h>
    int main()
    {
        pid_t pid = fork();
        if(pid == 0)
        {
            printf("this is child,pid = %d\n",getpid());
        }
        else
        {
            printf("this is parent,pid = %d\n",getpid());
        }
        return 0;
    }
    
    修改一下
    if(pid == 0)
    {
        int num =10;
        while(num==10){
            sleep(10);
        }
        printf("this is child,pid = %d\n",getpid());
    }
    ```

  - 可以看到，通过添加第 3~6 行代码，该进程执行时会直接进入死循环。这样做的好处有 2 个，其一是帮助 attach 命令成功捕捉到要调试的进程；其二是使用 GDB 调试该进程时，进程中真正的代码部分尚未得到执行，使得我们可以从头开始对进程中的代码进行调试。

    ```
    [root@bogon demo]# gdb myfork.exe -q
    Reading symbols from ~/demo/myfork.exe...done.
    (gdb) r
    Starting program: ~/demo/myfork.exe
    Detaching after fork from child process 5316.  <-- 子进程的 ID 号为 5316
    this is parent,pid = 5313               <-- 父进程执行完毕
    
    Program exited normally.
    (gdb) attach 5316                          <-- 跳转调试 ID 号为 5316 的子进程
    ......
    (gdb) n                                           <-- 程序正在运行，所有直接使用 next 命令就可以进行单步调试
    Single stepping until exit from function __nanosleep_nocancel,
    which has no line number information.
    0x00000037ee2acb50 in sleep () from /lib64/libc.so.6
    (gdb) n
    Single stepping until exit from function sleep,
    which has no line number information.
    main () at myfork.c:10
    10  while(num==10){
    (gdb) p num=1
    $1 = 1
    (gdb) n                                           <-- 跳出循环
    13         printf("this is child,pid = %d\n",getpid());
    (gdb) c
    Continuing.
    this is child,pid = 5316
    
    Program exited normally.
    (gdb) 
    ```

    

- pidof命令可以手动获取进程id号，pidof是shell命令

  - pidof + 进程名可以直接查看进程id，如果查不出来，带上全路径查看。

- 使用GDB调试某个进程，如果该进程fork了子进程，GDB会继续调试该进程，子进程会不受干扰地运行下去。

- gdb调试多进程程序时打印

  ```
  Detaching after fork from child process 28804.
  Detaching after fork from child process 28806.
  ```

  - 当 GDB 正在调试一个特定的进程，并且该进程派生出一个子进程时，GDB 只能跟随两个进程中的一个，因此它必须分离（停止跟随）另一个。这打印告诉你这种选择性的分离。子进程将在不被 GDB 调试的情况下运行。
  - 可以使用下面的方法调试子进程。

- 前面提到，GDB 调试多进程程序时默认只调试父进程。对于内核版本为 2.5.46 甚至更高的 Linux 发行版系统来说，可以通过修改 follow-fork-mode 或者 detach-on-fork 选项的值来调整这一默认设置。

- GDB follow-fork-mode选项

  - 确切地说，对于使用 fork() 或者 vfork() 函数构建的多进程程序，借助 follow-fork-mode 选项可以设定 GDB 调试父进程还是子进程。该选项的使用语法格式为：

  ```
  (gdb) set follow-fork-mode mode
  ```

  - 参数 mode 的可选值有 2 个：

    - parent：选项的默认值，表示 GDB 调试器默认只调试父进程；

    - child：和 parent 完全相反，它使的 GDB 只调试子进程。且当程序中包含多个子进程时，我们可以逐一对它们进行调试。


    ```
    (gdb) show follow-fork-mode
    Debugger response to a program call of fork or vfork is "parent".
    (gdb) set follow-fork-mode child                        <-- 调试子进程
    (gdb) r 
    Starting program: ~/demo/myfork.exe
    [New process 5376]
    this is parent,pid = 5375                  <-- 父进程执行完成
    
    Program received signal SIGTSTP, Stopped (user).
    [Switching to process 5376]             <-- 自动进入子进程
    0x00000037ee2accc0 in __nanosleep_nocancel () from /lib64/libc.so.6
    (gdb) n
    Single stepping until exit from function __nanosleep_nocancel,
    which has no line number information.
    0x00000037ee2acb50 in sleep () from /lib64/libc.so.6
    (gdb) n
    Single stepping until exit from function sleep,
    which has no line number information.
    main () at myfork.c:10
    10  while(num==10){
    (gdb) p num=1
    $2 = 1
    (gdb) c
    Continuing.
    this is child,pid = 5376
    ```
    
    ```
    通过执行如下命令，我们可以轻松了解到当前调试环境中 follow-fork-mode 选项的值：
    (gdb) show follow-fork-mode
    Debugger response to a program call of fork or vfork is "child".
    ```

- GDB detach-on-fork选项

  - 注意，借助 follow-fork-mode 选项，我们只能选择调试子进程还是父进程，且一经选定，调试过程中将无法改变。如果既想调试父进程，又想随时切换并调试某个子进程，就需要借助 detach-on-fork 选项。

  - detach-on-fork 选项的语法格式如下：

  ```
  (gdb) set detach-on-fork mode
  ```

  - 其中，mode 参数的可选值有 2 个：

    - on：默认值，表明 GDB 只调试一个进程，可以是父进程，或者某个子进程；

    - off：程序中出现的每个进程都会被 GDB 记录，我们可以随时切换到任意一个进程进行调试。

  - 和 detach-on-fork 搭配使用的，还有如表 1 所示的几个命令。

    | 命令语法格式             | 功 能                                                        |
    | ------------------------ | ------------------------------------------------------------ |
    | (gdb)show detach-on-fork | 查看当前调试环境中 detach-on-fork 选项的值。                 |
    | (gdb) info inferiors     | 查看当前调试环境中有多少个进程。其中，进程 id 号前带有 * 号的为当前正在调试的进程。 |
    | (gdb) inferiors id       | 切换到指定 ID 编号的进程对其进行调试。                       |
    | (gdb) detach inferior id | 断开 GDB 与指定 id 编号进程之间的联系，使该进程可以独立运行。不过，该进程仍存在 info inferiors 打印的列表中，其 Describution 列为 <null>，并且借助 run 仍可以重新启用。 |
    | (gdb) kill inferior id   | 断开 GDB 与指定 id 编号进程之间的联系，并中断该进程的执行。不过，该进程仍存在 info inferiors 打印的列表中，其 Describution 列为 <null>，并且借助 run 仍可以重新启用。 |
    | remove-inferior id       | 彻底删除指令 id 编号的进程（从 info inferiors 打印的列表中消除），不过在执行此操作之前，需先使用 detach inferior id 或者 kill inferior id 命令将该进程与 GDB 分离，同时确认其不是当前进程。 |

  ```
  (gdb) set detach-on-fork off             <-- 令 GDB 可调试多个进程
  (gdb) b 6
  Breakpoint 1 at 0x11b5: file myfork.c, line 6.
  (gdb) r
  Starting program: ~/demo/myfork.exe
  
  Breakpoint 1, main () at myfork.c:6
  6     pid_t pid = fork();
  (gdb) n
  [New inferior 2 (process 5163)]           <-- 新增一个子进程，ID 号为 5163
  Reading symbols from ~/demo/myfork.exe...
  Reading symbols from /usr/lib/debug/lib/x86_64-linux-gnu/libc-2.31.so...
  7     if(pid == 0)
  (gdb) n                                                <-- 由于 GDB 默认调试父进程，因此进入 else 语句
  17     int mnum=5;
  (gdb) info inferiors     <-- 查看当前调试环境中的进程数，当前有 2 个进程，1 号进程为当前正在调试的进程
    Num  Description       Executable       
  * 1    process 5159      ~/demo/myfork.exe
    2    process 5163       ~/demo/myfork.exe
  (gdb) inferior 2                                   <-- 进入 id 号为 2 的子进程
  [Switching to inferior 2 [process 5163] (~/demo/myfork.exe)]
  [Switching to thread 2.1 (process 5163)]
  (gdb) n
  53 in ../sysdeps/unix/sysv/linux/arch-fork.h
  (gdb) n
  __libc_fork () at ../sysdeps/nptl/fork.c:78
  78 ../sysdeps/nptl/fork.c: No such file or directory.
  (gdb) n
  ......                                                       <-- 执行多个 next 命令
  (gdb) n
  main () at myfork.c:7                           <-- 正式单步调试子进程  
  7     if(pid == 0)
  (gdb) n
  9         int num =10;
  (gdb)
  ```

  

##### 反向调试

- 读到本节，我们已经学会了借助 GDB 调试器对代码进行单步调试和断点调试。这 2 种调试方法有一个共同的特点，即调试过程中代码一直都是“正向”执行的（从第一行代码执行到最后一行代码）。这就产生一个问题，如果调试过程中不小心多执行了一次 next、step 或者 continue 命令，又或者想再次查看刚刚程序执行的过程，该怎么办呢？

- 面对这种情况，很多读者想到的是借助 run 命令重新启动程序，还原之前所做的所有调试工作。的确，这种方式可以解决上面列举的类似问题，只不过比较麻烦。事实上，如果我们使用的是 7.0 及以上版本的 GDB 调试器，还有一种更简单的解决方法，即反向调试。

- 所谓反向调试，指的是临时改变程序的执行方向，反向执行指定行数的代码，此过程中 GDB 调试器可以消除这些代码所做的工作，将调试环境还原到这些代码未执行前的状态。

- 要想反向调试程序，我们需要学会使用相应的一些命令。表 1 为大家罗列了完成反向调试常用的一些命令，并且展示各个命令的使用格式和对应的功能。

  | 命 令                            | 功 能                                                        |
  | -------------------------------- | ------------------------------------------------------------ |
  | (gdb) record (gdb) record btrace | 让程序开始记录反向调试所必要的信息，其中包括保存程序每一步运行的结果等等信息。进行反向调试之前（启动程序之后），需执行此命令，否则是无法进行反向调试的。 |
  | (gdb) reverse-continue (gdb) rc  | 反向运行程序，直到遇到使程序中断的事件，比如断点或者已经退回到 record 命令开启时程序执行到的位置。 |
  | (gdb) reverse-step               | 反向执行一行代码，并在上一行代码的开头处暂停。和 step 命令类似，当反向遇到函数时，该命令会回退到函数内部，并在函数最后一行代码的开头处（通常为 return 0; ）暂停执行。 |
  | (gdb) reverse-next               | 反向执行一行代码，并在上一行代码的开头处暂停。和 reverse-step 命令不同，该命令不会进入函数内部，而仅将被调用函数视为一行代码。 |
  | (gdb) reverse-finish             | 当在函数内部进行反向调试时，该命令可以回退到调用当前函数的代码处。 |
  | (gdb) set exec-direction mode    | mode 参数值可以为 forward （默认值）和 reverse：forward 表示 GDB 以正常的方式执行所有命令；reverse 表示 GDB 将反向执行所有命令，由此我们直接只用step、next、continue、finish 命令来反向调试程序。注意，return 命令不能在 reverse 模式中使用。 |

  - 注意，表 1 中仅罗列了常用的一些命令，并且仅展示了各个命令最常用的语法格式。有关 GDB 调试器提供的更多支持反向调试的命令，以及各个命令不同的语法格式，感兴趣的读者可前往[ GDB官网](https://sourceware.org/gdb/current/onlinedocs/gdb/Reverse-Execution.html#Reverse-Execution)查看。
  - h running 可以查看各种运行命令，包括缩写。有的有缩写有的没有。
  - record是记录一些反向调试所必要的信息，程序反向运行并不能无限的反向运行，只能运行到record刚开始的地方，因为record会记录一些信息，所以反向调试才会成功，如果没有record记录的这些信息，反向调试就会失败。所以需要record命令。
  - info record可以看record信息。record btrace是记录分支的，如果只是一个record，和record命令一样，但是record btrace可以记录分支。类似于在记录一个，这只是猜测，需要后续验证一下。

- 程序如下

  ```
  #include <stdio.h>
  int main ()
  {
      int n, sum;
      n = 1;
      sum = 0;
      while (n <= 100)
      {
          sum = sum + n;
          n = n + 1;
      }
      return 0;
  }
  ```

  ```
  (gdb) b 6
  Breakpoint 1 at 0x40047f: file main.c, line 6.
  (gdb) r
  Starting program: ~/demo/main.exe
  
  Breakpoint 1, main () at main.c:6
  6     sum = 0;
  (gdb) record                                                       <-- 开启记录模式
  (gdb) b 10 if n==10
  Breakpoint 2 at 0x40048e: file main.c, line 10.
  (gdb) c
  Continuing.
  
  Breakpoint 2, main () at main.c:10
  10         n = n + 1;
  (gdb) p n                                                           <-- 执行至 n=10，sum=55
  $1 = 10
  (gdb) p sum
  $2 = 55
  (gdb) reverse-next                                            <-- 回退一步，暂停在第 9 行代码开头处
  9         sum = sum + n;
  (gdb) p n                                                           <-- 此时 n=10，sum=45
  $3 = 10
  (gdb) p sum
  $4 = 45
  (gdb) reverse-continue                                      <-- 反向执行代码，直至第 6 行，也就是开启记录的起始位置
  Continuing.
  
  No more reverse-execution history.
  main () at main.c:6
  6     sum = 0;
  (gdb) p n                                                             <-- 回到了 n=1，sum=0 的时候
  $5 = 1
  (gdb) p sum
  $6 = 0
  (gdb)
  ```

- 对于打印到屏幕的数据并不会因为打印语句的回退而自动消失。换句话说，对于程序中出现的打印语句（例如 C 语言中的 printf() 输出函数），虽然可以进行反向调试，但已经输出到屏幕上的数据不会因反向调试而撤销。另外，反向调试也不适用于包含 I/O 操作的代码。

- 总的来说，尽管 GDB 调试功能尚不完善，但瑕不掩瑜，它能满足大部分场景的需要。在需要进行将代码反向执行时，读者可以先尝试使用 GDB 反向调试，其次再使用 run 命令重新开启调试。

##### 信号处理

- 信号是kill -l显示的32个信号
- handle命令handle signal mode

##### 查看栈信息

- 对于 C、C++ 程序而言，异常往往出现在某个函数体内，例如 main() 主函数、调用的系统库函数或者自定义的函数等。要知道，程序中每个被调用的函数在执行时，都会生成一些必要的信息，包括：

  - 函数调用发生在程序中的具体位置；
  - 调用函数时的参数；
  - 函数体内部各局部变量的值等等。

  这些信息会集中存储在一块称为“栈帧”的内存空间中。也就是说，程序执行时调用了多少个函数，就会相应产生多少个栈帧，其中每个栈帧自函数调用时生成，函数调用结束后自动销毁。

  这也就意味着，当程序因某种异常暂停执行时，如果其发生在某个函数内部，我们可以尝试借助该函数对应栈帧中记录的信息，找到程序发生异常的原因。

- main() 主函数对应的栈帧，又称为初始帧或者最外层的帧。除此之外，每当程序中多调用一个函数，执行过程中就会生成一个新的栈帧。更甚者，如果该函数是一个递归函数，则会生成多个栈帧。在程序内部，各个栈帧用地址作为它们的标识符，注意这里的地址并不一定为栈帧的起始地址。我们知道，每个栈帧往往是由连续的多个字节构成，每个字节都有自己的地址，不同操作系统为栈帧选定地址标识符的规则不同，它们会选择其中一个字节的地址作为栈帧的标识符。

- backtrace 命令用于打印当前调试环境中所有栈帧的信息

  ```gdb
  backtrace [-full] [n]
  ```

  用 [ ] 括起来的参数为可选项，它们的含义分别为：

  - n：一个整数值，当为正整数时，表示打印最里层的 n 个栈帧的信息；n 为负整数时，那么表示打印最外层 n 个栈帧的信息；
  - -full：打印栈帧信息的同时，打印出局部变量的值。

  当调试多线程程序时，该命令仅用于打印当前线程中所有栈帧的信息。如果想要打印所有线程的栈帧信息，应执行`thread apply all backtrace`命令。

-  借助如下命令，我们可以查看当前栈帧中存储的信息

  ```
  info frame
  ```

  该命令会依次打印出当前栈帧的如下信息：

  - 当前栈帧的编号，以及栈帧的地址；
  - 当前栈帧对应函数的存储地址，以及该函数被调用时的代码存储的地址
  - 当前函数的调用者，对应的栈帧的地址；
  - 编写此栈帧所用的编程语言；
  - 函数参数的存储地址以及值；
  - 函数中局部变量的存储地址；
  - 栈帧中存储的寄存器变量，例如指令寄存器（64位环境中用 rip 表示，32为环境中用 eip 表示）、堆栈基指针寄存器（64位环境用 rbp 表示，32位环境用 ebp 表示）等。

  除此之外，还可以使用`info args`命令查看当前函数各个参数的值；使用`info locals`命令查看当前函数中各局部变量的值。

- 根据栈帧编号或者栈帧地址，选定要查看的栈帧，语法格式如下

  ```
  frame spec
  ```

  该命令可以将 spec 参数指定的栈帧选定为当前栈帧。spec 参数的值，常用的指定方法有 3 种：

  1. 通过栈帧的编号指定。0 为当前被调用函数对应的栈帧号，最大编号的栈帧对应的函数通常就是 main() 主函数；
  2. 借助栈帧的地址指定。栈帧地址可以通过 info frame 命令（后续会讲）打印出的信息中看到；
  3. 通过函数的函数名指定。注意，如果是类似递归函数，其对应多个栈帧的话，通过此方法指定的是编号最小的那个栈帧。

  通过up和down调整当前栈帧。

- frame可以简写为f，gdb起来bt之后显示结果中

  ```c
  (gdb) bt
  #0  0x00007f949f622ff4 in _int_malloc () from /lib64/libc.so.6
  #1  0x00007f949f62678c in malloc () from /lib64/libc.so.6
  #2  0x000000000040857d in print_string_ptr (str=0x7f9490000a40 "module") at ../common/cJSON.c:222
  #3  0x00000000004092e4 in print_object (item=<optimized out>, fmt=1, depth=1) at ../common/cJSON.c:472
  #4  print_value (item=<optimized out>, depth=0, fmt=1) at ../common/cJSON.c:314
  #5  0x0000000000404981 in createJsonQueryUser (model=model@entry=0x40b2d8 "user_manage", type=type@entry=0x40b2d2 "query", query_info=...,
      wParam=wParam@entry=0, lParam=<optimized out>) at xUiMessage.cpp:76
  #6  0x00000000004037a2 in XUISession::__requestLogin (this=this@entry=0x7f9498000900, rpc=0x7f94980009f0, req=req@entry=0x7f94900008f0) at xUISession.cpp:119
  #7  0x000000000040477f in XUISession::Run (this=0x7f9498000900) at xUISession.cpp:640
  #8  0x0000000000406bfa in XThread::__threadFunc (lParam=0x7f9498000900) at ../common/xThread.cpp:228
  #9  0x0000000000406b27 in __posixThread (lParam=0x7f94980008e0) at ../common/xThread.cpp:101
  #10 0x00007f94a05acea5 in start_thread () from /lib64/libpthread.so.0
  #11 0x00007f949f69fb0d in clone () from /lib64/libc.so.6
  ```

  - 其中#0这一行是栈，#0代表第一层栈，#1代表第二层栈，需要看第几层的时候直接看#后面的数字，然后f 数字就能看到第几层栈的信息

##### GDB编辑和搜索源码

- 在调试文件时，某些时候可能会去找寻找某一行或者是某一部分的代码。可以使用 list 显示全部的源码，然后进行查看。当源文件的代码量较少时，我们可以使用这种方式搜索。如果源文件的代码量很大，使用这种方式寻找效率会很低。所以 GDB 中提供了相关的源代码搜索的的 search 命令。

  ```shell
  search <regexp>
  reverse-search <regexp>
  ```

  第一项命令格式表示从当前行的开始向前搜索，后一项表示从当前行开始向后搜索。其中 regexp 就是正则表达式，正则表达式描述了一种字符串匹配的模式，可以用来检查一个串中是否含有某种子串、将匹配的子串替换或者从某个串中取出符合某个条件的子串。很多的编程语言都支持使用正则表达式。

##### GDB调试core文件

###### core文件

- 当程序运行过程中出现Segmentation fault (core dumped)错误时，程序停止运行，并产生core文件。core文件是程序运行状态的内存映象。使用gdb调试core文件，可以帮助我们快速定位程序出现段错误的位置。当然，可执行程序编译时应加上-g编译选项，生成调试信息。
- 当程序访问的内存超出了系统给定的内存空间，就会产生Segmentation fault (core dumped)，因此，段错误产生的情况主要有：
  - 访问不存在的内存地址；
  - 访问系统保护的内存地址；
  - 数组访问越界等。
- core dumped又叫核心转储, 当程序运行过程中发生异常, 程序异常退出时, 由操作系统把程序当前的内存状况存储在一个core文件中, 叫core dumped。
- core意指core memory，用线圈做的内存。如今 ，半导体工业澎勃发展，已经没有人用 core memory 了，不过，在许多情况下，人们还是把记忆体叫作 core 。

###### 控制core文件生成

- 使用ulimit -c命令可查看core文件的生成开关。若结果为0，则表示关闭了此功能，不会生成core文件。

- 使用ulimit -c filesize命令，可以限制core文件的大小（filesize的单位为KB）。如果生成的信息超过此大小，将会被裁剪，最终生成一个不完整的core文件。在调试此core文 件的时候，gdb会提示错误。比如：ulimit -c 1024。

- 使用ulimit -c unlimited，则表示core文件的大小不受限制。

- 在终端通过命令`ulimit -c unlimited`只是临时修改，重启后无效 ，要想永久修改有三种方式：

  - 在/etc/rc.local 中增加一行 ulimit -c unlimited 

  - 在/etc/profile 中增加一行 ulimit -c unlimited 

  - 在/etc/security/limits.conf最后增加如下两行记录：

    ```
    @root soft core unlimited
    @root hard core unlimited
    ```

###### core文件的名称和生成路径

- core默认的文件名称是core.pid，pid指的是产生段错误的程序的进程号。  默认路径是产生段错误的程序的当前目录。
- 如果想修改core文件的名称和生成路径，相关的配置文件为：  
  - **/proc/sys/kernel/core_uses_pid：**控制产生的core文件的文件名中是否添加pid作为扩展，如果添加则文件内容为1，否则为0。
  - **/proc/sys/kernel/core_pattern：**可以设置格式化的core文件保存的位置和文件名，比如原来文件内容是core-%e。  可以这样修改:  echo “/corefile/core-%e-%p-%t” > /proc/sys/kernel/core_pattern  将会控制所产生的core文件会存放到/corefile目录下，产生的文件名为：core-命令名-pid-时间戳。
    -  %p - insert pid into filename 添加pid 
    -  %u - insert current uid into filename 添加当前uid  
    - %g - insert current gid into filename 添加当前gid  
    - %s - insert signal that caused the coredump into the filename 添加导致产生core的信号 
    -  %t - insert UNIX time that the coredump occurred into filename 添加core文件生成时的unix时间 
    -  %h - insert hostname where the coredump happened into filename 添加主机名  
    - %e - insert coredumping executable name into filename 添加命令名。  
    - 一般情况下，无需修改，按照默认的方式即可。

###### GDB调试core文件

- 使用gdb调试core文件来查找程序中出现段错误的位置时，要注意的是可执行程序在编译的时候需要加上-g编译命令选项。
- gdb调试core文件的步骤常见的有如下几种，推荐第一种。
- 第一种
  - 启动gdb，进入core文件，命令格式：**gdb [exec file] [core file]**。
  - 在进入gdb后，查找段错误位置：**where或者bt** 
- 第二种
  - 启动gdb，进入core文件，命令格式：**gdb –core=[core file]**
  - 在进入gdb后，指定core文件对应的符号表，命令格式：**file [exec file]** .
  - 查找段错误位置：**where或者bt**。
- 第三种
  - 启动gdb，进入core文件，命令格式：**gdb -c [core file]**。 
  - 在进入gdb后，指定core文件对应的符号表，命令格式：**file [exec file]** . 
  - 查找段错误位置：**where或者bt**。

##### GDB技巧

###### gdb提示No such file

- gdb提示的是找不到源码文件，但是不影响我们调试，源码文件找不到只是我们不能用list来查看源码了，但是可以正常调试。

  ```
  check_airport_runway.a: No such file or directory.
  ```

  - 上面的实例为l命令查看，提示找不到文件，或者打断点之后，c命令运行，到断点处程序暂停之后，也会提示这个。

###### 编译器优化的问题和调试时行号不对应的问题

- 在**没有开启编译优化**时，GCC编译器的目的是：**减少编译时间**和**生成预期的调试结果**。对于GCC编译的程序，调试的语句都是独立的，可以在程序的任何语句中设置断点，并设置变量的值和修改语句的执行，得到你想要的执行结果。
- 在**开启编译优化的开关**时，GCC编译器的目的是：**优化程序的性能**和**减少代码的大小**，尽管会以牺牲编译时间和程序的可调试能力为代价。
  - 所以在优化之后源文件的代码和编译优化之后可执行程序里面的代码段就会有区别，可能导致行号错乱。

- 编译器对于程序的优化处理是基于编译期间对程序分析。**不是所有的优化都是通过编译选项来控制的**。这里只介绍一些有编译选项的优化列表。在编译选项**-O0**或者**-O**下很多的优化是关闭的，即使设置独立的编译优化选项，例如**-Og**，也省略了很多优化过程。对于不同的优化级别开启的对应优化开关可以通过`gcc -Q -O2 --help=optimizers`来查看对应的开启优化列表。

- gcc优化选项

  - -O/-O1

    - 这两个都是开启level 1的编译优化。开启编译优化会导致更长的编译时间，对于大函数还会消耗更多的内存空间。level1的编译优化下，编译器会**尝试减少代码段大小和优化程序的执行时间**，**但不执行需要消耗大量编译时间的优化**。
    - 由此可见level 1级别的优化，只是有限的优化代码大小和执行时间，不会为了优化，而带来编译时间的巨大变化。Level 1级别的优化下，可以通过`gcc -Q -O1 --help=optimizers`查看开启的编译开关

  - -O2

    - 相比于-O1，-O2打开了更多的编译优化开关。level2级别的优化选项相对于-O，**牺牲了更多编译时间，但提高了程序的性能**。

  - -O3

    -  比-O2优化的更多

  - -O0

    - **默认的优化选项**，减少编译时间和生成完整的调试信息。

  - -Os

    - 优化生成的目标文件的大小。-Os是基于-O2的优化选项，

    - 按照手册的说法：

      > -Os开启了-O2优化选项的所有开关，除了会增加生成代码大小的以下一些开关，
      > -falign-functions -falign-jumps
      > -falign-labels -falign-loops
      > -fprefetch-loop-arrays -freorder-blocks-algorithm=stc

- 很多项目的**线上版本都是使用”-O2 -g”的编译选项进行编译**，以便发生问题的时候容易定位。但这有一个很大的弊端就是目标文件会比不开启调试信息的情况下大很多，所以一般对外发布的软件都是不含有调试信息的release版本，同时也会发布含有调试信息的debug版本，两者的性能是一样的只是debug多了调试信息而已。

- 行号不对应还可能是因为文件太大，行数太多导致的，例如在华泰遇到的，一个源文件6000行左右，到5000行在按n执行就直接显示1，但是这不是真正的第一行，而是将剩下的代码重新按照第一行读取来的，比如5000行以后的5001是第一行，5002是第二行。相当于基数变了，剩下的直接从1开始计数了，因为太大了，剩下的读取不到。

###### 源码路径查看与设置

- 查看源码搜索路径`show dir`，其中cdir表示编译路径compilation directory，cwd表示当前路径current working directory。
- 用-g编译过后的执行程序中只是包括了源文件的名字，没有路径名。GDB提供了可以让你指定源文件的路径的命令，以便GDB进行搜索。dir命令+绝对路径。

###### 一些其他

- info的简写是i
- n不会跳过if和循环，只是会跳过函数，但是其有判断条件，可能会不执行这个if和循环代码，直接往下走好多行。
- 回车键是重复上一个命令
- list <源文件> ，例list test.c ，以后的list都是显示显示这个test.c的源文件。
- 编译的时候-g选项会将文件名这些选项加上去，虽然我们list看不到源文件，但是我们可以根据文件名直接打断点，因为文件名包含在了gdb启动的程序中，不用list看到源文件也可以打断点。
- Info frame简写为i f，表示打印当前栈的一些信息，f <数字>表示将数字表示的第几层栈设置为当前的栈，用i f可以查看栈信息。可以用bt查看当前所有的栈的信息，然后用f设置即可。
- 使用gdb调试修改变量的值时，不同的语言使用不同的赋值语句，例如c语言 p a = 1，ada语言 p a:=1。set也可以设置，用法和p一样
- gdb有一些环境设置，使用help set可以看到这些环境设置，设置时不需要等号，例如 set varsize-limit 0，使用show命令可以查看这些变量的值。例如show varsize-limit。set赋值和set修改gdb环境语法有区别。
