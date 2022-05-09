#### shell脚本

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

#### Linux常用命令

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
  - 意思是执行一些命令之后在需要输入一些东西时，需要重复的人工输入，每次运行都需要输入，此时可以使用expect来交互完成，就不需要输入密码这类重复输入的东西了。
