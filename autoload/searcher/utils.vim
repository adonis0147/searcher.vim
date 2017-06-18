let s:cache_dir = printf('%s/.cache/searcher', $HOME)

function! searcher#utils#Mkdir()
	if !isdirectory(s:cache_dir)
		silent! call mkdir(s:cache_dir, 'p')
	end
	return s:cache_dir
endfunction

function! searcher#utils#GetCacheFile()
	return printf('%s/searcher-%s', s:cache_dir, getpid())
endfunction

function! searcher#utils#FindTargetPos(row, column)
	let filename = searcher#utils#GetFilename(a:row)
	let [line_num, column_num] = searcher#utils#GetPos(a:row, a:column)
	return [filename, line_num, column_num]
endfunction

function! searcher#utils#GetFilename(row)
	let files = searcher#cmd#GetFiles()
	let index = searcher#cmd#GetIndex()
	if a:row <= len(index)
		return files[index[a:row - 1]]
	else
		return ''
	endif
endfunction

function! searcher#utils#GetPos(row, column)
	let line = getline(a:row)
	let line_info = matchstr(line, '^\d\+[:-]')
	let line_num = str2nr(line_info[0:len(line_info) - 1])
	let indent = str2nr(g:searcher_result_indent)
	let column_num = max([a:column - (len(line_info) + indent), 1])
	if line_num != 0
		return [line_num, column_num]
	else
		return [1, 1]
	endif
endfunction
