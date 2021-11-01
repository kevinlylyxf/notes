- linux中--(两个-)一般是命令选项的全称，-一般为命令选项的简称。两个-存在的意义，当命令太多，简写不能指明时，只能用两个-全称来写。ls -a,  ls --all
- shell可以使用alias简写指令，如果令简写永久生效，将alias 别名="系统名称"（双引号要写）写到.bashrc文件中
- ls -l 中列出的10位数字中第一位d表示是directory目录的意思
- 一个系统里面可以有很多用户，whoami可以查看当前在哪个用户，who am i 也可以，不太一样。whereis可以查看的东西比which多，可以查看man手册在哪。
- apt-cache search 软件名称，可以查看软件介绍
- | 这是竖线，表示管道，就是将一条命令中前面的输出作为后面的输入。ls | grep a ,列出当前目录下包含a字母的所有东西。
- which 用来查找PATH路径下可执行文件的位置。例如查找当前python环境  which python 可以查找python是运行anaconda中的，不是其他的python，这个命令主要用来查找当前环境中运行的文件是在哪，运行的哪个
- locate 基于数据库的文件查找，效率最高，新建文件之后要更新数据库，sudo updatedb,查找新建的就能找到。
- tldr的意思是「Too long, Don't read」,man手册查出来的东西太多不爱看，这个命令可以将一些常用的命令简化的解释。
- id 可以查看用户所处的组，查看用户所处的权限。
- su和su - 的区别，su不切换当前的家目录，不改变当前环境，跟最开始登录一样。而su - 切换用户之后会切换到用户的家目录。其中的-号相当于更新当前的环境，相当于重新登录用户。
- 在terminal中有0、1、2三种文件，0为标准输入，1为标准输出，2为标准错误输出。例 ls /etc1 2>/dev/null,没有etc1这个文件，所以会有标准错误输出，也就是2，此时通过重定向就将错误输出重定向出去。
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%96%87%E4%BB%B6%E5%8F%8A%E7%9B%AE%E5%BD%95.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%96%87%E4%BB%B6%E5%86%85%E5%AE%B9%E7%9A%84%E6%9F%A5%E7%9C%8B%E4%B8%8E%E4%BF%AE%E6%94%B9.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%96%87%E4%BB%B6%E7%9A%84%E6%9F%A5%E6%89%BE%E4%B8%8E%E5%AE%9A%E4%BD%8D.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E7%94%A8%E6%88%B7%E7%9B%B8%E5%85%B3%E5%91%BD%E4%BB%A4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E8%BF%9B%E7%A8%8B%E7%9B%B8%E5%85%B3%E5%91%BD%E4%BB%A4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E7%B3%BB%E7%BB%9F%E4%BF%A1%E6%81%AF%E6%8D%95%E8%8E%B7%E5%91%BD%E4%BB%A4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E5%85%B6%E4%BB%96%E5%91%BD%E4%BB%A4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%96%87%E4%BB%B6%E7%B1%BB%E5%9E%8B.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/man%E6%89%8B%E5%86%8C%E6%95%B0%E5%AD%97%E5%90%AB%E4%B9%89.png)
- usermod 是修改用户所属组的，修改用户的信息，chgrp修改文件的所属组,chown是修改文件的所属用户所属组的,-g是修改组，-G是添加附加组
man -f   man -key
- 通配符 ？代表单个任意字符，\*代表多个任意字符，[]代表匹配任意单个字符，例如ls [0-9].c {}匹配字符串
- 任务管理
   - & 在命令的后面加上&表示后台执行的意思
   - ；在命令之间以；相连，表示顺序执行的意思
   - && 命令之间以&&相连，只有第一个命令执行成功，第二个命令才会执行
   - || 如果第一个命令失败，则执行第二个命令
   - \`\`命令替换符，命令中如果包含另一个命令，则用符号\`\`将它包括起来，在执行完子命令后，然后将其结果带入父命令继续执行，就相当于找了个变量记录命令结果，在执行其他命令时需要用就调出来。例如p=\`ls\`，需要结果时在调出来echo $p
   - 在shell中执行命令时，同时按下ctrl+z可以将资源暂时挂起，相当于停下来啥也不干，不占用资源。jobs可以查看挂起的任务，fg可以调回来最近的任务。例如在写vim时可以暂时挂起。%加序号可以调回序号的任务。
   - bg 执行bg，可以将挂起的命令后台执行。
---
- 管道、重定向
   - \> 输出重定向，将内容重定向到另一个地方，文件会覆盖，>> 跟>大体相同，只是会在后面添加，不会覆盖
   - < 输入重定向，将一个文件的内容输入到前面的文件，例./a.out < input <<用来指示结尾 例如cat >>a.log << haha 此时会在终端里向a.log输入数据，当输入haha时结束。主要用在脚本里自动生成一些数据
   - ''硬转义，其括起来的元字符，通配符都会被关掉，""软转义其内部可以出现特定的元字符如\ `
   - \ 反斜杠，转义，去除其后紧跟的元字符或通配符的特殊含义，只是一个字符。例如写程序时另起一行就可以用\回车来进行，此时回车只是回车，没有特殊含义。
