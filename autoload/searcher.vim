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

function! searcher#View()
	let keyword = searcher#cmd#GetKeyword()
	if keyword != ''
		call searcher#view#Highlight(keyword)
	endif
endfunction

autocmd FileType searcher call searcher#View()
