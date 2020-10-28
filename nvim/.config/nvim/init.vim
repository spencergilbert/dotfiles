lua require('plugins')

autocmd BufWritePost plugins.lua PackerCompile
autocmd FileType lua setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" Tree-sitter code folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" Telescope
nnoremap <Leader>f <cmd>lua require'telescope.builtin'.git_files{}<CR>
nnoremap <Leader>g <cmd>lua require'telescope.builtin'.live_grep{}<CR>
nnoremap <Leader>en <cmd>lua require'telescope.builtin'.find_files{ cwd = "~/.dotfiles/nvim/.config/nvim/" }<CR>
nnoremap <Leader>ts <cmd>lua require'telescope.builtin'.treesitter(require('telescope.themes').get_dropdown({}))<CR>

" diagnostic-nvim
" move to lua
call sign_define("LspDiagnosticsErrorSign", {"text" : "", "texthl" : "LspDiagnosticsError"})
call sign_define("LspDiagnosticsWarningSign", {"text" : "", "texthl" : "LspDiagnosticsWarning"})
call sign_define("LspDiagnosticsInformationSign", {"text" : "", "texthl" : "LspDiagnosticsInformation"})
call sign_define("LspDiagnosticsHintSign", {"text" : "", "texthl" : "LspDiagnosticsHint"})
