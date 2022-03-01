
" ====================
" === Editor Setup ===
" ====================
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
set formatoptions-=tc
set splitright
set splitbelow
set showmode
set showcmd
set wildmenu
set ignorecase
set smartcase
set shortmess+=c
" set inccommand=split
set completeopt=longest,noinsert,menuone,noselect,preview
set ttyfast "should make scrolling faster
set lazyredraw "same as above


" ===
" === Terminal Behaviors
" ===
tnoremap <C-N> <C-\><C-N>


" ===
" === Basic Mappings
" ===

" Set <LEADER> as <SPACE>
let mapleader="\<space>"

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


" ===
" === Cursor Movement
" ===
" New cursor movement (the default arrow keys are used for resizing windows)
noremap <silent> \v v$h

" <LEADER>k/j keys for 5 times k/j (faster navigation)
noremap <silent><LEADER>k 5k
noremap <silent><LEADER>j 5j

" N key: go to the start of the line
noremap <silent><LEADER>h 0
" I key: go to the end of the line
noremap <silent><LEADER>l $

" Faster in-line navigation
noremap <silent><LEADER>w 5w
noremap <silent><LEADER>b 5b