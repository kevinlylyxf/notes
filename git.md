#### Git初探

- Git远程仓库是有权限的，我们可以添加权限，通过用户名密码添加，或者添加ssh key，这样多人就可以协作了，如果没有权限是不能push的。

- Git 用以计算校验和的机制叫做 SHA-1 散列（hash，哈希）。 这是一个由 40 个十六进制字符（0-9 和 a-f）组成的字符串，基于 Git 中文件的内容或目录结构计算出来。
- Git 有三种状态，你的文件可能处于其中之一： **已提交（committed）**、**已修改（modified）** 和 **已暂存（staged）**。
  - 已修改表示修改了文件，但还没有保存到数据库中
  - 已暂存表示对一个已修改文件的当前版本做了标记，使之包含在下次提交的快照中。
  - 已提交表示数据已经安全地保存在本地数据库中。

##### 初次运行Git前的配置

- Git 自带一个 `git config`的工具来帮助设置控制 Git 外观和行为的配置变量。 这些变量存储在三个不同的位置

  - `/etc/gitconfig`，包含系统上每一个用户及他们仓库的通用配置。`git config --system`
  - `~/.gitconfig`只针对当前用户`git config --global`
  - 当前使用仓库的 Git 目录中的 `config` 文件（即 `.git/config`）：针对该仓库。 你可以传递 `--local` 选项让 Git 强制读写此文件。必须进入某个Git仓库才能让该选项生效。
  - 每一个级别会覆盖上一级别的配置，所以 `.git/config` 的配置变量会覆盖 `/etc/gitconfig` 中的配置变量。

- 命令行输入``git config``可以看到配置的提示信息。

- 你可以通过以下命令查看所有的配置以及它们所在的文件

  ```shell
  git config --list --show-origin
  ```

- 安装完 Git 之后，要做的第一件事就是设置你的用户名和邮件地址。 这一点很重要，因为每一个 Git 提交都会使用这些信息，它们会写入到你的每一次提交中，不可更改

  ```shell
  git config --global user.name "Kevin Li"
  git config --global user.email lylyxf@163.com
  ```

- 配置默认文本编辑器：当 Git 需要你输入信息时会调用它。 如果未配置，Git 会使用操作系统默认的文本编辑器。

  ```shell
  git config --global core.editor emacs
  ```

  

- 由于 Git 会从多个文件中读取同一配置变量的不同值，因此你可能会在其中看到意料之外的值而不知道为什么。 此时，你可以查询 Git 中该变量的原始值，它会告诉你哪一个配置文件最后设置了该值

  ```shell
  git config --show-origin user.name
  file:/home/lyl/.gitconfig       lylyxf@163.com
  ```

- `git help command`获取帮助，或者`git command -h`

#### Git基础

- 工作目录下的每一个文件都不外乎这两种状态：**已跟踪** 或 **未跟踪**。 已跟踪的文件是指那些被纳入了版本控制的文件，在上一次快照中有它们的记录，在工作一段时间后， 它们的状态可能是未修改，已修改或已放入暂存区。简而言之，已跟踪的文件就是 Git 已经知道的文件。

- 编辑过某些文件之后，由于自上次提交后你对它们做了修改，Git 将它们标记为已修改文件。 在工作时，你可以选择性地将这些修改过的文件放入暂存区，然后提交所有已暂存的修改，如此反复。

- `git status`查看当前状态，只要在 `Changes to be committed` 这行下面的，就说明是已暂存状态。 如果此时提交，那么该文件在你运行 `git add` 时的版本将被留存在后续的历史记录中。所有文件的版本是你最后一次运行`git add`命令时的版本。所以在放到暂存区之后，没有提交就在工作区修改，最后一次`git add`就是当前文件记录的版本。

-  `git add` 命令使用文件或目录的路径作为参数；如果参数是目录的路径，该命令将递归地跟踪该目录下的所有文件。

