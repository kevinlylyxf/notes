#### Git处理不同系统CR和LF问题

- 不同操系统下的换行符

  ```bash
  在文本处理中，CR（CarriageReturn），LF（LineFeed），CR/LF是不同操作系统上使用的换行符，具体如下：
  Dos和Windows采用回车+换行CR/LF表示下一行
  而UNIX/Linux采用换行符LF表示下一行
  苹果机(MAC OS系统)则采用回车符CR表示下一行
  
  CR与LF区别如下：
  CR用符号r表示，十进制ASCII代码是13，十六进制代码为0x0D
  LF使用n符号表示，ASCII代码是10，十六制为0x0A
  
  一般操作系统上的运行库会自动决定文本文件的换行格式。如一个程序在Windows上运行就生成CR/LF换行格式的文本文件，而在Linux上运行就生成LF格式换行的文本文件。在一个平台上使用另一种换行符的文件文件可能会带来意想不到的问题，特别是在编辑程序代码时。有时候代码在编辑器中显示正常，但在编译或者运行时却会因为换行符问题而出错。很多文本/代码编辑器带有换行符转换功能（Notepad++），使用这个功能可以将文本文件中的换行符在不同格式中互换。
  ```

- 换行符的问题在有的系统上不影响功能，即脚本执行的时候或者程序编译的时候都不影响，但是有的系统不行，所以在出现^M或者编译出问题的时候就要注意这个问题

- linux下vim打开文件显示^M问题

  - 为什么会出现这个问题，有两种情况

    - vim被配置为fileformat=unix，而你打开的文件都是dos格式的。unix格式的换行符为0A（ascii码）也就是<LF>，dos格式的换行符为 0D 0A(也就是<CR><LF>)，<CR>其实就显示为^M。这跟vim的配置有关，vim可以配置为即可以认识dos的也可以认识unix的。如果只设置成unix的就会出现上面的问题。
    - 文本中既有unix的换行符，又有dos的换行符，那么vim会认为你打开的是unix的，所以，那些dos的换行符就会出现恼人的^M。不过这种情况不常见

  - 解决办法

    - 使用dos2unix命令，如果没有使用包管理工具下载一个

    - 命令模式删除

      ```bash
      :%s/^M$//g         # 去掉行尾的^M。
      :%s/^M//g       # 去掉所有的^M。
      :%s/^M/[ctrl-v]+[enter]/g       # 将^M替换成回车。 
      :%s/^M/\r/g         # 将^M替换成回车。
      这里的^M并不是字符，而是用ctrl+shift+v crtl+shift+m来生成，切记不是字符。或者用ctrl+v+回车键来生成。
      ```

      - CR是控制字符，并不能显示具体的字符，所以我们需要用一些特殊的字符来显示，否则就看不到区别了，例如CR/LF中的CR用^M来显示，这样我们就知道有这样一个控制字符了。

      - 同理，我们在用vim删除的时候，这个^M也不是具体的^和M字符，而是用特殊的输入来替代，否则不能准确的替代CR控制字符。
    
    - sed命令
    
      ```bash
      sed -e ‘s/^M/\n/g’ myfile.txt
      这里的^M也不是字符，和上面一样输入
      ```
    
    - 如果是上面第一种问题情况，就将文件保存为unix格式的，set ff=unix，保存就可以。
    
    - 使用IDE工具转换换行符，这个比较简单

- Git解决方法

  ```shell
  在git bash 中设置
  	windows下建议设置autocrlf为true，safecrlf为true，
  
  下面为参数说明，--global表示全局设置
  
  2.1、autocrlf
  
  #提交时转换为LF，检出时转换为CRLF，检出即为clone
  git config --global core.autocrlf true
  
  #提交时转换为LF，检出时不转换
  git config --global core.autocrlf input
  
  #提交检出均不转换
  git config --global core.autocrlf false
  
  2.2、safecrlf
  
  #拒绝提交包含混合换行符的文件
  git config --global core.safecrlf true
  
  #允许提交包含混合换行符的文件
  git config --global core.safecrlf false
  
  #提交包含混合换行符的文件时给出警告
  git config --global core.safecrlf warn
  ```

  - 设置 core.autocrlf=true 后，我们工作区的文件都应该用 CRLF 来换行。如果改动文件时引入了 LF，或者设置 core.autocrlf 之前，工作区已经有 LF 换行符。提交改动时，git 会警告你哪些文件不是纯 CRLF 文件，但 git 不会擅自修改工作区的那些文件，而是对暂存区（我们对工作区的改动）进行修改。也因此，当我们进行 git add 的操作时，只要 git 发现改动的内容里有 LF 换行符，就还会出现这个警告。LF will be replaced by CRLF。

### 开始一个工作区

#### clone

- 把远程仓库完整复制一份到本地

##### 基本用法

```
git clone <仓库地址>
```

```
git clone https://github.com/user/repo.git
```

- 执行后会发生：
  - 创建一个 `repo` 文件夹
  - 下载所有代码
  - 自动关联远程仓库（默认叫 `origin`）
  - 自动 checkout 默认分支（通常是 `main` 或 `master`）

##### 指定目录名

```
git clone <仓库地址> <目录名>
```

```
git clone https://github.com/user/repo.git my_project
```

- 会克隆到 `my_project/` 目录，而不是默认的 repo

##### 常用参数

######  只克隆指定分支

```
git clone -b dev <仓库地址>
```

- 只拉 `dev` 分支

###### 浅克隆（加速）

```git
git clone --depth 1 <仓库地址>
```

- 只下载最近一次提交
- 很适合：
  - 大仓库
  - CI/CD
  - 临时查看代码

###### 克隆指定分支 + 浅克隆

```
git clone -b dev --depth 1 <仓库地址>
```

###### 使用 SSH 克隆

```
git clone git@github.com:user/repo.git
```

- 优点：
  - 不用输密码（配置 SSH key 后）
  - 更适合长期开发

###### clone 后的结构（核心理解）

```
git clone xxx
```

- 等价于做了这些事：

  1. 初始化仓库（`git init`）

  2. 添加远程仓库：

     ```
     git remote add origin xxx
     ```

  3. 拉取代码：

     ```
     git fetch
     ```

  4. 切换分支

     ```
     git checkout main
     ```

###### origin 是什么

- clone 后你会看到：

  ```
  git remote -v
  ```

  - 输出

    ```
    origin  https://github.com/user/repo.git (fetch)
    origin  https://github.com/user/repo.git (push)
    ```

    - `origin` = 默认远程仓库名字（可以改）

#### init

##### 作用

- 把一个普通文件夹变成 Git 仓库
- 本质就是： 在当前目录下创建一个 `.git` 目录

##### 基本用法

```
git init
```

- 执行后你会看到：

  ```
  Initialized empty Git repository in xxx/.git/
  
  中文显示：已初始化空的 Git 仓库于 /home/lyl/lyl/test/.git/
  ```

  - 说明：
    - 这个目录已经被 Git 接管了
    - 可以开始版本控制

##### .git 到底是什么

- `.git` 是整个 Git 的核心，里面包含：
  - 所有提交历史（commit）
  - 分支信息
  - 配置（remote、user等）
  - 暂存区（index）

##### 常用参数

###### 指定默认分支（推荐）

```
git init -b main
```

- 避免默认是 `master`

###### config配置默认分支

- 可以通过 `git config` 设置 `git init` 默认分支名

  ```
  git config --global init.defaultBranch main
  ```

###### 在已有仓库里再执行

```
git init
```

- 不会清空数据，只是“重新初始化”

###### 连接远程仓库

- `git init` 只是本地仓库，如果要推到远程：

  ```
  git remote add origin <仓库地址>
  git push -u origin main
  ```

#### config

##### 作用

- 用来配置 Git 的行为
  - 用户信息（用户名、邮箱）
  - 默认分支
  - 别名（alias）
  - 编辑器
  - 代理等

##### 常见用法

- 设置用户名

  ```
  git config --global user.name "Kevin Li"
  ```

- 设置邮箱

  ```
  git config --global user.email "xxx@example.com"
  ```

- 这两个是必须的，否则无法 commit

##### 配置的三个级别

###### 系统级（所有用户）

```
git config --system
```

- 路径：`/etc/gitconfig`

###### 全局（当前用户）

```
git config --global
```

- 路径：`~/.gitconfig`

###### 仓库级（当前项目）

```
git config
```

- 路径：`.git/config`

###### 优先级（非常重要）

```
system < global < local
```

- 越具体，优先级越高

##### 查看配置

###### 查看所有配置

```
git config --list
```

###### 查看某个配置

```
git config user.name 
或者
git config --get user.name
```

###### 查看配置来源（高级）

```
git config --list --show-origin
```

- 能看到是哪个文件配置的

##### 修改和删除配置

- 修改（直接重新设置即可）

  ```
  git config --global user.name "New Name"
  ```

- 删除配置

  ```
  git config --global --unset user.name
  ```

##### 常用配置

###### 默认分支

```
git config --global init.defaultBranch main
```

###### 设置编辑器

```
git config --global core.editor "vim"
```

###### 开启彩色输出

```
git config --global color.ui auto
```

###### 设置换行规则（跨平台重要）

```
git config --global core.autocrlf true
```

- Windows 常用

##### 设置别名

```
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.cm commit
```

- 以后可以用：

  ```
  git co
  git st
  ```

##### 模板

```
git config --global user.name "Kevin Li"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main
git config --global color.ui auto

# alias
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.cm commit
```

#### remote

##### 作用

- 管理远程仓库（remote）

  ```
  本地仓库 ←→ 远程仓库（GitHub / GitLab）
  ```

##### 核心概念

- 当你 clone 一个仓库时：

  ```
  git clone https://github.com/user/repo.git
  ```

