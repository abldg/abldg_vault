"" coding=utf-8
""==================================----------==================================
"" FILE: 04.csChanger.vim
"" MYPG: abldg, https://github.com/abldg
"" LSCT: 2025-03-08 22:09:14
"" VERS: 0.29
""==================================----------==================================

" Only load this indent file when no other was loaded.
if exists("isLoadedCSChanger")|finish|endif

let isLoadedCSChanger = 1

if !exists("s:cfp")
  let s:cfp = "/usr/local/share/nvim/runtime/colors"
endif

if !exists("s:curCSList")
  let s:curCSList = []
endif

if !exists("s:curIndex")
  let s:curIndex = -1
endif

if !exists("s:hasInitCSList")
  let s:hasInitCSList = 0 "false
endif

function! CheckColorScheme(scheme_name)
  "if a:scheme_name == "solarized"
  "  execute 'set background=dark'
  "endif
  execute 'let g:solarized_termcolors=256'
endfunction

function! InitCSList(cfp)
  let path_list = split(globpath(a:cfp, '*.vim', "\n"))
  let s:curCSList = map(path_list, 'fnamemodify(v:val, ":t:r")')
  let s:curListLen=len(s:curCSList)
endfunction

function! LoadColorScheme(n)
  if !s:hasInitCSList
    call InitCSList(s:cfp)
    if s:curListLen == 0
      call InitCSList($VIMRUNTIME/colors)
    endif
    let s:hasInitCSList = 1 "true
    let s:curIndex = localtime() % s:curListLen
  endif

  if a:n == 0 "random
    let s:curIndex = localtime() % s:curListLen
  elseif a:n == -1 "prev
    let s:curIndex -= 1
  else "if a:n == 1 next
    let s:curIndex += 1
  endif

  if (s:curIndex <= 0 || s:curIndex + 1 >= s:curListLen )
    let s:curIndex = localtime() % s:curListLen
  endif
  call CheckColorScheme(s:curCSList[s:curIndex])
  execute 'colorscheme ' . s:curCSList[s:curIndex]
endfunction

"set hotkey change-colorscheme
map  <silent><F7>  :colorscheme<cr>
map  <silent><F8>  :call LoadColorScheme(-1)<cr>
map  <silent><F9>  :call LoadColorScheme(1)<cr>
map  <silent><F10> :call LoadColorScheme(0)<cr>
imap <silent><F7>  <esc>:colorscheme<cr>
imap <silent><F8>  <esc>:call LoadColorScheme(-1)<cr>
imap <silent><F9>  <esc>:call LoadColorScheme(1)<cr>
imap <silent><F10> <esc>:call LoadColorScheme(0)<cr>

