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
Plug 'christoomey/vim-tmux-navigator'
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
let mapleader = ","
set number relativenumber
set autowrite
set splitbelow
set splitright

augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

set completeopt+=noselect

let g:python3_host_skip_check = 1

let g:deoplete#enable_at_startup = 1
let g:netrw_home = '~/.cache/nvim'

autocmd BufWritePost *.json !jsonlint -q %

au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"----------------------------------------------
" Language Server Protocol Setup
"----------------------------------------------
" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {}
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

" vim-go shortcuts
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
noremap <leader>a :cclose<CR>

" run :GoBuild or :GoTestCompile based on the go file<Paste>
function! s:build_go_files()
	let l:file = expand('%')
	if l:file =~# '^\f\+_test\.go$'
		call go#test#Test(0, 1)
	elseif l:file =~# '^\f\+\.go$'
		call go#cmd#Build(0)
	endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <leader>c <Plug>(go-coverage-toggle)

" Run goimports when running gofmt
let g:go_fmt_command = "goimports"
let g:go_metalinter_autosave = 1
" let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_deadline = "5s"

" Enable syntax highlighting per default
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

" Show the progress when running :GoCoverage
let g:go_echo_command_info = 1

" Show type information
let g:go_auto_type_info = 1
set updatetime=100

" Highlight variable uses
let g:go_auto_sameids = 1

" Add the failing test name to the output of :GoTest
let g:go_test_show_name = 1

" deoplete-go settings
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

"----------------------------------------------
" Language: Elixir
"----------------------------------------------
" mix format on save
autocmd BufWritePost *.exs,*.ex silent :!mix format %
