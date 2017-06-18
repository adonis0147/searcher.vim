let s:files = []
let s:index = []
let s:job = ''
let s:timer = 0

let s:keyword = '""'
let s:case_sensitive = 1

function! searcher#cmd#Build(argv)
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
	if g:searcher_cmd == 'sift'
		let prefix_options = ['--binary-skip', '--no-color', '-n', '-C', g:searcher_context]
		return prefix_options
	elseif g:searcher_cmd == 'rg'
		let prefix_options = ['--color=never', '--no-heading', '-n', '-C', g:searcher_context]
		return prefix_options
	elseif index(['ack', 'ag', 'pt'], g:searcher_cmd) >= 0
		let prefix_options = ['--nocolor', '--nogroup', '-C', g:searcher_context]
		return prefix_options
	endif
	return g:searcher_prefix_options
endfunction

function! searcher#cmd#Run(cmd)
	call searcher#log#Debug('command: %s', a:cmd)
	if bufwinnr(searcher#utils#GetCacheFile()) > 0
		let s:files = []
		let s:index = []

		let s:job = job_start(a:cmd, {
			\ 'out_cb'  : 'searcher#cmd#OutCallback',
			\ 'exit_cb' : 'searcher#cmd#ExitCallback',
			\ })

		call timer_stop(s:timer)
		let s:timer = timer_start(g:searcher_timer_interval, 'searcher#win#Update', {'repeat' : -1})
	endif
endfunction

function! searcher#cmd#OutCallback(channel, msg)
	let num_files = len(s:files)
	let filename = num_files ? s:files[num_files - 1] : ''
python << EOF
import os
import re
import vim
num_files = int(vim.eval('num_files'))
last_filename = vim.eval('filename')
msg = vim.eval('a:msg')
tokens = re.split(r'(-\d+-|:\d+:)', msg)
indent = ' ' * int(vim.eval('g:searcher_result_indent'))

def parse(tokens):
	if len(tokens) == 3:
		filename, content = tokens[0], '%s%s%s\n' % (tokens[1][1:], indent, tokens[2])
	else:
		filename = tokens[0]
		i = 0
		while not os.path.isfile(filename) and i + 2 < len(tokens) - 1:
			filename = '%s%s%s' % (filename, tokens[i + 1], tokens[i + 2])
			i += 2
		i += 1
		if i < len(tokens) - 1:
			content = '%s%s%s\n' % (tokens[i][1:], indent, ''.join(tokens[i + 1:]))
	return filename, content

def write_line(content):
	with open(vim.eval('searcher#utils#GetCacheFile()'), 'a') as f:
		f.write(content)
	vim.command('call add(s:index, %d)' % (num_files - 1))

if len(tokens) == 1:
	write_line('%s\n' % tokens[0])
else:
	filename, content = parse(tokens)
	if filename != last_filename:
		if num_files > 0:
			write_line('\n')
		vim.command('call add(s:files, "%s")' % filename)
		num_files += 1
		write_line('%s\n' % filename)
	write_line(content)
EOF
endfunction

function! searcher#cmd#ExitCallback(channel, msg)
	execute 'silent checktime'
	call timer_stop(s:timer)
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
