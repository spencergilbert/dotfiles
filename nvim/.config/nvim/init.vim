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
nnoremap <Leader>ff <cmd>Telescope find_files<CR>
nnoremap <Leader>fg <cmd>Telescope live_grep<CR>
nnoremap <Leader>fb <cmd>Telescope buffers<CR>
nnoremap <Leader>fh <cmd>Telescope help_tags<CR>

nnoremap <Leader>en <cmd>lua require'telescope.builtin'.find_files{ cwd = "~/.config/nvim/", find_command = { "fd", "-L", "--type", "f" }}<CR>
nnoremap <Leader>ts <cmd>lua require'telescope.builtin'.treesitter(require('telescope.themes').get_dropdown({}))<CR>

nnoremap <Leader>dn <cmd>lua vim.lsp.diagnostic.goto_next { wrap = false }<CR>
" diagnostic-nvim
" move to lua
call sign_define("LspDiagnosticsErrorSign", {"text" : "", "texthl" : "LspDiagnosticsError"})
call sign_define("LspDiagnosticsWarningSign", {"text" : "", "texthl" : "LspDiagnosticsWarning"})
call sign_define("LspDiagnosticsInformationSign", {"text" : "", "texthl" : "LspDiagnosticsInformation"})
call sign_define("LspDiagnosticsHintSign", {"text" : "", "texthl" : "LspDiagnosticsHint"})

let g:completion_chain_complete_list = {
    \'default': [
    \    {'complete_items': ['lsp', 'snippet', 'buffers', 'ts']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \]
\}