- 忽略文件：一般我们总会有些文件无需纳入 Git 的管理，也不希望它们总出现在未跟踪文件列表。 通常都是些自动生成的文件，比如日志文件，或者编译过程中创建的临时文件等。 在这种情况下，我们可以创建一个名为 `.gitignore` 的文件，列出要忽略的文件的模式。要养成一开始就为你的新仓库设置好 `.gitignore` 文件的习惯，以免将来误提交这类无用的文件。git status时就不会显示出这些文件和目录。但是如果没有忽略前就已经commit和push的依然会在远程仓库上存在。

  文件 `.gitignore` 的格式规范如下：

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

  ```shell
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

- `git diff`此命令比较的是工作目录中当前文件和暂存区域快照之间的差异。 也就是修改之后还没有暂存起来的变化内容。若要查看已暂存的将要添加到下次提交里的内容，可以用 `git diff --staged` 命令。 这条命令将比对已暂存文件与最后一次提交的文件差异。

- `git commit`选项参数很多，可以使用`git commit -h`查看，也可以不加参数直接输入`git commit`默认的提交消息包含最后一次运行 `git status` 的输出

- Git 提供了一个跳过使用暂存区域的方式， 只要在提交的时候，给 `git commit` 加上 `-a` 选项，Git 就会自动把所有已经跟踪过的文件暂存起来一并提交，从而跳过 `git add` 步骤。但是要小心，有时这个选项会将不需要的文件添加到提交中。

- 要从 Git 中移除某个文件，就必须要从已跟踪文件清单中移除（确切地说，是从暂存区域移除），然后提交。 可以用 `git rm` 命令完成此项工作，并连带从工作目录中删除指定的文件，这样以后就不会出现在未跟踪文件清单中了。不能简单的使用rm删除文件，删除后查看状态也会在未暂存清单里面看到，`git rm`是在数据库里面删除，就不跟踪了。

- 另外一种情况是，我们想把文件从 Git 仓库中删除（亦即从暂存区域移除），但仍然希望保留在当前工作目录中。 换句话说，你想让文件保留在磁盘，但是并不想让 Git 继续跟踪。 当你忘记添加 `.gitignore` 文件，不小心把一个很大的日志文件或一堆 `.a` 这样的编译生成文件添加到暂存区时，这一做法尤其有用。 为达到这一目的，使用 `--cached` 选项：

  ```shell
  git rm --cached README
  ```

- `git rm log/\*.log`注意到星号 `*` 之前的反斜杠 `\`， 因为 Git 有它自己的文件模式扩展匹配方式，所以我们不用 shell 来帮忙展开。 此命令删除 `log/` 目录下扩展名为 `.log` 的所有文件。这个和.gitignore是有区别的，那个不需要\。
- `git mv`可以移动目录修改文件名。

##### Git查看提交历史

- `git log`查看提交历史。这个命令会列出每个提交的 SHA-1 校验和、作者的名字和电子邮件地址、提交时间以及提交说明。
- `git log`后面有好多选项可以选择，按不同的输出来显示我们想要看到的历史。-p，--stat

##### Git撤销操作

- 有时候我们提交完了才发现漏掉了几个文件没有添加，或者提交信息写错了。 此时，可以运行带有 `--amend` 选项的提交命令来重新提交 `git commit --amend`这个命令会将暂存区中的文件提交。 如果自上次提交以来你还未做任何修改（例如，在上次提交后马上执行了此命令）， 那么快照会保持不变，而你所修改的只是提交信息。

  例如，你提交后发现忘记了暂存某些需要的修改，可以像下面这样操作：

  ```shell
  $ git commit -m 'initial commit'
  $ git add forgotten_file
  $ git commit --amend
  ```

  最终你只会有一个提交——第二次提交将代替第一次提交的结果。当你在修补最后的提交时，并不是通过用改进后的提交 **原位替换** 掉旧有提交的方式来修复的， 理解这一点非常重要。从效果上来说，就像是旧有的提交从未存在过一样，它并不会出现在仓库的历史中。

- 撤销对文件的修改：修改文件之后`git status`可以看到

  ```shell
  Changes not staged for commit:
    (use "git add <file>..." to update what will be committed)
    (use "git checkout -- <file>..." to discard changes in working directory)
  
  ```

  使用`git checkout --` 就可以取消对文件的修改。请务必记得 `git checkout -- <file>` 是一个危险的命令。 你对那个文件在本地的任何修改都会消失——Git 会用最近提交的版本覆盖掉它。 除非你确实清楚不想要对那个文件的本地修改了，否则请不要使用这个命令。

- 取消暂存的文件：就是放到暂存区的文件此次不提交了，放到工作区。此时git还是可以追踪的，如果不需要追踪的需要`git rm`删除，`git add` 添加到暂存区之后会有提示use ... to unstage，不同的版本可能不一样，看提示最清楚。

##### Git远程仓库的使用

- 如果想查看你已经配置的远程仓库服务器，可以运行 `git remote` 命令。如果你已经克隆了自己的仓库，那么至少应该能看到 origin ——这是 Git 给你克隆的仓库服务器的默认名字。

- 你也可以指定选项 `-v`，会显示需要读写远程仓库使用的 Git 保存的简写与其对应的 URL。

- 运行 `git remote add <shortname> <url>` 添加一个新的远程 Git 仓库，同时指定一个方便使用的简写：此时会在远程创建一个仓库，后面的ticgit就是新仓库的名字。一般情况下我们都是在服务器上新建一个仓库，然后git clone拉下来，这时可以选择使用https或者git协议，https需要验证用户名和密码，git协议使用ssh key来验证，直接push就可以了。

  ```shell
  git remote add pb https://github.com/paulboone/ticgit
  ```

  现在你可以在命令行中使用字符串 `pb` 来代替整个 URL。 例如，如果你想拉取 Paul 的仓库中有但你没有的信息，可以运行 `git fetch pb`

- `git fetch <remote>`这个命令会访问远程仓库，从中拉取所有你还没有的数据。 执行完成后，你将会拥有那个远程仓库中所有分支的引用，可以随时合并或查看。如果你使用 `clone` 命令克隆了一个仓库，命令会自动将其添加为远程仓库并默认以 “origin” 为简写。 所以，`git fetch origin` 会抓取克隆（或上一次抓取）后新推送的所有工作。 必须注意 `git fetch` 命令只会将数据下载到你的本地仓库——它并不会自动合并或修改你当前的工作。 当准备好时你必须手动将其合并入你的工作。

  如果你的当前分支设置了跟踪远程分支。 那么可以用 `git pull` 命令来自动抓取后合并该远程分支到当前分支。 这或许是个更加简单舒服的工作流程。默认情况下，`git clone` 命令会自动设置本地 master 分支跟踪克隆的远程仓库的 `master` 分支（或其它名字的默认分支）。 运行 `git pull` 通常会从最初克隆的服务器上抓取数据并自动尝试合并到当前所在的分支。

  ```shell
  git fetch origin master:tmp 
  //在本地新建一个temp分支，并将远程origin仓库的master分支代码下载到本地temp分支
  git diff tmp 
  //来比较本地代码与刚刚从远程下载下来的代码的区别
  git merge tmp
  //合并temp分支到本地的master分支
  git branch -d tmp
  //如果不想保留temp分支 可以用这步删除
  git pull <远程主机名> <远程分支名>:<本地分支名>
  //将远程主机 origin 的 master 分支拉取过来，与本地的 brantest 分支合并。
  git pull origin master:brantest
  //如果远程分支是与当前分支合并，则冒号后面的部分可以省略。
  git pull origin master
  
  git push 命用于从将本地的分支版本上传到远程并合并。
  git push <远程主机名> <本地分支名>:<远程分支名>
  //如果本地分支名与远程分支名相同，则可以省略冒号：
  git push <远程主机名> <本地分支名>
  ```

  

- 当你想分享你的项目时，必须将其推送到上游。 这个命令很简单：`git push <remote> <branch>`。 当你想要将 `master` 分支推送到 `origin` 服务器时（再次说明，克隆时通常会自动帮你设置好那两个名字）， 那么运行这个命令就可以将你所做的备份到服务器：当你和其他人在同一时间克隆，他们先推送到上游然后你再推送到上游，你的推送就会毫无疑问地被拒绝。 你必须先抓取他们的工作并将其合并进你的工作后才能推送。

  ```shell
  git push origin master
  ```

- 如果想要查看某一个远程仓库的更多信息，可以使用 `git remote show <remote>` 命令。它同样会列出远程仓库的 URL 与跟踪分支的信息。 这些信息非常有用，它告诉你正处于 `master` 分支，并且如果运行 `git pull`， 就会抓取所有的远程引用，然后将远程 `master` 分支合并到本地 `master` 分支。 它也会列出拉取到的所有远程引用。

- 如果你是 Git 的重度使用者，那么还可以通过 `git remote show` 看到更多的信息。这个命令列出了当你在特定的分支上执行 `git push` 会自动地推送到哪一个远程分支。 它也同样地列出了哪些远程分支不在你的本地，哪些远程分支已经从服务器上移除了， 还有当你执行 `git pull` 时哪些本地分支可以与它跟踪的远程分支自动合并。

- 你可以运行 `git remote rename` 来修改一个远程仓库的简写名。`git remote rename pb paul`

- 如果因为一些原因想要移除一个远程仓库——你已经从服务器上搬走了或不再想使用某一个特定的镜像了， 又或者某一个贡献者不再贡献了——可以使用 `git remote remove` 或 `git remote rm`    `git remote remove pau`l

##### Git打标签

- Git 可以给仓库历史中的某一个提交打上标签，以示重要。 比较有代表性的是人们会使用这个功能来标记发布结点（ `v1.0` 、 `v2.0` 等等）。

- 列出标签：在 Git 中列出已有的标签非常简单，只需要输入 `git tag` 你也可以按照特定的模式查找标签。 例如，Git 自身的源代码仓库包含标签的数量超过 500 个。 如果只对 1.8.5 系列感兴趣，可以运行： `git tag -l "v1.8.5*“`

- 创建标签：Git 支持两种标签：轻量标签（lightweight）与附注标签（annotated）。

  轻量标签很像一个不会改变的分支——它只是某个特定提交的引用。

  而附注标签是存储在 Git 数据库中的一个完整对象， 它们是可以被校验的，其中包含打标签者的名字、电子邮件地址、日期时间， 此外还有一个标签信息，并且可以使用 GNU Privacy Guard （GPG）签名并验证。 通常会建议创建附注标签，这样你可以拥有以上所有信息。但是如果你只是想用一个临时的标签， 或者因为某些原因不想要保存这些信息，那么也可以用轻量标签。

  - 在 Git 中创建附注标签十分简单。 最简单的方式是当你在运行 `tag` 命令时指定 `-a` 选项：

    ```shell
    git tag -a v1.4 -m "my version 1.4"
    ```

    `-m` 选项指定了一条将会存储在标签中的信息。 如果没有为附注标签指定一条信息，Git 会启动编辑器要求你输入信息。

  - 通过使用 `git show` 命令可以看到标签信息和与之对应的提交信息

    ```shell
    git show v1.4  //后面的名字必须要加，否则显示不出来
    ```

  - 后期打标签：假设在 v1.2 时你忘记给项目打标签，也就是在 “updated rakefile” 提交。 你可以在之后补上标签。 要在那个提交上打标签，你需要在命令的末尾指定提交的校验和（或部分校验和）：

    ```shell
    git tag -a v1.2 9fceb02  //9fceb02是git log查看出来的部分校验和，也可以是全部的，部分也可以
    ```

  - 共享标签：默认情况下，`git push` 命令并不会传送标签到远程仓库服务器上。 在创建完标签后你必须显式地推送标签到共享服务器上。 这个过程就像共享远程分支一样——你可以运行 `git push origin <tagname>`。如果想要一次性推送很多标签，也可以使用带有 `--tags` 选项的 `git push` 命令。 这将会把所有不在远程仓库服务器上的标签全部传送到那里。

    ```shell
    git push origin v1.5
    git push origin --tags
    ```

  - 删除标签：要删除掉你本地仓库上的标签，可以使用命令 `git tag -d <tagname>`删除远程标签的方式是：`git push origin --delete <tagname>`。只是删除某个确定的标签。

  - 轻量标签

    - 另一种给提交打标签的方式是使用轻量标签。 轻量标签本质上是将提交校验和存储到一个文件中——没有保存任何其他信息。 创建轻量标签，不需要使用 `-a`、`-s` 或 `-m` 选项，只需要提供标签名字：

      ```
      git tag v1.4-lw
      ```

    - 这时，如果在标签上运行 `git show`，你不会看到额外的标签信息。 命令只会显示出提交信息：

      ```
      $ git show v1.4-lw
      commit ca82a6dff817ec66f44342007202690a93763949
      Author: Scott Chacon <schacon@gee-mail.com>
      Date:   Mon Mar 17 21:52:11 2008 -0700
      
          changed the version number
      ```

      

