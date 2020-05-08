"  _       _ _         _           
" (_)     (_) |       (_)          
"  _ _ __  _| |___   ___ _ __ ___  
" | | '_ \| | __\ \ / / | '_ ` _ \ 
" | | | | | | |_ \ V /| | | | | | |
" |_|_| |_|_|\__(_)_/ |_|_| |_| |_|
                                  

" plugins {{{
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
	silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
	  \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim
endif

" specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')

Plug 'cocopon/iceberg.vim'
Plug 'cocopon/shadeline.vim'

" coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" initialize plugin system
call plug#end()
" }}}


" encoding {{{
set encoding=utf-8
scriptencoding utf-8
" }}}


" file types {{{
augroup vimrc_filetype
	autocmd!
	autocmd BufNewFile,BufRead *.go 	setlocal tabstop=4 shiftwidth=4
augroup END
" }}}


" misc {{{
let s:colorscheme = 'iceberg'
let mapleader = ","

" indent
set autoindent
if exists('&breakindent')
	set breakindent
endif
set noexpandtab
set nosmartindent
set shiftround
set shiftwidth=4
set tabstop=4
" }}}


" shadeline {{{
let g:shadeline = {}
let g:shadeline.active = {
	\   'left':  ['fname', 'flags'],
	\   'right': [
    \         ['ff', 'fenc', 'ft'],
    \         'ruler',
    \       ]
	\ }
let g:shadeline.inactive = {
	\   'left':  ['fname', 'flags']
	\ }
" }}}


" colorscheme {{{
if !has('gui_running')
	syntax enable
	execute printf('colorscheme %s', s:colorscheme)
else
	augroup vimrc_colorscheme
		autocmd!
		execute printf('autocmd GUIEnter * colorscheme %s', s:colorscheme)
	augroup END
endif

if $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit'
	set termguicolors
endif
" }}}
