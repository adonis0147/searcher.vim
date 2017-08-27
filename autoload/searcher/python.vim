let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

function! searcher#python#Init()
python << EOF
import os
import vim
import shlex
import shutil
sys.path.insert(0, vim.eval('s:plugin_path'))
import bootstrap
sys.path.pop(0)
cache_file = vim.eval('searcher#utils#GetCacheFile()')
EOF
endfunction
