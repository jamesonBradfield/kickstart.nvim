-- ~/.config/nvim/lua/custom/plugins/godot-help.lua
-- (or wherever you keep your plugin configurations)

return {
  dir = '~/Github-Projects/godot-help/', -- Point to plugin root, not lua subdirectory
  lazy = false,
  enabled = false,
  name = 'godot-help',
  ft = { 'gdscript', 'cs' }, -- Load for GDScript and C# files
  config = function()
    require('godot-help').setup {
      -- Custom Godot path if auto-detection fails
      -- godot_path = "/path/to/your/godot/executable",

      -- Custom help documentation path
      -- help_path = "/path/to/godot/doc",

      -- Custom keymaps
      keymaps = {
        search_help = '<leader>gh', -- Search all classes
        search_class = '<leader>gc', -- Search within class
      },

      -- Enable/disable window picker
      window_picker = true,

      -- Enable debug output for troubleshooting
      debug = false,
    }

    -- Run diagnostics on startup to check setup
    vim.defer_fn(function()
      require('godot-help').diagnose()
    end, 1000)
  end,
}
