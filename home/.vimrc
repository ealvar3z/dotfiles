vim9script

# =========================
# Core UI + behavior
# =========================
set nocompatible exrc secure
filetype plugin indent on
syntax off

call plug#begin()
	Plug 'tpope/vim-commentary'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'dense-analysis/ale'
	Plug 'ealvar3z/ed.vim'
call plug#end()

if executable('rg')
	set grepprg=rg\ --vimgrep\ --smart-case
	set grepformat=%f:%l:%c:%m
endif

set ruler
set wildmenu
set hidden
set updatetime=200

# Keep view centered (avoid needing zz, including in insert)
set scrolloff=999
set sidescrolloff=8

# tmux/terminal friendliness
set ttimeout
set ttimeoutlen=10
if exists('+termguicolors')
  set termguicolors
endif

colorscheme ed

# =========================
# Search / replace UX
# =========================
set magic
set ignorecase
set smartcase
set incsearch
set hlsearch
if exists('+inccommand')
  set inccommand=split
endif

&t_SI = "\<Esc>[6 q"
&t_EI = "\<Esc>[2 q"


# =========================
# Leader + mappings
# =========================
g:mapleader = "\<Space>"

# clear highlight
nnoremap <leader>h :nohlsearch<CR>

# jk to escape
inoremap jk <Esc>

# ; -> : (sacrifices "repeat f/F/t/T")
nnoremap ; :
vnoremap ; :
onoremap ; :

# Completion navigation on Tab / Shift-Tab (when popup menu is visible)
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<BS>"

# =========================
# C / NetBSD KNF-ish settings (internal Vim indent)
# =========================
def SetKNFC(): void
  setlocal noexpandtab
  setlocal tabstop=8
  setlocal shiftwidth=4
  setlocal softtabstop=4

  setlocal cindent
  setlocal cinoptions=:0,l1,t0,(0,W4,g0,N-s

  setlocal textwidth=80
  setlocal colorcolumn=+1

  # Prefer internal reindent via '=' (no external equalprg)
  setlocal equalprg=
enddef

# Build: prefer make if a Makefile exists, else compile current file
def SetCMakeprg(): void
  if filereadable('Makefile') || filereadable('makefile') || filereadable('GNUmakefile')
    setlocal makeprg=make
  else
    setlocal makeprg=cc\ -std=c23\ -Wall\ -Wextra\ -Wpedantic\ -O0\ -g\ %
  endif
enddef

augroup c_netbsd
  autocmd!
  autocmd FileType c,cpp SetKNFC()
  autocmd FileType c,cpp SetCMakeprg()
augroup END

# =========================
# Go / Python settings
# =========================
def SetGo(): void
  setlocal noexpandtab
  setlocal tabstop=8
  setlocal shiftwidth=8
  setlocal softtabstop=8
  setlocal textwidth=0
enddef

def SetGoMakeprg(): void
  setlocal makeprg=go\ test\ ./...
enddef

def SetPython(): void
  setlocal expandtab
  setlocal tabstop=4
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal textwidth=88
  setlocal colorcolumn=+1
enddef

def SetPythonMakeprg(): void
  setlocal makeprg=python3\ %
enddef

augroup go_python
  autocmd!
  autocmd FileType go SetGo()
  autocmd FileType go SetGoMakeprg()
  autocmd FileType python SetPython()
  autocmd FileType python SetPythonMakeprg()
augroup END

# =========================
# Quickfix workflow
# =========================
nnoremap <leader>q :copen<CR>
nnoremap <leader>Q :cclose<CR>
nnoremap <Leader>e :ALEPopulateQuickfix<CR>:sleep 100m<CR>:copen<CR>
nnoremap <Leader>w :silent! grep! <cword> \| cwindow \| redraw!<CR>
nnoremap ,n :cnext<CR>
nnoremap ,p :cprev<CR>
nnoremap ,0 :cfirst<CR>
nnoremap ,$ :clast<CR>

nnoremap <C-b> :CtrlpBuffer<CR>
nnoremap <C-k> :ALEHover<CR>
nnoremap <C-j> :ALEDetail<CR>

nmap <silent> gr :ALEFindReferences -quickfix<CR>:sleep 100m<CR>:copen<CR>
nmap <silent> gd :ALEGoToDefinition<CR>
nmap <silent> re :ALERename<CR>

g:ctrlp_use_caching = 0
g:ctrlp_working_path_mode = 'ra'
g:ale_hover_to_floating_preview = 1
g:ale_detail_to_floating_preview = 1
g:ale_floating_window_border = 0
g:ale_virtualtext_cursor = 0
g:ale_set_quickf = 1

# build + open quickfix
nnoremap <leader>m :silent make \| copen<CR>
