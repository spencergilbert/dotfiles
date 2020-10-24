lua require 'init'

" Statusline
set noshowmode

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
nnoremap <Leader>p <cmd>lua require'telescope.builtin'.git_files{}<CR>

nnoremap <Leader>en <cmd>lua require'telescope.builtin'.find_files{ cwd = "~/.config/nvim/" }<CR>
