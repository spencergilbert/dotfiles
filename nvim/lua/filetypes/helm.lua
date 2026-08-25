-- Detect Helm template files and assign the 'helm.tmpl' filetype.
-- This overrides the built-in '.tpl → smarty' detection when a .tpl file
-- is inside a Helm chart's templates/ directory.

vim.filetype.add({
	filename = {
		['_helpers.tpl'] = 'helm.tmpl',
		['helpers.tpl']  = 'helm.tmpl',
	},
	pattern = {
		['.*/templates/.*%.tpl$'] = 'helm.tmpl',
	},
})
