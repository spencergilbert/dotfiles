-- Detect Helm template files and assign the 'helm.tmpl' filetype.
-- This overrides the built-in '.tpl → smarty' detection when a .tpl file
-- is inside a Helm chart's templates/ directory.
-- Detect Helm templates and values files, but only when they belong to a 
-- chart. These patterns override Neovim's extension-based filetype detection.
local function in_helm_chart(filetype)
	return function(path)
		if vim.fs.root(path, 'Chart.yaml') then
			return filetype
		end
	end
end

vim.filetype.add({
	pattern = {
		['.*/templates/.*%.tpl$'] = in_helm_chart('helm'),
		['.*/templates/.*%.ya?ml$'] = in_helm_chart('helm'),
		[',*/values[^/]*%.ya?ml$'] = in_helm_chart('yaml.helm-values'),
	},
})
