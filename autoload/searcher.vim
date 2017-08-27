function! searcher#Search(argv)
	call searcher#cmd#Stop()
	let cmd = searcher#cmd#Build(a:argv)
	call searcher#win#Open()
	call searcher#cmd#Run(cmd)
	call searcher#view#Highlight(searcher#cmd#GetKeyword())
endfunction

function! searcher#Stop()
	call searcher#cmd#Stop()
	execute 'silent checktime'
endfunction

function! searcher#ClearAllCaches()
python << EOF
cache_dir = vim.eval('searcher#utils#Mkdir()')
for filename in os.listdir(cache_dir):
	filename = '%s/%s' % (cache_dir, filename)
	if os.path.isdir(filename):
		shutil.rmtree(filename)
	else:
		os.remove(filename)
EOF
endfunction

function! searcher#View()
	call searcher#win#SetWinId(win_getid())
	let keyword = searcher#cmd#GetKeyword()
	if keyword != ''
		call searcher#view#Highlight(keyword)
	endif
	autocmd QuitPre <buffer> :call searcher#win#SetCallerWinId(0)
endfunction

autocmd FileType searcher call searcher#View()
