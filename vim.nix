{ pkgs, ... }:

{
  nixpkgs.config.vim.ftNixSupport = true;
  programs.vim.defaultEditor      = true;

  environment.systemPackages = [
    (pkgs.vim_configurable.customize {
      name = "vim";

      vimrcConfig = {
        vam = {
          knownPlugins = pkgs.vimPlugins;
          pluginDictionaries = [{
            names = [ "rust-vim" ];
          }];
        };

        customRC = ''
          source $VIMRUNTIME/defaults.vim

          set hlsearch
          set ignorecase
          set smartcase
          set number
          set smartindent
          set tabstop=4
          set shiftwidth=4
          set list listchars=tab:›—,trail:·,extends:>,precedes:<
          set background=dark

          set t_Co=256
          set encoding=utf-8

          "Highlight trailing whitespace, tabs within words, and spaces before tabs
          match ErrorMsg  /\s\+$\| \+\ze\t\|[^\t]\zs\t\+/
          "2match ErrorMsg        /\%81v.\+/

          "Unsets the last search pattern after hitting enter
          nnoremap <CR> :noh<CR><CR>

          noremap j gj
          noremap k gk

          autocmd Filetype html setlocal ts=4 sts=4 sw=4
          autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
          autocmd Filetype javascript setlocal ts=4 sts=4 sw=4
          autocmd Filetype yaml setlocal ft=text

          autocmd BufNewFile,BufFilePre,BufRead *.ign set filetype=json
          autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

          autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/
          autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!
        '';
      };
    })
  ];
}
