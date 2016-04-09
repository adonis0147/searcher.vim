let s:text = ''
let s:files = []
let s:index = {}

function! searcher#buf#Init(text, files, index)
    let s:text = a:text
    let s:files = a:files
    let s:index = a:index
endfunction

function! searcher#buf#GetText()
    return s:text
endfunction

function! searcher#buf#GetFiles()
    return s:files
endfunction

function! searcher#buf#GetIndex()
    return s:index
endfunction

function! searcher#buf#Show()
    setlocal modifiable
    call searcher#buf#WriteText()
    call searcher#buf#ClearUndoHistory()
    setlocal nomodifiable
    call setbufvar('%', '&modified', 0)
endfunction

function! searcher#buf#WriteText()
    silent %delete _
    silent 0put = s:text
    silent $delete _ " delete trailing empty line
endfunction

function! searcher#buf#ClearUndoHistory()
	let old_undolevels = &undolevels
	set undolevels=-1
	execute "normal a \<BS>\<Esc>"
	let &undolevels = old_undolevels
	unlet old_undolevels
endfunction

