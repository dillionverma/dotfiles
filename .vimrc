set nocompatible
set number
filetype plugin indent on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'dikiaap/minimalist'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/nerdcommenter'
Plugin 'airblade/vim-gitgutter'
"Plugin 'ervandew/supertab'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'ryanoasis/vim-devicons'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-endwise'
Plugin 'tomlion/vim-solidity'
Plugin 'vim-syntastic/syntastic'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'wakatime/vim-wakatime'
Plugin 'raimondi/delimitmate'
Plugin 'yggdroot/indentline'
Plugin 'vim-ruby/vim-ruby'
Plugin 'thoughtbot/vim-rspec'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-bundler'
Plugin 'mattn/emmet-vim'
call vundle#end()

map <SPACE> <leader>

map <leader>s :source ~/.vimrc<CR>
vmap <C-c> :w !pbcopy<CR>

map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

vnoremap < <gv
vnoremap > >gv

au BufEnter *.rb syn match error contained "\<binding.pry\>"


" Configuration
set autoread " Set to auto read when a file is changed from the outside
set ignorecase
set smartcase
set incsearch
set backspace=indent,eol,start
set mouse=a
set nocursorline
set updatetime=250
set tabstop=2       " The width of a TAB is set to 4.
set shiftwidth=2    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces
set smartindent
set autoindent
set nowrap
set showmatch       " Show matching parenthesis
set runtimepath^=~/.vim/bundle/ctrlp.vim
set hidden
set history=50     " store info in memory for speed
set autoread        " autoread
set clipboard=unnamed
set wildignore+=*/.git/*,*/tmp/*,*/.DS_Store,*/vendor
set signcolumn=yes  " always show gitgutter

" Colors and Fonts
set term=screen-256color
set t_Co=256
syntax on
colorscheme minimalist
set background=dark

" speed up rendering
set synmaxcol=256 "speed up rendering because syntax only up to max column 
syntax sync minlines=256
set ttyfast

"hi Normal ctermbg=none
"hi NonText ctermbg=none
"highlight clear SignColumn

autocmd vimenter * NERDTree | wincmd p
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
let g:nerdtree_tabs_open_on_console_startup=1
let NERDTreeMapActivateNode='<right>'          " open nerdtree node with right key
let NERDTreeMouseMode=3                        " navigate nerdtree with single click
" let NERDTreeShowHidden=1                       " show hidden files
let g:NERDTreeWinSize=40
let NERDTreeIgnore = ['\.d', '\.o']

" make nerdtree syntax highlight faster
let g:NERDTreeSyntaxDisableDefaultExtensions = 1
let g:NERDTreeDisableExactMatchHighlight = 1
let g:NERDTreeDisablePatternMatchHighlight = 1
let g:NERDTreeSyntaxEnabledExtensions = ['c', 'h', 'c++', 'php', 'rb', 'js', 'css', 'scss', 'sass', 'html'] " example

let g:airline_powerline_fonts = 1
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=80
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f'] 
let indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
hi IndentGuidesOdd  ctermbg=none
hi IndentGuidesEven ctermbg=233

"highlight VertSplit ctermbg=NONE
"highlight VertSplit ctermfg=NONE
set fillchars+=vert:\ 

let g:airline_theme='onedark'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

let g:SuperTabDefaultCompletionType = "<c-n>"
let g:enable_bold_font = 1

let g:javascript_plugin_jsdoc = 1
let g:UltiSnipsExpandTrigger="<tab>"

let g:markdown_fenced_languages = ['c', 'cpp', 'python', 'bash=sh']

let g:jsx_ext_required = 0 "enables jsx syntax in .js files

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_cpp_compiler_options = "-std=c++14 -Wall -g"

"let g:closetag_filenames = "*.html,*.erb"

let g:user_emmet_expandabbr_key='<Tab>'
imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
let g:user_emmet_settings = {
    \  'html' : {
    \    'indent_blockelement': 1,
    \  },
    \}
