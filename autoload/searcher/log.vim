function! searcher#log#Debug(format, ...)
    let argv = join(map(copy(a:000), 'string(v:val)'), ',')
    execute 'let msg = printf(a:format, ' . argv . ')'
    echo msg
endfunction

