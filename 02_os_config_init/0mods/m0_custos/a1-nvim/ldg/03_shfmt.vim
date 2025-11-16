"" coding=utf-8
""==================================----------==================================
"" FILE: 03_shfmt.vim
"" MYPG: abldg, https://github.com/abldg
"" LSCT: 2025-03-08 22:09:14
"" VERS: 0.29
""==================================----------==================================

if exists('g:loaded_vimshfmt') || &cp || !executable('shfmt')
	finish
endif
let g:loaded_vimshfmt = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:shfmt_fmt_on_save')
	let g:shfmt_fmt_on_save = 0
endif

if !exists('g:shfmt_cmd')
	let g:shfmt_cmd = 'shfmt'
endif

" Options
if !exists('g:shfmt_extra_args')
	let g:shfmt_extra_args = '-i 4'
endif

let s:shfmt_switches = ['-p', '-i', '-bn', '-ci', '-ln', '-s']

function! s:ShfmtSwitches(...)
	return join(s:shfmt_switches, "\n")
endfunction

function! s:Shfmt(current_args)
	let l:extra_args = g:shfmt_extra_args
	let l:filename = @%
	let l:shfmt_cmd = g:shfmt_cmd
	let l:shfmt_opts = ' ' . a:current_args . ' ' . l:extra_args
	if a:current_args != ''
		let l:shfmt_opts = a:current_args
	endif
	let l:cursor_position = getcurpos()
	silent execute  "%!" . l:shfmt_cmd . ' ' . l:shfmt_opts
	if v:shell_error
		execute 'echom "shfmt returned an error, undoing changes. Often a syntax error, so check that."'
		" undo the buffer overwrite because shfmt returns no data on error, so we've erased the
		" user's work!
		undo
	endif
	" Reset the cursor position if we moved
	if l:cursor_position != getcurpos()
		call setpos('.', l:cursor_position)
	endif
endfunction

augroup Shfmt
	autocmd!
	if get(g:, 'shfmt_fmt_on_save', 1)
		" Use BufWritePre to filter the file before it's written since we're
		" processing current buffer instead of the saved file.
		autocmd BufWritePre *.sh Shfmt
		autocmd FileType sh autocmd BufWritePre <buffer> Shfmt
	endif
augroup END

command! -complete=custom,s:ShfmtSwitches -nargs=? Shfmt :call <SID>Shfmt(<q-args>)

let &cpo = s:save_cpo

"vim: set ft=vim ts=4 sts=4 sw=4 tw=78 et :

