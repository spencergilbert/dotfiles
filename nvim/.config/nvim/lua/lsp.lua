local lspconfig = require'lspconfig'
local saga = require'lspsaga'

local system_name
if vim.fn.has('mac') == 1 then
	system_name = "macOS"
elseif vim.fn.has('unix') == 1 then
	system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
	system_name = "Windows"
else
	print("Unsupported system for sumneko")
end

-- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

lspconfig.gopls.setup {
	on_attach = require'completion'.on_attach;
  settings = {
    gopls = {
      analyses = {
        fieldalignment = true,
        unusedparams = true,
      },
      gofumpt = true,
      staticcheck = true,
    },
  },
}

lspconfig.sumneko_lua.setup {
	cmd = {sumneko_binary, "-E", sumneko_root_path.."/main.lua"};
	on_attach = require'completion'.on_attach;
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = vim.split(package.path, ';'),
			},
			diagnostics = {
				globals = {'vim'},
			},
			workspace = {
				library = {
					[vim.fn.expand('$VIMRUNTIME/lua')] = true,
					[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
				},
			},
		},
	},
}

lspconfig.rust_analyzer.setup {
	on_attach = require'completion'.on_attach;
	settings = {
		["rust-analyzer"] = {}
	}
}

lspconfig.terraformls.setup {
	on_attach = require'completion'.on_attach;
	filetypes = { "terraform", "tf", "hcl" };
}

saga.init_lsp_saga {}
