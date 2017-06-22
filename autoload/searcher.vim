function! searcher#Search(argv)
	call searcher#cmd#Stop()
	let cmd = searcher#cmd#Build(a:argv)
	call searcher#win#Open()
	call searcher#cmd#Run(cmd)
	call searcher#view#highlight(searcher#cmd#GetKeyword())
endfunction
