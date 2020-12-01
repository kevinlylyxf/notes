- linux中--(两个-)一般是命令选项的全称，-一般为命令选项的简称。两个-存在的意义，当命令太多，简写不能指明时，只能用两个-全称来写。ls -a,  ls --all
- shell可以使用alias简写指令，如果令简写永久生效，将alias 别名="系统名称"（双引号要写）写到.bashrc文件中
- ls -l 中列出的10位数字中第一位d表示是directory目录的意思
- 一个系统里面可以有很多用户，whoami可以查看当前在哪个用户，who am i 也可以，不太一样。whereis可以查看软件的位置，不能查看文件的位置。
- apt-cache search 软件名称，可以查看软件介绍
- | 这是竖线，表示管道，就是将一条命令中前面的输出作为后面的输入。ls | grep a ,列出当前目录下包含a字母的所有东西。
- which 用来查找可执行文件的位置。例如查找当前python环境  which python 可以查找python是运行anaconda中的，不是其他的python，这个命令主要用来查找当前环境中运行的文件是在哪，运行的哪个
- locate 基于数据库的文件查找，效率最高，新建文件之后要更新数据库，sudo updatedb,查找新建的就能找到。
- tldr的意思是「Too long, Don't read」,man手册查出来的东西太多不爱看，这个命令可以将一些常用的命令简化的解释。
- id 可以查看用户所处的组，查看用户所处的权限。
- su和su - 的区别，su不切换当前的家目录，而su - 切换用户之后会切换到用户的家目录。其中的-号相当于更新当前的环境，相当于重新登录用户。
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
   - > 输出重定向，将内容重定向到另一个地方，文件会覆盖，>> 跟>大体相同，只是会在后面添加，不会覆盖
   - < 输入重定向，将一个文件的内容输入到前面的文件，例./a.out < input <<用来指示结尾 例如cat >>a.log << haha 此时会在终端里向a.log输入数据，当输入haha时结束。主要用在脚本里自动生成一些数据
   - '' 硬转移，其括起来的元字符，通配符都会被关掉，""软转义其内部可以出现特定的元字符如\ `
   - \ 反斜杠，转义，去除其后紧跟的元字符或通配符的特殊含义，只是一个字符。例如写程序时另起一行就可以用\回车来进行，此时回车只是回车，没有特殊含义。
- env 查看所有的环境变量，PATH，SHELL
- export 增加环境变量的值，在.bashrc中增加会一直存在。export PATH="...:$PATH"，环境变量中以：分隔，所以：$PATH是以前的环境变量