- Git 自动帮你做了：

  ```
  git remote add origin https://github.com/user/repo.git
  ```

  - `origin` = 默认远程仓库名字（只是个名字，可以改）

##### 常用命令

###### 查看远程仓库

```
git remote

输出
origin
```

###### 查看详细信息

```
git remote -v

输出
origin  https://github.com/user/repo.git (fetch)
origin  https://github.com/user/repo.git (push)
```

###### 添加远程仓库

```
git remote add origin <仓库地址>

git remote add origin https://github.com/user/repo.git
```

- 一般用于 `git init` 之后

###### 修改远程仓库地址

```
git remote set-url origin <新地址>
```

- 常见场景：
  - HTTPS → SSH
  - 仓库迁移

######  删除远程仓库

```
git remote remove origin
或者
git remote rm origin
```

###### 重命名远程仓库

```
git remote rename origin upstream
```

##### 多个远程仓库（进阶）

- 你可以有多个 remote：

  ```
  git remote add origin https://github.com/your/repo.git
  git remote add upstream https://github.com/official/repo.git
  ```

- 常见于：

  - fork 项目

- 查看效果

  ```
  git remote -v
  输出
  origin    https://github.com/your/repo.git
  upstream  https://github.com/official/repo.git
  ```

#### .gitignore

