local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

 local plugins = require('plugins').plugins

 require 'opts'

   require('lazy').setup(plugins)

vim.keymap.set('n', '<leader>v', function()
  local socket = vim.v.servername
  -- Escape backslashes for shell
  socket = socket:gsub("\\", "\\\\")
  local cmd = 'pwsh -NoProfile -ExecutionPolicy Bypass -File "C:/Users/jamie/bin/ducky.ps1" --nvim-socket "' .. socket .. '"'
  
  if package.loaded["snacks"] then
      -- Use toggle to allow hiding without killing
      Snacks.terminal.toggle(cmd, { 
        win = { 
          position = "float", 
          border = "rounded",
          width = 0.8,
          height = 0.8,
          title = " 🦆 Voice Ducky ",
          title_pos = "center"
        },
        interactive = true,
        singleton = true -- Keep one instance running
      })
  else
      vim.cmd("vsplit | terminal " .. cmd)
  end
end, { desc = "Voice Ducky" })
