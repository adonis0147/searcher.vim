let s:searcher_path = escape(expand('<sfile>:p:h'), '\')

function! searcher#python#Init()
python << EOF
import vim
import os
sys.path.insert(0, vim.eval('s:searcher_path'))
import searcher
sys.path.pop(0)
EOF
endfunction

