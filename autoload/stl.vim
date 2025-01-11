function! stl#hl_get(group)
  return [
    \ synIDattr(synIDtrans(hlID(a:group)), 'fg'),
    \ synIDattr(synIDtrans(hlID(a:group)), 'bg'),
    \ synIDattr(synIDtrans(hlID(a:group)), 'bold'),
    \ synIDattr(synIDtrans(hlID(a:group)), 'italic'),
    \ ]
endfunction

function! stl#mode()
  let [label, fg, bg, b, i] = get(g:stl_mode_map, mode(), g:stl_mode_map['c'])

  if g:color_enabled
    let type = exists('+termguicolors') && &termguicolors ? 'gui' : 'cterm'
    let attr = join(['bold', 'italic'][(b ? 0 : 1):(i ? -1 : -2)], ',')
    let attr = strlen(attr) ? 'cterm='.attr.' gui='.attr : ''

    execute 'highlight STLMode' type.'fg='.fg type.'bg='.bg attr
    execute 'highlight STLAccent' type.'fg='.bg type.'bg='.fg
  endif

  return label
endfunction

function! stl#githead()
  return trim(system(
    \ 'git -C ' . shellescape(expand('%:p:h'))
    \ . ' rev-parse --abbrev-ref --symbolic-full-name HEAD 2>/dev/null'
    \ ))
endfunction

function! stl#errors()
  let nr_errors = len(filter(copy(getloclist(0)),
    \ 'v:val.valid && v:val.type =~ "\\v(E|e|W|w)"'))

  return nr_errors ? nr_errors : ''
endfunction

function! stl#status(active)
  return join([
    \ a:active ? '%#STLMode#' : '%#StatusLineNC#',
    \ ' %{stl#mode()}%{&paste ? "*" : ""} %*',
    \ a:active ? '%#STLAccent#' : '%#StatusLineNC#',
    \ ' %n%(:%H%W%) %*',
    \ '%( %{stl#githead()} |%)',
    \ ' %<%f %=',
    \ ' %{winwidth(0) >= 72 && strlen(&filetype) ? &filetype : ""} ',
    \ a:active ? '%#STLAccent#' : '%#StatusLineNC#',
    \ ' %2p%% %*',
    \ ' %3l/%L:%-2c ',
    \ a:active ? '%#STLInfo#' : '%#StatusLineNC#',
    \ '%( %M%{&readonly ? "=" : ""}',
    \ '%{exists("+key") && !empty(&key) ? "#" : ""} %)',
    \ '%( %{&spell ? &spelllang : ""} %)',
    \ '%( %{strlen(&fenc) && (&fenc !=? "utf-8") ? &fenc : ""} %)',
    \ '%( %{strlen(&ff) && (&ff !=? "unix") ? &ff : ""} %)',
    \ a:active ? '%#STLError#' : '%#StatusLineNC#',
    \ '%( %{stl#errors()} %)',
    \ '%*'
    \ ], '')
endfunction

function! stl#update()
  for nr in range(1, winnr('$'))
    call setwinvar(nr, '&statusline', '%!stl#status('.(nr == winnr()).')')
  endfor
endfunction
