set number relativenumber

augroup numbertoggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
	autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

let g:deoplete#enable_at_startup = 1
autocmd BufWritePost *.json !jsonlint -q %
