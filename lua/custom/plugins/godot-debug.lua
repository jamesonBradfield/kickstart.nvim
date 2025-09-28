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
    },
    config = function()
      require('godot-debug').setup {
        exclude_dirs = { 'addons/', 'src/' },
        scene_cache_file = vim.fn.stdpath 'cache' .. '/godot_last_scene.txt',
        debug_mode = true,
        auto_detect = true,
        ignore_build_errors = {
          "GdUnit.*Can't establish server.*Already in use",
          'Resource file not found: res://<.*Texture.*>',
        },
        buffer_reuse = true,
        build_timeout = 120,
        show_build_output = true,
      }
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
