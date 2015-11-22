{ pkgs, base16 }:
{
  customRC = ''
filetype plugin indent on
syntax on

set nocompatible
set autoindent
set incsearch
set hlsearch
set ignorecase
set smartcase
set number
set showbreak=...
syntax on
set ruler
set smartindent
set tabstop=4
set shiftwidth=4
filetype on
set list listchars=tab:›—,trail:·,extends:>,precedes:<
set cursorline
"→›├−┄─₋-┅⇒
set t_Co=256
set tags=./tags;/
set laststatus=2
set encoding=utf-8
set background=dark

"Highlight trailing whitespace, tabs within words, and spaces before tabs
match ErrorMsg  /\s\+$\| \+\ze\t\|[^\t]\zs\t\+/
2match ErrorMsg        /\%81v.\+/

"Unsets the last search pattern after hitting enter
nnoremap <CR> :noh<CR><CR>

noremap j gj
noremap k gk

autocmd BufWinLeave * call clearmatches()

autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

autocmd Filetype html setlocal ts=4 sts=4 sw=4
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=4 sts=4 sw=4
autocmd Filetype yaml setlocal ft=text

autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
  '';
}