##### Git回退

- Git reset 命令有三个主要选项：git reset --soft; git reset --mixed; git reset --hard;以V1，V2，V3来表示commit版本。

  - `git reset --soft`将HEAD引用指向给定提交。索引（暂存区）和工作目录的内容是不变的，在三个命令中对现有版本库状态改动最小。意思为HEAD指针指向V2，但是当前工作区和暂存区依旧是V3，只要commit就可以变成V3
  - `git reset --mixed（git reset默认的模式）`HEAD引用指向给定提交，并且索引（暂存区）内容也跟着改变，工作目录内容不变。这个命令会将索引（暂存区）变成暂存该给定提交全部变化时的状态。工作目录不变且会显示工作目录中有什么修改。HEAD指针指向V2，暂存区为V2，工作区为V3，只要git add然后commit就会变为V3
  - `git reset --hard`HEAD引用指向给定提交，索引（暂存区）内容和工作目录内容都会变为给定提交时的状态。也就是在给定提交后所修改的内容都会丢失(新文件会被删除，不在工作目录中的文件恢复，未清除回收站的前提)。彻底回退到某个版本，本地的源码也会变为上一个版本的内容。HEAD指向V2，暂存区和工作区都是V2，V3版本的修改已经丢弃，所以只能重新修改工作区的文件。

