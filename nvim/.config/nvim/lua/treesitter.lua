local treesitter = require('nvim-treesitter.configs')

treesitter.setup {
	ensure_installed = {
		'go',
		'lua',
		'json',
		'rust',
		'toml',
		'yaml'
	},
	highlight = {
		enable = true
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	indent = {
		enable = true
	},
	refactor = {
		highlight_definitions = { enable = true },
		smart_rename = {
			enable = true,
			keymaps = {
				smart_rename = "grr",
			},
		},
	}
}
