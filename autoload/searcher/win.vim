let s:MAIN_BUF_NAME = '__searcher__'
let s:caller_buf_name = ''
autocmd BufEnter,BufLeave * execute 'call searcher#win#AutoCloseHiddensearcherBuf()'

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

function! searcher#win#SetCallerBufName(buf_name)
    let s:caller_buf_name = a:buf_name
endfunction

function! searcher#win#GetCallerBufName()
    return s:caller_buf_name
endfunction

function! searcher#win#InitCallerBufWin()
    let current_buf_name = bufname('%')
    call searcher#win#SetCallerBufName(current_buf_name)
    autocmd BufHidden,BufDelete <buffer> execute 'call searcher#win#SetCallerBufName("")'
endfunction

function! searcher#win#Open()
    let current_buf_name = bufname('%')
    if current_buf_name != '__searcher__' && searcher#win#GetCallerBufName() == ''
        call searcher#win#InitCallerBufWin()
    endif

    if searcher#win#Focus(s:MAIN_BUF_NAME) == 0
        execute 'silent keepalt topleft vertical split ' . s:MAIN_BUF_NAME
        call searcher#win#InitsearcherBufWin()
    endif
endfunction

function! searcher#win#Close()
    let nr = bufwinnr(s:MAIN_BUF_NAME)
    if nr != 0
        execute 'bdelete ' . s:MAIN_BUF_NAME
    else
        let searcher_buf_listed = buflisted(s:MAIN_BUF_NAME)
        if searcher_buf_listed == 1
            execute 'bdelete ' . s:MAIN_BUF_NAME
        endif
    endif
endfunction

function! searcher#win#AutoCloseHiddensearcherBuf()
    let nr = bufwinnr(s:MAIN_BUF_NAME)
    if nr == -1
        let searcher_buf_listed = buflisted(s:MAIN_BUF_NAME)
        if searcher_buf_listed == 1
            execute 'bdelete ' . s:MAIN_BUF_NAME
        endif
    endif
endfunction

function! searcher#win#InitsearcherBufWin()
    setlocal modifiable
    setlocal filetype=searcher
    setlocal fileencoding=utf-8
    setlocal nonumber
    call searcher#win#SetMappings()
endfunction

function! searcher#win#SetMappings()
    for [operate, hotkeys] in items(g:searcher_mappings)
        for hotkey in hotkeys
            execute 'nnoremap <silent><buffer> ' . hotkey .
                \ ' :call searcher#win#JumpTo("' . operate . '")<CR>'
        endfor
    endfor
endfunction

function! searcher#win#Focus(buf_name)
    let nr = winnr('$')
    if len(a:buf_name) != 0
        let nr = bufwinnr(a:buf_name)
    endif
    if nr > 0
        execute nr . 'wincmd w'
        return 1
    endif
    return 0
endfunction

function! searcher#win#JumpTo(way)
    let [filename, line_num, column_num] = searcher#utils#FindTargetPos(line('.'), col('.'))
    if bufwinnr(s:MAIN_BUF_NAME) == winnr('$')
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
        if index(keys(s:operation_mappings), a:way) != -1
            call searcher#win#Focus(s:caller_buf_name)
            let func = s:operation_mappings[a:way]
            execute 'call ' . func . '(filename, line_num, column_num)'
        endif
    endif
endfunction

function! searcher#win#JumpToFile(filename, line_num, column_num)
    execute 'silent edit ' . fnameescape(a:filename)
    call searcher#win#InitCallerBufWin()
    call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToFileSilently(filename, line_num, column_num)
    call searcher#win#JumpToFile(a:filename, a:line_num, a:column_num)
    call searcher#win#Focus(s:MAIN_BUF_NAME)
endfunction

function! searcher#win#JumpToTab(filename, line_num, column_num)
    execute 'silent tabedit ' . fnameescape(a:filename)
    call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToTabSilently(filename, line_num, column_num)
    execute 'silent tabedit ' . fnameescape(a:filename)
    call cursor(a:line_num, a:column_num)
    execute 'tabprevious'
    call searcher#win#Focus(s:MAIN_BUF_NAME)
endfunction

function! searcher#win#JumpToSplit(filename, line_num, column_num)
    execute 'silent split ' . fnameescape(a:filename)
    call searcher#win#InitCallerBufWin()
    call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToSplitSilently(filename, line_num, column_num)
    call searcher#win#JumpToSplit(a:filename, a:line_num, a:column_num)
    call searcher#win#Focus(s:MAIN_BUF_NAME)
endfunction

function! searcher#win#JumpToVSplit(filename, line_num, column_num)
    execute 'silent vsplit ' . fnameescape(a:filename)
    call searcher#win#InitCallerBufWin()
    call cursor(a:line_num, a:column_num)
endfunction

function! searcher#win#JumpToVSplitSilently(filename, line_num, column_num)
    call searcher#win#JumpToVSplit(a:filename, a:line_num, a:column_num)
    call searcher#win#Focus(s:MAIN_BUF_NAME)
endfunction

