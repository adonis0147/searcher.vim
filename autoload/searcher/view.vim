let s:REGEX_PREFIX_FOR_KEYWORD = '(^\d+:.*)@<='
let s:keyword_pattern          = ''
let s:highlight_id             = -1

let s:operation_mappings = {
	\ 'next' : 'searcher#view#SearchNext()',
	\ 'prev' : 'searcher#view#SearchPrevious()',
	\}

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
\ '<' : '\<',
\ '>' : '\>',
\ '=' : '\=',
\ }

function! searcher#view#Highlight(keyword)
	if searcher#cmd#IsKeywordCaseSensitive() == 1
		let regex_for_case = '\C'
	else
		let regex_for_case = '\c'
	endif
	let keyword = searcher#cmd#TransformKeyword(a:keyword, s:escape_mapping)
	let s:keyword_pattern = printf('\v%s%s%s', regex_for_case, s:REGEX_PREFIX_FOR_KEYWORD, keyword)
	call searcher#log#Debug("keyword_pattern: %s", s:keyword_pattern)
	if s:highlight_id != -1
		try
			call matchdelete(s:highlight_id)
		catch
			let s:highlight_id = -1
		endtry
	endif
	let s:highlight_id = matchadd('searcherKeyword', s:keyword_pattern)
	call searcher#view#SetMappings()
endfunction

function! searcher#view#SetMappings()
	for [operate, hotkey] in items(g:searcher_view_mapping)
		if index(keys(s:operation_mappings), operate) != -1
			let func = s:operation_mappings[operate]
			execute printf('nnoremap <silent><buffer> %s :call %s<CR>', hotkey, func)
		endif
	endfor
endfunction

function! searcher#view#SearchNext()
	call search(s:keyword_pattern)
endfunction

function! searcher#view#SearchPrevious()
	call search(s:keyword_pattern, 'b')
endfunction
