unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

map ; :
inoremap jk <Esc>

" General sane defaults.
nnoremap q: <nop>
syntax off
set autoindent
set autoread
set backspace=2
set encoding=utf8
set ignorecase
set incsearch
set nobackup
set nocompatible
set nohlsearch
set noswapfile
set nowrap
set relativenumber
set scrolloff=4
set smartcase
set spelllang=en_us
set textwidth=72
set wildmenu

" Status Line enhancements.
set laststatus=2
set statusline=%f%m%=%y\ %{strlen(&fenc)?&fenc:'none'}\ %l:%c\ %L\ %P
hi StatusLine cterm=NONE ctermbg=black ctermfg=brown
hi StatusLineNC cterm=NONE ctermbg=black ctermfg=darkgray

" Commenting blocks of code.
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,go,scala   let b:comment_leader = '// '
  autocmd FileType sh,ruby,python   let b:comment_leader = '# '
  autocmd FileType conf,fstab       let b:comment_leader = '# '
  autocmd FileType lua              let b:comment_leader = '-- '
  autocmd FileType vim              let b:comment_leader = '" '
augroup END
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

" Language specific indentation.
filetype plugin indent on
autocmd Filetype make,go,c,cpp setlocal noexpandtab tabstop=4 shiftwidth=4
autocmd Filetype html,js,css setlocal expandtab tabstop=2 shiftwidth=2


" C
ab exs EXIT_SUCCESS
ab exf EXIT_FAILURE
ab null NULL
ab #i #include
ab stdio <stdio.h>
ab stdlib <stdlib.h>
ab forc for (int i = 0; i < limit; i++) {}

" Go
ab iferr if err != nil { return err }
ab fmtp fmt.Printf(
ab fmts fmt.Sprintf(

" Ruby
ab doend do \|\| end

" Perl
ab sub sub { }
ab forp for (my $i = 0; $i < $limit; $i++) { }
ab ifp if ($condition) { }

" Python
ab def def function_name():
ab ifmain if __name__ == '__main__':
ab cls class ClassName:
