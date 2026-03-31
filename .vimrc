" UI
set termguicolors
set background=dark
syntax on
filetype plugin indent on

set number
set relativenumber
set cursorline
set signcolumn=yes
set scrolloff=8
set sidescrolloff=8
set showmode
set wildmenu
set ruler
set laststatus=2

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Editing
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set smartindent
set autoindent
set backspace=indent,eol,start
set splitright
set splitbelow

" Files / history
set hidden
set undofile
set updatetime=250
set timeoutlen=400
set nowrap

" Whitespace
set list
set listchars=tab:»·,trail:·,nbsp:␣

" System clipboard
if has('clipboard')
  set clipboard=unnamedplus
endif

" Mouse
if has('mouse')
  set mouse=a
endif

" Better command-line completion
set wildmode=longest:full,full

" Git gutter
let g:gitgutter_map_keys = 0
let g:gitgutter_set_sign_backgrounds = 1
let g:gitgutter_sign_added = '│'
let g:gitgutter_sign_modified = '│'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_sign_removed_first_line = '‾'
let g:gitgutter_sign_removed_above_and_below = '~'
let g:gitgutter_sign_modified_removed = '~'

" Sensible leader
let mapleader = ' '

" Comment toggles using commentstring when available.
function! ToggleCommentLine() abort
  let l:commentstring = &commentstring ==# '' || &commentstring ==# '%s' ? '# %s' : &commentstring
  let l:prefix = substitute(l:commentstring, '%s.*$', '', '')
  let l:suffix = substitute(l:commentstring, '^.*%s', '', '')
  let l:line = getline('.')
  let l:indent = matchstr(l:line, '^\s*')
  let l:body = l:line[len(l:indent):]

  if l:body =~ '^' . escape(l:prefix, '\.*$^~[]')
    let l:body = substitute(l:body, '^' . escape(l:prefix, '\.*$^~[]'), '', '')
    if !empty(l:suffix)
      let l:body = substitute(l:body, escape(l:suffix, '\.*$^~[]') . '$', '', '')
    endif
  else
    let l:body = l:prefix . l:body . l:suffix
  endif

  call setline('.', l:indent . l:body)
endfunction

function! ToggleCommentSelection(type) abort
  let l:start = line("'[")
  let l:end = line("']")

  if a:type ==# 'visual'
    let l:start = line("'<")
    let l:end = line("'>")
  endif

  for l:lnum in range(l:start, l:end)
    call cursor(l:lnum, 1)
    call ToggleCommentLine()
  endfor
endfunction

" Quick quality-of-life mappings
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>n :set invnumber invrelativenumber<CR>
nnoremap <leader>c<Space> :call ToggleCommentLine()<CR>
xnoremap <leader>c<Space> :<C-u>call ToggleCommentSelection('visual')<CR>
nnoremap ]h <Plug>(GitGutterNextHunk)
nnoremap [h <Plug>(GitGutterPrevHunk)
nnoremap <leader>gp <Plug>(GitGutterPreviewHunk)
nnoremap <leader>gs <Plug>(GitGutterStageHunk)
nnoremap <leader>gu <Plug>(GitGutterUndoHunk)
nnoremap <leader>gq :GitGutterQuickFix<CR>

" Keep visual selection when indenting
vnoremap < <gv
vnoremap > >gv

" Move selected lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Better split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

silent! colorscheme vesper
