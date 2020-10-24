local builtin = require('el.builtin')
local extensions = require('el.extensions')
local lsp = require('el.plugins.lsp_status')
local sections = require('el.sections')
local subscribe = require('el.subscribe')

local generator = function()
	local segments = {}

	table.insert(segments, extensions.mode)
	table.insert(segments, sections.split)
	table.insert(segments, builtin.tail_file)
	table.insert(segments, sections.collapse_builtin{
		' ',
		builtin.modified_flag,
	})
	table.insert(segments, sections.split)
	table.insert(segments, lsp.segment)
	table.insert(segments, subscribe.buf_autocmd(
		"el_git_status",
		"BufWritePost",
		function(window, buffer)
			return extensions.git_changes(window, buffer)
		end
	))
	table.insert(segments, ' [')
	table.insert(segments, builtin.line)
	table.insert(segments, ' : ')
	table.insert(segments, builtin.column)
	table.insert(segments, '] ')
	table.insert(segments, sections.collapse_builtin{
		' [',
		builtin.help_list,
		builtin.readonly_list,
		'] ',
	})
	table.insert(segments, builtin.filetype)

	return segments
end
require("el").setup({generator = generator})
