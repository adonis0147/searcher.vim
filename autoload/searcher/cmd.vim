function! searcher#cmd#Run(cmd)
call searcher#log#Debug('Commands: %s', string(a:cmd))
python << EOF
import vim
import searcher
cmd = vim.eval('a:cmd')
indent = int(vim.eval('g:searcher_result_indent'))
text, index, files = searcher.search(cmd, indent)
vim.command('let text = pyeval("text")')
vim.command('let files = pyeval("files")')
vim.command('let index = %s' % index)
EOF
call searcher#buf#Init(text, files, index)
endfunction

function! searcher#cmd#Build(argv)
    let parsed_options = searcher#opt#ParseOptions(a:argv)
    let cmd = g:searcher_cmd . ' ' . parsed_options
    return cmd
endfunction

