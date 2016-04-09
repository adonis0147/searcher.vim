function! searcher#Search(argv)
    let cmd = searcher#cmd#Build(a:argv)
    call searcher#cmd#Run(cmd)
    call searcher#win#Open()
    call searcher#buf#Show()
    call searcher#view#Init()
    call searcher#view#highlight(searcher#opt#GetKeyword())
    call cursor(1, 1)
    call searcher#view#SearchNext()
endfunction

