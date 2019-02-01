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

" General plugins
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Go plugins
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }

" Initialize plugin system
call plug#end()

"----------------------------------------------
" General Settings
"----------------------------------------------
set number relativenumber
set autowrite

augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

set completeopt+=noselect

let g:python3_host_prog  = '/usr/local/bin/python3'
let g:python3_host_skip_check = 1

let g:deoplete#enable_at_startup = 1
let g:netrw_home = '~/.cache/nvim'

autocmd BufWritePost *.json !jsonlint -q %

"----------------------------------------------
" Language Server Protocol Setup
"----------------------------------------------
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {}

nnoremap <F5> :call LanguageClient_contextMenu()<CR>

"----------------------------------------------
" Language: Golang
"----------------------------------------------
au FileType go set noexpandtab
au FileType go set shiftwidth=4
au FileType go set softtabstop=4
au FileType go set tabstop=4

" Run goimports when running gofmt
let g:go_fmt_command = "goimports"

" Enable syntax highlighting per default
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1

" Show the progress when running :GoCoverage
let g:go_echo_command_info = 1

" Show type information
let g:go_auto_type_info = 1

" Highlight variable uses
let g:go_auto_sameids = 1

" Add the failing test name to the output of :GoTest
let g:go_test_show_name = 1

" deoplete-go settings
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

