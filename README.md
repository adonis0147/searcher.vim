# searcher.vim

Code search plugin for Vim 8.0+ powered by [rg](https://github.com/BurntSushi/ripgrep) / [sift](https://github.com/svent/sift) / [pt](https://github.com/monochromegane/the_platinum_searcher).

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
    o    to open (same as Enter)
    O    to open and close the quickfix window
    go   to preview file, keeping focus on the results
    t    to open in new tab
    T    to open in new tab, keeping focus on the results
    h    to open in horizontal split
    H    to open in horizontal split, keeping focus on the results
    v    to open in vertical split
    gv   to open in vertical split, keeping focus on the results
  ```
