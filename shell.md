### shell脚本

- shell变量
   - Bash shell默认情况下不会区分变量类型，即是将整数和小数赋值给变量，也会被视为字符串，可以使用declare关键字显示定义变量的类型，一般情况下没有这个需求
   - 三种定义变量的方式，variable=value,variable='value',variable="value",variable是变量名，value是赋给变量的值，如果value不包含任何空白符(空格、Tab缩进)，可以不用引号，单引号引起来的是什么就输出什么，不希望解析变量命令。双引号引起来的输出时会先解析里面的变量和命令。不被引号包围的字符串不能出现空格，否则空格后边的字符串会作为其他便利情或者命令解析。
   - 赋值号=周围不能有空格
   - 使用变量，在变量名前面加$符号，变量名字前面有没有{}都可以，加括号是为了帮助解释器识别变量的边界，良好的编程习惯
   - 将命令的结果赋值给变量 variable=`command`,variable=$(command),第一种方式用反引号包围起来，第二种方式用$()包围起来更常用。例如log=$(cat log.txt),echo $log
   - 只读变量 readonly variable，删除变量unset，unset不能删除只读变量
- shell变量的作用范围
   - shell函数中定义的变量默认是全局变量，它和在函数外定义的变量一样的效果
   - 局部变量定义时加上local
   - 全局变量的作用范围是当前的shell进程，不是当前的shell脚本文件，例如在当前shell进程中定义a=99,有一个a.sh脚本，里面有echo $a,此时运行脚本会输出99，说明在shell进程中全局变量的作用域
   - 环境变量，使用export命令将全局变量导出，那么它的子进程也可以使用了，没有关系的两个进程不可以使用。进入子进程直接输入bash命令就行，exit退出
