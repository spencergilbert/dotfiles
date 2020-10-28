local diagnostic = require('diagnostic')
local completion = require('completion')
local lsp_status = require('lsp-status')
local nvim_lsp = require('nvim_lsp')

lsp_status.config({
  status_symbol = '',
  indicator_errors = '',
  indicator_warnings = '',
  indicator_info = '',
  indicator_hint = '',
  indicator_ok = '',
  spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
})
lsp_status.register_progress()

local custom_attach = function(client)
  completion.on_attach(client)
  diagnostic.on_attach(client)
  lsp_status.on_attach(client)

  -- Rust inlay hints
  if vim.api.nvim_buf_get_option(0, 'filetype') == 'rust' then
   vim.cmd [[autocmd BufEnter,BufWritePost <buffer> :lua require('lsp_extensions.inlay_hints').request { aligned = true, prefix = " » " }]]
  end

  vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")
end

nvim_lsp.gopls.setup({
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities,
})

nvim_lsp.rust_analyzer.setup({
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities,
})

nvim_lsp.sumneko_lua.setup({
  settings = {
    Lua = {
        diagnostics = {globals = {'vim'}},
      }
    },
  on_attach = custom_attach,
  capabilities = lsp_status.capabilities,
})
