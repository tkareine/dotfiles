""" Vim

" nable all features
set nocompatible

" <Leader> character is mapped to comma instead of backslash for easier access
let mapleader = ","

set wrap

" don't wrap words
set textwidth=0

" tab width
set tabstop=2

" (auto)indent uses 2 characters
set shiftwidth=2

" spaces instead of tabs
set expandtab

" ...but not for the following file types
autocmd FileType make set noexpandtab

" guess indentation
set smarttab
set autoindent

" expand the command line using tab
set wildchar=<Tab>

" show partial commands
set showcmd

" Fold using markers {{{
" like this
" }}}
"set foldmethod=marker

" highlight the searchterms
set hlsearch

" jump to the matches while typing
set incsearch

" ignore case while searching
set ignorecase

" don't wrap words
set textwidth=0

" show a ruler
set ruler

" show matching braces
set showmatch

" write before hiding a buffer
"set autowrite

" allows hidden buffers to stay unsaved, but we do not want this, so comment
" it out:
"set hidden

" auto-detect the filetype
filetype plugin indent on

" show line numbers
"set number

" syntax highlight
syntax on

" we use a dark background, don't we?
"set bg=dark

" colors I like
colorscheme desert

" always show the menu, insert longest match
set completeopt=menuone,longest

" powerful backspaces
set backspace=indent,eol,start

" history
set history=50

" 1000 undo levels
set undolevels=1000

" start scrolling before the last visible line
set scrolloff=3

" see what other <Tab> completion alternatives there are
set wildmenu

" let <Tab> completion behave like bash
set wildmode=list:longest

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

" plugin NERD_tree
map <Leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>
map <F10>     :execute 'NERDTreeToggle ' . getcwd()<CR>

" plugin FuzzyFinder
let g:fuzzy_ceiling = 20000
let g:fuzzy_ignore = "*~,*.*.swp,*.log,*.gz,*.zip"
let g:fuzzy_matching_limit = 200

map <Leader>b :FuzzyFinderBuffer<CR>
map <F8>      :FuzzyFinderBuffer<CR>

" highlight whitespace problems
" flags is '' to clear highlighting, or is a string to
" specify what to highlight (one or more characters):
"   e  whitespace at end of line
"   i  spaces used for indenting
"   s  spaces before a tab
"   t  tabs not at start of line
function! ShowExtraWhitespace(flags)
  let bad = ""
  let pat = []
  for c in split(a:flags, '\zs')
    if c == "e"
      call add(pat, '\s\+$')
    elseif c == "i"
      call add(pat, '^\t*\zs \+')
    elseif c == "s"
      call add(pat, ' \+\ze\t')
    elseif c == "t"
      call add(pat, '[^\t]\zs\t\+')
    else
      let bad .= c
    endif
  endfor
  if len(pat) > 0
    let s = join(pat, '\|')
    exec "syntax match ExtraWhitespace \"".s."\" containedin=ALL"
  else
    syntax clear ExtraWhitespace
  endif
  if len(bad) > 0
    echo "ShowExtraWhitespace ignored: ".bad
  endif
endfunction

function! InitShowExtraWhitespace()
  let b:ws_show = 1
  let b:ws_flags = "est"  " default (which whitespace to show)
  call ShowExtraWhitespace(b:ws_flags)
endfunction

function! ToggleShowExtraWhitespace()
  let b:ws_show = !b:ws_show
  if b:ws_show
    call ShowExtraWhitespace(b:ws_flags)
    echo "show extra whitespace"
  else
    call ShowExtraWhitespace("")
    echo "do not show extra whitespace"
  endif
endfunction

highlight ExtraWhitespace ctermbg=darkred guibg=darkred

autocmd InsertEnter * call ShowExtraWhitespace("")
autocmd InsertLeave * call ShowExtraWhitespace(b:ws_flags)
autocmd BufWinEnter * call InitShowExtraWhitespace()

nnoremap <Leader>ws :call ToggleShowExtraWhitespace()<CR>
nnoremap <F3> :call ToggleShowExtraWhitespace()<CR>

" show whitespace as chars
set listchars=tab:>-,trail:·,eol:$
nmap <silent> <Leader>wc :set nolist!<CR>

" toggle auto-indenting for code paste
nnoremap <Leader>p :set invpaste paste?<CR>
nnoremap <F2> :set invpaste paste?<CR>
imap <F2> <C-O><F2>

" Firefox-like shortcuts
map <C-T> :tabnew<CR>
map <C-N> :!gvim &<CR><CR>
"map <C-W> :confirm bdelete<CR>
map <F5>  :edit<CR>

""" GUI

" font
set gfn=Monospace\ 9

" cursor blinking off for all modes
set gcr=a:blinkon0