- shell命令替换
   - shell命令替换是指将命令的输出结果赋值给某个变量。
   - 可以使用；使用多个命令例如$(cd `dirname $0`;pwd)，$0是文件名,dirname就是获取当前文件路径的上一级路径，例如dirname /usr/bin,结果为/usr,dirname stdio.h,结果为.一个点，即表示当前目录,dirname /home/lyl/a/test.sh,结果为/home/lyl/a.后续如果要用的话直接cd进去，pwd显示当前路径，用命令替换给变量。这样就得到了路径名。文件名和路径不一样。这样操作下来其实就是用一个变量代替了路径名称，用的时候直接cd进去，就直接到了工作目录。
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
   - shell字符串截取
      - 从左边开始计数${string:start:length} url="c.biancheng.net" echo ${url:2:9} 省略length参数默认截取到字符串末尾
      - 从右边开始计数${string:0-start:length} 0-是固定写法表示从右边计数
      - 从指定字符开始截取 ${string#\*chars}使用#可以截取指定字符(或子字符串)右边的所有字符，即删除左边的，取右边的字符。*表示忽略左边的所有字符直到指定chars，如果不需要忽略chars左边的字符，可以不写\*，但是chars需要从头写起，上述写法是遇到第一个匹配的字符就结束了，如果希望直到最后一个指定字符，可以使用##,${string##\*chars
```shell
str="---aa+++aa@@@"
echo ${str#*aa}   #结果为 +++aa@@@
echo ${str##*aa}  #结果为 @@@
```
      - 使用%截取指定字符或字符串左边的所有字符，即取左边的删除右边的，从右往左查找。因为要截取chars左边的字符，忽略chars右边的字符，所以\*应该位于chars的右侧，其他方面%和#用法相同，%是从右往左查找。${string%chars\*}
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
   - alias，如果不带参数可以查看当前环境下所有的alias，使用unalise删除别名。   - echo，默认加上换行，echo -n表示不换行。默认情况下echo不会解析\开头的转义字符，比如\n表示换行,添加参数-e来让echo命令解析转义字符例如echo -e "hello\nworld"会分两行输出
- shell数学计算
   - 在 Bash Shell 中，如果不特别指明，每一个变量的值都是字符串，无论你给变量赋值时有没有使用引号，值都会以字符串的形式存储
   - shell中要进行数学运算必须使用数学计算命令  (())用于整数计算，效率很高。bc可以进行小数计算
   - ((b=a-15))，在括号里面可以不用加$前缀使用变量，取用结果时$b就行，如果里面没有变量需要$((1+2))。使用(())可以进行逻辑运算，大于小于，与或非之类的。可以在里面同时对多个表达式进行计算。((a=3+5,b=a+10))，如果没有赋值即((3+5,a+10)),以最后一个计算结果为结果
   - bc，echo "scale=4;3\*8/7;last\*5"|bc，通过管道输入到bc计算，scale设置小数点几位数字。
   - test命令或者写成[],test expression,或者[expression],用来检测某个条件是否成立，可以进行数值，字符串和文件三个方面的检测。[]这样写时和expression之间有空格
      - 文件类型相关 -b，判断文件是否存在，并且是否为块设备文件 -d，判断文件是否存在，并且是否为目录文件 -f，判断文件是否存在，并且是否为普通文件。-e，只判断文件
      - 文件权限判断 -r -w -x -u -g -k
      - 文件比较 -nt -ot -ef
      - 数值比较 -eq 相等 -ne 不相等 -gt 大于 -lt 小于 -ge大于等于 -le小于等于
      - 字符串判断 -z 是否为空 -n 是否非空 ==  != \> \< ,这样写防止将>认为成重定向运算符
      - 逻辑判断相关的 -a 与 -o 或 ！非
      - 当你在 test 命令中使用变量时，我强烈建议将变量用双引号""包围起来，这样能避免变量为空值时导致的很多奇葩问题
- [[]] 是shell内置关键字，用来检测某个条件是否成立，test能干的，[[]]也能干且干的更好。[[]]支持正则表达式
   - [[ ]] 对数字的比较仍然不友好，所以我建议，以后大家使用 if 判断条件时，用 (()) 来处理整型数字，用 [[ ]] 来处理字符串或者文件。
   - [[]]支持正则表达式，即支持字符串模糊匹配，而[]不支持模糊匹配。模糊匹配时，模糊匹配项不要加""，否则模糊匹配符也会当作字符处理。
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

  ```
  $ ./myscript.py &
  [1] 1337
  ```

  - 注意按照这种方法分支出去的sub-shell的stdout会仍然关联到其parent-shell，也就是说你在当前的terminal中仍然可以发现这个后台进程的stdout输出。所有的到stdout的输出都能打印出来，即使在后台运行。如果不需要打印，需要重定向。

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
  ./script.py & ./script2.py & ./script3.py & 
  ```

  - 在这个例子中，三个脚本会同时开始运行，且拥有各自独立的sub-shell环境。在shell脚本中，这个方法常常被用来利用计算机的多核性能来加速执行。
  - 如果你想创建个完全和当前的shell独立的后台进程（而不是想上面提到的用`&`创建的，和当前shell的stdout关联的方法），可以使用`nohup`命令。

- 有时候在shell命令中可能看到这样的写法：

  ```
  some_command > /dev/null 2>&1
  ```

  - 尽管我将输出重定向到 /dev/null，但它仍打印在终端中。这是因为我们没有将错误输出重定向到 /dev/null，所以为了也重定向错误输出，需要添加 2>&1：
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
  - `**command &>filename会重定向命令`command`标准输出`（stdout）`和标准错误`（stderr`）到文件`filename`中.直接重定向两个

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

- 在Shell中我们通常将EOF与 << 结合使用，表示后续的输入作为子命令或子Shell的输入，直到遇到EOF为止，再返回到主调Shell。回顾一下< <的用法，当shell看到< <的时候，它就会知道下一个词是一个分界符。在该分界符以后的内容都被当作输入，直到shell又看到该分界符(位于单独的一行)。这个分界符可以是你所定义的任何字符串。

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

- while read line如果不是从文件中重定向的话，会一直等待输入，直到按ctrl-D

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

- 让我们仔细地区别变量和变量的值。如果`**variable1**`是一个变量的名字，那么`**$variable1**`就是引用这个变量的值――即这个变量它包含的数据。如果只有变量名出现（即指没有前缀$），那就可能是在1）声明一个变量或是在给这个变量赋值。2）声明废弃这个变量，3）导出（[exported](http://shouce.jb51.net/shell/internal.html#EXPORTREF)）变量，4）或是在变量指示的是一种[信号](http://shouce.jb51.net/shell/debugging.html#SIGNALD)的特殊情况。（参考[例子 29-5](http://shouce.jb51.net/shell/debugging.html#EX76)）。变量赋值可以使用等于号（＝），比如：var1=27。也可在[read](http://shouce.jb51.net/shell/internal.html#READREF)命令和在一个循环的情况下赋值，比如：for var2 in 1 2 3。

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

  - 此时引号引起来的不被命令行解释二十将参数传到grep命令中，有grep命令来解释。

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

- 当要引用一个变量的值时，一般推荐使用双引号。使用双引号除了变量名[[2\]](http://shouce.jb51.net/shell/quoting.html#FTN.AEN1994)前缀($)、后引符(`)和转义符(\)外，会使shell不再解释引号中其它所有的特殊字符。[[3\]](http://shouce.jb51.net/shell/quoting.html#FTN.AEN2000) 用双引号时$仍被当成特殊字符，允许引用一个被双引号引起的变量("$variable"), 那也是说$variable会被它的值所代替。

- 用双引号还能使句子不被分割开. [[4\]](http://shouce.jb51.net/shell/quoting.html#FTN.AEN2024) 一个参数用双引号引起来能使它被看做一个单元，这样即使参数里面包含有[空白字符](http://shouce.jb51.net/shell/special-chars.html#WHITESPACEREF)也不会被shell分割开了。

  ```
  COMMAND $variable2 $variable2 $variable2        # 没有带参数执行COMMAND 命令
  COMMAND "$variable2" "$variable2" "$variable2"  # 用三个含空字符串的参数执行COMMAND命令
  COMMAND "$variable2 $variable2 $variable2"      # 用一个包含两个空白符的参数执行COMMAND命令
  ```

  - 上面这是一个示例

- 在命令行上，把感叹号"!"放在双引号里执行命令会出错（译者注：比如说：echo "hello!"）. 因为感叹号被解释成了一个[历史命令](http://shouce.jb51.net/shell/histcommands.html). 然而在一个脚本文件里，这么写则是正确的，因为在脚本文件里Bash的历史机制被禁用了。在双号号里在字符"\"也会引起许多不一致的行为。

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

- *转义*是引用单字符的方法.在单个字符前面的转义符(\)告诉shell不必特殊解释这个字符，只把它当成字面上的意思。但是一些字符前面加上反斜杠是有特殊的含义的。

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

- 其余的就是正常的转义的含义，表示其字符本身，例如`\"，\$，\\`

#### 测试

- 一个**if/then**结构测试一列命令的[退出状态](http://shouce.jb51.net/shell/exit-status.html#EXITSTATUSREF)是否为0（因为依照惯例，0意味着命令执行成功），如果是0则会执行一个或多个命令。

- 有一个命令 **[** ([左方括](http://shouce.jb51.net/shell/special-chars.html#LEFTBRACKET)是特殊字符). 它和**test**是同义词,因为效率的原因，它被[内建](http://shouce.jb51.net/shell/internal.html#BUILTINREF)在shell里。这个命令的参数是比较表达式或者文件测试，它会返回一个退出状态指示比较的结果(0表示真，1表示假)。

  - 每个表达式执行完退出的时候，都会返回一个退出状态码(exit status 0～255)，if语句根据 [ ] 表达式执行的退出状态码进行判断，在所有的退出状态码中，0表示执行成功，1~255为退出的状态代号（详见下表）。所以，与C语言不同的就在这里，shell的if [ 1 ] 中整数 0 1 与C语言中的 while(1)用法并不相通，也就是说整数 0 1 作为退出状态码的时候，确实表示真假，但是并不能作为 if [ ] 的判断条件来用，虽然shell也是弱数据类型的语言。
  - 也就是说if []里面不能直接写0和1这种判断，因为直接写数字0判断结果也是真，写数字1判断结果也是真，和c语言中的不一样，判断表达式的返回结果时确实是0代表真，1代表假。

- 在版本2.02，Bash引入了[[[ ... \]]](http://shouce.jb51.net/shell/tests.html#DBLBRACKETS) 扩展的测试命令，它使熟悉其他语言中这种比较测试的程序员也能很快熟悉比较操作。注意[[是一个[关键字](http://shouce.jb51.net/shell/internal.html#KEYWORDREF) ，不是一个命令。

  Bash把[[ $a -lt $b ]]看成一个返回退出状态的单元。

- 如果 (( ... )) 和 let ... 构造计算的算术表达式扩展为非零值，则它们也返回退出状态 0。因此，这些算术扩展结构可用于执行算术比较。

  - 上面的意思是说如果表达式为假的话，let和(())返回1，为真返回0，因为在shell中0代表真。上面两种表达式的真假和我们平常认识的真假意思一样。
  - []和[[]]的表示结果是一样的，只是双括号是单括号的升级版。
  - (())和let也可以用if判断真假，这个真假和我们平常认识的真假一样，非0表示真，0表示假，但是这种判断会有一种返回状态，非0的返回状态时0，就和shell的真假对应起来了。

- **if** 命令不仅能测试由方括号括起来的条件，也能测试任何命令。

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

  - 注意"<"字符在`**[ ]**` 结构里需要转义

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
  if [ $string1 ]       # 这次,变量$string1什么也不加.此时返回结果为假，上面所有的都是为初始化的变量。
  
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
  ture命令是内建的.
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

  - 和[重定向操作符](http://shouce.jb51.net/shell/io-redirection.html#IOREDIRREF)（>）连用, 可以把一个文件的长度截短为零，文件的权限不变。如果文件不存在，则会创建一个新文件。

    ```
     : > data.xxx   # 文件"data.xxx"现在长度为0了	      
     
     # 作用相同于：cat /dev/null >data.xxx（译者注：echo >data.xxx也可以）
     # 但是，用NULL（:）操作符不会产生一个新的进程，因为NULL操作符是内建的。
    ```

  - 和添加重定向操作符（>>）连用(`**: >> target_file**`).如果目标文件存在则什么也没有发生，如果目标文件不存在，则创建它。

###### （）

- 一组由圆括号括起来的命令是新开一个[子shell](http://shouce.jb51.net/shell/subshells.html#SUBSHELLSREF)来执行的.

  - 因为是在子shell里执行，在圆括号里的变量不能被脚本的其他部分访问。因为[父进程（即脚本进程）不能存取子进程（即子shell）创建的变量](http://shouce.jb51.net/shell/subshells.html#PARVIS)。（译者注：读者若对这部分内容感兴趣，可以参考stevens的<<Advance Unix Environment Programing>>一书中对进程的描述。）.

    ```
    a=123
    ( a=321; )	      
     
    echo "a = $a"   # a = 123
    # 在圆括号里的变量"a"实际上是一个局部变量，作用局域只是在圆括号内用于数组始初化
    ```

- 数组初始胡

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

- 每个`**[list]**`中的元素都可能包含多个参数.在处理参数组时,这是非常有用的.在这种情况下,使用[set](http://shouce.jb51.net/shell/internal.html#SETREF)命令(见[例子 11-15](http://shouce.jb51.net/shell/internal.html#EX34))来强制解析每个[list]中的元素,并且分配每个解析出来的部分到一个位置参数中.

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

- 在一个for循环中忽略`**in [list]**`部分的话,将会使循环操作$@(从命令行传递给脚本的参数列表).一个非常好的例子,见[例子 A-16](http://shouce.jb51.net/shell/contributed-scripts.html#PRIMES).

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

  

### Linux常用命令

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

##### su -

- su和su - 的区别，su不切换当前的家目录，不改变当前环境，跟最开始登录一样。相当于su 到那个用户获得那个用户对文件的权限，而su - 切换用户之后会切换到用户的家目录。其中的-号相当于更新当前的环境，相当于重新登录用户。
- 例如在root下编译内核，提示要用普通用户编译，所以su - yq切换到普通用户，但是又提示权限不够，所以su 得到root权限，但是没有完全切换到root登录。

##### sync

- [用户缓冲区和内核缓冲区]: https://www.cnblogs.com/BlueBlueSea/p/14807245.html

- sync命令是强制把内存中的数据写回硬盘，以免数据的丢失。主要还是和缓冲区有关，理解了缓冲区就理解了sync命令。缓冲区可以在c.md里面查看

- mount挂载之后直接umount文件就会出现错误，因为有一部分数据在缓冲区内没有写入到u盘中，所以在umount之前要执行sync命令。每一个文件都有缓冲区，所以在将文件cp 到/mnt中时，每一个文件都开辟了缓冲区，如果没有强制写入硬盘就会出现有一部分数据在缓冲区中没有写入硬盘中。

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

##### netstat

- Linux netstat 命令用于显示网络状态。利用 netstat 指令可让你得知整个 Linux 系统的网络情况。

  ```
  -a或--all 显示所有连线中的Socket。
  -n或--numeric 直接使用IP地址，而不通过域名服务器。拒绝显示别名，能显示数字的全部转化成数字。
  -p或--programs 显示正在使用Socket的程序识别码和程序名称。
  -t或--tcp 显示TCP传输协议的连线状况。
  -u或--udp 显示UDP传输协议的连线状况。
  -i或--interfaces 显示网络界面信息表单。即网卡列表
  -x或--unix 此参数的效果和指定"-A unix"参数相同。即本地套接字连接
  <Socket>={-t|--tcp} {-u|--udp} {-U|--udplite} {-S|--sctp} {-w|--raw}
             {-x|--unix} --ax25 --ipx --netrom
  ```

- 从整体上看，netstat的输出结果可以分为两个部分：

  - 一个是Active Internet connections，称为有源TCP连接，其中"Recv-Q"和"Send-Q"指的是接收队列和发送队列，这些数字一般都应该是0。如果不是则表示软件包正在队列中堆积，这种情况非常少见。
  - 另一个是Active UNIX domain sockets，称为有源Unix域套接口(和网络套接字一样，但是只能用于本机通信，性能可以提高一倍)。RefCnt表示连接到本套接口上的进程号，即连接到本套接字的进程数量。这个列表下proto都是unix表示本地通信。

- 一般使用netstat -anp来查看某个进程查看的端口什么的。


##### find

- Linux find 命令用来在指定目录下查找文件。任何位于参数之前的字符串都将被视为欲查找的目录名。如果使用该命令时，不设置任何参数，则 find 命令将在当前目录下查找子目录与文件。并且将查找到的子目录和文件全部进行显示。

  ```
  find   path   -option   [   -print ]   [ -exec   -ok   command ]   {} \;
  ```

- -print： find命令将匹配的文件输出到标准输出。

- -exec： find命令对匹配的文件执行该参数所给出的shell命令。相应命令的形式为'command' {} \;，注意{}和\;之间的空格。其中使用-exec时后面的{} 和\;一定要有，否则不能正常执行。

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

  - ！表示非，！-name表示不取以~开头的备份文件，-exec就是对查找到的文件执行命令。

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
