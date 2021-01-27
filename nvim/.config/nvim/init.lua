-- Load modules
require("plugins")

vim.api.nvim_exec(
[[
autocmd BufWritePost plugins.lua PackerCompile
autocmd BufEnter * lua require'completion'.on_attach()

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" LSP provider to find the cursor word definition and reference
nnoremap <silent> gh <cmd>lua require'lspsaga.provider'.lsp_finder()<CR>

" Code action
nnoremap <silent><leader>ca <cmd>lua require('lspsaga.codeaction').code_action()<CR>

" Show hover doc
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>

" Preview definition
nnoremap <silent> gd <cmd>lua require'lspsaga.provider'.preview_definition()<CR>

" Jump diagnostics
nnoremap <silent> [e <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>
nnoremap <silent> ]e <cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>

" float terminal also you can pass the cli command in open_float_terminal function
nnoremap <silent> <A-d> <cmd>lua require'lspsaga.floaterm'.open_float_terminal()<CR>
tnoremap <silent> <A-d> <C-\><C-n>:lua require'lspsaga.floaterm'.close_float_terminal()<CR>

" Telescope
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
]],
false)

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

-- Avoid showing message extra message when using completion
vim.o.shortmess = "filnxtToOFc"

-- Tree-sitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
