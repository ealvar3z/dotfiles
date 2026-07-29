" ALE behaves like an explicit compile command: it runs only when requested,
" reports into quickfix, and avoids inline diagnostics.
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_open_list = 1
let g:ale_keep_list_window_open = 1
let g:ale_list_window_size = 10
let g:ale_set_signs = 0
let g:ale_set_highlights = 0
let g:ale_virtualtext_cursor = 'disabled'
let g:ale_echo_cursor = 0
let g:ale_linters = {'perl': ['psc']}

" Use Tab for contextual insert completion, with omni completion preferred
" when the current filetype provides it.
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']

" Install vim-plug on first use, then install any missing plugins.
let s:plug_path = expand('~/.vim/autoload/plug.vim')
if !filereadable(s:plug_path) && executable('curl')
  silent execute '!curl -fLo ' . shellescape(s:plug_path)
        \ . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

if filereadable(s:plug_path)
  let g:plug_url_format = 'https://github.com/%s.git'
  call plug#begin('~/.vim/plugged')
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-eunuch'
  Plug 'tpope/vim-vinegar'
  Plug 'dense-analysis/ale'
  Plug 'ervandew/supertab'
  call plug#end()

  let s:plugins_missing =
        \ !isdirectory(expand('~/.vim/plugged/vim-sensible'))
        \ || !isdirectory(expand('~/.vim/plugged/vim-commentary'))
        \ || !isdirectory(expand('~/.vim/plugged/vim-eunuch'))
        \ || !isdirectory(expand('~/.vim/plugged/vim-vinegar'))
        \ || !isdirectory(expand('~/.vim/plugged/ale'))
        \ || !isdirectory(expand('~/.vim/plugged/supertab'))
  if s:plugins_missing
    augroup install_vim_plugins
      autocmd!
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
  endif

  runtime! plugin/sensible.vim
endif

set hidden
set viminfo='100,<50,s10,h
set showcmd
set completeopt=menuone
set shortmess+=c
set wildmode=longest:full,full
set nowrap
set linebreak
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set autoindent
set smartindent
set ignorecase
set smartcase
set hlsearch
set nomodeline
set scrolloff=3
set splitbelow
set splitright
set ttyfast
set lazyredraw
set background=dark
set laststatus=0
set noshowmode
set visualbell
set noerrorbells
set noundofile
set nowritebackup
set nobackup
set noswapfile

let mapleader=" "
inoremap jk <Esc>
nnoremap ; :
vnoremap ; :
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap Y y$

function! s:QuickfixMove(command) abort
  try
    execute a:command
  catch /^Vim\%((\a\+)\)\=:E/
    echohl WarningMsg
    echomsg substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
    echohl None
  endtry
endfunction

nnoremap <leader>n :call <SID>QuickfixMove('cnext')<CR>
nnoremap <leader>p :call <SID>QuickfixMove('cprevious')<CR>

if has("mouse")
  set mouse=a
endif

if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat=%f:%l:%c:%m
endif

function! s:Compile() abort
  try
    silent update
  catch
    echohl ErrorMsg
    echomsg 'Compile: could not save the current buffer'
    echohl None
    return
  endtry

  if exists(':ALELint') != 2
    echohl ErrorMsg
    echomsg 'Compile: ALE is not installed'
    echohl None
    return
  endif

  ALELint
endfunction

nnoremap <silent> <leader>m :call <SID>Compile()<CR>

function! s:PerlDoc(topic) abort
  if empty(a:topic)
    echohl WarningMsg
    echomsg 'Perldoc: no symbol under the cursor'
    echohl None
    return
  endif

  let l:output = systemlist('perldoc -f ' . shellescape(a:topic) . ' 2>&1')
  if v:shell_error
    let l:output = systemlist('perldoc ' . shellescape(a:topic) . ' 2>&1')
  endif
  if v:shell_error
    echohl WarningMsg
    echomsg 'Perldoc: no documentation found for ' . a:topic
    echohl None
    return
  endif

  let l:docbuf = bufnr('__Perldoc__')
  if l:docbuf == -1
    botright new
    silent file __Perldoc__
  elseif bufwinid(l:docbuf) != -1
    call win_gotoid(bufwinid(l:docbuf))
  else
    execute 'botright sbuffer ' . l:docbuf
  endif
  setlocal buftype=nofile bufhidden=wipe noswapfile
  setlocal modifiable
  silent %delete _
  call setline(1, l:output)
  setlocal nomodifiable
  setlocal nowrap
  normal! gg
  nnoremap <silent><buffer> q :close<CR>
endfunction

augroup perl_support
  autocmd!
  autocmd FileType perl nnoremap <silent><buffer> K :call <SID>PerlDoc(expand('<cword>'))<CR>
augroup END

if isdirectory(expand('~/.vim/plugged/ale'))
  call ale#linter#Define('perl', {
        \ 'name': 'psc',
        \ 'executable': '/Users/eax/.local/bin/psc',
        \ 'command': '%e check %s',
        \ 'callback': 'ale#handlers#gcc#HandleGCCFormat',
        \ 'output_stream': 'stderr',
        \ 'lint_file': 1,
        \ })
endif
