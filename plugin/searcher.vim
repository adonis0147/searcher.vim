let s:searcher_mappings = {
	\ 'open'    : ['<CR>', 'o'],
	\ 'opens'   : ['go'],
	\ 'tab'     : ['t'],
	\ 'tabs'    : ['T'],
	\ 'split'   : ['h'],
	\ 'splits'  : ['H'],
	\ 'vsplit'  : ['v'],
	\ 'vsplits' : ['V'],
	\ }

let s:searcher_view_mapping = {
	\ 'next' : '<c-j>',
	\ 'prev' : '<c-k>',
	\ }

if !exists('g:searcher_cmd')
	let g:searcher_cmd = 'rg'
endif

if !exists('g:searcher_context')
	let g:searcher_context = 2
endif

if !exists('g:searcher_prefix_options')
	let g:searcher_prefix_options = []
endif

if !exists('g:searcher_result_indent')
	let g:searcher_result_indent = 2
endif

if !exists('g:searcher_mappings')
	let g:searcher_mappings = s:searcher_mappings
endif

if !exists('g:searcher_check_whether_under_terminal')
	let g:searcher_check_whether_under_terminal = 1
endif

if g:searcher_check_whether_under_terminal
	let g:searcher_under_terminal = !has('gui_running')
else
	let g:searcher_under_terminal = 0
endif

if g:searcher_under_terminal
	let g:searcher_update_interval = -1
else
	if !exists('g:searcher_update_interval')
		let g:searcher_update_interval = 1.0
	endif
endif

if !exists('g:searcher_view_mapping')
	let g:searcher_view_mapping = s:searcher_view_mapping
endif

if !exists('g:searcher_debug')
	let g:searcher_debug = 0
endif

function! s:Init()
	call searcher#python#Init()
endfunction

call s:Init()

function! s:CleanUp()
	let cache_file = searcher#utils#GetCacheFile()
	call delete(cache_file)
endfunction

autocmd VimLeavePre * call s:CleanUp()

command! -bang -nargs=* -complete=file Searcher call searcher#Search(<q-args>)
command! -bang -nargs=0 -complete=file SearcherStop call searcher#Stop()
command! -bang -nargs=0 -complete=file SearcherClearAllCaches call searcher#ClearAllCaches()
