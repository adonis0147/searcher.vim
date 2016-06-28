let s:REGEX_PREFIX_FOR_KEYWORD = '(^\d+:.*)@<='
let s:keyword_pattern          = ''
let s:highlight_id             = -1

let s:operation_mappings = {
    \ 'next'    : 'searcher#view#SearchNext()',
    \ 'prev'    : 'searcher#view#SearchPrevious()',
    \}

function! searcher#view#Init()
    call searcher#view#SetMappings()
endfunction

function! searcher#view#SetMappings()
    for [operate, hotkey] in items(g:searcher_view_mapping)
        if index(keys(s:operation_mappings), operate) != -1
            let func = s:operation_mappings[operate]
            execute 'nnoremap <silent><buffer> ' . hotkey .
                \ ' :call ' . func . '<CR>'
        endif
    endfor
endfunction

function! searcher#view#highlight(keyword)
    if searcher#opt#GetCaseSensitive() == 1
        let regex_for_case = '\C'
    else
        let regex_for_case = '\c'
    endif
    let s:keyword_pattern = '\v' . regex_for_case . s:REGEX_PREFIX_FOR_KEYWORD . a:keyword
    if s:highlight_id != -1
        try
            call matchdelete(s:highlight_id)
        catch
            let s:highlight_id = -1
        endtry
    endif
    let s:highlight_id = matchadd('searcherKeyword', s:keyword_pattern)
endfunction

function! searcher#view#SearchNext()
    call search(s:keyword_pattern)
endfunction

function! searcher#view#SearchPrevious()
    call search(s:keyword_pattern, 'b')
endfunction

function! searcher#view#GetKeywordPattern()
    return s:keyword_pattern
endfunction