- env 查看所有的环境变量，PATH，SHELL
- export 增加环境变量的值，在.bashrc中增加会一直存在。export PATH="...:\$PATH"，环境变量中以：分隔，所以：$PATH是以前的环境变量
- man bash 查看bash手册，通过/FILES可以查看配置文件，n是查找下一个。
- ls --help 可以查看选项参数，好多命令可以这样查看。
- w命令展示谁登录系统以及正在做什么的一些信息
- tmux命令
---
- inode 磁盘的最小存储单位叫做扇区，每个扇区储存512字节，磁盘读取的时候是按block读取的读取的，一个block包含几个扇区，最常见的block大小为4K。文件的另外一些信息需要别的地方储存，例如文件的日期，修改日期，文件的拥有者文件的所属组，mtime，atime，ctime之类的，这些信息都存在inode中，每个文件都有一个inode，inode消耗存储空间，硬盘中有一个区域是专门来存inode的，linux中使用inode号码来识别文件，表面上，用户通过文件名，打开文件。实际上，系统内部这个过程分成三步：首先，系统找到这个文件名对应的inode号码；其次，通过inode号码，获取inode信息；最后，根据inode信息，找到文件数据所在的block，读出数据。
- 硬连接，多个文件名指向同一个inode号码，对文件内容的修改影响到所有文件名，删除一个文件不影响另一个文件。ln
- 软连接，文件A指向文件B的路径，所以读取A就是读取B，此时是软连接，ln -s
---
### shell编程
- ./sh可以执行脚本，也可以bash .sh 使用bash执行脚本
- 定义局部变量 local a=12
- $0 获取当前执行shell脚本的文件名包括路径。
- \$n，用来获取当前脚本执行的第n个参数，类似./a.out <input，此时input就是参数，只是写在程序执行时候，在shell脚本中不需要写<符号，可以在后面写几个参数，每一个都会与$匹配。
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/shell%E7%89%B9%E6%AE%8A%E5%8F%98%E9%87%8F.png)
- \$? 判断上一条指令是否执行成功，0为成功，非0为不成功，这是判断指令是否执行成功时用的，而0，1，2是指指令的输入输出结果的，可以在指令中使用1>或2>重定向输出，但是其成功与否使用\$?,\$?只是对上一条指令负责其结果可以作为流程控制if的条件，0代表成功，\$?也可以得到return的值，但是不常用。可以用if判断，如果为0则进行then后面的，否则进行else后面的
- read -s -p "请输入密码:" -t 2 pw 命令解释-p就是显示提示信息，-s就是输入时不显示在屏幕上，-t 2就是超时2s结束命令，pw就是输入的密码存入到pw
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E8%BE%93%E5%85%A5%E8%BE%93%E5%87%BA.png)
- echo -e ，使用\转义，\n换行的意思，使某些字母有特殊的含义。 backslash反斜杠的意思
- man test可以查看判断时的语句类似与-eq之类的判断语句写法
- 函数写法，可以在前面写个function，也可以不写，最好写上，有返回值就写return，没有就不写。
- 判断分支if,写法if 条件表达式 ;then fi ,或者else，或者elif then，then写在一行加；不在一行另起一行时不加，最后写fi
- while写法while ;do done
- for写法 for(());do done，中间要写两个括号，里面可以写c++里面的循环语句。
- 变量名外面的花括号是可选的，加不加都行，加花括号时候为了帮助解释器识别变量的边界，使用变量是加$
- 条件表达式要放在中括号里面，并且需要有空格。中括号也进行基本的算数运算，条件表达式有两个中括号，算数运算只有一个。
- shell中的算数运算，使用expr或者$[],不能直接进行运算，结果是错误的。expr进行\*运算时，必须进行\转义，否则*有特殊含义。
- \${a[@]} \${a[\*]}，输出数组里所有元素。${#a[*]}，输出数组中元素个数。#换成!找到数组下标。
- unset删除数据或数组里的值，或是直接删除一个数组
- > ```last | grep -v "wtmp begins" | grep -v "^$" | cut -d ' ' -f 1 | sort | uniq -c | sort -n -r |  head -n 1 ```
---
## 文件及目录操作
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/u%E6%8B%B7%E8%B4%9D.png) 
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/cat%E5%91%BD%E4%BB%A4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/nl.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/tail.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/head.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%96%87%E4%BB%B6%E6%97%B6%E9%97%B4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E4%BF%AE%E6%94%B9%E6%96%87%E4%BB%B6%E6%97%B6%E9%97%B4.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/find1.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/find2.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/find3.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%96%87%E4%BB%B6%E7%9A%84%E7%89%B9%E6%AE%8A%E6%9D%83%E9%99%90.png)
- 文件的隐藏属性chattr和lsattr命令
- set_uid，占位符s，没有多余的位置，占的是x的位置，如果有x就是小写的s，没有x就是大写的S，其作用是在执行该程序时获取程序所有者权限，例如，ls -l /etc/shadow,列出来的为-rw-r----- 1 root shadow 1433 Oct 23 11:57 /etc/shadow，其所属为root，ls -l \`which passwd`，显示出来的为-rwsr-xr-x 1 root root 59640 Aug 21  2019 /usr/bin/passwd，此地有s，说明在进行passwd时可以获得passwd所属root的权限
- set_gid，和set_uid类似，其是将文件的所属组改变，便利协同办公，几个用户创建的文件，用户所属的组不同，但是在这个目录下创建的文件所属的组都是一个
---
## 数据操作
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/%E6%95%B0%E6%8D%AE%E6%8F%90%E5%8F%96.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/wc.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/sort.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/tr.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/cut.png)
![](https://raw.githubusercontent.com/kevinlylyxf/notes/master/pictures/ubuntu/grep.png)
