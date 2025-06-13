-- ~/.config/nvim/lua/custom/plugins/godot-debug.lua
return {
  -- Development version (local path)
  {
    'godot-debug',
    enabled = true, -- Toggle this when developing
    lazy = false,
    dev = true,
    dir = '~/Github-Projects/godot-debug', -- Path to your project
    dependencies = {
      'folke/snacks.nvim', -- Direct dependency
      'mfussenegger/nvim-dap',
    },
    config = function()
      -- Add a debug statement to see if it's loading
      require('godot-debug').setup()
    end,
  },

  -- Released version (from GitHub)
  -- {
  --   'jamesonBradfield/godot-debug',
  --   enabled = false, -- Toggle this when you want to use the release version
  --   lazy = false,
  --   dependencies = {
  --     'folke/snacks.nvim',
  --   },
  --   config = function()
  --     require('godot-debug').setup()
  --   end,
  -- },
}
