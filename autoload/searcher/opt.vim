let s:keyword = '""'
let s:case_sensitive = 1

function! searcher#opt#GetPrefixOptions()
    if g:searcher_cmd == 'sift'
        let prefix_options = '--binary-skip --no-color -n -C ' . g:searcher_context
        return prefix_options
    elseif index(['ack', 'ag', 'pt'], g:searcher_cmd) >= 0
        let prefix_options = '--nocolor --nogroup -C ' . g:searcher_context
        return prefix_options
    endif
    return g:searcher_prefix_options
endfunction

function! searcher#opt#ParseOptions(argv)
python << EOF
import vim
import shlex
argv_list = shlex.split(vim.eval('a:argv'))
case_sensitive_options = vim.eval('g:searcher_case_sensitive_options')
vim.command('let s:case_sensitive = 1')
for argv in argv_list[:-2]:
    if argv in case_sensitive_options:
        vim.command('let s:case_sensitive = 0')
vim.command("let s:keyword = pyeval('argv_list[-2]')")
argv_list[-2] = '"%s"' % argv_list[-2]
vim.command("let parsed_argv = '%s'" % ' '.join(argv_list))
EOF
let prefix_options = searcher#opt#GetPrefixOptions()
return prefix_options . ' ' . parsed_argv
endfunction

function! searcher#opt#GetCaseSensitive()
    return s:case_sensitive
endfunction

function! searcher#opt#GetKeyword()
    return s:keyword
endfunction

