-- ~/.config/nvim/lua/custom/plugins/godot-debug.lua
return {
  -- Development version (local path)
  {
    'godot-debug',
    enabled = true, -- Toggle this when developing
    lazy = false,
    dev = true,
    dir = vim.fn.expand '~/Github-Projects/godot-debug', -- Path to your project
    dependencies = {
      'folke/snacks.nvim', -- Direct dependency
      'mfussenegger/nvim-dap',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      -- Add a debug statement to see if it's loading
      print 'Loading local godot-debug from dev path'
      require('godot-debug').setup()
    end,
  },

  -- Released version (from GitHub)
  -- {
  --   'jamesonBradfield/godot-debug.nvim',
  --   enabled = true, -- Toggle this when you want to use the release version
  --   lazy = false,
  --   dependencies = {
  --     'folke/snacks.nvim',
  --   },
  --   config = function()
  --     require('godot-debug').setup()
  --   end,
  -- },
}
