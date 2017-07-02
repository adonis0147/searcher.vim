function! searcher#log#Debug(format, ...)
	if g:searcher_debug
		let argv = join(map(copy(a:000), 'string(v:val)'), ',')
		execute 'let msg = printf(a:format, ' . argv . ')'
		echom printf('%s - searcher.vim - Debug - %s', strftime('%Y-%m-%d %H:%M:%S'), msg)
	endif
endfunction
