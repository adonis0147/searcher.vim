# searcher.vim

Code search plugin for Vim powered by [rg](https://github.com/BurntSushi/ripgrep) / [sift](https://github.com/svent/sift) / [pt](https://github.com/monochromegane/the_platinum_searcher).

## Dependencies

- Vim 8.0+
- Search tools ([rg](https://github.com/BurntSushi/ripgrep) / [sift](https://github.com/svent/sift) / [pt](https://github.com/monochromegane/the_platinum_searcher))

## Quick Start

1. Type `:Searcher [options] <keyword> <path>` in command mode.
2. Explore the results.  
`<c-j>` ==> Jump to the next result  
`<c-k>` ==> Jump to the previous result  
3. Jump to the corresponding position.  
  ```
    <c-o>   to open (same as Enter)
    go      to preview file, keeping focus on the results
    <c-t>   to open in new tab
    gt      to open in new tab, keeping focus on the results
    <c-h>   to open in horizontal split
    gh      to open in horizontal split, keeping focus on the results
    <c-v>   to open in vertical split
    gv      to open in vertical split, keeping focus on the results
    q       to close window
  ```
## Commands
- **Searcher [options] \<keyword\> \<path\>**  
    Start searching.
- **SearcherCWD [options] \<keyword\>**  
    Start searching in the current working directory (as given by :pwd).
- **SearcherStop**  
    Stop searching.
- **SearcherClearAllCaches**  
    Clear all caches which are stored in `$HOME/.cache/searcher`.

## Example

Type `:Searcher -t vim func .` (Use [rg](https://github.com/BurntSushi/ripgrep) as the search tool and the options `-t vim` for [rg](https://github.com/BurntSushi/ripgrep) is to search vim files.)

![example](https://raw.githubusercontent.com/adonis0147/searcher.vim/master/example.gif)

**Note:** The input options must be valid for the chosen search tool (default: rg).

## Extras

1. For convenience, you can add a shortcut by setting `nnoremap <leader>a :Searcher -t %:e -S <C-R><C-W> .`. As a result, you can search the word under the cursor in files with the same extension. - search tool: rg

