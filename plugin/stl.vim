if exists('g:loaded_stl') || !exists('+statusline') || v:version < 700
  finish
endif

let g:loaded_stl = 1

let s:save_cpo = &cpo
set cpo&vim

let g:color_enabled = (&t_Co > 2 || has('gui_running')) && has('syntax')

set noshowmode

if g:color_enabled
  if !hlexists('STLInfo')
    highlight link STLInfo STLMode
  endif

  if !hlexists('STLError')
    highlight link STLError Error
  endif

  try
    execute 'let s:theme = stl#theme#'.g:colors_name.'#colors'
  catch
    let s:theme = stl#theme#dracula#colors
  endtry

  for [key, val] in items(s:theme)
    if !hlexists(key)
      execute 'highlight' key
        \ 'guibg='.val.guibg 'guifg=bg gui=bold'
        \ 'ctermbg='.val.ctermbg 'ctermfg=0 cterm=bold'
    endif
  endfor

  unlet s:theme
endif

let g:stl_mode_map = {
  \ 'n':  ['normal'] + stl#hl_get('STLNormalMode'),
  \ 'i':  ['insert'] + stl#hl_get('STLInsertMode'),
  \ 'R':  ['replace'] + stl#hl_get('STLReplaceMode'),
  \ 'c':  ['command'] + stl#hl_get('STLCommandMode'),
  \ 't':  ['terminal'] + stl#hl_get('STLCommandMode'),
  \ 'v':  ['visual'] + stl#hl_get('STLVisualMode'),
  \ 'V':  ['v-line'] + stl#hl_get('STLVisualMode'),
  \ '': ['v-block'] + stl#hl_get('STLVisualMode'),
  \ 's':  ['select'] + stl#hl_get('STLSelectMode'),
  \ 'S':  ['s-line'] + stl#hl_get('STLSelectMode'),
  \ '': ['s-block'] + stl#hl_get('STLSelectMode'),
  \ }

augroup stl
  autocmd!
  autocmd BufWinEnter,VimEnter,WinEnter * call stl#update()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
