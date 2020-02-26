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

" Enable persistent undo history
set undofile

" Disable undofile for temporary files
augroup vimrc
  autocmd!
  autocmd BufWritePre /tmp/* setlocal noundofile
augroup END

" Set ctags directory
set tags=./tags;

" Set backup directory
set backupdir=~/.vim/backup//

" Set swap directory
set directory=~/.vim/swap//

" Set undo directory
set undodir=~/.vim/undo//


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                          Neovim Configuration                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('nvim')
  " Highlight terminal cursor
  highlight! link TermCursor Cursor
  highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15

  " Switching back from the terminal mode
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-v><Esc> <Esc>

  " Set default editor to nvr in terminal mode to prevent
  " launching vim inside vim accidentally
  if executable('nvr')
    let $VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    let $EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  endif
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Vundle                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype off                  " Required
set rtp+=~/.vim/bundle/Vundle.vim  " Set the runtime path to include Vundle
call vundle#begin()           " Keep Plugin commands between vundle#begin/end
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- List of Plugins

Plugin 'VundleVim/Vundle.vim'             " Let Vundle manage Vundle, required

" Plugins
Plugin 'scrooloose/nerdtree'              " The NERD Tree file explorer
Plugin 'airblade/vim-gitgutter'           " GitGutter for Vim
Plugin 'sjbach/lusty'                     " LustyExplorer plugin
Plugin 'mileszs/ack.vim'                  " Ack plugin for Vim
Plugin 'tpope/vim-fugitive'               " Git tools
Plugin 'tpope/vim-rails.git'              " Rails :/
Plugin 'tpope/vim-surround'               " Surround your code :)
Plugin 'tpope/vim-dispatch'               " Dispatch test runner to tmux pane
Plugin 'scrooloose/nerdcommenter'         " Commenting and uncommenting stuff
Plugin 'vim-ruby/vim-ruby'                " Vim Ruby
Plugin 'ngmy/vim-rubocop'                 " Rubocop Integration
Plugin 'jiangmiao/auto-pairs'             " Autogenerate pairs for quotes & {[(
Plugin 'ervandew/supertab'                " Tab completions
Plugin 'mattn/emmet-vim'                  " Emmet for Vim
Plugin 'terryma/vim-multiple-cursors'     " Sublime-like multiple cursors
Plugin 'kien/ctrlp.vim'                   " Fuzzy finder for vim (CTRL+P)
Plugin 'janko-m/vim-test'                 " For tests
Plugin 'kien/rainbow_parentheses.vim'     " Colorful parentheses
Plugin 'guns/vim-clojure-static'          " Neat Clojure plugin
Plugin 'tpope/vim-fireplace'              " Clojure REPL support
Plugin 'paredit.vim'                      " Paredit for Vim
Plugin 'joukevandermaas/vim-ember-hbs'    " Support for Ember Handlebars
Plugin 'pangloss/vim-javascript'          " Improved JS support
Plugin 'mxw/vim-jsx'                      " JSX support
Plugin 'sgur/vim-editorconfig'            " Vim Editorconfig support

" Dependencies of vim-markdown
Plugin 'godlygeek/tabular'                " Aligning text
Plugin 'plasticboy/vim-markdown'          " Improve the original Markdown

" Dependencies of snipmate
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'honza/vim-snippets'
Plugin 'garbas/vim-snipmate'              " Snippets for our use :)

" Themes
Plugin 'siriniok/vim-colors-solarized'    " Solarized theme
Plugin 'Donearm/Laederon'                 " laederon
Plugin 'treycucco/vim-monotonic'          " monotonic-light

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call vundle#end()
filetype plugin indent on     " Required
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Display

set title                     " Update the title of your window or terminal
set number                    " Display line numbers
set ruler                     " Display cursor position
set wrap                      " Wrap lines when they are too long
syntax enable                 " Enable syntax highlighting
set background=light
colorscheme monotonic-light   " Default colorscheme
" autocmd Filetype ruby colorscheme railscasts  " Ruby colorscheme
if !has('nvim')
  set antialias
endif

set updatetime=250            " More frequent updates for, e.g. signs.

set scrolloff=3               " Display at least 3 lines around you cursor
                              " (for scrolling)

" Show matching brackets when text indicator is over them
set showmatch

set cursorline                " Highlight the current line
" set cuc cul                 " Highlight active column

set guioptions=T              " Enable the toolbar

set colorcolumn=78,80
" highlight ColorColumn ctermbg=7

" Display tabs and spaces
set list
set listchars=tab:▸\ ,space:·,nbsp:·
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

" Enable mouse in all modes
set mouse=a
if !has('nvim')
  set ttymouse=xterm2
endif

let mapleader=',' " My leader key
noremap \ ,

noremap <Leader>W :w !sudo tee % > /dev/null " ,W sudo saves the file

" Enable wildmenu for command line completions
" Hit <Tab> after : and see what will happen
set wildmenu

" Backspace behaves as expected
set backspace=indent,eol,start

" Removing escape
ino ii <Esc> " jj
cno ii <c-c> " jj
vno v <Esc>

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

" Resolve conflict with tmux
nnoremap <Leader>x <c-a>

" Insert new line without entering insert mode
nmap oo o<Esc>
nmap OO O<Esc>

" Puts the caller in Ruby code
nnoremap <leader>wtf oputs "#" * 90<c-m>puts caller<c-m>puts "#" * 90<esc>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Plugins                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- NERDTree

" autocmd vimenter * NERDTree   " Activate the NERDTree on launching vim
" autocmd VimEnter * wincmd p   " focus on file after launching
map <leader>q :NERDTreeToggle<CR> " Opens and closes Nerdtree with ,q
let NERDTreeShowHidden=1      " enable displaying hidden files
let g:NERDTreeWinSize=20
" Close Vim if NERDTree is the only window left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") &&
  \ b:NERDTree.isTabTree()) | q | endif
" Prevent NERDTree from opening on sesion restore
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && v:this_session == "" | NERDTree | endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Ack

" Default params for ack
let g:ackprg="ack -H --nocolor --nogroup --column"
" Add a mark and search
nmap <leader>j mA:Ack<space>
" Add a mark and search for the word under the cursor
nmap <leader>ja mA:Ack "<C-r>=expand("<cword>")<cr>"
nmap <leader>jA mA:Ack "<C-r>=expand("<cWORD>")<cr>"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- rainbow_parentheses

au VimEnter * RainbowParenthesesToggle
au Syntax   * RainbowParenthesesLoadRound
au Syntax   * RainbowParenthesesLoadSquare
au Syntax   * RainbowParenthesesLoadBraces
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- NERDCommenter

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- CtrlP

" Ignore files
set wildignore+=*/tmp/*,*/node_modules/*,*/bower_components/*,*.so,*.swp,*.zip
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
