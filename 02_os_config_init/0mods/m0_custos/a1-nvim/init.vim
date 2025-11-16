"" coding=utf-8
""==================================----------==================================
"" FILE: init.vim
"" MYPG: abldg, https://github.com/abldg
"" LSCT: 2025-03-09 22:50:01
"" VERS: 0.1
""==================================----------==================================
set nocompatible
syntax on
" solarized options
colorscheme industry

set background=dark
set laststatus=2

set noshowmode
hi Normal guibg=NONE ctermbg=NONE

set t_Co=256
if has("termguicolors")
  set t_8f=[38;2;%lu;%lu;%lum
  set t_8b=[48;2;%lu;%lu;%lum
  " enable true color
  set termguicolors
endif
"if has("guifont") | set guifont=Fira\ Code:h14 | endif

filetype off  "/*<<<! required!
filetype plugin indent on     "/*<<<! required!
filetype plugin on
let g:leader=';'
let g:mapleader=';'
"let g:email='developer@ljjx.com'

inoremap jg <Esc>

" 设定文件浏览器目录为当前目录
"set bsdir=buffer
" 设置编码
set fenc=utf-8
set encoding=utf-8
set nocompatible

set laststatus=2
set noshowmode

"set to use clipboard of system
set clipboard=unnamed

" 设置文件编码检测类型及支持格式
set fencs=utf-8,gb18030,gbk

"显示行号
set number
"Show related row numbers
set rnu "relativenumber
set cul "current line

"settings for backspace
set backspace=2
set backspace=indent,eol,start

"忽略大小写查找
set ic

" tab宽度
set et
set tabstop=2 softtabstop=2
set cindent shiftwidth=2
set autoindent shiftwidth=2

" set 折叠
set foldmethod=indent
" 打开文件默认不折叠
set foldlevelstart=99

"Disable highlight
nnoremap <leader><leader>h :nohl<cr>
nnoremap <leader><leader>n :set number!<cr>
nnoremap <leader><leader>r :set rnu!<cr>
nnoremap <leader><leader>l :set list!<cr>
nnoremap <leader><leader>c :set cul!<cr>

"[Wrapped lines goes down/up to next row]
noremap j gj
noremap k gk
vnoremap < <gv
vnoremap > >gv

"[Adjust viewports to the same size]
map <leader>= <c-w>=
"[Easier horizontal scrolling]
map zl zL
map zh zH
"Easier formatting]
nnoremap <silent> <leader>q gwip

"[Jumpings]
noremap <leader>lb 0
noremap <leader>le $
noremap <leader>pa %

"[Copy and paste]
vnoremap <leader>y "+y
noremap  <leader>p "+p
nnoremap Y y$

"[Windows Operations]
noremap  <leader>w :w<cr>
noremap  <leader>q :q<cr>
noremap  <leader>W :wqa!<cr>
noremap  <leader>Q :qa!<cr>

" 设置快捷键遍历子窗口
nnoremap nw <C-W><C-W>        " 依次遍历
nnoremap <Leader>lw <C-W>l    " 跳转至右方的窗口
nnoremap <Leader>hw <C-W>h    " 跳转至左方的窗口
nnoremap <Leader>kw <C-W>k    " 跳转至上方的子窗口
nnoremap <Leader>jw <C-W>j    " 跳转至下方的子窗口

"[Remove blank lines]
map <leader>rbl :sil! g/^\n\+$/d<cr>
"[Remove trail-whitespaces]
map <leader>rtw :sil! %s/\s\+$//g<cr>
nnoremap <Leader>q :q<CR>         " 定义快捷键关闭当前分割窗口
nnoremap <Leader>w :w<CR>         " 定义快捷键保存当前窗口内容
nnoremap <Leader>aq :wa<CR>:q<CR> " 定义快捷键保存所有窗口内容并退出 vim
nnoremap <Leader>qa :qa!<CR>       " 不做任何保存，直接退出 vim

nmap <Leader>bn :bnext<CR>
nmap <Leader>bp :bprevious<CR>

"[Override F1 mapping]
map <silent><F1> <esc>:exec "help ".expand("<cword>")<cr>
map <silent><F3> <esc>:set ft=bash<cr>

"[For Shell script file]
"set pastetoggle=<F2>    " pastetoggle (sane indentation on pastes)
map <silent><leader>u :set nu!<cr>
map <silent><leader>r :set rnu!<cr>

" coc settings
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.jpg,*.png,*.gif,*.jpeg,.DS_Store
set wildignore+=*/tmp/*,*\\tmp\\*  " Windows

" settings for resize splitted window
nmap w[ :vertical resize -3<CR>
nmap w] :vertical resize +3<CR>

nmap w- :resize -3<CR>
nmap w= :resize +3<CR>

" search word under cursor
noremap <Leader>s :Rg <cword><cr>

set mouse= "disable the mouse
set autowrite autoread  "Automatically write/read a file
set shortmess +=atI
set nobk noswf nowarn bh=delete
if !exists('g:abAutoSwitchCwd')
 au BufEnter * if (bufname("") !~ "^\[A-Za-z0-9\]*://" )| lcd %:p:h | endif
endif

if !exists('g:abRestoreCursor')
  func! AbResCur()
    if line("'\"") <= line('$')
      normal! g`"
      return 1
    endif
  endfunc
  augroup abresCur
    au!
    au BufWinEnter * call AbResCur()
  augroup END
endif

"[FileType Extends]
au BufRead,BufNewFile _vim,.vim set ft=vim et ts=4 sts=4
au BufRead,BufNewFile [Mm]ake[Ff]ile,mk_* set ft=make noet ts=2 sts=2
au InsertEnter * set cul "cuc
au InsertLeave * set nocul "nocuc

" AutoGroups
augroup configgroup
  autocmd!
"  autocmd BufEnter *.cls setlocal filetype=java
"  autocmd BufEnter *.avsc setlocal ft=json
"  autocmd BufEnter *.zsh-theme setlocal filetype=zsh
  autocmd BufEnter *.go,*.mk,Makefile setlocal noet ts=2 sts=2 tw=120
  autocmd BufEnter *.sh,*.py,*.lua setlocal ts=2 sts=2 tw=120
augroup END

for f in split(glob('~/.config/nvim/ldg/*.vim'), '\n')
  exe 'source' f
endfor
