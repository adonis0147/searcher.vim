function! searcher#utils#FindTargetPos(row, column)
    let filename = searcher#utils#GetFilenameByLineNum(a:row)
    let [line_num, column_num] = searcher#utils#GetPos(a:row, a:column)
    return [filename, line_num, column_num]
endfunction

function! searcher#utils#GetFilenameByLineNum(line_num)
    let files = searcher#buf#GetFiles()
    let index = searcher#buf#GetIndex()
    if has_key(index, a:line_num)
        return get(files, index[a:line_num], '')
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
    if len(line_num) != 0
        return [line_num, column_num]
    else
        return [1, 1]
    endif
endfunction

