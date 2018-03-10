let s:files = []
let s:index = []
let s:job = ''

let s:keyword = ''
let s:case_sensitive = 1

let s:start_time = ''
let s:last_update_time = ''

let s:escape_mapping = {
\ '^' : '\^',
\ '$' : '\$',
\ '.' : '\.',
\ '|' : '\|',
\ '?' : '\?',
\ '*' : '\*',
\ '+' : '\+',
\ '(' : '\(',
\ ')' : '\)',
\ '[' : '\[',
\ ']' : '\]',
\ '-' : '\-',
\ }

function! searcher#cmd#Build(argv)
exec python#PythonUntilEOF()
argv_list = shlex.split(vim.eval('a:argv'))
options = vim.eval('searcher#cmd#GetCaseOptions()')
case_sensitive = bootstrap.is_case_sensitive(argv_list, options)
vim.command('let s:case_sensitive = %d' % case_sensitive)
vim.command("let s:keyword = %s('argv_list[-2]')" % pyeval)
vim.command('let argv = %s' % argv_list)
EOF
	let prefix_options = searcher#cmd#GetPrefixOptions()
	let cmd = [g:searcher_cmd]
	call extend(cmd, prefix_options)
	let argv[len(argv) - 2] = searcher#cmd#TransformKeyword(s:keyword, s:escape_mapping)
	call extend(cmd, argv)
	return cmd
endfunction

function! searcher#cmd#TransformKeyword(keyword, escape_mapping)
	let characters = []
	let i = 0
	while i < len(a:keyword)
		let c = a:keyword[i]
		if has_key(a:escape_mapping, c)
			call add(characters, a:escape_mapping[c])
		else
			call add(characters, c)
		endif
		let i = i + 1
	endwhile
	return join(characters, '')
endfunction

function! searcher#cmd#GetCaseOptions()
	let options = {
		\ 'ignore-case'    : ['-i', '--ignore-case'],
		\ 'case-sensitive' : [],
		\ 'smart-case'     : ['-S', '--smart-case'],
		\ }
	if g:searcher_cmd == 'rg'
		let options['case-sensitive'] = ['-s', '--case-sensitive']
	elseif g:searcher_cmd == 'sift'
		let options['smart-case'] = ['-s', '--smart-case']
		let options['case-sensitive'] = ['-I', '--no-ignore-case']
	endif
	return options
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
exec python#PythonUntilEOF()
files = []
index = []
remaining = ''
EOF
	endif
endfunction

function! searcher#cmd#OutCallback(channel, msg)
exec python#PythonUntilEOF()
msg = '%s%s' % (remaining, vim.eval('a:msg'))
files_size, index_size = len(files), len(index)
text, remaining = bootstrap.parse(msg, files, index, int(vim.eval('g:searcher_result_indent')))
if text:
	with open(cache_file, 'ab') as f:
		f.write(text)
vim.command("let files = %s('files[files_size:]')" % pyeval)
vim.command("let index = %s('index[index_size:]')" % pyeval)
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
