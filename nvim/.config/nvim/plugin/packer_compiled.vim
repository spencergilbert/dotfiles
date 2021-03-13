" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
local package_path_str = "/home/sgilbert/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/sgilbert/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/sgilbert/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/sgilbert/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/sgilbert/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

_G.packer_plugins = {
  ["astronauta.nvim"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/astronauta.nvim"
  },
  ["completion-nvim"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/completion-nvim"
  },
  dracula = {
    config = { "\27LJ\2\nW\0\0\3\0\5\0\t6\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\0\0009\0\3\0'\2\4\0B\0\2\1K\0\1\0\24colorscheme dracula\bcmd\18termguicolors\6o\bvim\0" },
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/dracula"
  },
  ["galaxyline.nvim"] = {
    config = { "\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15statusline\frequire\0" },
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/galaxyline.nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/lspsaga.nvim"
  },
  ["nvim-jqx"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/nvim-jqx"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n#\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\blsp\frequire\0" },
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15treesitter\frequire\0" },
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/opt/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["telescope-github.nvim"] = {
    config = { "\27LJ\2\nG\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\agh\19load_extension\14telescope\frequire\0" },
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/telescope-github.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-vinegar"] = {
    config = { "\27LJ\2\n:\0\0\2\0\4\0\0056\0\0\0009\0\1\0'\1\3\0=\1\2\0K\0\1\0\18~/.cache/nvim\15netrw_home\6g\bvim\0" },
    loaded = true,
    path = "/home/sgilbert/.local/share/nvim/site/pack/packer/start/vim-vinegar"
  }
}

-- Config for: galaxyline.nvim
try_loadstring("\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15statusline\frequire\0", "config", "galaxyline.nvim")
-- Config for: nvim-lspconfig
try_loadstring("\27LJ\2\n#\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\blsp\frequire\0", "config", "nvim-lspconfig")
-- Config for: vim-vinegar
try_loadstring("\27LJ\2\n:\0\0\2\0\4\0\0056\0\0\0009\0\1\0'\1\3\0=\1\2\0K\0\1\0\18~/.cache/nvim\15netrw_home\6g\bvim\0", "config", "vim-vinegar")
-- Config for: telescope-github.nvim
try_loadstring("\27LJ\2\nG\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\agh\19load_extension\14telescope\frequire\0", "config", "telescope-github.nvim")
-- Config for: dracula
try_loadstring("\27LJ\2\nW\0\0\3\0\5\0\t6\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\0\0009\0\3\0'\2\4\0B\0\2\1K\0\1\0\24colorscheme dracula\bcmd\18termguicolors\6o\bvim\0", "config", "dracula")
-- Config for: nvim-treesitter
try_loadstring("\27LJ\2\n*\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\15treesitter\frequire\0", "config", "nvim-treesitter")
END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