- 文件 `.gitignore` 的格式规范如下：

  - 所有空行或者以 `#` 开头的行都会被 Git 忽略。
  - 可以使用标准的 glob 模式匹配，它会递归地应用在整个工作区中。所谓的 glob 模式是指 shell 所使用的简化了的正则表达式
  - 匹配模式可以以（`/`）开头防止递归。其/不是从根目录下开始忽略得，而是从当前目录开始的，并且不会递归到子目录。/TODO表示忽略当前目录下的TODO文件，子目录是不忽略的。例如当前目录下有个bin目录，此时这个bin会忽略，如果当前目录下有个lib目录，lib下有个bin目录，这个bin就相当于是子目录的文件和目录就不会被忽略。
  - 匹配模式可以以（`/`）结尾指定目录。明确表示是个目录。忽略掉这个目录。如果不加（/）表示文件和目录一起忽略。这个可以明确如果当前目录下有dbg的文件和dbg的目录时更加容易。
    - 忽略dbg文件和dbg目录    dbg
    - 只忽略dbg目录，不忽略dbg文件   dbg/
    - 只忽略dbg文件，不忽略dbg目录   dbg  !dbg/
    - 只忽略当前目录下的dbg文件和目录，子目录的dbg不在忽略范围内  /dbg
    - 忽略当前目录下的所有文件和目录 /*， 剩下的在用！取消忽略。如果是目录就在后面写上/
  - 要忽略指定模式以外的文件或目录，可以在模式前加上叹号（`!`）取反。
  - 以方括号“[]”包含单个字符的匹配列表。忽略.o和.a文件 *.[oa]
  - 以问号“?”通配单个字符
  - 使用两个星号（`**`）表示匹配任意中间目录，比如 `a/**/z` 可以匹配 `a/z` 、 `a/b/z` 或 `a/b/c/z` 等。

  ```
  # 忽略所有的 .a 文件
  *.a
  
  # 但跟踪所有的 lib.a，即便你在前面忽略了 .a 文件
  !lib.a
  
  # 只忽略当前目录下的 TODO 文件，而不忽略 subdir/TODO，subdir和TODO在同一级目录。subdir里面有一个子目录TODO就不会被删除。因为只删除当前一层目录下的。但是subdir和TODO是两个不同的目录。因为/TODO被忽略了，当然TODO里面所有的东西都被忽略了。
  /TODO
  
  # 忽略任何目录下名为 build 的文件夹。a文件夹下的build目录和b问价夹下的目录都会被删除。从当前目录开始可以递归到子目录。所有名为build的文件夹都会被删除
  build/
  
  # 忽略 doc/notes.txt，但不忽略 doc/server/arch.txt。这样是在当前目录层次里面忽略下一个目录层次的东西，就不用在下一级目录里面重新创建一个.gitignore文件了。这样维护起来比较简单。这样和多创建几个.gitignore文件都可以看自己怎么选了。如果不希望递归就在doc前面加/，这样就不会在同一级目录下寻找其他目录子目录里面的doc文件了。/符号并不是不让往后面写，只是说不允许递归，到其他目录里面。可以这样/TODO/bin/，这样表示忽略TODO下面的bin目录，而不是忽略subdir/TODO/下面的bin目录。
  doc/*.txt
  
  # 忽略 doc/ 目录及其所有子目录下的 .pdf 文件
  doc/**/*.pdf
  ```

- GitHub 有一个十分详细的针对数十种项目及语言的 `.gitignore` 文件列表， 你可以在 https://github.com/github/gitignore 找到它。

- 在最简单的情况下，一个仓库可能只根目录下有一个 `.gitignore` 文件，它递归地应用到整个仓库中。 然而，子目录下也可以有额外的 `.gitignore` 文件。子目录中的 `.gitignore` 文件中的规则只作用于它所在的目录中。 （Linux 内核的源码库拥有 206 个 `.gitignore` 文件。）

- `git rm log/\*.log`注意到星号 `*` 之前的反斜杠 `\`， 因为 Git 有它自己的文件模式扩展匹配方式，所以我们不用 shell 来帮忙展开。 此命令删除 `log/` 目录下扩展名为 `.log` 的所有文件。这个和.gitignore是有区别的，那个不需要\。

##### 如何验证是否生效（强烈推荐）

```
git check-ignore -v 文件名
```

- 会告诉你：
  - 哪一行规则匹配了

##### 一个你必须理解的点

- `.gitignore` 只影响：

  ```
  未被跟踪的文件
  ```

- 不会影响：

  - 已 commit 的文件
  - 历史记录

##### gitignore忽略目录，目录下面的文件也会一起忽略吗

- 忽略一个目录时，目录下面的所有文件和子目录都会一起被忽略

- 常见用法

  ```
  build/
  ```

  - 含义：

    ```
    build/
    ├── a.o
    ├── b.log
    └── sub/
        └── c.txt
    ```

    - 全部都会被忽略

- Git 的规则是：

  ```
  忽略目录 = 整个目录树都不再递归处理
  ```

- 一旦目录被忽略：

  - Git **不会再往里面看**
  - 所有子文件自动忽略

- 一个很多人踩的坑

  - 你想“忽略目录，但保留某个文件”

    ```
    build/
    !build/keep.txt
    ```

  - 这样是没用的！因为：

    ```
    build/ 已经被忽略 → Git 根本不会进入这个目录
    ```

    - 所以 `!build/keep.txt` 不会生效

  - 正确写法（必须这样写）

    ```
    build/*
    !build/keep.txt
    ```

    - 含义：
      - 忽略 build 下面所有内容
      - 但保留 keep.txt

##### 多级 `.gitignore` 文件

- Git 支持：

  ```
  root/.gitignore
  src/.gitignore
  src/module/.gitignore
  ```

  - 离文件越近的 `.gitignore` 优先级越高

###### 示例

- 根目录 `.gitignore`

  ```
  *.log
  ```

- 子目录 `src/.gitignore`

  ```
  !important.log
  ```

- 结果：

  ```
  src/important.log   ✅ 不忽略
  其他目录的 .log     ❌ 忽略
  ```

### 在当前变更上工作

#### add

##### 作用

- 把文件加入“暂存区”（staging area），告诉 Git：这些改动我要提交

##### 直观理解

- Git 有三个区域：

  ```
  工作区（你改代码的地方）
      ↓ git add
  暂存区（准备提交）
      ↓ git commit
  仓库（历史记录）
  ```

- `git add` 就是把改动从 **工作区 → 暂存区**

##### 常用命令

###### 添加单个文件

```
git add file.txt
```

###### 添加多个文件

```
git add file1.c file2.c
```

###### 添加当前目录所有改动

```
git add .
```

- 包括：
  - 新文件
  - 修改的文件

###### 添加所有

```
git add -A
```

- 包括：
  - 新增
  - 修改
  - 删除

###### 只添加已修改文件

```
git add -u
```

- 不包含新文件

##### 为什么需要 git add

- 很多人会问：为什么不能直接 `commit`？

  - 原因是：Git 允许你**选择性提交**

- 举个例子

  - 你改了两个文件：

    - A（写完了 ✅）
    - B（还没写完 ❌）

  - 你可以：

    ```
    git add A
    git commit -m "完成A"
    ```

    - B 不会被提交

###### 查看状态

```
git status

Changes not staged（未 add）
Changes to be committed（已 add）
```

##### 高级用法

###### 交互式添加（强烈推荐）

```
git add -p
```

-  可以做到：
  - 按“代码块”提交
  - 精细控制提交内容

- 普通 add

  ```
  git add file.c
  ```

  - 整个文件全部加入暂存区

  ```
  git add -p file.c
  ```

  - Git 会一段一段问你：Git 会一段一段问你：

- 使用场景

  - 你改了很多东西，比如一个文件：
    - 改了一部分 bug（应该提交 ✅）
    - 写了一半新功能（不想提交 ❌）
  - 用 `git add -p` 可以只提交一部分

- 操作过程

  ```
  git add -p
  
  git会显示
  diff --git a/test.c b/test.c
  @@ -1,5 +1,5 @@
  - int a = 1;
  + int a = 2;
  
  然后提示
  Stage this hunk [y,n,q,a,d,e,?]?
  ```

  - 选项含义

    ```
    选项	含义
    y	加入这个代码块
    n	不加入
    q	退出
    a	后面所有都加入
    d	后面所有都不加入
    s	拆分更小块
    e	手动编辑
    ?	查看帮助
    
    实际开发你只需要记这几个：
    y → 要这块
    n → 不要
    s → 太大了，拆一下
    q → 退出
    ```

- s（split）特别重要

  - 有时候 Git 分块太大：

    ```
    s
    ```

    - 会拆成更小的块

###### 添加删除操作

- 当你删除文件：

  ```
  rm file.txt
  ```

- 需要：

  ```
  git add -A
  ```

- 否则不会记录删除

- 或者使用`git rm`

#### mv

- 移动或重命名文件，并让 Git 记录这个操作

##### 基本用法

###### 重命名文件

```
git mv old.txt new.txt
```

###### 移动文件

```
git mv file.txt dir/
```

- 把文件移动到目录里

###### 同时移动 + 重命名

```
git mv old.txt dir/new.txt
```

##### 到底做了什么

```
git mv a.txt b.txt

等价于
mv a.txt b.txt
git add b.txt
git rm a.txt
```

##### 和普通 mv 的区别

```
mv a.txt b.txt
```

- Git 会认为：

  ```
  删除了 a.txt
  新增了 b.txt
  ```

- `git mv` Git 更容易识别为：“重命名操作”

##### 查看效果

```
git status
```

- 会看到：

  ```
  renamed: a.txt -> b.txt
  ```

#### restore

- `git restore` 是 Git 较新的命令（Git 2.23+），专门用来**恢复文件内容**，把以前一些混乱的操作（比如 checkout）拆分得更清晰。

##### 作用

- **恢复文件状态**，可以恢复：
  - 工作区（你改过但没 add 的）
  - 暂存区（已经 add 的）

- 核心理解，`git restore` = **把文件“变回去”**

##### 常见用法

###### 丢弃工作区修改（最常用）

```
git restore file.txt
```

- 撤销你对 `file.txt` 的修改
- 回到上一次 commit 的状态
- 修改会丢失！

###### 恢复所有文件

```
git restore .
```

- 当前目录所有改动全部还原

##### 恢复暂存区

###### 取消 add（很常用）

```
git restore --staged file.txt
```

-  等价于：

  ```
  git reset HEAD file.txt
  ```

- 效果：

  - 从暂存区移除
  - 文件还在工作区

##### 同时恢复暂存区 + 工作区

```
git restore --staged --worktree file.txt
```

- 撤销 add
- 撤销修改
- 完全回到 commit 状态

##### 从指定版本恢复

###### 从某个 commit 恢复

```
git restore --source=<commit> file.txt

例子：
git restore --source=HEAD~1 file.txt
```

- 把文件恢复到上一个版本

##### 命令对比

| 命令         | 作用                  |
| ------------ | --------------------- |
| git restore  | 恢复文件              |
| git reset    | 回退提交 / 操作暂存区 |
| git checkout | 老命令（功能太多）    |

- 为什么有 restore？以前用下面命令

  ```
  git checkout file.txt
  ```

  - 太混乱：
    - 又能切分支
    - 又能恢复文件
  - 所以 Git 拆成：
    - `git switch`（切分支）
    - `git restore`（恢复文件）

#### rm

- 删除文件，并让 Git 记录这个删除操作

##### 基本用法

###### 删除文件（最常用）

```
git rm file.txt
```

-  效果：
  - 删除工作区的文件
  - 同时从暂存区移除
  - 标记为“已删除”，等待 commit

###### 删除多个文件

```
git rm a.txt b.txt
```

###### 删除目录

```
git rm -r dir/
```

- `-r` = 递归删除

###### 只从 Git 删除，不删本地文件

```
git rm --cached file.txt
```

- Git 不再跟踪这个文件
- 本地文件还在

###### 强制删除（修改过的文件）

```
git rm -f file.txt
```

-  如果文件有修改但没提交，会报错，用 `-f` 强制删除

##### 做了什么

```
git rm file.txt
等价于
rm file.txt
git add file.txt   # 记录删除
```

- 普通删除，查看状态 `git status`，会看到

  ```
  deleted: file.txt（未暂存）
  ```

  - 还需要：

    ```
    git add file.txt
    ```

- `git rm`删除之后，`git status`查看状态

  ```
  deleted: file.txt
  ```

##### 常见问题

###### git rm 删除后还能恢复吗

- 如果还没 commit：

  ```
  git restore file.txt
  ```

- 如果已经 commit：

  ```
  git checkout HEAD~1 file.txt
  ```

###### 为什么 git rm 报错？

- 文件有修改但没 add，使用-f强行删除

#### stash

- `git stash` 是 Git 里一个非常实用的“临时存储工作区改动”的命令，可以把你当前未提交的修改先**藏起来**，让工作区变干净，方便你切换分支或做其他操作。

##### 常用用法

###### 临时保存当前修改

```
git stash
```

- 效果：

  - 工作区改动 ✔️ 保存

  - 暂存区改动 ✔️ 保存

  - 当前目录变干净 ✔️

###### 查看 stash 列表

```
git stash list
```

- 输出类似：

  ```
  stash@{0}: WIP on main: 1234567 commit msg
  stash@{1}: WIP on feature: abcdefg commit msg
  ```

###### 恢复 stash（不删除）

```
git stash apply
```

- 默认恢复最新一条 `stash@{0}`

- 指定某一条：

  ```
  git stash apply stash@{1}
  ```

###### 恢复并删除（最常用）

```
git stash pop
```

- = apply + drop

- 可以pop一个具体的

  ```
  git stash pop stash@{1}
  ```

###### 删除 stash

```
git stash drop stash@{0}
```

- 清空全部：

  ```
  git stash clear
  ```

###### 只 stash 未暂存的改动

```
git stash -k
# 或
git stash --keep-index
```

- 暂存区不动

###### 包含未跟踪文件

```
git stash -u
# 或
git stash --include-untracked
```

- stash 默认不包含 untracked 文件

###### 连 ignored 文件一起

```
git stash -a
```

###### 添加说明（推荐）

```
git stash push -m "临时保存：修一半的功能"
```

###### 查看 stash 内容

```
git stash show
```

- 详细：

  ```
  git stash show -p
  ```

##### 常见使用场景

###### 写一半要切分支

```
# 正在开发 feature
git stash

# 切到其他分支修bug
git switch main

# 修完回来
git switch feature
git stash pop
```

###### pull / rebase 前保存改动

```
git stash
git pull --rebase
git stash pop
```

### 检查历史和状态

#### log

##### 基本用法

```
git log

输出
commit a1b2c3d4
Author: Kevin Li <xxx@gmail.com>
Date:   Sat Mar 21 10:00:00 2026

    fix: 修复登录bug
```

- 输出内容包括：
  - commit 哈希值
  - 作者
  - 日期
  - 提交信息

##### 常用参数

###### 一行显示（最常用）

```
git log --oneline

输出
a1b2c3d fix login bug
b2c3d4e add user module
```

- 只显示commit和提交内容

###### 显示分支图

```
git log --oneline --graph --decorate

输出
* a1b2c3d (HEAD -> main) fix login bug
* b2c3d4e add feature
|\
| * c3d4e5f (dev) dev commit
```

###### 查看最近 N 条

```
git log -n 5
或者
git log --oneline -5
```

###### 查看某个文件的历史

```
git log filename.c
```

- 只看这个文件的变更记录

###### 查看详细改动

```
git log -p

输出
commit ca3c1f222102a096e09158c85f5b16df0b08b25e
Author: kevin <lylyxf@163.com>
Date:   Wed Dec 24 19:27:29 2025 +0800

    c++

diff --git a/c++.md b/c++.md
index 1f58a7f..16dc475 100644
--- a/c++.md
+++ b/c++.md
@@ -7500,6 +7500,53 @@ stopwatch stopwatch::operator++(int n){
     Point<float, float> *p = new Point(10.6, 109);
```

- 会显示每次提交改了什么


###### 查看某一行是谁改的（配合 log）

```
git blame filename.c
```

###### 按作者筛选

```
git log --author="Kevin"
```

###### 按时间筛选

```
git log --since="2026-03-01"   since（从什么时候开始） 显示 2026-03-01 之后（包含当天） 的提交
git log --until="2026-03-21"   until（到什么时候为止） 显示 2026-03-21 之前（包含当天） 的提交

两个一起用
git log --since="2026-03-01" --until="2026-03-21"  只看 3月1日 ~ 3月21日之间的提交
```

- 时间格式

```
 标准日期
  git log --since="2026-03-01"
  git log --since="2026-03-01 10:00"

  相对时间
  git log --since="2 days ago"
  git log --since="1 week ago"
  git log --since="3 months ago"

  查看今天的提交
  git log --since="today"

  查看昨天的提交
  git log --since="yesterday" --until="today"
```

###### 搜索提交信息

```
git log --grep="fix"
```

- 从提交的说明里面查找

###### 查看某一行代码历史

```
git log -L 10,20:filename.c
```

###### 只看修改过的文件名

```
git log --name-only

输出
commit 3a7419bde82bf9fa121c4c66a4e385e013ae9e91
Author: kevin <lylyxf@163.com>
Date:   Wed Mar 26 19:28:56 2025 +0800

c 3-26

c++.md
c.m
```

- 会把修改的文件名字列出来

###### 显示统计信息

```
git log --stat

输出
commit 4378b876d985f88b9ffbd5e21b5358f9b4b1a1a9
Author: kevin <lylyxf@163.com>
Date:   Tue Dec 23 18:51:43 2025 +0800

c++

 c++.md | 1088 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 974 insertions(+), 114 deletions(-)
```

###### 查看某次提交详情

```
git show <commit-id>
```

###### -S and -G

- 查看grep一节

#### reflog

- reflog 是干什么的？
  - 记录 HEAD（以及分支）“指针移动历史”
  - 也就是：
    - commit
    - checkout / switch
    - merge
    - rebase
    - reset（重点！）
  - 这些操作，都会被记录

##### 常用命令

```
git reflog
```

- 输出类似：

  ```
  a1b2c3d (HEAD -> main) HEAD@{0}: commit: fix bug
  e4f5g6h HEAD@{1}: reset: moving to HEAD~1
  i7j8k9l HEAD@{2}: checkout: moving from dev to main
  ```

- 关键字段解释：

  | 项       | 含义     |
  | -------- | -------- |
  | HEAD@{0} | 当前状态 |
  | HEAD@{1} | 上一步   |
  | HEAD@{2} | 再往前   |

- 就像“时间轴”

##### 重要用途

###### 找回被 reset 掉的 commit

- 你之前问过 reset 

  ```
  git reset --hard HEAD~1
  ```

  - commit “消失”了

- 用 reflog 找回来：

  ```
  git reflog
  ```

- 找到：

  ```
  abc1234 HEAD@{1}: commit: add feature
  ```

- 恢复：

  ```
  git reset --hard abc1234
  ```

###### 找回 rebase 前的状态

- rebase 很容易改历史

  ```
  git reflog
  ```

- 找到 rebase 前的 commit：

  ```
  git reset --hard HEAD@{3}
  ```

###### 找回误删分支

- 如果你删了分支：

  ```
  git branch -D feature
  ```

- git reflog，找到旧 commit：

  ```
  git checkout -b feature abc1234
  ```

  

#### show

- `git show` = 查看某一次提交的“完整详情”（包括具体代码改动），查看当前工作区的改动用`git status`

##### 基本用法

```
git show
```

- 默认显示：当前 HEAD（最新一次提交）
- 输出包括：
  - commit 信息
  - 作者
  - 日期
  - 提交说明
  - ✅ 具体代码改动（diff）

##### 指定某个提交

```
git show <commit-id>

例如
git show a1b2c3d
```

- 会显示这次提交改了什么代码

##### 输出内容结构（重点理解）

```
commit a1b2c3d
Author: Kevin Li
Date:   Sat Mar 21 10:00:00 2026

fix: 修复登录问题

diff --git a/login.c b/login.c
index 123..456 100644
--- a/login.c
+++ b/login.c
@@ -10,7 +10,8 @@
```

##### 查看某个文件在某次提交中的内容

```
git show <commit-id>:file.c

例如
git show a1b2c3d:login.c
```

- 查看这个提交时的 `login.c` 内容（不是 diff，是完整文件）

###### 查看 HEAD 上的文件版本

```
git show HEAD:file.c
```

##### 只看文件列表（不看 diff）

```
git show --name-only
```

##### 只看统计信息

```
git show --stat

类似这个命令
git log --stat
```

###### 不看代码，只看提交信息

```
git show --no-patch
```

##### 查看标签（tag）

```
git show v1.0
```

##### 查看分支最后一次提交

```
git show main
git show dev
```

##### 查看 stash 内容

```
git show stash
```

#### status

- `git status` = 查看当前仓库的“状态”

##### 本质

- `git status` 本质是在对比三块区域

  ```
  工作区（Working Directory）
          ↓
  暂存区（Staging Area / Index）
          ↓
  本地仓库（Repository / HEAD）
  ```

- 它会告诉你：

  - 哪些文件 **改了但没 add**
  - 哪些文件 **已经 add 但没 commit**
  - 哪些文件 **还没被 git 管理（untracked）**

##### 输出示例

```
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  modified:   login.c

Changes to be committed:
  new file:   user.c

Untracked files:
  test.c
```

- `Changes not staged for commit` ，改了，但还没 `git add`
  - ✔ 在工作区
  -  ❌ 不在暂存区
- `Changes to be committed`，已经 `git add`，等着 commit
  - ✔ 在暂存区
  -  ✔ 即将进入仓库
- `Untracked files`， Git 还没管的文件
  - ❌ 不在 Git 管理中

##### 常用参数

###### 简洁模式

```
git status -s

输出
M login.c
A  user.c
?? test.c

标记	含义
M	modified（修改）
A	added（新增）
D	deleted（删除）
??	未跟踪
```

###### 显示分支信息

```
git status -sb

输出
## main...origin/main
 M login.c
```

- 输出更紧凑

#### grep

- `git grep` = 在 Git 仓库里搜索代码（比普通 grep 更智能）

##### 基本用法

```
git grep "关键字"

例如
git grep "malloc"

输出
src/main.c:    ptr = malloc(100);
lib/util.c:    data = malloc(size);
```

##### 区别和普通grep

| 对比              | grep     | git grep         |
| ----------------- | -------- | ---------------- |
| 搜索范围          | 整个目录 | ✅ Git 管理的文件 |
| 忽略 `.gitignore` | ❌ 不会   | ✅ 会自动忽略     |
| 搜索历史版本      | ❌ 不支持 | ✅ 支持           |
| 性能              | 一般     | 🚀 更快           |

##### 常用用法

###### 显示行号

```
git grep -n "malloc"

输出
src/main.c:10: ptr = malloc(100);
```

###### 显示文件名（不显示内容）

```
git grep -l "malloc"
```

###### 忽略大小写

```
git grep -i "malloc"
```

###### 使用正则表达式

```
git grep -E "malloc|calloc"
```

###### 只搜索某些目录/文件

```
git grep "malloc" -- src/

或者
git grep "malloc" -- "*.c"
```

###### 搜索多个关键字（与/或）

```
git grep "malloc" --and "free"   -- 与

git grep -E "malloc|free"    -- 或
```

###### 搜索某个提交里的内容

```
git grep "malloc" <commit-id>
```

###### 搜索某个分支

```
git grep "malloc" dev
```

###### 搜索所有分支

```
git grep "malloc" $(git rev-list --all)
```

- 用于查“这个代码在哪个版本出现过”

###### 字符串什么时候被引入或删除

- `git log -S` 是**排查 bug 的神器级命令**。

- 基本用法

  ```
  git log -S "关键字"
  
  例如
  git log -S "malloc"
  ```

  - Git 会找出：所有让 `malloc` 这个字符串“数量发生变化”的提交

- 核心原理

  - `-S` 做的不是简单搜索，而是：比较每次提交前后，这个字符串的“出现次数”

    | 情况                             | 是否会被匹配 |
    | -------------------------------- | ------------ |
    | 新增了一行 `malloc`              | ✅            |
    | 删除了一行 `malloc`              | ✅            |
    | 修改了代码但没改变 `malloc` 数量 | ❌            |

- 找某个函数是在哪次提交引入的

  ```
  git log -S "Init_System"
  ```

  - 找“第一次出现这个函数”的提交

- 常用参数

  ```
  显示具体改动  git log -S "malloc" -p
  简洁模式     git log -S "malloc" --oneline
  限制文件范围  git log -S "malloc" -- src/main.c
  忽略大小写    git log -S "malloc" -i
  ```

- 和-G的区别

  - `-S`（按数量变化）看“有没有增加/减少”

  - `-G`（按正则匹配）只要 diff 里出现就算

    ```
    malloc(100);
    改成
    malloc(200);
    
    | `-S "malloc"` | ❌（数量没变） |
    | `-G "malloc"` | ✅       |
    
    ```

#### diff

- `git diff` = 查看“代码具体改了什么”

##### 本质

```
工作区（Working Directory）
暂存区（Index / Staging）
本地仓库（HEAD）
```

- `git diff` 就是在比较这三者之间的差异

##### 基本用法

```
git diff
```

- 看的是：工作区 vs 暂存区（index），你改了但还没 `git add` 的内容

##### 输出

```
diff --git a/file.c b/file.c
index 1234567..89abcde 100644
--- a/file.c
+++ b/file.c
@@ -10,7 +10,8 @@
 line1
-line2
+line2_new
+line2_extra
 line3
```

- 可以分成 4 大块：
  - ① 文件信息
  - ② 索引信息
  - ③ 文件头（旧/新）
  - ④ 具体改动（hunk）

- ① 文件信息

  ```
  diff --git a/file.c b/file.c
  ```

  - 表示：
    - 比较的是 `file.c`
    - `a/` = 旧版本
    - `b/` = 新版本

- ②索引信息（可忽略但了解一下）

  | 部分      | 含义           |
  | --------- | -------------- |
  | `1234567` | 旧版本 blob id |
  | `89abcde` | 新版本 blob id |
  | `100644`  | 文件权限       |

  -  一般开发中可以忽略

- ③ 文件头

  ```
  --- a/file.c
  +++ b/file.c
  
  ---	旧文件
  +++	新文件
  ```

- ④ 变更块

  ```
  @@ -10,7 +10,8 @@
  
  -10,7	旧文件：第10行开始，7行
  +10,8	新文件：第10行开始，8行
  ```

- ⑤ 具体内容（最关键）

  ```
   line1        ← 上下文（没变）
  -line2        ← 删除
  +line2_new    ← 新增
  +line2_extra  ← 新增
   line3        ← 上下文
  ```

  | 符号       | 含义   |
  | ---------- | ------ |
  | ``（空格） | 未改变 |
  | `-`        | 删除   |
  | `+`        | 新增   |

  - 空格表示上下文内容，没有改动

- 新增文件

  ```
  --- /dev/null
  +++ b/new.c
  ```

- 删除文件

  ```
  --- a/old.c
  +++ /dev/null
  ```

- 重命名文件

  ```
  diff --git a/a.c b/b.c
  ```

##### git diff图形化显示

- 直接用vim比较

  ```
  git difftool -t vimdiff
  ```

  - 效果：
    - 左边：旧版本
    - 右边：新版本
    - 中间高亮差异

- 配置默认 difftool

  ```
  git config --global diff.tool vimdiff
  git config --global difftool.prompt false
  ```

  - 以后直接：

    ```
    git difftool
    ```

- 如果有多个文件：**逐个文件处理，每次会问你**

  ```
  Viewing (1/5): file1.c
  Launch 'vimdiff' [Y/n]?
  ```

  - 你按：

    - `y` → 打开这个文件 diff
    - `n` → 跳过

  - 所以默认是：一个一个确认 + 一个一个打开

  - 如果你不想每次确认

    ```
    git difftool -y
    ```

    - 行为变成：
      - 不再询问
      - 自动逐个打开
    - 仍然是一个一个打开，不是全部同时弹出

##### git diff比较的两个文件都是从哪里来的，旧版本的是怎么存储的

- `git diff` 比较的两个“文件”来源是：

  | 来源   | 来自哪里                            |
  | ------ | ----------------------------------- |
  | 新版本 | 工作区 / 暂存区 / 某个 commit       |
  | 旧版本 | Git 对象库（.git 目录里的历史快照） |

  - 旧版本不是磁盘上的文件，而是从 Git 内部“还原出来”的

- 旧版本到底存在哪里

  - 在：

    ```
    .git/objects/
    ```

  - 这里面存的是 Git 的核心对象：

    - blob（文件内容）
    - tree（目录结构）
    - commit（提交信息）

- Git 是怎么存文件的

  - 每个文件内容 → 一个 blob

  - 比如一个文件：

    ```
    int a = 1;
    ```

    - Git 会存成一个 blob（类似哈希对象）

  - 修改一行 = 新 blob

    ```
    int a = 2;
    ```

    - Git 不存“差异”，而是：**存一个新的完整内容 blob**

  - 重要结论： Git 存的是：

    ```
    完整文件快照（snapshot）
    ```

    - 而不是传统理解的“diff patch”

  - 那为什么 Git 又很省空间

    - 内容去重（关键）
      - 如果两个文件内容一样： 只存一份 blob（通过 hash）
    - pack 压缩（高级）在 `.git/objects/pack/`：
      - Git 会把多个对象做：
        - delta 压缩（类似差异存储）
        - zlib 压缩
        - 但这是**存储优化**，不是逻辑模型

- git diff 时发生了什么

  - 假设：

    ```
    git diff HEAD
    ```

  - Git 实际流程：

    ① 从哪里取两个版本

    | 版本   | 来源                 |
    | ------ | -------------------- |
    | HEAD   | commit → tree → blob |
    | 工作区 | 磁盘文件             |

    ② Git 做了什么

    ```
    1. 从 .git/objects 读取旧版本 blob
    2. 从磁盘读取当前文件
    3. 在内存中做 diff
    4. 输出结果
    ```

    - 不会生成临时文件

- 举个完整例子

  - commit A：

    ```
    int a = 1;
    ```

  - commit B：

    ```
    int a = 2;
    ```

  - 执行：

    ```
    git diff A B
    ```

  - Git 会：

    - 从对象库取出 A 的 blob

    - 取出 B 的 blob

    - 在内存比较

    - 输出：

      ```
      - int a = 1;
      + int a = 2;
      ```

##### 常用命令

###### 看未 add 的改动

```
git diff

工作区 vs 暂存区
```

###### 看已 add 的改动

```
git diff --cached
# 或
git diff --staged

暂存区 vs HEAD
```

###### 看所有改动

```
git diff HEAD

工作区 + 暂存区 vs HEAD
```

###### 看某个文件

```
git diff file.c
```

###### 只看文件名

```
git diff --name-only
```

###### 看改动统计

```
git diff --stat
```

###### 忽略空格

```
git diff -w
```

###### 比较两个提交

```
git diff commit1 commit2
```

###### 比较两个分支

```
git diff main dev
```

- 这些都是可以组合使用的，例如-w 和--cached，不是只说的这一个命令，上面很多都是可以的

#### bisect

- `git bisect` = 用“二分查找”帮你定位“是哪一次提交引入了 bug”

##### 解决问题

- 场景
  - 现在代码是 ❌ 有 bug 的
  - 以前某个版本是 ✅ 正常的
  - 中间有几百次提交…
- 你想知道，到底是哪一次提交把代码搞坏了？

##### 核心思想

- `git bisect` 做的事：

  ```
  不是一个一个试
  而是：
  每次砍一半（类似二分查找）
  ```

- 比如 100 次提交：

  - 普通方法：最多试 100 次
  - bisect：只需要 ~7 次

基本使用流程

- 步骤 1：开始

  ```
  git bisect start
  ```

- 步骤 2：标记当前版本是坏的

  ```
  git bisect bad
  ```

  - 默认就是当前 HEAD

- 步骤 3：标记一个“好的版本”

  ```
  git bisect good <commit-id>
  ```

  - 这个 commit 必须是：确认没有 bug 的版本

- 步骤 4：Git 自动帮你切换到中间版本

  - 然后你需要：

  ```
  # 测试代码（运行程序）
  ```

  ------

- 步骤 5：告诉 Git 结果

  - 如果这个版本：有 bug：

  ```
  git bisect bad
  ```

  - 没 bug：

  ```
  git bisect good
  ```

  - Git 会继续：
    - 自动跳到下一个“中间点”
    - 不断缩小范围

  ------

- 步骤 6：最终结果

  - Git 会告诉你：

  ```
  <commit-id> is the first bad commit
  ```

  - 找到了罪魁祸首

  ------

- 步骤 7：结束

  ```
  git bisect reset
  ```

  - 回到原来的分支

##### 示例

```
git bisect start
git bisect bad              # 当前版本有 bug
git bisect good a1b2c3d     # 某个老版本是好的

# Git 自动切换版本

# 你测试程序
git bisect bad              # 或 good

# 重复几次...

# 最终输出：
# xxx is the first bad commit

git bisect reset
```

##### 疑问

- 我从现在的代码不就能确定是哪句话引起来的bug吗，为什么还要测试，直接用blame看是谁写的不就行了

- 你说的是：

  >  现在代码有 bug → 看这一行 → `git blame` → 找到是谁写的

  - 听起来合理，但有几个致命问题：

    - bug 不一定在“出问题的那一行”

      ```
      if (timeout > 10)   // 这里崩了
      你以为问题在这行
      但真实原因可能是：
      timeout = get_config();  // 上游改了默认值
      bug 在别的提交引入的
      ```

    - blame 只看“最后一次修改”

      ```
      git blame file.c
      ```

      - 这行代码最后是谁改的
      - bug 可能是：
        - 3 次提交前引入的
        - 后面的人只是改了格式 / 重排代码

    - 逻辑 bug ≠ 单行代码问题

      - 很多 bug 是：
        - 多文件交互
        - 状态变化
        - 时序问题
        - 配置变化
        - 根本不是某一行能看出来的

    - 有些 bug 是“行为变化”，不是代码明显错误

      ```
      retry = 3 → retry = 5
      ```

      - 看起来没问题，但导致系统超时，blame 看不出“什么时候开始出问题”

#### blame

- `git blame` = 查看“每一行代码是谁在什么时候写的”

##### 基本用法

###### 找“这行代码是谁写的”

```
git blame file.c

输出
a1b2c3d (Kevin Li 2026-03-21 10:00:00) int a = 1;
b2c3d4e (Tom      2026-03-20 09:00:00) int b = 2;
```

| 部分      | 含义         |
| --------- | ------------ |
| commit-id | 哪次提交改的 |
| 作者      | 谁写的       |
| 时间      | 什么时候写的 |
| 代码      | 当前这一行   |

###### 只看某几行

```
git blame -L 10,20 file.c
```

###### 忽略代码移动

```
git blame -w file.c
```

- 忽略空格变化

### 扩展、标记和调校您的历史记录

#### branch

- `git branch` = 查看 / 创建 / 删除 / 管理分支

##### 基本用法

```
git branch

输出
* main
  dev
  feature/login
```

- `*`  当前所在分支（HEAD）
- 其他存在的分支

##### 常用操作

###### 创建分支

```
git branch dev
```

- 创建一个 `dev` 分支，但不会切换过去

###### 切换分支

```
git switch dev

或（老命令）：
git checkout dev
```

###### 创建 + 切换

```
git switch -c dev

或者
git checkout -b dev
```

###### 删除分支

```
git branch -d dev    --安全删除（已合并）
git branch -D dev    --强制删除 
```

###### 查看所有分支

```
git branch -a
```

- 包括远程分支

###### 查看远程分支

```
git branch -r
```

###### 查看分支最后一次提交

```
git branch -v
```

###### 查看已合并分支

```
git branch --merged
```

###### 查看未合并分支

```
git branch --no-merged
```

###### 重命名分支

```
git branch -m old_name new_name
```

##### 分支的本质

- 分支其实就是：一个指向 commit 的指针

  ```
  A --- B --- C   (main)
           \
            D --- E   (dev)
  ```

  - `main` 和 `dev` 只是：指向不同 commit 的“标签”

- 删除分支不会删代码

  - 只是删除指针，commit 还在（只要没被 GC）

#### commit

- `git commit` = 把“暂存区的内容”保存成一个版本（生成一次提交）

##### 基本用法

```
git commit -m "提交说明"
```

- 作用：
  - 把已经 `git add` 的内容提交
  - 生成一个 commit（版本记录）

- 每一次 commit 都会生成：

  ```
  commit-id（哈希）
  作者
  时间
  提交说明
  指向父提交
  ```

  - 本质是一个“版本节点”

##### 常用参数

###### -m

```
git commit -m "fix bug"
```

- 直接写提交信息

###### -a（跳过 add）

```
git commit -a -m "update"
```

- 自动：
  - add 已跟踪文件
  - ❗ 不包含新文件

###### --amend（修改上一次提交）

```
git commit --amend

例如
git commit --amend -m "fix: 登录问题"
```

-  用来：
  - 改提交信息
  - 或补充修改
- amend 会改历史，如果已经 push：不要随便 amend

###### 只提交某些文件

```
git commit file.c -m "update"
```

- 会自动 add 这些文件再提交

###### 分块提交（配合 add -p）

```
git add -p
git commit -m "small change"
```

- 精确控制提交内容

#### merge

- `git merge` = 把“另一个分支的提交”合并到当前分支

##### 基本用法

```
git merge dev
```

- 把 `dev` 分支的内容合并到当前分支

```
main:   A --- B
               \
dev:            C --- D
```

- 在 `main` 上执行：

  ```
  git merge dev
  ```

  - 结果：

    ```
    main:   A --- B -------- M
                   \       /
    dev:            C --- D
    ```

    - 产生一个新的 merge commit（M）

##### 两种合并方式

###### Fast-forward（快进合并）

```
main: A --- B
              \
dev:           C --- D
```

- 执行：

  ```
  git merge dev
  ```

- 结果：

  ```
  main: A --- B --- C --- D
  ```

  - 没有新 commit，只是指针前移

###### 三方合并（真正 merge）

```
main: A --- B
         \
dev:      C --- D
```

- 会生成

  ```
  main: A --- B ---- M
           \       /
  dev:      C --- D
  ```

  - `M` 是 merge commit

###### 区别

- 什么时候会发生 Fast-forward
  - 条件只有一个（非常关键）：当前分支没有新的提交，只是“落后于目标分支”，例如上面快速合并的图
- 什么时候不会 Fast-forward？
  - 只要当前分支有“自己的新提交”，例如上面三方合并的图
  - 必须产生 merge commit

##### 常用参数

###### --no-ff（强制产生 merge commit）

```
git merge --no-ff dev
```

- 即使能快进，也会生成 merge commit
- 常用于团队开发（保留历史结构）

###### -abort（中止合并）

```
git merge --abort
```

- 发生冲突时回退

###### --squash（压缩提交）

```
git merge --squash dev
```

- 不保留 dev 的历史，合成一个提交

##### 什么是冲突？

- 两个分支改了同一段代码：

  ```
  <<<<<<< HEAD
  int a = 1;
  =======
  int a = 2;
  >>>>>>> dev
  ```

- 解决流程

  ```
  # 1. 修改代码（手动解决冲突）
  # 2. 标记为已解决
  git add file.c
  
  # 3. 完成合并
  git commit
  ```

- merge 不会删除分支


##### git merge产生的merge commit是默认的？

- 是的，`git merge` 在需要时会自动创建一个 merge commit（默认行为），
- 但注意：
  -  **不是“每次都会产生”**

###### 什么时候会产生 merge commit

- 分叉了（最常见）

  ```
  A---B---C   (main)
       \
        D---E (feature)
  ```

- 执行：

  ```
  git merge feature
  ```

- 结果：

  ```
  A---B---C-------M
       \         /
        D---E---/
  ```

  -  这里的 `M`：就是 **自动生成的 merge commit**

###### 什么时候不会产生 merge commit

- Fast-forward（快进）

  ```
  main:    A---B---C
  feature: A---B---C---D---E
  ```

- 执行：

  ```
  git merge feature
  ```

- 结果：

  ```
  main: A---B---C---D---E
  ```

  - **没有 merge commit ❗**

###### 为什么默认会产生 merge commit

- Git 的设计是：**保留分支历史结构**

  ```
  你从哪分出来
  什么时候合并回来
  ```

- 所以： 默认策略：

  ```
  能快进就快进
  不能快进就创建 merge commit
  ```

###### 强制生成 merge commit

```
git merge --no-ff feature
```

- 常用于：
  - 保留 feature 分支的存在感
  - 团队规范（很常见）

###### 禁止 merge commit（只允许快进）

```
git merge --ff-only feature
```

- 如果不能快进 → 直接失败

###### merge commit 是谁创建的

- **是 Git 自动帮你创建的 commit**，但你可以：

  ```
  git merge feature
  ```

- 然后会弹出编辑器：让你写 commit message

  - 默认是：

  ```
  Merge branch 'feature'
  ```

- 默认情况下，`git merge` 产生 merge commit 时会“弹出编辑器让你修改提交信息”

  - Git 会打开编辑器（通常是 `vim`）：

    ```
    Merge branch 'feature'
    
    # Please enter a commit message...
    ```

    - 你可以：
      - 修改 commit message 
      - 直接保存退出 

- 不想弹编辑器怎么办

  - 直接用默认信息（推荐）

    ```
    git merge --no-edit feature
    ```

  - 不弹编辑器，直接生成：

    ```
    Merge branch 'feature'
    ```

  - 自己写 message

    ```
    git merge -m "merge login feature" feature
    ```

  -  完全不会弹

- 什么时候不会弹
  - fast-forward

#### reset

- 移动 HEAD 指针 + 可选地修改暂存区（index）和工作区（working tree）

##### 三种模式

###### `--soft`（只移动 HEAD）

```
git reset --soft <commit>
```

- 效果：

  | 区域   | 是否变化 |
  | ------ | -------- |
  | HEAD   | ✅ 移动   |
  | 暂存区 | ❌ 不变   |
  | 工作区 | ❌ 不变   |

-  结果：

  - 相当于“撤销提交，但代码还在暂存区”
  - 可以重新提交（改 commit message）

  ```
  git reset --soft HEAD~1
  ```

  - 撤销上一次 commit，但保留改动

###### `--mixed`（默认模式）

```
git reset --mixed <commit>
# 或直接写
git reset <commit>
```

- 效果：

  | 区域   | 是否变化  |
  | ------ | --------- |
  | HEAD   | ✅         |
  | 暂存区 | ✅（清空） |
  | 工作区 | ❌         |

- 结果：

  - commit 被撤销
  - 改动回到工作区（变成“未暂存”）

- 常用场景：

  ```
  git reset HEAD file.c
  ```

  - 取消 `git add`

###### --hard

```
git reset --hard <commit>
```

- 效果：

  | 区域   | 是否变化 |
  | ------ | -------- |
  | HEAD   | ✅        |
  | 暂存区 | ✅        |
  | 工作区 | ✅        |

- 结果：所有改动直接丢失

- 常用场景：

  ```
  git reset --hard HEAD~1
  ```

  - 回到上一个提交，代码彻底回滚

##### git reset可以只回退一个文件吗

###### 场景1：取消某个文件的 `git add`（最常见）

```
git reset HEAD file.c
```

- 效果：

  | 区域   | 状态          |
  | ------ | ------------- |
  | HEAD   | 不变          |
  | 暂存区 | ❌ file 被移除 |
  | 工作区 | ✅ 保留修改    |

- 等价于（新命令）：

  ```
  git restore --staged file.c
  ```

###### 场景2：把某个文件恢复到某个版本

- 比如回到 HEAD 版本：

  ```
  git reset HEAD file.c
  ```

  - 这个命令**不会修改工作区内容**，只是影响暂存区

- 如果你想连工作区也恢复：

  ```
  git restore file.c
  ```

###### 场景3：回退某个文件到某个 commit（高级）

```
git reset <commit> file.c
```

- 效果：

  - 暂存区中的 file.c 回到那个 commit 的版本
  - 工作区不变

- `git reset <commit> file.c`这个命令不是影响暂存区吗，是默认的mix？

  - 普通 reset（不带路径）

    - 做了两件事：
      1. 移动 HEAD
      2. 重置暂存区（所有文件）

  - 带文件的 reset

    - 实际行为：

      | 动作       | 是否发生      |
      | ---------- | ------------- |
      | 移动 HEAD  | ❌ 不会        |
      | 修改暂存区 | ✅ 只改 file.c |
      | 修改工作区 | ❌ 不会        |

      - 一旦你写了 `file.c`，HEAD 就不会动了

##### git reset会丢失commit吗

- `git reset` 不会立刻删除 commit，但可能让它“不可见”
- `git reset` 做的事情是：
  - 移动分支指针（HEAD）

###### 例子

- 假设：

  ```
  A -- B -- C -- D   (main)
  ```

  ------

- 执行：

  ```
  git reset --hard C
  ```

- 变成：

  ```
  A -- B -- C   (main)
           \
            D   (悬空了)
  ```

- 结果：

  - D commit **还在**
  - 但没有分支指向它
  - → 你在 `git log` 看不到了

###### 什么时候“真的丢失”

-  只有满足这两个条件才会彻底消失：

  - 1️⃣ 没有任何引用指向它

  - 2️⃣ 被 Git GC 清理
    - 默认大约：reflog 保留 ~90 天

#### switch

- `git switch` 是 Git 为了替代 `git checkout` 的一部分功能而推出的**专门用于“切换分支”**的命令（Git 2.23 之后）。
- switch = 专门切分支（不再混杂文件操作）

##### 为什么要有 git switch？

- 以前：

  ```
  git checkout
  ```

-  既可以：

  - 切分支
  - 还可以恢复文件

- 太混乱、容易误操作

- 现在拆成两个命令：

  | 功能     | 新命令        |
  | -------- | ------------- |
  | 切分支   | `git switch`  |
  | 操作文件 | `git restore` |

##### 常用命令

###### 切换到已有分支

```
git switch dev

等价于：
git checkout dev
```

###### 创建并切换分

```
git switch -c feature/login

等价于：
git checkout -b feature/login
```

###### 切回上一个分支

```
git switch -
```

- 超级好用，（相当于“来回切换”）

###### 基于某个 commit 创建分支

```
git switch -c fix-bug <commit-id>
```

###### 切换远程分支（自动创建本地分支）

```
git switch origin/dev
```

- Git 会自动：

  ```
  创建本地 dev 分支
  并跟踪 origin/dev
  ```

######  强制切换（丢弃本地修改）

```
git switch -f dev

类似：
git checkout -f dev
```

###### 带上未提交修改一起切换

```
git switch -m dev
```

- 尝试 merge 当前修改到新分支

##### 切换分支，当前工作区和暂存区的数据会不会丢

- 正常情况下不会丢，但有可能被覆盖或被 Git 阻止切换

###### 情况1：没有冲突（安全切换）

```
git switch other-branch
```

| 区域   | 会发生什么   |
| ------ | ------------ |
| 工作区 | 保留你的修改 |
| 暂存区 | 保留         |
| 分支   | 切换成功     |

- 前提：这些修改在新分支中**不会产生覆盖冲突**

###### 情况2：会影响目标分支（有冲突风险）

- 比如：

  - 你在 `main` 改了 `a.c`
  - `feature` 分支里这个文件内容不一样

- 这时候：

  ```
  git switch feature
  ```

  - Git 会直接拒绝：

    ```
    error: Your local changes to the following files would be overwritten by checkout:
        a.c
    Please commit your changes or stash them before you switch branches.
    ```

  - 关键点：**Git 不会让你丢数据，而是直接拦住你**

###### 什么时候“看起来像丢了”？

- 切换后文件变了，原因：
  - 你的修改被**新分支的版本覆盖显示**
- 但其实：
  - Git 不允许真正覆盖未提交修改
  - 所以这种情况通常是：
    - 修改不冲突
    - 或文件在两个分支一致



#### tag

- `git tag` 用来给某个提交打“标签”（版本号、里程碑等），常用于发布版本，比如 `v1.0.0`。

- tag = 给某个 commit 起一个名字（不可变指针）

  ```
  commit abc123  ← tag: v1.0.0
  ```

##### 为什么要用 tag

- 常见用途：
  - 发布版本（v1.0 / v2.0）
  - 标记重要节点
  - 快速回到某个版本

##### 常用命令

###### 查看所有 tag

```
git tag

输出：
v1.0
v1.1
v2.0
```

###### 创建 tag

- 轻量标签（lightweight）

  ```
  git tag v1.0
  ```

  - 只是一个指针（没有额外信息）

- 注解标签（推荐 ⭐）

  ```
  git tag -a v1.0 -m "first release"
  ```

  - 包含：
    - 作者
    - 日期
    - 说明

- 给历史 commit 打 tag

  ```
  git tag -a v1.0 <commit-id> -m "release"
  ```

###### 查看 tag 详情

```
git show v1.0
```

###### 删除 tag

- 删除本地 tag：

  ```
  git tag -d v1.0
  ```

- 删除远程 tag：

  ```
  git push origin --delete v1.0
  ```

###### 推送 tag 到远程

- 默认 **tag 不会自动 push**

- 推送单个tag

  ```
  git push origin v1.0
  ```

- 推送所有 tag：

  ```
  git push origin --tags
  ```

###### 切换到 tag

```
git switch --detach v1.0
```

- 进入：detached HEAD（游离状态）

#### rebase

- rebase = 把你的提交“挪到”另一个分支后面（改写历史）
- 注意一点是改变的feature，是把main上的内容拿出来，然后把分叉的地方的数据重新接到最后，但是还是在feature分支上

##### 核心思想

- 假设当前分支结构：

  ```
  A---B---C   (main)
       \
        D---E   (feature)
  ```

- 执行：

  ```
  git rebase main
  ```

- 结果

  ```
  A---B---C---D'---E'   (feature)
  ```

  - 关键点：
    - D、E 被“重新生成”（变成 D'、E'）
    - commit hash 会变化

- rebase 在干什么？

- 本质三步：

  1. 找到分叉点（B）
  2. 把 D、E “拿下来”
  3. 重新应用到 main 后面

##### 常用用法

###### 基本用法（同步主分支）

```
git switch feature
git rebase main
```

- 让 feature 基于最新 main

###### 交互式 rebase（超级重要）

```
git rebase -i HEAD~3
```

- 可以：

  - 合并 commit（squash）
  - 修改 commit message
  - 删除 commit
  - 调整顺序

- 界面类似：

  ```
  pick 1234 feat: add login
  pick 5678 fix: bug
  ```

- 可改成：

  ```
  pick 1234 feat: add login
  squash 5678 fix: bug
  ```

##### 解决冲突

- rebase 过程中如果冲突：

  ```
  # 1. 手动解决冲突
  
  # 2. 标记已解决
  git add .
  
  # 3. 继续
  git rebase --continue
  ```

##### 其他操作

```
git rebase --abort   # 放弃
git rebase --skip    # 跳过当前 commit
```

##### rebase vs merge

###### merge

```
git merge main

结果
A---B---C
 \     \
  D---E---M
  
多了一个 merge commit
```

###### rebase

```
git rebase main

A---B---C---D'---E'
历史更“直线”
```

- 原来的 D、E 并不是“直接没了”，而是变成了新的 commit（D'、E'），旧的 D、E 变成“不可达”状态

- Git 做的不是“移动”，而是：

  1. 读取 D 的改动 → 生成 D'
  2. 读取 E 的改动 → 生成 E'
  3. 把分支指向 E'

- 那原来的 D、E 呢？

  - 状态是：
    - ❌ 不在任何分支上（不可达）
    - ❌ `git log` 看不到
    - ✅ 还在 Git 对象库里（暂时）

- 可以证明它还在

  ```
  git reflog
  ```

  - 你会看到：

  ```
  abc123 HEAD@{1}: commit: D
  def456 HEAD@{2}: commit: E
  ```

  - 说明旧 commit 还存在

- 什么时候真的“没了”？

  - Git 有垃圾回收机制：

    ```
    git gc
    ```

  - 默认：

    - 几天/几周后
    - 不可达 commit 会被清理

  - 那时候 D、E 才彻底消失

##### 怎么做

###### rebase 一般怎么做

- 假设：

  - `main` 是主分支
  - `feature` 是你的开发分支

- 历史大概这样：

  ```
  A---B---C   main
       \
        D---E   feature
  ```

- 现在 `main` 前进了，你想让 `feature` 跟上 `main`：

  ```
  git switch feature
  git rebase main
  ```

- 意思是：把 **feature 分支上的 D、E**，拿下来，重新接到 `main` 后面

- 结果变成：

  ```
  A---B---C---D'---E'   feature
  ```

###### merge 一般怎么做

- 还是这两个分支：

  ```
  A---B---C   main
       \
        D---E   feature
  ```

- 如果你想把 `feature` 合进 `main`，通常这样做：

  ```
  git switch main
  git merge feature
  ```

- 意思是：把 `feature` 的内容合到当前分支 `main`

- 所以这里确实是：

  - ✅ **站在 main 分支上，merge feature**

###### 为什么会这样

- 因为 Git 大多数这类命令，都是对“当前分支”生效的。

```
git rebase main
```

- 意思不是“改 main”，而是：**把当前分支** 变基到 `main` 上

```
git merge feature
```

- 意思不是“改 feature”，而是：把 `feature` 合并到 **当前分支**

##### 怎么选

| 场景                 | 推荐          |
| -------------------- | ------------- |
| 本地开发整理历史     | ✅ rebase      |
| 已经 push 的公共分支 | ❌ 不要 rebase |
| 团队协作合并         | ✅ merge       |

##### 重要

- 不要 rebase 已经 push 的公共分支
- 否则：
  - commit hash 改变
  - 别人仓库会冲突爆炸

##### 经典工作流

```
# 开发分支
git switch feature

# 同步主分支
git fetch origin
git rebase origin/main

# 推送（如果之前 push 过）
git push -f   -- 只对自己分支用！
```

##### rebase 的核心价值

👉 **让提交历史更干净、线性**

##### 疑问

###### git rebase之后，会自动切换分支吗

- `git rebase` 不会切换分支
- 在当前分支上操作，并且操作完还停留在这个分支
- `feature` 的历史被改写，你仍然在 feature 分支上

- 为什么不会切换
  - `rebase` 的本质是：修改当前分支的历史（HEAD 所在分支）

###### 当前分支上的D 和E不是不可达了吗

- 不是完全“不可达”，而是：从分支上不可达，但仍然可以通过 reflog 找到
- 旧的 D、E 状态
  - 此时：
    - ❌ feature 不再指向 D、E
    - ❌ `git log` 看不到 D、E
    - ✅ 但它们还存在（对象库里）
    - ✅ reflog 还能找到
- feature 分支的历史中已经不包含 D、E 了，用git commit已经看不到了

### 协同

#### fetch

- 只从远程仓库下载数据到本地仓库，但不修改你的工作区和当前分支

##### 核心作用

- 当你执行：

  ```
  git fetch
  ```

- Git 会做这几件事：

  1. 连接远程仓库（默认是 `origin`）
  2. 下载最新的提交（commit）、分支信息
  3. 更新本地的**远程跟踪分支**

##### 执行后发生了什么

- 假设远程仓库：

  ```
  origin/main: A---B---C---D
  ```

- 你本地：

  ```
  main: A---B---C
  ```

- 执行：

  ```
  git fetch
  ```

- 结果：

  ```
  origin/main: A---B---C---D   （更新了）
  main:        A---B---C       （没变）
  ```

  - **你的代码一点没变，只是知道远程多了 D**

##### 经常用法

###### 获取所有远程更新

```
git fetch
```

- `git fetch`（不带参数）默认会拉取远程的“所有分支信息”，但不是把所有分支都变成本地分支

- 拉取远程所有分支的最新提交

  - 比如远程有：

    ```
    origin/main
    origin/dev
    origin/feature/login
    ```

  - fetch 后，本地会更新：

    ```
    origin/main
    origin/dev
    origin/feature/login
    ```

    - 上面的例子中为什么分支还有三层目录的这种

      - 看起来像“**三层目录**”，其实本质上不是目录，而是**分支名里带了 `/`**。

    - Git 的分支名本质是一个字符串，可以包含 `/`

      ```
      feature/login
      bugfix/api/v2
      ```

      - `/` 只是**命名约定中的分隔符**，不是目录结构

    - 这是团队开发中非常常见的一种规范，用来“分类分支”。

      常见命名方式：

      | 分支名                 | 含义           |
      | ---------------------- | -------------- |
      | `feature/login`        | 登录功能开发   |
      | `bugfix/api`           | 修 API bug     |
      | `hotfix/payment/crash` | 修支付崩溃问题 |
      | `release/v1.2.0`       | 发布版本       |

      - 好处：
        - 一眼看出用途
        - 便于团队协作
        - Git 工具（如 `git branch`）显示更清晰

- 不会创建本地分支，本地仍然可能只有：

  ```
  main
  ```

  - 不会自动变成：

    ```
    main
    dev
    feature/login   ❌（不会自动创建）
    ```

- 如果远程新增了分支呢？

  - 比如远程新建：

    ```
    origin/feature/payment
    ```

  - 你执行：

    ```
    git fetch
    ```

  - 本地会出现：

    ```
    origin/feature/payment
    ```

  - 但不会自动创建：

    ```
    feature/payment   ❌
    ```

- 想用这个新分支怎么办？

  - 你需要手动：

    ```
    git checkout -b feature/payment origin/feature/payment
    ```

  - 或者（新写法）：

    ```
    git switch -c feature/payment origin/feature/payment
    ```

###### 指定远程

```
git fetch origin
```

###### 只抓某个分支

```
git fetch origin main
```

###### 查看差异（常见组合）

```
git fetch
git diff main origin/main
```

- 看你本地和远程差多少

###### 查看远程提交

```
git log origin/main
```

###### fetch + merge

```
git fetch
git merge origin/main
```

- 优点：
  - 不会自动改代码
  - 可以先检查再合并
  - 更适合生产环境

###### 远程删除分支

- 默认：

  ```
  git fetch
  ```

- 不会删除你本地的 `origin/xxx`，需要：

  ```
  git fetch --prune
  ```

  - 才会同步删除

##### fetch 的本质

- Git 有三个区域：

  ```
  工作区 (Working Directory)
  暂存区 (Index)
  本地仓库 (Repository)
  ```

- `git fetch` **只操作：本地仓库**
- 不会影响：
  - 工作区 ❌
  - 暂存区 ❌
  - 当前分支 ❌

##### 什么时候必须用 fetch？

✔ 想看远程更新但不想改代码
 ✔ 做代码评审
 ✔ 避免 `pull` 带来的自动合并冲突
 ✔ 和 `rebase` 配合

##### git fetch拉下来的远程分支，为什么用的时候还要加origin

- **因为 `origin/main` 和 `main` 是两个完全不同的“引用（ref）”**

  - `main` 👉 你本地分支
  - `origin/main` 👉 远程分支在你本地的“镜像”

- fetch 后实际发生了什么

  - 执行：

    ```
    git fetch
    ```

  - Git 做的是：

    ```
    更新：origin/main
    不动：main
    ```

  - 状态变成：

    ```
    HEAD → main → A---B---C
    origin/main → A---B---C---D
    ```

    - 注意：
      - 新提交 D 在 `origin/main`
      - 你的 `main` 还停在 C

- 为什么不能直接用 `main`？

  -  `main` 代表的是“你当前的代码状态”

  -  `origin/main` 才是“远程最新状态”

- Git 强制把这两个东西分开：

  ```
  你当前的工作（main）
  远程的最新状态（origin/main）
  ```

  - 这样你可以：
    - ✔ 先看远程改了什么
    - ✔ 决定怎么合并
    - ✔ 避免自动冲突

- 为什么必须写 `origin/`？

  -  Git 可能有多个远程仓库

  - 现在你有：

    ```
    origin/main
    upstream/main
    ```

  -  所以必须写清楚：

    ```
    git merge origin/main
    ```

    - 否则 Git 不知道你要哪个远程

- 什么时候可以不写 origin？只有一种情况：

  -  **本地分支“跟踪”了远程分支**，比如：

  ```
  git branch -vv
  ```

  - 看到：

  ```
  main  abc123 [origin/main]
  ```

  - 这时可以：

    ```
    git pull
    git push
    ```

    - Git 自动知道对应的是 `origin/main`

#### push

- `git push` = 把本地分支的提交，上传到远程仓库，并更新远程分支指针

##### 例子

- 本地：

  ```
  main: A---B---C---D
  ```

- 远程：

  ```
  origin/main: A---B---C
  ```

- 执行：

  ```
  git push origin main
  ```

- 结果：

  ```
  远程 origin/main: A---B---C---D ✔
  ```

- D 被上传，并且远程指针前进

##### 常见用法

###### 推送当前分支（最常用）

```
git push
```

- 前提：当前分支已经绑定远程（tracking）

###### 指定远程 + 分支

```
git push origin main
```

- 明确把本地 `main` 推到远程 `origin/main`

###### 第一次推送（建立关联）

```
git push -u origin main
```

- 作用：

  - 推送

  - 建立 tracking 关系

- 以后就可以直接：

  ```
  git push
  ```

###### 查看关联的远程分支

```
git branch -u origin/main

输出
* main abc123 [origin/main] commit message
```

- `[origin/main]` 就是关联的远程分支

###### 推送所有分支

```
git push --all
```

###### push 不是“覆盖”，而是“快进（fast-forward）”

- 默认情况下：

  ```
  只允许：
  远程分支 是 本地分支 的祖先
  ```

- 正常情况

  ```
  远程: A---B---C
  本地: A---B---C---D
  ```

  - 可以 push 

- 被拒绝情况

  ```
  远程: A---B---C---E
  本地: A---B---C---D
  ```

  - push 会失败：

  ```
  rejected (non-fast-forward)
  ```

- 解决方式：

  ```
  git pull --rebase
  git push
  ```

###### 强制 push

```
git push --force
```

- 会直接改写远程历史 

###### 删除远程分支

```
git push origin --delete branch_name

举例
git push origin --delete feature/login
```

- 含义：
  - `origin`：远程仓库名
  - `--delete`：删除远程分支
  - `feature/login`：远程分支名

- 删除后本地还在？（常见坑）

  - 删除远程后，你本地可能还有：

    ```
    git branch
    ```

  - 这时候你需要：删除本地分支

    ```
    git branch -d feature/login
    或者强制
    git branch -D feature/login
    ```

- 远程分支列表不同步（你肯定遇到过）

  - 删除远程后：

    ```
    git branch -r
    ```

  - 可能还看到 `origin/feature/login`

  - 解决方法：

    ```
    git fetch -p
    或者
    git remote prune origin
    ```

    - 含义：
      - 清理已经不存在的远程分支引用

###### 新建远程分支

- 先有本地分支 → 再 push 到远程

  ```
  git push -u origin branch_name
  ```

- Git 没有“单独创建远程分支”的命令

  - 远程分支是这样产生的：

    ```
    本地分支 ——push——> 远程分支
    ```

- 推荐写法（最安全）

  ```
  git push -u origin HEAD
  ```

  - 含义：
    - 把“当前分支”推到远程同名分支

- 改名推送

  ```
  git push -u origin 本地名:远程名
  
  git push -u origin dev:feature/login
  ```

  - 含义：
    - 本地 dev → 远程 feature/login

##### 如何看远程的比现在的新不新

###### 简单方法

- 先更新远程信息

  ```
  git fetch
  ```

  - 这一步很关键（不会改你代码，只更新“远程快照”）

- 看状态

  ```
  git status
  ```

  - 会看到类似：

  ```
  Your branch is behind 'origin/main' by 3 commits.
  ```

  - 或：

    ```
    Your branch is ahead of 'origin/main' by 2 commits.
    ```

  - 或：

    ```
    Your branch and 'origin/main' have diverged.
    ```

- 含义总结：

  | 提示     | 意思               |
  | -------- | ------------------ |
  | behind   | 远程更新（你落后） |
  | ahead    | 你本地更新         |
  | diverged | 双方都有更新       |

###### 更直观：看提交差异

- 看远程比你多哪些提交

  ```
  git log HEAD..origin/main --oneline
  ```

  -  有输出 = 远程更新了

- 看你比远程多哪些提交

  ```
  git log origin/main..HEAD --oneline
  ```

  - 有输出 = 你本地更新了

- 记忆口诀：

  ```
  A..B  =>  看 B 比 A 多的提交
  ```

- HEAD..origin/main这个是固定写法吗

  - 不是固定写法 ，而是 Git 的一种**通用“范围表达式”语法**。

  - `HEAD..origin/main` 只是这种格式的一种具体用法：

    ```
    A..B
    ```

    - 意思是：“在 B 中，但不在 A 中的提交”

  - 

###### 一步看清 ahead / behind（推荐）

```
git branch -vv
```

- 输出示例：

  ```
  * main 123abc [origin/main: behind 2] msg
  ```

- 或：

  ```
  * main 123abc [origin/main: ahead 1] msg
  ```

#### pull

- `git pull` = `git fetch` + `git merge`（默认）

- 执行：

  ```
  git pull
  ```

- 等价于：

  ```
  git fetch
  git merge origin/当前分支
  ```

##### 过程拆解

- 假设当前在 `main`：

  ```
  本地 main:        A---B---C
  远程 origin/main: A---B---C---D
  ```

- 执行：

  ```
  git pull
  ```

- 第一步：fetch

  ```
  origin/main → A---B---C---D
  main        → A---B---C
  HEAD        → main
  ```

- 第二步：merge

  ```
  main → A---B---C---D
  HEAD → main
  ```

  - 本地分支前进了

##### 常见用法

###### 默认用法

```
git pull
```

- 前提：当前分支已经绑定远程（tracking）

###### 指定远程 + 分支

```
git pull origin main
```

###### 推荐用法

```
git pull --rebase
```

- 等价：

  ```
  git fetch
  git rebase origin/main
  ```