- `git reflog` 可以查看所有分支的所有操作记录（包括commit和reset的操作，已经被删除的commit记录），git log则不能察看已经删除了的commit记录。`git reflog`查询到commit id之后，使用git reset就可以回退到未来。git reflog常用于恢复本地的错误操作。

- git log查看的是每次commit的记录，并不会记录reset回退后版本时间线以后的commit，因为git是按照时间记录的，回退后git log就不能查看回退后版本时间线以后的commit。git reflog查看的是所有的操作记录包括reset的都会记录到里面，其记录是从git clone开始的，git clone以前的不会记录，而且只会记录本地操作，其他主机上的操作也不会记录，因为其是为本地用的。远程仓库记录的只是commit记录，只是记录commit那个时间的快照。所以git pull拉下来合并的时候也是看的你当前commit和远程仓库上commit的时间，如果本地上的commit时间是最新的，就会自动合并。合并后不用重新commit，因为本地已经commit，git就会记录到，只要push到远程仓库就行，远程仓库就会记录到本地上那个commit。

##### Git stash(储藏)

- 经常有这样的事情发生，当你正在进行项目中某一部分的工作，里面的东西处于一个比较杂乱的状态，而你想转到其他分支上进行一些工作。问题是，你不想提交进行了一半的工作，否则以后你无法回到这个工作点。解决这个问题的办法就是`git stash`命令。储藏(stash)可以获取你工作目录的中间状态——也就是你修改过的被追踪的文件和暂存的变更——并将它保存到一个未完结变更的堆栈中，随时可以重新应用。
- 使用git的时候，我们往往使用分支（branch）解决任务切换问题，例如，我们往往会建一个自己的分支去修改和调试代码, 如果别人或者自己发现原有的分支上有个不得不修改的bug，我们往往会把完成一半的代码`commit`提交到本地仓库，然后切换分支去修改bug，改好之后再切换回来。这样的话往往log上会有大量不必要的记录。其实如果我们不想提交完成一半或者不完善的代码，但是却不得不去修改一个紧急Bug，那么使用`git stash`就可以将你当前未提交到本地（和服务器）的代码推入到Git的栈中，这时候你的工作区间和上一次提交的内容是完全一样的，所以你可以放心的修Bug，等到修完Bug，提交到服务器上后，再使用`git stash apply`将以前一半的工作应用回来。
- 常用命令
  - git stash在存储的时候只针对当前分支存储，git stash list时可以看到在哪个分支上储藏的，但是在还原时可以将另一个分支的储藏还原到当前分支上，但是一般不这么干，git stash的堆栈就是一个，不会为每个分支都设有一个堆栈，但是我们还原的时候可以选择还原哪个，list里面会有分支的记录，直接还原对应的那个就可以。
  - **git stash** save "save message" : 执行存储时，添加备注，方便查找，只有git stash 也要可以的，但查找时不方便识别。
  - **git stash list** ：查看stash了哪些存储
  - **git stash show** ：显示做了哪些改动，默认show第一个存储,如果要显示其他存贮，后面加stash@{$num}，比如第二个 git stash show stash@{1}
  - **git stash show -p** : 显示第一个存储的改动，如果想显示其他存存储，命令：git stash show stash@{$num} -p ，比如第二个：git stash show stash@{1} -p
  - **git stash apply** :应用某个存储,但不会把存储从存储列表中删除，默认使用第一个存储,即stash@{0}，如果要使用其他个，git stash apply stash@{$num} ， 比如第二个：git stash apply stash@{1} 
  - **git stash pop** ：命令恢复之前缓存的工作目录，将缓存堆栈中的对应stash删除，并将对应修改应用到当前的工作目录下,默认为第一个stash,即stash@{0}，如果要应用并删除其他stash，命令：git stash pop stash@{$num} ，比如应用并删除第二个：git stash pop stash@{1}
  - **git stash drop** stash@{$num} ：丢弃stash@{$num}存储，从列表中删除这个存储
  - **git stash clear** ：删除所有缓存的stash
- git stash可以暂存部分文件，命令git stash push <file>



#### Git分支

