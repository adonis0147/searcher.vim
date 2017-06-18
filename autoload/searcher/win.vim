let s:win_id = 0
let s:caller_win_id = 0
let s:operation_mappings = {
	\ 'open'    : 'searcher#win#JumpToFile',
	\ 'opens'   : 'searcher#win#JumpToFileSilently',
	\ 'tab'     : 'searcher#win#JumpToTab',
	\ 'tabs'    : 'searcher#win#JumpToTabSilently',
	\ 'split'   : 'searcher#win#JumpToSplit',
	\ 'splits'  : 'searcher#win#JumpToSplitSilently',
	\ 'vsplit'  : 'searcher#win#JumpToVSplit',
	\ 'vsplits' : 'searcher#win#JumpToVSplitSilently',
	\}

function! searcher#win#Open()
	let s:caller_win_id = win_getid()
	if isdirectory(searcher#utils#Mkdir())
		let cache_file = searcher#utils#GetCacheFile()
		let nr = bufwinnr(cache_file)
		if nr < 0
			execute printf('silent keepalt topleft vertical split %s', searcher#utils#GetCacheFile())
			call searcher#win#Init()
		else
			execute printf('%dwincmd w', nr)
		endif
		execute 'silent %delete'
		execute 'silent write'
		setlocal nomodifiable
		let s:win_id = win_getid()
	endif
endfunction

function! searcher#win#Init()
	setlocal modifiable
	setlocal filetype=searcher
	setlocal fileencoding=utf-8
	setlocal nonumber
	setlocal nolist
	setlocal autoread
	call searcher#win#SetMappings()
endfunction

function! searcher#win#SetMappings()
	for [operate, hotkeys] in items(g:searcher_mappings)
		for hotkey in hotkeys
			execute printf('nnoremap <silent><buffer> %s :call searcher#win#JumpToBy("%s")<CR>', hotkey, operate)
		endfor
	endfor
endfunction

function! searcher#win#Update(timer)
	let job = searcher#cmd#GetJob()
	if job == '' || job_status(job) != 'run'
		call timer_stop(a:timer)
	endif
	execute 'silent checktime'
endfunction

function! searcher#win#JumpToBy(way)
	let [filename, line_num, column_num] = searcher#utils#FindTargetPos(line('.'), col('.'))
	if winnr() == winnr('$')
		if a:way == 'tab'
			call searcher#win#JumpToTab(filename, line_num, column_num)
		elseif a:way == 'tabs'
			call searcher#win#JumpToTabSilently(filename, line_num, column_num)
		else
			execute 'silent keepalt botright vertical split'
			if a:way !~ '.\+s$'
				call searcher#win#JumpToFile(filename, line_num, column_num)
			else
				call searcher#win#JumpToFileSilently(filename, line_num, column_num)
			endif
		endif
	else
		call win_gotoid(s:caller_win_id)
		let func = s:operation_mappings[a:way]
		execute printf('call %s(filename, line_num, column_num)', func)
	endif
endfunction

function! searcher#win#JumpToTab(filename, line_num, column_num)
	execute printf('silent tabedit %s', fnameescape(a:filename))
	call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToTabSilently(filename, line_num, column_num)
	call searcher#win#JumpToTab(a:filename, a:line_num, a:column_num)
	execute 'tabprevious'
	execute printf('call win_gotoid(%d)', s:win_id)
endfunction

function! searcher#win#JumpToFile(filename, line_num, column_num)
	execute printf('silent edit %s', fnameescape(a:filename))
	call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToFileSilently(filename, line_num, column_num)
	call searcher#win#JumpToFile(a:filename, a:line_num, a:column_num)
	execute printf('call win_gotoid(%d)', s:win_id)
endfunction

function! searcher#win#JumpToSplit(filename, line_num, column_num)
	execute printf('silent split %s', fnameescape(a:filename))
	call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToSplitSilently(filename, line_num, column_num)
	call searcher#win#JumpToSplit(a:filename, a:line_num, a:column_num)
	execute printf('call win_gotoid(%d)', s:win_id)
endfunction

function! searcher#win#JumpToVSplit(filename, line_num, column_num)
	execute printf('silent vsplit %s', fnameescape(a:filename))
	call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToVSplitSilently(filename, line_num, column_num)
	call searcher#win#JumpToVSplit(a:filename, a:line_num, a:column_num)
	execute printf('call win_gotoid(%d)', s:win_id)
endfunction
