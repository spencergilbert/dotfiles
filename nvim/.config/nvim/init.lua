-- Load modules
require'plugins'

local keymap = require'astronauta.keymap'

vim.api.nvim_exec(
[[
autocmd BufEnter * lua require'completion'.on_attach()
autocmd BufWritePost plugins.lua PackerCompile
autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)

autocmd FileType lua setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
]],
false)

-- LSP finder
keymap.nnoremap { 'gh', function() require'lspsaga.provider'.lsp_finder() end, silent = true }

-- Code action
keymap.nnoremap { '<leader>ca', function() require'lspsaga.codeaction'.code_action() end, silent = true }

-- Hover doc
keymap.nnoremap { 'K', function() require'lspsaga.hover'.render_hover_doc() end, silent = true }
keymap.nnoremap { 'C-f', function() require'lspsaga.action'.smart_scroll_with_saga(1) end, silent = true }
keymap.nnoremap { 'C-b', function() require'lspsaga.action'.smart_scroll_with_saga(-1) end, silent = true }

-- Signature help
keymap.nnoremap { 'gs', function() require'lspsaga.signaturehelp'.signature_help() end, silent = true }

-- Rename
keymap.nnoremap { 'gr', function() require'lspsaga.rename'.rename() end, silent = true}

-- Preview definition
keymap.nnoremap { 'gd', function() require'lspsaga.provider'.preview_definition() end, silent = true }

-- Jump diagnostics
keymap.nnoremap { '<leader>cd', function() require'lspsaga.diagnostic'.show_line_diagnostics() end, silent = true }
keymap.nnoremap { '[e', function() require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev() end, silent = true }
keymap.nnoremap { ']e', function() require'lspsaga.diagnostic'.lsp_jump_diagnostic_next() end, silent = true }

-- Float terminal
keymap.nnoremap { '<A-d>', function() require'lspsaga.floaterm'.open_float_terminal() end, silent = true }
keymap.tnoremap { '<A-d>', function() require'lspsaga.floaterm'.close_float_terminal() end, silent = true }

-- Telescope
keymap.nnoremap { '<leader>ff', function() require'telescope.builtin'.find_files() end }
keymap.nnoremap { '<leader>fg', function() require'telescope.builtin'.live_grep() end }
keymap.nnoremap { '<leader>fb', function() require'telescope.builtin'.buffers({ show_all_buffers = true }) end }
keymap.nnoremap { '<leader>fh', function() require'telescope.builtin'.help_tags() end }

-- Use <Tab> and <S-Tab> to navigate popup menu
-- keymap.inoremap { '<expr> <Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]]}
-- keymap.inoremap { '<expr> <S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]]}

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

-- Avoid showing message extra message when using completion
vim.o.shortmess = "filnxtToOFc"

-- Tree-sitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