- 每个分支只能看到自己的文件，其他分支的内容看不到。
- `git branch`创建分支。切换到一个已存在的分支，你需要使用 `git checkout` 命令
- 你可以简单地使用 `git log` 命令查看各个分支当前所指的对象。 提供这一功能的参数是 `--decorate`。
- 你可以简单地使用 `git log` 命令查看分叉历史。 运行 `git log --oneline --decorate --graph --all` ，它会输出你的提交历史、各个分支的指向以及项目的分支分叉情况。
- 新建一个分支并同时切换到那个分支上，你可以运行一个带有 `-b` 参数的 `git checkout` 命令
- 使用带 `-d` 选项的 `git branch` 命令来删除分支
- `git merge`将分支合并到当前分支。合并之后分支就可以删除了，因为master现在就指向那里。意思是我们有很多分支，当想合并分支时，切换到想要合并到的那个分支，然后`git merge`之后就可以合并。
  - 有时候合并操作不会如此顺利。 如果你在两个不同的分支中，对同一个文件的同一个部分进行了不同的修改，Git 就没法干净的合并它们。 如果你对 #53 问题的修改和有关 `hotfix` 分支的修改都涉及到同一个文件的同一处，在合并它们的时候就会产生合并冲突。合并冲突后就会停止合并，解决完成后才会合并。合并冲突后可以使用`git status`查看冲突。
- 你在 `hotfix` 分支上所做的工作并没有包含到 `iss53` 分支中。 如果你需要拉取 `hotfix` 所做的修改（此时hotfix已经合并到master），你可以使用 `git merge master` 命令将 `master` 分支合并入 `iss53` 分支，或者你也可以等到 `iss53` 分支完成其使命，再将其合并回 `master` 分支。
- 三方合并：和之前将分支指针向前推进所不同的是，Git 将此次三方合并的结果做了一个新的快照并且自动创建一个新的提交指向它。 这个被称作一次合并提交，它的特别之处在于他有不止一个父提交。
- `git branch` 命令不只是可以创建与删除分支。 如果不加任何参数运行它，会得到当前所有分支的一个列表
- 如果需要查看每一个分支的最后一次提交，可以运行 `git branch -v` 命令
- `--merged` 与 `--no-merged` 这两个有用的选项可以过滤这个列表中已经合并或尚未合并到当前分支的分支。 如果要查看哪些分支已经合并到当前分支，可以运行 `git branch --merged`：查出来的分支就可以删除了

##### Git fetch

- 一旦远程主机的版本库有了更新（Git术语叫做commit），需要将这些更新取回本地，这时就要用到`git fetch`命令。

  ```c
  git fetch <远程主机名>
  ```

- `git fetch`命令通常用来查看其他人的进程，因为它取回的代码对你本地的开发代码没有影响。默认情况下，`git fetch`取回所有分支（branch）的更新。如果只想取回特定分支的更新，可以指定分支名。

  ```c
  git fetch <远程主机名> <分支名>
  ```

- 所取回的更新，在本地主机上要用"远程主机名/分支名"的形式读取。比如`origin`主机的`master`，就要用`origin/master`读取。

  `git branch`命令的`-r`选项，可以用来查看远程分支，`-a`选项查看所有分支

  ```git
  git branch -r
  origin/master
  
  $ git branch -a
  * master
    remotes/origin/master
    
    
    -a选项中显示出来fetch下来的前面带有remotes，-r选项不带，使用时用origin就行了，不需要带上remotes
  ```

- `git fetch`拉取下来的代码在origin开头的远程分支上，不会直接覆盖本地的代码。需要时在`git merge`就可以了

##### Git merge和合并冲突

- **工作区(working directory)，**简言之就是你工作的区域。对于git而言，就是的本地工作目录。工作区的内容会包含提交到暂存区和版本库(当前提交点)的内容，同时也包含自己的修改内容。

- **暂存区(stage area, 又称为索引区index)，**是git中一个非常重要的概念。是我们把修改提交版本库前的一个过渡阶段。查看GIT自带帮助手册的时候，通常以index来表示暂存区。在工作目录下有一个.git的目录，里面有个index文件，存储着关于暂存区的内容。git add命令将工作区内容添加到暂存区。

- **本地仓库(local repository)，**版本控制系统的仓库，存在于本地。当执行git commit命令后，会将暂存区内容提交到仓库之中。在工作区下面有.git的目录，这个目录下的内容不属于工作区，里面便是仓库的数据信息，暂存区相关内容也在其中

- git merge合并的是远程仓库和本地仓库，并不会合并工作区和暂存区的内容，如果本地修改没有commit，本地仓库就不会变，如果远程仓库上也没有人提交的话，两地的内容就一样，此时合并时显示已经是最新的代码。

- 在合并的时候，你应该注意到了“快进（fast-forward）”这个词。 由于你想要合并的分支 `hotfix` 所指向的提交 `C4` 是你所在的提交 `C2` 的直接后继， 因此 Git 会直接将指针向前移动。换句话说，当你试图合并两个分支时， 如果顺着一个分支走下去能够到达另一个分支，那么 Git 在合并两者的时候， 只会简单的将指针向前推进（指针右移），因为这种情况下的合并操作没有需要解决的分歧——这就叫做 “快进（fast-forward）”。

