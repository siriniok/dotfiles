""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Vim Configuration                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8
scriptencoding utf8

" Hide buffer (file) instead of abandoning when switching to another buffer
set hidden

" Set how many lines of history VIM should remember
set history=1000

" Allow for mappings including `Esc`, while preserving zero timeout after
" pressing it manually (only vim needs a fix for this)
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Allow for up to 50 opened tabs on startup
set tabpagemax=50

" Set spellcheck language
set spelllang=en_us

" Enable word completion
set complete+=kspell

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Enable persistent undo history
set undofile

" Disable undofile for temporary files
augroup vimrc
  autocmd!
  autocmd BufWritePre /tmp/* setlocal noundofile
augroup END

" Exclude empty buffers and options from session. Prevents CHADTree from opening
set sessionoptions-=blank
set sessionoptions-=options

" Set ctags directory
setglobal tags-=./tags tags-=./tags; tags^=./tags;

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
"                                  vim-plug                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- List of Plugs

" Plugs
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}

" Vim Polyglot requires to declare configuration before initialization
let g:polyglot_disabled = [
      \'sensible', 'markdown', 'javascript.plugin', 'jsx.plugin', 'ruby', 'typescript'
      \]
Plug 'sheerun/vim-polyglot'             " A collection of language packs
Plug 'othree/yajs.vim'                  " Improved JS support
Plug 'herringtondarkholme/yats.vim'     " TypeScript support
Plug 'maxmellon/vim-jsx-pretty'         " JSX support
Plug 'vim-ruby/vim-ruby'                " Vim Ruby

" vim-markdown
Plug 'godlygeek/tabular'                " Aligning text
Plug 'plasticboy/vim-markdown'          " Improve the original Markdown

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
      \'coc-tslint-plugin',
      \'coc-tsserver',
      \'coc-css',
      \'coc-eslint',
      \'coc-html',
      \'coc-json',
      \'coc-git',
      \'coc-prettier'
      \]

Plug 'dense-analysis/ale'               " ALE Linting
Plug 'adelarsq/vim-matchit'             " Extended matching for the % operator
Plug 'airblade/vim-gitgutter'           " GitGutter
Plug 'tpope/vim-fugitive'               " Git tools
Plug 'tpope/vim-rails'                  " Rails :/
Plug 'tpope/vim-surround'               " Surround your code :)
Plug 'tpope/vim-dispatch'               " Dispatch test runner to tmux pane
Plug 'tpope/vim-commentary'             " Commenting and uncommenting stuff
Plug 'ngmy/vim-rubocop'                 " Rubocop Integration
Plug 'jiangmiao/auto-pairs'             " Autogenerate pairs for quotes & {[(
Plug 'mattn/emmet-vim'                  " Emmet for Vim
Plug 'terryma/vim-multiple-cursors'     " Sublime-like multiple cursors
Plug 'tpope/vim-projectionist'          " Vim Projectionist
Plug 'janko-m/vim-test'                 " For tests
Plug 'guns/vim-clojure-static'          " Neat Clojure plugin
Plug 'tpope/vim-fireplace'              " Clojure REPL support
Plug 'vim-scripts/paredit.vim'          " Paredit for Vim
Plug 'eapache/rainbow_parentheses.vim'  " Colorful parentheses
Plug 'sgur/vim-editorconfig'            " Vim Editorconfig support
Plug 'thaerkh/vim-workspace'            " Session management
Plug 'junegunn/vim-easy-align'          " Vim easy align
Plug 'kshenoy/vim-signature'            " Marks signature
Plug 'mbbill/undotree'                  " Undotree
Plug 'Olical/conjure'                   " Conjure

" Fuzzy finder for vim (CTRL+P)
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Snippets
Plug 'SirVer/ultisnips'                 " A snippet engine
Plug 'honza/vim-snippets'               " snipmate and ultisnip snippets

" Themes
" Plug 'Donearm/Laederon'                 " laederon
" Plug 'treycucco/vim-monotonic'          " monotonic-light

" Plug 'owickstrom/vim-colors-paramount'  " paramount
" Plug 'andreypopp/vim-colors-plain'      " plain
" Plug 'liuchengxu/space-vim-theme'       " space_vim_theme
" Plug 'axvr/photon.vim'                  " antiphoton
" Plug 'YorickPeterse/vim-paper'      " paper
Plug 'cideM/yui'      " yui
" Plug 'reedes/vim-colors-pencil'         " pencil
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#end()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Display

set title                     " Update the title of your window or terminal
set number                    " Display line numbers
set signcolumn=number         " Always show the signcolumn
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

set updatetime=250            " More frequent updates

set scrolloff=3               " Display at least 3 lines around you cursor
                              " (for scrolling)

" Show matching brackets when text indicator is over them
set showmatch

set cursorline                " Highlight the current line

set guioptions=T              " Enable the toolbar

set colorcolumn=80

" Display tabs and spaces
set list
set listchars=tab:▸\·,space:·,nbsp:·,extends:>,precedes:<
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

" Break undo sequence in insert mode before deleting
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

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
"                             Spellchecking                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Toggle spell
nnoremap <leader>z :setlocal invspell<CR>

" Enable spellchecking automatically
autocmd BufRead,BufNewFile *.md setlocal spell
autocmd BufRead,BufNewFile *.txt setlocal spell
autocmd FileType gitcommit setlocal spell
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Plugs                                     "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- CHADTree

nnoremap <leader>q <cmd>CHADopen<cr> " Toogle CHADTree

let g:chadtree_settings = {
      \"ignore.name_exact": [
        \".DS_Store", ".directory", "thumbs.db", ".git", "node_modules"
      \],
      \"keymap.refresh": ["R"],
      \"view.width": 20
      \}
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
" -- fzf

nnoremap <C-p> :<C-u>Rg<CR>

let g:fzf_preview_window = ['right:50%', 'ctrl-/']

command! -bang -nargs=? -complete=dir Files
        \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case -. -- '.shellescape(<q-args>), 1,
      \   fzf#vim#with_preview(), <bang>0)
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
nnoremap ]g :ALENextWrap<CR>     " move to the next ALE warning/error
nnoremap [g :ALEPreviousWrap<CR> " move to the previous ALE warning/error
nnoremap <Leader>gg :ALEDetail<CR> " show details about ALE warning/error
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- CoC

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use `[p` and `]p` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [p <Plug>(coc-diagnostic-prev)
nmap <silent> ]p <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Show documentation on hover
function! ShowDocIfNoDiagnostic(timer_id)
  if (coc#float#has_float() == 0 && CocHasProvider('hover') == 1)
    silent call CocActionAsync('doHover')
  endif
endfunction

function! s:show_hover_doc()
  call timer_start(1000, 'ShowDocIfNoDiagnostic')
endfunction

" Comment out to enable
" autocmd CursorHoldI * :call <SID>show_hover_doc()
" autocmd CursorHold * :call <SID>show_hover_doc()

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -- Deolpete

let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_camel_case = 1
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
