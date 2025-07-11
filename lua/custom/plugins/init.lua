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
require('auto-grapple').setup()

-- Neovim server setup for Godot
local function setup_godot_server()
  local pipepath

  if vim.fn.has 'win32' == 1 then
    -- Windows named pipe format
    pipepath = '\\\\.\\pipe\\godot-nvim'
  else
    -- Unix socket format
    pipepath = vim.fn.stdpath 'cache' .. '/godot.pipe'
  end

  -- Only start server if it doesn't exist
  local success, server_name = pcall(vim.fn.serverstart, pipepath)
  if success then
    vim.g.godot_server_pipe = server_name
  else
    -- Fallback: let Neovim choose the address
    local fallback_server = vim.fn.serverstart()
    if fallback_server then
      vim.g.godot_server_pipe = fallback_server
      print('Godot server started on: ' .. fallback_server)
    end
  end
end

-- Call the setup function
setup_godot_server()

-- Godot LSP configuration
local lspconfig = require 'lspconfig'
lspconfig.gdscript.setup {
  name = 'godot',
  cmd = { 'nc', 'localhost', '6005' }, -- Default Godot LSP port
  filetypes = { 'gdscript' },
  root_dir = lspconfig.util.root_pattern 'project.godot',
}

-- Godot-specific settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gdscript',
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = false -- Godot prefers tabs

    -- Godot keybindings
    local opts = { buffer = true, silent = true }
    vim.keymap.set('n', '<F5>', '<cmd>!godot --path . %<CR>', opts)
    vim.keymap.set('n', '<F6>', '<cmd>!godot --path .<CR>', opts)
  end,
})
return {}
