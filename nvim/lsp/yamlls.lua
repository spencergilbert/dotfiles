return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  root_markers = { '.git' },
  settings = {
	  redhat = {
		  telemetry = {
			  enabled = false,
		  },
	  },
	  yaml = {
		  schemaStore = {
			  enable = false,
		  },
	  },
  },
}
