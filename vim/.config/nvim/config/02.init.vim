set number
set ruler

let g:deoplete#enable_at_startup = 1
autocmd BufWritePost *.json !jsonlint -q %
