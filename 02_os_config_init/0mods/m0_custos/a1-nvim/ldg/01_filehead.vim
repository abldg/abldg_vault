"" coding=utf-8
""==================================----------==================================
"" FILE: 01_filehead.vim
"" MYPG: abldg, https://github.com/abldg
"" LSCT: 2025-03-08 22:09:14
"" VERS: 0.29
""==================================----------==================================
if exists('g:loaded_abfheader') | finish | endif
let g:loaded_abfheader= 1
let s:inver='0.1'
let s:myurl='abldg, https://github.com/abldg'
let s:tsfmt='%F %T'

function! s:getFT()
	let lft=&ft
  if lft == '' | let lft=expand('%:e') | endif
  if lft == 'sh' | let lft='bash' | endif
  return lft
endfunction

function! s:getCC()
  let lft=s:getFT()
  if -1 != index(split('vim vimrc _vimrc .vimrc'),lft)
    return '""'
  elseif -1 != index(split('c h cpp rust ts js java go hxx hpp rs'),lft)
    return '//'
  elseif -1 != index(split('sql sqlx lua'),lft)
    return '--'
  else  " # sh bash python ini cfg
    return '##'
  endif
endfunction

function! s:chkHdr()
  let t=12
  if line('$') < t | let t=line('$') | endif
  for lnx in getline(1,t)
    if ( lnx =~# 'LSCT' ) | return 1 | endif
  endfor
  return 0
endfunction

function! s:newHdr()
  if 1 == s:chkHdr() | return | endif
  let lhls=[]
  let lft=s:getFT()
  let lc=s:getCC()
  if ( lft == 'lua' || lft == 'python' || lft == 'bash' || lft =~ 'sh' )
    call add(lhls, '#!/usr/bin/env '.lft)
  endif
  let lsplt='=================================='
  call append(0,[lc.' coding=utf-8'
    \,l:lc.lsplt.'----------'.lsplt
    \,l:lc.' FILE: '.expand('%:t')
    \,l:lc.' MYPG: '.s:myurl
    \,l:lc.' LSCT: '.strftime(s:tsfmt)
    \,l:lc.' VERS: '.s:inver
    \,l:lc.lsplt.'----------'.lsplt])
  if len(lhls) > 0 | call append(0,lhls) | endif
  exec 'normal <c-o>'
endfunction

function! AbUpdateHdr()
  if 0 == s:chkHdr() | call s:newHdr() | return| endif
  let n=1
  let t=15
  let lc=s:getCC()
  if line('$') <= 15 | let t=line('$') | endif
  while n <= t
    let ctx=getline(n)
    if ctx =~# "FILE: "
      let ctx=l:lc.' FILE: '.expand('%:t')
    elseif ctx =~# "MYPG: " || ctx =~# "WURL: "
      let ctx=l:lc.' MYPG: '.s:myurl
    elseif ctx =~# "LSCT: "
      let ctx=l:lc.' LSCT: '.strftime(s:tsfmt)
    elseif ctx =~# "VERS: "
      let nLDP=strridx(ctx,'.')+1
      let bLDP=strpart(ctx,0,nLDP)
      let nv=str2nr(strpart(ctx,nLDP))+1
      let ctx=bLDP.nv
    endif
    call setline(n,ctx)
    let n+=1
  endwhile
endfunction

" Short-Keys
noremap  <silent><leader>ff :call AbUpdateHdr()<cr>