- 什么叫做合并，如果远程仓库上有人对一个文件进行了修改提交，但是本地没有拉下来就直接在本地修改了，相当于在上上次的文件下修改，此时两个版本中同一个文件都有修改，此时git就不知道选哪一个了，也不能根据commit时间来选择，此时就会报错，如果一个修改一个没有修改，此时就可以使用commit时间来选择，选择最新的就可以。

- 其实根据commit来选择也是全部的选择，只是指针的移动，不可能在一个版本下一个文件比现在时间新而一个旧。

- 在本地的合并是选择最新的文件，而远程仓库和本地的合并还需要将数据使用git fetch拉下来，然后在合并。

- 如果远程仓库上有其他人的提交，本地仓库上还没有拉下来，但是本地上已经有一些修改，使用git pull时如果合并没有冲突就会直接和本地合并，本地修改的部分git status还是可以看到我们修改的一些东西。此时必须是两个版本上的文件都没有修改，如果修改了此时合并估计也有问题，因为不知道是依据哪个的修改。例如我在101.2上给远程仓库上提交，此时在101.81上拉下来，但是我在101.81上对encode_tool里面的main函数进行了修改，但是我没有提交，所以拉下来因为本地仓库和远程仓库中这个文件没有变化，直接merge。然后本地的修改git status也能看出来，git diff可以看到具体的修改。但是如果本地和远程中的文件不一样，但是本地也修改了应该会出现问题。只要冲突了解决冲突就可以了。此时修改了如果commit，然后本地和远程中仓库对同一文件进行了修改，只要按照下面的操作解决冲突。

- 其实理解合并就是看两个分支，git fetch拉下来的数据在本地以origin开头的显示，合并的时候直接使用合并就可以了，合并的时候主要看commit之后的，如果两个分支对同一个文件都没有修改，那就是相同的直接合并，如果远程分支变了，本地没有commit但是修改了，此时pull就是出错，git不知道对谁修改的，git会提示让你commit或者stash。如果远程分支没变，本地修改并且commit了，就会按照本地的来合并。如果本地修改了一个文件并且commit，远程修改了另一个文件，但是远程哪个commit在本地没有显示，此时git pull就会合并，并且不会出错。此时git log查看就会看到本地的commit和远程的那个commit。先后顺序按照commit时间来显示。当前目录中就相当于哪个文件最新就用哪个文件。

- 有时候合并操作不会如此顺利。 如果你在两个不同的分支中，对同一个文件的同一个部分进行了不同的修改，Git 就没法干净的合并它们。 如果你对 #53 问题的修改和有关 `hotfix` 分支的修改都涉及到同一个文件的同一处，在合并它们的时候就会产生合并冲突

- 在合并冲突后的任意时刻使用 `git status` 命令来查看那些因包含合并冲突而处于未合并（unmerged）状态的文件

- 任何因包含合并冲突而有待解决的文件，都会以未合并状态标识出来。 Git 会在有冲突的文件中加入标准的冲突解决标记，这样你可以打开这些包含冲突的文件然后手动解决冲突。 出现冲突的文件会包含一些特殊区段，看起来像下面这个样子：

  ```
  <<<<<<< HEAD:index.html
  <div id="footer">contact : email.support@github.com</div>
  =======
  <div id="footer">
   please contact us at support@github.com
  </div>
  >>>>>>> iss53:index.html
  ```

  - 这表示 `HEAD` 所指示的版本（也就是你的 `master` 分支所在的位置，因为你在运行 merge 命令的时候已经检出到了这个分支）在这个区段的上半部分（`=======` 的上半部分），而 `iss53` 分支所指示的版本在 `=======` 的下半部分。 为了解决冲突，你必须选择使用由 `=======` 分割的两部分中的一个，或者你也可以自行合并这些内容。 例如，你可以通过把这段内容换成下面的样子来解决冲突：

    ```
    <div id="footer">
    please contact us at email.support@github.com
    </div>
    ```

  - 上述的冲突解决方案仅保留了其中一个分支的修改，并且 `<<<<<<<` , `=======` , 和 `>>>>>>>` 这些行被完全删除了。 在你解决了所有文件里的冲突之后，对每个文件使用 `git add` 命令来将其标记为冲突已解决。 一旦暂存这些原本有冲突的文件，Git 就会将它们标记为冲突已解决。

##### 远程分支

