" vim-plug automatically
if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute "!curl -fLo  ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Initialize plugins with vim-plug
call plug#begin('~/.vim/plugged')

" All of tpope's plugins
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-rhubarb'

" Go development plugin
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Emmet plugin for HTML
Plug 'mattn/emmet-vim'

call plug#end()

" Keymap settings
map ; :
inoremap jk <Esc>
set pastetoggle=<F2>

" General settings
set sw=4      		" Set shift width to 4 globally
set tw=4      		" Set text width to 4 globally
set nu        		" Show line numbers
set relativenumber 	" Relative line numbers

" Cursor settings: change from block to thin in insert mode
if has("termguicolors")
  set termguicolors
endif
let &t_SI = "\e[6 q"  " Thin cursor in insert mode
let &t_EI = "\e[2 q"  " Block cursor in normal mode

" Remember the last position in a file
if has("autocmd")
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif
endif

" Language-specific settings
autocmd FileType c setlocal sw=4 ts=4 sts=4 expandtab
autocmd FileType perl setlocal sw=4 ts=4 sts=4 expandtab
autocmd FileType make setlocal sw=4 ts=4 sts=4 noexpandtab
autocmd FileType ruby setlocal sw=2 ts=2 sts=2 expandtab
autocmd FileType python setlocal sw=4 ts=4 sts=4 expandtab

" Plugin configurations
" Vim-go settings (optional, customize as needed)
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

