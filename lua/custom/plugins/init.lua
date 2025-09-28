-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldtext = ''
vim.opt.foldcolumn = '0'
vim.opt.fillchars:append { fold = ' ' }
vim.g.python3_host_prog = '/home/jamie/.venv/bin/python3'
-- Load LSP configuration for Godot and OmniSharp
require 'lspconfig'
-- Remote server setup for notes
if vim.fn.argv()[0] == '--listen' then
  require('remote-server').setup()
end
return {}
