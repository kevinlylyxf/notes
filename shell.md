### shell脚本

- shell变量
   - Bash shell默认情况下不会区分变量类型，即是将整数和小数赋值给变量，也会被视为字符串，可以使用declare关键字显示定义变量的类型，一般情况下没有这个需求
   - 三种定义变量的方式，variable=value,variable='value',variable="value",variable是变量名，value是赋给变量的值，如果value不包含任何空白符(空格、Tab缩进)，可以不用引号，单引号引起来的是什么就输出什么，不希望解析变量命令。双引号引起来的输出时会先解析里面的变量和命令。不被引号包围的字符串不能出现空格，否则空格后边的字符串会作为其他变量或者命令解析。
   - 赋值号=周围不能有空格
   - 使用变量，在变量名前面加$符号，变量名字前面有没有{}都可以，加括号是为了帮助解释器识别变量的边界，良好的编程习惯
   - 将命令的结果赋值给变量 variable=`command`,variable=$(command),第一种方式用反引号包围起来，第二种方式用$()包围起来更常用。例如log=$(cat log.txt),echo $log
     - 只是将命令的输出结果(输出到终端)赋值给一个变量，命令执行成功与否用if判断，或者用$?
   - 只读变量 readonly variable，删除变量unset，unset不能删除只读变量
   
- shell变量的作用范围
  
   - Shell 也支持自定义函数，但是 Shell 函数和 C++、Java、C# 等其他编程语言函数的一个不同点就是：在 Shell 函数中定义的变量默认也是全局变量，它和在函数外部定义变量拥有一样的效果
   
      ```
      #!/bin/bash
      
      #定义函数
      function func(){
          a=99
      }
      
      #调用函数
      func
      
      #输出函数内部的变量
      echo $a
      
      输出99
      ```
   
      - 所以在一些函数定义的后面要使用unset来删除这个函数内定义的变量。
   
   - shell函数中定义的变量默认是全局变量，它和在函数外定义的变量一样的效果
   
   - 局部变量定义时加上local
   
   - 需要强调的是，全局变量的作用范围是当前的 Shell 进程(对子shell和子进程都是无效的，参考下面的子shell和子进程一节)，而不是当前的 Shell 脚本文件，它们是不同的概念。打开一个 Shell 窗口就创建了一个 Shell 进程，打开多个 Shell 窗口就创建了多个 Shell 进程，每个 Shell 进程都是独立的，拥有不同的进程 ID。在一个 Shell 进程中可以使用 source 命令执行多个 Shell 脚本文件，此时全局变量在这些脚本文件中都有效。source命令相当于在当前shell进程中，并没有创建一个子进程，所以source的脚本命令都相当于在一个shell进程中
   
      ```
      test1.sh
      #!/bin/sh
      a=4
      
      test.sh
      #!/bin/sh
      echo $a
      
      如果执行
      source test1.sh 
      source test.sh
      输出结果为4
      
      如果执行
      ./test1.sh
      ./test.sh
      没有任何输出结果
      
      source两个脚本，相当于在一个shell进程中执行一样，即使test1.sh中的变量不是export的，test脚本也可以直接使用。source的脚本就相当于在命令行执行一样，上面的source两个脚本，就相当于在命令行中定义了一个变量a，然后echo这个变量一样。类似于都在命令行中执行。
      
      如果不是source的，是执行执行的，就相当于开启了一个子进程，除了export的环境变量能用，其他的变量都不能用。
      ```
   
      - 上面的意思是说一个shell窗口是一个shell进程，如果在shell窗口中定义一个变量，然后在shell脚本中可以使用这个变量。这个是错误的，不能这么用。
         - 如果要在shell窗口中定义一个变量然后脚本中使用，只能用export，参考下面环境变量，export变量之后，在脚本里面可以使用这个变量。
      - 全局变量的作用范围只是在当前的shell进程，如果在当前的脚本文件中执行其他的脚本，就会另起一个进程，在当前文件中定义的全局变量在其他的脚本文件中不能直接使用这个变量。如果source的话可以。
   
   - 环境变量，使用export命令将全局变量导出，那么它的子进程也可以使用了，没有关系的两个进程不可以使用。进入子进程直接输入bash命令就行，exit退出
   
      - 全局变量只在当前 Shell 进程中有效，对其它 Shell 进程和子进程都无效。如果使用`export`命令将全局变量导出，那么它就在所有的子进程中也有效了，这称为“环境变量”。
      - 环境变量被创建时所处的 Shell 进程称为父进程，如果在父进程中再创建一个新的进程来执行 Shell 命令，那么这个新的进程被称作 Shell 子进程。当 Shell 子进程产生时，它会继承父进程的环境变量为自己所用，所以说环境变量可从父进程传给子进程。不难理解，环境变量还可以传递给孙进程。
        - 用sh test.sh这样执行脚本，会创建一个新进程，所以里面的export在当前shell里面看不到，但是我们可以用source来执行，这样可以在当前进程里面看到。
      - 注意，两个没有父子关系的 Shell 进程是不能传递环境变量的，并且环境变量只能向下传递而不能向上传递，即“传子不传父”。
      - 我们一直强调的是环境变量在 Shell 子进程中有效，并没有说它在所有的 Shell 进程中都有效；如果你通过终端创建了一个新的 Shell 窗口，那它就不是当前 Shell 的子进程，环境变量对这个新的 Shell 进程仍然是无效的。
      - 通过 export 导出的环境变量只对当前 Shell 进程以及所有的子进程有效，如果最顶层的父进程被关闭了，那么环境变量也就随之消失了，其它的进程也就无法使用了，所以说环境变量也是临时的。
      - 如果想让环境变量长期有效需要写进配置文件中
      - 这个是环境变量，makefile也可以使用环境变量，所以我们可以让shell脚本中导出环境变量然后在shell脚本中执行make命令，来让make执行的makefile脚本中也使用这个环境变量。
   
- shell命令替换
   - shell命令替换是指将命令的输出结果赋值给某个变量。
   - 可以使用；使用多个命令例如$(cd `dirname $0`;pwd)，$0是文件名,dirname就是获取当前文件路径的上一级 ，例如dirname /usr/bin,结果为/usr,dirname stdio.h,结果为.一个点，即表示当前目录,dirname /home/lyl/a/test.sh,结果为/home/lyl/a.后续如果要用的话直接cd进去，pwd显示当前路径，用命令替换给变量。这样就得到了路径名。文件名和路径不一样。这样操作下来其实就是用一个变量代替了路径名称，用的时候直接cd进去，就直接到了工作目录。
   - %格式控制符，以什么格式显示时间date +%s，显示的是秒为单位，date +"%Y-%m-%d",以年月日的格式显示
   - 如果被替换的命令的输出内容包括很多行，在输出变量的时候应该将变量用双引号包围，lsl=$(ls -l), echo "$lsl",此时会分行显示，如果没有双引号系统会用默认的空格来填充，换行符就没有用了，连续的空白符会被压缩成一个。
   - 反引号里面不能嵌套。例如a=$(wc -l $(ls | sed -n '1p'))，反引号不能这么写

- shell特殊变量
   - 在shell中定义函数时不能带参数，调用函数时可以传递参数，传进来的参数在函数内部也使用$n的形式接收。这涉及到给脚本文件传递参数和给函数传递参数，使用的方法都是一样的。一个是在脚本里面一个在shell里面
   - $0 当前脚本的文件名
   - $n 传递给脚本或函数的参数个数
   - $# 传递给脚本或函数的参数个数
   - $? 上个命令的退出状态或函数返回值，一般成功为0，失败为1，在函数调用后使用$?可以得到函数返回值。
   - $$ 当前shell进程id，对于shell脚本就是这些脚本所在的进程id
   - $\* 传递给脚本或函数的所有参数
   - $@ 传递给脚本或函数的所有参数
   - 当$\*和$@没有被双引号包围时，他们之间没有任何区别，即将每个参数看作一份数据，彼此之间以空格区分，但是被双引号包围时，$\*会将所有的参数整体上看作一份数据，而不是把每个参数看作一个数据，$@和原来一样。使用echo看不出来，但是用for循环来逐个输出数据，$\*是一份数据$@是n个数据

- shell字符串
   - 获取字符串长度 ${#string_name}
   
   - shell中字符串拼接，直接放在一起即为拼接
   
      ```
      在 Shell 中你不需要使用任何运算符，将两个字符串并排放在一起就能实现拼接，非常简单粗暴
      #!/bin/bash
      name="Shell"
      url="http://c.biancheng.net/shell/"
      str1=$name$url  #中间不能有空格
      str2="$name $url"  #如果被双引号包围，那么中间可以有空格
      str3=$name": "$url  #中间可以出现别的字符串
      str4="$name: $url"  #这样写也可以
      str5="${name}Script: ${url}index.html"  #这个时候需要给变量名加上大括号
      echo $str1
      echo $str2
      echo $str3
      echo $str4
      echo $str5
      
      Shellhttp://c.biancheng.net/shell/
      Shell http://c.biancheng.net/shell/
      Shell: http://c.biancheng.net/shell/
      Shell: http://c.biancheng.net/shell/
      ShellScript: http://c.biancheng.net/shell/index.html
      ```
   
   - shell字符串截取
      - 从左边开始计数${string:start:length} url="c.biancheng.net" echo ${url:2:9} 省略length参数默认截取到字符串末尾
        - 这个起始值也是从0开始的，跟c语言的是数组一样。
      - 从右边开始计数${string:0-start:length} 0-是固定写法表示从右边计数
        - 0-是固定写法，不能直接写成-
      - 从指定字符开始截取 ${string#\*chars}使用#可以截取指定字符(或子字符串)右边的所有字符，即删除左边的，取右边的字符。*表示忽略左边的所有字符直到指定chars，如果不需要忽略chars左边的字符，可以不写\*，但是chars需要从头写起，上述写法是遇到第一个匹配的字符就结束了，如果希望直到最后一个指定字符，可以使用##,${string##\*chars
```shell
str="---aa+++aa@@@"
echo ${str#*aa}   #结果为 +++aa@@@
echo ${str##*aa}  #结果为 @@@
```
      - 使用%截取指定字符或字符串左边的所有字符，即取左边的删除右边的，从右往左查找。因为要截取chars左边的字符，忽略chars右边的字符，所以*应该位于chars的右侧，其他方面%和#用法相同，%是从右往左查找。${string%chars*}
- shell数组
   - 只支持一维数组，并不要求数组元素的类型必须相同
   - 数组定义()来表示数组，中间用空格隔开nums=(29 100 13 8)
   - 数组长度不固定，定义之后可以增加元素，nums[4]=50，前面只定义到3
   - 获取数组元素${array_name[index]}，获取完一般放到变量里面，或者直接输出.${nums[\*]}和${nums[@]}是取得数组的所有元素
   - 获取数组长度${#array_name[@]}或者\*,如果某个元素是字符串，可以通过指定下标的方式获得该元素的长度${#arr[2]}
   - 数组的拼接，直接获取所有元素然后在两个数组中间放空格，外面在加上()
   - 删除数组元素 unset arr[1],不加[1]就是删除整个数组
   - 关联数组就是使用字符串作为下标而不是整数，类似于key-value，关联数组必须使用带有-A选项的declare命令创建，其余和普通数组一样
   
- shell内建命令
   - 使用type命令来确定是否是内建命令，例如type cd,$PATH中的大多数命令都是外部命令
   - alias，如果不带参数可以查看当前环境下所有的alias，使用unalise删除别名。echo，默认加上换行，echo -n表示不换行。默认情况下echo不会解析\开头的转义字符，比如\n表示换行,添加参数-e来让echo命令解析转义字符例如echo -e "hello\nworld"会分两行输出
   
- shell数学计算
   - 在 Bash Shell 中，如果不特别指明，每一个变量的值都是字符串，无论你给变量赋值时有没有使用引号，值都会以字符串的形式存储
   
   - shell中要进行数学运算必须使用数学计算命令  (())用于整数计算，效率很高。bc可以进行小数计算
   
   - ((b=a-15))，在括号里面可以不用加$前缀使用变量，取用结果时$b就行，如果里面没有变量需要$((1+2))。使用(())可以进行逻辑运算，大于小于，与或非之类的。可以在里面同时对多个表达式进行计算。((a=3+5,b=a+10))，如果没有赋值即((3+5,a+10)),以最后一个计算结果为结果
   
      - 在使用(())用作数学计算时，可以赋值给一个变量，也可以不赋值，如果需要赋值给一个变量时，必须要加$
   
         ```shell
         b=$((1+2))
         echo $b   #输出结果为3，其中赋值语句中的$必须要加，否则会有语法错误。
         
         如果不赋值给一个变量
         ((b=1+2))
         echo $b  #输出结果为3，此时b在计算时已经赋值，可以直接使用。
         ```
   
   - bc，echo "scale=4;3\*8/7;last\*5"|bc，通过管道输入到bc计算，scale设置小数点几位数字。
   
   - test命令或者写成[],test expression,或者[ expression ],用来检测某个条件是否成立，可以进行数值，字符串和文件三个方面的检测。[]这样写时和expression之间有空格
      - 文件类型相关 -b，判断文件是否存在，并且是否为块设备文件； -d，判断文件是否存在，并且是否为目录文件； -f，判断文件是否存在，并且是否为普通文件；-e，只判断文件
      - 文件权限判断 -r -w -x -u -g -k
      - 文件比较 -nt -ot -ef
      - 数值比较 -eq 相等 -ne 不相等 -gt 大于 -lt 小于 -ge大于等于 -le小于等于
      - 字符串判断 -z 是否为空 -n 是否非空 `==  != \> \<` ,这样写防止将>认为成重定向运算符
      - 逻辑判断相关的 -a 与 -o 或 ！非
      - 当你在 test 命令中使用变量时，我强烈建议将变量用双引号""包围起来，这样能避免变量为空值时导致的很多奇葩问题
   
- [[]] 是shell内置关键字，用来检测某个条件是否成立，test能干的，[[]]也能干且干的更好。[[]]支持正则表达式
   - [[ ]] 对数字的比较仍然不友好，所以我建议，以后大家使用 if 判断条件时，用 (()) 来处理整型数字，用 [[ ]] 来处理字符串或者文件。
   - [[]]支持正则表达式，即支持字符串模糊匹配，而[]不支持模糊匹配。模糊匹配时，模糊匹配项不要加""，否则模糊匹配符也会当作字符处理。
   - [[]]和其中的表达式也是需要空格的。
   
- while while cindition do done

- exit  用来退出当前shell进程并返回一个退出状态，使用$?可以接受这个状态
---
[shell正则表达式分为基本的和扩展的](https://man.linuxde.net/docs/shell_regex.html)

- shell中的cd命令是有继承的，cd之后下一条命令可以直接用cd进来的目录，就不用填写绝对路径了。makefile里面的cd不行，必须得写在一行。而且shell中的变量不能和环境变量重名。
- shell调用函数时只需要写函数名就可以不用(),但是定义函数时需要写上()
- shell脚本是用来执行命令行程序的，所以在命令行能弄的脚本里面都能弄，包括可执行程序。脚本里面可以调用外面的程序来运行。

------

#### shell脚本使用

##### 后台启动服务&与nohup

###### &

- 单个的&符号通常可以发现在一个bash命令的行尾：

  ```
  ./myscript.py &
  ```

  - 其作用是令该命令转到后台执行。对于这样的命令，系统会创建一个sub-shell来运行这个命令。同时，在执行该行命令的shell环境中，这个命令会立刻返回0并且继续下面的shell命令的执行。除此之外，在执行这个命令之后，terminal上会输出创建的sub-shell的线程ID（PID）。
  - 脚本名称和&之间可以有空格，也可以没有空格

  ```
  $ ./myscript.py &
  [1] 1337
  ```

  - 注意按照这种方法分支出去的sub-shell的stdout会仍然关联到其parent-shell，也就是说你在当前的terminal中仍然可以发现这个后台进程的stdout输出。所有的到stdout的输出都能打印出来，即使在后台运行。如果不需要打印，需要重定向。

    ```
    $ ./myscript.py > /dev/null &
    ```

- 通过`&`分支出去的sub-shell的PID被存储在一个特殊的变量`$!`中，

  ```
  $ echo $!
  1337
  ```

- 你也可以通过`jobs`命令来检查`sub-shell`的信息

  ```
  $ jobs
  [1]+  Running                 ./myscript.py &
  ```

- 对于sub-shell，你可以通过`fg`命令将其拉回当前的terminal。

- 如果有多个命令需要放到后台运行，可以采用如下方式：

  ```
  ./script.py & ./script2.py & ./script3.py &   #就是这样写的，不用写成三行，这样每一个脚本都会在后台运行。
  ```

  - 在这个例子中，三个脚本会同时开始运行，且拥有各自独立的sub-shell环境。在shell脚本中，这个方法常常被用来利用计算机的多核性能来加速执行。
  - 如果你想创建个完全和当前的shell独立的后台进程（而不是想上面提到的用`&`创建的，和当前shell的stdout关联的方法），可以使用`nohup`命令。

- 有时候在shell命令中可能看到这样的写法：

  ```
  some_command > /dev/null 2>&1
  ```

  - 尽管我将输出重定向到 /dev/null，但它仍打印在终端中。这是因为我们没有将错误输出重定向到 /dev/null，所以为了也重定向错误输出，需要添加 2>&1
  - 这里前面的`> /dev/null`好理解，代表将`stdout`导向到`/dev/null`，而后者代表将`stderr`重定向到`stdout`，或者说`stderr`的输出等同于`stdout`。由于`stdout`已经被重定向到`/dev/null`，那么这意味着`stderr`也被重定向到了这个位置。1是系统默认代表`stdout`的值，2代表`stderr`。
  - 1 ：表示stdout标准输出，系统默认值是1，所以">/dev/null"等同于"1>/dev/null"
  - & ：表示等同于的意思，2>&1，表示2的输出重定向等同于1
  - 1 > /dev/null 2>&1 语句含义：
    - 1 > /dev/null ： 首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息
    - 2>&1 ：接着，标准错误输出重定向（等同于）标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。
  - 实例解析
    - cmd >a  2>a和cmd >a 2>&1为什么不同？
    - 这个命令的理解是标准输出到a文件了，然后2>&1说明标准错误输出到标准输出，也就是a文件
    - cmd >a 2>a ：stdout和stderr都直接送往文件 a ，a文件会被打开两遍，由此导致stdout和stderr互相覆盖。
    - cmd >a 2>&1 ：stdout直接送往文件a ，stderr是继承了FD1的管道之后，再被送往文件a 。a文件只被打开一遍，就是FD1将其打开。
    - cmd >a 2>a 相当于使用了FD1、FD2两个互相竞争使用文件 a 的管道；
    - cmd >a 2>&1 只使用了一个管道FD1，但已经包括了stdout和stderr。
    - 从IO效率上来讲，cmd >a 2>&1的效率更高。
  - `command &>filename会重定向命令`command`标准输出`（stdout）`和标准错误`（stderr`）到文件`filename`中.直接重定向两个

###### nohup

- **nohup** 英文全称 no hang up（不挂起），用于在系统后台不挂断地运行命令，退出终端不会影响程序的运行。

- 上面的&命令在终端退出后进程就会消失，nohup命令终端退出后进程不会退出。

- **nohup** 命令，在默认情况下（非重定向时），会输出一个名叫 nohup.out 的文件到当前目录下，如果当前目录的 nohup.out 文件不可写，输出重定向到 **$HOME/nohup.out** 文件中。

  ```
  nohup Command [ Arg … ] [　& ]
  ```

  - command： 要执行的命令
  - Arg 一些参数，可以指定输出文件
  - & 让命令在后台执行，终端退出后命令仍旧执行
  - 在终端如果看到以下输出说明运行成功：appending output to nohup.out

##### shell交互输入自动化

- **Shell 交互输入自动化**，我们知道命令可以接受命令行参数。Linux也支持很多交互式应用程序，如`passwd`和`ssh`。
  - ssh登录之后需要输入账户和密码等信息，交互自动化可以让脚本自动完成。此时需要一些手段

###### 预备知识

- 观察交互式输入的顺序。参照上面的代码，我们可以将涉及的步骤描述如下：

  ```
  notes[Return]docx[Return]
  ```

- 输入`notes`，按回车键，然后输入`docx`，再按回车键。这一系列操作可以被转换成下列字符串：

  ```
  "notes\ndocx\n"
  ```

- 按下回车键时会发送`\n`。添加`\n`后，就生成了发送给`stdin`的字符串。

- 通过发送与用户输入等效的字符串，我们就可以实现在交互过程中自动发送输入。

###### 工作原理

- 先写一个读取交互式输入的脚本，然后用这个脚本做自动化演示：

  ```
  #!/bin/bash
  # backup.sh
  # 使用后缀备份文件。不备份以~开头的临时文件
  read -p " What folder should be backed up: " folder
  read -p " What type of files should be backed up: " suffix
  find $folder -name "*.$suffix" -a ! -name '~*' -exec cp {} \
      $BACKUP/$LOGNAME/$folder
  echo "Backed up files from $folder to $BACKUP/$LOGNAME/$folder"
  ```

- 按照下面的方法向脚本发送自动输入：

  ```
  $ echo -e "notes\ndocx\n" | ./backup.sh
  Backed up files from notes to /BackupDrive/MyName/notes
  ```

- 像这样的交互式脚本自动化能够在开发和调试过程中节省大量输入。另外还可以确保每次测试都相同，不会出现由于输入错误导致的bug假象。

- 我们用`echo -e`来生成输入序列。`-e`选项表明`echo`会解释转义序列。如果输入内容比较多，可以用单独的输入文件结合重定向操作符来提供输入：

  ```
  $ echo -e "notes\ndocx\n" > input.data
  $ cat input.data
  notes
  docx
  ```

- 你也可以选择手动构造输入文件，不使用`echo`命令：

  ```
  $ ./interactive.sh < input.data
  ```

  - 这种方法是从文件中导入交互式输入数据。

- 如果你是一名逆向工程师，那可能免不了要同缓冲区溢出攻击打交道。要实施攻击，我们需要将十六进制形式的`shellcode`（例如`\xeb\x1a\x5e\x31\xc0\x88\x46`）进行重定向。这些字符没法直接输入，因为键盘上并没有其对应的按键。因此，我们需要使用：

  ```
  echo -e "\xeb\x1a\x5e\x31\xc0\x88\x46"
  ```

  - 这条命令会将这串字节序列重定向到有缺陷的可执行文件中。

- `echo`命令和重定向可以实现交互式输入的自动化。但这种技术存在问题，因为输入内容没有经过验证，我们认定目标应用总是以相同的顺序接收数据。但如果程序要求的输入顺序不同，或是对某些输入内容不做要求，那就要出岔子了。

- `expect`程序能够执行复杂的交互操作并适应目标应用的变化。该程序在世界范围内被广泛用于控制硬件测试、验证软件构建、查询路由器统计信息等。

- `expect`有3个主要命令，如下表所示：

  |   命令   |          描述          |
  | :------: | :--------------------: |
  | `spawn`  |    运行新的目标应用    |
  | `expect` | 关注目标应用发送的模式 |
  |  `send`  |  向目标应用发送字符串  |

- 下面的例子会先执行备份脚本，然后查找模式`*folder*`或`*file*`，以此确定备份脚本是否要求输入目录名或文件名并作出相应的回应。如果重写备份脚本，要求先输入备份文件类型，后输入备份目录，这个自动化脚本依然能够应对。

  ```
  #!/usr/bin/expect
  #文件名: automate_expect.tcl
  spawn ./backup .sh
  expect {
    "*folder*" {
       send "notes\n"
       exp_continue
     }
    "*type*" {
       send "docx\n"
       exp_continue
    }
  }
  ```

  - `spawn`命令的参数是需要自动化运行的应用程序及其参数。
  - `expect`命令接受一组模式以及匹配模式时要执行的操作。操作需要放入花括号中。
  - `send`命令是要发送的信息。和`echo -n -e`类似，`send`不会自动添加换行符，也能够理解转义字符。echo -n表示不换行。
  - expect表示匹配的模式，就是在让你输入密码的时候会在终端里面打印一些信息，此时匹配的就是这些信息，当匹配到这个信息时输入密码，匹配到其他的时候输入其他的，这样就没有顺序了，输入的交换顺序也能使用，这个是基于匹配的。expect表示需要等待的消息。

##### shell中EOF的使用

- EOF是End Of File的缩写，表示自定义终止符。既然自定义，那么EOF就不是固定的，可以随意设置别名，意思是把内容当作标准输入传给程序，Linux中按Ctrl-d就代表EOF。

- 在Shell中我们通常将EOF与 << 结合使用，表示后续的输入作为子命令或子Shell的输入，直到遇到EOF为止，再返回到主调Shell。回顾一下<<的用法，当shell看到<<的时候，它就会知道下一个词是一个分界符。在该分界符以后的内容都被当作输入，直到shell又看到该分界符(位于单独的一行)。这个分界符可以是你所定义的任何字符串。

- 第一个EOF必须以重定向字符<<开始，第二个EOF必须顶格写，否则会报错。

- 通过cat配合重定向能够生成文件并追加操作，在它之前先回顾几个特殊符号：

  ```
  <   :输入重定向
  >   :输出重定向
  >>  :输出重定向,进行追加,不会覆盖之前内容
  <<  :标准输入来自命令行的一对分隔号的中间内容
  ```

  ```
  [root@localhost ~]# cat <<EOF   //运行后会出现输入提示符">"
  > Hello
  > wolrd
  > EOF
  输入结束后，在终端显示以下内容：
  Hello
  wolrd
  ```

- 向文件file1.txt中输入内容

  ```
  [root@localhost ~]# cat >file1.txt <<EOF
  > aaa
  > bbb
  > ccc
  > EOF
  
  [root@localhost ~]# cat file1.txt 
  aaa
  bbb
  ccc
  ```

- 追加内容至file1.txt中

  ```
  [root@localhost ~]# cat >>file1.txt <<EOF
  > 111
  > 222
  > 333
  > EOF
  
  [root@localhost ~]# cat file1.txt 
  aaa
  bbb
  ccc
  111
  222
  333
  ```

- 覆盖file1.txt

  ```
  [root@localhost ~]# cat >file1.txt <<EOF
  > Hello wolrd
  > EOF
  
  [root@localhost ~]# cat file1.txt 
  Hello wolrd
  ```

- 自定义EOF

  ```
  [root@localhost ~]# cat >file1.txt <<FFF
  > test
  > hello
  > FFF
  
  [root@localhost ~]# cat file1.txt 
  test
  hello
  ```

- 编写一个脚本，生成mysql配置文件

  ```
  [root@localhost ~]# vim /root/test.sh
  #!/bin/bash
  cat >/root/EOF/my.cnf <<EOF
  [client]
  port=3306
  socket=/usr/local/mysql/var/mysql.sock
  basedir=/usr/local/msyql/
  datadir=/data/mysql/data
  pid-file=/data/mysql/data/mysql.pid
  user=mysql
  server-id=1
  log_bin=mysql-bin
  EOF
  
  [root@localhost ~]# cat /root/EOF/my.cnf    //查看生成的mysql配置文件
  [client]
  port=3306
  socket=/usr/local/mysql/var/mysql.sock
  basedir=/usr/local/msyql/
  datadir=/data/mysql/data
  pid-file=/data/mysql/data/mysql.pid
  user=mysql
  server-id=1
  log_bin=mysql-bin
  ```

  - 这样我们可以通过脚本来向文件中写入数据，来进行一些配置文件的输入。

- git上人家配置nginx例子

  ```
  #!/bin/bash
  
  MY_SOFTS_DIR="/usr/local/mysofts"
  NGINX_VERSION=nginx-1.16.0
  OPENSSL_VERSION=openssl-1.1.1b
  
  yum install -y gcc gcc-c++
  yum install -y zlib*
  yum install -y pcre pcre-devel
  
  rm -rf $NGINX_VERSION $NGINX_VERSION.*
  rm -rf $OPENSSL_VERSION $OPENSSL_VERSION.*
  rm -rf /usr/bin/pod2man
  mkdir -p $MY_SOFTS_DIR
  
  cd /tmp
  wget http://nginx.org/download/$NGINX_VERSION.tar.gz
  tar -zxvf $NGINX_VERSION.tar.gz 
  
  wget https://www.openssl.org/source/$OPENSSL_VERSION.tar.gz
  tar -zxvf $OPENSSL_VERSION.tar.gz
  
  cd $NGINX_VERSION
  ./configure --prefix=$MY_SOFTS_DIR/nginx --with-http_v2_module --with-http_stub_status_module --with-http_ssl_module --with-stream --with-openssl=../$OPENSSL_VERSION
  make && make install
  
  rm -rf /etc/init.d/nginx
  cat >> /etc/init.d/nginx <<EOF
  #!/bin/bash
  # Startup script for the nginx Web Server
  # chkconfig: - 85 15
  # description: nginx is a World Wide Web server. It is used to serve
  NGINX=${MY_SOFTS_DIR}/nginx/sbin/nginx
  start()
  {
      \$NGINX
      echo "nginx启动成功!"
  }
  stop()
  {
      PID=\$(ps -ef | grep "nginx" | grep -v grep | awk '{print \$2}')
      kill -9 \${PID}
      echo "nginx已关闭!"
  }
  restart()
  {
      PID=\$(ps -ef | grep "nginx" | grep -v grep | awk '{print \$2}')
      kill -9 \${PID}	
      $NGINX
      echo "nginx重启成功!"
  }
  case \$1 in
  "start") start
  	;;
  "stop") stop
  	;;
  "restart") restart
  	;;
  *) echo "请输入正确的操作参数start|stop|restart"
  	;;
  esac
  EOF
  chkconfig --add /etc/init.d/nginx
  chmod 755 /etc/init.d/nginx
  chkconfig --add nginx
  chkconfig --level 345 nginx on
  service nginx start
  
  echo "==========安装完毕！============"
  ```

  - 上面将/etc/init.d/nginx删除，然后使用cat和EOF重新向/etc/init.d/nginx中写入东西，相当于重新配置

- 除了向一个文件写入东西，我们也可以在当前shell中向一个命令写入东西，表示这个命令要执行的东西，例如expect，在终端中输入expect就会进入交互界面，此时我们输入的东西会被expect执行，所以我们可以使用<<和EOF在shell脚本中给expect输入东西，然后expect就会执行这个命令。

  ```
  #!/bin/bash
  echo "123"
  /usr/bin/expect <<EOF　　#利用here document的expect代码嵌套
  
  spawn ssh root@172.16.11.99
  expect "*password:"
  send "rootzhang\r"
  expect "*#"
  send "touch zhangjiacai\r"
  expect "*#"
  send "exit\r"
  expect eof　　#捕获结束
  
  EOF  
  ```

##### while read line

- while read line如果不是从文件中重定向的话，会一直等待输入，直到按ctrl-D，在脚本里面有while read line，执行这个脚本的时候，会一直在终端里面等待输入。

- 在shell脚本中，我们经常看到以下的一种结构：

  ```
  while read line
  
  do
  
         …
  
  done < file
  ```

  - read通过输入重定向，把file的第一行所有的内容赋值给变量line，循环体内的命令一般包含对变量line的处理；然后循环处理file的第二行、第三行。。。一直到file的最后一行。

  - 这种结构还有另外的写法

    ```
    cat file | while read line
    do
    	...
    done
    ```

    - 用cat读取文件，然后通过管道输入到while循环中，这样也是一行一行的处理。

  - 上面这两种结构都是基于另一个文件作为输入的。

  - 如果是基于当前文件中变量的话，读取当前文件变量的内容，并不是读取另一个文件内容话，结果如下

    ```
    #!/bin/bash
    date=`date +%Y%m%d`
    datatime=${yesterday}
    yesterday=`date +%Y%m%d -d "1 days ago"`
    
    echo '$date'
    echo '====='$datatime
    echo '-----'$yesterday
     
     
    IPS="10.1.1.10 3001
    10.1.1.10 3003
    10.1.1.11 3001
    10.1.1.13 3002
    10.1.1.13 3004
    10.1.1.14 3002"
     
    echo "======while test========"
    i=0
     
    echo $IPS | while read line
    do
       echo $(($i+1))
       echo $line
    done
     
    echo "=======for test========"
    n=0
    for ip in $IPS
    do
       n=$(($n+1))
       echo $ip
       echo $n
    done
    
    ======while test========
    1
    10.1.1.10 3001 10.1.1.10 3003 10.1.1.11 3001 10.1.1.13 3002 10.1.1.13 3004 10.1.1.14 3002
    =======for test========
    10.1.1.10
    1
    3001
    2
    10.1.1.10
    3
    3003
    4
    10.1.1.11
    5
    3001
    6
    10.1.1.13
    7
    3002
    8
    10.1.1.13
    9
    3004
    10
    10.1.1.14
    11
    3002
    12
    ```

- for是每次读取文件中一个以空格为分割符的字符串

  - 通过上面的例子可以看出，如果是当前脚本文件中的变化的话，while read line会一次性全部读取，如果是其他文件读入的话会一行一行的读入，进入到循环中。
  - read函数本来就是读取一行，换行符之前的内容都会当作read的内容，IPS用引号引起来的，所以是一行。

- for循环总是按空格来分割读取的，不管是当前文件中的变量，还是其他文件中的内容。如果读取其他文件中的内容的时候，for循环如下写法

  ```
  #!/bin/bash
  
  for i in `cat /home/admin/timeout_login.txt`
  do
  
      /usr/bin/expect << EOF
      spawn /usr/bin/ssh -t -p 22022 admin@$i "sudo su -"
  
      expect {
          "yes/no" { send "yes\r" }
      }   
  
      expect {
          "password:" { send "xxo1#qaz\r" }
      }
      
      expect {
          "*password*:" { send "xx1#qaz\r" }
      }
  
      expect "*]#"
      send "df -Th\r"
      expect "*]#"
      send "exit\r"
      expect eof
  
  EOF
  done
  ```

  - in后面不能直接写文件的名字，需要用cat来读取文件的内容来输入到循环中，cat这内容需要用引号包起来或者使用$()，表示使用这个命令的结果作为内容。

- 实例

  - 计算文档a.txt中每一行中出现的数字个数并且要计算一下整个文档中一共出现了几个数字。例如a.txt内容如下：

    ```
    12aa*lkjskdj
    alskdflkskdjflkjj
    ```

  - 脚本如下

    ```
    #!/bin/bash
    sum=0
    while read line
    do
    line_n=`echo $line|sed 's/[^0-9]//g'|wc -L`
    echo $line_n
    sum=$[$sum+$line_n]
    done < $1
    echo "sum:$sum"
    
    输出结果应该为：
    2
    0
    sum:2
    ```


#### 变量和参数

- 让我们仔细地区别变量和变量的值。如果`variable1`是一个变量的名字，那么`$variable1`就是引用这个变量的值――即这个变量它包含的数据。如果只有变量名出现（即指没有前缀$），那就可能是在1）声明一个变量或是在给这个变量赋值。2）声明废弃这个变量，3）导出（[exported](http://shouce.jb51.net/shell/internal.html#EXPORTREF)）变量，4）或是在变量指示的是一种[信号](http://shouce.jb51.net/shell/debugging.html#SIGNALD)的特殊情况。变量赋值可以使用等于号（＝），比如：var1=27。也可在[read](http://shouce.jb51.net/shell/internal.html#READREF)命令和在一个循环的情况下赋值，比如：for var2 in 1 2 3。

  ```
  hello="A B  C   D"
  echo $hello   # A B C D
  echo "$hello" # A B  C   D
  # 正如你所看到的：echo $hello和echo "$hello"产生不同的输出。
                                  　^      ^
  # 把变量引起来会保留空白字符.
  ```

###### 变量赋值

- =赋值操作符（它的左右两边不能有空白符）
  - 不要搞混了=和-eq，-eq是比赋值操作更高级的测试。
  - 注意：等于号（=）根据环境的不同它可能是赋值操作符也可能是一个测试操作符。

###### bash变量是无类型的

- 不同与许多其他的编程语言，Bash不以"类型"来区分变量。本质上来说，Bash变量是字符串，但是根据环境的不同，Bash允许变量有整数计算和比较。其中的决定因素是变量的值是不是只含有数字.

  ```
  如果没有声明变量会怎么样?
  echo "f = $f"            # f =
  let "f += 1"             # 算术计算能通过吗?
  echo "f = $f"            # f = 1
  echo                     # 没有预先声明的变量变为整数
  ```

  ```
  # What about null variables?
  e=""
  echo "e = $e"            # e =
  let "e += 1"             # 数值计算允许有null值操作?
  echo "e = $e"            # e = 1
  echo                     # 空值(null)变量变成了整数
  ```

  ```
  a=2334                   # 整数.
  let "a += 1"
  echo "a = $a "           # a = 2335
  echo                     # 仍然是整数.
  
  
  b=${a/23/BB}             # 把变量a中的"23"替换为"BB"并赋给变量b，这是字符串的替换
                           # 这使变量$b成为字符串
  echo "b = $b"            # b = BB35
  declare -i b             # 即使明确地声明它是整数也没有用
  echo "b = $b"            # b = BB35
  
  let "b += 1"             # BB35 + 1 =
  echo "b = $b"            # b = 1
  echo
  
  c=BB34
  echo "c = $c"            # c = BB34
  d=${c/BB/23}             # 把"BB"替换成"23"
                         # 这使变量$d成为一个整数
  echo "d = $d"            # d = 2334
  let "d += 1"             # 2334 + 1 =
  echo "d = $d"            # d = 2335
  ```

- **shift**命令使位置参数都左移一位。`$1` <--- `$2`, `$2` <--- `$3`, `$3` <--- `$4`, 以此类推.

  - 原来旧的$1值会消失，但是*`$0` (脚本名称)不会改变*. 如果你把大量的位置参数传给脚本，那么可以使用**shift**命令存取超过10的位置参数, 虽然这个功能也能由[{bracket}花括号](http://shouce.jb51.net/shell/othertypesv.html#BRACKETNOTATION) 做到.

  ```
     1 #!/bin/bash
     2 # 用 'shift'命令逐步存取所有的位置参数
     3 
     4 #  给这个脚本一个命名，比如说shft，
     5 #+ 然后以一些参数来调用这个脚本,例如
     6 #          ./shft a b c def 23 skidoo
     7 
     8 until [ -z "$1" ]  # 直到所有的位置参数被存取完...
     9 do
    10   echo -n "$1 "
    11   shift
    12 done
    13 
    14 echo               # 换行.
    15 
    16 exit 0
  ```


#### 引用

- 引用意味着保护在引号中的字符串. 引用在保护被引起字符串中的[特殊字符](http://shouce.jb51.net/shell/special-chars.html#SCHARLIST1)被shell或shell脚本解释或扩展. (如果一个字符能被特殊解释为不同于它字面上表示的意思，那么这个字符是“特殊”的,比如说通配符 -- *.)

- 某些程序和软件包可以重新解释或扩展引号里的特殊字符。引号一个很重要的作用是保护命令行上的一个参数不被shell解释，而把此参数传递给要执行的程序来处理它。

  ```
   bash$ grep '[Ff]irst' *.txt
   file1.txt:This is the first line of file1.txt.
   file2.txt:This is the First line of file2.txt.
  ```

  - 此时引号引起来的不被命令行解释而是将参数传到grep命令中，由grep命令来解释。
  - 上面那句话保护命令行上的一个参数不被shell解释说的就是如果不带引号[Ff]irst将会被shell解释，就不会传进去grep命令中，如果引号引起来就会原封不动的传进去grep命令中，因为grep命令也是能解释正则表达式的。

- 引号也能改掉[echo's](http://shouce.jb51.net/shell/internal.html#ECHOREF)不换行的“习惯”。

  ```
  bash$ echo $(ls -l)
   total 8 -rw-rw-r-- 1 bozo bozo 130 Aug 21 12:57 t222.sh -rw-rw-r-- 1 bozo bozo 78 Aug 21 12:57 t71.sh
   
   
   bash$ echo "$(ls -l)"
   total 8
   -rw-rw-r--  1 bozo bozo 130 Aug 21 12:57 t222.sh
   -rw-rw-r--  1 bozo bozo  78 Aug 21 12:57 t71.sh
  ```

  - 不加引号是不会默认换行的，加上引号是默认换行的。

- 当要引用一个变量的值时，一般推荐使用双引号。使用双引号除了变量名[[2\]](http://shouce.jb51.net/shell/quoting.html#FTN.AEN1994)前缀($)、后引符(`)和转义符(\)外，会使shell不再解释引号中其它所有的特殊字符。[[3\]](http://shouce.jb51.net/shell/quoting.html#FTN.AEN2000) 用双引号时$仍被当成特殊字符，允许 引用一个被双引号引起的变量("$variable"), 那也是说$variable会被它的值所代替。

- 用双引号还能使句子不被分割开. [[4\]](http://shouce.jb51.net/shell/quoting.html#FTN.AEN2024) 一个参数用双引号引起来能使它被看做一个单元，这样即使参数里面包含有[空白字符](http://shouce.jb51.net/shell/special-chars.html#WHITESPACEREF)也不会被shell分割开了。

  ```
  COMMAND $variable2 $variable2 $variable2        # 没有带参数执行COMMAND 命令
  COMMAND "$variable2" "$variable2" "$variable2"  # 用三个含空字符串的参数执行COMMAND命令
  COMMAND "$variable2 $variable2 $variable2"      # 用一个包含两个空白符的参数执行COMMAND命令
  ```

  - 上面这是一个示例

- 在命令行上，把感叹号"!"放在双引号里执行命令会出错（译者注：比如说：echo "hello!"）. 因为感叹号被解释成了一个[历史命令](http://shouce.jb51.net/shell/histcommands.html). 然而在一个脚本文件里，这么写则是正确的，因为在脚本文件里Bash的历史机制被禁用了。在双号号里字符`"\"`也会引起许多不一致的行为。

  ```
   bash$ echo hello\!
   hello!
  
   bash$ echo "hello\!"
   hello\!
  
   bash$ echo -e x\ty
   xty
  
   bash$ echo -e "x\ty"
   x       y
  ```

  - echo -e参数是开启转义的意思。意思是里面的转义字符要转义出来。

###### 转义

- 转义是引用单字符的方法.在单个字符前面的转义符\告诉shell不必特殊解释这个字符，只把它当成字面上的意思。但是一些字符前面加上反斜杠是有特殊的含义的。

- 一些转义字符的表示的特殊意思

  ```
  和echo，sed连用时：
  \n
  表示新行
  
  \r
  表示回车
  
  \t
  表示水平的制表符
  
  \v
  表示垂直的制表符
  
  \b
  表示后退符
  
  \a
  表示“警告”（蜂鸣或是闪动）
  
  \0xx
  翻译成ASCII码为八进制0xx所表示的字符
  ```

  ```
  echo "\v\v\v\v"      # 打印出 \v\v\v\v literally.
  # 用带着选项-e的'echo'会打印出转义字符串.
  echo "============="
  echo "VERTICAL TABS"
  echo -e "\v\v\v\v"   # 打印四个垂直的制表符.
  echo "=============="
  
  echo "QUOTATION MARK"
  echo -e "\042"       # 打印出字符" (引号, 它的八进制ASCII码为42).
  echo "=============="
  
  # 当使用像$'\X'的结构时，-e选项是多余的.
  echo; echo "NEWLINE AND BEEP"
  echo $'\n'           # 新行.
  echo $'\a'           # 警告 (蜂鸣).
  
  用ASCII码值把字符赋给变量.
  # ----------------------------------------
  quote=$'\042'        # 引号"被赋给变量quote了.
  echo "$quote This is a quoted string, $quote and this lies outside the quotes."
  
  echo
  
  # 用连串的ASCII码把一串字符赋给变量..
  triple_underline=$'\137\137\137'  # 137是字符'_'的ASCII码.
  echo "$triple_underline UNDERLINE $triple_underline"
  
  echo
  
  ABC=$'\101\102\103\010'           # 101, 102, 103分别是A, B, C字符的八进制ASCII码.
  echo $ABC
  ```

  - -e才会转义
  - 上面这种`$'\X’`结构是bash需要使用的，这样就可以不用使用-e选项。但是zsh解释器目前直接支持了不用输入-e也能直接转义了。所以不用这种结构，这种结构记住是bash用的就行了，其他的解释器应该不用这么麻烦。

- 其余的就是正常的转义的含义，表示其字符本身，例如`\"，\$，\\`

#### 测试

- 一个**if/then**结构测试一列命令的[退出状态](http://shouce.jb51.net/shell/exit-status.html#EXITSTATUSREF)是否为0（因为依照惯例，0意味着命令执行成功），如果是0则会执行一个或多个命令。

  ```
  if  condition1
  then
     statement1
  elif condition2
  then
      statement2
  elif condition3
  then
      statement3
  ……
  else
     statementn
  fi
  ```

- 有一个命令 **[** ([左方括](http://shouce.jb51.net/shell/special-chars.html#LEFTBRACKET)是特殊字符). 它和**test**是同义词,因为效率的原因，它被[内建](http://shouce.jb51.net/shell/internal.html#BUILTINREF)在shell里。这个命令的参数是比较表达式或者文件测试，它会返回一个退出状态指示比较的结果(0表示真，1表示假)。

  - 每个表达式执行完退出的时候，都会返回一个退出状态码(exit status 0～255)，if语句根据 [ ] 表达式执行的退出状态码进行判断，在所有的退出状态码中，0表示执行成功，1~255为退出的状态代号（详见下表）。所以，与C语言不同的就在这里，shell的if [ 1 ] 中整数 0 1 与C语言中的 while(1)用法并不相通，也就是说整数 0 1 作为退出状态码的时候，确实表示真假，但是并不能作为 if [ ] 的判断条件来用，虽然shell也是弱数据类型的语言。
  - 也就是说if []里面不能直接写0和1这种判断，因为直接写数字0判断结果也是真，写数字1判断结果也是真，和c语言中的不一样，判断表达式的返回结果时确实是0代表真，1代表假。

- 在版本2.02，Bash引入了[[[ ... \]]](http://shouce.jb51.net/shell/tests.html#DBLBRACKETS) 扩展的测试命令，它使熟悉其他语言中这种比较测试的程序员也能很快熟悉比较操作。注意[[是一个[关键字](http://shouce.jb51.net/shell/internal.html#KEYWORDREF) ，不是一个命令。

  Bash把[[ $a -lt $b ]]看成一个返回退出状态的单元。

- 如果 (( ... )) 和 let ... 构造计算的算术表达式扩展为非零值，则它们也返回退出状态 0。因此，这些算术扩展结构可用于执行算术比较。

  - 上面的意思是说如果表达式为假的话，let和(())返回1，为真返回0，因为在shell中0代表真。上面两种表达式的真假和我们平常认识的真假意思一样。

  - []和[[]]的表示结果是一样的，只是双括号是单括号的升级版。

  - (())和let也可以用if判断真假，这个真假和我们平常认识的真假一样，非0表示真，0表示假，但是这种判断会有一种返回状态，非0的返回状态时0，就和shell的真假对应起来了。

    ```
    if ((1))
    then
        echo "hello"
    fi
    
    1的测试结果为真，所以返回值为0，所以此结构输出hello
    ```

- **if** 命令不仅能测试由方括号括起来的条件，也能测试任何命令。例如左方括号的参数是比较表达式或者文件测试，左方括号其实也是一个命令，就跟下面的cmp和grep这些类似，只是有一些参数上的差异和形式上的差异，都是命令。

  ```
     1 if cmp a b &> /dev/null  # 禁止输出.
     2 then echo "Files a and b are identical."
     3 else echo "Files a and b differ."
     4 fi
     5 
     6 # 非常有用的"if-grep"组合:
     7 # ----------------------------------- 
     8 if grep -q Bash file
     9 then echo "File contains at least one occurrence of Bash."
    10 fi
    11 
    12 word=Linux
    13 letter_sequence=inu
    14 if echo "$word" | grep -q "$letter_sequence"
    15 # 选项"-q"使grep禁止输出.
    16 then
    17   echo "$letter_sequence found in $word"
    18 else
    19   echo "$letter_sequence not found in $word"
    20 fi
    21 
    22 
    23 if COMMAND_WHOSE_EXIT_STATUS_IS_0_UNLESS_ERROR_OCCURRED
    24 then echo "Command succeeded."
    25 else echo "Command failed."
    26 fi
    
    cmp命令是比较两个文件，如果相同则返回状态0
    grep -q用在if中很有用  Quiet; do not write anything to standard output.  Exit immediately with zero status if any match is found, even if an error was detected.  Also see the -s or --no-messages option.中文意思为，安静模式，不打印任何标准输出。 如果有匹配的内容则立即返回状态值0。
    
  type可以判断一个命令是否存在，如果不存在就显示没有存在命令，存在的话就会打印一些信息，此时我们重定向，让信息不打印
  if type wget >/dev/null
  then
  	echo "in"
  fi
  这样可以判断一个命令在不在，如果在的话，打印in，不在的话就不打印。
  ```

- shell中各种真假的总结，如果不知道可以用if/then来判断一下

  ```
  if [ 0 ]      # 0，0代表真
  if [ 1 ]      # 1，1也代表真，这是在直接写数字的情况下。
  if [ -1 ]     # -1，-1为真
  if [ ]        # NULL (空条件)， NULL为假.
  if [ xyz ]    # 字符串， 任意字符串为true.
  if [ $xyz ]   # 变量$xyz为null值, 但它只是一个未初始化的变量.未初始化的变量为false.
  if [ -n "$xyz" ]   # 进一步实验核实， 未始初化的变量为false.
  xyz=          # 已初始化, 但设置成null值.
  	if [ -n "$xyz" ]，此时为真
  
  -n表示字符串不为空，字符串不为空时返回值为0表示真。
  ```

- elif是else if的缩写。作用是在一个if/then里嵌入一个内部的if/then结构。

  ```
     1 if [ condition1 ]
     2 then
     3    command1
     4    command2
     5    command3
     6 elif [ condition2 ]
     7 # 和else if相同
     8 then
     9    command4
    10    command5
    11 else
    12    default-command
    13 fi
  ```

- [[]]结构比Bash版本的[]更通用。它是从*ksh88*中引进的test命令的扩展。

- 在[[和]]之间的所有的字符都不会被文件扩展或是标记分割，但是会有参数引用和命令替换。

- 用**[[ ... ]]**测试结构比用**[ ... ]**更能防止脚本里的许多逻辑错误。比如说，&&,||,<和>操作符能在一个[[]]测试里通过，但在[]结构会发生错误。两种解析是不一样的，注意一下。

- 在一个if的后面，不必一定是test命令或是test结构（[]或是[[]]）。

  ```
     1 dir=/home/bozo
     2 
     3 if cd "$dir" 2>/dev/null; then   # "2>/dev/null"会隐藏错误的信息.
     4   echo "Now in $dir."
     5 else
     6   echo "Can't change to $dir."
     7 fi
  ```

  - "if COMMAND"结构会返回COMMAND命令的退出状态码。

- 同样的，在一个测试方括号里面的条件测试也可以用[列表结构(list construct)](http://shouce.jb51.net/shell/list-cons.html#LISTCONSREF)而不必用if。

  ```
     1 var1=20
     2 var2=22
     3 [ "$var1" -ne "$var2" ] && echo "$var1 is not equal to $var2"
     4 
     5 home=/home/bozo
     6 [ -d "$home" ] || echo "$home directory does not exist."
  ```

- [(( ))结构](http://shouce.jb51.net/shell/dblparens.html)扩展并计算一个算术表达式的值。如果表达式值为0，会返回1或假作为退出状态码。一个非零值的表达式返回一个0或真作为[退出状态码](http://shouce.jb51.net/shell/exit-status.html#EXITSTATUSREF)。这个结构和先前**test**命令及[]结构的讨论刚好相反。这个结构就是用来算数运算的，不能进行其他的操作，所以可以直接写0和1这种在括号里面。

  ```
  (( 0 ))  # 1
  (( 1 ))  # 0
  (( 5 > 4 ))   # 真 0
  (( 5 > 9 )) # 假 1
  (( 5 / 4 ))  # 除法有效.0
  (( 1 / 2 )) # 除法计算结果< 1， 截取为0返回1为假
  (( 1 / 0 )) 2>/dev/null # 除以0的非法计算.  # 1
  ```

###### 文件测试操作符

- -e   文件存在
- -s   文件大小不为零
- -d   文件是一个目录
- -f    文件是一个普通文件(不是一个目录或是一个设备文件)
- -p    文件是一个[管道](http://shouce.jb51.net/shell/special-chars.html#PIPEREF)
- -L    文件是一个符号链接
- -S    文件是一个[socket](http://shouce.jb51.net/shell/devproc.html#SOCKETREF)
- -r，-x，-w 文件是否可读可写可执行

###### 整数比较

- -eq 等于if [ "$a" -eq "$b" ]
- -ne 不等于if [ "$a" -ne "$b" ]
- -gt大于if [ "$a" -gt "$b" ]
- -ge大于等于if [ "$a" -ge "$b" ]
- -lt小于if [ "$a" -lt "$b" ]
- -le小于等于if [ "$a" -le "$b" ]

- <小于(在[双括号](http://shouce.jb51.net/shell/dblparens.html)里使用)(("$a" < "$b"))
- <=小于等于 (在双括号里使用)(("$a" <= "$b"))
- \>大于 (在双括号里使用)(("$a" > "$b"))
- \>=大于等于(在双括号里使用)(("$a" >= "$b"))

###### 字符串比较

- =等于if [ "$a" = "$b" ]

- ==等于if [ "$a" == "$b" ]。它和=是同义词。

  - ==比较操作符在一个[双方括号](http://shouce.jb51.net/shell/tests.html#DBLBRACKETS)测试和一个单方括号号里意思不同。

    ```
       1 [[ $a == z* ]]    # 如果变量$a以字符"z"开始(模式匹配)则为真.
       2 [[ $a == "z*" ]]  # 如果变量$a与z*(字面上的匹配)相等则为真.
       3 
       4 [ $a == z* ]      # 文件扩展和单元分割有效.
       5 [ "$a" == "z*" ]  # 如果变量$a与z*(字面上的匹配)相等则为真.和[[ $a == z* ]]结果一样
    ```

- !=不相等if [ "$a" != "$b" ]，操作符在[[[ ... \]]](http://shouce.jb51.net/shell/tests.html#DBLBRACKETS)结构里使用模式匹配.

- <小于，依照ASCII字符排列顺序，>大于类似

  ```
  if [[ "$a" < "$b" ]]
  if [ "$a" \< "$b" ]
  ```

  - 注意"<"字符在`[ ]` 结构里需要转义

- -z字符串为"null"，即是指字符串长度为零。

- -n字符串不为"null"，即长度不为零.

  - 在测试方括号里进行-n测试时一定要把字符串用引号起来。用没有引号引起的! -z或者在方括号里只有未引号引起的字符串 (参考[例子 7-6](http://shouce.jb51.net/shell/comparison-ops.html#STRTEST))来进行测试一般都能工作，然而，这其实是不安全的测试。应该总是用引号把测试字符串引起来。

- 算式和字符串比较

  ```
     1 #!/bin/bash
     2 
     3 a=4
     4 b=5
     5 
     6 #  这儿的"a"和"b"既能被看成是整数也能被看着是字符串。
     7 #  在字符串和数字之间不是严格界定的，
     8 #+ 因为Bash变量不是强类型的。
     9 
    10 #  Bash允许变量的整数操作和比较，
    11 #+ 但这些变量必须只包括数字字符.
    12 #  不管怎么样，你应该小心考虑.
    13 
    14 echo
    15 
    16 if [ "$a" -ne "$b" ]
    17 then
    18   echo "$a is not equal to $b"
    19   echo "(arithmetic comparison)"
    20 fi
    21 
    22 echo
    23 
    24 if [ "$a" != "$b" ]
    25 then
    26   echo "$a is not equal to $b."
    27   echo "(string comparison)"
    28   #     "4"  != "5"
    29   # ASCII 52 != ASCII 53
    30 fi
    31 
    32 # 在这个实际的例子中,"-ne"和"!="都能工作.
    33 
    34 echo
    35 
    36 exit 0
  ```

- 判断一个字符串是否是null

  ```
  如果一个字符串变量没有被初始化，它里面的值未定义。这种情况称为"null"值(不同于零).
  if [ -n $string1 ]    # $string1没有被声明或初始化. 此时返回结果为真
  if [ -n "$string1" ]  # 这次, $string1变量被引号引起.此时返回结果为假
  if [ $string1 ]       # 这次,变量$string1什么也不加.此时返回结果为假，上面所有的都是未初始化的变量。
  
  ```

  ```
  Linux 下判断字符串是否为空，有一个大坑！
  首先想到的两个参数：
  
  -z：判断 string 是否是空串
  -n：判断 string 是否是非空串
  
  常规错误做法：
  #!/bin/sh
  STRING=
  if [ -z $STRING ]; then 
      echo "STRING is empty" 
  fi
  
  if [ -n $STRING ]; then 
      echo "STRING is not empty" 
  fi
  
  root@james-desktop:~# ./zerostring.sh 
  STRING is empty 
  STRING is not empty
  
  发现使用 -n 判断时，竟然出现错误！
  
  正确做法：
  #!/bin/sh
  
  STRING=
  if [ -z "$STRING" ]; then 
      echo "STRING is empty" 
  fi
  
  if [ -n "$STRING" ]; then 
      echo "STRING is not empty" 
  fi
  
  root@james-desktop:~# ./zerostring.sh 
  STRING is empty
  
  这里，我们得出一个道理，在进行字符串比较时，用引号将字符串界定起来，是一个非常好的习惯！
  ```

###### 混合比较

- -a逻辑与如果exp1和exp2都为真，则exp1 -a exp2返回真.

- -o逻辑或只要exp1和exp2任何一个为真，则exp1 -o exp2 返回真.

- 它们和Bash中用于[双方括号结构](http://shouce.jb51.net/shell/tests.html#DBLBRACKETS)的比较操作符&&和||很相似。

  ```
  [[ condition1 && condition2 ]]
  ```

- -o和-a操作符和test命令或单方括号一起使用。

  ```
  if [ "$exp1" -a "$exp2" ]
  ```

###### 测试和比较的另一种方法

- 对于测试,[[[ \]]](http://shouce.jb51.net/shell/tests.html#DBLBRACKETS)结构可能比`[ ]`更合适.同样地,算术比较可能用[(( ))](http://shouce.jb51.net/shell/dblparens.html)结构更有用.

```
   1 a=8
   2 
   3 # 下面所有的比较是等价的.
   4 test "$a" -lt 16 && echo "yes, $a < 16"         # "与列表"
   5 /bin/test "$a" -lt 16 && echo "yes, $a < 16" 
   6 [ "$a" -lt 16 ] && echo "yes, $a < 16" 
   7 [[ $a -lt 16 ]] && echo "yes, $a < 16"          # 在[[ ]]和(( ))中不必用引号引起变量
   8 (( a < 16 )) && echo "yes, $a < 16"             #
   9 
  10 city="New York"
  11 # 同样，下面的所有比较都是等价的.
  12 test "$city" \< Paris && echo "Yes, Paris is greater than $city"  # 产生 ASCII 顺序.
  13 /bin/test "$city" \< Paris && echo "Yes, Paris is greater than $city" 
  14 [ "$city" \< Paris ] && echo "Yes, Paris is greater than $city" 
  15 [[ $city < Paris ]] && echo "Yes, Paris is greater than $city"    # 不需要用引号引起$city.
```

#### 操作符和相关主题

- =变量赋值，通用的变量赋值操作符，可以用于数值和字符串的赋值

  ```
  不要把"="赋值操作符和=测试操作符搞混了。
     1 #    = 用于测试操作符
     2 
     3 if [ "$string1" = "$string2" ]
     4 # if [ "X$string1" = "X$string2" ] 会更安全,
     5 # 它为了防止其中有一个字符串为空时产生错误信息.
     6 # (增加的"X"字符可以互相抵消.) 
     7 then
     8    command
     9 fi
  ```

- &&逻辑与，||逻辑或类似

  ```
     1 if [ $condition1 ] && [ $condition2 ]
     2 # 等同于:  if [ $condition1 -a $condition2 ]
     3 # 如果condition1和condition2都为真则返回真...
     4 
     5 if [[ $condition1 && $condition2 ]]    # Also works.
     6 # 注意&&操作不能在[ ... ]结构中使用.
  ```

- 除非一个数字有特别的前缀或符号，否则shell脚本把它当成十进制的数。一个前缀为0的数字是八进制数。一个前缀为0x的数字是十六进制数。一个数用内嵌的#来求值则看成BASE#NUMBER(有范围和符号限制)(译者注：BASE#NUMBER即：基数#数值，参考下面的例子)。

  - ```
    其他的进制的表示形式: BASE#NUMBER
    BASE值在2和64之间.
    NUMBER必须使用在BASE范围内的符号，例如16进制只能到F
    实例
    let "bin = 2#111100111001101"
    ```

- ```
  注意逻辑非字符"!"需要一个空格.
  ! true
  true命令是内建的.
  使用type命令查看是否是内建的命令
   !true   会导致一个"command not found"（命令没有发现）的错误。
  ```

##### 内建命令

- 所谓 Shell 内建命令，就是由 Bash 自身提供的命令，而不是文件系统中的某个可执行文件。

- 例如，用于进入或者切换目录的 cd 命令，虽然我们一直在使用它，但如果不加以注意很难意识到它与普通命令的性质是不一样的：该命令并不是某个外部文件，只要在 Shell 中你就一定可以运行这个命令。

- 可以使用 type 来确定一个命令是否是内建命令：

  ```
  [root@localhost ~]# type cd
  cd is a Shell builtin
  [root@localhost ~]# type ifconfig
  ifconfig is /sbin/ifconfig
  ```

  - 由此可见，cd 是一个 Shell 内建命令，而 ifconfig 是一个外部文件，它的位置是`/sbin/ifconfig`。

- 还记得系统变量 [$PATH](http://c.biancheng.net/view/962.html) 吗？$PATH 变量包含的目录中几乎聚集了系统中绝大多数的可执行命令，它们都是外部命令。

- 通常来说，内建命令会比外部命令执行得更快，执行外部命令时不但会触发磁盘 I/O，还需要 fork 出一个单独的进程来执行，执行完成后再退出。而执行内建命令相当于调用当前 Shell 进程的一个函数。

  | 命令      | 说明                                                  |
  | --------- | ----------------------------------------------------- |
  | :         | 扩展参数列表，执行重定向操作                          |
  | .         | 读取并执行指定文件中的命令（在当前 shell 环境中）     |
  | alias     | 为指定命令定义一个别名                                |
  | bg        | 将作业以后台模式运行                                  |
  | bind      | 将键盘序列绑定到一个 readline 函数或宏                |
  | break     | 退出 for、while、select 或 until 循环                 |
  | builtin   | 执行指定的 shell 内建命令                             |
  | caller    | 返回活动子函数调用的上下文                            |
  | cd        | 将当前目录切换为指定的目录                            |
  | command   | 执行指定的命令，无需进行通常的 shell 查找             |
  | compgen   | 为指定单词生成可能的补全匹配                          |
  | complete  | 显示指定的单词是如何补全的                            |
  | compopt   | 修改指定单词的补全选项                                |
  | continue  | 继续执行 for、while、select 或 until 循环的下一次迭代 |
  | declare   | 声明一个变量或变量类型。                              |
  | dirs      | 显示当前存储目录的列表                                |
  | disown    | 从进程作业表中刪除指定的作业                          |
  | echo      | 将指定字符串输出到 STDOUT                             |
  | enable    | 启用或禁用指定的内建shell命令                         |
  | eval      | 将指定的参数拼接成一个命令，然后执行该命令            |
  | exec      | 用指定命令替换 shell 进程                             |
  | exit      | 强制 shell 以指定的退出状态码退出                     |
  | export    | 设置子 shell 进程可用的变量                           |
  | fc        | 从历史记录中选择命令列表                              |
  | fg        | 将作业以前台模式运行                                  |
  | getopts   | 分析指定的位置参数                                    |
  | hash      | 查找并记住指定命令的全路径名                          |
  | help      | 显示帮助文件                                          |
  | history   | 显示命令历史记录                                      |
  | jobs      | 列出活动作业                                          |
  | kill      | 向指定的进程 ID(PID) 发送一个系统信号                 |
  | let       | 计算一个数学表达式中的每个参数                        |
  | local     | 在函数中创建一个作用域受限的变量                      |
  | logout    | 退出登录 shell                                        |
  | mapfile   | 从 STDIN 读取数据行，并将其加入索引数组               |
  | popd      | 从目录栈中删除记录                                    |
  | printf    | 使用格式化字符串显示文本                              |
  | pushd     | 向目录栈添加一个目录                                  |
  | pwd       | 显示当前工作目录的路径名                              |
  | read      | 从 STDIN 读取一行数据并将其赋给一个变量               |
  | readarray | 从 STDIN 读取数据行并将其放入索引数组                 |
  | readonly  | 从 STDIN 读取一行数据并将其赋给一个不可修改的变量     |
  | return    | 强制函数以某个值退出，这个值可以被调用脚本提取        |
  | set       | 设置并显示环境变量的值和 shell 属性                   |
  | shift     | 将位置参数依次向下降一个位置                          |
  | shopt     | 打开/关闭控制 shell 可选行为的变量值                  |
  | source    | 读取并执行指定文件中的命令（在当前 shell 环境中）     |
  | suspend   | 暂停 Shell 的执行，直到收到一个 SIGCONT 信号          |
  | test      | 基于指定条件返回退出状态码 0 或 1                     |
  | times     | 显示累计的用户和系统时间                              |
  | trap      | 如果收到了指定的系统信号，执行指定的命令              |
  | type      | 显示指定的单词如果作为命令将会如何被解释              |
  | typeset   | 声明一个变量或变量类型。                              |
  | ulimit    | 为系统用户设置指定的资源的上限                        |
  | umask     | 为新建的文件和目录设置默认权限                        |
  | unalias   | 刪除指定的别名                                        |
  | unset     | 刪除指定的环境变量或 shell 属性                       |
  | wait      | 等待指定的进程完成，并返回退出状态码                  |

#### 数学计算

- 如果要执行算术运算（数学计算），就离不开各种运算符号，和其他编程语言类似，Shell 也有很多算术运算符，下面就给大家介绍一下常见的 Shell 算术运算符，如下表所示。

  | 算术运算符            | 说明/含义                                                |
  | --------------------- | -------------------------------------------------------- |
  | +、-                  | 加法（或正号）、减法（或负号）                           |
  | *、/、%               | 乘法、除法、取余（取模）                                 |
  | **                    | 幂运算                                                   |
  | ++、--                | 自增和自减，可以放在变量的前面也可以放在变量的后面       |
  | !、&&、\|\|           | 逻辑非（取反）、逻辑与（and）、逻辑或（or）              |
  | <、<=、>、>=          | 比较符号（小于、小于等于、大于、大于等于）               |
  | ==、!=、=             | 比较符号（相等、不相等；对于字符串，= 也可以表示相当于） |
  | <<、>>                | 向左移位、向右移位                                       |
  | ~、\|、 &、^          | 按位取反、按位或、按位与、按位异或                       |
  | =、+=、-=、*=、/=、%= | 赋值运算符，例如 a+=1 相当于 a=a+1，a-=1 相当于 a=a-1    |

  - 上面写的这些都可以用在算数运算中，即可以使用在(())和let和expr等

- 但是，Shell 和其它编程语言不同，Shell 不能直接进行算数运算，必须使用数学计算命令，这让初学者感觉很困惑，也让有经验的程序员感觉很奇葩。

- ```
  [c.biancheng.net]$ echo 2+8
  2+8
  [c.biancheng.net]$ a=23
  [c.biancheng.net]$ b=$a+55
  [c.biancheng.net]$ echo $b
  23+55
  [c.biancheng.net]$ b=90
  [c.biancheng.net]$ c=$a+$b
  [c.biancheng.net]$ echo $c
  23+90
  ```

  - 从上面的运算结果可以看出，默认情况下，Shell 不会直接进行算术运算，而是把`+`两边的数据（数值或者变量）当做字符串，把`+`当做字符串连接符，最终的结果是把两个字符串拼接在一起形成一个新的字符串。
  - 这是因为，在 Bash Shell 中，如果不特别指明，每一个变量的值都是字符串，无论你给变量赋值时有没有使用引号，值都会以字符串的形式存储。
  - 换句话说，Bash shell 在默认情况下不会区分变量类型，即使你将整数和小数赋值给变量，它们也会被视为字符串，这一点和大部分的编程语言不同。

- 要想让数学计算发挥作用，必须使用数学计算命令，Shell 中常用的数学计算命令如下表所示。

  

  | 运算操作符/运算命令                                     | 说明                                                         |
  | ------------------------------------------------------- | ------------------------------------------------------------ |
  | [(( ))](http://c.biancheng.net/view/2480.html)          | 用于整数运算，效率很高，**推荐使用**。                       |
  | [let](http://c.biancheng.net/view/2504.html)            | 用于整数运算，和 (()) 类似。                                 |
  | $[]                                                     | 用于整数运算，不如 (()) 灵活。                               |
  | [expr](http://c.biancheng.net/view/vip_3236.html)       | 可用于整数运算，也可以处理字符串。比较麻烦，需要注意各种细节，不推荐使用。 |
  | [bc](http://c.biancheng.net/view/vip_3237.html)         | Linux下的一个计算器程序，可以处理整数和小数。Shell 本身只支持整数运算，想计算小数就得使用 bc 这个外部的计算器。 |
  | [declare -i](http://c.biancheng.net/view/vip_3238.html) | 将变量定义为整数，然后再进行数学运算时就不会被当做字符串了。功能有限，仅支持最基本的数学运算（加减乘除和取余），不支持逻辑运算、自增自减等，所以在实际开发中很少使用。 |

##### (())

- 双小括号 (( )) 是 Bash Shell 中专门用来进行整数运算的命令，它的效率很高，写法灵活，是企业运维中常用的运算命令。

- 注意：(( )) 只能进行整数运算，不能对小数（浮点数）或者字符串进行运算。后续讲到的 bc 命令可以用于小数运算。

- 双小括号 (( )) 的语法格式为：

  ```
  ((表达式))
  ```

- 表达式可以只有一个，也可以有多个，多个表达式之间以逗号`,`分隔。对于多个表达式的情况，以最后一个表达式的值作为整个 (( )) 命令的执行结果。

- 可以使用`$`获取 (( )) 命令的结果，这和使用`$`获得变量值是类似的。

- | 运算操作符/运算命令                | 说明                                                         |
  | ---------------------------------- | ------------------------------------------------------------ |
  | ((a=10+66) ((b=a-15)) ((c=a+b))    | 这种写法可以在计算完成后给变量赋值。以 ((b=a-15)) 为例，即将 a-15 的运算结果赋值给变量 c。  注意，使用变量时不用加`$`前缀，(( )) 会自动解析变量名。 |
  | a=$((10+66) b=$((a-15)) c=$((a+b)) | 可以在 (( )) 前面加上`$`符号获取 (( )) 命令的执行结果，也即获取整个表达式的值。以 c=$((a+b)) 为例，即将 a+b 这个表达式的运算结果赋值给变量 c。  注意，类似 c=((a+b)) 这样的写法是错误的，不加`$`就不能取得表达式的结果。 |
  | ((a>7 && b==c))                    | (( )) 也可以进行逻辑运算，在 if 语句中常会使用逻辑运算。     |
  | echo $((a+10))                     | 需要立即输出表达式的运算结果时，可以在 (( )) 前面加`$`符号。 |
  | ((a=3+5, b=a+10))                  | 对多个表达式同时进行计算。                                   |

  - 在 (( )) 中使用变量无需加上`$`前缀，(( )) 会自动解析变量名，这使得代码更加简洁，也符合程序员的书写习惯。
  - 上面的写法是两种理解方式，如果返回双括号的执行结果时在取得结果赋值时，需要加上美元符号，如果在双括号里面赋值时就不需要加美元括号了。
  - 还有多个表示式时指没有赋值的情况，如果在双括号里面赋值此时就不需要用这个表达式赋值了，只有没有赋值的情况下才会用最后一个表达式的情况赋值。

##### let命令

- let 命令和双小括号 (( )) 的用法是类似的，它们都是用来对整数进行运算

- Shell let 命令的语法格式为：

  ```
  let 表达式
  ```

  或者

  ```
  let "表达式"
  ```

  或者

  ```
  let '表达式'
  ```

  - 它们都等价于`((表达式))`。

- 当表达式中含有 Shell 特殊字符（例如 |）时，需要用双引号`" "`或者单引号`' '`将表达式包围起来。

- 和 (( )) 类似，let 命令也支持一次性计算多个表达式，并且以最后一个表达式的值作为整个 let 命令的执行结果。但是，对于多个表达式之间的分隔符，let 和 (( )) 是有区别的：

  - let 命令以空格来分隔多个表达式；
  - (( )) 以逗号`,`来分隔多个表达式。

- 另外还要注意，对于类似`let x+y`这样的写法，Shell 虽然计算了 x+y 的值，但却将结果丢弃；若不想这样，可以使用`let sum=x+y`将 x+y 的结果保存在变量 sum 中。

  - 这种情况下 (( )) 显然更加灵活，可以使用`$((x+y))`来获取 x+y 的结果。请看下面的例子：

  ```
  a=10 b=20
  echo $((a+b))
  30
  echo let a+b  #错误，echo会把 let a+b作为一个字符串输出
  let a+b
  ```

- ```
  let a+=6 c=a+b  #多个表达式以空格为分隔
  ```

##### expr

- expr 是 evaluate expressions 的缩写，译为“表达式求值”。Shell expr 是一个功能强大，并且比较复杂的命令，它除了可以实现整数计算，还可以结合一些选项对字符串进行处理，例如计算字符串长度、字符串比较、字符串匹配、字符串提取等。本节只讲解 expr 在整数计算方面的应用，并不涉及字符串处理，有兴趣的读者请自行研究。

- Shell expr 对于整数计算的用法为：

  ```
  expr 表达式
  ```

  - expr 对`表达式`的格式有几点特殊的要求：

    - 出现在`表达式`中的运算符、数字、变量和小括号的左右两边至少要有一个空格，否则会报错。

    - 有些特殊符号必须用反斜杠`\`进行转义（屏蔽其特殊含义），比如乘号`*`和小括号`()`，如果不用`\`转义，那么 Shell 会把它们误解为正则表达式中的符号（`*`对应通配符，`()`对应分组）。

    - 使用变量时要加`$`前缀。

  ```
  [c.biancheng.net]$ expr 2 +3  #错误：加号和 3 之前没有空格
  expr: 语法错误
  [c.biancheng.net]$ expr 2 + 3  #这样才是正确的
  5
  [c.biancheng.net]$ expr 4 * 5  #错误：乘号没有转义
  expr: 语法错误
  [c.biancheng.net]$ expr 4 \* 5  #使用 \ 转义后才是正确的
  20
  [c.biancheng.net]$ expr ( 2 + 3 ) \* 4  #小括号也需要转义
  bash: 未预期的符号 `2' 附近有语法错误
  [c.biancheng.net]$ expr \( 2 + 3 \) \* 4  #使用 \ 转义后才是正确的
  20
  [c.biancheng.net]$ n=3
  [c.biancheng.net]$ expr n + 2  #使用变量时要加 $
  expr: 非整数参数
  [c.biancheng.net]$ expr $n + 2  #加上 $ 才是正确的
  5
  [c.biancheng.net]$ m=7
  [c.biancheng.net]$ expr $m \* \( $n + 5 \)
  56
  ```

- 以上是直接使用 expr 命令，计算结果会直接输出，如果你希望将计算结果赋值给变量，那么需要将整个表达式用反引号````（位于 Tab 键的上方）包围起来，请看下面的例子。

  ```
  [c.biancheng.net]$ m=5
  [c.biancheng.net]$ n=`expr $m + 10`
  [c.biancheng.net]$ echo $n
  15
  ```

  - 你看，使用 expr 进行数学计算是多么的麻烦呀，需要注意各种细节，我奉劝大家还是省省心，老老实实用 (())、let 或者 $[] 吧。

##### bc

- Bash Shell 内置了对整数运算的支持，但是并不支持浮点运算，而 Linux bc 命令可以很方便的进行浮点运算，当然整数运算也不再话下。

- bc 甚至可以称得上是一种编程语言了，它支持变量、数组、输入输出、分支结构、循环结构、函数等基本的编程元素

- bc命令的一些选项

- | 选项                | 说明                  |
  | ------------------- | --------------------- |
  | -h \| --help        | 帮助信息              |
  | -v \| --version     | 显示命令版本信息      |
  | -l \| --mathlib     | 使用标准数学库        |
  | -i \| --interactive | 强制交互              |
  | -w \| --warn        | 显示 POSIX 的警告信息 |
  | -s \| --standard    | 使用 POSIX 标准来处理 |
  | -q \| --quiet       | 不显示欢迎信息        |

- bc 有四个内置变量，我们在计算时会经常用到，如下表所示：

  | 变量名      | 作 用                                                        |
  | ----------- | ------------------------------------------------------------ |
  | scale       | 指定精度，也即小数点后的位数；默认为 0，也即不使用小数部分。 |
  | ibase       | 指定输入的数字的进制，默认为十进制。                         |
  | obase       | 指定输出的数字的进制，默认为十进制。                         |
  | last 或者 . | 表示最近打印的数字                                           |

- bc 还有一些内置函数，如下表所示：

  | 函数名  | 作用                               |
  | ------- | ---------------------------------- |
  | s(x)    | 计算 x 的正弦值，x 是弧度值。      |
  | c(x)    | 计算 x 的余弦值，x 是弧度值。      |
  | a(x)    | 计算 x 的反正切值，返回弧度值。    |
  | l(x)    | 计算 x 的自然对数。                |
  | e(x)    | 求 e 的 x 次方。                   |
  | j(n, x) | 贝塞尔函数，计算从 n 到 x 的阶数。 |

  - 要想使用这些数学函数，在输入 bc 命令时需要使用`-l`选项，表示启用数学库

- 在前边的例子中，我们基本上是一行一个表达式，这样看起来更加舒服；如果你愿意，也可以将多个表达式放在一行，只要用分号`;`隔开就行

###### shell中使用bc

- 在 Shell 脚本中，我们可以借助管道或者输入重定向来使用 bc 计算器。

  - 管道是 Linux 进程间的一种通信机制，它可以将前一个命令（进程）的输出作为下一个命令（进程）的输入，两个命令之间使用竖线`|`分隔。
  - 通常情况下，一个命令从终端获得用户输入的内容，如果让它从其他地方（比如文件）获得输入，那么就需要重定向。

- 如果读者希望直接输出 bc 的计算结果，那么可以使用下面的形式：

  ```
  echo "expression" | bc
  ```

  - `expression`就是希望计算的数学表达式，它必须符合 bc 的语法，上面我们已经进行了介绍。在 expression 中，还可以使用 Shell 脚本中的变量。

- 使用下面的形式可以将 bc 的计算结果赋值给 Shell 变量：

  ```
  variable=$(echo "expression" | bc)
  
  variable 就是变量名。
  ```

- 进制转换实例

  ```
  #十进制转十六进制
  [mozhiyan@localhost ~]$ m=31
  [mozhiyan@localhost ~]$ n=$(echo "obase=16;$m"|bc)
  [mozhiyan@localhost ~]$ echo $n
  1F
  #十六进制转十进制
  [mozhiyan@localhost ~]$ m=1E
  [mozhiyan@localhost ~]$ n=$(echo "obase=10;ibase=16;$m"|bc)
  [mozhiyan@localhost ~]$ echo $n
  30
  ```

- 借助输入重定向使用 bc 计算器

  ```
  variable=$(bc << EOF
  expressions
  EOF
  )
  ```

  - 其中，`variable`是 Shell 变量名，`express`是要计算的数学表达式（可以换行，和进入 bc 以后的书写形式一样），`EOF`是数学表达式的开始和结束标识（你也可以换成其它的名字，比如 aaa、bbb 等）。

#### 特殊变量

##### 特殊字符

###### 空命令：

- 这个命令意思是空操作(`*即什么操作也不做*`). 它一般被认为是和shell的内建命令[true](http://shouce.jb51.net/shell/internal.html#TRUEREF)是一样的。冒号":" 命令是Bash自身[内建](http://shouce.jb51.net/shell/internal.html#BUILTINREF)的, and its它的[退出状态码](http://shouce.jb51.net/shell/exit-status.html#EXITSTATUSREF)是真(即0)。[译者注：shell中真用数字0表示].

  - 死循环可以这么写：

    ```
       1 while :
       2 do
       3    operation-1
       4    operation-2
       5    ...
       6    operation-n
       7 done
       8 
       9 # 等同于:
      10 #    while true
      11 #    do
      12 #      ...
      13 #    done
    ```

  - 在必须要有两元操作的地方作为一个分隔符

    ```
     1 : ${username=`whoami`}
     2 # ${username=`whoami`}   如果没有开头的:，将会出错
     3 #                        除非"username"是一个外部命令或是内建命令...
    ```

    ```
     : $((n = $n + 1))
     #  ":"是需要的，
     #+ 否则Bash会尝试把"$((n = $n + 1))"作为命令运行.
     echo -n "$n "
    ```

    - 冒号和后面要有一个空格作为分割。

  - 和[重定向操作符](http://shouce.jb51.net/shell/io-redirection.html#IOREDIRREF)（>）连用, 可以把一个文件的长度截短为零，文件的权限不变。如果文件不存在，则会创建一个新文件。
  
    ```
     : > data.xxx   # 文件"data.xxx"现在长度为0了	      
     
     # 作用相同于：cat /dev/null >data.xxx（译者注：echo >data.xxx也可以）
     # 但是，用NULL（:）操作符不会产生一个新的进程，因为NULL操作符是内建的。
    ```
  
  - 和添加重定向操作符（>>）连用(`**: >> target_file**`).如果目标文件存在则什么也没有发生，如果目标文件不存在，则创建它。

###### （）

- 一组由圆括号括起来的命令是新开一个[子shell](http://shouce.jb51.net/shell/subshells.html#SUBSHELLSREF)来执行的.

  - 因为是在子shell里执行，在圆括号里的变量不能被脚本的其他部分访问。因为[父进程（即脚本进程）不能存取子进程（即子shell）创建的变量](http://shouce.jb51.net/shell/subshells.html#PARVIS)。

    ```
    a=123
    ( a=321; )	      
     
    echo "a = $a"   # a = 123
    # 在圆括号里的变量"a"实际上是一个局部变量，作用局域只是在圆括号内用于数组始初化
    ```

- 数组初始化

  ```
  Array=(element1 element2 element3)
  ```

###### {}

- **代码块[花括号].** 这个结构也是一组命令代码块，事实上，它是匿名的函数。然而与一个[函数](http://shouce.jb51.net/shell/functions.html#FUNCTIONREF)所不同的,在代码块里的变量仍然能被脚本后面的代码访问。

  ```
  a=123
  { a=321; }
  echo "a = $a"   # a = 321   (结果是在代码块里的值)
  ```

- 不像一个用圆括号括起来的命令组，一个用花括号括起的代码块不会以一个[子shell](http://shouce.jb51.net/shell/subshells.html#SUBSHELLSREF)运行。

- 看一下下面的shell组命令

  - **代码块与I/O重定向**

    ```
    
       1 #!/bin/bash
       2 # 从/etc/fstab文件里按一次一行地读.
       3 
       4 File=/etc/fstab
       5 
       6 {
       7 read line1
       8 read line2
       9 } < $File
      10 
      11 echo "First line in $File is:"
      12 echo "$line1"
      13 echo
      14 echo "Second line in $File is:"
      15 echo "$line2"
      16 
      17 exit 0
    ```

  - **把一个代码块的结果写进一个文件**

    ```
       1 #!/bin/bash
       2 # rpm-check.sh
       3 
       4 # 查询一个rpm安装包的描述，软件清单，和是否它能够被安装.
       5 # 并把结果保存到一个文件中.
       6 # 
       7 # 这个脚本使用一个代码块来举例说明。
       8 
       9 SUCCESS=0
      10 E_NOARGS=65
      11 
      12 if [ -z "$1" ]
      13 then
      14   echo "Usage: `basename $0` rpm-file"
      15   exit $E_NOARGS
      16 fi  
      17 
      18 { 
      19   echo
      20   echo "Archive Description:"
      21   rpm -qpi $1       # 查询软件包的描述.
      22   echo
      23   echo "Archive Listing:"
      24   rpm -qpl $1       # 查询软件包中的软件清单.
      25   echo
      26   rpm -i --test $1  # 查询该软件包能否被安装.
      27   if [ "$?" -eq $SUCCESS ]
      28   then
      29     echo "$1 can be installed."
      30   else
      31     echo "$1 cannot be installed."
      32   fi  
      33   echo
      34 } > "$1.test"       # 把代码块的所有输出重定向到一个文件中。
      35 
      36 echo "Results of rpm test in file $1.test"
      37 
      38 # 参考rpm的man手册来理解上面所用的选项。
      39 
      40 exit 0
    ```

#### 访问变量

##### 操作字符串

- Bash已经支持了令人惊讶的字符串操作的数量。不幸地，这些工具缺乏统一的标准。一些是[参数替换](http://shouce.jb51.net/shell/parameter-substitution.html#PARAMSUBREF)的子集，其它受到UNIX的[expr](http://shouce.jb51.net/shell/moreadv.html#EXPRREF)命令的功能的影响。这导致不一致的命令语法和冗余的功能，但这些并没有引起混乱。

###### 字符串长度

```
${#string}
expr length $string
expr "$string" : '.*'

   1 stringZ=abcABC123ABCabc
   2 
   3 echo ${#stringZ}                 # 15
   4 echo `expr length $stringZ`      # 15
   5 echo `expr "$stringZ" : '.*'`    # 15
```

###### 匹配字符串开头的字串的长度

```
expr match "$string" '$substring'
$substring 是一个正则表达式.

expr "$string" : '$substring'
$substring 是一个正则表达式.

   1 stringZ=abcABC123ABCabc
   2 #       |------|
   3 
   4 echo `expr match "$stringZ" 'abc[A-Z]*.2'`   # 8
   5 echo `expr "$stringZ" : 'abc[A-Z]*.2'`       # 8
```

###### 索引

```
expr index $string $substring

   1 stringZ=abcABC123ABCabc
   2 echo `expr index "$stringZ" C12`             # 6
   3                                              # C 字符的位置.
   4 
   5 echo `expr index "$stringZ" 1c`              # 3
   6 # 'c' (in #3 position) matches before '1'.
```

###### 子串提取

```
${string:position}
把$string中从第$postion个字符开始字符串提取出来.

如果$string是"*"或"@"，则表示从位置参数中提取第$postion后面的字符串。[1]

${string:position:length}
把$string中$postion个字符后面的长度为$length的字符串提取出来。

   1 stringZ=abcABC123ABCabc
   2 #       0123456789.....
   3 #       以0开始计算.
   4 
   5 echo ${stringZ:0}                            # abcABC123ABCabc
   6 echo ${stringZ:1}                            # bcABC123ABCabc
   7 echo ${stringZ:7}                            # 23ABCabc
   8 
   9 echo ${stringZ:7:3}                          # 23A
  10                                              # 提取的子串长为3

  14 # 有没有可能从字符串的右边结尾处提取?
  15     
  16 echo ${stringZ:-4}                           # abcABC123ABCabc
  17 # 默认是整个字符串，就相当于${parameter:-default}.
  18 # 然而. . .
  19 
  20 echo ${stringZ:(-4)}                         # Cabc 
  21 echo ${stringZ: -4}                          # Cabc
  22 # 这样,它可以工作了.
  23 # 圆括号或附加的空白字符可以转义$position参数.
 
 
如果$string参数是"*"或"@"，则会提取第$length个位置参数开始的共$length个参数。[译者注：实际取得的参数有可能少于$length，因为有可能余下的参数没有那么多了]

   1 echo ${*:2}          # 打印第二个位置以后的参数.
   2 echo ${@:2}          # 和上面一样.
   3 
   4 echo ${*:2:3}        # 打印从第二个参数起的三个位置参数.
   
   上面这几个是将传进来的位置参数打印出来，因为位置参数也算是一个大的字符串也需要提取
```

```
expr substr $string $position $length
	提取$string中从位置$postition开始的长度为$length的子字符串。
   1 stringZ=abcABC123ABCabc
   2 #       123456789......
   3 #       以1开始计算.
   4 
   5 echo `expr substr $stringZ 1 2`              # ab
   6 echo `expr substr $stringZ 4 3`              # ABC
   
expr match "$string" '\($substring\)'
	从$string字符串左边开始提取提取由$substring描述的正则表达式的子串。
	
expr "$string" : '\($substring\)'
	从$string字符串左边开始提取由$substring描述的正则表达式的子串。

   1 stringZ=abcABC123ABCabc
   2 #       =======	    
   3 
   4 echo `expr match "$stringZ" '\(.[b-c]*[A-Z]..[0-9]\)'`   # abcABC1
   5 echo `expr "$stringZ" : '\(.[b-c]*[A-Z]..[0-9]\)'`       # abcABC1
   6 echo `expr "$stringZ" : '\(.......\)'`                   # abcABC1
   7 # 上面的每个echo都打印相同的结果.
   
expr match "$string" '.*\($substring\)'
	从$string字符串结尾开始提取由$substring描述的正则表达式的子串。
	
expr "$string" : '.*\($substring\)'
	从$string字符串结尾开始提取由$substring描述的正则表达式的子串。	
   1 stringZ=abcABC123ABCabc
   2 #                ======
   3 
   4 echo `expr match "$stringZ" '.*\([A-C][A-C][A-C][a-c]*\)'`    # ABCabc
   5 echo `expr "$stringZ" : '.*\(......\)'`                       # ABCabc
```

###### 子串移动

```
${string#substring}
从$string左边开始，剥去最短匹配$substring子串.

${string##substring}
从$string左边开始，剥去最长匹配$substring子串.
   1 stringZ=abcABC123ABCabc
   2 #       |----|
   3 #       |----------|
   4 
   5 echo ${stringZ#a*C}      # 123ABCabc
   6 # 剥去匹配'a'到'C'之间最短的字符串.
   7 
   8 echo ${stringZ##a*C}     # abc
   9 # 剥去匹配'a'到'C'之间最长的字符串.
   
${string%substring}
从$string结尾开始，剥去最短匹配$substring子串。

${string%%substring}
从$string结尾开始，剥去最长匹配$substring子串。

   1 stringZ=abcABC123ABCabc
   2 #                    ||
   3 #        |------------|
   4 
   5 echo ${stringZ%b*c}      # abcABC123ABCa
   6 # 从$stringZ后面尾部开始，剥去匹配'a'到'C'之间最短的字符串.
   7 
   8 echo ${stringZ%%b*c}     # a
   9 # 从$stringZ后面尾部开始，剥去匹配'a'到'C'之间最长的字符串.
   
```

```
   1 #!/bin/bash
   2 #  cvt.sh:
   3 #  把一个目录下的所有MacPaint图像文件转换成"pbm"格式.
   4 
   5 #  使用软件包"netpbm"中的"macptopbm"程序来转换,
   6 #+ 这个程序由Brian Henderson(bryanh@giraffe-data.com)维护.
   7 #  Netpbm是大多数Linux发行版的标准套件.
   8 
   9 OPERATION=macptopbm
  10 SUFFIX=pbm          # 新的文件后缀. 
  11 
  12 if [ -n "$1" ]
  13 then
  14   directory=$1      # 如果一个目录名传递给脚本...
  15 else
  16   directory=$PWD    # 否则使用当前目录.
  17 fi  
  18   
  19 #  假定在目标目录中，
  20 #+ 都是带着".mac"后缀的MacPaint图像文件.
  21 
  22 for file in $directory/*    # 文件名匹配符.
  23 do
  24   filename=${file%.*c}      #  剥掉文件名中的".mac"后缀，
  25                             #+ '.*c'匹配所有'.'和'c'之间所有的匹配字符 
  26 			    
  27   $OPERATION $file > "$filename.$SUFFIX"
  28                             # 把结果重定向到新的文件中
  29   rm -f $file               # 转换后删除原来的文件.
  30   echo "$filename.$SUFFIX"  # 打印一条完成某文件的消息到标准输出.
  31 done
  32 
  33 exit 0
```

###### 子串替换

```
${string/substring/replacement}
用$replacement替换由$substring匹配的字符串。

${string//substring/replacement}
用$replacement替换所有匹配$substring的字符串。
   1 stringZ=abcABC123ABCabc
   2 
   3 echo ${stringZ/abc/xyz}           # xyzABC123ABCabc
   4                                   #用'xyz'代替第一个匹配的'abc'.
   5 
   6 echo ${stringZ//abc/xyz}          # xyzABC123ABCxyz
   7                                   # 用'xyz'代替所有的'abc'.
   
${string/#substring/replacement}
如果$string字符串的最前端匹配$substring字符串，用$replacement替换$substring.

${string/%substring/replacement}
如果$string字符串的最后端匹配$substring字符串，用$replacement替换$substring.

   1 stringZ=abcABC123ABCabc
   2 
   3 echo ${stringZ/#abc/XYZ}          # XYZABC123ABCabc
   4                                   # 用'XYZ'替换前端的'abc'.
   5 
   6 echo ${stringZ/%abc/XYZ}          # abcABC123ABCXYZ
   7                                   # 用'XYZ'替换后端的'abc'.
```

- Bash脚本可以调用[awk](http://shouce.jb51.net/shell/awk.html#AWKREF)的字符串操作功能来代替它自己内建的字符串操作符.

##### 参数替换

- ${parameter}，和$parameter是相同的，都是表示变量parameter的值。在一些环境中，使用${parameter}比较不会引起误解.

  ```
  可以把变量和字符串连接.
     1 your_id=${USER}-on-${HOSTNAME}
     2 echo "$your_id"
     3 #
     4 echo "Old \$PATH = $PATH"
     5 PATH=${PATH}:/opt/bin  #在脚本的生存期内，能额外增加路径/opt/bin到环境变量$PATH中去.
     6 echo "New \$PATH = $PATH"
  ```

- **${parameter-default}**`, `**${parameter:-default}**，如果变量没有被设置，使用默认值。

  ```
   1 echo ${username-`whoami`}
   2 # 如果变量$username还没有被设置，则把命令`whoami`的结果赋给该变量.
  ```

  - ${parameter-default}和${parameter:-default}几乎是相等的。它们之间的差别是：当一个参数已被声明，但是值是NULL的时候两者不同.

    ```
       1 #!/bin/bash
       2 # param-sub.sh
       3 
       4 #  变量是否被声明，
       5 #+ 即使它的值是空的(null)
       6 #+ 也会影响是否使用默认值.
       7 
       8 username0=
       9 echo "username0 has been declared, but is set to null."
      10 echo "username0 = ${username0-`whoami`}"
      11 # 不会有输出.
      12 
      13 echo
      14 
      15 echo username1 has not been declared.
      16 echo "username1 = ${username1-`whoami`}"
      17 # 会输出默认值.
      18 
      19 username2=
      20 echo "username2 has been declared, but is set to null."
      21 echo "username2 = ${username2:-`whoami`}"
      22 #                            ^
      23 # 和上面一个实例比较.
      24 # 有输出是因为:-比-多一个测试条件.
    ```

- **${parameter=default}**`, `**${parameter:=default}**，如果变量parameter没有设置，把它设置成默认值.

  ```
     1 echo ${username=`whoami`}
     2 # 变量"username"现在已经被设置成`whoami`的输出.
  ```

- **${parameter+alt_value}**`, `**${parameter:+alt_value}**，如果变量parameter设置，使用alt_value作为新值，否则使用空字符串。除了引起的当变量被声明且值是空值时有些不同外，两种形式几乎相等。请看下面的例子.

  ```
     1 echo "###### \${parameter+alt_value} ########"
     2 echo
     3 
     4 a=${param1+xyz}
     5 echo "a = $a"      # a =
     6 
     7 param2=
     8 a=${param2+xyz}
     9 echo "a = $a"      # a = xyz
    10 
    11 param3=123
    12 a=${param3+xyz}
    13 echo "a = $a"      # a = xyz
    14 
    15 echo
    16 echo "###### \${parameter:+alt_value} ########"
    17 echo
    18 
    19 a=${param4:+xyz}
    20 echo "a = $a"      # a =
    21 
    22 param5=
    23 a=${param5:+xyz}
    24 echo "a = $a"      # a =
    25 # 产生与a=${param5+xyz}不同。
    26 
    27 param6=123
    28 a=${param6+xyz}
    29 echo "a = $a"      # a = xyz
  ```

- **${parameter?err_msg}**`, `**${parameter:?err_msg}**，如果变量parameter已经设置，则使用该值，否则打印err_msg错误信息。这两种形式几乎相同，仅有和上面所说的一点不同：带有:使当变量已声明但值是空值时不同.

- 实例

  - **变量替换和"usage"信息[译者注：通常就是帮助信息]**

    ```
    
       1 #!/bin/bash
       2 # usage-message.sh
       3 
       4 : ${1?"Usage: $0 ARGUMENT"}
       5 #  如果没有提供命令行参数则脚本在这儿就退出了,
       6 #+ 并打印了错误信息.
       7 #    usage-message.sh: 1: Usage: usage-message.sh ARGUMENT
       8 
       9 echo "These two lines echo only if command-line parameter given."
      10 echo "command line parameter = \"$1\""
      11 
      12 exit 0  # 仅在命令行参数提供时，才会在这儿退出.
      13 
      14 # 分别检查有命令行参数和没有命令行参数时的退出状态。
      15 # 如果有命令行参数,则"$?"为0.
      16 # 否则, "$?"为1.
    ```

##### declare和typeset

- declare 和 typeset 都是 Shell 内建命令，它们的用法相同，都用来设置变量的属性。不过 typeset 已经被弃用了，建议使用 declare 代替。

- declare 命令的用法如下所示：

  ```
  declare [+/-] [aAfFgilprtux] [变量名=变量值]
  ```

  - 其中，`-`表示设置属性，`+`表示取消属性，`aAfFgilprtux`都是具体的选项，它们的含义如下表所示：

    

    | 选项            | 含义                                                       |
    | --------------- | ---------------------------------------------------------- |
    | -f [name]       | 列出之前由用户在脚本中定义的函数名称和函数体。             |
    | -F [name]       | 仅列出自定义函数名称。                                     |
    | -g name         | 在 Shell 函数内部创建全局变量。                            |
    | -p [name]       | 显示指定变量的属性和值。                                   |
    | -a name         | 声明变量为普通数组。                                       |
    | -A name         | 声明变量为关联数组（支持索引下标为字符串）。               |
    | -i name         | 将变量定义为整数型。                                       |
    | -r name[=value] | 将变量定义为只读（不可修改和删除），等价于 readonly name。 |
    | -x name[=value] | 将变量设置为环境变量，等价于 export name[=value]。         |

- 将变量声明为整数并进行计算。

  ```
  #!/bin/bash
  declare -i m n ret  #将多个变量声明为整数
  m=10
  n=30
  ret=$m+$n
  echo $ret
  ```

- 将变量定义为只读变量。

  ```
  [c.biancheng.net]$ declare -r n=10
  [c.biancheng.net]$ n=20
  bash: n: 只读变量
  [c.biancheng.net]$ echo $n
  10
  ```

- 显示变量的属性和值。

  ```
  [c.biancheng.net]$ declare -r n=10
  [c.biancheng.net]$ declare -p n
  declare -r n="10"
  ```

##### $RANDOM：产生随机整数

- `$RANDOM`是Bash的一个返回伪随机 [[1\]](http://shouce.jb51.net/shell/randomvar.html#FTN.AEN5161)整数(范围为0 - 32767)的内部[函数](http://shouce.jb51.net/shell/functions.html#FUNCTIONREF)(而不是一个常量或变量)，它不应该用于产生加密的密钥.

- 产生随机整数实例

  ```
     1 #!/bin/bash
     2 
     3 # 每次调用$RANDOM都会返回不同的随机整数.
     4 # 范围为: 0 - 32767 (带符号的16位整数).
     5 
     6 MAXCOUNT=10
     7 count=1
     8 
     9 echo
    10 echo "$MAXCOUNT random numbers:"
    11 echo "-----------------"
    12 while [ "$count" -le $MAXCOUNT ]      # 产生10($MAXCOUNT)个随机整数.
    13 do
    14   number=$RANDOM
    15   echo $number
    16   let "count += 1"  # 增加计数.
    17 done
    18 echo "-----------------"
    19 
    20 # 如果你需要某个范围的随机整数，可以使用取模操作符.(译者注：事实上，这不是一个非常好的办法。理由请见man 3 rand)
    21 # 取模操作会返回除法的余数.
    22 
    23 RANGE=500
    24 
    25 echo
    26 
    27 number=$RANDOM
    28 let "number %= $RANGE"
    29 #           ^^
    30 echo "Random number less than $RANGE  ---  $number"
    31 
    32 echo
    33 
    34 
    35 
    36 #  如果你需要一个大于某个下限的随机整数,
    37 #+ 应该增加测试以便抛弃所有小于此下限值的数值.
    38 
    39 FLOOR=200
    40 
    41 number=0   #初始化
    42 while [ "$number" -le $FLOOR ]
    43 do
    44   number=$RANDOM
    45 done
    46 echo "Random number greater than $FLOOR ---  $number"
    47 echo
    48 
    49    # 让我们检测另外一个完成上面循环作用的简单办法，即
    50    #       let "number = $RANDOM + $FLOOR"
    51    # 这能避免了while循环，并且运行得更快。
    52    # 但，使用这个技术可能会产生问题，思考一下是什么问题？
    53 
    54 
    55 
    56 # 联合上面两个技巧重新产生在两个限制值之间的随机整数.
    57 number=0   #初始化
    58 while [ "$number" -le $FLOOR ]
    59 do
    60   number=$RANDOM
    61   let "number %= $RANGE"  # Scales $number down within $RANGE.
    62 done
    63 echo "Random number between $FLOOR and $RANGE ---  $number"
    64 echo
    65 
    66 
    67 
    68 # 产生二元值，即"真"或"假".
    69 BINARY=2
    70 T=1
    71 number=$RANDOM
    72 
    73 let "number %= $BINARY"
    74 #  注意    let "number >>= 14"    会产生更平均的随机分布   #(译者注：正如在man手册里提到的，更高位的随机分布更平均，
    75 #+ (除了最后的二元值右移出所有的值).                       #取模操作使用低位来产生随机会相对不平均)
    76 if [ "$number" -eq $T ]
    77 then
    78   echo "TRUE"
    79 else
    80   echo "FALSE"
    81 fi  
    82 
    83 echo
    84 
    85 
    86 # 模拟掷骰子.
    87 SPOTS=6   # 模除 6 会产生 0 - 5 之间的值.
    88           # 结果增1会产生 1 - 6 之间的值.
    89           # 多谢Paulo Marcel Coelho Aragao的简化.
    90 die1=0
    91 die2=0
    92 # 这会比仅设置SPOTS=7且不增1好?为什么会好？为什么会不好?
    93 
    94 # 单独地掷每个骰子，然后计算出正确的机率.
    95 
    96     let "die1 = $RANDOM % $SPOTS +1" # 掷第一个.
    97     let "die2 = $RANDOM % $SPOTS +1" # 掷第二个.
    98     #  上面的算术式中，哪个操作符优先计算 --
    99     #+ 取模 (%) 还是 加法 (+)?
   100 
   101 
   102 let "throw = $die1 + $die2"
   103 echo "Throw of the dice = $throw"
   104 echo
   105 
   106 
   107 exit 0
  ```

#### 循环和分支

##### 循环

```
for arg in [list]
do
   command(s)...
done
```

- 在循环的每次执行中,arg将顺序的存取list中列出的变量..

  ```
     1 for arg in "$var1" "$var2" "$var3" ... "$varN"  
     2 # 在第1次循环中, arg = $var1	    
     3 # 在第2次循环中, arg = $var2	    
     4 # 在第3次循环中, arg = $var3	    
     5 # ...
     6 # 在第N次循环中, arg = $varN
     7 
     8 # 在[list]中的参数加上双引号是为了防止单词被不合理地分割.
  ```

  - list中的参数允许包含通配符.
  - 如果do和for想在同一行出现,那么在它们之间需要添加一个";".

- 每个`[list]`中的元素都可能包含多个参数.在处理参数组时,这是非常有用的.在这种情况下,使用[set](http://shouce.jb51.net/shell/internal.html#SETREF)命令(见[例子 11-15](http://shouce.jb51.net/shell/internal.html#EX34))来强制解析每个[list]中的元素,并且分配每个解析出来的部分到一个位置参数中.

- 在for循环中操作文件

  ```
  
     1 #!/bin/bash
     2 # list-glob.sh:  在for循环中使用文件名扩展产生 [list]
     3 
     4 echo
     5 
     6 for file in *
     7 #           ^  在表达式中识别文件扩展符时,
     8 #+             Bash 将执行文件名扩展.
     9 do
    10   ls -l "$file"  # Lists all files in $PWD (current directory).
    11   #  回想一下,通配符"*"能够匹配所有文件,
    12   #+ 然而,在"文件扩展符"中,是不能匹配"."文件的.
    13 
    14   #  如果没匹配到任何文件,那它将扩展成自己
    15   #  为了不让这种情况发生,那就设置nullglob选项
    16   #+   (shopt -s nullglob).
    17   #  Thanks, S.C.
    18 done
    19 
    20 echo; echo
    21 
    22 for file in [jx]*
    23 do
    24   rm -f $file    # 只删除当前目录下以"j"或"x"开头的文件.
    25   echo "Removed file \"$file\"".
    26 done
    27 
    28 echo
    29 
    30 exit 0
  ```

  - 因为shell脚本本来就是命令的组成，所以我们可以直接操作文件，在for魂环中的通配符就代表匹配的文件。

- 在一个for循环中忽略`in [list]`部分的话,将会使循环操作$@(从命令行传递给脚本的参数列表).一个非常好的例子,见[例子 A-16](http://shouce.jb51.net/shell/contributed-scripts.html#PRIMES).

  ```
     1 #!/bin/bash
     2 
     3 #  使用两种方法来调用这个脚本,一种是带参数的情况,另一种不带参数.
     4 #+ 观察此脚本的行为各是什么样的?
     5 
     6 for a
     7 do
     8  echo -n "$a "
     9 done
    10 
    11 #  没有[list],所以循环将操作'$@'
    12 #+ (包括空白的命令参数列表).
    13 
    14 echo
    15 
    16 exit 0
  ```

- 使用命令替换来产生for循环的[list]

  ```
     1 #!/bin/bash
     2 #  for-loopcmd.sh: 带[list]的for循环
     3 #+ [list]是由命令替换产生的.
     4 
     5 NUMBERS="9 7 3 8 37.53"
     6 
     7 for number in `echo $NUMBERS`  # for number in 9 7 3 8 37.53
     8 do
     9   echo -n "$number "
    10 done
    11 
    12 echo 
    13 exit 0
  ```

  - 使用命令替换时如果里面的结果是带空格的字符串的话就会自动当成很多个元素，并不是只有一个。

    ```
    列出系统上的所有用户，awk分割出来每一个就是一个元素，可以在for循环里面便利。
    1 #!/bin/bash
       2 # userlist.sh
       3 
       4 PASSWORD_FILE=/etc/passwd
       5 n=1           # User number
       6 
       7 for name in $(awk 'BEGIN{FS=":"}{print $1}' < "$PASSWORD_FILE" )
       8 # 域分隔   = :           ^^^^^^
       9 # 打印出第一个域                 ^^^^^^^^
      10 # 从password文件中取得输入                    ^^^^^^^^^^^^^^^^^
      11 do
      12   echo "USER #$n = $name"
      13   let "n += 1"
      14 done  
      15 
      16 
      17 # USER #1 = root
      18 # USER #2 = bin
      19 # USER #3 = daemon
      20 # ...
      21 # USER #30 = bozo
      22 
      23 exit 0
    ```

  - 列出目录下所有的符号连接

    ```
       1 #!/bin/bash
       2 # symlinks.sh: 列出目录中所有的符号连接文件.
       3 
       4 
       5 directory=${1-`pwd`}
       6 #  如果没有其他的特殊指定,
       7 #+ 默认为当前工作目录.
       8 #  下边的代码块,和上边这句等价.
       9 # ----------------------------------------------------------
      10 # ARGS=1                 # 需要一个命令行参数.
      11 #
      12 # if [ $# -ne "$ARGS" ]  # 如果不是一个参数的话...
      13 # then
      14 #   directory=`pwd`      # 当前工作目录
      15 # else
      16 #   directory=$1
      17 # fi
      18 # ----------------------------------------------------------
      19 
      20 echo "symbolic links in directory \"$directory\""
      21 
      22 for file in "$( find $directory -type l )"   # -type l 就是符号连接文件
      23 do
      24   echo "$file"
      25 done | sort                                  # 否则列出的文件将是未排序的
      26 #  严格上说,此处并不一定非要一个循环不可,
      27 #+ 因为"find"命令的结果将被扩展成一个单词.
      28 #  然而,这种方式很容易理解和说明.
      29 
      30 #  Dominik 'Aeneas' Schnitzer 指出,
      31 #+ 如果没将 $( find $directory -type l )用""引用起来的话
      32 #+ 那么将会把一个带有空白部分的文件名拆成以空白分隔的两部分(文件名中允许有空白).
      33 #  即使这只将取出每个参数的第一个域.
      34 
      35 exit 0
      36 
      37 
      38 # Jean Helou 建议使用下边的方法:
      39 
      40 echo "symbolic links in directory \"$directory\""
      41 # 当前IFS的备份.要小心使用这个值.
      42 OLDIFS=$IFS
      43 IFS=:
      44 
      45 for file in $(find $directory -type l -printf "%p$IFS")
      46 do     #                              ^^^^^^^^^^^^^^^^
      47        echo "$file"
      48        done|sort
    ```

###### c风格的for循环

```
  1 #!/bin/bash
   2 # 两种循环到10的方法.
   3 
   4 echo
   5 
   6 # 标准语法.
   7 for a in 1 2 3 4 5 6 7 8 9 10
   8 do
   9   echo -n "$a "
  10 done  
  11 
  12 echo; echo
  13 
  14 # +==========================================+
  15 
  16 # 现在, 让我们用C风格的语法做同样的事.
  17 
  18 LIMIT=10
  19 
  20 for ((a=1; a <= LIMIT ; a++))  # 双圆括号, 并且"LIMIT"变量前边没有 "$".
  21 do
  22   echo -n "$a "
  23 done                           # 这是一个借用'ksh93'的结构.
  24 
  25 echo; echo
  26 
  27 # +=========================================================================+
  28 
  29 # 让我们使用C的逗号操作符,来同时增加两个变量的值.
  30 
  31 for ((a=1, b=1; a <= LIMIT ; a++, b++))  # 逗号将同时进行2条操作.
  32 do
  33   echo -n "$a-$b "
  34 done
  35 
  36 echo; echo
  37 
  38 exit 0
```

###### while循环

- 这种结构在循环的开头判断条件是否满足,如果条件一直满足,那就一直循环下去(0为[退出码[exit status\]](http://shouce.jb51.net/shell/exit-status.html#EXITSTATUSREF)).与[for 循环](http://shouce.jb51.net/shell/loops.html#FORLOOPREF1)的区别是,这种结构适合用在循环次数未知的情况下.

  ```
  while [condition]
  do
    command...
  done
  ```

- 简单的while循环

  ```
     1 #!/bin/bash
     2 
     3 var0=0
     4 LIMIT=10
     5 
     6 while [ "$var0" -lt "$LIMIT" ]
     7 do
     8   echo -n "$var0 "        # -n 将会阻止产生新行.
     9   #             ^           空格,数字之间的分隔.
    10 
    11   var0=`expr $var0 + 1`   # var0=$(($var0+1))  也可以.
    12                           # var0=$((var0 + 1)) 也可以.
    13                           # let "var0 += 1"    也可以.
    14 done                      # 使用其他的方法也行.
    15 
    16 echo
    17 
    18 exit 0
  ```

- 多条件的while循环

  ```
     1 #!/bin/bash
     2 
     3 var1=unset
     4 previous=$var1
     5 
     6 while echo "previous-variable = $previous"
     7       echo
     8       previous=$var1
     9       [ "$var1" != end ] # 记录之前的$var1.
    10       # 这个"while"循环中有4个条件, 但是只有最后一个能控制循环.
    11       # 退出状态由第4个条件决定.
    12 do
    13 echo "Input variable #1 (end to exit) "
    14   read var1
    15   echo "variable #1 = $var1"
    16 done  
    17 
    18 # 尝试理解这个脚本的运行过程.
    19 # 这里还是有点小技巧的.
    20 
    21 exit 0
  ```

- c风格的while循环

  ```
  
     1 #!/bin/bash
     2 # wh-loopc.sh: 循环10次的while循环.
     3 
     4 LIMIT=10
     5 a=1
     6 
     7 while [ "$a" -le $LIMIT ]
     8 do
     9   echo -n "$a "
    10   let "a+=1"
    11 done           # 到目前为止都没什么令人惊奇的地方.
    12 
    13 echo; echo
    14 
    15 # +=================================================================+
    16 
    17 # 现在, 重复C风格的语法.
    18 
    19 ((a = 1))      # a=1
    20 # 双圆括号允许赋值两边的空格,就像C语言一样.
    21 
    22 while (( a <= LIMIT ))   # 双圆括号, 变量前边没有"$".
    23 do
    24   echo -n "$a "
    25   ((a += 1))   # let "a+=1"
    26   # Yes, 看到了吧.
    27   # 双圆括号允许像C风格的语法一样增加变量的值.
    28 done
    29 
    30 echo
    31 
    32 # 现在,C程序员可以在Bash中找到回家的感觉了吧.
    33 
    34 exit 0
  
  ```

###### until

- 这个结构在循环的顶部判断条件,并且如果条件一直为false那就一直循环下去.(与while相反).

  ```
  until [condition-is-true]
  do
    command...
  done
  ```

  - 注意: until循环的判断在循环的顶部,这与某些编程语言是不同的.

    ```
       1 #!/bin/bash
       2 
       3 END_CONDITION=end
       4 
       5 until [ "$var1" = "$END_CONDITION" ]
       6 # 在循环的顶部判断条件.
       7 do
       8   echo "Input variable #1 "
       9   echo "($END_CONDITION to exit)"
      10   read var1
      11   echo "variable #1 = $var1"
      12   echo
      13 done  
      14 
      15 exit 0
    ```

    

##### 嵌套循环

- 嵌套循环就是在一个循环中还有一个循环,内部循环在外部循环体中.在外部循环的每次执行过程中都会触发内部循环,直到内部循环执行结束.外部循环执行了多少次,内部循环就完成多少次.当然,不论是外部循环或内部循环的break语句都会打断处理过程.

  ```
     1 #!/bin/bash
     2 # nested-loop.sh: 嵌套的"for" 循环.
     3 
     4 outer=1             # 设置外部循环计数.
     5 
     6 # 开始外部循环.
     7 for a in 1 2 3 4 5
     8 do
     9   echo "Pass $outer in outer loop."
    10   echo "---------------------"
    11   inner=1           # 重设内部循环的计数.
    12 
    13   # ===============================================
    14   # 开始内部循环.
    15   for b in 1 2 3 4 5
    16   do
    17     echo "Pass $inner in inner loop."
    18     let "inner+=1"  # 增加内部循环计数.
    19   done
    20   # 内部循环结束.
    21   # ===============================================
    22 
    23   let "outer+=1"    # 增加外部循环的计数.
    24   echo              # 每次外部循环之间的间隔.
    25 done               
    26 # 外部循环结束.
    27 
    28 exit 0
  ```

##### 循环控制

- **break**和**continue**这两个循环控制命令[[1\]](http://shouce.jb51.net/shell/loopcontrol.html#FTN.AEN5576)与其它语言的类似命令的行为是相同的. **break**命令将会跳出循环,continue命令将会跳过本次循环下边的语句,直接进入下次循环..
- **break**命令可以带一个参数.一个不带参数的**break**循环只能退出最内层的循环,而**break N**可以退出N层循环.
- **continue**命令也可以像**break**带一个参数.一个不带参数的**continue**命令只去掉本次循环的剩余代码.而**continue N**将会把N层循环剩余的代码都去掉,但是循环的次数不变.

##### 测试与分支case/in

- 在shell中的**case**同C/C++中的**switch**结构是相同的.它允许通过判断来选择代码块中多条路径中的一条.它的作用和多个if/then/else语句相同，是它们的简化结构，特别适用于创建目录.

  ```
  case "$variable" in
  
  "$condition1" )
  command...
  ;;
  
  "$condition2" )
  command...
  ;;
  
  esac
  ```

  - 对变量使用""并不是强制的,因为不会发生单词分离.
  - 每句测试行,都以右小括号)结尾.
  - 每个条件块都以两个分号结尾;;.
  - **case**块的结束以esac(case的反向拼写)结尾.

- c语言中文网讲述

  ```
  case expression in
      pattern1)
          statement1
          ;;
      pattern2)
          statement2
          ;;
      pattern3)
          statement3
          ;;
      ……
      *)
          statementn
  esac
  ```

  - case、in 和 esac 都是 Shell 关键字，expression 表示表达式，pattern 表示匹配模式。

    - expression 既可以是一个变量、一个数字、一个字符串，还可以是一个数学计算表达式，或者是命令的执行结果，只要能够得到 expression 的值就可以。
    - pattern 可以是一个数字、一个字符串，甚至是一个简单的正则表达式。

  - case in 的 pattern 部分支持简单的正则表达式，具体来说，可以使用以下几种格式：

    | 格式  | 说明                                                         |
    | ----- | ------------------------------------------------------------ |
    | *     | 表示任意字符串。                                             |
    | [abc] | 表示 a、b、c 三个字符中的任意一个。比如，[15ZH] 表示 1、5、Z、H 四个字符中的任意一个。 |
    | [m-n] | 表示从 m 到 n 的任意一个字符。比如，[0-9] 表示任意一个数字，[0-9a-zA-Z] 表示字母或数字。 |
    | \|    | 表示多重选择，类似逻辑运算中的或运算。比如，abc \| xyz 表示匹配字符串 "abc" 或者 "xyz"。 |

- 实例

  ```
     1 #!/bin/bash
     2 # 测试字符串范围
     3 
     4 echo; echo "Hit a key, then hit return."
     5 read Keypress
     6 
     7 case "$Keypress" in
     8   [[:lower:]]   ) echo "Lowercase letter";;
     9   [[:upper:]]   ) echo "Uppercase letter";;
    10   [0-9]         ) echo "Digit";;
    11   *             ) echo "Punctuation, whitespace, or other";;
    12 esac      #  允许字符串的范围出现在[]中,
    13           #+ 或者POSIX风格的[[中.
  ```

  ```
     1 #!/bin/bash
     2 
     3 # 未经处理的地址资料
     4 
     5 clear # 清屏.
     6 
     7 echo "          Contact List"
     8 echo "          ------- ----"
     9 echo "Choose one of the following persons:" 
    10 echo
    11 echo "[E]vans, Roland"
    12 echo "[J]ones, Mildred"
    13 echo "[S]mith, Julie"
    14 echo "[Z]ane, Morris"
    15 echo
    16 
    17 read person
    18 
    19 case "$person" in
    20 # 注意,变量是被引用的.
    21 
    22   "E" | "e" )
    23   # 接受大写或小写输入.
    24   echo
    25   echo "Roland Evans"
    26   echo "4321 Floppy Dr."
    27   echo "Hardscrabble, CO 80753"
    28   echo "(303) 734-9874"
    29   echo "(303) 734-9892 fax"
    30   echo "revans@zzy.net"
    31   echo "Business partner & old friend"
    32   ;;
    33 # 注意,在每个选项后边都需要以;;结尾.
    34 
    35   "J" | "j" )
    36   echo
    37   echo "Mildred Jones"
    38   echo "249 E. 7th St., Apt. 19"
    39   echo "New York, NY 10009"
    40   echo "(212) 533-2814"
    41   echo "(212) 533-9972 fax"
    42   echo "milliej@loisaida.com"
    43   echo "Ex-girlfriend"
    44   echo "Birthday: Feb. 11"
    45   ;;
    46 
    47 # 后边的Smith和Zane的信息在这里就省略了.
    48 
    49           * )
    50    # 默认选项.
    51    # 空输入(敲RETURN).
    52    echo
    53    echo "Not yet in database."
    54   ;;
    55 
    56 esac
    57 
    58 echo
  ```

- **select**结构是建立菜单的另一种工具,这种结构是从ksh中引入的.

  ```
  select variable [in list]
  do
  command...
  break
  done
  ```

  ```
     1 #!/bin/bash
     2 
     3 PS3='Choose your favorite vegetable: ' # 设置提示符字串.
     4 
     5 echo
     6 
     7 select vegetable in "beans" "carrots" "potatoes" "onions" "rutabagas"
     8 do
     9   echo
    10   echo "Your favorite veggie is $vegetable."
    11   echo "Yuck!"
    12   echo
    13   break  # 如果这里没有'break'会发生什么?
    14 done
    15 
    16 exit 0
  
  ```


#### I/O重定向

- 输出重定向

  - 输出重定向是指命令的结果不再输出到显示器上，而是输出到其它地方，一般是文件中。这样做的最大好处就是把命令的结果保存起来，当我们需要的时候可以随时查询。Bash 支持的输出重定向符号如下表所示。

    | 类 型                      | 符 号                                                        | 作 用                                                        |
    | -------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
    | 标准输出重定向             | command >file                                                | 以覆盖的方式，把 command 的正确输出结果输出到 file 文件中。  |
    | command >>file             | 以追加的方式，把 command 的正确输出结果输出到 file 文件中。  |                                                              |
    | 标准错误输出重定向         | command 2>file                                               | 以覆盖的方式，把 command 的错误信息输出到 file 文件中。      |
    | command 2>>file            | 以追加的方式，把 command 的错误信息输出到 file 文件中。      |                                                              |
    | 正确输出和错误信息同时保存 | command >file 2>&1                                           | 以覆盖的方式，把正确输出和错误信息同时保存到同一个文件（file）中。 |
    | command >>file 2>&1        | 以追加的方式，把正确输出和错误信息同时保存到同一个文件（file）中。 |                                                              |
    | command >file1 2>file2     | 以覆盖的方式，把正确的输出结果输出到 file1 文件中，把错误信息输出到 file2 文件中。 |                                                              |
    | command >>file1 2>>file2   | 以追加的方式，把正确的输出结果输出到 file1 文件中，把错误信息输出到 file2 文件中。 |                                                              |
    | command >file 2>file       | 【**不推荐**】这两种写法会导致 file 被打开两次，引起资源竞争，所以 stdout 和 stderr 会互相覆盖，我们将在《[结合Linux文件描述符谈重定向，彻底理解重定向的本质](http://c.biancheng.net/view/vip_3241.html)》一节中深入剖析。 |                                                              |
    | command >>file 2>>file     |                                                              |                                                              |
  
- 输入重定向

  - 输入重定向就是改变输入的方向，不再使用键盘作为命令输入的来源，而是使用文件作为命令的输入。

    | 符号                  | 说明                                                         |
    | --------------------- | ------------------------------------------------------------ |
    | command <file         | 将 file 文件中的内容作为 command 的输入。                    |
    | command <<END         | 从标准输入（键盘）中读取数据，直到遇见分界符 END 才停止（分界符可以是任意的字符串，用户自己定义）。 |
    | command <file1 >file2 | 将 file1 作为 command 的输入，并将 command 的处理结果输出到 file2。 |

  - 和输出重定向类似，输入重定向的完整写法是`fd<file`，其中 fd 表示文件描述符，如果不写，默认为 0，也就是标准输入文件。

  - 实例

    ```
    统计文档中有多少行文字。
    wc -l <readme.txt  #输入重定向
    ```

    ```
    #!/bin/bash
    
    while read str; do
        echo $str
    done <readme.txt
    
    这种写法叫做代码块重定向，也就是把一组命令同时重定向到一个文件
    ```

    ```
    统计用户在终端输入的文本的行数。
    [c.biancheng.net]$ wc -l <<END
    > 123
    > 789
    > abc
    > xyz
    > END
    4
    wc 命令会一直等待用输入，直到遇见分界符 END 才结束读取。
    ```

##### 文件描述符

- 前面提到，`>`是输出重定向符号，`<`是输入重定向符号；更准确地说，它们应该叫做文件描述符操作符。> 和 < 通过修改文件描述符改变了文件指针的指向，所以能够实现重定向的功能。

  | 分类       | 用法                                                         | 说明                                                         |
  | ---------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
  | 输出       | n>filename                                                   | 以输出的方式打开文件 filename，并绑定到文件描述符 n。n 可以不写，默认为 1，也即标准输出文件。 |
  | n>&m       | 用文件描述符 m 修改文件描述符 n，或者说用文件描述符 m 的内容覆盖文件描述符 n，结果就是 n 和 m 都代表了同一个文件，因为 n 和 m 的文件指针都指向了同一个文件。  因为使用的是`>`，所以 n 和 m 只能用作命令的输出文件。n 可以不写，默认为 1。 |                                                              |
  | n>&-       | 关闭文件描述符 n 及其代表的文件。n 可以不写，默认为 1。      |                                                              |
  | &>filename | 将正确输出结果和错误信息全部重定向到 filename。              |                                                              |
  | 输入       | n<filename                                                   | 以输入的方式打开文件 filename，并绑定到文件描述符 n。n 可以不写，默认为 0，也即标准输入文件。 |
  | n<&m       | 类似于 n>&m，但是因为使用的是`<`，所以 n 和 m 只能用作命令的输入文件。n 可以不写，默认为 0。 |                                                              |
  | n<&-       | 关闭文件描述符 n 及其代表的文件。n 可以不写，默认为 0。      |                                                              |
  | 输入和输出 | n<>filename                                                  | 同时以输入和输出的方式打开文件 filename，并绑定到文件描述符 n，相当于 n>filename 和 n<filename 的总和。。n 可以不写，默认为 0。 |

- 文件描述符 10 只用了一次，我们在末尾最好将它关闭，这是一个好习惯。

  ```
  echo "C语言中文网" 10>log.txt >&10 10>&-
  ```

  - 有些文件描述符不是很常用的，用完可以关掉，0、1、2除外。

##### exec命令操作文件描述符

- exec 是 [Shell 内置命令](http://c.biancheng.net/view/1136.html)，它有两种用法，一种是执行 Shell 命令，一种是操作文件描述符。本节只讲解后面一种，前面一种请大家自行学习。

- shell的内建命令exec将并不启动新的shell，而是用要被执行命令替换当前的shell进程，并且将老进程的环境清理掉，而且exec命令后的其它命令将不再执行。

  - 因此，如果你在一个shell里面，执行exec ls；那么，当列出了当前目录后，这个shell就自己退出了，因为这个shell进程已被替换为仅仅执行ls命令的一个进程，执行结束自然也就退出了。为了避免这个影响我们的使用，一般将exec命令放到一个shell脚本里面，用主脚本调用这个脚本，调用点处可以用bash a.sh，（a.sh就是存放该命令的脚本），这样会为a.sh建立一个sub shell去执行，当执行到exec后，该子脚本进程就被替换成了相应的exec的命令。source命令或者”.”，不会为脚本新建shell，而只是将脚本包含的命令在当前shell执行。不过，要注意一个例外，当exec命令来对文件描述符操作的时候，就不会替换shell，而且操作完成后，还会继续执行接下来的命令。
  - exec ls -al  是不需要引号的，执行exec后面输入命令就可以了,输入引号就错了

- 使用 exec 命令可以永久性地重定向，后续命令的输入输出方向也被确定了，直到再次遇到 exec 命令才会改变重定向的方向；换句话说，一次重定向，永久有效。

- 难道说我们以前使用的重定向都是临时的吗？是的！前面使用的重定向都是临时的，它们只对当前的命令有效，对后面的命令无效。

- 有些脚本文件的输出内容很多，我们不希望直接输出到显示器上，或者我们需要把输出内容备份到文件中，方便以后检索，按照以前的思路，必须在每个命令后面都使用一次重定向，写起来非常麻烦。如果以后想修改重定向的方向，那工作量也是不小的。

- exec 命令就是为解决这种困境而生的，它可以让重定向对当前 Shell 进程中的所有命令有效，它的用法为：

  ```
  exec 文件描述符操作
  ```

  ```
  [mozhiyan@localhost ~]$ echo "重定向未发生"
  重定向未发生
  [mozhiyan@localhost ~]$ exec >log.txt
  [mozhiyan@localhost ~]$ echo "c.biancheng.net"
  [mozhiyan@localhost ~]$ echo "C语言中文网"
  [mozhiyan@localhost ~]$ exec >&2
  [mozhiyan@localhost ~]$ echo "重定向已恢复"
  重定向已恢复
  [mozhiyan@localhost ~]$ cat log.txt
  c.biancheng.net
  C语言中文网
  ```

  - `exec >log.txt`将当前 Shell 进程的所有标准输出重定向到 log.txt 文件，它等价于`exec 1>log.txt`。
  - 后面的两个 echo 命令都没有在显示器上输出，而是输出到了 log.txt 文件。
  - `exec >&2`用来恢复重定向，让标准输出重新回到显示器，它等价于`exec 1>&2`。2 是标准错误输出的文件描述符，它也是输出到显示器，并且没有遭到破坏，我们用 2 来覆盖 1，就能修复 1，让 1 重新指向显示器。
  - 接下来的 echo 命令将结果输出到显示器上，证明`exec >&2`奏效了。
  - 最后我们用 cat 命令来查看 log.txt 文件的内容，发现就是中间两个 echo 命令的输出。

- 以输出重定向为例，手动恢复的方法有两种：

  - /dev/tty 文件代表的就是显示器，将标准输出重定向到 /dev/tty 即可，也就是 exec >/dev/tty。
  - 如果还有别的文件描述符指向了显示器，那么也可以别的文件描述符来恢复标号为 1 的文件描述符，例如 exec >&2。注意，如果文件描述符 2 也被重定向了，那么这种方式就无效了。

- 输入重定向的例子

  ```
  #!/bin/bash
  exec 6<&0  #先将0号文件描述符保存
  exec <nums.txt  #输入重定向
  sum=0
  while read n; do
      ((sum += n))
  done
  echo "sum=$sum"
  exec 0<&6 6<&-  #恢复输入重定向，并关闭文件描述符6
  read -p "请输入名字、网址和年龄：" name url age
  echo "$name已经$age岁了，它的网址是 $url"
  ```

##### shell组命令

- 所谓组命令，就是将多个命令划分为一组，或者看成一个整体。

- Shell 组命令的写法有两种：

  ```
  { command1; command2; command3; . . . }
  (command1; command2; command3;. . . )
  ```

  - 两种写法的区别在于：由花括号`{}`包围起来的组命名在当前 Shell 进程中执行，而由小括号`()`包围起来的组命令会创建一个子 Shell，所有命令都在子 Shell 中执行。
  - 对于第一种写法，花括号和命令之间必须有一个空格，并且最后一个命令必须用一个分号或者一个换行符结束。
  - 子 Shell 就是一个子进程，是通过当前 Shell 进程创建的一个新进程。但是子 Shell 和一般的子进程（比如`bash ./test.sh`创建的子进程）还是有差别的，我们将在《[子Shell和子进程](http://c.biancheng.net/view/vip_3248.html)》一节中深入讲解，读者暂时把子 Shell 和子进程等价起来就行。

- 组命令可以将多条命令的输出结果合并在一起，在使用重定向和管道时会特别方便。

- 例如，下面的代码将多个命令的输出重定向到 out.txt：

  ```
  ls -l > out.txt  #>表示覆盖
  echo "http://c.biancheng.net/shell/" >> out.txt  #>>表示追加
  cat readme.txt >> out.txt
  ```

  - 本段代码共使用了三次重定向。

- 借助组命令，我们可以将以上三条命令合并在一起，简化成一次重定向：

  ```
  { ls -l; echo "http://c.biancheng.net/shell/"; cat readme.txt; } > out.txt
  ```

  - 或者写作：

  ```
  (ls -l; echo "http://c.biancheng.net/shell/"; cat readme.txt) > out.txt
  ```

  - 使用组命令技术，我们节省了一些打字时间。

- 类似的道理，我们也可以将组命令和管道结合起来：

  ```
  { ls -l; echo "http://c.biancheng.net/shell/"; cat readme.txt; } | lpr
  ```

  - 这里我们把三个命令的输出结果合并在一起，并把它们用管道输送给命令 lpr 的输入，以便产生一个打印报告。

- 两种组命令的对比

  - 虽然两种 Shell 组命令形式看起来相似，它们都能用在重定向中合并输出结果，但两者之间有一个很重要的不同：由`{}`包围的组命令在当前 Shell 进程中执行，由`()`包围的组命令会创建一个子Shell，所有命令都会在这个子 Shell 中执行。
  - 在子 Shell 中执行意味着，运行环境被复制给了一个新的 shell 进程，当这个子 Shell 退出时，新的进程也会被销毁，环境副本也会消失，所以在子 Shell 环境中的任何更改都会消失（包括给变量赋值）。因此，在大多数情况下，除非脚本要求一个子 Shell，否则使用`{}`比使用`()`更受欢迎，并且`{}`的进行速度更快，占用的内存更少。

##### 代码块重定向

- 所谓代码块，就是由多条语句组成的一个整体；for、while、until 循环，或者 if...else、case...in 选择结构，或者由`{ }`包围的命令都可以称为代码块。

- 将重定向命令放在代码块的结尾处，就可以对代码块中的所有命令实施重定向。

- 使用 while 循环不断读取 nums.txt 中的数字，计算它们的总和。

  ```
  #!/bin/bash
  sum=0
  while read n; do
      ((sum += n))
  done <nums.txt  #输入重定向
  echo "sum=$sum"
  ```

- 对`{}`包围的代码使用重定向。

  ```
  #!/bin/bash
  {
      echo "C语言中文网";
      echo "http://c.biancheng.net";
      echo "7"
  } >log.txt  #输出重定向
  {
      read name;
      read url;
      read age
  } <log.txt  #输入重定向
  echo "$name已经$age岁了，它的网址是 $url"
  ```

##### Here Document

- Shell 还有一种特殊形式的重定向叫做“Here Document”，目前没有统一的翻译，你可以将它理解为“嵌入文档”“内嵌文档”“立即文档”。

- 所谓文档，就是命令需要处理的数据或者字符串；所谓嵌入，就是把数据和代码放在一起，而不是分开存放（比如将数据放在一个单独的文件中）。有时候命令需要处理的数据量很小，将它放在一个单独的文件中有点“大动干戈”，不如直接放在代码中来得方便。

- Here Document 的基本用法为：

  ```
  command <<END
    document
  END
  ```

  - `command`是 Shell 命令，`<<END`是开始标志，`END`是结束标志，`document`是输入的文档（也就是一行一行的字符串）。
  - 这种写法告诉 Shell 把 document 部分作为命令需要处理的数据，直到遇见终止符`END`为止（终止符`END`不会被读取）。
  - 注意，终止符`END`必须独占一行，并且要定顶格写。

- cat 命令一般是从文件中读取内容，并将内容输出到显示器上，借助 Here Document，cat 命令可以从键盘上读取内容。

  ```
  [mozhiyan@localhost ~]$ cat <<END
  > Shell教程
  > http://c.biancheng.net/shell/
  > 已经进行了三次改版
  > END
  Shell教程
  http://c.biancheng.net/shell/
  已经进行了三次改版
  ```

- 在脚本文件中使用 Here Document，并将 document 中的内容转换为大写。

  ```
  #!/bin/bash
  #在脚本文件中使用立即文档
  tr a-z A-Z <<END
  one two three
  Here Document
  END
  ```

- 忽略制表符

  - 默认情况下，行首的制表符也被当做正文的一部分。

  ```
  #!/bin/bash
  cat <<END
      Shell教程
      http://c.biancheng.net/shell/
      已经进行了三次改版
  END
  ```

  - 这里的制表符仅仅是为了格式对齐，我们并不希望它作为正文的一部分，为了达到这个目的，你可以在`<<`和`END`之间增加`-`，请看下面的代码：

  ```
  #!/bin/bash
  #增加了减号-
  cat <<-END
      Shell教程
      http://c.biancheng.net/shell/
      已经进行了三次改版
  END
  ```

- 忽略命令替换

  - 默认情况下，正文中出现的变量和命令也会被求值或运行，Shell 会先将它们替换以后再交给 command，请看下面的例子：

    ```
    [mozhiyan@localhost ~]$ name=C语言中文网
    [mozhiyan@localhost ~]$ url=http://c.biancheng.net
    [mozhiyan@localhost ~]$ age=7
    [mozhiyan@localhost ~]$ cat <<END
    > ${name}已经${age}岁了，它的网址是 ${url}
    > END
    C语言中文网已经7岁了，它的网址是 http://c.biancheng.net
    ```

  - 你可以将分界符用单引号或者双引号包围起来使 Shell 替换失效：

    ```
    [mozhiyan@localhost ~]$ name=C语言中文网
    [mozhiyan@localhost ~]$ url=http://c.biancheng.net
    [mozhiyan@localhost ~]$ age=7
    [mozhiyan@localhost ~]$ cat <<'END'  #使用单引号包围
    > ${name}已经${age}岁了，它的网址是 ${url}
    > END
    ${name}已经${age}岁了，它的网址是 ${url}
    ```

##### Here String

- Here String 是 [Here Document](http://c.biancheng.net/view/vip_3244.html) 的一个变种，它的用法如下：

  ```
  command <<< string
  ```

- command 是 Shell 命令，string 是字符串（它只是一个普通的字符串，并没有什么特别之处）。

  - 这种写法告诉 Shell 把 string 部分作为命令需要处理的数据。例如，将小写字符串转换为大写：

  ```
  [mozhiyan@localhost ~]$ tr a-z A-Z <<< one
  ONE
  ```

- Here String 对于这种发送较短的数据到进程是非常方便的，它比 Here Document 更加简洁。

- 一个单词不需要使用引号包围，但如果 string 中带有空格，则必须使用双引号或者单引号包围，如下所示：

  ```
  [mozhiyan@localhost ~]$ tr a-z A-Z <<< "one two three"
  ONE TWO THREE
  ```

- 双引号和单引号是有区别的，双引号会解析其中的变量（当然不写引号也会解析），单引号不会，请看下面的代码：

  ```
  [mozhiyan@localhost ~]$ var=two
  [mozhiyan@localhost ~]$ tr a-z A-Z <<<"one $var there"
  ONE TWO THERE
  [mozhiyan@localhost ~]$ tr a-z A-Z <<<'one $var there'
  ONE $VAR THERE
  [mozhiyan@localhost ~]$ tr a-z A-Z <<<one${var}there
  ONETWOTHERE
  ```

- 有了引号的包围，Here String 还可以接收多行字符串作为命令的输入，如下所示：

  ```
  [mozhiyan@localhost ~]$ tr a-z A-Z <<<"one two there
  > four five six
  > seven eight"
  ONE TWO THERE
  FOUR FIVE SIX
  SEVEN EIGHT
  ```

- 与 Here Document 相比，Here String 通常是相当方便的，特别是发送变量内容（而不是文件）到像 grep 或者 sed 这样的过滤程序时。

#### 函数

- Shell 函数的本质是一段可以重复使用的脚本代码，这段代码被提前编写好了，放在了指定的位置，使用时直接调取即可。

- Shell 函数定义的语法格式如下：

  ```
  function name() {
    statements
    [return value]
  }
  ```

  - `function`是 Shell 中的关键字，专门用来定义函数；
  - `name`是函数名；
  - `statements`是函数要执行的代码，也就是一组语句；
  - `return value`表示函数的返回值，其中 return 是 Shell 关键字，专门用在函数中返回一个值；这一部分可以写也可以不写。

- 如果你嫌麻烦，函数定义时也可以不写 function 关键字：

  ```
  name() {
    statements
    [return value]
  }
  ```

  - 如果写了 function 关键字，也可以省略函数名后面的小括号：

  ```
  function name {
    statements
    [return value]
  }
  ```

##### 函数调用

- 调用 Shell 函数时可以给它传递参数，也可以不传递。如果不传递参数，直接给出函数名字即可：

  ```
  name
  ```

  - 如果传递参数，那么多个参数之间以空格分隔：

  ```
  name param1 param2 param3
  ```

  - 不管是哪种形式，函数名字后面都不需要带括号。

  - 和其它编程语言不同的是，Shell 函数在定义时不能指明参数，但是在调用时却可以传递参数，并且给它传递什么参数它就接收什么参数。

  - Shell 也不限制定义和调用的顺序，你可以将定义放在调用的前面，也可以反过来，将定义放在调用的后面。

- 定义一个函数，计算所有参数的和：

  ```
  #!/bin/bash
  function getsum(){
      local sum=0
      for n in $@
      do
           ((sum+=n))
      done
      return $sum
  }
  getsum 10 20 55 15  #调用函数并传递参数
  echo $?
  ```

  - `$@`表示函数的所有参数，`$?`表示函数的退出状态（返回值）。

##### 函数返回值

- 在 C++、Java、C#、Python 等大部分编程语言中，返回值是指函数被调用之后，执行函数体中的代码所得到的结果，这个结果就通过 return 语句返回。

- 但是 Shell 中的返回值表示的是函数的退出状态：返回值为 0 表示函数执行成功了，返回值为非 0 表示函数执行失败（出错）了。if、while、for 等语句都是根据函数的退出状态来判断条件是否成立。

- Shell 函数的返回值只能是一个介于 0~255 之间的整数，其中只有 0 表示成功，其它值都表示失败。

- 函数执行失败时，可以根据返回值（退出状态）来判断具体出现了什么错误，比如一个打开文件的函数，我们可以指定 1 表示文件不存在，2 表示文件没有读取权限，3 表示文件类型不对。

- 如果函数体中没有 return 语句，那么使用默认的退出状态，也就是最后一条命令的退出状态。如果这就是你想要的，那么更加严谨的写法为：

  ```
  return $?
  ```

  - `$?`是一个特殊变量，用来获取上一个命令的退出状态，或者上一个函数的返回值，请猛击《[Shell $?](http://c.biancheng.net/view/808.html)》了解更多。

###### 如何得到函数的返回结果

- 有人可能会疑惑，既然 return 表示退出状态，那么该如何得到函数的处理结果呢？比如，我定义了一个函数，计算从 m 加到 n 的和，最终得到的结果该如何返回呢？

- 这个问题有两种解决方案：

  - 一种是借助全局变量，将得到的结果赋值给全局变量；
  - 一种是在函数内部使用 echo、printf 命令将结果输出，在函数外部使用`$()`或者``捕获结果。

- 下面我们具体来定义一个函数 getsum，计算从 m 加到 n 的和，并使用以上两种解决方案。

  ```
  将函数处理结果赋值给一个全局变量。
  #!/bin/bash
  sum=0  #全局变量
  function getsum(){
      for((i=$1; i<=$2; i++)); do
          ((sum+=i))  #改变全局变量
      done
      return $?  #返回上一条命令的退出状态
  }
  read m
  read n
  if getsum $m $n; then
      echo "The sum is $sum"  #输出全局变量
  else
      echo "Error!"
  fi
  这种方案的弊端是：定义函数的同时还得额外定义一个全局变量，如果我们仅仅知道函数的名字，但是不知道全局变量的名字，那么也是无法获取结果的。
  
  在函数内部使用 echo 输出结果。
  #!/bin/bash
  function getsum(){
      local sum=0  #局部变量
      for((i=$1; i<=$2; i++)); do
          ((sum+=i))
      done
     
      echo $sum
      return $?
  }
  read m
  read n
  total=$(getsum $m $n)
  echo "The sum is $total"
  #也可以省略 total 变量，直接写成下面的形式
  #echo "The sum is "$(getsum $m $n)
  ```

  - 这种方案的弊端是：如果不使用`$()`，而是直接调用函数，那么就会将结果直接输出到终端上，不过这貌似也无所谓，所以我推荐这种方案。如果使用$()来获取结果，就不会输出到终端上了。直接调用函数会。

- 总起来说，虽然C语言、C++、Java 等其它编程语言中的返回值用起来更加方便，但是 Shell 中的返回值有它独特的用途，所以不要带着传统的编程思维来看待 Shell 函数的返回值。

#### read命令

- read 是 [Shell 内置命令](http://c.biancheng.net/view/1136.html)，用来从标准输入中读取数据并赋值给变量。如果没有进行重定向，默认就是从键盘读取用户输入的数据；如果进行了重定向，那么可以从文件中读取数据。

- read 命令的用法为：

  ```
  read [-options] [variables]
  ```

  - `options`表示选项，如下表所示；`variables`表示用来存储数据的变量，可以有一个，也可以有多个。

  - `options`和`variables`都是可选的，如果没有提供变量名，那么读取的数据将存放到环境变量 REPLY 中。

    | 选项         | 说明                                                         |
    | ------------ | ------------------------------------------------------------ |
    | -a array     | 把读取的数据赋值给数组 array，从下标 0 开始。                |
    | -d delimiter | 用字符串 delimiter 指定读取结束的位置，而不是一个换行符（读取到的数据不包括 delimiter）。 |
    | -e           | 在获取用户输入的时候，对功能键进行编码转换，不会直接显式功能键对应的字符。 |
    | -n num       | 读取 num 个字符，而不是整行字符。                            |
    | -p prompt    | 显示提示信息，提示内容为 prompt。                            |
    | -r           | 原样读取（Raw mode），不把反斜杠字符解释为转义字符。         |
    | -s           | 静默模式（Silent mode），不会在屏幕上显示输入的字符。当输入密码和其它确认信息的时候，这是很有必要的。 |
    | -t seconds   | 设置超时时间，单位为秒。如果用户没有在指定时间内输入完成，那么 read 将会返回一个非 0 的退出状态，表示读取失败。 |
    | -u fd        | 使用文件描述符 fd 作为输入源，而不是标准输入，类似于重定向。 |

- 实例

  ```
  使用 read 命令给多个变量赋值。
  #!/bin/bash
  read -p "Enter some information > " name url age
  echo "网站名字：$name"
  echo "网址：$url"
  echo "年龄：$age"
  注意，必须在一行内输入所有的值，不能换行，否则只能给第一个变量赋值，后续变量都会赋值失败。
  本例还使用了-p选项，该选项会用一段文本来提示用户输入。
  
  只读取一个字符。
  #!/bin/bash
  read -n 1 -p "Enter a char > " char
  printf "\n"  #换行
  echo $char
  -n 1表示只读取一个字符。运行脚本后，只要用户输入一个字符，立即读取结束，不用等待用户按下回车键。
  printf "\n"语句用来达到换行的效果，否则 echo 的输出结果会和用户输入的内容位于同一行，不容易区分。
  
  
  在指定时间内输入密码。
  #!/bin/bash
  if
      read -t 20 -sp "Enter password in 20 seconds(once) > " pass1 && printf "\n" &&  #第一次输入密码
      read -t 20 -sp "Enter password in 20 seconds(again)> " pass2 && printf "\n" &&  #第二次输入密码
      [ $pass1 == $pass2 ]  #判断两次输入的密码是否相等
  then
      echo "Valid password"
  else
      echo "Invalid password"
  fi
  这段代码中，我们使用&&组合了多个命令，这些命令会依次执行，并且从整体上作为 if 语句的判断条件，只要其中一个命令执行失败（退出状态为非 0 值），整个判断条件就失败了，后续的命令也就没有必要执行了。
  ```


#### 进程替换

- 进程替换和命令替换非常相似。[命令替换](http://c.biancheng.net/view/1164.html)是把一个命令的输出结果赋值给另一个变量，例如`dir_files=`ls -l``或`date_time=$(date)`；而进程替换则是把一个命令的输出结果传递给另一个（组）命令。

- 为了说明进程替换的必要性，我们先来看一个使用管道的例子：

  ```
  echo "http://c.biancheng.net/shell/" | read echo $REPLY
  ```

  - 以上代码输出结果总是为空，因为 echo 命令在父 Shell 中执行，而 read 命令在子 Shell 中执行，当 read 执行结束时，子 Shell 被销毁，REPLY 变量也就消失了。管道中的命令总是在子 Shell 中执行的，任何给变量赋值的命令都会遭遇到这个问题。
  - 使用 read 读取数据时，如果没有提供变量名，那么读取到的数据将存放到环境变量 REPLY 中，这一点已在《[Shell read](http://c.biancheng.net/view/2991.html)》中讲到。

- 幸运的是，Shell 提供了一种“特异功能”，叫做进程替换，它可以用来解决这种麻烦。

- Shell 进程替换有两种写法，一种用来产生标准输出，借助输入重定向，它的输出结果可以作为另一个命令的输入：

  ```
  <(commands)
  ```

  - 另一种用来接受标准输入，借助输出重定向，它可以接收另一个命令的输出结果：

  ```
  >(commands)
  ```

  - commands 是一组命令列表，多个命令之间以分号`;`分隔。注意，`<`或`>`与圆括号之间是没有空格的。

- 例如，为了解决上面遇到的问题，我们可以像下面这样使用进程替换：

  ```
  read < <(echo "http://c.biancheng.net/shell/")
  echo $REPLY
  ```

  - 整体上来看，Shell 把`echo "http://c.biancheng.net/shell/"`的输出结果作为 read 的输入。`<()`用来捕获 echo 命令的输出结果，`<`用来将该结果重定向到 read。
  - 注意，两个`<`之间是有空格的，第一个`<`表示输入重定向，第二个`<`和`()`连在一起表示进程替换。
  - 本例中的 read 命令和第二个 echo 命令都在当前 Shell 进程中运行，读取的数据也会保存到当前进程的 REPLY 变量，大家都在一个进程中，所以使用 echo 能够成功输出。
  - 而在前面的例子中我们使用了管道，echo 命令在父进程中运行，read 命令在子进程中运行，读取的数据也保存在子进程的 REPLY 变量中，echo 命令和 REPLY 变量不在一个进程中，而子进程的环境变量对父进程是不可见的，所以读取失败。

- 再来看一个进程替换用作「接受标准输入」的例子：

  ```
  echo "C语言中文网" > >(read; echo "你好，$REPLY")
  
  运行结果：
  你好，C语言中文网
  
  因为使用了重定向，read 命令从`echo "C语言中文网"`的输出结果中读取数据。
  ```

###### shell进程替换本质

- 为了能够在不同进程之间传递数据，实际上进程替换会跟系统中的文件关联起来，这个文件的名字为`/dev/fd/n`（n 是一个整数）。该文件会作为参数传递给`()`中的命令，`()`中的命令对该文件是读取还是写入取决于进程替换格式是`<`还是`>`：

  - 如果是`>()`，那么该文件会给`()`中的命令提供输入；借助输出重定向，要输入的内容可以从其它命令而来。
  - 如果是`<()`，那么该文件会接收`()`中命令的输出结果；借助输入重定向，可以将该文件的内容作为其它命令的输入。

- 使用 echo 命令可以查看进程替换对应的文件名：

  ```
  [c.biancheng.net]$ echo >(true)
  /dev/fd/63
  [c.biancheng.net]$ echo <(true)
  /dev/fd/63
  [c.biancheng.net]$ echo >(true) <(true)
  /dev/fd/63 /dev/fd/62
  ```

  - `/dev/fd/`目录下有很多序号文件，进程替换一般用的是 63 号文件，该文件是系统内部文件，我们一般查看不到。

#### 子shell和子进程

- Shell 中有很多方法产生子进程，比如以新进程的方式运行 Shell 脚本，使用组命令、管道、命令替换等，但是这些子进程是有区别的。
- 子进程的概念是由父进程的概念引申而来的。在 Linux 系统中，系统运行的应用程序几乎都是从 init（pid为 1 的进程）进程派生而来的，所有这些应用程序都可以视为 init 进程的子进程，而 init 则为它们的父进程。
- Shell 脚本是从上至下、从左至右依次执行的，即执行完一个命令之后再执行下一个。如果在 Shell 脚本中遇到子脚本（即脚本嵌套，但是必须以新进程的方式运行）或者外部命令，就会向系统内核申请创建一个新的进程，以便在该进程中执行子脚本或者外部命令，这个新的进程就是子进程。子进程执行完毕后才能回到父进程，才能继续执行父脚本中后续的命令及语句。
- 了解 Linux 编程的读者应该知道，使用 fork() 函数可以创建一个子进程；除了 PID（进程ID）等极少的参数不同外，子进程的一切都来自父进程，包括代码、数据、堆栈、打开的文件等，就连代码的执行位置（状态）都是一样的。
- 也就是说，fork() 克隆了一个一模一样的自己，身高、体重、颜值、嗓音、年龄等各种属性都相同。当然，后期随着各自的发展轨迹不同，两者会变得不一样，比如 A 好吃懒做越来越肥，B 经常健身成了一个肌肉男；但是在 fork() 出来的那一刻，两者都是一样的。
- Linux 还有一种创建子进程的方式，就是子进程被 fork() 出来以后立即调用 exec() 函数加载新的可执行文件，而不使用从父进程继承来的一切。什么意思呢？
- 比如在 ~/bin 目录下有两个可执行文件分别叫 a.out 和 b.out。现在我运行 a.out，就会产生一个进程，比如叫做 A。在进程 A 中我又调用 fork() 函数创建了一个进程 B，那么 B 就是 A 的子进程，此时它们是一模一样的。但是，我调用 fork() 后立即又调用 exec() 去加载 b.out，这可就坏事了，B 进程中的一切（包括代码、数据、堆栈等）都会被销毁，然后再根据 b.out 重建建立一切。这样一折腾，B 进程除了 ID 没有变，其它的都变了，再也没有属于 A 的东西了。
- 你看，同样是创建子进程，但是结果却大相径庭：
  - 第一种只使用 fork() 函数，子进程和父进程几乎是一模一样的，父进程中的函数、变量、别名等在子进程中仍然有效。
  - 第二种使用 fork() 和 exec() 函数，子进程和父进程之间除了硬生生地维持一种“父子关系”外，再也没有任何联系了，它们就是两个完全不同的程序。
- 对于 Shell 来说，以新进程的方式运行脚本文件，比如`bash ./test.sh`、`chmod +x ./test.sh; ./test.sh`，或者在当前 Shell 中使用 bash 命令启动新的 Shell，它们都属于第二种创建子进程的方式，所以子进程除了能继承父进程的环境变量外，基本上也不能使用父进程的什么东西了，比如，父进程的全局变量、局部变量、文件描述符、别名等在子进程中都无效。
- 但是，组命令、命令替换、管道这几种语法都使用第一种方式创建进程，所以子进程可以使用父进程的一切，包括全局变量、局部变量、别名等。我们将这种子进程称为**子 Shell（sub shell）**。
- 子 Shell 虽然能使用父 Shell 的的一切，但是如果子 Shell 对数据做了修改，比如修改了全局变量，那么这种修改只能停留在子 Shell，无法传递给父 Shell。不管是子进程还是子 Shell，都是“传子不传父”。

  ```
  a=1
  (a=2)
  echo $a
  
  结果输出1
  ```

  - 验证了上面的说法，子shell对全局变量的修改只停留在子shell，应该是子shell里面拷贝了一份，所以父shell应该不会变。

###### 如何检测子shell和子进程

- 我们都知道使用 $ 变量可以获取当前进程的 ID，我在父 Shell 和子 Shell 中都输出 $ 的值，只要它们不一样，不就是创建了一个新的进程吗？那我们就来试一下吧。

  ```
  [mozhiyan@localhost ~]$ echo $$  #父Shell PID
  3299
  [mozhiyan@localhost ~]$ (echo $$)  #组命令形式的子Shell PID
  3299
  [mozhiyan@localhost ~]$ echo "http://c.biancheng.net" | { echo $$; }  #管道形式的子Shell PID
  3299
  [mozhiyan@localhost ~]$ read < <(echo $$)  #进程替换形式的子Shell PID
  [mozhiyan@localhost ~]$ echo $REPLY
  3299
  ```

  - 你看，子 Shell 和父 Shell 的 ID 都是一样的，哪有产生新进程了？作者你是不是骗人呢？

  - 其实不是我骗人，而是你掉坑里了，因为 $ 变量在子 Shell 中无效！Base 官方文档说，在普通的子进程中，$ 确实被展开为子进程的 ID；但是在子 Shell 中，$ 却被展开成父进程的 ID。

- 除了 $，Bash 还提供了另外两个环境变量——SHLVL 和 BASH_SUBSHELL，用它们来检测子 Shell 非常方便。

- SHLVL 是记录多个 Bash 进程实例嵌套深度的累加器，每次进入一层普通的子进程，SHLVL 的值就加 1。而 BASH_SUBSHELL 是记录一个 Bash 进程实例中多个子 Shell（sub shell）嵌套深度的累加器，每次进入一层子 Shell，BASH_SUBSHELL 的值就加 1。

- 我们还是用实例来说话吧，先说 SHLVL。创建一个脚本文件，命名为 test.sh，内容如下：

  ```
  #!/bin/bash
  echo "$SHLVL  $BASH_SUBSHELL"
  ```

  然后打开 Shell 窗口，依次执行下面的命令：

  ```
  [mozhiyan@localhost ~]$ echo "$SHLVL  $BASH_SUBSHELL"
  2  0
  [mozhiyan@localhost ~]$ bash  #执行bash命令开启一个新的Shell会话
  [mozhiyan@localhost ~]$ echo "$SHLVL  $BASH_SUBSHELL"
  3  0
  [mozhiyan@localhost ~]$ bash ./test.sh  #通过bash命令运行脚本
  4  0
  [mozhiyan@localhost ~]$ echo "$SHLVL  $BASH_SUBSHELL"
  3  0
  [mozhiyan@localhost ~]$ chmod +x ./test.sh  #给脚本增加执行权限
  [mozhiyan@localhost ~]$ ./test.sh
  4  0
  [mozhiyan@localhost ~]$ echo "$SHLVL  $BASH_SUBSHELL"
  3  0
  [mozhiyan@localhost ~]$ exit  #退出内层Shell
  exit
  [mozhiyan@localhost ~]$ echo "$SHLVL  $BASH_SUBSHELL"
  2  0
  ```

  - SHLVL 和 BASH_SUBSHELL 的初始值都是 0，但是输出结果中 SHLVL 的值从 2 开始，我猜测 Bash 在初始化阶段可能创建了子进程，我们暂时不用理会它，将关注点放在值的变化上。
  - 仔细观察的读者应该会发现，使用 bash 命令开启新的会话后，需要使用 exit 命令退出才能回到上一级 Shell 会话。
  - `bash ./test.sh`和`chmod +x ./test.sh; ./test.sh`这两种运行脚本的方式，在脚本运行期间会开启一个子进程，运行结束后立即退出子进程。

- 再说一下 BASH_SUBSHELL，请看下面的命令：

  ```
  [mozhiyan@localhost ~]$ echo "$SHLVL  $BASH_SUBSHELL"
  2  0
  [mozhiyan@localhost ~]$ (echo "$SHLVL  $BASH_SUBSHELL")  #组命令
  2  1
  [mozhiyan@localhost ~]$ echo "hello" | { echo "$SHLVL  $BASH_SUBSHELL"; }  #管道
  2  1
  [mozhiyan@localhost ~]$ var=$(echo "$SHLVL  $BASH_SUBSHELL")  #命令替换
  [mozhiyan@localhost ~]$ echo $var
  2 1
  [mozhiyan@localhost ~]$ ( ( ( (echo "$SHLVL  $BASH_SUBSHELL") ) ) )  #四层组命令
  2  4
  ```

  - 你看，组命令、管道、命令替换这几种写法都会进入子 Shell。

- 注意，“进程替换”看起来好像产生了一个子 Shell，其实只是玩了一个障眼法而已。进程替换只是借助文件在`()`内部和外部的命令之间传递数据，但是它并没有创建子 Shell；换句话说，`()`内部和外部的命令是在一个进程（也就是当前进程）中执行的。

#### 正则表达式

- Bash本身没有正则表达式的功能.在脚本里，使用正则表达式的是命令和软件包 -- 例如[sed](http://shouce.jb51.net/shell/sedawk.html#SEDREF)和[awk](http://shouce.jb51.net/shell/awk.html#AWKREF) -- 它们可以解释正则表达式.

- Bash所做的是展开文件名扩展 [[1\]](http://shouce.jb51.net/shell/globbingref.html#FTN.AEN13843) -- 这就是所谓的通配*(globbing*) -- 但它不是使用标准的正则表达式. 而是使用通配符. 通配解释标准的通配符：\*和?, 方括号括起来的字符,还有其他的一些特殊的字符(比如说^用来表示取反匹配).然而通配机制的通配符有很大的局限性. 包含有*号的字符串将不会匹配以点开头的文件，例如`.bashrc`. [[2\]](http://shouce.jb51.net/shell/globbingref.html#FTN.AEN13856) 另外,通配机制的`*?*` 字符和正则表达式中表示的意思不一样.

  - 意思是说bash本身并不是用的标准的正则表达式，而是直接使用的通配符机制。只是用来扩展用的。

- 文件名扩展*意思是扩展包含有特殊字符的文件名模式和模板. 例如，`example.???`可能扩展成`example.001`和/或`example.txt`.

- 在此需要注意的是命令里面使用的正则表达式和bash里面用的符号不是同一个东西，一个是标准的正则，一个是文件名展开的工作。

- 如果 Bash 中没有设置 -f 选项，就会支持文件名扩展。Bash 支持以下三种通配符来实现文件名扩展：

  ```
  *匹配任何字符串，包括空字符串。
  ? 匹配任意单个字符。
  [...] 匹配方括号内的任意字符。任意一个字符
  ```
  
  - 常用的是这三个，并不是只有这三个。

###### 正则表达式遗忘的东西

- 正则表达式\w含义

  ```
  匹配字母、数字、下划线。等价于 [A-Za-z0-9_]
  ```

  - 这是一个具体的意思，正则表达式就是这样规定的。sed也是这样用的

  - sed中使用的是`\w\+`
  - 例如\d匹配数字，这些是perl正则表达式，每一种语言都有自己的正则表达式语法，sed估计支持很多种语法，我们常用的是bash，但是sed也支持其他的，所以不能直观的认为只有bash的才支持。

###### 通配符和正则表达式

- 通配符是shell在做PathnameExpansion时用到的。说白了一般只用于文件名匹配，它是由shell解析的，比如find，ls，cp，mv等。

- case分支中支持的也是通配符

- [正则表达式](https://so.csdn.net/so/search?q=正则表达式&spm=1001.2101.3001.7020)是用来匹配字符串的，针对文件内容的文本过滤工具里，大都用到正则表达式，如vi，grep，awk，sed等。

- 通配符和正则表达式看起来有点像，不能混淆。可以简单的理解为通配符只有*,?,[],{}这4种，而正则表达式复杂多了。

  - `{...}` 表示匹配大括号里面的所有模式，模式之间使用逗号分隔。

    ```
    $ echo d{a,e,i,u,o}g
    dag deg dig dug dog
    
    它可以用于多字符的模式。
    $ echo {cat,dog}
    cat dog
    ```

  - `{...}`与`[...]`有一个很重要的区别。如果匹配的文件不存在，`[...]`会失去模式的功能，变成一个单纯的字符串，而`{...}`依然可以展开。

    ```
    # 不存在 a.txt 和 b.txt
    $ ls [ab].txt
    ls: [ab].txt: No such file or directory
    
    $ ls {a,b}.txt
    ls: a.txt: No such file or directory
    ls: b.txt: No such file or directory
    
    上面代码中，如果不存在a.txt和b.txt，那么[ab].txt就会变成一个普通的文件名，而{a,b}.txt可以照样展开。
    ```

    - 所以mv test{,_bak}，这个通配符可以扩展为mv test test_bak.

  - 大括号可以嵌套

    ```
    $ echo {j{p,pe}g,png}
    jpg jpeg png
    
    大括号也可以与其他模式联用。
    $ echo {cat,d*}
    cat dawg dg dig dog doug dug
    上面代码中，会先进行大括号扩展，然后进行*扩展。
    ```

- \*在通配符和正则表达式中有其不一样的地方，在通配符中\*可以匹配任意的0个或多个字符，而在正则表达式中他是重复之前的一个或者多个字符，不能独立使用的。比如通配符可以用*来匹配任意字符，而正则表达式不行，他只匹配任意长度的前面的字符。


###### 不同的正则表达式

- [不同的正则POSIX和PCRE](https://zhuanlan.zhihu.com/p/435815082)

- 80年代，POSIX (Portable Operating System Interface) 标准公诸于世，它制定了不同的操作系统都需要遵守的一套规则，其中就包括正则表达式的规则。遵循POSIX规则的正则表达式，称为POSIX派系的正则表达式。Unix 系统或类Unix系统上的大部分工具，如grep 、sed 、awk等都属于POSIX派系。

- 90年代，随着Perl语言的发展，它的正则表达式功能越来越强悍。为了把Perl语言中正则的功能移植到其他语言中，PCRE（Perl Compatible Regular Expressions）派系的正则表达式也诞生了。现代编程语言如Python ，Ruby ，PHP ，C / C++ ，Java 等正则表达式，大部分都属于PCRE派系。

- POSIX派系是遵循POSIX规则的正则表达式其中代表软件有：grep ，sed和awk等

- POSIX派系分为两种标准：

  1. BRE标准（Basic Regular Expression基本正则表达式）
  2. ERE标准（Extended Regular Expression扩展正则表达式）

  ![](https://pic4.zhimg.com/80/v2-2f07c9418bd24024153a1713be309acb_1440w.jpg)

  - 是不是很难找到两者的差别点呢？仔细留意一下，第 3，4，5，7 行的内容，我们能发现，如果使用BRE标准，需要对[],(),|符号进行转义。作者看来ERE实际上是BRE的一个扩展标准，开发者使用ERE能书写更简单的正则表达式，不需要对某些字符进行特殊转义。

- POSIX派系有自己的字符组，叫POSIX字符组，具体解释如下所示：

  |    字符类    |                           作用                           |
  | :----------: | :------------------------------------------------------: |
  | `[:alnum:]`  |                    任何一个字母或数字                    |
  | `[:alpha:]`  |                       任何一个字母                       |
  | `[:blank:]`  |                       空格或制表符                       |
  | `[:cntrl:]`  |             ASCII 控制字符(ASCII 0-31, 127)              |
  | `[:digit:]`  |                       任何一个数字                       |
  | `[:graph:]`  |            和 `[:print:]` 一样, 但不包括空格             |
  | `[:lower:]`  |                     任何一个小写字母                     |
  | `[:print:]`  |                    任何一个可打印字符                    |
  | `[:punct:]`  | 既不属于 `[:alnum:]` 也不属于 `[:cntrl:]` 的任何一个字符 |
  | `[:space:]`  |                任何一个空白字符, 包括空格                |
  | `[:upper:]`  |                     任何一个大写字符                     |
  | `[:xdigit:]` |                   任何一个十六进制数字                   |

- PCRE特性

  - 更易用相对于POSIX派系的BRE标准，不需要使用\进行转义例如：在多选分支结构直接使用|即可（1|2表达1或者2）
  - 更简洁在兼容POSIX字符组的基础上还支持更简洁的写法：例如：\w等价于[[:word:]]，\d等价于[[:digit:]]
  - 更多功能例如：Look-around（环顾断言），Non-capturing Group（非捕获组），non-greedy（非贪婪）等。

- 正因为PCRE与POSIX相比，PCRE使用起来更加易用简洁（不需要转义，有更简洁字符组），功能更加丰富（非捕获组，环顾断言，非贪婪）。如果没有特殊原因，应尽可能使用PCRE派系，让正则匹配的结果更符合我们预期。

  <img src="https://pic1.zhimg.com/80/v2-c94209c310462df0cbad03d1a167a314_1440w.jpg" style="zoom:50%;" />

- 在 **BRE** 和 **ERE** 环境中，是不存在诸如 `\d`, `\s` 的特殊元字符的，就算有，那也应该是那个工具提供的额外扩展。下面这些基本上也可以看作是目前通用的，一些工具进行了扩展。

  <img src="https://pic4.zhimg.com/80/v2-757482a91dfb15922182d5b4a1f8cdc3_1440w.jpg" style="zoom:50%;" />

<img src="https://pic4.zhimg.com/80/v2-ed96a58c22461288729c1c393f7fd9c7_1440w.jpg" style="zoom:50%;" />

- 非贪婪表示在满足匹配时，匹配尽可能短的字符串，使用？来表示非贪婪匹配。例如上面图中所示，在量词后面加一个问号？就是非贪婪模式。

#### 数组

- 和其他编程语言一样，Shell 也支持数组。数组（Array）是若干数据的集合，其中的每一份数据都称为元素（Element）。
- Shell 并且没有限制数组的大小，理论上可以存放无限量的数据。和 [C++](http://c.biancheng.net/cplus/)、[Java](http://c.biancheng.net/java/)、[C#](http://c.biancheng.net/csharp/) 等类似，Shell 数组元素的下标也是从 0 开始计数。
- 获取数组中的元素要使用下标`[ ]`，下标可以是一个整数，也可以是一个结果为整数的表达式；当然，下标必须大于等于 0。
- 遗憾的是，常用的 Bash Shell 只支持一维数组，不支持多维数组。

##### 数组的定义

- 在 Shell 中，用括号`( )`来表示数组，数组元素之间用空格来分隔。由此，定义数组的一般形式为：

  ```
  array_name=(ele1  ele2  ele3 ... elen)
  ```

  - 注意，赋值号`=`两边不能有空格，必须紧挨着数组名和数组元素。

- 下面是一个定义数组的实例：

  ```
  nums=(29 100 13 8 91 44)
  ```

- Shell 是弱类型的，它并不要求所有数组元素的类型必须相同，例如：

```
arr=(20 56 "http://c.biancheng.net/shell/")
```

- 第三个元素就是一个“异类”，前面两个元素都是整数，而第三个元素是字符串。

- Shell 数组的长度不是固定的，定义之后还可以增加元素。例如，对于上面的 nums 数组，它的长度是 6，使用下面的代码会在最后增加一个元素，使其长度扩展到 7：

```
nums[6]=88
```

- 此外，你也无需逐个元素地给数组赋值，下面的代码就是只给特定元素赋值：

```
ages=([3]=24 [5]=19 [10]=12)
```

- 以上代码就只给第 3、5、10 个元素赋值，所以数组长度是 3。
- 数组可以是稀疏的，并不是每一个元素都需要挨着。

##### 获取数组元素

- 获取数组元素的值，一般使用下面的格式：

  ```
  ${array_name[index]}
  ```

  其中，array_name 是数组名，index 是下标。例如：

  ```
  n=${nums[2]}
  ```

  表示获取 nums 数组的第二个元素，然后赋值给变量 n。再如：

  ```
  echo ${nums[3]}
  ```

  表示输出 nums 数组的第 3 个元素。

  使用`@`或`*`可以获取数组中的所有元素，例如：

  ```
  ${nums[*]}
  ${nums[@]}
  ```

  两者都可以得到 nums 数组的所有元素。

- 上面获取到数组的所有元素之后，我们就可以直接使用for循环来使用这些元素，因为获取到的所有元素都是以空格区分的。

  ```
  #!/bin/bash
  nums=(29 100 13 8 91 44)
  echo ${nums[@]}  #输出所有数组元素
  nums[10]=66  #给第10个元素赋值（此时会增加数组长度）
  echo ${nums[*]}  #输出所有数组元素
  echo ${nums[4]}  #输出第4个元素
  
  运行结果：
  29 100 13 8 91 44
  29 100 13 8 91 44 66
  91
  ```

##### 获取数组长度

```
所谓数组长度，就是数组元素的个数。

利用@或*，可以将数组扩展成列表，然后使用#来获取数组元素的个数，格式如下：
${#array_name[@]}
${#array_name[*]}

其中 array_name 表示数组名。两种形式是等价的，选择其一即可。

如果某个元素是字符串，还可以通过指定下标的方式获得该元素的长度，如下所示：
${#arr[2]}

获取 arr 数组的第 2 个元素（假设它是字符串）的长度。
回忆字符串长度的获取
回想一下 Shell 是如何获取字符串长度的呢？其实和获取数组长度如出一辙，它的格式如下：
${#string_name}

string_name 是字符串名。
```

```
#!/bin/bash
nums=(29 100 13)
echo ${#nums[*]}
#向数组中添加元素
nums[10]="http://c.biancheng.net/shell/"
echo ${#nums[@]}
echo ${#nums[10]}
#删除数组元素
unset nums[1]
echo ${#nums[*]}

3
4
29
3
```

##### 数组拼接

```
所谓 Shell 数组拼接（数组合并），就是将两个数组连接成一个数组。

拼接数组的思路是：先利用@或*，将数组扩展成列表，然后再合并到一起。具体格式如下：
array_new=(${array1[@]}  ${array2[@]})
array_new=(${array1[*]}  ${array2[*]})

两种方式是等价的，选择其一即可。其中，array1 和 array2 是需要拼接的数组，array_new 是拼接后形成的新数组。
```

```
#!/bin/bash
array1=(23 56)
array2=(99 "http://c.biancheng.net/shell/")
array_new=(${array1[@]} ${array2[*]})
echo ${array_new[@]}  #也可以写作 ${array_new[*]}

23 56 99 http://c.biancheng.net/shell/
```

##### 删除数组

```
在 Shell 中，使用 unset 关键字来删除数组元素，具体格式如下：
unset array_name[index]

其中，array_name 表示数组名，index 表示数组下标。

如果不写下标，而是写成下面的形式：
unset array_name

那么就是删除整个数组，所有元素都会消失。
```

##### 关联数组

- 现在最新的 Bash Shell 已经支持关联数组了。关联数组使用字符串作为下标，而不是整数，这样可以做到见名知意。

- 关联数组也称为“键值对（key-value）”数组，键（key）也即字符串形式的数组下标，值（value）也即元素值。

- 例如，我们可以创建一个叫做 color 的关联数组，并用颜色名字作为下标。

  ```
  declare -A color
  color["red"]="#ff0000"
  color["green"]="#00ff00"
  color["blue"]="#0000ff"
  ```

  - 也可以在定义的同时赋值：

    ```
    declare -A color=(["red"]="#ff0000", ["green"]="#00ff00", ["blue"]="#0000ff")
    ```

  - 不同于普通数组，关联数组必须使用带有`-A`选项的 declare 命令创建。

###### 访问关联数组

```
访问关联数组元素的方式几乎与普通数组相同，具体形式为：
array_name["index"]

例如：
color["white"]="#ffffff"
color["black"]="#000000"

加上$()即可获取数组元素的值：
$(array_name["index"])

例如：
echo $(color["white"])
white=$(color["black"])
```

###### 获取所有元素的下标和值

```
使用下面的形式可以获得关联数组的所有元素值：
${array_name[@]}
${array_name[*]}

使用下面的形式可以获取关联数组的所有下标值：
${!array_name[@]}
${!array_name[*]}
```

###### 获取关联数组长度

```
使用下面的形式可以获得关联数组的长度：
${#array_name[*]}
${#array_name[@]}
```



#### trap命令

- 当我们设计一个大且复杂的脚本时，考虑到当脚本运行时出现用户退出或系统关机会发生什么是很重要的。当这样的事件发生时，一个信号将会发送到所有受影响的进程。相应地，这些进程的程序可以采取一些措施以确保程序正常有序地终结。比如说，我们编写了一个会在执行时生成临时文件的脚本。在好的设计过程中，我们会让脚本在执行完成时删除这些临时文件。同样聪明的做法是，如果脚本接收到了指示程序将提前结束的信号，也应删除这些临时文件。

- Bash Shell 的内部命令 trap 让我们可以在 Shell 脚本内捕获特定的信号并对它们进行处理。 trap 命令的语法如下所示：

  ```
  trap command signal [ signal ... ]
  ```

  - 上述语法中，command 可以是一个脚本或是一个函数。signal 既可以用信号名，也可以用信号值指定。
  - 当 Shell 收到信号 signal(s) 时，command 将被读取和执行。比如，如果 signal 是 0 或 EXIT 时，command 会在 Shell 退出时被执行。如果 signal 是 DEBUG 时，command 会在每个命令后被执行。
  - signal 也可以被指定为 ERR，那么每当一个命令以非 0 状态退出时， command 就会被执行（注意，当非 0 退出状态来自一个 if 语句部分，或来自 while、until 循环时，command 不会被执行）。

- 有时，接收到一个信号后你可能不想对其做任何处理。比如，当你的脚本处理较大的文件时，你可能希望阻止一些错误地输入 Ctrl+C 或 Ctrl+\ 组合键的做法，并且希望它能执行完成而不被用户中断。这时就可以使用空字符串`" "`或`' '`作为 trap 的命令参数，那么 Shell 将忽略这些信号。其用法类似如下所示：

  ```
  $ trap ' ' SIGHUP SIGINT [ signal... ]
  ```

- 如果我们在脚本中应用了捕获，我们通常会在脚本的结尾处，将接收到信号时的行为处理重置为默认模式。重置（移除）捕获的语法如下所示：

  ```
  $ trap - signal [ signal ... ]
  ```

  - 从上述语法中可以看出，使用破折号作为 trap 语句的命令参数，就可以移除信号的捕获。

- 捕获信号之后，如果没有移除捕获，这个捕获会一直应用到最后，只要捕获到信号就执行命令。不管多少次。

#### shell模块化

- 所谓模块化，就是把代码分散到多个文件或者文件夹。对于大中型项目，模块化是必须的，否则会在一个文件中堆积成千上万行代码，这简直是一种灾难。

- 基本上所有的编程语言都支持模块化，以达到代码复用的效果，比如，Java 和 Python 中有 import，C/C++ 中有 #include。在 Shell 中，我们可以使用 source 命令来实现类似的效果。

  ```
  source 命令的用法为：
  source filename
  
  也可以简写为：
  . filename
  
  两种写法的效果相同。对于第二种写法，注意点号.和文件名中间有一个空格。
  ```

  - source 是 [Shell 内置命令](http://c.biancheng.net/view/1136.html)的一种，它会读取 filename 文件中的代码，并依次执行所有语句。你也可以理解为，source 命令会强制执行脚本文件中的全部命令，而忽略脚本文件的权限。

- 创建两个脚本文件 func.sh 和 main.sh：func.sh 中包含了若干函数，main.sh 是主文件，main.sh 中会包含 func.sh。

  ```
  func.sh 文件内容：
  #计算所有参数的和
  function sum(){
      local total=0
      for n in $@
      do
           ((total+=n))
      done
      echo $total
      return 0
  }
  
  main.sh 文件内容：
  #!/bin/bash
  source func.sh
  echo $(sum 10 20 55 15)
  
  运行 main.sh，输出结果为：
  100
  
  source 后边可以使用相对路径，也可以使用绝对路径，这里我们使用的是相对路径。
  ```

  - 这就相当于代码分散开来不是很长了，相当于在另一个文件中放入了一些代码，在使用的时候直接引入引来我们可以执行使用。这个和直接执行另一个脚本文件有本质的区别，执行脚本文件是起一个进程来运行这个脚本，模块化是分散代码，避免一个文件很大。

###### 避免重复引入

- 熟悉 C/C++ 的读者都知道，C/C++ 中的头文件可以避免被重复引入；换句话说，即使被多次引入，效果也相当于一次引入。这并不是 #include 的功劳，而是我们在头文件中进行了特殊处理。
- Shell source 命令和 C/C++ 中的 #include 类似，都没有避免重复引入的功能，只要你使用一次 source，它就引入一次脚本文件中的代码。
- 那么，在 Shell 中究竟该如何避免重复引入呢？
- 我们可以在模块中额外设置一个变量，使用 if 语句来检测这个变量是否存在，如果发现这个变量存在，就 return 出去。
- 这里需要强调一下 return 关键字。return 在 C++、C#、Java 等大部分编程语言中只能退出函数，除此以外再无他用；但是在 Shell 中，return 除了可以退出函数，还能退出由 source 命令引入的脚本文件。
- 所谓退出脚本文件，就是在被 source 引入的脚本文件（子文件）中，一旦遇到 return 关键字，后面的代码都不会再执行了，而是回到父脚本文件中继续执行 source 命令后面的代码。
- return 只能退出由 source 命令引入的脚本文件，对其它引入脚本的方式无效。
- 下面我们通过一个实例来演示如何避免脚本文件被重复引入。本例会涉及到两个脚本文件，分别是主文件 main.sh 和 模块文件 module.sh。

- 模块文件 module.sh：

  ```
  if [ -n "$__MODULE_SH__" ]; then
      return
  fi
  __MODULE_SH__='module.sh'
  echo "http://c.biancheng.net/shell/"
  
  ```

  - 注意第一行代码，一定要是使用双引号把`$__MODULE_SH__`包围起来，具体原因已经在《[Shell test](http://c.biancheng.net/view/2742.html)》一节中讲到。

  - 主文件 main.sh：

  ```
  #!/bin/bash
  source module.sh
  source module.sh
  echo "here executed"
  ```

  - `./`表示当前文件，你也可以直接写作`source module.sh`。

  ```
  运行 main.sh，输出结果为：
  http://c.biancheng.net/shell/
  here executed
  ```

  - 我们在 main.sh 中两次引入 module.sh，但是只执行了一次，说明第二次引入是无效的。

  - main.sh 中的最后一条 echo 语句产生了输出结果，说明 return 只是退出了子文件，对父文件没有影响。

### Linux常用命令

#### 手册上

##### ls

- 基本的列出所有文件的命令.但是往往就是因为这个命令太简单,所以我们总是低估它.比如,用 -R 选项,这是递归选项,**ls** 将会以目录树的形式列出所有文件, 另一个很有用的选项是 -S ,将会按照文件尺寸列出所有文件, `-t`, 将会按照修改时间来列出文件,-i 选项会显示文件的inode

##### cat

- **cat**, 是单词 *concatenate的缩写*, 把文件的内容输出到`stdout`. 当与重定向操作符 (> 或 >>)结合使用时, 一般都是用来将多个文件连接起来.

  ```
  
     1 # Uses of 'cat'
     2 cat filename                          # 打印出文件内容.
     3 
     4 cat file.1 file.2 file.3 > file.123   # 把3个文件连接到一个文件中.
  ```

  - **cat** 命令的 -n 选项是为了在目标文件中的所有行前边插入行号. `-b` 选项 与 -n 选项一样, 区别是不对空行进行编号. -v 选项可以使用 ^ 标记法 来echo 出不可打印字符.-s选项可以把多个空行压缩成一个空行.

- 在一个 [管道](http://shouce.jb51.net/shell/special-chars.html#PIPEREF) 中, 可能有一种把stdin [重定向](http://shouce.jb51.net/shell/io-redirection.html#IOREDIRREF) 到一个文件中的更有效的办法, 这种方法比 **cat**文件的方法更有效率.

  ```
     1 cat filename | tr a-z A-Z
     2 
     3 tr a-z A-Z < filename   #  效果相同,但是处理更少,
     4                         #+ 并且连管道都省掉了.
  ```

- **tac** 命令, 就是 *cat*的反转, 将从文件的结尾列出文件.

##### rev

- 把每一行中的内容反转, 并且输出到 `stdout`上. 这个命令与 **tac**命令的效果是不同的, 因为它并不反转行序, 而是把每行的内容反转.

  ```
   bash$ cat file1.txt
   This is line 1.
   This is line 2.
   
   
   bash$ tac file1.txt
   This is line 2.
   This is line 1.
   
   
   bash$ rev file1.txt
   .1 enil si sihT
   .2 enil si sihT
  ```

##### cp

- 这是文件拷贝命令. `cp file1 file2` 把` file1 `拷贝到 `file2`, 如果存在 `file2` 的话，那 file2 将被覆盖

- 特别有用的选项就是 `-a` 归档 选项 (为了copy一个完整的目录树), `-u` 是更新选项, 和 `-r` 与 `-R` 递归选项.

  ```
     1 cp -u source_dir/* dest_dir
     2 #  "Synchronize" dest_dir to source_dir把源目录"同步"到目标目录上,
     3 #+  也就是拷贝所有更新的文件和之前不存在的文件
  ```

##### sort

- sort 是 Linux 的排序命令，而且可以依据不同的数据类型来进行排序。sort 将文件的每一行作为一个单位，相互比较。比较原则是从首字符向后，依次按 ASCII 码值进行比较，最后将它们按升序输出。

- sort 命令格式如下：

  ```
  sort [选项] 文件名
  ```

  - -f：忽略大小写；
  - -b：忽略每行前面的空白部分；
  - -n：以数值型进行排序，默认使用字符串排序；
  - -r：反向排序；
  - -u：删除重复行。就是 uniq 命令；
  - -t：指定分隔符，默认分隔符是制表符；
  - -k [n,m]：按照指定的字段范围排序。从第 n 个字段开始，到第 m 个字（默认到行尾）；

##### expand

- **expand** 将会把每个tab转化为一个空格.这个命令经常用在管道中.
- **unexpand** 将会把每个空格转化为一个tab.效果与 **expand** 相反.

##### uniq

- 这个过滤器将会删除一个已排序文件中的重复行.这个命令经常出现在 [sort](http://shouce.jb51.net/shell/textproc.html#SORTREF)命令的管道后边 .

  ```
  -c或--count 在每列旁边显示该行重复出现的次数。
  -d或--repeated 仅显示重复出现的行列。
  -f<栏位>或--skip-fields=<栏位> 忽略比较指定的栏位。
  -s<字符位置>或--skip-chars=<字符位置> 忽略比较指定的字符。
  -u或--unique 仅显示出一次的行列。
  -w<字符位置>或--check-chars=<字符位置> 指定要比较的字符。
  ```

  ```
  
     1 cat list-1 list-2 list-3 | sort | uniq > final.list
     2 # 将3个文件连接起来,
     3 # 将它们排序,
     4 # 删除其中重复的行,
     5 # 最后将结果重定向到一个文件中.
  ```

##### nl

- 计算行号过滤器. `nl filename` 将会在 stdout 中列出文件的所有内容, 但是会在每个非空行的前面加上连续的行号. 如果没有 filename 参数, 那么就操作 stdin.
- **nl** 命令的输出与 `cat -n 非常相似`, 然而, 默认情况下 **nl** 不会列出空行.

##### tr

- Linux tr 命令用于转换或删除文件中的字符。

  ```
  tr [-cdst][--help][--version][第一字符集][第二字符集]  
  tr [OPTION]…SET1[SET2] 
  ```

  - -c, --complement：反选设定字符。也就是符合 SET1 的部份不做处理，不符合的剩余部份才进行转换
  - -d, --delete：删除指令字符
  - -s, --squeeze-repeats：缩减连续重复的字符成指定的单个字符
  - -t, --truncate-set1：削减 SET1 指定范围，使之与 SET2 设定长度相等

- [必须使用引用或中括号](http://shouce.jb51.net/shell/special-chars.html#UCREF), 这样做才是合理的. 引用可以阻止 shell 重新解释出现在 **tr** 命令序列中的特殊字符.中括号应该被引用起来防止被shell扩展.

  ```
  无论 tr "A-Z" "*" <filename 还是 tr A-Z \* <filename 都可以将 filename 中的大写字符修改为星号(写到 stdout).但是在某些系统上可能就不能正常工作了, 而 tr A-Z '[**]' 在任何系统上都可以正常工作.
  ```

- `-d` 选项删除指定范围的字符.

  ```
     1 echo "abcdef"                 # abcdef
     2 echo "abcdef" | tr -d b-d     # aef
     3 
     4 
     5 tr -d 0-9 <filename
     6 # 删除 "filename" 中所有的数字.
  ```

- `--squeeze-repeats` (或 `-s`) 选项用来在重复字符序列中除去除第一个字符以外的所有字符. 这个选项在删除多余的[whitespace](http://shouce.jb51.net/shell/special-chars.html#WHITESPACEREF) 的时候非常有用.

  ```
  bash$ echo "XXXXX" | tr --squeeze-repeats 'X'
   X
  ```

- `-c` "complement" 选项将会 *反转* 匹配的字符集. 通过这个选项, **tr** 将只会对那些 *不* 匹配的字符起作用.

  ```
   bash$ echo "acfdeb123" | tr -c b-d +
   +c+d+b++++
  ```

- 注意 **tr** 命令支持 [POSIX 字符类](http://shouce.jb51.net/shell/regexp.html#POSIXREF). [[1\]](http://shouce.jb51.net/shell/textproc.html#FTN.AEN8253)

  - 这个可以看man手册上有写。

##### cmp

- **cmp** 命令是上边 **diff** 命令的一个简单版本. **diff** 命令会报告两个文件的不同之处, 而 **cmp** 命令仅仅指出那些位置有不同, 而不会显示不同的具体细节.

##### basename

- 从文件名中去掉路径信息, 只打印出文件名. 结构 `basename $0` 可以让脚本知道它自己的名字, 也就是, 它被调用的名字. 可以用来显示用法信息, 比如如果你调用脚本的时候缺少参数, 可以使用如下语句:

  ```
  echo "Usage: `basename $0` arg1 arg2 ... argn"
  ```

- basename - strip directory and suffix from filenames

  ```
  basename [pathname] [suffix]
  ```

  - suffix为后缀，如果suffix被指定了，basename会将pathname或string中的suffix去掉。

    ```
    $ basename /tmp/test/file.txt
    file.txt
    $ basename /tmp/test/file.txt .txt
    file
    ```

    

##### dirname

- 从带路径的文件名中去掉文件名, 只打印出路径信息.

##### host

- 通过名字或 IP 地址来搜索一个互联网主机的信息, 使用 DNS.

  ```
  
   bash$ host surfacemail.com
   surfacemail.com. has address 202.92.42.236
  ```

##### lsof

- 列出打开的文件. 这个命令将会把所有当前打开的文件列出一份详细的表格, 包括文件的所有者信息, 尺寸, 与它们相关的信息等等. 当然, **lsof**也可以管道输出到 [grep](http://shouce.jb51.net/shell/textproc.html#GREPREF) 和(或)[awk](http://shouce.jb51.net/shell/awk.html#AWKREF)来分析它的结果.

- **lsof**是系统管理工具。我大多数时候用它来从系统获得与[网络](http://linuxaria.com/tag/network)连接相关的信息，但那只是这个强大而又鲜为人知的应用的第一步。将这个工具称之为lsof真实名副其实，因为它是指“**列出打开文件（lists openfiles）**”。而有一点要切记，在Unix中一切（包括网络套接口）都是文件。

- sof 查看端口占用语法格式：

  ```
  lsof -i:端口号
  ```

  - 查看服务器 8000 端口的占用情况：

    ```
    # lsof -i:8000
    COMMAND   PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
    nodejs  26993 root   10u  IPv4 37999514      0t0  TCP *:8000 (LISTEN)
    ```

  - FD表示文件描述符

- 更多 lsof 的命令如下：

  ```
  lsof -i:8080：查看8080端口占用
  lsof abc.txt：显示开启文件abc.txt的进程
  lsof -c abc：显示abc进程现在打开的文件
  lsof -c -p 1234：列出进程号为1234的进程所打开的文件
  lsof -g gid：显示归属gid的进程情况
  lsof +d /usr/local/：显示目录下被进程开启的文件
  lsof +D /usr/local/：同上，但是会搜索目录下的目录，时间较长
  lsof -d 4：显示使用fd为4的进程
  lsof -i -U：显示所有打开的端口和UNIX domain文件
  ```

- netstat也可以查看端口占用情况

  - netstat 查看端口占用语法格式：

    ```
    netstat -tunlp | grep 端口号
    ```

    - -t (tcp) 仅显示tcp相关选项
    - -u (udp)仅显示udp相关选项
    - -n 拒绝显示别名，能显示数字的全部转化为数字
    - -l 仅列出在Listen(监听)的服务状态
    - -p 显示建立相关链接的程序名

##### dmesg

- 将所有的系统启动消息输出到stdout上. 方便出错,并且可以查出安装了哪些设备驱动和察看使用了哪些系统中断. **dmesg**命令的输出当然也可以在脚本中使用 [grep](http://shouce.jb51.net/shell/textproc.html#GREPREF), [sed](http://shouce.jb51.net/shell/sedawk.html#SEDREF), 或 [awk](http://shouce.jb51.net/shell/awk.html#AWKREF) 来进行分析.

##### stat

- 显示一个或多个给定文件(也可以是目录文件或设备文件)的详细的统计信息.

  ```
  bash$ stat test.cru
     File: "test.cru"
     Size: 49970        Allocated Blocks: 100          Filetype: Regular File
     Mode: (0664/-rw-rw-r--)         Uid: (  501/ bozo)  Gid: (  501/ bozo)
   Device:  3,8   Inode: 18185     Links: 1    
   Access: Sat Jun  2 16:40:24 2001
   Modify: Sat Jun  2 16:40:24 2001
   Change: Sat Jun  2 16:40:24 2001
  ```

  

#### 自己总结

##### xargs

- Unix 命令都带有参数，有些命令可以接受"标准输入"（stdin）作为参数。

  ```shell
  cat /etc/passwd | grep root
  ```

  上面的代码使用了管道命令（`|`）。管道命令的作用，是将左侧命令（`cat /etc/passwd`）的标准输出转换为标准输入，提供给右侧命令（`grep root`）作为参数。

  因为`grep`命令可以接受标准输入作为参数，所以上面的代码等同于下面的代码。

  ```bash
  grep root /etc/passwd
  ```

  但是，大多数命令都不接受标准输入作为参数，只能直接在命令行输入参数，这导致无法用管道命令传递参数。举例来说，`echo`命令就不接受管道传参。

  ```bash
  echo "hello world" | echo   代码不会有输出。因为管道右侧的echo不接受管道传来的标准输入作为参数。
  ```

- `xargs`命令的作用，是将标准输入转为命令行参数。

  ```bash
  $ echo "hello world" | xargs echo
  hello world    代码将管道左侧的标准输入，转为命令行参数hello world，传给第二个echo命令。
  ```

  `xargs`的作用在于，大多数命令（比如`rm`、`mkdir`、`ls`）与管道一起使用时，都需要`xargs`将标准输入转为命令行参数。

  ```bash
  echo "one two three" | xargs mkdir   代码等同于mkdir one two three。如果不加xargs就会报错，提示mkdir缺少操作参数。
  ```

- xargs一些参数

  - 默认情况下，`xargs`将换行符和空格作为分隔符，把标准输入分解成一个个命令行参数。

    ```bash
    echo "one two three" | xargs mkdir   xargs将one two three分解成三个命令行参数，执行mkdir one two three
    ```

  - `-d`参数可以更改分隔符。

    ```bash
    $ echo -e "a\tb\tc" | xargs -d "\t" echo
    a b c               上面的命令指定制表符\t作为分隔符，所以a\tb\tc就转换成了三个命令行参数。echo命令的-e参数表示解释转义字符。
    ```

  - `-p`参数打印出要执行的命令，询问用户是否要执行。

- bilibili介绍

  - 主要讲述以下两个shell指令区别，通过这个例子来理解xargs与管道

    ```
    $ find . -name "test*" | grep js
    
    $ find . -name "test*" | xargs grep js
    ```

  - 不加xargs的管道

    - 管道都是前面的输出作为后面的输入，而不加xargs这种正常的管道，讲的具体一点是:前面的输出变成一个匿名文件，后面的shell接这个匿名文件。我们详细展开第一句的效果等同于下面的shell，这样作用就很明显了，就是先找到当前目录下test开头的文件列表，然后呢这些文件名里面含有js字样的给过滤出来

      ```
      $ find . -name "test*" > 1.output
      $ grep js 1.output
      ```

    - 因为我当前目录有多个testx.js文件，所以上述指令结果如下

      ```
      find . -name "test*" | grep js
      ./test1.js
      ./test2.js
      ./test3.js
      ./test4.js
      ./test5.js
      ./test6.js
      ```

  - 加xargs的管道

    - 同样还是前面的输出作为后面的输入，只不过这次没有中间文件了，前面shell的字符串输出，通过空格和回车拆分成1或多条，后面shell接这一或多条。我们将第二局shell展开，就等效于下面指令，即找到所有test开头的文件，并在文件内容里寻找js字样，注意不加xargs是在文件名里寻找。可以通过xargs后面加-t查看实际执行的shell。

      ```
      $ find . -name "test*"
      ./test1.js
      ./test2.js
      ./test3.js
      ./test4.js
      ./test5.js
      ./test6.js
      $ grep js ./test1.js ./test2.js ./test3.js ./test4.js ./test5.js ./test6.js
      ```

    - 这几个js文件的内容中基本也都含有js字样，指令结果如下。

    ```
    $ find . -name "test*" | xargs grep js
    ./test1.js:const data = await readJSONFromURL('https://jsonplaceholder.typicode.com/comments');
    ./test2.js:const content = await Deno.readTextFile("test2.js");
    ./test4.js:fs.readFile('test4.js', 'utf8', function(err, data) {
    ./test4.js:const data = await Deno.readTextFile('test4.js');
    ./test5.js:import {express,readJSONFromURL} from "./deps.js";
    ./test5.js:    const data = await readJSONFromURL('https://jsonplaceholder.typicode.com 
    ```


##### su -

- su和su - 的区别，su不切换当前的家目录，不改变当前环境，跟最开始登录一样。相当于su 到那个用户获得那个用户对文件的权限，而su - 切换用户之后会切换到用户的家目录。其中的-号相当于更新当前的环境，相当于重新登录用户。
- 例如在root下编译内核，提示要用普通用户编译，所以su - yq切换到普通用户，但是又提示权限不够，所以su 得到root权限，但是没有完全切换到root登录。

##### sync

- [用户缓冲区和内核缓冲区]: https://www.cnblogs.com/BlueBlueSea/p/14807245.html

- sync命令是强制把内存中的数据写回硬盘，以免数据的丢失。主要还是和缓冲区有关，理解了缓冲区就理解了sync命令。缓冲区可以在c.md里面查看

- mount挂载之后直接umount文件就会出现错误，因为有一部分数据在缓冲区内没有写入到u盘中，所以在umount之前要执行sync命令。每一个文件都有缓冲区，所以在将文件cp 到/mnt中时，每一个文件都开辟了缓冲区，如果没有强制写入硬盘就会出现有一部分数据在缓冲区中没有写入硬盘中。


##### ps

- ps兼容UNIX、BSD、GUN三种风格的语法：

  - UNIX 风格，选项可以组合在一起，并且选项前必须有“-”连字符

  - BSD 风格，选项可以组合在一起，但是选项前不能有“-”连字符。BSD是[Unix](https://link.jianshu.com?t=http://zh.wikipedia.org/zh-cn/Unix)的一个分支

  - GNU 风格的长选项，选项前有两个“-”连字符。GUN计划，后来发展出了Linux

- -o 用户自定义格式。

  - 用户自定义输出的格式以及选项，例如ps aux -o pid，只显示pid，ps aux -o pid，command将显示pid和命令列

##### diff

- diff <变动前的文件> <变动后的文件>

- diff比较的是两个文件的差异，所以是以第一个文件为基础，第二个文件与第一个文件的差异，-表示第二个比第一个少了，+表示第二个比第一个多了。

- diff比较文件差异的时候可能是因为空格数的不同导致的，或者空行导致的，这些不应该显示出来，要不然就太多了，例如在windows上写的代码，拖到linux上，这样比较前后两个文件，所有的行都会显示出来，因为是空格数不同导致的。diff有选项-b会忽略由空格数不同导致的差异。

- diff有三种格式
  - 正常格式（normal diff）
  - 上下文格式（context diff）
  - 合并格式（unified diff）

- 创建两个文件，第一个文件叫做f1，内容是每行一个a，一共7行。第二个文件叫做f2，修改f1而成，第4行变成b，其他不变。

  - 正常格式diff f1 f2

    ```c
    4c4
    < a
    ---
    > b
        
        第一行是一个提示，用来说明变动位置。它分成三个部分：前面的"4"，表示f1的第4行有变化；中间的"c"表示变动的模式是内容改变（change），其他模式还有"增加"（a，代表addition）和"删除"（d，代表deletion）；后面的"4"，表示变动后变成f2的第4行。
        第二行分成两个部分< a,前面的小于号，表示要从f1当中去除该行（也就是第4行），后面的"a"表示该行的内容。
        第三行用来分割f1和f2。
        第四行，类似于第二行,前面的大于号表示f2增加了该行，后面的"b"表示该行的内容。
    ```

  - 上下文格式，它的使用方法是加入c参数（代表context）diff -c f1 f2

    ```shell
       *** f1 2012-08-29 16:45:41.000000000 +0800
    　　--- f2 2012-08-29 16:45:51.000000000 +0800
    　　***************
    　　*** 1,7 ****
    　　 a
    　　 a
    　　 a
    　　!a
    　　 a
    　　 a
    　　 a
    　　--- 1,7 ----
    　　 a
    　　 a
    　　 a
    　　!b
    　　 a
    　　 a
    　　 a
    　　 
    　　 第一部分的两行，显示两个文件的基本情况：文件名和时间信息。"***"表示变动前的文件，"---"表示变动后的文件。
    　　 第二部分是15个星号，将文件的基本情况与变动内容分割开。
    　　 第三部分显示变动前的文件，即f1。这时不仅显示发生变化的第4行，还显示第4行的前面三行和后面三行，因此一共显示7行。所以，前面的"*** 1,7 ****"就表示，从第1行开始连续7行。另外，文件内容的每一行最前面，还有一个标记位。如果为空，表示该行无变化；如果是感叹号（!），表示该行有改动；如果是减号（-），表示该行被删除；如果是加号（+），表示该行为新增。
    　　 第四部分显示变动后的文件，即f2。
    ```

  - 合并格式，如果两个文件相似度很高，那么上下文格式的diff，将显示大量重复的内容，很浪费空间。1990年，GNU diff率先推出了"合并格式"的diff，将f1和f2的上下文合并在一起显示。它的使用方法是加入u参数（代表unified）。diff -u f1 f2

    ```shell
       --- f1 2012-08-29 16:45:41.000000000 +0800
    　　+++ f2 2012-08-29 16:45:51.000000000 +0800
    　　@@ -1,7 +1,7 @@
    　　 a
    　　 a
    　　 a
    　　-a
    　　+b
    　　 a
    　　 a
    　　 a
    　　 
    　　 它的第一部分，也是文件的基本信息。"---"表示变动前的文件，"+++"表示变动后的文件。
    　　 第二部分，变动的位置用两个@作为起首和结束。前面的"-1,7"分成三个部分：减号表示第一个文件（即f1），"1"表示第1行，"7"表示连续7行。合在一起，就表示下面是第一个文件从第1行开始的连续7行。同样的，"+1,7"表示变动后，成为第二个文件从第1行开始的连续7行。
    　　 第三部分是变动的具体内容。
    　　 除了有变动的那些行以外，也是上下文各显示3行。它将两个文件的上下文，合并显示在一起，所以叫做"合并格式"。每一行最前面的标志位，空表示无变动，减号表示第一个文件删除的行，加号表示第二个文件新增的行。
    ```

- 版本管理系统git，使用的是合并格式diff的变体。

  ```shell
  	diff --git a/f1 b/f1
  　　index 6f8a38c..449b072 100644
  　　--- a/f1
  　　+++ b/f1
  　　@@ -1,7 +1,7 @@
  　　 a
  　　 a
  　　 a
  　　-a
  　　+b
  　　 a
  　　 a
  　　 a
  　　 
  　　 第一行表示结果为git格式的diff。进行比较的是，a版本的f1（即变动前）和b版本的f1（即变动后）。
  　　 第二行表示两个版本的git哈希值（index区域的6f8a38c对象，与工作目录区域的449b072对象进行比较），最后的六位数字是对象的模式（普通文件，644权限）。
  　　 第三行表示进行比较的两个文件。"---"表示变动前的版本，"+++"表示变动后的版本。
  　　 后面的行都与官方的合并格式diff相同。
  ```

- git add就是暂存区，git commit是版本库，git 只能比较本地的，远程的不能比较，即不能比较本地和远程的diff

  - git diff -h可以查看帮助，里面有显示可以只显示变化的文件名git diff HEAD^  --name-only

  - 比较不同分支之间的差异
  
    ```shell
    git diff master dev
    上面的命令是以master分支为参照，比较dev分支和master分支之间的差异。注意改变分支的比较顺序，结果会不同，默认不加文件名参数，会比较出所有文件的差异。 比较指定文件的差异可以参照如下命令:
    git diff master dev -- READMD.md index.php
    ```

  - 比较工作区和版本库之间的文件差异
  
    ```shell
    Git中用一个叫HEAD的指针指向当前分支的最新一次提交，我们可以用以下命令来比较工作区和版本库之间的文件差异
    比较全部文件: git diff HEAD
    比较单个文件: git diff HEAD -- READMD.md
    比较单个文件或者某几个文件，需要加上--
    
    git diff HEAD^ 则显示上一次提交之前工作目录与git仓库之间的差异。所以我们在git pull后，可以通过git diff HEAD^ 来查看拉下来的文件有那些具体的修改。
    HEAD 表示当前版本，也就是最新的提交。上一个版本就是 HEAD^ ，上上一个版本就是 HEAD^^ ，
    往上100个版本写100个 “ ^ ” 比较容易数不过来，所以写成 HEAD~100 。HEAD~2 相当于 HEAD^^ 。
    ```

  - 比较工作区和暂存区之间的文件差异
  
    - 使用默认的git diff，不加任何参数，默认比较的是工作区和暂存区之间的文件差异。
  
  - 比较暂存区和版本库之间的文件差异
  
    - 使用git diff --cached或者git diff --staged来比较暂存区和版本库之间的文件差异，cached和staged都有表示缓存的意思。
  

##### ln

- 功能是为某一个文件在另外一个位置建立一个同步的链接.当我们需要在不同的目录，用到相同的文件时，我们不需要在每一个需要的目录下都放一个必须相同的文件，我们只要在某个固定的目录，放上该文件，然后在 其它的目录下用ln命令链接（link）它就可以，不必重复的占用磁盘空间。

  ```
  ln [参数][源文件或目录][目标文件或目录]
  ```

  - 源文件是真实存在的文件，目标文件是我们要创建的链接文件
  - -s是创建软连接
  - ls查看文件时前面的是链接文件，后面的是真实的文件libm.so.6 -> libm-2.17.so，->的意思是指向真实的文件

##### ldconfig和ldd

- ldd用来查看程式运行所需的共享库,常用来解决程式因缺少某个库文件而不能运行的一些问题。

  ```shell
  ldd /bin/ls
  linux-vdso.so.1 =>  (0x00007fff69bff000)
  librt.so.1 => /lib64/librt.so.1 (0x00007fd67f147000)
  libacl.so.1 => /lib64/libacl.so.1 (0x00007fd67ef41000)
  libc.so.6 => /lib64/libc.so.6 (0x00007fd67ec01000)
  libpthread.so.0 => /lib64/libpthread.so.0 (0x00007fd67e9e6000)
  /lib64/ld-linux-x86-64.so.2 (0x00007fd67f351000)
  libattr.so.1 => /lib64/libattr.so.1 (0x00007fd67e7e2000)
  
  第一个linux-vdso.so.1是系统用的，这个不用管
  ```

  - 第一列：程序需要依赖什么库
  - 第二列: 系统提供的与程序需要的库所对应的库
  - 第三列：库加载的开始地址
  - 通过对比第一列和第二列，我们可以分析程序需要依赖的库和系统实际提供的，是否相匹配
  - 通过观察第三列，我们可以知道在当前的库中的符号在对应的进程的地址空间中的开始位置

-  ldd不是个可执行程式，而只是个shell脚本； ldd显示可执行模块的dependency的工作原理，其实质是通过ld-linux.so（elf动态库的装载器）来实现的。ld-linux.so模块会先于executable模块程式工作，并获得控制权，因此当上述的那些环境变量被设置时，ld-linux.so选择了显示可执行模块的dependency。

- ldconfig

  - `ldconfig`是一个动态库管理命令, 为了让动态库为系统所共享, 须运行该命令

  - `ldconfig`通常在系统启动时运行, 而当用户安装了一个新的动态库时, 就需要手动运行该命令

  - ldconfig作用，在默认搜寻目录(`/lib`和`/usr/lib`)下, 以及动态库配置文件(`/etc/ld.so.conf`和`/etc/ld.so.conf.d/*.conf`)里所列的目录下, 搜索出可共享的动态库(格式如`lib*.so*`), 进而创建出动态装入程序*(ld.so)*所需的连接和缓存文件，缓存文件默认为`/etc/ld.so.cache`, 此文件保存动态库名字列表。简单来说动态装载器ld.so需要/etc/ld.so.cache文件来查看需要的库路径，如果没有在这个缓存文件里面就不会加载，ldconfig会将默认搜寻目录和动态库配置文件中找需要的库，并将其加入到缓存文件中，这样系统就能装在所需要的库。一般安装软件时，会在/etc/ld.so.conf.d目录下生成一个文件，文件以conf为后缀例如mysql.ld.conf，文件里面记录着库存放的路径。这样运行ldconfig就能搜寻到库，放到缓存文件中，然后ld.so就能加载上了。

  - 命令选项

    ```shell
    -p或--print-cache：此选项指示ldconfig打印出当前缓存文件所保存的全部共享库的名字。
    -v或--verbose：用此选项时，ldconfig将显示正在扫描的目录及搜索到的动态连接库，还有它所建立的链接的名字。
    ```

  - 注意事项

    - 往/lib和/usr/lib里面加东西, 是不用修改/etc/ld.so.conf的, 但是完了之后要调一下ldconfig, 不然这个library会找不到
    - 想往上面两个目录以外加东西的时候, 一定要修改/etc/ld.so.conf, 然后再调用ldconfig, 不然也会找不到. 比如安装了一个mysql到/usr/local/mysql, mysql有一大堆library在/usr/local/mysql/lib下面, 这时就需要在/etc/ld.so.conf下面加一行/usr/local/mysql/lib, 保存过后ldconfig一下, 新的library才能在程序运行时被找到
    - 如果想在这两个目录以外放lib, 但是又不想在/etc/ld.so.conf中加东西或者是没有权限加东西. 那也可以, 就是export一个全局变量`LD_LIBRARY_PATH`, 然后运行程序的时候就会去这个目录中找library. 一般来讲这只是一种临时的解决方案, 在没有权限或临时需要的时候使用
    - ldconfig做的这些东西都与运行程序时有关, 跟编译时一点关系都没有
    - 总之, 就是不管做了什么关于library的变动后, 最好都ldconfig一下, 不然会出现一些意想不到的结果

##### bin和lib目录详解

- bin目录有/bin,/sbin,/usr/bin,/usr/sbin,/usr/local/bin,/usr/local/sbin
  - `/bin`放置系统的关键程序比如 `ls` `cat` ，对于“关键”的定义，不同的发行版会有不同的理解
  - `/usr/bin` 放置发行版管理的程序，比如 Ubuntu 自带 `md5sum` ，这个 binary 就会在这个目录下
  - `/usr/local/bin` 放置用户自己的程序，比如你编译了一个 gcc，那么 gcc 这个可执行 binary 应该在这个目录下，自己在晚上下载安装的软件一般放在这里
  - 除此之外，还有对应的三个目录 `/sbin` `/usr/sbin` `/usr/local/sbin` ，放置系统管理的程序，比如 `deluser` `chroot` `service` ,`reboot` `shutdown`
  - 这是一种文件的管理方式而已，你甚至可以把自己的 binary 放到 `$HOME/bin` 下。还有，OS X 用 [homebrew](https://brew.sh/) 安装的软件，会放在 `/usr/local/Cellar` 下，然后在 `/usr/local/bin` 创建一个指向相关 bin 目录的符号链接；但是在 Ubuntu 下，会放到 `/usr/bin` 下。
  - 需要知道 `/` `/usr` `/usr/local` 这些都是 prefix，你编译一个软件的之后，要执行 `./configure --prefix=/usr/local` 然后 `make && make install` 。那么 `/usr/local` 就会作为 prefix，库文件就放在 `/usr/local/lib` 下面，配置文件就放在 `/usr/local/etc` 下面，可执行文件（binary）就放在 `/usr/local/bin` 下面。
- lib64，lib目录和bin目录一样，只要有bin目录的地方就有lib目录，用来存放bin程序需要的库。简单说,/lib是内核级的,/usr/lib是系统级的,/usr/local/lib是用户级的。
- /opt这里主要存放那些可选的程序。你想尝试最新的firefox测试版吗?那就装到/opt目录下吧，这样，当你尝试完，想删掉firefox的时候，你就可 以直接删除它，而不影响系统其他任何设置。安装到/opt目录下的程序，它所有的数据、库文件等等都是放在同个目录下面。而/usr/local里面的程序和库没有统一在一个文件夹里面，这样造成删除的时候困难，使用包管理工具安装的软件一般放在/usr里面。homebrew安装的放在/usr/local/Cellar下面有各个软件的文件夹，apt-get没有单独命名的文件夹，其内容是分散的lib和bin

##### xrandr

- xrandr是一款官方的扩展配置工具。它可以设置屏幕显示的大小、方向、镜像等，包括对多屏的设置。
- xrandr查看屏幕可以设置的分辨率，然后xrandr -s 设置分辨率

##### source

- source命令作用

  - 在当前bash环境下读取并执行FileName中的命令，该命令经常用命令(.就是一个点)来代替

    ```
    source filename 
    
    # 中间有空格
    . filename
    ```

  - source命令（从 C Shell 而来）是bash shell的内置命令。点命令，就是个点符号，（从Bourne Shell而来）是source的另一名称。

  - source（或点）命令通常用于重新执行刚修改的初始化文档，如 .bash_profile 和 .profile 这些配置文件。

- 举例说明

  - 假如在登录后对 .bash_profile 中的 EDITER 和 TERM 变量做了修改，这时就可以用 *source* 命令重新执行 .bash_profile文件,使修改立即生效而不用注销并重新登录。

  - 再比如您在一个可执行的脚本 a.sh 里写这样一行代码

    ```
    export KKK=111 
    ```

  - 假如您用 **./a.sh** 执行该脚本，执行完毕后，在当前shell环境中运行 `echo $KKK`，发现没有值，但是用 **source a.sh** 来执行 ，然后再 **echo $KKK**，就会发现 打印 **111** 。

  - 原因说明，因为调用./a.sh来执行shell是在一个子shell里运行的，所以执行后，结构并没有反应到父shell里，但是source不同他就是在本shell中执行的，所以能够看到结果。

- 总结：source命令（从 C Shell 而来）是bash shell的内置命令. 点命令，就是一个点符号，是source的另一名称。这两个命令都以一个脚本为参数，该脚本将在当前shell的环境执行，即不会启动一个新的子shell。所有在脚本中设置的变量都将成为当前Shell的一部分。

- source其他妙用

  - 在编译核心时，常常要反复输入一长串命令，如

    ```
    make mrproper
    make menuconfig
    make dep
    make clean
    make bzImage
    .......
    ```

  - 这些命令既长，又繁琐。而且有时候容易输错，浪费你的时间和精力。如果把这些命令做成一个文件，让它自动按顺序执行，对于需要多次反复编译核心的用户来说，会很方便。

  - 用source命令可以办到这一点。它的作用就是把一个文件的内容当成是shell来执行。

  - 先在/usr/src/mysh目录下建立一个文件，取名为make_command，在其中输入如下内容：

    ```
    make mrproper &&
    make menuconfig &&
    make dep &&
    make clean &&
    make bzImage &&
    make modules &&
    make modules_install &&
    cp arch/i386/boot/bzImge /boot/vmlinuz_new &&
    cp System.map /boot &&
    vi /etc/lilo.conf &&
    lilo -v
    ```

    - 文件建立好之后，以后每次编译核心，只需要在/usr/src/mysh下输入`source make_command` 就行了。这个文件也完全可以做成脚本，只需稍加改动即可。

  - shell编程中的命令有时和C语言是一样的。&&表示与，||表示或。把两个命令用&&联接起来，如 `make mrproper && make menuconfig`，表示要第一个命令执行成功才能执行第二个命令。对执行顺序有要求的命令能保证一旦有错误发生，下面的命令不会盲目地继续执行。

- source filename 与 sh filename 及./filename执行脚本的区别
  - 当shell脚本具有可执行权限时，用`sh filename`与`./filename`执行脚本是没有区别得。`./filename`是因为当前目录没有在PATH中，所有”.”是用来表示当前目录的。
  - `sh filename` 重新建立一个子shell，在子shell中执行脚本里面的语句，该子shell继承父shell的环境变量，但子shell新建的、改变的变量不会被带回父shell，除非使用export。
  - `source filename`：这个命令其实只是简单地读取脚本里面的语句依次在当前shell里面执行，没有建立新的子shell。那么脚本里面所有新建、改变变量的语句都会保存在当前shell里面。

###### 脚本里面写函数

- 如果我们在一个脚本里面写一个函数，然后在当前终端下source一下，我们就可以在终端里面使用这个函数。例如

  ```
  #test.sh
  #!/bin/sh
  function pcd(){
  	echo "test"
  }
  ```

  - 如果我们在当前终端里面source一下，我们就可以直接在当前终端里面输入pcd，就会打印出test，相当于在终端里面执行这个函数。
  - 所以我们可以写一些函数，然后source一下这个文件，然后在终端里面使用。

- 对于上面的source test.sh，我们必须在test.sh目录里面，如果我们将test.sh所在目录加入到PATH环境变量中我们就可以在任意目录source，因为现在我们能找到这个test.sh文件了。

##### netstat

- Linux netstat 命令用于显示网络状态。利用 netstat 指令可让你得知整个 Linux 系统的网络情况。

  ```
  -a或--all 显示所有连线中的Socket。
  -n或--numeric 直接使用IP地址，而不通过域名服务器。拒绝显示别名，能显示数字的全部转化成数字。
  -p或--programs 显示正在使用Socket的程序识别码和程序名称。
  -t或--tcp 显示TCP传输协议的连线状况。
  -u或--udp 显示UDP传输协议的连线状况。
  -i或--interfaces 显示网络界面信息表单。即网卡列表
  -l或--listening Show only listening sockets.  (These are omitted by default.)显示监听端口
  -x或--unix 此参数的效果和指定"-A unix"参数相同。即本地套接字连接
  <Socket>={-t|--tcp} {-u|--udp} {-U|--udplite} {-S|--sctp} {-w|--raw}
             {-x|--unix} --ax25 --ipx --netrom
  ```

- 从整体上看，netstat的输出结果可以分为两个部分：

  - 一个是Active Internet connections，称为有源TCP连接，其中"Recv-Q"和"Send-Q"指的是接收队列和发送队列，这些数字一般都应该是0。如果不是则表示软件包正在队列中堆积，这种情况非常少见。
  - 另一个是Active UNIX domain sockets，称为有源Unix域套接口(和网络套接字一样，但是只能用于本机通信，性能可以提高一倍)。RefCnt表示连接到本套接口上的进程号，即连接到本套接字的进程数量。这个列表下proto都是unix表示本地通信。

- 一般使用netstat -anp来查看某个进程查看的端口什么的。

- 除了IP地址能通过/etc/hosts重命名，端口也是能映射的，通过/etc/services来映射端口名字，所以在查看端口时，我们也要用-n参数来防止映射，直接显示具体的端口号和IP地址。

  ```
  service-name    port/protocol   [aliases..]  [#comment]
  最后两个字段是可选的，因此用 [ ] 表示。
  service-name 是网络服务的名称。例如 telnet、ftp 等。
  port/protocol 是网络服务使用的端口（一个数值）和服务通信使用的协议（TCP/UDP）。
  alias 是服务的别名。
  comment 是你可以添加到服务的注释或说明。以 # 标记开头。
  
  rje             5/tcp                           # Remote Job Entry
  discard         9/udp           sink null
  ```

  - /etc/services文件保存了服务和端口的对应关系。但是通常服务的配置文件里会自行定义端口(每一个程序自己的配置文件里面定义这个端口)。那么两者间是什么关系呢？事实上，服务最终采用的方案仍然是自己的端口定义配置文件。但是/etc/services的存在有几个意义：
    - 如果每一个服务都能够严格遵循该机制，在此文件里标注自己所使用的端口信息，则主机上各服务间对端口的使用，将会非常清晰明了，易于管理。
    - 在该文件中定义的服务名，可以作为配置文件中的参数使用。例如：在配置路由策略时，使用"www"代替"80"，即为调用了此文件中的条目“www  80”
    - 当有特殊情况，需要调整端口设置，只需要在/etc/services中修改www的定义，即可影响到服务。例如：在文件中增加条目“privPort  55555”，在某个私有服务中多个配置文件里广泛应用，进行配置。当有特殊需要，要将这些端口配置改为66666，则只需修改/etc/services文件中对应行即可。
    - 在应用程序中可以通过服务名和协议获取到对应的端口号，通过在该文件注册可以使应用程序不再关心端口号。
    - 应用程序可以不直接使用端口号，通过函数getservbyname("server","tcp")获取端口号。同时可以通过函数getservbyport（htons（50），“tcp”）获取对应端口和规约上的服务名。使用这两个系统函数需要包含头文件：#include <netdb.h>

- netstat查看的信息中有127.0.0.1和0.0.0.0两种本地的地址，区别如下：

  - [具体介绍127.0.0.1和0.0.0.0](https://juejin.cn/post/6844904138812162061)
  - **127.0.0.1** 从上面 特殊的IP网段中我们可以知道`127.0.0.1`表示的是`回环IP地址（loopback address）`。啥意思呢？所有发往目标IP为`127.0.0.1`的数据包都不会通过网卡发送到网络上，而是在数据离开网络层时将其回送给本机的有关进程。
    - 实际上`localhost`通常也代表127.0.0.1。这是因为通常在**本机Hosts文件**会把localhost映射为127.0.0.1 。此外`以127开头`的IP地址都是回环地址，只是我们通常使用127.0.0.1。所以这只能在本机来回收发包的地址有啥用呢？**本机测试用！！**
  - 0.0.0.0这个IP地址指的是`没有路由的元地址`，通常被用来表示`无效的，未知的 或是 没有指定目标IP的地址`。看不懂没关系，它其实相当于Java中的`this`，真表示啥要放到实际所处环境中去考虑。**用处**主要有：
    - 当考虑它在一台服务器中的作用时，它指代的就是`这台机器上所有的IP`。假如一台机器上有两个IP:203.16.20.5/24   和 203.16.24.4/24。如果我们把一个Java应用的IP绑定到了0.0.0.0:8080，那访问203.16.20.5:8080 和 203.16.24.4:8080都可以与这个Java应用建立连接。
    - 上面就是说在服务器中0.0.0.0IP绑定了监听端口，但是此服务器上有两张网卡，两个IP地址，此时client端可以通过任意一个地址和此服务器相连接。因为其是没有指定服务器IP的地址，所以服务器地址有两个，每一个都能作为地址来连接。但是端口都是固定的。
  - 127.0.0.1只是本机器测试用的，而0.0.0.0可以使一个服务器上的多网卡都可以作为服务器来连接。两个不是一个概念。
  - 127.0.0.1只是本机器测试或者是本地通信用的，而0.0.0.0是给外面的机器或者本地通信使用的，只是这个IP我们可以使用服务器上的多个网卡来通信，所以在服务器端bind函数可以绑定IP地址为0.0.0.0，此时client端可以通过这个服务器端的多个IP地址来connect。这就避免了浪费多张网卡的情况了。如果只有一张网卡也能这样用，相当于绑定了固定的IP地址。一般的服务器上的监听端口对应的IP都是0.0.0.0，不会是具体的本机器的IP地址。这样更方便管理和使用。
  - 127.0.0.1主要用于网络软件测试以及本地机[进程间通信](https://baike.baidu.com/item/进程间通信/1235923?fromModule=lemma_inlink)，无论什么程序，一旦使用回送地址发送数据，协议软件立即返回，不进行任何网络传输。相当于不用加各种报文头了，直接发送到本地对应的端口里面去了。
  - 0.0.0.0主要是服务器用的，在服务器bind的时候，直接绑定0.0.0.0这个地址。
  

##### find

- Linux find 命令用来在指定目录下查找文件。任何位于参数之前的字符串都将被视为欲查找的目录名。如果使用该命令时，不设置任何参数，则 find 命令将在当前目录下查找子目录与文件。并且将查找到的子目录和文件全部进行显示。

  ```
  find   path   -option   [   -print ]   [ -exec   -ok   command ]   {} \;
  ```

- -print： find命令将匹配的文件输出到标准输出。

- -exec： find命令对匹配的文件执行该参数所给出的shell命令。相应命令的形式为'command' {} \;，注意{}和\;之间的空格。其中使用-exec时后面的{} 和\;一定要有，否则不能正常执行。

  - 如果 `*COMMAND*` 中包含 {}, 那么 **find** 命令将会用所有匹配文件的路径名来替换 "{}" .

  - 就相当于在所有的查出来的文件执行那个命令。

    ```
    
       1 find ~/ -name 'core*' -exec rm {} \;
       2 # 从用户的 home 目录中删除所有的 core dump文件.
    ```

    

- -ok： 和-exec的作用相同，只不过以一种更为安全的模式来执行该参数所给出的shell命令，在执行每一个命令之前，都会给出提示，让用户来确定是否执行。

- find 根据下列规则判断 path 和 expression，在命令列上第一个 - ( ) , ! 之前的部份为 path，之后的是 expression。如果 path 是空字串则使用目前路径，如果 expression 是空字串则使用 -print 为预设 expression。

- expression 中可使用的选项有二三十个之多，在此只介绍最常用的部份。

  - -mount, -xdev : 只检查和指定目录在同一个文件系统下的文件，避免列出其它文件系统中的文件
  - -amin n : 在过去 n 分钟内被读取过
  - -anewer file : 比文件 file 更晚被读取过的文件
  - -atime n : 在过去 n 天内被读取过的文件
  - -cmin n : 在过去 n 分钟内被修改过
  - -cnewer file :比文件 file 更新的文件
  - -ctime n : 在过去 n 天内创建的文件
  - -mtime n : 在过去 n 天内修改过的文件
  - -empty : 空的文件-gid n or -group name : gid 是 n 或是 group 名称是 name
  - -ipath p, -path p : 路径名称符合 p 的文件，ipath 会忽略大小写
  - -name name, -iname name : 文件名称符合 name 的文件。iname 会忽略大小写
  - -size n : 文件大小 是 n 单位，b 代表 512 位元组的区块，c 表示字元数，k 表示 kilo bytes，w 是二个位元组。
  - -type c : 文件类型是 c 的文件。
    - d: 目录
    - c: 字型装置文件
    - b: 区块装置文件
    - p: 具名贮列
    - f: 一般文件
    - l: 符号连结
    - s: socket

- find命令中也有与或非，用来控制匹配条件等等。

  ```
  		! expr True if expr is false.  This character will also usually need protection from interpretation by the shell.
  
         -not expr
                Same as ! expr, but not POSIX compliant.
  
         expr1 expr2
                Two expressions in a row are taken to be joined with an implied -a; expr2 is not evaluated if expr1 is false.
  
         expr1 -a expr2
                Same as expr1 expr2.
  
         expr1 -and expr2
                Same as expr1 expr2, but not POSIX compliant.
  
         expr1 -o expr2
                Or; expr2 is not evaluated if expr1 is true.
  
         expr1 -or expr2
                Same as expr1 -o expr2, but not POSIX compliant.
  
         expr1 , expr2
                List; both expr1 and expr2 are always evaluated.  The value of expr1 is discarded; the value of the list is the value of expr2.  The comma operator can  be
                useful  for searching for several different types of thing, but traversing the filesystem hierarchy only once.  The -fprintf action can be used to list the
                various matched items into several different output files.
  
  ```

  - 上面说明find可以用的与或非的符号，还有逗号运算符，逗号运算符中两个expr都是会被执行的

    ```
    read -p " What folder should be backed up: " folder
    read -p " What type of files should be backed up: " suffix
    find $folder -name "*.$suffix" -a ! -name '~*' -exec cp {} \
        $BACKUP/$LOGNAME/$folder
    echo "Backed up files from $folder to $BACKUP/$LOGNAME/$folder"
    ```

  - 其中-a表示与，也可以没有

  - ！表示非，！-name表示不取以~开头的备份文件，-exec就是对查找到的文件执行命令。、


##### alias

- ```
  alias [name[=value]]
  ```

  - 这里需要注意的是：

  - 等号（=）前后不能有空格，否则就会出现语法错误了。
  - 如果value中有空格或tab，则value一定要使用引号（单、双引号都行）括起来。

- 别名虽好，但也有它的弊端，比如定义的别名恰好和某个命令重名了，这就麻烦了，Shell 中执行的将永远都是别名。这里，如果我们想执行真正的那个命令而非别名，该怎么办呢？有三种方法可以解决这个问题：

  - 方案一：使用命令的绝对路径。

  - 方案二：切换到命令所在的目录，执行./command。

  - 方案三：在命令前使用反斜线（\），脚本里面也得使用反斜线。脚本里面使用别名时需要先source一下那个别名文件。如果脚本文件嵌套比较多，在当前文件中没有看到source，没准在其他的脚本文件中source了，在这里能直接用。

    ```
    #绝对路径方法
    [roc@roclinux ~]$ /bin/vi test.sh
     
    #明确指定当前路径的方法
    [roc@roclinux ~]$ cd /bin
    [roc@roclinux bin]$ ./vi ~/test.sh
     
    #使用反斜线的方法
    [roc@roclinux bin]$ cd
    [roc@roclinux ~]$ \vi test.sh
    ```

- 如果想让别名永久有效的话，就需要把所有的别名设置方案加入到（$HOME）目录下的 .alias 文件中（如果系统中没有这个文件，你可以创建一个），然后在 .bashrc 文件中增加这样一段代码：

  ```
  # Aliases
  if [ -f ~/.alias ]; then
    . ~/.alias
  fi
  ```

  - 也可以设置别的文件

- 在别名的应用中，单引号和双引号的使用是比较容易造成困惑的，请看下面的示例：

  ```
  [root@roclinux ~]$ echo $PWD
  /root
  [root@roclinux ~]$ alias dirA="echo work directory is $PWD"
  [root@roclinux ~]$ alias dirB='echo work directory is $PWD'
   
  # 正确显示
  [root@roclinux ~]$ dirA            
  work directory is /root
   
  # 正确显示
  [root@roclinux ~]$ dirB
  work directory is /root 
   
  # 显示不正确, 怎么回事?     
  [root@roclinux ~]$ cd /
  [root@roclinux /]$ dirA
  work directory is /root     
   
  # 正确显示 
  [root@roclinux /]$ dirB
  work directory is /    
  ```

  - 上面的程序最让人困惑的是，别名中使用了 Shell 的系统变量 $PWD 来显示当前的目录路径，但当目录切换了之后，单引号的别名可以正常显示，而双引号的别名却无法正常显示了，这和我们使用 bash 的变量的经验正好相反。这是怎么回事呢？

  - 下面就来看看 dirA 和 dirB 背后的真实面容：

    ```
    [roc@roclinux ~]$ alias dirA
    alias dirA="echo work directory is /root"
     
    [roc@roclinux ~]$ alias dirB
    alias dirB='echo work directory is $PWD'
    ```

  - 看到了吧，使用双引号的 dirA，通过 Shell 的变量转换后已经变成了字符串 echo work directory is/root，当目录切换后，当然还是显示字符串的内容。而使用单引号的 dirB，由于不受 Shell 的影响，仍然保留着原来的设置 echowork directory is$PWD，当切换目录后再执行，变量 $PATH 被 Shell 替换掉，因此，内容被正确显示了。

  - 上面的程序最让人困惑的是，别名中使用了 Shell 的系统变量 $PWD 来显示当前的目录路径，但当目录切换了之后，单引号的别名可以正常显示，而双引号的别名却无法正常显示了，这和我们使用 bash 的变量的经验正好相反。这是怎么回事呢？
  - 在使用引号时如果有系统变量需要使用单引号。

- 脚本中的别名

  ```
  shopt -s expand_aliases
  # 必须设置这个选项，否则脚本不会扩展别名功能.
  ```

- 用`alias`命令设置的别名命令在终端[命令行](https://so.csdn.net/so/search?q=命令行&spm=1001.2101.3001.7020)可以直接敲，但是在shell脚本中默认是无法直接使用的，需要先开启`expand_aliases`选项才行。具体做法是在shell脚本中加入以下内容：

  ```
  #!/usr/bin/env bash
  shopt -s expand_aliases
  source ~/.bash_profile
  ```

  - 其中`shopt`命令是“shell options”的缩写，用来开关shell中的选项；开启`expand_aliases`之后`source`命令重新读取和执行记录了`alias`别名设置的bash配置文件。

- shopt查不到man手册，可以在man bash里面看到shopt选项以及后面的子选项。

##### expect

- expect工具在日常的运维中非常有用，可以用在多机器服务重启、远程copy、多机器日志查看、ftp文件操作、telnet等多种场景。shell中有些操作会受限于密码输入的人工操作，expect工具可以代替人工来完成一些交互性工作。
  - 意思是执行一些命令之后在需要输入一些东西时，需要重复的人工输入，每次运行都需要输入，此时可以使用expect来交互完成，就不需要输入密码这类重复输入的东西了。这些密码是提前写在expect脚本中的，不用自己在去输入。

- expect自动交互流程：

  - spawn启动指定进程---expect获取指定关键字---send向指定程序发送指定字符---执行完成退出.

- expect常用命令总结

  ```
  spawn               交互程序开始后面跟命令或者指定程序
  expect              获取匹配信息匹配成功则执行expect后面的程序动作
  send exp_send       用于发送指定的字符串信息，exp_send是send的alise
  exp_continue        在expect中多次匹配就需要用到
  send_user           用来打印输出 相当于shell中的echo
  exit                退出expect脚本
  eof                 expect执行结束 退出，一般要写成expect eof，与spawn对应，表示捕捉终端输出信息终止，结束交互。
  set                 定义变量
  puts                输出变量
  interact			执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了。如果没有这一句登录完成后会退出，而不是留在远程终端上。
  set timeout         设置超时时间 set timeout -1,表示不设置超时时间，set timeout 300 表示超时时间设置为300秒
  ```

  - 转义字符\r是回车

  - spawn命令就是用来启动新的进程的。spawn后的send和expect命令都是和spawn打开的进程进行交互的。

  - send命令接收一个字符串参数，并将该参数发送到进程。（有点像here document）

  - expect通常是用来等待一个进程的反馈，expect可以接收一个字符串参数，也可以接收正则表达式参数。和上文的send命令结合，实现简单的交互式。

    - expect中的命令send可以和expect写在一行，但是命令send等必须要用{}括起来，expect和send也可以分两行来写，这样就可以不用写括号了，expect也可以多分支匹配，这样就像下面这样。

    - 单一分支模式语法：

      - expect "hi" {send "You said hi"}　　#匹配到hi后，会输出"you said hi"给进程，作为标准输入

    - 多分支模式语法：匹配到hi，hello，bye任意一个字符串时，执行相应的输出。

      ```
      expect {
      　　"hi" { send "You said hi\n"; exp_continue}
      　　"hello" { send "Hello yourself\n"; exp_continue}
      　　"bye" { send "That was unexpected\n"}
      }
      ```

  - interact：利用spawn、expect、send自动化完成部分操作。如果想在适当的时候干预这个过程---就用到了interact（互相影响 互相作用）比如下载完ftp文件时，仍然可以停留在ftp命令行状态，以便手动的执行后续命令。interact可以达到这些目的，在自动登录ftp后，允许用户交互。

    ```
    spawn ftp 172.16.1.1
    expect "Name"
    send "ftp\r"
    expect "Password:"
    send "123456\r"
    interact　　//留在ftp中手动执行后续命令操作
    ```

    - 执行完成后保持交互状态，把控制权交给控制台，这个时候就可以手工操作了；
    - 如果没有这一句登录完成后会退出，而不是留在远程终端上。

- shell脚本中执行expect命令

  - 如果需要在shell脚本中嵌套expect代码，可以使用expect -c "expect代码"

    ```
    expect -c "
    　　spawn ssh $user_name@$ip_addr df -P
    　　expect {
    　　　　\"*(yes/no)?\" {send \"yes\r\" ; exp_continue}
    　　　　\"*password:\" {send \"$user_pwd\r\" ; exp_continue}
    　　　　#退出
    　　}
    "
    ```

    - 在expect -c里面的代码，双引号要用\转义字符。expect -c执行的代码要用双引号包围。

  - 使用here document的嵌套调用

    ```
    #!/bin/bash
    echo "123"
    /usr/bin/expect <<EOF　　#利用here document的expect代码嵌套
    
    spawn ssh root@172.16.11.99
    expect "*password:"
    send "rootzhang\r"
    expect "*#"
    send "touch zhangjiacai\r"
    expect "*#"
    send "exit\r"
    expect eof　　#捕获结束
    
    EOF  
    ```

    - 这个在上面的shell中EOF有介绍，这个是在shell脚本中执行expect代码。

###### 示例

- ssh登录远程主机执行命令,执行方法 expect 1.sh 或者 ./1.sh

  ```
  #!/usr/bin/expect
  
  spawn ssh saneri@192.168.56.103 df -Th
  expect "*password"
  send "123456\n"
  expect eof
  ```

  - 此时登录执行df -Th命令后就会退出。如果不退出需要使用interact，此处是expect脚本，解释器是expect

- ssh远程登录主机执行命令，在shell脚本中执行expect命令,执行方法sh 2.sh、bash 2.sh 或./2.sh都可以执行.

  ```
  #!/bin/bash
  
  passwd='123456'
  
  /usr/bin/expect <<-EOF
  
  set time 30
  spawn ssh saneri@192.168.56.103 df -Th
  expect {
  "*yes/no" { send "yes\r"; exp_continue }
  "*password:" { send "$passwd\r" }
  }
  expect eof
  EOF
  ```

  - 此处是shell脚本，解释器是bash，然后在shell脚本中嵌套执行expect

- 创建ssh key，将id_rsa和id_rsa.pub文件分发到各台主机上面。

  ```
  1.创建主机配置文件
  
  [root@localhost script]# cat host 
  192.168.1.10 root 123456
  192.168.1.20 root 123456
  192.168.1.30 root 123456
  
  [root@localhost script]# ls
  copykey.sh  hosts
  2.编写copykey.sh脚本,自动生成密钥并分发key.
  [root@localhost script]# vim copykey.sh
  
  #!/bin/bash
  
  # 判断id_rsa密钥文件是否存在
  if [ ! -f ~/.ssh/id_rsa ];then
   ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
  else
   echo "id_rsa has created ..."
  fi
  
  #分发到各个节点,这里分发到host文件中的主机中.
  while read line
    do
      user=`echo $line | cut -d " " -f 2`
      ip=`echo $line | cut -d " " -f 1`
      passwd=`echo $line | cut -d " " -f 3`
      
      expect <<EOF
        set timeout 10
        spawn ssh-copy-id $user@$ip
        expect {
          "yes/no" { send "yes\n";exp_continue }
          "password" { send "$passwd\n" }
        }
       expect "password" { send "$passwd\n" }
  EOF
    done <  hosts
  ```

- 使用普通用户登录远程主机，并通过sudo到root权限，通过for循环批量在远程主机执行命令.

  ```
  cat timeout_login.txt 
  10.0.1.8
  10.0.1.34
  10.0.1.88
  10.0.1.76
  10.0.1.2
  10.0.1.3
  ```

  ```
  #!/bin/bash
  
  for i in `cat /home/admin/timeout_login.txt`
  do
  
      /usr/bin/expect << EOF
      spawn /usr/bin/ssh -t -p 22022 admin@$i "sudo su -"
  
      expect {
          "yes/no" { send "yes\r" }
      }   
  
      expect {
          "password:" { send "xxo1#qaz\r" }
      }
      
      expect {
          "*password*:" { send "xx1#qaz\r" }
      }
  
      expect "*]#"
      send "df -Th\r"
      expect "*]#"
      send "exit\r"
      expect eof
  
  EOF
  done
  ```

- 90上scp自动拷贝到服务器的expect

  ```
  #!/bin/sh
  INSTALLER_NAME_HEAD="tc-agent-v1.0-"
  INSTALLER_NAME=${INSTALLER_NAME_HEAD}`date "+%Y%m%d_%H%M%S"`.tar.gz
  PACKAGE_DIR=trust_terminal_package
  
  rm  ${INSTALLER_NAME_HEAD}*
  
  echo "build package...."
  tar zcf ${INSTALLER_NAME} $PACKAGE_DIR
  
  echo "build package <${INSTALLER_NAME}> successfully!"
  SCP_DST_DIR=root@192.168.104.7:/shared/package/tc-agent/
  ./expect_scp ${INSTALLER_NAME} $SCP_DST_DIR
  echo "scp successfully!"
  
  #!/usr/bin/expect
  set src_file [lindex $argv 0]
  set dst [lindex $argv 1]
  set timeout -1
  set password "Youqi123456"
  
  spawn scp $src_file $dst
  expect {
   "(yes/no)?" {
     send "yes\n"
     expect "*assword:" { send "$password\n"}
    }
    "*assword:" {
     send "$password\n"
    }
  }
  expect "100%"
  expect eof
  ```

  - 上面是两个脚本，shell脚本调用expect脚本。
  -  set 赋值，set host [lindex $argv 0] 就是将参数0赋值给变量host，其中，[] 括起命令，执行括号内命令后返回结果，lindex是取列表中的某个参数，$argv则是参数列表。

##### grep

```
-A NUM, --after-context=NUM
	Print NUM lines of trailing context after matching lines.  Places a line  containing  a  group  separator  (--)  between  		contiguous  groups  of  matches。打印匹配行得后面几行
-B NUM, --before-context=NUM
	Print  NUM  lines  of  leading  context  before  matching  lines.   Places  a  line  containing  a  group separator (--) 		between contiguous groups of matches.打印匹配行得前面几行
-P, --perl-regexp
	Interpret PATTERN as a Perl regular expression  正则匹配
-i, --ignore-case
-v, --invert-match
	Invert the sense of matching, to select non-matching lines.
-r，--recursive
	Read all files under each directory, recursively  递归文件夹
-n, --line-number
    Prefix each line of output with the 1-based line number within its input file. 输出行号
```

##### sed

- **sed** 是一种流编辑器，它是文本处理中非常重要的工具，能够完美的配合正则表达式使用，功能不同凡响。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”（pattern space），接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。文件内容并没有 改变，除非你使用重定向存储输出。Sed主要用来自动编辑一个或多个文件；简化对文件的反复操作；编写转换程序等。

- sed是将处理完的数据打印到屏幕上，并不会修改文件里面的内容，如果需要修改文件里的内容，需要-i选项

- 所有的命令都是单引号引起来的。

- 命令格式

  ```
  sed [options] 'command' file(s)
  sed [options] -f scriptfile file(s)
  ```

- 选项

  ```
  -e<script>或--expression=<script>：以选项中的指定的script来处理输入的文本文件；
  -f<script文件>或--file=<script文件>：以选项中指定的script文件来处理输入的文本文件；
  -h或--help：显示帮助；
  -n或--quiet或——silent：仅显示script处理后的结果；
  -V或--version：显示版本信息。
  ```

  ```
  官方手册上给的
  -e script, --expression=script
      add the script to the commands to be executed
  
  -f script-file, --file=script-file
      add the contents of script-file to the commands to be executed
  这个说明要选项写全部的然后加=号，要不简写有空格没有等于号，直接写命令， 命令都需要单引号引起来
  
  -e选项是加入命令，因为一个单引号引起来的是一个命令，如果需要对一行进行多个操作，需要使用-e选项，这样多个命令就会组合起来，对每行都进行操作。
  ```

- sed命令

  ```
  a\ # 在当前行下面插入文本。
  i\ # 在当前行上面插入文本。
  c\ # 把选定的行改为新的文本。
  d # 删除，删除选择的行。
  D # 删除模板块的第一行。
  s # 替换指定字符
  h # 拷贝模板块的内容到内存中的缓冲区。
  H # 追加模板块的内容到内存中的缓冲区。
  g # 获得内存缓冲区的内容，并替代当前模板块中的文本。
  G # 获得内存缓冲区的内容，并追加到当前模板块文本的后面。
  l # 列表不能打印字符的清单。
  n # 读取下一个输入行，用下一个命令处理新的行而不是用第一个命令。
  N # 追加下一个输入行到模板块后面并在二者间嵌入一个新行，改变当前行号码。
  p # 打印模板块的行。
  P # (大写) 打印模板块的第一行。
  q # 退出Sed。
  b lable # 分支到脚本中带有标记的地方，如果分支不存在则分支到脚本的末尾。
  r file # 从file中读行。
  t label # if分支，从最后一行开始，条件一旦满足或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾。
  T label # 错误分支，从最后一行开始，一旦发生错误或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾。
  w file # 写并追加模板块到file末尾。  
  W file # 写并追加模板块的第一行到file末尾。  
  ! # 表示后面的命令对所有没有被选定的行发生作用。  
  = # 打印当前行号码。  
  # # 把注释扩展到下一个换行符以前。  
  ```

  - 其中a、i、c中后面有一个反斜线，这是一种写法，我们可以用这种来操作，或者将反斜线去掉中间写个空格，这样也可以。

- sed替换标记

  ```
  g # 表示行内全面替换。  
  p # 表示打印行。  
  w # 表示把行写入一个文件。  
  x # 表示互换模板块中的文本和缓冲区中的文本。  
  y # 表示把一个字符翻译为另外的字符（但是不用于正则表达式）
  \1 # 子串匹配标记
  & # 已匹配字符串标记
  ```

  - 上面中的p命令，可以在用逗号选中一些行的时候直接打印，这些标记并不是在每一个命令中都能适用的，只是在一些命令中适用，例如s中适用g

- sed元字符集

  ```
  ^ # 匹配行开始，如：/^sed/匹配所有以sed开头的行。
  $ # 匹配行结束，如：/sed$/匹配所有以sed结尾的行。
  . # 匹配一个非换行符的任意字符，如：/s.d/匹配s后接一个任意字符，最后是d。
  * # 匹配0个或多个字符，如：/*sed/匹配所有模板是一个或多个空格后紧跟sed的行。
  [] # 匹配一个指定范围内的字符，如/[sS]ed/匹配sed和Sed。  
  [^] # 匹配一个不在指定范围内的字符，如：/[^A-RT-Z]ed/匹配不包含A-R和T-Z的一个字母开头，紧跟ed的行。
  \(..\) # 匹配子串，保存匹配的字符，如s/\(love\)able/\1rs，loveable被替换成lovers。
  & # 保存搜索字符用来替换其他字符，如s/love/ **&** /，love这成 **love** 。
  \< # 匹配单词的开始，如:/\<love/匹配包含以love开头的单词的行。
  \> # 匹配单词的结束，如/love\>/匹配包含以love结尾的单词的行。
  x\{m\} # 重复字符x，m次，如：/0\{5\}/匹配包含5个0的行。
  x\{m,\} # 重复字符x，至少m次，如：/0\{5,\}/匹配至少有5个0的行。
  x\{m,n\} # 重复字符x，至少m次，不多于n次，如：/0\{5,10\}/匹配5~10个0的行。  
  ```
  
  - sed默认是基础的正则表达式，需要使用扩展的正则表达式需要使用-r命令，然后就可以使用+、？、｜这些正则了。
  - 有一些命令是以行号作为匹配的，例如打印输出固定行`sed -n '1,5p' file`，除了按行号，我们也可以按照正则表达式来匹配某些行，然后对其进行操作，其中两个正则表达式匹配，中间还可以有逗号，表示一个匹配的范围，而不是某一些具体的行，是一个具体的范围，很多行。惨老下面选定行的范围一节。正则表达式匹配需要定界符。
  - 上面列举的sed命令有一些是需要在前面的，例如替换命令s。但是有一些命令是需要在后面的，例如打印命令p，只有匹配到某些具体的行才打印，所以前面需要一些匹配，行匹配或者正则匹配都行。

###### 替换操作s

```
替换文本中的字符串：

sed 's/book/books/' file
-n选项 和 p命令 一起使用表示只打印那些发生替换的行：

sed -n 's/test/TEST/p' file

直接编辑文件 选项-i ，会匹配file文件中每一行的所有book替换为books：

sed -i 's/book/books/g' file
```

###### 全面替换标记g

```
使用后缀 /g 标记会替换每一行中的所有匹配：

sed 's/book/books/g' file
当需要从第N处匹配开始替换时，可以使用 /Ng：

echo sksksksksksk | sed 's/sk/SK/2g'
skSKSKSKSKSK

echo sksksksksksk | sed 's/sk/SK/3g'
skskSKSKSKSK

echo sksksksksksk | sed 's/sk/SK/4g'
skskskSKSKSK
```

###### 定界符

```
以上命令中字符 / 在sed中作为定界符使用，也可以使用任意的定界符：

sed 's:test:TEXT:g'
sed 's|test|TEXT|g'
定界符出现在样式内部时，需要进行转义：

sed 's/\/bin/\/usr\/local\/bin/g'
```

###### 打印文件中固定行p

- 打印文件中某些固定的行

  ```
  sed -n '1,5p' file
  ```

  - -n的含义是仅显示处理后的结果，例如上面的命令只显示第一行到第五行(p命令处理后的结果，p是打印，所以只显示原本的行，如果其他命令例如s替换，会显示出替换之后的行，原本的行不会显示)，如果没有-n所有的行都会显示，其中处理的行会显示两遍，例如上面的命令如果没有-n，其中第一行到第五行会显示两遍，其余的行会显示一遍，因为第一行和第五行有命令处理了，原本的和命令处理过的都会显示，其余的行没有处理，只显示原本的。

###### 删除操作d

- 删除空白行：

  ```shell
  sed '/^$/d' file
  ```

  删除文件的第2行：

  ```shell
  sed '2d' file
  ```

  删除文件的第2行到末尾所有行：

  ```shell
  sed '2,$d' file
  ```

  删除文件最后一行：

  ```shell
  sed '$d' file
  ```

  - $符号表示最后一行，例如1，$d，删除所有的。

  删除文件中所有开头是test的行：
  
  ```shell
  sed '/^test/'d file
  ```

###### 已匹配字符串标记&

- 正则表达式 \w+ 匹配每一个单词，使用 [&] 替换它，& 对应于之前所匹配到的单词：

  ```shell
  echo this is a test line | sed 's/\w\+/[&]/g'
  [this] [is] [a] [test] [line]
  ```

  所有以192.168.0.1开头的行都会被替换成它自已加localhost：

  ```shell
  sed 's/^192.168.0.1/&localhost/' file
  192.168.0.1localhost
  ```

- 已匹配字符串和子串匹配是有区别的，子串是用括号包括的匹配。

###### 子串匹配标记

- 匹配给定样式的其中一部分：

  ```shell
  echo this is digit 7 in a number | sed 's/digit \([0-9]\)/\1/'
  this is 7 in a number
  ```

  命令中 digit 7，被替换成了 7。样式匹配到的子串是 7，(..) 用于匹配子串，对于匹配到的第一个子串就标记为 **\1** ，依此类推匹配到的第二个结果就是 **\2** ，例如：

  ```shell
  echo aaa BBB | sed 's/\([a-z]\+\) \([A-Z]\+\)/\2 \1/'
  BBB aaa
  ```

  love被标记为1，所有loveable会被替换成lovers，并打印出来：

  ```shell
  sed -n 's/\(love\)able/\1rs/p' file
  ```

- 上面中的含义就是匹配到的那个字串后续用\1这种数字来标记出来，然后相当于在进行组合。

###### 引用

- sed表达式可以使用单引号来引用，但是如果表达式内部包含变量字符串，就需要使用双引号。

  ```shell
  test=hello
  echo hello WORLD | sed "s/$test/HELLO"
  HELLO WORLD
  ```

###### 选定行的范围

- 所有在模板test和check所确定的范围内的行都被打印：

  ```shell
  sed -n '/test/,/check/p' file
  ```

  打印从第5行开始到第一个包含以test开始的行之间的所有行：

  ```shell
  sed -n '5,/^test/p' file
  ```

  对于模板test和west之间的行，每行的末尾用字符串aaa bbb替换：

  ```shell
  sed '/test/,/west/s/$/aaa bbb/' file
  ```

- 每一个匹配都是用斜杠引起来的，如果没有逗号表示匹配一个，也必须用斜杠引起来
- 这种选定行的范围在好多地方能用，例如s命令替换也可以选定行的范围。这样这个命令就可以在好些地方使用了，例如d，s这些
- 这个逗号表示一个范围，跟1，5一样表示第一行到第五行，定界符中间的逗号也表示一个范围，两个匹配之间的都在选定的范围之内

###### 多点编辑e命令

- -e选项允许在同一行里执行多条命令：

  ```shell
  sed -e '1,5d' -e 's/test/check/' file
  ```

  上面sed表达式的第一条命令删除1至5行，第二条命令用check替换test。命令的执行顺序对结果有影响。如果两个命令都是替换命令，那么第一个替换命令将影响第二个替换命令的结果。

  和 -e 等价的命令是 --expression：

  ```shell
  sed --expression='s/test/check/' --expression='/love/d' file
  ```

###### 从文件读入r命令

- file里的内容被读进来，显示在与test匹配的行后面，如果匹配多行，则file的内容将显示在所有匹配行的下面：

  ```shell
  sed '/test/r file' filename
  ```

###### 写入命令w命令

- 在example中所有包含test的行都被写入file里：

  ```shell
  sed -n '/test/w file' example
  ```

###### 追加行下a\命令

- 将 this is a test line 追加到 以test 开头的行后面：

  ```shell
  sed '/^test/a\this is a test line' file
  ```

  在 test.conf 文件第2行之后插入 this is a test line：

  ```shell
  sed -i '2a\this is a test line' test.conf
  ```

###### 插入行上i\命令

- 将 this is a test line 追加到以test开头的行前面：

  ```shell
  sed '/^test/i\this is a test line' file
  ```

  在test.conf文件第5行之前插入this is a test line：

  ```shell
  sed -i '5i\this is a test line' test.conf
  ```

###### 变形y命令

- 把1~10行内所有abcde转变为大写，注意，正则表达式元字符不能使用这个命令：

  ```shell
  sed '1,10y/abcde/ABCDE/' file
  ```

###### 退出q命令

- 打印完第10行后，退出sed

  ```shell
  sed '10q' file
  ```

###### 下一个n命令

- 如果test被匹配，则移动到匹配行的下一行，替换这一行的aa，变为bb，并打印该行，然后继续：

  ```shell
  sed '/test/{ n; s/aa/bb/; }' file
  ```

###### 保持和获取h和G命令

- 在sed处理文件的时候，每一行都被保存在一个叫模式空间的临时缓冲区中，除非行被删除或者输出被取消，否则所有被处理的行都将 打印在屏幕上。接着模式空间被清空，并存入新的一行等待处理。

  ```shell
  sed -e '/test/h' -e '$G' file
  ```

  在这个例子里，匹配test的行被找到后，将存入模式空间，h命令将其复制并存入一个称为保持缓存区的特殊缓冲区内。第二条语句的意思是，当到达最后一行后，G命令取出保持缓冲区的行，然后把它放回模式空间中，且追加到现在已经存在于模式空间中的行的末尾。在这个例子中就是追加到最后一行。简单来说，任何包含test的行都被复制并追加到该文件的末尾。

###### 保持和互换h和x命令

- 互换模式空间和保持缓冲区的内容。也就是把包含test与check的行互换：

  ```shell
  sed -e '/test/h' -e '/check/x' file
  ```

###### 打印奇数行或者偶数行

- 方法1：

  ```shell
  sed -n 'p;n' test.txt  #奇数行
  sed -n 'n;p' test.txt  #偶数行
  ```

  方法2：

  ```shell
  sed -n '1~2p' test.txt  #奇数行
  sed -n '2~2p' test.txt  #偶数行
  ```

###### 打印匹配字符串的下一行

- ```
  grep -A 1 SCC URFILE sed -n '/SCC/{n;p}' URFILE awk '/SCC/{getline; print}' URFILE
  ```

###### 脚本命令的寻址方式

- 前面在介绍各个脚本命令时，我们一直忽略了对 address 部分的介绍。对各个脚本命令来说，address 用来表明该脚本命令作用到文本中的具体行。

- 默认情况下，sed 命令会作用于文本数据的所有行。如果只想将命令作用于特定行或某些行，则必须写明 address 部分，表示的方法有以下 2 种：

  1. 以数字形式指定行区间；
  2. 用文本模式指定具体行区间。

- 以上两种形式都可以使用如下这 2 种格式，分别是：

  ```
  [address]脚本命令
  
  或者
  
  address {
    多个脚本命令
  }
  ```

  - 如果address中后面只是一个脚本命令，可以不用写中括号，如果是多个命令，需要写上中括号，例如上面的n命令。

- $符号表示最后一行，例如1，$d，删除所有的。

- 如果有匹配的话需要写上中括号，如果没有匹配的话作用于所有，不用写括号也行，直接用分号隔开。

##### awk

- **awk** 是一种编程语言，用于在linux/unix下对文本和数据进行处理。数据可以来自标准输入(stdin)、一个或多个文件，或其它命令的输出。它支持用户自定义函数和动态正则表达式等先进功能，是linux/unix下的一个强大编程工具。它在命令行中使用，但更多是作为脚本来使用。awk有很多内建的功能，比如数组、函数等，这是它和C语言的相同之处，灵活性是awk最大的优势。
- 和 sed 命令类似，awk 命令也是逐行扫描文件（从第 1 行到最后一行），寻找含有目标文本的行，如果匹配成功，则会在该行上执行用户想要的操作；反之，则不对行做任何处理。

###### sed和AWK区别

- sed常用于数据修改，awk常用于数据切片和数据格式化

- sed一般对行进行操作，awk一般对列进行操作。

- 使用Awk，我们可以做以下事情：

  ```
  1，将文本文件视为由字段和记录组成的文本数据库；
  2，在操作文本数据库的过程中能够使用变量；
  3，能够使用数学运算和字符串操作
  4，能够使用常见的编程结构，例如条件分支与循环；
  5，能够格式化输出；
  6，能够自定义函数；
  7，能够在awk脚本中执行UNIX命令；
  8，能够处理UNIX命令的输出结果；
  ```

- sed的核心是正则，awk的核心是格式化

- 对于sed， 基本的两个概念是匹配和行为。

  - 匹配是通过区域选择加上[正则表达式](https://www.zhihu.com/search?q=正则表达式&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A509302805})实现，比如“3到6行以This开头的”
  - 行为是**增删改查**。可以在某个位置新增或删除一行，可以通过正则表达式进行变量替换，可以显示满足某些条件的行。配合shell的[批处理](https://www.zhihu.com/search?q=批处理&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A509302805})就会很强大， 比如我想把所有文件的开头添加一个注释，比如我想把所有文件的某一个变量进行替换，比如我想把所有文件满足某些条件的行进行合并和拆分。
  - 同时，sed提供了一个辅助空间（hold space）可以实现逆序输出等神操作。
  - 另外，sed的用法非常灵活，你可以将匹配和行为进行不同的**嵌套**，举个复杂的例子“将第某行到某行之间的满足A条件的里面满足B条件的行进行C操作和D操作并且将E条件的行进行F操作”这样的灵活组合方式怕是也只有sed了， 你用python+re的方式估计不少代码量。
    - 使用-e选项可以对一行执行多个命令

- awk，经常用于格式化输出，也就是将数据按照我们想要的方式来显示，并且可以做一些基本的统计工作

  - 它的运作模式是“预处理+逐行处理+最终处理“
  - 一般我们只用“逐行处理”比如对于满足条件的某些行，我们打印某某列。通过指定分隔符我们很容易的对列进行操作。
  - 如果要进行一些统计工作比如文件内容是所有学生的成绩，想要打印学生的平均成绩，就需要“预处理”和“最终处理”
  - 预处理来定义变量，逐行处理来修改变量，最终处理来打印变量。
  - 不仅仅是变量，还可以定义数组，最终处理的时候还支持for循环。所以你可以在遍历的时候存入所有你需要的数据，然后在最终处理的时候通过for循环来打印几乎任何你想要的格式。

###### 语法格式

```
awk [options] 'script' var=value file(s)
awk [options] -f scriptfile var=value file(s)
```

- 常用命令选项
  - **-F fs** fs指定输入分隔符，fs可以是字符串或正则表达式，如-F:，默认的分隔符是连续的空格或制表符
    - 每一行开始的空格都会被去掉，不会当作分隔符。
  - **-v var=value** 赋值一个用户定义变量，将外部变量传递给awk
  - **-f scripfile** 从脚本文件中读取awk命令
  - **-m[fr] val** 对val值设置内在限制，-mf选项限制分配给val的最大块数目；-mr选项限制记录的最大数目。这两个功能是Bell实验室版awk的扩展功能，在标准awk中不适用。
- var=value是从外部传入变量，需要配合-v选项来使用。

###### awk模式和操作

- awk脚本是由模式和操作组成的。
- 模式可以是以下任意一个
  - /正则表达式/：使用通配符的扩展集。
    - 正则表达式匹配需要用斜杠包起来
  - 关系表达式：使用运算符进行操作，可以是字符串或数字的比较测试。
  - 模式匹配表达式：用运算符`~`（匹配）和`!~`（不匹配）。
  - BEGIN语句块、pattern语句块、END语句块：参见awk的工作原理
- 操作由一个或多个命令、函数、表达式组成，之间由换行符或分号隔开，并位于大括号内，主要部分是：
  - 变量或数组赋值
  - 输出命令
  - 内置函数
  - 控制流语句

###### awk模式

-  awk中的模式匹配在awk程序命令中非常重要，它决定着被处理数据文件中到底哪一行需要处理，并且做出什么样的处理。

- 关系表达式

  - awk可以支持许多关系运算符，例如>, <, ==等。对于数据文件，我们经常需要把比较关系作为匹配模式。

    ```
    #打印第2列的成绩超过80的行
    awk '$2 > 80 { print }' scores.txt
    ```

- 正则表达式

  - 正则表达式做为匹配模式， **一定要把表达式放在两条斜线之间，/regular_expression/**

    ```
    #输出以字符T开头的行
    awk '/^T/ { print }' scores.txt
        
    #输出以Tom或者Kon开头的行
    awk '/^(Tom|Kon)/ { print }' scores.txt
    ```

- 混合模式

  - 混合模式就是把关系表达式和正则表达式结合起来，可以使用&&, ||, !来连接，不过它们都需要在单引号以内。

    ```
    #混合模式
    awk '/^K/ && $2 > 80 { print }' scores.txt
    输出以K开头的行，同时第2列分数大于80分的行。
    ```

- 区间模式

  - 用于匹配一段连续的文本行。语法为：`awk 'pattern1, pattern2 { actions }' datafile`

    ```
    #区间模式
    awk '/^Nancy/, $2==92 { print }' scores.txt
    以Nancy开头的行为起始，第2列等于92分的行为终止，输出之间的连续的行。 注意：当满足patter1或者pattern2的行不只一行的时候，会自动选择第一个符合要求的行。
    ```

###### awk脚本基本构造

```shell
awk 'BEGIN{ print "start" } pattern{ commands } END{ print "end" }' file
```

- 一个awk脚本通常由：BEGIN语句块、能够使用模式匹配的通用语句块、END语句块3部分组成，这三个部分是可选的。任意一个部分都可以不出现在脚本中，脚本通常是被 **单引号** 中，例如：

```shell
awk 'BEGIN{ i=0 } { i++ } END{ print i }' filename
```

- 其中pattern表示上面的模式，意思是匹配的东西。

###### awk工作原理

- ```shell
  awk 'BEGIN{ commands } pattern{ commands } END{ commands }'
  ```

  - 第一步：执行`BEGIN{ commands }`语句块中的语句；
  - 第二步：从文件或标准输入(stdin)读取一行，然后执行`pattern{ commands }`语句块，它逐行扫描文件，从第一行到最后一行重复这个过程，直到文件全部被读取完毕。
  - 第三步：当读至输入流末尾时，执行`END{ commands }`语句块。

- **BEGIN语句块** 在awk开始从输入流中读取行 **之前** 被执行，这是一个可选的语句块，比如变量初始化、打印输出表格的表头等语句通常可以写在BEGIN语句块中。

- **END语句块** 在awk从输入流中读取完所有的行 **之后** 即被执行，比如打印所有行的分析结果这类信息汇总都是在END语句块中完成，它也是一个可选语句块。

- **pattern语句块** 中的通用命令是最重要的部分，它也是可选的。如果没有提供pattern语句块，则默认执行`{ print }`，即打印每一个读取到的行，awk读取的每一行都会执行该语句块。

  - pattern是上面的模式那个东西。

- 实例

  ```shell
  echo -e "A line 1\nA line 2" | awk 'BEGIN{ print "Start" } { print } END{ print "End" }'
  Start
  A line 1
  A line 2
  End
  ```

- 当使用不带参数的`print`时，它就打印当前行，当`print`的参数是以逗号进行分隔时，打印时则以空格作为定界符。在awk的print语句块中双引号是被当作拼接符使用，例如：

  ```shell
  echo | awk '{ var1="v1"; var2="v2"; var3="v3"; print var1,var2,var3; }' 
  v1 v2 v3
  ```

  双引号拼接使用：

  ```shell
  echo | awk '{ var1="v1"; var2="v2"; var3="v3"; print var1"="var2"="var3; }'
  v1=v2=v3
  ```

  { }类似一个循环体，会对文件中的每一行进行迭代，通常变量初始化语句（如：i=0）以及打印文件头部的语句放入BEGIN语句块中，将打印的结果等语句放在END语句块中。

###### awk内置变量

- 说明：`[A][N][P][G]`表示第一个支持变量的工具，[A]=awk、[N]=nawk、[P]=POSIXawk、[G]=gawk

  ```shell
   **$n**  当前记录的第n个字段，比如n为1表示第一个字段，n为2表示第二个字段。 
   **$0**  这个变量包含执行过程中当前行的文本内容。
  [N]  **ARGC**  命令行参数的数目。
  [G]  **ARGIND**  命令行中当前文件的位置（从0开始算）。
  [N]  **ARGV**  包含命令行参数的数组。
  [G]  **CONVFMT**  数字转换格式（默认值为%.6g）。
  [P]  **ENVIRON**  环境变量关联数组。
  [N]  **ERRNO**  最后一个系统错误的描述。
  [G]  **FIELDWIDTHS**  字段宽度列表（用空格键分隔）。
  [A]  **FILENAME**  当前输入文件的名。
  [P]  **FNR**  同NR，但相对于当前文件。
  [A]  **FS**  字段分隔符（默认是任何空格）。
  [G]  **IGNORECASE**  如果为真，则进行忽略大小写的匹配。
  [A]  **NF**  表示字段数，在执行过程中对应于当前的字段数。
  [A]  **NR**  表示记录数，在执行过程中对应于当前的行号。
  [A]  **OFMT**  数字的输出格式（默认值是%.6g）。
  [A]  **OFS**  输出字段分隔符（默认值是一个空格）。
  [A]  **ORS**  输出记录分隔符（默认值是一个换行符）。
  [A]  **RS**  记录分隔符（默认是一个换行符）。
  [N]  **RSTART**  由match函数所匹配的字符串的第一个位置。
  [N]  **RLENGTH**  由match函数所匹配的字符串的长度。
  [N]  **SUBSEP**  数组下标分隔符（默认值是34）。
  ```

- 转义序列

  ```
  \\ \自身
  \$ 转义$
  \t 制表符
  \b 退格符
  \r 回车符
  \n 换行符
  \c 取消换行
  ```

- 示例

  ```shell
  echo -e "line1 f2 f3\nline2 f4 f5\nline3 f6 f7" | awk '{print "Line No:"NR", No of fields:"NF, "$0="$0, "$1="$1, "$2="$2, "$3="$3}' 
  Line No:1, No of fields:3 $0=line1 f2 f3 $1=line1 $2=f2 $3=f3
  Line No:2, No of fields:3 $0=line2 f4 f5 $1=line2 $2=f4 $3=f5
  Line No:3, No of fields:3 $0=line3 f6 f7 $1=line3 $2=f6 $3=f7
  ```

- 使用`print $NF`可以打印出一行中的最后一个字段，使用`$(NF-1)`则是打印倒数第二个字段，其他以此类推：

  ```shell
  echo -e "line1 f2 f3\n line2 f4 f5" | awk '{print $NF}'
  f3
  f5
  echo -e "line1 f2 f3\n line2 f4 f5" | awk '{print $(NF-1)}'
  f2
  f4
  ```

  打印每一行的第二和第三个字段：

  ```shell
  awk '{ print $2,$3 }' filename
  ```

  统计文件中的行数：

  ```shell
  awk 'END{ print NR }' filename
  ```

  以上命令只使用了END语句块，在读入每一行的时，awk会将NR更新为对应的行号，当到达最后一行NR的值就是最后一行的行号，所以END语句块中的NR就是文件的行数。

- 一个每一行中第一个字段值累加的例子：

  ```shell
  seq 5 | awk 'BEGIN{ sum=0; print "总和：" } { print $1"+"; sum+=$1 } END{ print "等于"; print sum }' 
  总和：
  1+
  2+
  3+
  4+
  5+
  等于
  15
  ```

- NF表示字段数，$字符表示第几个字段，所以$NF表示最后一个字段。

###### 将外部变量传递给awk

- 借助 **`-v`选项** ，可以将外部值（并非来自stdin）传递给awk：

  ```shell
  VAR=10000
  echo | awk -v VARIABLE=$VAR '{ print VARIABLE }'
  ```

  另一种传递外部变量方法：

  ```shell
  var1="aaa"
  var2="bbb"
  echo | awk '{ print v1,v2 }' v1=$var1 v2=$var2
  ```

  当输入来自于文件时使用：

  ```shell
  awk '{ print v1,v2 }' v1=$var1 v2=$var2 filename
  ```

  以上方法中，变量之间用空格分隔作为awk的命令行参数跟随在BEGIN、{}和END语句块之后。

###### 查找进程pid

```shell
netstat -antup | grep 7770 | awk '{ print $NF NR}' | awk '{ print $1}'
```

###### awk运算与判断

- 作为一种程序设计语言所应具有的特点之一，awk支持多种运算，这些运算与C语言提供的基本相同。awk还提供了一系列内置的运算函数（如log、sqr、cos、sin等）和一些用于对字符串进行操作（运算）的函数（如length、substr等等）。这些函数的引用大大的提高了awk的运算功能。作为对条件转移指令的一部分，关系判断是每种程序设计语言都具备的功能，awk也不例外，awk中允许进行多种测试，作为样式匹配，还提供了模式匹配表达式~（匹配）和!~（不匹配）。作为对测试的一种扩充，awk也支持用逻辑运算符。

- 算数运算符

  | 运算符 | 描述                       |
  | ------ | -------------------------- |
  | + -    | 加，减                     |
  | * / &  | 乘，除与求余               |
  | + - !  | 一元加，减和逻辑非         |
  | ^ ***  | 求幂                       |
  | ++ --  | 增加或减少，作为前缀或后缀 |

  - 例：

    ```shell
    awk 'BEGIN{a="b";print a++,++a;}'
    0 2
    ```

    注意：所有用作算术运算符进行操作，操作数自动转为数值，所有非数值都变为0

- 赋值运算符

  | 运算符                  | 描述     |
  | ----------------------- | -------- |
  | = += -= *= /= %= ^= **= | 赋值语句 |

  例：

  ```shell
  a+=5; 等价于：a=a+5; 其它同类
  ```

- 逻辑运算符

  | 运算符 | 描述   |
  | ------ | ------ |
  | `||`   | 逻辑或 |
  | &&     | 逻辑与 |

  例：

  ```shell
  awk 'BEGIN{a=1;b=2;print (a>5 && b<=2),(a>5 || b<=2);}'
  0 1
  ```

- 正则运算符

  | 运算符 | 描述                             |
  | ------ | -------------------------------- |
  | ~ !~   | 匹配正则表达式和不匹配正则表达式 |

  ```
  ^ 行首
  $ 行尾
  . 除了换行符以外的任意单个字符
  * 前导字符的零个或多个
  .* 所有字符
  [] 字符组内的任一字符
  [^]对字符组内的每个字符取反(不匹配字符组内的每个字符)
  ^[^] 非字符组内的字符开头的行
  [a-z] 小写字母
  [A-Z] 大写字母
  [a-Z] 小写和大写字母
  [0-9] 数字
  \< 单词头单词一般以空格或特殊字符做分隔,连续的字符串被当做单词
  \> 单词尾
  ```

  > 正则需要用 /正则/ 包围住

  例：

  ```shell
  awk 'BEGIN{a="100testa";if(a ~ /^100*/){print "ok";}}'
  ok
  ```

  - 这个是一个运算符，表示匹配或者不匹配正则。例如上面的a匹配正则的话，这个表达式返回值就是正确的，不匹配的话就是不正确的。

- 关系运算符

  | 运算符          | 描述       |
  | --------------- | ---------- |
  | < <= > >= != == | 关系运算符 |

  例：

  ```shell
  awk 'BEGIN{a=11;if(a >= 9){print "ok";}}'
  ok
  ```

  注意：> < 可以作为字符串比较，也可以用作数值比较，关键看操作数如果是字符串就会转换为字符串比较。两个都为数字才转为数值比较。字符串比较：按照ASCII码顺序比较。

- 其他运算符

  | 运算符 | 描述                 |
  | ------ | -------------------- |
  | $      | 字段引用             |
  | 空格   | 字符串连接符         |
  | ?:     | C条件表达式          |
  | in     | 数组中是否存在某键值 |

  例：

  ```shell
  awk 'BEGIN{a="b";print a=="b"?"ok":"err";}'
  ok
  awk 'BEGIN{a="b";arr[0]="b";arr[1]="c";print (a in arr);}'
  0
  awk 'BEGIN{a="b";arr[0]="b";arr["b"]="c";print (a in arr);}'
  1
  ```

###### 读取下一条记录

- awk中`next`语句使用：在循环逐行匹配，如果遇到next，就会跳过当前行，直接忽略下面语句。而进行下一行匹配。next语句一般用于多行合并：

  ```shell
  cat text.txt
  a
  b
  c
  d
  e
  
  awk 'NR%2==1{next}{print NR,$0;}' text.txt
  2 b
  4 d
  ```

  当记录行号除以2余1，就跳过当前行。下面的`print NR,$0`也不会执行。下一行开始，程序有开始判断`NR%2`值。这个时候记录行号是`：2` ，就会执行下面语句块：`'print NR,$0'`

  分析发现需要将包含有“web”行进行跳过，然后需要将内容与下面行合并为一行：

  ```shell
  cat text.txt
  web01[192.168.2.100]
  httpd            ok
  tomcat               ok
  sendmail               ok
  web02[192.168.2.101]
  httpd            ok
  postfix               ok
  web03[192.168.2.102]
  mysqld            ok
  httpd               ok
  0
  awk '/^web/{T=$0;next;}{print T":"t,$0;}' text.txt
  web01[192.168.2.100]:   httpd            ok
  web01[192.168.2.100]:   tomcat               ok
  web01[192.168.2.100]:   sendmail               ok
  web02[192.168.2.101]:   httpd            ok
  web02[192.168.2.101]:   postfix               ok
  web03[192.168.2.102]:   mysqld            ok
  web03[192.168.2.102]:   httpd               ok
  ```

  - 这个next语句块必须和剩下的语句块分开来写。

###### 简单的读取一条记录

- `awk getline`用法：输出重定向需用到`getline函数`。getline从标准输入、管道或者当前正在处理的文件之外的其他输入文件获得输入。它负责从输入获得下一行的内容，并给NF,NR和FNR等内建变量赋值。如果得到一条记录，getline函数返回1，如果到达文件的末尾就返回0，如果出现错误，例如打开文件失败，就返回-1。这句话说明从管道、标准输入或者当前处理文件的其他输入文件需要getline函数，第三个是当前文件的其他文件。这个是awk语句块之内的获取数据，并不是echo | awk这样从外面给awk内容数据的。

  getline语法：getline var，变量var包含了特定行的内容。

  awk getline从整体上来说，用法说明：

  - **当其左右无重定向符`|`或`<`时：** getline作用于当前文件，读入当前文件的第一行给其后跟的变量`var`或`$0`（无变量），应该注意到，由于awk在处理getline之前已经读入了一行，所以getline得到的返回结果是隔行的。
  - **当其左右有重定向符`|`或`<`时：** getline则作用于定向输入文件，由于该文件是刚打开，并没有被awk读入一行，只是getline读入，那么getline返回的是该文件的第一行，而不是隔行。

  **示例：**

  执行linux的`date`命令，并通过管道输出给`getline`，然后再把输出赋值给自定义变量out，并打印它：

  ```shell
  awk 'BEGIN{ "date" | getline out; print out }' test
  ```

  执行shell的date命令，并通过管道输出给getline，然后getline从管道中读取并将输入赋值给out，split函数把变量out转化成数组mon，然后打印数组mon的第二个元素：

  ```shell
  awk 'BEGIN{ "date" | getline out; split(out,mon); print mon[2] }' test
  ```

  命令ls的输出传递给geline作为输入，循环使getline从ls的输出中读取一行，并把它打印到屏幕。这里没有输入文件，因为BEGIN块在打开输入文件前执行，所以可以忽略输入文件。

  ```shell
  awk 'BEGIN{ while( "ls" | getline) print }'
  ```

###### 打印某些具体的行

- awk打印某些具体的行

  ```
  awk ' NR>=1 && NR <=5 {print}' file
  ```

  - NR表示当前的行数，为系统内置变量，print表示打印具体的行，print $1表示打印第一个分割的字符串，不加$表示打印一整行

###### 输出到一个文件

- awk中允许用如下方式将结果输出到一个文件：

  ```shell
  echo | awk '{printf("hello word!n") > "datafile"}'
  # 或
  echo | awk '{printf("hello word!n") >> "datafile"}'
  ```

  - 如果没有echo，此时会在命令行中一直等待输入，但是总是写进去的是hello，world
  - 如果有echo就不会等待。

- 注意此处用的是printf不是print

  - printf更加自由化，一切输出格式都需要自己定义。

    print是定义好的printf，通过内部变量能改变已经定义好的格式。

  - printf是函数，需要加小括号。

- printf的用法：

  ```
  格式：printf "格式化"，变量1，变量2
  
  格式化内容：
  
  1.数据格式
  
    十进制整数：%d
  
    科学计数法显示数字：%e
  
    浮点数：%f
  
    字符串：%s
  
    ASCII码：%c
  
  2.换行，空格等
  
    换行：\n
  
    空格：\t
  
  3.对齐
  
    左对齐：“-”，默认右对齐。
  ```

  ```
  shell@ubuntu:~/test$ echo 15|awk '{printf ("d:%15d\nf:%10.2f\ns:%5s",$0,$0,$0)}'
  d:             15
  f:     15.00
  s:   15<br><br>shell@ubuntu:~/test$ echo 15|awk '{printf ("d:|%-15d|\nf:%10.2f\ns:%5s",$0,$0,$0)}'<br>d:|15             |<br>f:     15.00<br>s:   15<br><br><br>
  ```

  

###### 关闭文件

- awk中允许在程序中关闭一个输入或输出文件，方法是使用awk的close语句。

  ```shell
  close("filename")
  ```

  filename可以是getline打开的文件，也可以是stdin，包含文件名的变量或者getline使用的确切命令。或一个输出文件，可以是stdout，包含文件名的变量或使用管道的确切命令。

###### 设置字段定界符

- 默认的字段定界符是空格，可以使用`-F "定界符"` 明确指定一个定界符：

  ```shell
  awk -F: '{ print $NF }' /etc/passwd
  # 或
  awk 'BEGIN{ FS=":" } { print $NF }' /etc/passwd
  ```

  在`BEGIN语句块`中则可以用`OFS=“定界符”`设置输出字段的定界符。

###### 流程控制语句

- 在linux awk的while、do-while和for语句中允许使用break,continue语句来控制流程走向，也允许使用exit这样的语句来退出。break中断当前正在执行的循环并跳到循环外执行下一条语句。if 是流程选择用法。awk中，流程控制语句，语法结构，与c语言类型。有了这些语句，其实很多shell程序都可以交给awk，而且性能是非常快的。下面是各个语句用法。

  - 条件判断语句

  ```shell
  if(表达式)
    语句1
  else
    语句2
  ```

  格式中语句1可以是多个语句，为了方便判断和阅读，最好将多个语句用{}括起来。awk分枝结构允许嵌套，其格式为：

  ```shell
  if(表达式)
    {语句1}
  else if(表达式)
    {语句2}
  else
    {语句3}
  ```

  示例：

  ```shell
  awk 'BEGIN{
  test=100;
  if(test>90){
    print "very good";
    }
    else if(test>60){
      print "good";
    }
    else{
      print "no pass";
    }
  }'
  
  very good
  ```

  每条命令语句后面可以用`;` **分号** 结尾。

  - while语句

  ```shell
  while(表达式)
    {语句}
  ```

  示例：

  ```shell
  awk 'BEGIN{
  test=100;
  total=0;
  while(i<=test){
    total+=i;
    i++;
  }
  print total;
  }'
  5050
  ```

  - for循环

  for循环有两种格式：

  格式1：

  ```shell
  for(变量 in 数组)
    {语句}
  ```

  示例：

  ```shell
  awk 'BEGIN{
  for(k in ENVIRON){
    print k"="ENVIRON[k];
  }
  
  }'
  TERM=linux
  G_BROKEN_FILENAMES=1
  SHLVL=1
  pwd=/root/text
  ...
  logname=root
  HOME=/root
  SSH_CLIENT=192.168.1.21 53087 22
  ```

  注：ENVIRON是awk常量，是子典型数组。

  格式2：

  ```shell
  for(变量;条件;表达式)
    {语句}
  ```

  示例：

  ```shell
  awk 'BEGIN{
  total=0;
  for(i=0;i<=100;i++){
    total+=i;
  }
  print total;
  }'
  5050
  ```

  - do循环

  ```shell
  do
  {语句} while(条件)
  ```

  例子：

  ```shell
  awk 'BEGIN{ 
  total=0;
  i=0;
  do {total+=i;i++;} while(i<=100)
    print total;
  }'
  5050
  ```

  - 其他语句

  - **break** 当 break 语句用于 while 或 for 语句时，导致退出程序循环。
  - **continue** 当 continue 语句用于 while 或 for 语句时，使程序循环移动到下一个迭代。
  - **next** 能能够导致读入下一个输入行，并返回到脚本的顶部。这可以避免对当前输入行执行其他的操作过程。
  - **exit** 语句使主输入循环退出并将控制转移到END,如果END存在的话。如果没有定义END规则，或在END中应用exit语句，则终止脚本的执行。

###### 数组

- 数组是awk的灵魂，处理文本中最不能少的就是它的数组处理。因为数组索引（下标）可以是数字和字符串在awk中数组叫做关联数组(associative arrays)。awk 中的数组不必提前声明，也不必声明大小。数组元素用0或空字符串来初始化，这根据上下文而定。

- awk数组目前不支持一次性全部赋值，需要一个一个的赋值。

- 数组的定义

  数字做数组索引（下标）：

  ```shell
  Array[1]="sun"
  Array[2]="kai"
  ```

  字符串做数组索引（下标）：

  ```shell
  Array["first"]="www"
  Array"[last"]="name"
  Array["birth"]="1987"
  ```

  使用中`print Array[1]`会打印出sun；使用`print Array[2]`会打印出kai；使用`print["birth"]`会得到1987。

- 读取数组的值

  ```shell
  { for(item in array) {print array[item]}; }       #输出的顺序是随机的
  { for(i=1;i<=len;i++) {print array[i]}; }         #Len是数组的长度
  ```

- 得到数组长度：

  ```shell
  awk 'BEGIN{info="it is a test";lens=split(info,tA," ");print length(tA),lens;}'
  4 4
  ```

  length返回字符串以及数组长度，split进行分割字符串为数组，也会返回分割得到数组长度。

  ```shell
  awk 'BEGIN{info="it is a test";split(info,tA," ");print asort(tA);}'
  4
  ```

  asort对数组进行排序，返回数组长度。

- 输出数组内容（无序，有序输出）：

  ```shell
  awk 'BEGIN{info="it is a test";split(info,tA," ");for(k in tA){print k,tA[k];}}'
  4 test
  1 it
  2 is
  3 a 
  ```

  `for…in`输出，因为数组是关联数组，默认是无序的。所以通过`for…in`得到是无序的数组。如果需要得到有序数组，需要通过下标获得。

  ```shell
  awk 'BEGIN{info="it is a test";tlen=split(info,tA," ");for(k=1;k<=tlen;k++){print k,tA[k];}}'
  1 it
  2 is
  3 a
  4 test
  ```

  注意：数组下标是从1开始，与C数组不一样。

- 判断键值存在以及删除键值：

  ```shell
  # 错误的判断方法：
  awk 'BEGIN{tB["a"]="a1";tB["b"]="b1";if(tB["c"]!="1"){print "no found";};for(k in tB){print k,tB[k];}}' 
  no found
  a a1
  b b1
  c
  ```

  以上出现奇怪问题，`tB[“c”]`没有定义，但是循环时候，发现已经存在该键值，它的值为空，这里需要注意，awk数组是关联数组，只要通过数组引用它的key，就会自动创建改序列。

  ```shell
  # 正确判断方法：
  awk 'BEGIN{tB["a"]="a1";tB["b"]="b1";if( "c" in tB){print "ok";};for(k in tB){print k,tB[k];}}'  
  a a1
  b b1
  ```

  `if(key in array)`通过这种方法判断数组中是否包含`key`键值。

  ```shell
  #删除键值：
  awk 'BEGIN{tB["a"]="a1";tB["b"]="b1";delete tB["a"];for(k in tB){print k,tB[k];}}'                     
  b b1
  ```

  `delete array[key]`可以删除，对应数组`key`的，序列值。

- 二维、多维数组使用

  - 多维数组也是一个一个的赋值，所以不用考虑一次性赋值和访问的问题。

  awk的多维数组在本质上是一维数组，更确切一点，awk在存储上并不支持多维数组。awk提供了逻辑上模拟二维数组的访问方式。例如，`array[2,4]=1`这样的访问是允许的。awk使用一个特殊的字符串`SUBSEP(�34)`作为分割字段，在上面的例子中，关联数组array存储的键值实际上是2�344。

  类似一维数组的成员测试，多维数组可以使用`if ( (i,j) in array)`这样的语法，但是下标必须放置在圆括号中。类似一维数组的循环访问，多维数组使用`for ( item in array )`这样的语法遍历数组。与一维数组不同的是，多维数组必须使用`split()`函数来访问单独的下标分量。

  ```shell
  awk 'BEGIN{
  for(i=1;i<=9;i++){
    for(j=1;j<=9;j++){
      tarr[i,j]=i*j; print i,"*",j,"=",tarr[i,j];
    }
  }
  }'
  1 * 1 = 1
  1 * 2 = 2
  1 * 3 = 3
  1 * 4 = 4
  1 * 5 = 5
  1 * 6 = 6 
  ...
  9 * 6 = 54
  9 * 7 = 63
  9 * 8 = 72
  9 * 9 = 81
  ```

  可以通过`array[k,k2]`引用获得数组内容。

  另一种方法：

  ```shell
  awk 'BEGIN{
  for(i=1;i<=9;i++){
    for(j=1;j<=9;j++){
      tarr[i,j]=i*j;
    }
  }
  for(m in tarr){
    split(m,tarr2,SUBSEP); print tarr2[1],"*",tarr2[2],"=",tarr[m];
  }
  }'
  ```

###### 内置函数

- awk内置函数，主要分以下3种类似：算数函数、字符串函数、其它一般函数、时间函数。

- 算术函数

  | 格式            | 描述                                                         |
  | --------------- | ------------------------------------------------------------ |
  | atan2( y, x )   | 返回 y/x 的反正切。                                          |
  | cos( x )        | 返回 x 的余弦；x 是弧度。                                    |
  | sin( x )        | 返回 x 的正弦；x 是弧度。                                    |
  | exp( x )        | 返回 x 幂函数。                                              |
  | log( x )        | 返回 x 的自然对数。                                          |
  | sqrt( x )       | 返回 x 平方根。                                              |
  | int( x )        | 返回 x 的截断至整数的值。                                    |
  | rand( )         | 返回任意数字 n，其中 0 <= n < 1。                            |
  | srand( [expr] ) | 将 rand 函数的种子值设置为 Expr 参数的值，或如果省略 Expr 参数则使用某天的时间。返回先前的种子值。 |

  举例说明：

  ```shell
  awk 'BEGIN{OFMT="%.3f";fs=sin(1);fe=exp(10);fl=log(10);fi=int(3.1415);print fs,fe,fl,fi;}'
  0.841 22026.466 2.303 3
  ```

  OFMT 设置输出数据格式是保留3位小数。

  获得随机数：

  ```shell
  awk 'BEGIN{srand();fr=int(100*rand());print fr;}'
  78
  awk 'BEGIN{srand();fr=int(100*rand());print fr;}'
  31
  awk 'BEGIN{srand();fr=int(100*rand());print fr;}'
  41 
  ```

- 字符串函数

  | 格式                                | 描述                                                         |
  | ----------------------------------- | ------------------------------------------------------------ |
  | gsub( Ere, Repl, [ In ] )           | 除了正则表达式所有具体值被替代这点，它和 sub 函数完全一样地执行。 |
  | sub( Ere, Repl, [ In ] )            | 用 Repl 参数指定的字符串替换 In 参数指定的字符串中的由 Ere 参数指定的扩展正则表达式的第一个具体值。sub 函数返回替换的数量。出现在 Repl 参数指定的字符串中的 &（和符号）由 In 参数指定的与 Ere 参数的指定的扩展正则表达式匹配的字符串替换。如果未指定 In 参数，缺省值是整个记录（$0 记录变量）。 |
  | index( String1, String2 )           | 在由 String1 参数指定的字符串（其中有出现 String2 指定的参数）中，返回位置，从 1 开始编号。如果 String2 参数不在 String1 参数中出现，则返回 0（零）。 |
  | length [(String)]                   | 返回 String 参数指定的字符串的长度（字符形式）。如果未给出 String 参数，则返回整个记录的长度（$0 记录变量）。 |
  | blength [(String)]                  | 返回 String 参数指定的字符串的长度（以字节为单位）。如果未给出 String 参数，则返回整个记录的长度（$0 记录变量）。 |
  | substr( String, M, [ N ] )          | 返回具有 N 参数指定的字符数量子串。子串从 String 参数指定的字符串取得，其字符以 M 参数指定的位置开始。M 参数指定为将 String 参数中的第一个字符作为编号 1。如果未指定 N 参数，则子串的长度将是 M 参数指定的位置到 String 参数的末尾 的长度。 |
  | match( String, Ere )                | 在 String 参数指定的字符串（Ere 参数指定的扩展正则表达式出现在其中）中返回位置（字符形式），从 1 开始编号，或如果 Ere 参数不出现，则返回 0（零）。RSTART 特殊变量设置为返回值。RLENGTH 特殊变量设置为匹配的字符串的长度，或如果未找到任何匹配，则设置为 -1（负一）。 |
  | split( String, A, [Ere] )           | 将 String 参数指定的参数分割为数组元素 A[1], A[2], . . ., A[n]，并返回 n 变量的值。此分隔可以通过 Ere 参数指定的扩展正则表达式进行，或用当前字段分隔符（FS 特殊变量）来进行（如果没有给出 Ere 参数）。除非上下文指明特定的元素还应具有一个数字值，否则 A 数组中的元素用字符串值来创建。 |
  | tolower( String )                   | 返回 String 参数指定的字符串，字符串中每个大写字符将更改为小写。大写和小写的映射由当前语言环境的 LC_CTYPE 范畴定义。 |
  | toupper( String )                   | 返回 String 参数指定的字符串，字符串中每个小写字符将更改为大写。大写和小写的映射由当前语言环境的 LC_CTYPE 范畴定义。 |
  | sprintf(Format, Expr, Expr, . . . ) | 根据 Format 参数指定的 printf 子例程格式字符串来格式化 Expr 参数指定的表达式并返回最后生成的字符串。 |

  注：Ere都可以是正则表达式。

  **gsub,sub使用**

  ```shell
  awk 'BEGIN{info="this is a test2010test!";gsub(/[0-9]+/,"!",info);print info}'
  this is a test!test!
  ```

  在 info中查找满足正则表达式，`/[0-9]+/` 用`””`替换，并且替换后的值，赋值给info 未给info值，默认是`$0`

  **查找字符串（index使用）**

  ```shell
  awk 'BEGIN{info="this is a test2010test!";print index(info,"test")?"ok":"no found";}'
  ok
  ```

  未找到，返回0

  **正则表达式匹配查找(match使用）**

  ```
  awk 'BEGIN{info="this is a test2010test!";print match(info,/[0-9]+/)?"ok":"no found";}'
  ok
  ```

  **截取字符串(substr使用）**

  ```shell
  [wangsl@centos5 ~]$ awk 'BEGIN{info="this is a test2010test!";print substr(info,4,10);}'
  s is a tes
  ```

  从第 4个 字符开始，截取10个长度字符串

  **字符串分割（split使用）**

  ```shell
  awk 'BEGIN{info="this is a test";split(info,tA," ");print length(tA);for(k in tA){print k,tA[k];}}'
  4
  4 test
  1 this
  2 is
  3 a
  ```

  分割info，动态创建数组tA，这里比较有意思，`awk for …in`循环，是一个无序的循环。 并不是从数组下标1…n ，因此使用时候需要注意。

  **格式化字符串输出（sprintf使用）**

  格式化字符串格式：

  其中格式化字符串包括两部分内容：一部分是正常字符，这些字符将按原样输出; 另一部分是格式化规定字符，以`"%"`开始，后跟一个或几个规定字符,用来确定输出内容格式。

  | 格式 | 描述                     | 格式 | 描述                          |
  | ---- | ------------------------ | ---- | ----------------------------- |
  | %d   | 十进制有符号整数         | %u   | 十进制无符号整数              |
  | %f   | 浮点数                   | %s   | 字符串                        |
  | %c   | 单个字符                 | %p   | 指针的值                      |
  | %e   | 指数形式的浮点数         | %x   | %X 无符号以十六进制表示的整数 |
  | %o   | 无符号以八进制表示的整数 | %g   | 自动选择合适的表示法          |

  ```shell
  awk 'BEGIN{n1=124.113;n2=-1.224;n3=1.2345; printf("%.2f,%.2u,%.2g,%X,%on",n1,n2,n3,n1,n1);}'
  124.11,18446744073709551615,1.2,7C,174
  ```

- 一般函数

  | 格式                                | 描述                                                         |
  | ----------------------------------- | ------------------------------------------------------------ |
  | close( Expression )                 | 用同一个带字符串值的 Expression 参数来关闭由 print 或 printf 语句打开的或调用 getline 函数打开的文件或管道。如果文件或管道成功关闭，则返回 0；其它情况下返回非零值。如果打算写一个文件，并稍后在同一个程序中读取文件，则 close 语句是必需的。 |
  | system(command )                    | 执行 Command 参数指定的命令，并返回退出状态。等同于 system 子例程。 |
  | Expression `|` getline [ Variable ] | 从来自 Expression 参数指定的命令的输出中通过管道传送的流中读取一个输入记录，并将该记录的值指定给 Variable 参数指定的变量。如果当前未打开将 Expression 参数的值作为其命令名称的流，则创建流。创建的流等同于调用 popen 子例程，此时 Command 参数取 Expression 参数的值且 Mode 参数设置为一个是 r 的值。只要流保留打开且 Expression 参数求得同一个字符串，则对 getline 函数的每次后续调用读取另一个记录。如果未指定 Variable 参数，则 $0 记录变量和 NF 特殊变量设置为从流读取的记录。 |
  | getline [ Variable ] < Expression   | 从 Expression 参数指定的文件读取输入的下一个记录，并将 Variable 参数指定的变量设置为该记录的值。只要流保留打开且 Expression 参数对同一个字符串求值，则对 getline 函数的每次后续调用读取另一个记录。如果未指定 Variable 参数，则 $0 记录变量和 NF 特殊变量设置为从流读取的记录。 |
  | getline [ Variable ]                | 将 Variable 参数指定的变量设置为从当前输入文件读取的下一个输入记录。如果未指定 Variable 参数，则 $0 记录变量设置为该记录的值，还将设置 NF、NR 和 FNR 特殊变量。 |

  **打开外部文件（close用法）**

  ```shell
  awk 'BEGIN{while("cat /etc/passwd"|getline){print $0;};close("/etc/passwd");}'
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  ```

  **逐行读取外部文件(getline使用方法）**

  ```shell
  awk 'BEGIN{while(getline < "/etc/passwd"){print $0;};close("/etc/passwd");}'
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  awk 'BEGIN{print "Enter your name:";getline name;print name;}'
  Enter your name:
  chengmo
  chengmo
  ```

  **调用外部应用程序(system使用方法）**

  ```shell
  awk 'BEGIN{b=system("ls -al");print b;}'
  total 42092
  drwxr-xr-x 14 chengmo chengmo     4096 09-30 17:47 .
  drwxr-xr-x 95 root   root       4096 10-08 14:01 ..
  ```

  b返回值，是执行结果。

- 时间函数

  | 格式                               | 描述                                                         |
  | ---------------------------------- | ------------------------------------------------------------ |
  | 函数名                             | 说明                                                         |
  | mktime( YYYY MM dd HH MM ss[ DST]) | 生成时间格式                                                 |
  | strftime([format [, timestamp]])   | 格式化时间输出，将时间戳转为时间字符串具体格式，见下表。     |
  | systime()                          | 得到时间戳，返回从1970年1月1日开始到当前时间(不计闰年)的整秒数 |

  **建指定时间(mktime使用）**

  ```shell
  awk 'BEGIN{tstamp=mktime("2001 01 01 12 12 12");print strftime("%c",tstamp);}'
  2001年01月01日 星期一 12时12分12秒
  awk 'BEGIN{tstamp1=mktime("2001 01 01 12 12 12");tstamp2=mktime("2001 02 01 0 0 0");print tstamp2-tstamp1;}'
  2634468
  ```

  求2个时间段中间时间差，介绍了strftime使用方法

  ```shell
  awk 'BEGIN{tstamp1=mktime("2001 01 01 12 12 12");tstamp2=systime();print tstamp2-tstamp1;}' 
  308201392
  ```

  **strftime日期和时间格式说明符**

  | 格式 | 描述                                                     |
  | ---- | -------------------------------------------------------- |
  | %a   | 星期几的缩写(Sun)                                        |
  | %A   | 星期几的完整写法(Sunday)                                 |
  | %b   | 月名的缩写(Oct)                                          |
  | %B   | 月名的完整写法(October)                                  |
  | %c   | 本地日期和时间                                           |
  | %d   | 十进制日期                                               |
  | %D   | 日期 08/20/99                                            |
  | %e   | 日期，如果只有一位会补上一个空格                         |
  | %H   | 用十进制表示24小时格式的小时                             |
  | %I   | 用十进制表示12小时格式的小时                             |
  | %j   | 从1月1日起一年中的第几天                                 |
  | %m   | 十进制表示的月份                                         |
  | %M   | 十进制表示的分钟                                         |
  | %p   | 12小时表示法(AM/PM)                                      |
  | %S   | 十进制表示的秒                                           |
  | %U   | 十进制表示的一年中的第几个星期(星期天作为一个星期的开始) |
  | %w   | 十进制表示的星期几(星期天是0)                            |
  | %W   | 十进制表示的一年中的第几个星期(星期一作为一个星期的开始) |
  | %x   | 重新设置本地日期(08/20/99)                               |
  | %X   | 重新设置本地时间(12:00:00)                               |
  | %y   | 两位数字表示的年(99)                                     |
  | %Y   | 当前月份                                                 |
  | %%   | 百分号(%)                                                |

###### 字符串拼接

- 别家的语言，字符串拼接符好歹也是看得见分的清楚的，比如 [PHP](https://www.twle.cn/l/yufei/php/php-basic-index.html) 家的字符串拼接符是 **点号（ . ）**，比如 [Python](https://www.twle.cn/l/yufei/python30/python-30-index.html) 家的是 **加号（ + ）**

- AWK 家的字符串拼接符，竟然是 **空格 ( `' '` )**。 你能分得清这到底是拼接符还是空白符嘛？

- AWK 语言使用 **空格 ( `' '` )** 作为字符串拼接符。

- 需要注意的是，空格没有限制，你可以任意多个。

  ```
  [www.twle.cn]$ awk 'BEGIN { str1 = "你好，"; str2 = "简单教程"; str3 = str1 str2; print str3 }'
  [www.twle.cn]$ awk 'BEGIN { str1 = "你好，"; str2 = "简单教程"; str3 = str1      str2; print str3 }'
  
  你好，简单教程
  你好，简单教程
  ```

- 如果需要在字符串中间拼接一个空格

  ```
  node=$1 " " $2
  ```

###### 多条模式匹配的语句

```
awk '
BEGIN   {
        scenario = trace_ref = central = ""
        fmt = "%-12s %s\n"
        }
$1 == "NODE" || $1 == "FPNODE" {
        node = $2
        if (NF > 2 && $3 != "TYPE") node = node " " $3
        }
$1 == "TRACE_REF" {
        trace_ref = $2
        }
$1 == "CENTRAL" {
        central = node
        }
$1 == "CSCI" {
        csci = $2 $3
        if ($2 == "ATG") central = node
        if ($2 ~ /^PTG/) scenario = node
        printf(fmt, csci, node)
        }
END     {
        if (central != "" || trace_ref != "" || scenario != "" ) print ""
        if (central   != "") printf(fmt, "CENTRAL", central)
        if (scenario  != "") printf(fmt, "SCENARIO", scenario)
        if (trace_ref != "") printf(fmt, "TRACE_REF", trace_ref)
        }
' $HOME/INTEG/run_config/$RUN_CONFIG_VERS/config/`basename $map .map`.conf

```

- 上例中每一行$1匹配了好多次，如果$1匹配到NODE，创建变量node并赋值，第二行没有匹配到NODE，但是在下面的模式匹配语句中也可以使用第一次皮袍到赋值的node值，因为这是一个变量，而且这是相当于在一个语句中，所以可以一直使用node值。

##### ipcs

- 进程间通信有如下的目的：

  - 数据传输，一个进程需要将它的数据发送给另一个进程，发送的数据量在一个字节到几M之间；
  - 共享数据，多个进程想要操作共享数据，一个进程对数据的修改，其他进程应该立刻看到；
  - 通知事件，一个进程需要向另一个或一组进程发送消息，通知它们发生了某件事情；
  - 资源共享，多个进程之间共享同样的资源。为了做到这一点，需要内核提供锁和同步机制；
  - 进程控制，有些进程希望完全控制另一个进程的执行（如Debug进程），此时控制进程希望能够拦截另一个进程的所有陷入和异常，并能够及时知道它的状态改变。

- Linux进程间通信由以下几部分发展而来：

  - 早期UNIX进程间通信：包括管道、FIFO、信号。

  - 基于System V的进程间通信：包括System V[消息队列](https://cloud.tencent.com/product/cmq?from=10680)、System V信号灯（Semaphore）、System V共享内存。

  - 基于Socket进程间通信。

  - 基于POSIX进程间通信：包括POSIX消息队列、POSIX信号灯、POSIX共享内存。

- IPCS命令是Linux下显示进程间通信设施状态的工具。我们知道，系统进行进程间通信（IPC）的时候，可用的方式包括信号量、共享内存、消息队列、管道、信号（signal）、套接字等形式[[2](http://www.cnblogs.com/linshui91/archive/2010/09/29/1838770.html)]。使用IPCS可以查看共享内存、信号量、消息队列的状态。

  - ipcs只能显示上面三种进程间通信工具的状态。
    - ------ Semaphore Arrays --------
    - ------ Shared Memory Segments --------
    - ------ Message Queues --------

##### set

- 我们知道，Bash 执行脚本的时候，会创建一个新的 Shell。

  > ```bash
  > $ bash script.sh
  > ```

  - 上面代码中，`script.sh`是在一个新的 Shell 里面执行。这个 Shell 就是脚本的执行环境，Bash 默认给定了这个环境的各种参数。

  - `set`命令用来修改 Shell 环境的运行参数，也就是可以定制环境。一共有十几个参数可以定制，[官方手册](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)有完整清单，本文介绍其中最常用的四个。

  - 顺便提一下，如果命令行下不带任何参数，直接运行`set`，会显示所有的环境变量和 Shell 变量。

  > ```bash
  > $ set
  > ```

  - 例如

    ```
    #!/bin/sh
    aaaaa=bbbbb
    set
    ```

    - 此时

###### set -u

- 执行脚本的时候，如果遇到不存在的变量，Bash 默认忽略它。

  > ```bash
  > #!/usr/bin/env bash
  > 
  > echo $a
  > echo bar
  > ```

- 上面代码中，`$a`是一个不存在的变量。执行结果如下。

  > ```bash
  > $ bash script.sh
  > 
  > bar
  > ```

- 可以看到，`echo $a`输出了一个空行，Bash 忽略了不存在的`$a`，然后继续执行`echo bar`。大多数情况下，这不是开发者想要的行为，遇到变量不存在，脚本应该报错，而不是一声不响地往下执行。

- `set -u`就用来改变这种行为。脚本在头部加上它，遇到不存在的变量就会报错，并停止执行。

  > ```bash
  > #!/usr/bin/env bash
  > set -u
  > 
  > echo $a
  > echo bar
  > ```

- 运行结果如下。

  > ```bash
  > $ bash script.sh
  > bash: script.sh:行4: a: 未绑定的变量
  > ```

- 可以看到，脚本报错了，并且不再执行后面的语句。

- `-u`还有另一种写法`-o nounset`，两者是等价的。

  > ```bash
  > set -o nounset
  > ```

###### set -x

- 默认情况下，脚本执行后，屏幕只显示运行结果，没有其他内容。如果多个命令连续执行，它们的运行结果就会连续输出。有时会分不清，某一段内容是什么命令产生的。

- `set -x`用来在运行结果之前，先输出执行的那一行命令。

  > ```bash
  > #!/usr/bin/env bash
  > set -x
  > 
  > echo bar
  > ```

- 执行上面的脚本，结果如下。

  > ```bash
  > $ bash script.sh
  > + echo bar
  > bar
  > ```

- 可以看到，执行`echo bar`之前，该命令会先打印出来，行首以`+`表示。这对于调试复杂的脚本是很有用的。

- `-x`还有另一种写法`-o xtrace`。

  > ```bash
  > set -o xtrace
  > ```

###### set -e

- 如果脚本里面有运行失败的命令（返回值非0），Bash 默认会继续执行后面的命令。

  > ```bash
  > #!/usr/bin/env bash
  > 
  > foo
  > echo bar
  > ```

- 上面脚本中，`foo`是一个不存在的命令，执行时会报错。但是，Bash 会忽略这个错误，继续往下执行。

  > ```bash
  > $ bash script.sh
  > script.sh:行3: foo: 未找到命令
  > bar
  > ```

- 可以看到，Bash 只是显示有错误，并没有终止执行。

- 这种行为很不利于脚本安全和除错。实际开发中，如果某个命令失败，往往需要脚本停止执行，防止错误累积。这时，一般采用下面的写法。

  > ```bash
  > command || exit 1
  > ```

- 上面的写法表示只要`command`有非零返回值，脚本就会停止执行。

- 如果停止执行之前需要完成多个操作，就要采用下面三种写法。

  > ```bash
  > # 写法一
  > command || { echo "command failed"; exit 1; }
  > 
  > # 写法二
  > if ! command; then echo "command failed"; exit 1; fi
  > 
  > # 写法三
  > command
  > if [ "$?" -ne 0 ]; then echo "command failed"; exit 1; fi
  > ```

- 另外，除了停止执行，还有一种情况。如果两个命令有继承关系，只有第一个命令成功了，才能继续执行第二个命令，那么就要采用下面的写法。

  > ```bash
  > command1 && command2
  > ```

- 上面这些写法多少有些麻烦，容易疏忽。`set -e`从根本上解决了这个问题，它使得脚本只要发生错误，就终止执行。

  > ```bash
  > #!/usr/bin/env bash
  > set -e
  > 
  > foo
  > echo bar
  > ```

- 执行结果如下。

  > ```bash
  > $ bash script.sh
  > script.sh:行4: foo: 未找到命令
  > ```

- 可以看到，第4行执行失败以后，脚本就终止执行了。

- `set -e`根据返回值来判断，一个命令是否运行失败。但是，某些命令的非零返回值可能不表示失败，或者开发者希望在命令失败的情况下，脚本继续执行下去。这时可以暂时关闭`set -e`，该命令执行结束后，再重新打开`set -e`。

  > ```bash
  > set +e
  > command1
  > command2
  > set -e
  > ```

- 上面代码中，`set +e`表示关闭`-e`选项，`set -e`表示重新打开`-e`选项。

- 还有一种方法是使用`command || true`，使得该命令即使执行失败，脚本也不会终止执行。

  > ```bash
  > #!/bin/bash
  > set -e
  > 
  > foo || true
  > echo bar
  > ```

- 上面代码中，`true`使得这一行语句总是会执行成功，后面的`echo bar`会执行。

- `-e`还有另一种写法`-o errexit`。

  > ```bash
  > set -o errexit
  > ```

###### set -o pipefail

- `set -e`有一个例外情况，就是不适用于管道命令。

- 所谓管道命令，就是多个子命令通过管道运算符（`|`）组合成为一个大的命令。Bash 会把最后一个子命令的返回值，作为整个命令的返回值。也就是说，只要最后一个子命令不失败，管道命令总是会执行成功，因此它后面命令依然会执行，`set -e`就失效了。

- 请看下面这个例子。

  > ```bash
  > #!/usr/bin/env bash
  > set -e
  > 
  > foo | echo a
  > echo bar
  > ```

- 执行结果如下。

  > ```bash
  > $ bash script.sh
  > a
  > script.sh:行4: foo: 未找到命令
  > bar
  > ```

- 上面代码中，`foo`是一个不存在的命令，但是`foo | echo a`这个管道命令会执行成功，导致后面的`echo bar`会继续执行。

- `set -o pipefail`用来解决这种情况，只要一个子命令失败，整个管道命令就失败，脚本就会终止执行。

  > ```bash
  > #!/usr/bin/env bash
  > set -eo pipefail
  > 
  > foo | echo a
  > echo bar
  > ```

- 运行后，结果如下。

  > ```bash
  > $ bash script.sh
  > a
  > script.sh:行4: foo: 未找到命令
  > ```

- 可以看到，`echo bar`没有执行。

###### man手册

- set — set or unset options and positional parameters

  - set的主要功能为设置上面的那些选项或者设置位置参数，这样就不用在执行脚本的时候带一些参数了，例如./test.sh liyunliang，这个参数liyunliang在脚本里面用set设置就可以了。

- man手册给的例子

  ```
  Write out all variables and their values:
       set
  Set $1, $2, and $3 and set "$#" to 3:
       set c a b
  Turn on the -x and -v options:
       set -xv
   Unset all positional parameters:
       set --
   Set $1 to the value of x, even if it begins with '-' or '+':
       set -- "$x"
   Set the positional parameters to the expansion of x, even if x expands with a leading '-' or '+':
       set -- $x
  ```

  - 其中set c a b是将位置参数$1设置为c，$2设置为a，$3设置为b

  - set -- 是关闭所有的位置参数

  - set --  "$x"和set -- $x区别

    - 主要就是一个带引号一个不带引号。示例如下

      ```
      #!/bin/sh
      a="1 2 3"
      set -- "$a"
      此时是将a变量1 2 3作为一个整体赋值给位置参数$1,带有空格。
      
      #!/bin/sh
      a="1 2 3"
      set -- $a
      此时是将变量a以空格作为分割符赋值给位置参数。此时$1是1，$2是2，$3是3
      ```

- set只是用来设置位置参数，不能设置变量，设置变量直接定义就可以了，不能加set。
- set设置的位置参数可以被子shell继承和使用(例如括号引起来的子shell或者管道这些)，子进程不能使用。

##### env

- env命令用于显示系统中已存在的环境变量，以及在定义的环境中执行指令。该命令只使用"-“作为参数选项时，隐藏了选项”-i"的功能。若没有设置任何选项和参数时，则直接显示当前的环境变量。

- env命令是输出所有的环境变量,即使在当前shell中export之后的,env也能显示.所有在配置文件中export的更能显示了.

  ```
  -i, --ignore-environment
      不带环境变量启动 
  -u, --unset=NAME
      从环境变量中删除一个变量 
  --help
      显示帮助并退出 
  --version
      输出版本信息并退出 
  
  单独的-隐含-i.如果没有COMMAND,那么打印结果环境变量. 
  ```

- env在不带参数的时候是输出环境变量，其余的都是执行脚本的时候使用，例如env -i ./test.sh，就是在test.sh脚本中清空所有的环境变量，意思为所有的环境变量在test.sh脚本中都没有。还有其他的env test=TEST ./test.sh，表示除了大家都有的环境变量外，还额外有test这个环境变量，这个环境变量在外面的进程是没有的，只有在执行test.sh这个进程中才有，env -u test ./test.sh，表示test.sh脚本中删除了test环境变量，其余的都有，这个不会在其他的shell进程中也删除test环境变量。如果执行env -u test |  grep test，此时没有test环境变量，如果紧接着在执行env | grep test，是有test环境变量的，说明env -u不会在环境变量中删除某些环境变量，只是在某一个shell进程中删除环境变量。

##### set、env、export、source、exec

[网上讲解，说的很好](https://segmentfault.com/a/1190000013356532)

- 

##### tail

- 用于显示文本文件的末尾几行。

  ```shell
  tail notes.log         # 默认显示最后 10 行
  ```

- -f ：常用于查阅正在改变的日志文件。**tail -f filename** 会把 filename 文件里的最尾部的内容显示在屏幕上，并且不断刷新，只要 filename 更新就可以看到最新的文件内容。

  ```shell
  tail -f notes.log
  此命令显示 notes.log 文件的最后 10 行。当将某些行添加至 notes.log 文件时，tail 命令会继续显示这些行。 显示一直继续，直到您按下（Ctrl-C）组合键停止显示。
  ```

- -n Number：从首行或末行位置来读取指定文件，位置由 Number 变量的符号（+ 或 - 或无）表示，并通过行号Number 进行位移。
  
  - tail -n +0表示从第一行就开始打印到最后，tail -n 20 和tail -n -20一样都是打印最后20行。
  
  - 显示文件 notes.log 的内容，从第 20 行至文件末尾:
  
    ```shell
    tail -n +20 notes.log
    ```

##### more、less

- `more` 是一个老式的、基础的终端分页阅读器，它可以用于打开指定的文件并进行交互式阅读。如果文件的内容太长，在一屏以内无法完整显示，就会逐页显示文件内容。使用回车键或者空格键可以滚动浏览文件的内容，但有一个限制，就是只能够单向滚动。也就是说只能按顺序往下翻页，而不能进行回看。
  - 有的 Linux 用户向我指出，在 `more` 当中是可以向上翻页的。不过，最原始版本的 `more` 确实只允许向下翻页，在后续出现的较新的版本中也允许了有限次数的向上翻页，只需要在浏览过程中按 `b` 键即可向上翻页。
  - 但是现在一般more只能向下不能向上
  - 按空格键翻页
  - 如果需要查看所有选项以及对应的按键，可以按 `h` 键。
- `less` 命令也是用于打开指定的文件并进行交互式阅读，它也支持翻页和搜索。如果文件的内容太长，也会对输出进行分页，因此也可以翻页阅读。比 `more` 命令更好的一点是，`less` 支持向上翻页和向下翻页，也就是可以在整个文件中任意阅读。
- 在使用功能方面，`less` 比 `more` 命令具有更多优点，以下列出其中几个：
  - 支持向上翻页和向下翻页
  - 支持向上搜索和向下搜索
  - 可以跳转到文件的末尾并立即从文件的开头开始阅读
  - 在编辑器中打开指定的文件
- less基本使用
  - 按空格键或回车键可以向下翻页，按 `b` 键可以向上翻页。
  - 按 `n` 键可以跳转到下一个匹配的字符串，如果需要跳转到上一个匹配的字符串，可以按 `N` 键。如果需要向上搜索，在输入问号（`?`）之后接着输入需要搜索的内容。
  - 只需要按 `v` 键，就会将正在阅读的文件在默认编辑器中打开，然后就可以对文件进行各种编辑操作了。
  - 按 `h` 键可以查看 `less` 工具的选项和对应的按键。

##### tee

- tee命令用于读取标准输入的数据，并将其内容输出成文件。

- tee指令会从标准输入设备读取数据，将其内容输出到标准输出设备，同时保存成文件。

  ```
  tee [-ai][--help][--version][文件...]
  ```

  - -a或--append 　附加到既有文件的后面，而非覆盖它．
  - -i或--ignore-interrupts 　忽略中断信号。
  - 其中的文件可以是多个，同时保存到多个文件中。

- tee命令一般和管道用在一起。

- 管道是一种通信机制，通常用于进程间的通信，它表现出来的形式将前面每一个进程的输出（stdout）直接作为下一个进程的输入（stdin）。

  - 管道命令使用`|`作为界定符号
  - 管道命令仅能处理**standard output**,对于**standard error output**会予以忽略。
  - 管道命令必须要能够接受来自前一个命令的数据成为**standard input**继续处理才行。
  - 管道只会将标准输入传到下一个进程，标准错误输出是不会传到下一个进程的，所以我们可以将标准错误输出重定向到标准输出然后一起传入到下一个进程。

- 实例

  ```shell
  mk='(umake clean; umake clean_lib; umake do_define_units;umake depend;umake all;umake do_install) 2>&1 | tee umakeall.log'
  ```

  - 其中的umake也是一个alias
  - tee命令接受来自管道的标准输入，放入到文件中。

##### which、whereis、find、locate

- **which**：常用于查找可直接执行的命令。只能查找可执行文件，该命令基本只在$PATH路径中搜索，查找范围最小，查找速度快。默认只返回第一个匹配的文件路径，通过选项 -a 可以返回所有匹配结果。
- **whereis**：不只可以查找命令，其他文件类型都可以（man中说只能查命令、源文件和man文件，实际测试可以查大多数文件）。在$PATH路径基础上增加了一些系统目录的查找，查找范围比which稍大，查找速度快。可以通过 -b 选项，限定只搜索二进制文件。
  - 例如可以查找/etc下面的文件，whereis profile
- **locate**：超快速查找任意文件。它会从linux内置的索引数据库查找文件的路径，索引速度超快。刚刚新建的文件可能需要一定时间才能加入该索引数据库，可以通过执行updatedb命令来强制更新一次索引，这样确保不会遗漏文件。该命令通常会返回大量匹配项，可以使用 *-r* 选项通过正则表达式来精确匹配。
- **find**：直接搜索整个文件目录，默认直接从根目录开始搜索，建议在以上命令都无法解决问题时才用它，功能最强大但速度超慢。除非你指定一个很小的搜索范围。通过 *-name* 选项指定要查找的文件名，支持通配符。

##### echo

- 在`Linux`命令行终端或`Bash Shell`脚本中适当使用颜色，能够让第一时间感觉到您的命令或脚本执行过程中差异。

- 字背景颜色范围`40–47`

  - `40`:黑
  - `41`:红
  - `42`:绿
  - `43`:黄色
  - `44`:蓝色
  - `45`:紫色
  - `46`:天蓝
  - `47`:白色

- 字颜色`30–37`

  - `30`:黑
  - `31`:红
  - `32`:绿
  - `33`:黄
  - `34`:蓝色
  - `35`:紫色
  - `36`:天蓝
  - `37`:白色

- ANSI控制码的说明

  - `\33[0m` 关闭所有属性
  - `\33[1m` 设置高亮度
  - `\33[4m` 下划线
  - `\33[5m` 闪烁
  - `\33[7m` 反显

- 当`echo`命令带`-e`参数时，可以使用反斜杠`\`输出特殊的字符。

  echo输出带颜色的字体格式如下:

  ```sh
  $ echo -e "\033[字背景颜色;字体颜色m字符串\033[0m"
  # 其中: "\033" 引导非常规字符序列。”m”意味着设置属性然后结束非常规字符序列。
  
  $ echo -e "\033[41;32m红色背景绿色文字\033[0m"
  # 其中: 41的位置代表底色, 32的位置是代表字的颜色。
  
  $ echo -e "\033[32m绿色文字\033[0m"
  #输出绿色文字
  
  $ echo -e "\033[31m红字\033[32m绿字\033[0m" # 输出红字和绿字
  #输出红字和绿字
  
  $ echo -e "\033[31m红字\033[43;32m绿字带黄色背景\033[0m" # 输出红字和带黄色背景的绿字
  #输出红字和带黄色背景的绿字
  
  $ echo -e "\033[4;47;31m带下划线的白色背景的红字\033[0m\033[1;41;32m高亮的红色背景的绿字\033[0m"
  $ echo -e "\033[4m\033[47m\033[31m带下划线的白色背景的红字\033[0m \033[1m\033[41m\033[32m高亮的红色背景的绿字\033[0m"
  #带下划线的白色背景的红字、高亮的红色背景的绿字
  
  通过以上示例可知：控制符可以进行组合在一起，如\033[4;47;31m将三个属性组合在一起(属性数字中间使用分号;隔开)；也可以\033[4m\033[47m\033[31m每个属性单独写。
  ```

- 如果经常使用颜色控制的话，可以将颜色控制符进行定义好。 可以在`~/.bashrc`中设置个人偏好，使用`vi ~/.bashrc`打开`.bashrc`文件：并将下面的变量写入到文件中：将下面的变量写入到`~/.bashrc`文件中:

  ```sh
  [meizhaohui@localhost ~]$ vi ~/.bashrc
  bg_black=”\033[40m”
  bg_red=”\033[41m”
  bg_green=”\033[42m”
  bg_yellow=”\033[43m”
  bg_blue=”\033[44m”
  bg_purple=”\033[45m”
  bg_cyan=”\033[46m”
  bg_white=”\033[47m”
      
  fg_black=”\033[30m”
  fg_red=”\033[31m”
  fg_green=”\033[32m”
  fg_yellow=”\033[33m”
  fg_blue=”\033[34m”
  fg_purple=”\033[35m”
  fg_cyan=”\033[36m”
  fg_white=”\033[37m”
      
  set_clear=”\033[0m”
  set_bold=”\033[1m”
  set_underline=”\033[4m”
  set_flash=”\033[5m”
  ```

  - 此时按如下命令输入相应的字体:

    ```sh
    [meizhaohui@localhost ~]$ source ~/.bashrc
    [meizhaohui@localhost ~]$ echo -e "${bg_red}${fg_green}${set_bold}红色背景粗体的绿色字${set_clear}"
    红色背景粗体的绿色字
    红色背景粗体的绿色字  
    [meizhaohui@localhost ~]$ echo -e "${bg_red}${fg_green}红色背景的绿色字${set_clear}"
    红色背景的绿色字
    红色背景的绿色字
    ```

  - 如果要在脚本中使用使用`~/.bashrc`中定义的`bg_red`、`fg_green`等变量，可以在`shell`脚本中使用`source ~/.bashrc`或者点操作符加载`~/.bashrc`文件到脚本中。

    打印颜色脚本:

    ```sh
    [meizhaohui@localhost ~]$ cat print_color.sh
    #!/bin/bash
    #Source personal definitions
    source ~/.bashrc
    # 或使用以下命令：
    # . ~/.bashrc
    echo -e "${bg_red}${fg_green}${set_bold}红色背景粗体的绿色字${set_clear}"
    ```

- 当我们编写Shell脚本时，需要将日志信息保存起来，我们也可以使用`echo`命令输出带颜色的字体，方便查看日志信息。

  如，我们将以下代码加入到`~/.bashrc`文件中，并重新加载，使其生效。

  ```sh
  #################################################
  # Get now date string.
  # 当前日期字符串
  #################################################
  function now_date() {
      format=$1
      if [[ "${format}" ]]; then
          now=$(date +"${format}")
      else
          now=$(date +"%Y%m%d_%H%M%S")
      fi
  
      echo "${now}"
  }
  
  #################################################
  # Basic log function.
  # 基本日志，输出时间戳
  # ex: [2021/08/15 19:16:10]
  #################################################
  function echo_log() {
      now=$(date +"[%Y/%m/%d %H:%M:%S]")
      echo -e "\033[1;$1m${now}$2\033[0m"
  }
  
  #################################################
  # Debug log message.
  # 调试日志，黑色
  #################################################
  function msg_debug() {
      echo_log 30 "[Debug] ====> $*"
  }
  
  #################################################
  # Error log message.
  # 异常日志，红色
  #################################################
  function msg_error() {
      echo_log 31 "[Error] ====> $*"
  }
  
  #################################################
  # Success log message.
  # 成功日志，绿色
  #################################################
  function msg_success() {
      echo_log 32 "[Success] ====> $*"
  }
  
  #################################################
  # Warning log message.
  # 警告日志，黄色
  #################################################
  function msg_warn() {
      echo_log 33 "[Warning] ====> $*"
  }
  
  #################################################
  # Information log message.
  # 一般消息日志，蓝色
  #################################################
  function msg_info() {
      echo_log 34 "[Info] ====> $*"
  }
  ```

  - 然后，在命令行就可以打印不同样式的消息了。

  ```sh
  [meizhaohui@hellogitlab ~]$ msg_debug 'debug message'
  [2021/08/21 12:35:45][Debug] ====> debug message
  [meizhaohui@hellogitlab ~]$ msg_info "info message"
  [2021/08/21 12:35:47][Info] ====> info message
  [meizhaohui@hellogitlab ~]$ msg_warn 'warn message'
  [2021/08/21 12:35:58][Warning] ====> warn message
  [meizhaohui@hellogitlab ~]$ msg_error 'error message'
  [2021/08/21 12:36:16][Error] ====> error message
  [meizhaohui@hellogitlab ~]$ msg_success 'success message'
  [2021/08/21 12:36:25][Success] ====> success message
  ```

- 后面我们可以把相应的消息写入到日志文件中，后期查看日志文件内容时，也可以看到有颜色的日志信息。

  ```sh
  [meizhaohui@hellogitlab ~]$ msg_info "info message" >> log.txt
  [meizhaohui@hellogitlab ~]$ msg_warn 'warn message' >> log.txt
  [meizhaohui@hellogitlab ~]$ msg_success 'success message' >> log.txt
  [meizhaohui@hellogitlab ~]$ cat log.txt
  [2021/08/21 12:40:14][Info] ====> info message
  [2021/08/21 12:40:27][Warning] ====> warn message
  [2021/08/21 12:40:37][Success] ====> success message
  [meizhaohui@hellogitlab ~]$
  ```

###### Nerd font

- echo支持一些转义字符，nerd font就是一堆特殊的符号和字体，对于特殊的符号，在终端中也可以输出出来，当然终端要配置对应的字体，转义如下

  ```
  \uHHHH
  	the Unicode (ISO/IEC 10646) character whose value is the hexadecimal value HHHH (one to four hex digits)
  \xHH
  the eight-bit character whose value is the hexadecimal value HH (one or two hex digits)
  ```

  - 所以在终端中可以输出一些特殊的符号，这些符号对应的UTF-8的值在nerd font官网上可以查到，以四位十六进制的数表示。
  - \u在bash 4.2之后才支持的，所以man echo没有查到这个，只有在bash官网手册上才查到。

- 在vim配置中也是以\uHHHH表示的，这些最后在终端中以对应的符号表示

  ```
  "suggest.completionItemKindLabels": {
  		"class": "\uf0e8",
  		"color": "\ue22b",
  		"constant": "\uf8fe",
  		"default": "\uf29c",
  		"enum": "\uf435",
  		"enumMember": "\uf02b",
  		"event": "\ufacd",
  		"field": "\uf93d",
  		"file": "\uf723",
  		"folder": "\uf115",
  		"function": "\u0192",
  		"interface": "\uf417",
  		"keyword": "\uf1de",
  		"method": "\uf6a6",
  		"module": "\uf40d",
  		"operator": "\uf915",
  		"property": "\ue624",
  		"reference": "\ufa46",
  		"snippet": "\ue60b",
  		"struct": "\ufb44",
  		"text": "\ue612",
  		"typeParameter": "\uf728",
  		"unit": "\uf475",
  		"value": "\uf89f",
  		"variable": "\ue71b"
  	},
  ```

#### 网络相关

##### 对于数据库的理解

- 每一个数据库都有一个端口，这个端口就表明数据库是作为一个服务来存在的，在用的时候需要先起数据库服务。
- 对于一些数据库提供了一些不同语言的API的理解
  - 例如mysql提供了一些c++的接口，此时我们就可以编写自己的程序，使用数据库提供的API，每种操作增删改查都封装好了，我们只需要使用接口就行了
  - 在数据库提供的API中，应该有连接数据库的API，在使用时我们先连接数据库，在用其他的API进行增删改查操作
  - 不需要关注端口啊，socket这些，API都封装好了，我们只需要使用就可以了。我们的程序和数据库之间应该是通过socket连接的，但是这些具体的链接我们不需要写，API封装好了。
  - 我们只需要先起数据库服务，然后编写自己的程序，然后通过API对数据库进行增删改查就可以了。
  - 数据库作为一种server，我们通过socket连接，然后进行操作，我们不需要管怎么实现的，只需要使用他对外提供的API就可以。
  - 作为数据库也是一个进程，我们自己的程序一般也有很多进程，我们自己的进程之间通信可以有很多中方式，例如共享内存、FIFO，这是我们内部设计的问题，但是我们自己的进程和数据库进程之间通信，我们是不需要关心的，已经确定好了，是通过socket通信的，数据库作为一种通用的服务是外挂在我们的进程之外的，我们只需要使用API操作他就可以了，不用考虑设计我们的进程和数据库进程之间的连接通信，也不用管怎么样比较好，因为已经确定了，想其他的没用了。

##### tcpdump

[网上讲解](https://blog.csdn.net/weixin_36338224/article/details/107035214)

- 常用命令如下

  ```
  tcpdump -A -l -i eth1 tcp port 8204
  ```

- `-i`：指定要过滤的网卡接口，如果要查看所有网卡，可以 `-i any`
- `-A`：以ASCII码方式显示每一个数据包(不显示链路层头部信息). 在抓取包含网页数据的数据包时, 可方便查看数据
- `-s` : tcpdump 默认只会截取前 `96` 字节的内容，要想截取所有的报文内容，可以使用 `-s number`， `number` 就是你要截取的报文字节数，如果是 0 的话，表示截取报文全部内容。
- `-l` : 基于行的输出，便于你保存查看，或者交给其它工具分析
- `-q` : 简洁地打印输出。即打印很少的协议相关信息, 从而输出行都比较简短.
- 显示数据包的头部
  - -x：以16进制的形式打印每个包的头部数据（但不包括数据链路层的头部）
  - -xx：以16进制的形式打印每个包的头部数据（包括数据链路层的头部）
  - -X：以16进制和 ASCII码形式打印出每个包的数据(但不包括连接层的头部)，这在分析一些新协议的数据包很方便。
  - -XX：以16进制和 ASCII码形式打印出每个包的数据(包括连接层的头部)，这在分析一些新协议的数据包很方便。
- 在用-X以16进制打印包内容时，打印出来很多点，这些点表示不可见字符，因为有很多不可见字符，所以打印出来很多。
  - -A是以ASCII方式显示，不知道具体的ASCII值，不可见字符也是打印点。

##### ethtool

- 常用命令

  ```
  ethtool [-p] ethX [N]
  ```

- `-p` 用于区别不同ethX对应网卡的物理位置，常用的方法是使网卡port上的led不断的闪；N指示了网卡闪的持续时间，以秒为单位。

#### 其他

##### getopt和getopts

###### 区别

- getopts是shell中内建的命令，它的使用语法相对getopt简单，但它不支持长命令参数（--option）。它不会重排列所有参数的顺序，选项参数的格式必须是-d val，而不能是中间没有空格的-dval，遇到非-开头的参数，或者选项参数结束标记--就中止了，如果中间遇到非选项的命令行参数，后面的选项参数就都取不到了，出现的目的仅仅是为了代替getopt较快捷方便的执行参数的分析。
- getopts的缺点正好是getopt所具有的优点。相对于getopts而言，getopt是一个独立的外部工具（Linux的一个命令），它的使用语法比较复杂，支持长命令参数，会重排参数的顺序。在shell中处理命令行参数时，需要配合其他Linux命令一起使用才行。

###### getopt和getopts

- getopts是shell命令行参数解析工具，意在从shell 命令行当中解析参数。命令格式：

  ```bash
  getopts optstring name [arg ...]
  ```

  - optstring列出了对应的shell 脚本可以识别的所有参数。比如：shell script可以识别-a, -f 以及-s参数，则optstring就是afs;如果对应的参数后面还跟随一个值，则在相应的optstring后面加冒号**。**比如a:fs表示a参数后面会有一个值出现，-a value的形式。另外，getopts执行匹配到a的时候，会把value存放在一个OPTARG的shell 变量中。如果optstring是以冒号开头的，命令行当中出现了optstring当中没有的参数将不会提示错误信息。

  - name表示的是参数的名称，每次执行getopts，会从命令行当中获取下一个参数，然后存放到name中。如果获取到参数不在optstring中，则name的值被设置为?。命令行当中的所有参数都有一个index，第一个参数从1开始，依次类推，另外有一个名为OPTIND的shell变量存放下一个要处理的参数的index。

    ```bash
    #!/bin/bash
     
    func() {
        echo "Usage:"
        echo "test.sh [-j S_DIR] [-m D_DIR]"
        echo "Description:"
        echo "S_DIR,the path of source."
        echo "D_DIR,the path of destination."
        exit -1
    }
     
    upload="false"
     
    while getopts 'h:j:m:u' OPT; do
        case $OPT in
            j) S_DIR="$OPTARG";;
            m) D_DIR="$OPTARG";;
            u) upload="true";;
            h) func;;
            ?) func;;
        esac
    done
     
    echo $S_DIR
    echo $D_DIR
    echo $upload
    
    
    //执行结果：
    [root@bobo tmp] sh test.sh -j /data/usw/web -m /opt/data/web
    /data/usw/web
    /opt/data/web
    false
    ```

    - getopts后面跟的字符串就是参数列表，每个字母代表一个选项，如果字母后面跟一个冒号，则表示这个选项还会有一个值，比如-j /data/usr/web 和 -m /opt/data/web。而getopts字符串中没有跟随冒号的字母就是开关型的选项，不需要指定值，等同于true/false，只要带上这个参数就是true。
    - getopts识别出各个选项之后，就可以配合case进行操作。操作中，有两个"常量"，一个是OPTARG，用来获取当前选项的值；另外一个就是OPTIND，表示当前选项在参数列表中的位移。case的最后一项是?，用来识别非法的选项，进行相应的操作，我们的脚本中输出了帮助信息。
    - OPTIND是用来获取当前选项在参数列表中的位移，例如上面示例中就是解析参数列表中的 -h、-j、-m、-u这些参数的，如果有的参数不以这些开头，例如写在最后的不以这些开头的参数，OPTIND就不会+1，所以我们可以结合shift来将这些可以解析的参数shift掉，剩下的就是不用解析值。

    ```bash
    #!/bin/bash
    #test3.sh
    
    func() {
            echo "Usage:"
            echo "test.sh [-j S_DIR] [-m D_DIR]"
            echo "Description:"
            echo "S_DIR, the path of source."
            echo "D_DIR, the path of destination."
            exit -1
    }
    
    upload="false"
    
    echo $OPTIND
    
    while getopts 'h:s:d:u' OPT; do
            case $OPT in
                    s) S_DIR="$OPTARG";;
                    d) D_DIR="$OPTARG";;
                    u) upload="true";;
                    h) func;;
                    ?) func;;
            esac
    done
    
    echo $OPTIND
    shift $((OPTIND - 1))
    echo $1
    
    
    
    [root@bobo tmp]# sh test.sh -j /data/usw/web beijing
    1              #执行的是第一个"echo $OPTIND"
    3              #执行的是第二个"echo $OPTIND"
    beijing        #此时$1是"beijing"
     
    [root@bobo tmp]# sh test.sh -m /opt/data/web beijing                
    1              #执行的是第一个"echo $OPTIND"
    3              #执行的是第二个"echo $OPTIND"
    beijing
     
    [root@bobo tmp]# sh test.sh -j /data/usw/web -m /opt/data/web beijing
    1              #执行的是第一个"echo $OPTIND"
    5              #执行的是第二个"echo $OPTIND"
    beijing
     
                      参数位置： 1        2       3       4        5     6
    [root@bobo tmp]# sh test.sh -j /data/usw/web -m /opt/data/web -u beijing
    6
    beijing
    ```

    - 当选项参数识别完成以后，就能识别剩余的参数了，我们可以使用shift进行位移，抹去选项参数。
    - 在上面的脚本中，我们位移的长度等于case循环结束后的OPTIND - 1，OPTIND的初始值为1。当选项参数处理结束后，其指向剩余参数的第一个。getopts在处理参数时，处理带值的选项参数，OPTIND加2；处理开关型变量时，OPTIND则加1。
    - 很多脚本执行的时候我们并不知道后面参数的个数，但可以使用$*来获取所有参数。但在程序处理的过程中有时需要逐个的将$1、$2、$3……$n进行处理。shift是shell中的内部命令，用于处理参数位置。每次调用shift时，它将所有位置上的参数减一。 $2变成了$1, $3变成了$2, $4变成了$3。shift命令的作用就是在执行完$1后，将$2变为$1，$3变为$2，依次类推。shift也可以带参数，表示shift多少次。

###### getopt

- getopt的命令使用有一下的三种格式：

  ```
  getopt optstring parameters
  getopt [options] [--] optstring parameters
  getopt [options] -o|--options optstring [options] [--] parameters
  ```

  - getopt的参数分为两部分：用于修改getopt解析模式的选项(即语法中的options和-o|--options optstring)和待解析的参数(即语法中的parameters部分)。第二部分将从第一个非选项参数开始，或者从"--"之后的第一项内容开始。如果在第一部分中没有给定"-o|--options"，则第二部分的第一个参数将用作短选项字符串。
  - 上面的说法是针对第三种语法来说的，第二种语法是可以添加一些选项来用的，getopt支持一些选项，第一种语法和getopts一样，使用方法类似。

- 如在Linux的Terminal中输入：get c:b -c file -b home

  - 返回匹配结果如下：

  ```
  -c file -b -- home
  ```

  - 输出结果分为两部分，"--"之前的是模式的匹配的结果，"--"之后的是非选项类型的参数
  - 所谓的非选项类型的参数，即是在parameters中，一个不是以"-"开头，也不是它前面的选项所需的参数，那么它就是一个非选项类型的参数（比如上述输入paramters中的home)。
  - --是getopt命令自己加的，最后解析完这个也会变成位置参数，所以在判断的时候可以判断位置参数是不是--

- 仅凭getopt命令是不能独立完成shell命令行参数的解析，还需要配合其他命令一起运用才行。我们可以使用这样一种方法，将getopt命令返回的匹配结果重新作为shell的位置参数，我们在循环中去左移动这些位置参数，每移动一次判断是当前参数是那种类型选项，并执行对应操作。当遇到"--"时，命令参数解析完毕，退出循环

- getopt返回的结果如何作为shell的传入位置参数呢？此时可以使用shell的内置的set函数，set -- arg，arg中的参数作为shell的新的位置参数，可通过$N进行直接引用

  ```
  #!/bin/sh
  
  SHORTOPTS="h,o:"
  LONGOPTS="help,output:"
  ARGS=$(getopt --options $SHORTOPTS  \  #①
    --longoptions $LONGOPTS -- "$@" )
    
  eval set -- "$ARGS"
  while true;
  do
      case $1 in
          -h|--help)
             echo "Print Help Information "
             shift
             ;;
          -o|--output)
             echo "Output result to $2 directory"
             shift 2
             ;;
          --)
             shift
             break
             ;;
      esac
  done
  ```

  - --options表示短选项，--longoptions表示长选项，这里使用的是上述getopt命令的第三种形式。
  - 如果--options、--longoptions后要指定多个选项参数，不同选项之间可以通过","进行分割指定；如果选项需要跟随一个参数，该选项后面需要加":"，如果选项后面需要跟随一个可选参数，该选项后面需要加"::"

- 其他例子

  ```
  #!/bin/bash
  
  #echo $@
  
  #-o或--options选项后面接可接受的短选项，如ab:c::，表示可接受的短选项为-a -b -c，其中-a选项不接参数，-b选项后必须接参数，-c选项的参数为可选的
  #-l或--long选项后面接可接受的长选项，用逗号分开，冒号的意义同短选项。
  #-n选项后接选项解析错误时提示的脚本名字
  ARGS=`getopt -o ab:c:: --long along,blong:,clong:: -n 'example.sh' -- "$@"`
  if [ $? != 0 ]; then
      echo "Terminating..."
      exit 1
  fi
  
  #echo $ARGS
  #将规范化后的命令行参数分配至位置参数（$1,$2,...)
  eval set -- "${ARGS}"
  
  while true
  do
      case "$1" in
          -a|--along) 
              echo "Option a";
              shift
              ;;
          -b|--blong)
              echo "Option b, argument $2";
              shift 2
              ;;
          -c|--clong)
              case "$2" in
                  "")
                      echo "Option c, no argument";
                      shift 2  
                      ;;
                  *)
                      echo "Option c, argument $2";
                      shift 2;
                      ;;
              esac
              ;;
          --)
              shift
              break
              ;;
          *)
              echo "Internal error!"
              exit 1
              ;;
      esac
  done
  
  #处理剩余的参数
  for arg in $@
  do
      echo "processing $arg"
  done
  ```

  - 这个set --也可以直接简写，不用set -- $()

    ```
    #/bin/bash
    ###################################
    # Extract command line options & values with getopt
    #
    set -- $(getopt -q ab:cd "$@")
    #
    echo 
    while [ -n "$1" ]
    do
      case "$1" in
      -a) echo "Found the -a option" ;;
      -b) param="$2"
          echo "Found the -b option, with parameter value $param"
          shift ;;
      -c) echo "Found the -c option" ;;
      --) shift
          break ;;
       *) echo "$1 is not option";;
    esac
    
      shift
    done
    #
    count=1
    for param in "$@"
    do 
      echo "Parameter #$count: $param"
      count=$[ $count + 1 ]
    done
    #
    ```


##### 批量修改文件名

###### rename

```
rename [options] expression replacement file...
```

- 其中file支持通配符

- 如果只是修改当前目录下的文件只需要执行

  ```
  rename .a .adb *.a
  ```

- 如果目录有嵌套要修改所有的

  ```
  find ./ -name "*.a" | xargs rename .a .adb *
  ```

  - 没有xargs是不对的。

- 如果删除文件名中的某一个子字符串，

  ```
  rename '_with_long_name' '' file_with_long_name.*
         will remove the substring in the filenames.
  示例
  find ./ -name "*.adb" | xargs rename '_b' '' *.adb
  将查找出来的所有文件名中的_b去掉。
  mdx_timer_b.adb变为mdx_timer.adb
  ```

##### nm、objdump、readelf

- nm命令如果不加参数是用来查看目标文件或者可执行文件ELF的符号表的，所以要查看动态库的符号表时不加参数就会出错。如果要查看动态库的符号表需要加参数`nm -D`

##### /dev/zero和/dev/null

- 在类Unix操作系统中，设备节点并不一定要对应物理设备。没有这种对应关系的设备被称之为伪设备。操作系统运用了它们实现多种多样的功能，/dev/null和/dev/zero就是这样的设备，类似的还有/dev/urandom、/dev/tty等。

- 检查下/dev/null和/dev/zero两个文件的属性：

  ```bash
  [root@localhost ~]# ll /dev/null /dev/zero 
  crw-rw-rw- 1 root root 1, 3 Nov 10 05:39 /dev/null
  crw-rw-rw- 1 root root 1, 5 Nov 10 05:39 /dev/zero
  ```

  - 可以看出这两个文件是字符设备文件。

###### /dev/null

- 在类Unix系统中，/dev/null（空设备文件或黑洞文件）是一个特殊的设备文件，所有写入其中的数据，都会被丢弃的无影无踪，/dev/null通常被用于丢弃不需要的数据输出，或作为用于输入流的空文件。这些操作通常由重定向完成。

- 清空文件：

  ```bash
  cat /dev/null >/etc/hosts     将从/dev/null读取到的数据写入到/etc/hosts，表示清空hosts文件。
  cat/etc/hosts                /etc/hosts显示没有数据了
  ```

- 将无用的输出流写入到/dev/null丢弃：

  ```ruby
  [root@localhost ~]# curl www.baidu.com -I | head -1
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                   Dload  Upload   Total   Spent    Left  Speed
    0   277    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  HTTP/1.1 200 OK
  执行上述命令时，会凭空多出来几行无用信息，此时就可以将错误信息定向到/dev/null，以此来丢弃无用信息。
  [root@localhost ~]# curl www.baidu.com -I 2> /dev/null  | head -1
  HTTP/1.1 200 OK
  ```

###### /dev/zero

- 和/dev/null类似，/dev/zero也是一个特殊的字符设备文件，当我们使用或读取它的时候，它会提供无限连续不断的空的数据流（特殊的数据格式流）。

- /dev/zero文件的常见应用场景有二：
  a./dev/zero文件覆盖其他文件信息。
  b.产生指定大小的空文件，例如：交换文件、模拟虚拟文件系统等。

- 产生指定大小的空文件:

  ```kotlin
  [root@localhost ~]# dd if=/dev/zero of=/test.data bs=1M count=2  #<==生成块大小1M，含有2个块的文件。
  2+0 records in
  2+0 records out
  2097152 bytes (2.1 MB) copied, 0.0902584 s, 23.2 MB/s
  [root@localhost ~]# ll -h /test.data 
  -rw-r--r-- 1 root root 2.0M Nov 11 14:34 /test.data  #<==一共2M大小。
  [root@localhost ~]# file /test.data 
  /test.data: data  #<==特殊的数据文件格式。
  ```

- 提示：在使用dd命令产生空文件时常用/dev/zero作为字符流的源。

- 利用/dev/zero文件覆盖其他文件信息:

  ```csharp
  [root@localhost ~]# echo abcde > test.txt  #<==生成一个新文件写入abcde字符串。
  [root@localhost ~]# dd if=/dev/zero of=test.txt bs=1M count=10  #<==用空的字符流覆盖存在的test.txt文件。
  10+0 records in
  10+0 records out
  10485760 bytes (10 MB) copied, 0.056705 s, 185 MB/s
  [root@localhost ~]# cat test.txt   #<==数据丢失了。
  ```

###### /dev/urandom

- 除了 /dev/null 和 /dev/zero 之外，还有一个很重要的文件，即 /dev/urandom，它是“随机数设备”，它的本领就是可以生成理论意义上的随机数。

- 如果我们想清除硬盘里的某些机密数据，就可以使用 /dev/urandom 这个随机数生成器来产生随机数据，写到磁盘上，以确保将磁盘原始数据完全覆盖掉。

  ```
  [root@roclinux ~]# dd if=/dev/urandom of=/dev/sda
  ```

##### dd

###### dd和cp的区别

- ‍cp与dd的区别在于cp可能是以字节方式读取文件，而dd是以扇区方式记取。显然dd方式效率要高些。

- dd最大的用处是他可以进行格式转换和格式化。dd是对块进行操作的，cp是对文件操作的。

- 比如有两块硬盘，要将第一块硬盘里的数据复制到第二块硬盘上

  ```
  dd if=/dev/hda of=/dev/hdc
  ```

  - hda和hdc硬盘上数据的布局是一摸一样的（扇区级别，每个扇区上的数据都是一样的）

- cp只是将第一硬盘上的数据复制到第二个硬盘上，由于系统写硬盘不是顺序写的，哪里有足够的空间放就放到哪，所以第二个硬盘相同的扇区号上的数据和第一块硬盘是可能不一样的。
- dd命令可以用来进行整个partition或者disk的备份
