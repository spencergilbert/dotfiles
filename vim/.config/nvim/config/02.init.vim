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
