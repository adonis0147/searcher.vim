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
	\ }
let s:is_toggled = 0
let s:last_line = 1
let s:last_column = 1

function! searcher#win#Open()
	if win_getid() != s:win_id
		let s:caller_win_id = win_getid()
	endif
	if isdirectory(searcher#utils#Mkdir())
		let cache_file = searcher#utils#GetCacheFile()
		let nr = bufwinnr(cache_file)
		if nr < 0
			execute printf('silent keepalt topleft vertical split %s', searcher#utils#GetCacheFile())
			call searcher#win#Init()
		else
			execute printf('%dwincmd w', nr)
			setlocal modifiable
		endif
		setlocal noreadonly
		execute 'silent %delete'
		execute 'silent write'
		setlocal nomodifiable
		execute 'clearjumps'
		let s:win_id = win_getid()
		let s:is_toggled = 1
		let [s:last_line, s:last_column] = [1, 1]
	endif
endfunction

function! searcher#win#Init()
	setlocal modifiable
	setlocal filetype=searcher
	setlocal nonumber
	setlocal nolist
	setlocal autoread
	call searcher#win#SetMappings()
	autocmd! BufLeave <buffer> :call searcher#win#Leave()
endfunction

function! searcher#win#SetMappings()
	for [operate, hotkeys] in items(g:searcher_mappings)
		for hotkey in hotkeys
			execute printf('nnoremap <silent><buffer> %s :call searcher#win#JumpToBy("%s")<CR>', hotkey, operate)
		endfor
	endfor
	execute 'nnoremap <silent><buffer> q :SearcherToggle<CR>'
endfunction

function! searcher#win#Leave()
	let [s:last_line, s:last_column] = [line('.'), col('.')]
endfunction

function! searcher#win#Quit()
	call searcher#win#SetCallerWinId(0)
	call searcher#win#Toggle()
endfunction

function! searcher#win#JumpToBy(way)
	let [filename, line_num, column_num] = searcher#utils#FindTargetPos(line('.'), col('.'))
	if win_id2win(s:caller_win_id) == 0
		if a:way == 'tab'
			call searcher#win#JumpToTab(filename, line_num, column_num)
		elseif a:way == 'tabs'
			call searcher#win#JumpToTabSilently(filename, line_num, column_num)
		else
			execute 'silent keepalt rightbelow vertical split'
			let s:caller_win_id = win_getid()
			call searcher#win#JumpToFile(filename, line_num, column_num)
			execute 'clearjumps'
			if a:way =~ '.\+s$'
				execute printf('call win_gotoid(%d)', s:win_id)
			endif
		endif
	else
		if a:way !~ 'vsplit'
			call win_gotoid(s:caller_win_id)
		endif
		let func = s:operation_mappings[a:way]
		execute printf('call %s(filename, line_num, column_num)', func)
	endif

	if a:way !~ '.\+s$' && g:searcher_auto_close == 1
		call searcher#win#Toggle()
	endif
endfunction

function! searcher#win#JumpToTab(filename, line_num, column_num)
	execute printf('silent tabedit %s', fnameescape(a:filename))
	call cursor(a:line_num, a:column_num)
	execute 'clearjumps'
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
	execute 'clearjumps'
endfunction

function! searcher#win#JumpToSplitSilently(filename, line_num, column_num)
	call searcher#win#JumpToSplit(a:filename, a:line_num, a:column_num)
	execute printf('call win_gotoid(%d)', s:win_id)
endfunction

function! searcher#win#JumpToVSplit(filename, line_num, column_num)
	execute printf('silent rightbelow vertical split %s', fnameescape(a:filename))
	call cursor(a:line_num, a:column_num)
	execute 'clearjumps'
endfunction

function! searcher#win#JumpToVSplitSilently(filename, line_num, column_num)
	call searcher#win#JumpToVSplit(a:filename, a:line_num, a:column_num)
	execute printf('call win_gotoid(%d)', s:win_id)
endfunction

function! searcher#win#Toggle()
	if s:is_toggled == 1
		execute printf('bdelete %s', searcher#utils#GetCacheFile())
		let s:is_toggled = 0
	else
		let s:caller_win_id = win_getid()
		execute printf('silent keepalt topleft vertical split %s', searcher#utils#GetCacheFile())
		call searcher#win#Init()
		setlocal nomodifiable
		let s:win_id = win_getid()
		let s:is_toggled = 1
		call cursor(s:last_line, s:last_column)
	endif
endfunction

function! searcher#win#SetWinId(win_id)
	let s:win_id = a:win_id
endfunction

function! searcher#win#SetCallerWinId(caller_win_id)
	let s:caller_win_id = a:caller_win_id
endfunction
