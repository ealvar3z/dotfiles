set nocompatible
set backspace=indent,eol,start
set hidden
set history=1000
set viminfo='100,<50,s10,h
set ruler
set showcmd
set wildmenu
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
set incsearch
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

syntax on
filetype plugin indent on

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

let s:perl_compile = {}

function! s:PerlCompileRefresh(state, status) abort
  call setqflist([], 'r', {
        \ 'id': a:state.qfid,
        \ 'title': a:state.title,
        \ 'lines': a:state.lines,
        \ 'efm': a:state.efm,
        \ })
  let l:items = getqflist({'id': a:state.qfid, 'items': 1}).items
  call insert(l:items, {'text': a:status, 'valid': 0})
  call setqflist([], 'r', {
        \ 'id': a:state.qfid,
        \ 'title': a:state.title,
        \ 'items': l:items,
        \ })
endfunction

function! s:PerlCompileOutput(state, channel, message) abort
  if !empty(a:message)
    call add(a:state.lines, a:message)
    call s:PerlCompileRefresh(a:state, 'Perl compile running...')
  endif
endfunction

function! s:PerlCompileFinish(state) abort
  if !get(a:state, 'closed', 0) || !has_key(a:state, 'exit_status')
    return
  endif

  if get(a:state, 'cancelled', 0)
    call s:PerlCompileRefresh(a:state, 'Perl compile cancelled')
    return
  endif

  call setqflist([], 'r', {
        \ 'id': a:state.qfid,
        \ 'title': a:state.title,
        \ 'lines': a:state.lines,
        \ 'efm': a:state.efm,
        \ })
  let l:items = getqflist({'id': a:state.qfid, 'items': 1}).items
  let l:valid = filter(copy(l:items), 'get(v:val, "valid", 0)')
  if a:state.exit_status == 0
    let l:status = empty(l:valid)
          \ ? 'Perl syntax check finished successfully'
          \ : 'Perl syntax check finished with warnings'
  else
    let l:status = printf('Perl compile finished with status %d', a:state.exit_status)
  endif
  call insert(l:items, {'text': l:status, 'valid': 0})
  call setqflist([], 'r', {
        \ 'id': a:state.qfid,
        \ 'title': a:state.title,
        \ 'items': l:items,
        \ })
  echomsg l:status
endfunction

function! s:PerlCompileClosed(state, channel) abort
  let a:state.closed = 1
  call s:PerlCompileFinish(a:state)
endfunction

function! s:PerlCompileExited(state, job, status) abort
  let a:state.exit_status = a:status
  call s:PerlCompileFinish(a:state)
endfunction

function! s:PerlCompile() abort
  let l:path = expand('%:p')
  if empty(l:path)
    echohl ErrorMsg
    echomsg 'PerlCompile: the current buffer has no file name'
    echohl None
    return
  endif

  try
    silent update
  catch
    echohl ErrorMsg
    echomsg 'PerlCompile: could not save the current buffer'
    echohl None
    return
  endtry

  if has_key(s:perl_compile, 'job')
        \ && job_status(s:perl_compile.job) ==# 'run'
    let s:perl_compile.cancelled = 1
    call job_stop(s:perl_compile.job)
  endif

  let l:title = 'perl -Wc ' . l:path
  call setqflist([], ' ', {
        \ 'title': l:title,
        \ 'items': [{'text': 'Perl compile starting...', 'valid': 0}],
        \ })
  let l:qfid = getqflist({'id': 0}).id
  let l:state = {
        \ 'lines': [],
        \ 'qfid': l:qfid,
        \ 'title': l:title,
        \ 'efm': &l:errorformat,
        \ }
  let s:perl_compile = l:state

  let l:winid = win_getid()
  botright copen 10
  call win_gotoid(l:winid)

  let l:state.job = job_start(['perl', '-Wc', l:path], {
        \ 'out_mode': 'nl',
        \ 'err_mode': 'nl',
        \ 'out_cb': function('<SID>PerlCompileOutput', [l:state]),
        \ 'err_cb': function('<SID>PerlCompileOutput', [l:state]),
        \ 'close_cb': function('<SID>PerlCompileClosed', [l:state]),
        \ 'exit_cb': function('<SID>PerlCompileExited', [l:state]),
        \ })
  if job_status(l:state.job) ==# 'fail'
    let l:state.closed = 1
    let l:state.exit_status = -1
    call s:PerlCompileFinish(l:state)
  endif
endfunction

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
  autocmd FileType perl compiler perl
  autocmd FileType perl setlocal makeprg=perl\ -Wc\ %:S
  autocmd FileType perl command! -buffer PerlCompile call <SID>PerlCompile()
  autocmd FileType perl nnoremap <silent><buffer> <leader>m :PerlCompile<CR>
  autocmd FileType perl nnoremap <silent><buffer> K :call <SID>PerlDoc(expand('<cword>'))<CR>
augroup END
