let s:files = []
let s:index = []
let s:job = ''

let s:keyword = ''
let s:case_sensitive = 1

let s:start_time = ''
let s:last_update_time = ''

function! searcher#cmd#Build(argv)
python << EOF
argv_list = shlex.split(vim.eval('a:argv'))
case_sensitive_options = vim.eval('g:searcher_case_sensitive_options')
vim.command('let s:case_sensitive = 1')
for argv in argv_list[:-2]:
	if argv in case_sensitive_options:
		vim.command('let s:case_sensitive = 0')
vim.command("let s:keyword = pyeval('argv_list[-2]')")
vim.command('let argv = %s' % argv_list)
EOF
	let prefix_options = searcher#cmd#GetPrefixOptions()
	let cmd = [g:searcher_cmd]
	call extend(cmd, prefix_options)
	let s:keyword = searcher#cmd#TransformKeyword(s:keyword)
	let argv[len(argv) - 2] = s:keyword
	call extend(cmd, argv)
	return cmd
endfunction

function! searcher#cmd#TransformKeyword(keyword)
	return substitute(a:keyword, '(', '\\(', 'g')
endfunction

function! searcher#cmd#GetPrefixOptions()
	if g:searcher_cmd == 'rg'
		let prefix_options = ['--color=never', '--no-heading', '-n', '-C', g:searcher_context]
		return prefix_options
	elseif g:searcher_cmd == 'sift'
		let prefix_options = ['--binary-skip', '--no-color', '-n', '-C', g:searcher_context]
		return prefix_options
	elseif g:searcher_cmd == 'pt'
		let prefix_options = ['--nocolor', '--nogroup', '-C', g:searcher_context]
		return prefix_options
	endif
	return g:searcher_prefix_options
endfunction

function! searcher#cmd#Stop()
	if s:job != ''
		let channel = job_getchannel(s:job)
		if ch_status(channel) != 'closed'
			call ch_close(channel)
			call job_stop(s:job)
		endif
	endif
endfunction

function! searcher#cmd#Run(cmd)
	call searcher#log#Debug('command: %s', a:cmd)
	if bufwinnr(searcher#utils#GetCacheFile()) > 0
		let s:files = []
		let s:index = []

		let s:start_time = reltime()
		let s:last_update_time = reltime()

		let s:job = job_start(a:cmd, {
			\ 'out_mode' : 'raw',
			\ 'out_cb'   : 'searcher#cmd#OutCallback',
			\ 'close_cb' : 'searcher#cmd#CloseCallback',
			\ })
python << EOF
files = []
index = []
remaining = ''
EOF
	endif
endfunction

function! searcher#cmd#OutCallback(channel, msg)
python << EOF
msg = '%s%s' % (remaining, vim.eval('a:msg'))
files_size, index_size = len(files), len(index)
text, remaining = parser.parse(msg, files, index, int(vim.eval('g:searcher_result_indent')))
with open(cache_file, 'a') as f:
	f.write('%s\n' % text)
vim.command("let files = pyeval('files[files_size:]')")
vim.command("let index = pyeval('index[index_size:]')")
EOF
	call extend(s:files, files)
	call extend(s:index, index)

	let elapsed_time = reltimefloat(reltime(s:last_update_time))
	if g:searcher_update_interval >= 0 && elapsed_time > g:searcher_update_interval
		let s:last_update_time = reltime()
		execute 'silent checktime'
	endif
endfunction

function! searcher#cmd#CloseCallback(channel)
	execute 'silent checktime'
	echom printf('Searcher done! (elapsed time:%ss)', reltimestr(reltime(s:start_time)))
endfunction

function! searcher#cmd#GetJob()
	return s:job
endfunction

function! searcher#cmd#GetFiles()
	return s:files
endfunction

function! searcher#cmd#GetIndex()
	return s:index
endfunction

function! searcher#cmd#GetKeyword()
	return s:keyword
endfunction

function! searcher#cmd#IsKeywordCaseSensitive()
	return s:case_sensitive
endfunction
