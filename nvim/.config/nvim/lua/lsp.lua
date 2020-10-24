local nvim_lsp = require('nvim_lsp')
local diagnostic = require('diagnostic')
local completion = require('completion')
local lsp_status = require('lsp-status')

local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  diagnostic.on_attach(client, bufnr)
  completion.on_attach(client, bufnr)
  lsp_status.on_attach(client, bufnr)
end

local servers = { 'gopls', 'rust_analyzer', 'sumneko_lua' }
for _, lsp in ipairs(servers) do
  lsp_status.register_progress()
  lsp_status.config({
    status_symbol = '',
    indicator_errors = '',
    indicator_warnings = '',
    indicator_info = '',
    indicator_hint = '',
    indicator_ok = '',
    spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  })
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = lsp_status.capabilities
}
end
