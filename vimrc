" ====================
" === Editor Setup ===
" ====================

" ===
" === Auto load for first time uses
" ===
" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
	\| PlugInstall --sync | source $MYVIMRC
	\| endif



" ===
" === System
" ===
"set clipboard=unnamedplus
let &t_ut=''
set autochdir


" ===
" === Editor behavior
" ===
set exrc
set secure
set number
set relativenumber
set cursorline
set hidden
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=2
set autoindent
set list
set listchars=tab:\|\ ,trail:▫
set scrolloff=4
set ttimeoutlen=0
set notimeout
set viewoptions=cursor,folds,slash,unix
set wrap
set tw=0
set indentexpr=
set foldmethod=indent
set foldlevel=99
set foldenable
" Cancel automatic folding
"set foldlevelstart=99

set formatoptions-=tc
set splitright
set splitbelow
set showmode
set showcmd
set wildmenu
set ignorecase
set smartcase
set shortmess+=c
set completeopt=longest,noinsert,menuone,noselect,preview
set ttyfast "should make scrolling faster
set lazyredraw "same as above
set visualbell
silent !mkdir -p $HOME/.vim/tmp/backup
silent !mkdir -p $HOME/.vim/tmp/undo
if has('persistent_undo')
	set undofile
	set undodir=$HOME/.vim/tmp/undo,.
endif
set backupdir=$HOME/.vim/tmp/backup,.
set directory=$HOME/.vim/tmp/backup,.
set colorcolumn=100
set updatetime=100
set virtualedit=block

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


" ===
" === Terminal Behaviors
" ===
tnoremap <C-N> <C-\><C-N>


" ===
" === fold Behaviors
" ===
nnoremap <space> za


" ===
" === Basic Mappings
" ===

" Set <LEADER> as <SPACE>
let mapleader="\<space>"
noremap ; :

" Save & quit
noremap Q :q<CR>
" noremap <C-q> :qa<CR>
noremap S :w<CR>

" Open the vimrc file anytime
noremap <LEADER>rc :e $HOME/.vim/vimrc<CR>

" make Y to copy till the end of the line
nnoremap Y y$

" Copy to system clipboard
vnoremap Y "+y

" Indentation
nnoremap < <<
nnoremap > >>

" Search
noremap <LEADER><CR> :nohlsearch<CR>

" Space to Tab
nnoremap <LEADER>tt :%s/    /\t/g
vnoremap <LEADER>tt :s/    /\t/g


" ===
" === Cursor Movement
" ===
" New cursor movement (the default arrow keys are used for resizing windows)
noremap <silent> \v v$h

" <LEADER>K/J keys for 5 times k/j (faster navigation)
noremap <silent><LEADER>K 5k
noremap <silent><LEADER>J 5j

" N key: go to the start of the line
noremap <silent><LEADER>H 0
" I key: go to the end of the line
noremap <silent><LEADER>L $

" Faster in-line navigation
noremap <silent><LEADER>w 5w
noremap <silent><LEADER>b 5b


" ===
" === Insert Mode Cursor Movement
" ===
inoremap <C-a> <ESC>A


" ===
" === Command Mode Cursor Movement
" ===
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-w> <S-Right>


" ===
" === Window management
" ===
" Use <space> + new arrow keys for moving the cursor around windows
noremap <LEADER>w <C-w>w
noremap <LEADER>k <C-w>k
noremap <LEADER>j <C-w>j
noremap <LEADER>h <C-w>h
noremap <LEADER>l <C-w>l
noremap <LEADER>o <C-w>o

" Disable the default s key
noremap s <nop>

" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
noremap sk :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sj :set splitbelow<CR>:split<CR>
noremap sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sl :set splitright<CR>:vsplit<CR>

" Resize splits with arrow keys
noremap <LEADER><up> :res +5<CR>
noremap <LEADER><down> :res -5<CR>
noremap <LEADER><left> :vertical resize-5<CR>
noremap <LEADER><right> :vertical resize+5<CR>

" Place the two screens up and down
noremap su <C-w>t<C-w>K
" Place the two screens side by side
noremap sn <C-w>t<C-w>H

" Rotate screens
noremap sru <C-w>b<C-w>K
noremap srn <C-w>b<C-w>H

" Press <SPACE> + q to close the window below the current window
noremap <LEADER>q <C-w>j:q<CR>


" ===
" === Tab management
" ===
" Create a new tab with tu
noremap ti :tabe<CR>
noremap tI :tab split<CR>
" Move around tabs with tn and ti
noremap tu :-tabnext<CR>
noremap tn :+tabnext<CR>
" Move the tabs with tmn and tmi
noremap tmu :-tabmove<CR>
noremap tmn :+tabmove<CR>


" ===
" === Other useful stuff
" ===
" find and replace
noremap \s :%s//g<left><left>


" ===
" === Install Plugins with Vim-Plug
" ===

call plug#begin('~/.vim/plugged')

" Auto Complete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

