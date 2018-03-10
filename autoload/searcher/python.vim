let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

function! searcher#python#Init()
exec python#PythonUntilEOF()
import os
import vim
import shlex
import shutil
sys.path.insert(0, vim.eval('s:plugin_path'))
import bootstrap
sys.path.pop(0)
cache_file = vim.eval('searcher#utils#GetCacheFile()')
pyeval = 'py3eval' if sys.version_info[0] >= 3 else 'pyeval'
EOF
endfunction

function! python#PythonUntilEOF()
	return python#UsePython3() ? 'python3 << EOF' : 'python << EOF'
endfunction

function! python#UsePython3()
	return has('python3')
endf
