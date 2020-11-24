local lspstatus = require('lsp-status')
local lspconfig = require('lspconfig')

lspstatus.config({
  status_symbol = '',
  indicator_errors = '',
  indicator_warnings = '',
  indicator_info = '',
  indicator_hint = '',
  indicator_ok = '',
  spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
})
lspstatus.register_progress()

local custom_attach = function(client)
  lspstatus.on_attach(client)

  -- Rust inlay hints
  if vim.api.nvim_buf_get_option(0, 'filetype') == 'rust' then
   vim.cmd [[autocmd InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua require('lsp_extensions').inlay_hints{ prefix = ' » ', highlight = "NonText" }]]
  end

  vim.cmd("setlocal omnifunc=v:lua.vim.lsp.omnifunc")
end

lspconfig.gopls.setup({
  on_attach = custom_attach,
  capabilities = lspstatus.capabilities,
})

lspconfig.sumneko_lua.setup({
  settings = {
    Lua = {
        diagnostics = {
          globals = {'vim'}
        },
      }
    },
  on_attach = custom_attach,
  capabilities = lspstatus.capabilities,
})

lspconfig.rust_analyzer.setup({
  on_attach = custom_attach,
  capabilities = lspstatus.capabilities,
})