- 从一个远程跟踪分支检出一个本地分支会自动创建所谓的“跟踪分支”（它跟踪的分支叫做“上游分支”）。 跟踪分支是与远程分支有直接关系的本地分支。 如果在一个跟踪分支上输入 `git pull`，Git 能自动地识别去哪个服务器上抓取、合并到哪个分支。

  当克隆一个仓库时，它通常会自动地创建一个跟踪 `origin/master` 的 `master` 分支。 然而，如果你愿意的话可以设置其他的跟踪分支，或是一个在其他远程仓库上的跟踪分支，又或者不跟踪 `master` 分支。 最简单的实例就是像之前看到的那样，运行 `git checkout -b <branch> <remote>/<branch>`。 这是一个十分常用的操作所以 Git 提供了 `--track` 快捷方式：

  ```shell
  git checkout --track origin/serverfix
  ```

  由于这个操作太常用了，该捷径本身还有一个捷径。 如果你尝试检出的分支 (a) 不存在且 (b) 刚好只有一个名字与之匹配的远程分支，那么 Git 就会为你创建一个跟踪分支：

  ```shell
  git checkout serverfix
  ```

  设置已有的本地分支跟踪一个刚刚拉取下来的远程分支，或者想要修改正在跟踪的上游分支， 你可以在任意时间使用 `-u` 或 `--set-upstream-to` 选项运行 `git branch` 来显式地设置。

  ```shell
  git branch -u origin/serverfix
  ```

  如果想要将本地分支与远程分支设置为不同的名字，你可以轻松地使用上一个命令增加一个不同名字的本地分支：

  ```shell
  git checkout -b sf origin/serverfix
  ```

  如果想要查看设置的所有跟踪分支，可以使用 `git branch` 的 `-vv` 选项。 这会将所有的本地分支列出来并且包含更多的信息，如每一个分支正在跟踪哪个远程分支与本地分支是否是领先、落后或是都有。其中领先和落后通过ahead和behind指出。

  当设置好跟踪分支后，可以通过简写 `@{upstream}` 或 `@{u}` 来引用它的上游分支。 所以在 `master` 分支时并且它正在跟踪 `origin/master` 时，如果愿意的话可以使用 `git merge @{u}` 来取代 `git merge origin/master`。

- 如果在本地新建一个分支push上去的时候要写上本地分支名和远程分支名就可以了，因为远程没有，这样远程就会按照分支名新建一个。

- 当 `git fetch` 命令从服务器上抓取本地没有的数据时，它并不会修改工作目录中的内容。 它只会获取数据然后让你自己合并。 然而，有一个命令叫作 `git pull` 在大多数情况下它的含义是一个 `git fetch` 紧接着一个 `git merge` 命令。 如果有一个像之前章节中演示的设置好的跟踪分支，不管它是显式地设置还是通过 `clone` 或 `checkout` 命令为你创建的，`git pull` 都会查找当前分支所跟踪的服务器与分支， 从服务器上抓取数据然后尝试合并入那个远程分支。pull的合并本地的数据应该是commit的。没有commit的不会合并。

  由于 `git pull` 的魔法经常令人困惑所以通常单独显式地使用 `fetch` 与 `merge` 命令会更好一些。

  - git pull一些使用问题，别人修改了文件并且提交push，你也修改了此文件并且没有add和commit，然后在pull时就会出现问题，本地对文件的修改将会被合并操作覆盖，如果不是同一个文件，本地数据应该会保存，这种情况下git会有提示信息。解决办法一为add和commit，pull合并时就会按照commit时间来比较，记录到最新的commit。方法二为`git stash`，看具体用法。
  - git pull时如果检测到问题就会放弃合并，按照提示信息解决就好。
  - 在修改文件前最好pull一下，这样就不会出现这种问题，出现这种问题按提示解决就好，在实际开发中，应该不会出现几个人同时对一个文件的修改，如果有也应该用分支来做，多建几个分支，然后最后合并。
  - git在push时，如果查询到其他人有提交，而且本地的git log没有，说明其他人修改了一些东西，此时不允许提交，只能先pull下来，然后在提交，pull时如果涉及到同一个文件就看上面的解决办法，git stash之后把修改的拉下来，git stash pop应该会出错，因为涉及到同一个文件，不涉及同一个文件就没问题。用的时候在看吧。

- Git有一些工作模式涉及到分支与合并，在Git手册上。以后可以多查看手册。

- 删除远程分支：假设你已经通过远程分支做完所有的工作了——也就是说你和你的协作者已经完成了一个特性， 并且将其合并到了远程仓库的 `master` 分支（或任何其他稳定代码分支）。 可以运行带有 `--delete` 选项的 `git push` 命令来删除一个远程分支。 如果想要从服务器上删除 `serverfix` 分支，运行下面的命令：

  ```shell
   git push origin --delete serverfix
  To https://github.com/schacon/simplegit
   - [deleted]         serverfix
  ```

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
  
    

