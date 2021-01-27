local treesitter = require'nvim-treesitter.configs'

treesitter.setup {
	ensure_installed = {
		"go",
		"lua",
		"json",
		"rust",
		"toml",
		"yaml"
	},
	highlight = {
		enable = true
	},
	incremental_selection = {
		enable = false
	},
	indent = {
		enable = true
	},
}
