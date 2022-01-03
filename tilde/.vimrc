""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Vim Configuration                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8
scriptencoding utf8

" Hide buffer (file) instead of abandoning when switching to another buffer
set hidden

" Set how many lines of history VIM should remember
set history=500

" Set spellcheck language
set spelllang=en_us

" Enable word completion
set complete+=kspell

" Enable persistent undo history
set undofile

" Disable undofile for temporary files
augroup vimrc
  autocmd!
  autocmd BufWritePre /tmp/* setlocal noundofile
augroup END

" Exclude empty buffers from session. Prevents Nerd Tree from opening
set sessionoptions-=blank

" Set ctags directory
set tags=./tags

" Set backup directory
set backupdir=~/.vim/backup//

" Set swap directory
set directory=~/.vim/swap//

" Set undo directory
set undodir=~/.vim/undo//

" Ignore files when searching
set wildignore+=*/tmp/*,*/node_modules/*,*/bower_components/*,*.so,*.swp,*.zip

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
set runtimepath+=~/.vim/bundle/Vundle.vim " Set runtime path to include Vundle
call vundle#begin()           " Keep Plugin commands between vundle#begin/end
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- List of Plugins

Plugin 'VundleVim/Vundle.vim'             " Let Vundle manage Vundle, required

" Plugins
Plugin 'scrooloose/nerdtree'              " The NERD Tree file explorer
Plugin 'Xuyuanp/nerdtree-git-plugin'      " Git status flags for NERD Tree
Plugin 'airblade/vim-gitgutter'           " GitGutter for Vim
Plugin 'tpope/vim-fugitive'               " Git tools
Plugin 'tpope/vim-rails.git'              " Rails :/
Plugin 'tpope/vim-surround'               " Surround your code :)
Plugin 'tpope/vim-dispatch'               " Dispatch test runner to tmux pane
Plugin 'tpope/vim-commentary'             " Commenting and uncommenting stuff
Plugin 'vim-ruby/vim-ruby'                " Vim Ruby
Plugin 'ngmy/vim-rubocop'                 " Rubocop Integration
Plugin 'jiangmiao/auto-pairs'             " Autogenerate pairs for quotes & {[(
Plugin 'mattn/emmet-vim'                  " Emmet for Vim
Plugin 'terryma/vim-multiple-cursors'     " Sublime-like multiple cursors
Plugin 'junegunn/fzf'                     " Fuzzy finder for vim (CTRL+P)
Plugin 'tpope/vim-projectionist'          " Vim Projectionist
Plugin 'janko-m/vim-test'                 " For tests
Plugin 'guns/vim-clojure-static'          " Neat Clojure plugin
Plugin 'tpope/vim-fireplace'              " Clojure REPL support
Plugin 'paredit.vim'                      " Paredit for Vim
Plugin 'eapache/rainbow_parentheses.vim'  " Colorful parentheses
Plugin 'othree/yajs.vim'                  " Improved JS support
Plugin 'herringtondarkholme/yats.vim'     " TypeScript support
Plugin 'maxmellon/vim-jsx-pretty'         " JSX support
Plugin 'sgur/vim-editorconfig'            " Vim Editorconfig support
Plugin 'thaerkh/vim-workspace'            " Session management
Plugin 'dense-analysis/ale'               " ALE Linting
Plugin 'junegunn/vim-easy-align'          " Vim easy align
Plugin 'autozimu/LanguageClient-neovim'   " Run install.sh after upgrade
Plugin 'kshenoy/vim-signature'            " Marks signature
Plugin 'mbbill/undotree'                  " Undotree
Plugin 'Olical/conjure'                   " Conjure

" Dependencies of vim-markdown
Plugin 'godlygeek/tabular'                " Aligning text
Plugin 'plasticboy/vim-markdown'          " Improve the original Markdown

Plugin 'Shougo/deoplete.nvim'             " A completion engine
if !has('nvim')
  Plugin 'roxma/nvim-yarp'
  Plugin 'roxma/vim-hug-neovim-rpc'
endif

" Snippets
Plugin 'SirVer/ultisnips'                 " A snippet engine
Plugin 'honza/vim-snippets'               " snipmate and ultisnip snippets

" Themes
" Plugin 'Donearm/Laederon'                 " laederon
" Plugin 'treycucco/vim-monotonic'          " monotonic-light

" Plugin 'owickstrom/vim-colors-paramount'  " paramount
" Plugin 'andreypopp/vim-colors-plain'      " plain
" Plugin 'liuchengxu/space-vim-theme'       " space_vim_theme
" Plugin 'axvr/photon.vim'                  " antiphoton
" Plugin 'YorickPeterse/vim-paper'      " paper
Plugin 'cideM/yui'      " yui
Plugin 'reedes/vim-colors-pencil'         " pencil

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
set wrap linebreak            " Wrap lines when they are too long
set formatoptions=jroqc       " See fo-table
set textwidth=80
set wrapmargin=2
syntax enable                 " Enable syntax highlighting
set background=light

" Force true colors in tmux
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" Enable italics in vim
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

colorscheme yui   " Default colorscheme

" Fixes for paramount
" hi Normal      ctermbg=255 ctermfg=234  cterm=None
" Fixes for monotonic-light
" hi Directory    ctermbg=255  ctermfg=234  cterm=Bold
" hi MatchParen   ctermbg=None ctermfg=None cterm=Bold,Underline
" hi ColorColumn  ctermbg=254  ctermfg=None  cterm=None

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

set colorcolumn=80

" Display tabs and spaces
set list
set listchars=tab:▸\·,space:·,nbsp:·
set showbreak=↳\·

" Add - to keywords
set iskeyword+=-
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Search

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
set autoindent                " Auto indent
set smartindent               " Smart indent
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Status Line

set showcmd                   " Enable info about the current command
set cmdheight=2               " Height of command bar
set laststatus=2              " Always show the status line

function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? '✨ all good ✨' : printf(
        \   '😞 %dW %dE',
        \   all_non_errors,
        \   all_errors
        \)
endfunction

" Format the status line
set statusline=
set statusline+=\ %f
set statusline+=%m%r%h%w
set statusline+=%=
set statusline+=\ %{LinterStatus()}
set statusline+=\ \ Buffer\ #%n\ --%p%%--\ \ L:\ %l\ C:\ %c\ 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Misc

" Disable SnipMate old parser deprecation message
let g:snipMate = { 'snippet_version' : 1 }

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

" ,W sudo saves the file
noremap <Leader>W :w !sudo tee % > /dev/null

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

" Run ctags
nnoremap <leader>ct :!ctags -R<CR>

" Toggle spell
nnoremap <leader>z :setlocal invspell<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                              Autocommands                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Run ctag on every file write
" :autocmd BufWritePost * call system("ctags -R")

" Enable spellchecking automatically
autocmd BufRead,BufNewFile *.md setlocal spell
autocmd BufRead,BufNewFile *.txt setlocal spell
autocmd FileType gitcommit setlocal spell
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                Plugins                                     "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- NERDTree

map <leader>q :NERDTreeToggle<CR> " Opens and closes Nerdtree with ,q
let NERDTreeShowHidden=1      " enable displaying hidden files
let g:NERDTreeWinSize=20

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Ack

" Default params for ack
let g:ackprg='ack -H --nocolor --nogroup --column'
" Add a mark and search
nmap <leader>j mA:Ack<space>
" Add a mark and search for the word under the cursor
nmap <leader>ja mA:Ack "<C-r>=expand("<cword>")<cr>"
nmap <leader>jA mA:Ack "<C-r>=expand("<cWORD>")<cr>"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- rainbow_parentheses

augroup rainbow
  au VimEnter * RainbowParenthesesToggle
  au Syntax   * RainbowParenthesesLoadRound
  au Syntax   * RainbowParenthesesLoadSquare
  au Syntax   * RainbowParenthesesLoadBraces
augroup END
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- NERDCommenter

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- FZF

nnoremap <C-p> :<C-u>FZF<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Vim Workspace

nnoremap <leader>ss :ToggleWorkspace<CR>
nnoremap <leader>sc :CloseHiddenBuffers<CR>
let g:workspace_session_directory = $HOME . '/.vim/session/'
let g:workspace_undodir= $HOME . '/.vim/undo/'
let g:workspace_autosave = 0
let g:workspace_session_disable_on_args = 1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- ALE

let g:ale_linters = {
\  'clojure':    ['clj-kondo'],
\  'css':        ['prettier'],
\  'javascript': ['eslint'],
\  'ruby':       ['standardrb'],
\  'python':     ['flake8', 'pylint'],
\  'vim':        ['vint']
\}

let g:ale_fixers = {
\  'clojure':    ['remove_trailing_lines', 'trim_whitespace'],
\  'javascript': ['prettier', 'eslint'],
\  'css':        ['prettier'],
\  'html':       ['prettier'],
\  'python':     ['yapf'],
\  'ruby':       ['standardrb'],
\}

let g:ale_fix_on_save = 1
nnoremap ]p :ALENextWrap<CR>     " move to the next ALE warning/error
nnoremap [p :ALEPreviousWrap<CR> " move to the previous ALE warning/error
nnoremap <Leader>pp :ALEDetail<CR> " show details about ALE warning/error
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Vim Easy Align

" Remap ga
nnoremap <leader>ga ga
xnoremap <leader>ga ga

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Language Server

let g:LanguageClient_serverCommands = {
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'ruby': ['~/.rvm/gems/default/bin/solargraph', 'stdio'],
    \ }

nnoremap <leader>mm :call LanguageClient_contextMenu()<CR>
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <leader>mr :call LanguageClient#textDocument_rename()<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Deolpete

let g:deoplete#enable_at_startup = 1

inoremap <silent><expr> <S-TAB>
      \ pumvisible() ? "\<C-p>" :
      \ <SID>check_back_space() ? "\<S-TAB>" :
      \ deoplete#manual_complete()

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ deoplete#manual_complete()

function! s:check_back_space() abort "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- UltiSnips

let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsEditSplit="context"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Undotree

nnoremap mu :UndotreeToggle<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Vim Markdown

let g:vim_markdown_folding_disabled = 1
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Paredit

let g:paredit_electric_return=0
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
