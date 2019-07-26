"----------------------------------------------
" Plugin installation 
"----------------------------------------------
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
	silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
	  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim
endif

" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')

" Possible plugins
" https://github.com/JakeBecker/elixir-ls

" General plugins
Plug 'lotabout/skim', { 'dir': '~/.skim', 'do': './install' }
Plug 'lotabout/skim.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Go plugins
" Plug 'zchee/deoplete-go', { 'do': 'make'}
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }

" Elixir plugins
Plug 'elixir-editors/vim-elixir'

" Rust plugins
Plug 'rust-lang/rust.vim'

" Initialize plugin system
call plug#end()

"----------------------------------------------
" General Settings
"----------------------------------------------
let mapleader = ","
set number relativenumber
set autowrite
set splitbelow
set splitright

command! -bang -nargs=* Rg call fzf#vim#rg_interactive(<q-args>, fzf#vim#with_preview('right:50%:hidden', 'alt-h'))

augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

set completeopt+=noselect

let g:python3_host_skip_check = 1

let g:deoplete#enable_at_startup = 1

let g:netrw_home = '~/.cache/nvim'
let g:netrw_banner = 0
let g:netrw_liststyle = 3

autocmd BufWritePost *.json !jsonlint -q %

au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"----------------------------------------------
" Language Server Protocol Setup
"----------------------------------------------
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
	\ 'go': ['gopls'],
	\ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
	\ }

function LC_maps()
	if has_key(g:LanguageClient_serverCommands, &filetype)
		noremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
		noremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
		noremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
	endif
endfunction

autocmd FileType * call LC_maps()

"----------------------------------------------
" Language: Golang
"----------------------------------------------
" Go file settings
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

" gomt on save
autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()
"----------------------------------------------
" Language: Elixir
"----------------------------------------------
" mix format on save
autocmd BufWritePost *.exs,*.ex silent :!mix format %

"----------------------------------------------
" Language: Rust
"----------------------------------------------
" rustfmt on save
let g:rustfmt_autosave = 1
