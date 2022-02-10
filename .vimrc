"===
"===System
"===
"关闭vi兼容模式
set nocompatible
"打开文件类型检测与根据不同类型文件加载不同插件
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
"设置vim中应用鼠标
set mouse=a
set encoding=utf-8
"设置vim剪切板与系统剪切板可以通用
set clipboard=unnamed


" Prevent incorrect backgroung rendering
"let &t_ut=''

"===
"===Main code dispaly
"===
set number
set ruler
set cursorline
syntax enable
syntax on

"===
"===Editor behavior
"===
"Better tab
"将tab自动设置为存储空格
set expandtab
set tabstop=4
"tab宽度设置
set shiftwidth=4
set softtabstop=4
"显示非可见字符，如行尾的空格，tab
set list
"设置非可见字符的显示形式
set listchars=tab:▸\ ,trail:▫
"设置文件阅览时当前行与屏幕顶端与底端的距离，防止在最后一行
set scrolloff=20

"Prevent auto line split
"设置自动换行
set wrap
set tw=0
"Better backspace
set backspace=indent,eol,start
"设置文件折叠方式，相同缩进的文件被折叠
set foldmethod=indent
set foldlevel=99


"===
"===Window behaviors
"===
"设置分屏时光标所在位置
set splitright
set splitbelow


"===
"===Status/command bar
"===
"总是显示状态栏
set laststatus=2
set autochdir
"设置显示命令
set showcmd

"Show command autocomplete
set wildmenu
"设置自动忽略的匹配的文件类型
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmode=full
"Searching options
set hlsearch
exec "nohlsearch"
set incsearch
set ignorecase
set smartcase


"===
"===Restore Cursor Position
"===
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"===
"===Basic Mappings
"===

"Set <leader> as <space>
let mapleader=" "
"使用不同的map可以在不同的模式下映射，map下的映射在插入模式下不受影响
map ; :
map q; q:
"!命令用来暂时离开vim到终端执行command的显示结果，例如rls，此时将在shell中显示
map <Leader>/ :!
"r在当前位置插入另一个文件的内容，r！可以将shell命令的输出插入当前文档
map <Leader>r :r !
map <Leader>sr :%s/

"save & quit
map Q :q<CR>
map S :w<CR>

"open the vimrc file anytime
map <Leader>rc :e ~/.vimrc<CR>

"copy to system clipboard
vnoremap Y :w !xclip -i -sel c<CR>

"search
map <Leader><CR> :nohlsearch<CR>

map fi :tabe<CR>
map fj :-tabnext<CR>
map fl :+tabnext<CR>


"===
"===Window management
"===
"Use <space> + new arrow keys for moving the cursor around windows
map <LEADER>w <C-w>w
map <LEADER>i <C-w>k
map <LEADER>k <C-w>j
map <LEADER>j <C-w>h
map <LEADER>l <C-w>l

"split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
map si :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
map sk :set splitbelow<CR>:split<CR>
map sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
map sl :set splitright<CR>:vsplit<CR>

" Resize splits with arrow keys,map下的定义不影响插入模式下
nmap <LEADER><up> :res -5<CR>
nmap <LEADER><down> :res +5<CR>
nmap <LEADER><left> :vertical resize-5<CR>
nmap <LEADER><right> :vertical resize+5<CR>

" Place the two screens up and down
noremap su <C-w>t<C-w>K
" Place the two screens side by side
noremap sn <C-w>t<C-w>H

" Compile function
map r :call CompileRunGcc()<CR>
"使用！来强制重定义同名函数
func! CompileRunGcc()
  exec "w"
  if &filetype == 'c'
"缓冲区是一块内存区域(Buffer)，用于存储着正在编辑的文件，%表示当前缓冲区，用于指示当前缓冲区的名字即文件的名字
    exec "!g++ % -o %<"
"%<表示没有后缀的文件名,即将1.cpp后面的后缀名去掉
    exec "!time ./%<"
  elseif &filetype == 'cpp'
    exec "!g++ % -o %<"
    exec "!time ./%<"
  elseif &filetype == 'java'
    exec "!javac %"
    exec "!time java %<"
  elseif &filetype == 'sh'
    :!time bash %
  elseif &filetype == 'python'
    silent! exec "!clear"
    exec "!time python3 %"
  elseif &filetype == 'html'
    exec "!firefox % &"
  elseif &filetype == 'markdown'
    exec "MarkdownPreview"
  elseif &filetype == 'vimwiki'
    exec "MarkdownPreview"
  endif
endfunc

noremap R :call CompileBuildrrr()<CR>
func! CompileBuildrrr()
  exec "w"
  if &filetype == '.vimrc'
    exec "source $MYVIMRC"
  elseif &filetype == 'markdown'
    exec "echo"
  endif
endfunc


"===
"===Install Plugins with vim-plug
"===
call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'tpope/vim-surround'
Plug 'gcmt/wildfire.vim'
call plug#end()
colorscheme molokai

"nerdtree 配置
map ff :NERDTreeToggle<CR>


"===
"===coc.nvim setting
"===
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
