set number
set ruler

autocmd BufWritePost *.json !jsonlint -q %
