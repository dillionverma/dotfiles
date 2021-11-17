set nocompatible
syntax enable               " Switch syntax highlighting on
filetype plugin indent on   " Enable file type detection and do language-dependent indenting.
set number                  " Show line numbers

set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=/usr/local/opt/fzf
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'dikiaap/minimalist'
Plugin 'psliwka/vim-smoothie'
Plugin 'morhetz/gruvbox'
Plugin 'sainnhe/gruvbox-material'
Plugin 'vim-airline/vim-airline'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'junegunn/fzf.vim'
Plugin 'fatih/vim-go'
Plugin 'airblade/vim-gitgutter'

" HTML
Plugin 'mattn/emmet-vim'
Plugin 'alvan/vim-closetag'

Plugin 'w0rp/ale'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
call vundle#end()

map <SPACE> <leader>
map <leader>m :NERDTreeFind<cr>
nnoremap <c-p> :Files<cr>
nnoremap <c-S-F> :RG<cr>

set autoread        " Set to auto read when a file is changed from the outside
set encoding=utf8   " Make backspace behave in a sane manner.
set ignorecase
set smartcase
set incsearch
set hlsearch
set backspace=indent,eol,start
set mouse=a         " Enable mouse
set nocursorline
set updatetime=250
set tabstop=2       " The width of a TAB is set to 2.
set shiftwidth=2    " Indents will have a width of 2
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces
set smartindent
set autoindent
set nowrap
set showmatch       " Show matching parenthesis
set hidden          " Allow hidden buffers, don't limit to 1 file per window/split
set clipboard=unnamed
set wildignore+=*/.git/*,*/tmp/*,*/.DS_Store,*/vendor,*/.swp
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
set scrolloff=8 
set splitbelow

" speed up rendering
set synmaxcol=256 "speed up rendering because syntax only up to max column 
syntax sync minlines=512
set ttyfast
set lazyredraw


" Color
set t_Co=256
"set background=dark
"colorscheme minimalist
colorscheme gruvbox
hi EndOfBuffer ctermfg=235 ctermbg=NONE guibg=NONE
hi vertsplit ctermfg=NONE ctermbg=NONE
hi LineNr ctermfg=Yellow ctermbg=NONE
hi Normal ctermbg=NONE guibg=NONE gui=NONE
hi StatusLine ctermfg=NONE ctermbg=NONE
hi StatusLineNC ctermfg=235 ctermbg=NONE
hi Search ctermbg=58 ctermfg=15
hi Default ctermfg=1
hi clear SignColumn
hi IndentGuidesOdd  ctermbg=none
hi IndentGuidesEven ctermbg=235

hi GitGutterAdd ctermfg=2
hi GitGutterChange ctermfg=3
hi GitGutterDelete ctermfg=1
hi GitGutterChangeDelete ctermfg=4

" =========================================
" ================= FZF ===================
" =========================================

let g:fzf_layout = { 'down': '~30%' }

" Little preview window for files
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview())

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -bang -nargs=* RG call RipgrepFzf(<q-args>, <bang>0)

" =========================================
" =============== AIRLINE =================
" =========================================

let g:airline_theme='gruvbox_material'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_highlighting_cache=1

" =========================================
" ================ OTHER ==================
" =========================================
"
let g:gitgutter_sign_added='┃'
let g:gitgutter_sign_modified='┃'
"let g:ycm_key_list_stop_completion = [ '<C-y>', '<Enter>' ]
"let g:user_emmet_expandabbr_key='<Tab>'
"imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

