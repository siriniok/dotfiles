""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Vim Configuration                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Cancel the compatibility with Vi. Essential if you want
" to enjoy the features of Vim
set nocompatible

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Hide buffer (file) instead of abandoning when switching to another buffer
set hidden

" Set how many lines of history VIM should remember
set history=500


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Vundle                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim  " set the runtime path to include Vundle
call vundle#begin()           " keep Plugin commands between vundle#begin/end
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- List of Plugins

Plugin 'VundleVim/Vundle.vim'             " let Vundle manage Vundle, required
Plugin 'altercation/vim-colors-solarized' " Solarized theme
Plugin 'scrooloose/nerdtree'              " The NERD Tree file explorer
Plugin 'airblade/vim-gitgutter'           " GitGutter for Vim
Plugin 'tpope/vim-fugitive'               " Git tools
Plugin 'tpope/vim-rails.git'              " Rails :/
Plugin 'tomtom/tcomment_vim'              " commenting and uncommenting stuff

" Dependencies of snipmate
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'honza/vim-snippets'

Plugin 'garbas/vim-snipmate'              " snippets for our use :)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call vundle#end()
filetype plugin indent on     " required
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Display

set title                     " Update the title of your window or terminal
set number                    " Display line numbers
set ruler                     " Display cursor position
set wrap                      " Wrap lines when they are too long
syntax enable                 " Enable syntax highlighting
set background=dark
colorscheme solarized
colorscheme solarized
set antialias

set updatetime=250            " More frequent updates for, e.g. signs.

set scrolloff=3               " Display at least 3 lines around you cursor
                              " (for scrolling)

" Show matching brackets when text indicator is over them
set showmatch

set guioptions=T              " Enable the toolbar
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Search

set ignorecase                " Ignore case when searching
set smartcase                 " If there is an uppercase in your search term
                              " search case sensitive again
set incsearch                 " Highlight search results when typing
set hlsearch                  " Highlight search results
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Beep

set visualbell                " Prevent Vim from beeping
set noerrorbells              " Prevent Vim from beeping
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Indentation

set expandtab                 " Use spaces instead of tabs
set shiftwidth=2              " 1 tab == 2 spaces
set tabstop=2
set smarttab                  " Be smart when using tabs ;)
set ai                        " Auto indent
set si                        " Smart indent
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Status Line

set showcmd                   " Enable info about the current command
set cmdheight=2               " Height of command bar
set laststatus=2              " Always show the status line

" Returns true if paste mode is enabled
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  endif
  return ''
endfunction

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Keybindings

" Enable wildmenu for command line completions
" Hit <Tab> after : and see what will happen
set wildmenu

" Backspace behaves as expected
set backspace=indent,eol,start

:imap jj <Esc>                " Escape on jj keybinding
command W w !sudo tee % > /dev/null  " :W sudo saves the file

" Don't be a noob, join the no arrows key movement
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Move between splits easily
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Plugins                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- NERDTree

autocmd vimenter * NERDTree   " Activate the NERDTree on launching vim
autocmd VimEnter * wincmd p   " focus on file after launching
let NERDTreeShowHidden=1      " enable displaying hidden files
let g:NERDTreeWinSize=20
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
