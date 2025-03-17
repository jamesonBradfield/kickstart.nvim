local spec = { -- Godot debugger integration
  'godot-debug', -- Local module
  dir = vim.fn.stdpath('config') .. '/lua/custom/godot-debug', -- Location of your module
  dependencies = {
    'mfussenegger/nvim-dap',
    'folke/snacks.nvim',
  },
  config = function()
    -- Initialize the godot debug module
    local godot_debug = require('godot-debug')
    godot_debug.setup()
  end,
  -- Only load for Godot project files
  ft = { 'gdscript', 'cs' },
}

return spec
