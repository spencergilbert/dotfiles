lua require('plugins')

autocmd BufWritePost plugins.lua PackerCompile
autocmd BufEnter * lua require('completion').on_attach()
autocmd FileType lua setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

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

nnoremap <Leader>en <cmd>lua require('telescope.builtin').find_files{ cwd = "~/.config/nvim/", find_command = { "fd", "-L", "--type", "f" }}<CR>
nnoremap <Leader>ts <cmd>lua require('telescope.builtin').treesitter(require('telescope.themes').get_dropdown({}))<CR>

nnoremap <Leader>dn <cmd>lua vim.lsp.diagnostic.goto_next { wrap = false }<CR>
sign define LspDiagnosticsSignError text= texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text= texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=

" TODO https://github.com/nvim-lua/completion-nvim/wiki/per-server-setup-by-lua
let g:completion_chain_complete_list = {
    \'go': [
    \    {'complete_items': ['lsp', 'path', 'ts']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
    \'lua': [
    \    {'complete_items': ['lsp', 'path', 'ts']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
    \'rust': [
    \    {'complete_items': ['lsp', 'path', 'ts']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \],
    \'default': [
    \    {'complete_items': ['buffer', 'path', 'ts']},
    \    {'mode': '<c-p>'},
    \    {'mode': '<c-n>'}
    \]
\}
