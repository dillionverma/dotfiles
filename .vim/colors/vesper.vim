hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'vesper'
set background=dark

if has('termguicolors')
  set termguicolors
endif

let s:bg        = '#101010'
let s:bg_alt    = '#1c1c1c'
let s:bg_float  = '#232323'
let s:fg        = '#ffffff'
let s:fg_soft   = '#c7c7c7'
let s:comment   = '#7d7d7d'
let s:mint      = '#99ffe4'
let s:mint_soft = '#a0e9d6'
let s:orange    = '#ffc799'
let s:red       = '#ff8080'
let s:purple    = '#b8a1ff'
let s:blue      = '#8cc2ff'
let s:yellow    = '#ffe6b3'

function! s:hi(group, fg, bg, style) abort
  let l:cmd = ['hi', a:group]
  call add(l:cmd, 'guifg=' . (empty(a:fg) ? 'NONE' : a:fg))
  call add(l:cmd, 'guibg=' . (empty(a:bg) ? 'NONE' : a:bg))
  call add(l:cmd, 'ctermfg=NONE')
  call add(l:cmd, 'ctermbg=NONE')
  call add(l:cmd, 'gui=' . (empty(a:style) ? 'NONE' : a:style))
  call add(l:cmd, 'cterm=' . (empty(a:style) ? 'NONE' : a:style))
  execute join(l:cmd, ' ')
endfunction

call s:hi('Normal', s:fg, s:bg, '')
call s:hi('NormalFloat', s:fg, s:bg_float, '')
call s:hi('CursorLine', '', s:bg_alt, '')
call s:hi('CursorColumn', '', s:bg_alt, '')
call s:hi('ColorColumn', '', s:bg_alt, '')
call s:hi('CursorLineNr', s:mint, s:bg_alt, 'bold')
call s:hi('LineNr', s:comment, s:bg, '')
call s:hi('SignColumn', s:comment, s:bg, '')
call s:hi('VertSplit', s:bg_float, s:bg, '')
call s:hi('WinSeparator', s:bg_float, s:bg, '')
call s:hi('StatusLine', s:bg, s:mint, 'bold')
call s:hi('StatusLineNC', s:fg_soft, s:bg_alt, '')
call s:hi('Pmenu', s:fg, s:bg_float, '')
call s:hi('PmenuSel', s:bg, s:mint, 'bold')
call s:hi('PmenuSbar', '', s:bg_alt, '')
call s:hi('PmenuThumb', '', s:comment, '')
call s:hi('Visual', '', s:bg_float, '')
call s:hi('Search', s:bg, s:orange, 'bold')
call s:hi('IncSearch', s:bg, s:red, 'bold')
call s:hi('MatchParen', s:mint, s:bg_float, 'bold')
call s:hi('Directory', s:mint, '', 'bold')
call s:hi('Title', s:mint, '', 'bold')
call s:hi('ErrorMsg', s:red, s:bg, 'bold')
call s:hi('WarningMsg', s:orange, s:bg, 'bold')
call s:hi('ModeMsg', s:mint, s:bg, 'bold')
call s:hi('MoreMsg', s:mint, s:bg, 'bold')
call s:hi('Question', s:purple, s:bg, 'bold')

call s:hi('Comment', s:comment, '', 'italic')
call s:hi('Constant', s:orange, '', '')
call s:hi('String', s:orange, '', '')
call s:hi('Character', s:orange, '', '')
call s:hi('Number', s:orange, '', '')
call s:hi('Boolean', s:orange, '', 'bold')
call s:hi('Identifier', s:fg, '', '')
call s:hi('Function', s:mint, '', '')
call s:hi('Statement', s:purple, '', '')
call s:hi('Conditional', s:purple, '', '')
call s:hi('Repeat', s:purple, '', '')
call s:hi('Operator', s:mint_soft, '', '')
call s:hi('Keyword', s:purple, '', '')
call s:hi('PreProc', s:blue, '', '')
call s:hi('Type', s:yellow, '', '')
call s:hi('Special', s:mint_soft, '', '')
call s:hi('Delimiter', s:fg_soft, '', '')
call s:hi('Underlined', s:blue, '', 'underline')
call s:hi('Todo', s:bg, s:mint, 'bold')
call s:hi('Error', s:red, s:bg, 'bold')

call s:hi('DiffAdd', s:mint, s:bg_alt, '')
call s:hi('DiffChange', s:yellow, s:bg_alt, '')
call s:hi('DiffDelete', s:red, s:bg_alt, '')
call s:hi('DiffText', s:bg, s:orange, 'bold')
call s:hi('GitGutterAdd', s:mint, s:bg, '')
call s:hi('GitGutterChange', s:orange, s:bg, '')
call s:hi('GitGutterDelete', s:red, s:bg, '')
call s:hi('GitGutterChangeDelete', s:orange, s:bg, '')

call s:hi('DiagnosticError', s:red, '', '')
call s:hi('DiagnosticWarn', s:orange, '', '')
call s:hi('DiagnosticInfo', s:blue, '', '')
call s:hi('DiagnosticHint', s:mint, '', '')
