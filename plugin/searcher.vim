let s:searcher_mappings = {
	\ 'open'	: ['<CR>', 'o'],
	\ 'opens'	: ['go'],
	\ 'tab'		: ['t'],
	\ 'tabs'	: ['T'],
	\ 'split'	: ['h'],
	\ 'splits'	: ['H'],
	\ 'vsplit'	: ['v'],
	\ 'vsplits' : ['V'],
	\}

let s:searcher_view_mapping = {
	\ 'next'	: '<c-j>',
	\ 'prev'	: '<c-k>',
	\}

if !exists('g:searcher_cmd')
	let g:searcher_cmd = 'rg'
endif

if !exists('g:searcher_context')
	let g:searcher_context = 2
endif

if !exists('g:searcher_prefix_options')
	let g:searcher_prefix_options = []
endif

if !exists('g:searcher_timer_interval')
	let g:searcher_timer_interval = 1000
endif

if !exists('g:searcher_result_indent')
	let g:searcher_result_indent = 2
endif

if !exists('g:searcher_mappings')
	let g:searcher_mappings = s:searcher_mappings
endif

if !exists('g:searcher_view_mapping')
	let g:searcher_view_mapping = s:searcher_view_mapping
endif

if !exists('g:searcher_case_sensitive_options')
    let g:searcher_case_sensitive_options = ['-i', '--ignore-case']
endif

function! s:CleanUp()
	let cache_file = searcher#utils#GetCacheFile()
	call delete(cache_file)
endfunction

autocmd VimLeavePre * call s:CleanUp()

command! -bang -nargs=* -complete=file Searcher call searcher#Search(<q-args>)
