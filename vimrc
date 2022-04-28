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
set encoding=utf-8


" ===
" === Editor behavior
" ===
set exrc
set secure
set number
set hlsearch
set relativenumber
set cursorline
set hidden
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
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
set wildmode=list:longest,full
set ignorecase
set smartcase
set shortmess+=c
set completeopt=longest,noinsert,menuone,noselect,preview
set ttyfast "should make scrolling faster
set lazyredraw "same as above
"set visualbell
silent !mkdir -p $HOME/.vim/tmp/backup
silent !mkdir -p $HOME/.vim/tmp/undo
if has('persistent_undo')
    set undofile
    set undodir=$HOME/.vim/tmp/undo,.
endif
set backupdir=$HOME/.vim/tmp/backup,.
set directory=$HOME/.vim/tmp/backup,.
" set colorcolumn=100
set updatetime=100
set virtualedit=block
" tag file set
set tags=./.tags;,.tags

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif




" ===
" === Terminal Behaviors
" ===
tnoremap <C-N> <C-\><C-N>
noremap \t :vertical term<CR>

" ===
" === fold Behaviors
" ===
nnoremap <LEADER><LEADER> za


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

" tags set
" jump directly
" ctrl + ] jump
noremap s] <C-w>]   " new window jump

" jump after select use in multiple options
" g] preview multiple under the screen after select in this window
noremap <LEADER>] <C-w>g] " preview multiple under the screen after select jump to new window
noremap <LEADER>tj :tnext<CR>
noremap <LEADER>tk :tprevious<CR>
noremap <LEADER>t, :tfirst<CR>
noremap <LEADER>t. :tlast<CR>

" display the definition of the lable in the preview window
" show definition directly
" QuickFix
noremap s[ <C-w>}
" show definition after select use in multiple options
noremap <LEADER>[ <C-w>g} 
noremap <LEADER>xj :ptnext<CR>
noremap <LEADER>xk :ptprevious<CR>
noremap <LEADER>x, :ptfirst<CR>
noremap <LEADER>x. :ptlast<CR>
noremap <LEADER>xn <C-w>z   " close preview window

" ===
" === Cursor Movement
" ===
" New cursor movement (the default arrow keys are used for resizing windows)
noremap <silent> \v v$h

" <LEADER>K/J keys for 5 times k/j (faster navigation)
noremap <silent> K 5k
noremap <silent> J 5j

" go to the start of the line
noremap <silent><LEADER>, 0
" go to the end of the line
noremap <silent><LEADER>. $

" Faster in-line navigation
noremap <silent> W 5w
noremap <silent> B 5b


" ===
" === Insert Mode Cursor Movement
" ===
inoremap <silent><C-e> <c-r>=execute('norm! e')<cr>
inoremap <silent><C-h> <c-r>=execute('norm! h')<cr>
inoremap <silent><C-l> <c-r>=execute('norm! l')<cr>
inoremap <silent><C-j> <c-r>=execute('norm! j')<cr>
inoremap <silent><C-k> <c-r>=execute('norm! k')<cr>
inoremap <silent><C-a> <ESC>A

" new line after this current line
inoremap <silent><C-n> <c-r>=execute('norm! o')<cr>



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
" new window
noremap <LEADER>n :vnew<CR>


" Disable the default s key
noremap s <nop>

" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
noremap sk :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sj :set splitbelow<CR>:split<CR>
noremap sh :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sl :set splitright<CR>:vsplit<CR>

" Resize splits with arrow keys
noremap <LEADER><up> :res -5<CR>
noremap <LEADER><down> :res +5<CR>
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
noremap tj :-tabnext<CR>
noremap tk :+tabnext<CR>
" Move the tabs with tmn and tmi
noremap th :-tabmove<CR>
noremap tl :+tabmove<CR>


" ===
" === Buffers management
" ===
noremap <LEADER>d :bdelete %<CR>
noremap bb :buffers<CR>
noremap bj :bnext<CR>
noremap bk :bprevious<CR>
noremap b, :bfirst<CR>
noremap b. :blast<CR>

" select buffer
noremap \b :Buffers<CR>

" new windows form buffers
noremap <LEADER>vb :vertical ball<CR>

" close all buffers except the current buffer
noremap bo :%bd \| e# \| bd#<CR>


" ===
" === Other useful stuff
" ===
" find and replace
noremap \s :%s//g<left><left>

" select file
noremap \f :Files<CR>

" rg(ripgrep) search result
noremap \r :Rg<CR>


" ===
" === Install Plugins with Vim-Plug
" ===

call plug#begin('~/.vim/plugged')

" Auto Complete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'


" Editor Enhancement
Plug 'tpope/vim-surround'

" Status line & navigation
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'

" Taglist
Plug 'liuchengxu/vista.vim'

" colors
Plug 'tomasr/molokai'
Plug 'morhetz/gruvbox'

" For general writing
Plug 'junegunn/goyo.vim'

" comment
Plug 'preservim/nerdcommenter'

" undo tree
Plug 'mbbill/undotree'

" snippets
Plug 'honza/vim-snippets'

" Editor Enhancement
" This plugin conflicts with <C-> in inoremap, inoremap all changed to <M->
Plug 'jiangmiao/auto-pairs'

call plug#end()

" ===
" === colors
" ===
set background=dark
" colorscheme molokai
colorscheme gruvbox

" ===
" === coc.nvim
" ===
let g:coc_global_extensions = [
        \ 'coc-marketplace',
        \ 'coc-cmake',
        \ 'coc-docker',
        \ 'coc-diagnostic',
        \ 'coc-pyright',
        \ 'coc-snippets',
        \ 'coc-xml',
        \ 'coc-sh',
        \ 'coc-json',
        \ 'coc-vimlsp',
		\ 'coc-clangd']
		
" <tab>
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-r> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use `<LEADER>-` and `<LEADER>=` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <LEADER>- <Plug>(coc-diagnostic-prev)
nmap <silent> <LEADER>= <Plug>(coc-diagnostic-next)

" Use <LEADER>H to show documentation in preview window.
nnoremap <silent> <LEADER>H :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Switch between source/header
noremap hc :CocCommand clangd.switchSourceHeader<CR>

" coc-snippets
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'


" ===
" === nerdtree
" ===
nnoremap tt :NERDTreeToggle<CR>



" ===
" === goyo
" ===
nnoremap gy :Goyo<CR>


" ===
" === vista.vim
" ===
noremap <LEADER>v :Vista!!<CR>
let g:vista_default_executive = 'coc'
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]
let g:vista_fzf_preview = ['right:50%']
let g:vista#renderer#enable_icon = 1
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }


" ===
" === nerdcommenter
" ===
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1


" [count]<leader>cc |NERDCommenterComment|
" [count]<leader>cu |NERDCommenterUncomment|
" [count]<leader>cs |NERDCommenterSexy|
" [count]<leader>c<space> |NERDCommenterToggle|
" [count]<leader>cm |NERDCommenterMinimal|


" ===
" === undotree 
" ===
" The current state is marked as > number <.
" The next state which will be restored by :redo or <ctrl-r> is marked as { number }
" The [ number ] marks the most recent change.
" Saved changes are marked as s and the big S indicates the most recent saved change.
nnoremap <LEADER>ut :UndotreeToggle<CR>
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SplitWidth = 24
let g:undotree_DiffAutoOpen = 1
let g:undotree_DiffpanelHeight = 8
let g:undotree_SetFocusWhenToggle = 1
