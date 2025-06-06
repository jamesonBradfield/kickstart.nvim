return {
  -- Development version (local path)
  {
    'gdunit4',
    enabled = true, -- Toggle this when developing
    lazy = false,
    dev = true,
    dir = '~/Github-Projects/gdunit.nvim', -- Path to your project
    dependencies = {
      'folke/snacks.nvim', -- Direct dependency
      'mfussenegger/nvim-dap',
    },
    config = function()
      -- Add a debug statement to see if it's loading
      vim.notify 'Loading gdunit4 development version'
      require('gdunit4').setup()
      vim.keymap.set('n', '<leader>u', '', { desc = 'gd[u]nit' })
      vim.keymap.set('n', '<leader>ur', '<cmd>GdUnit run<CR>', { desc = 'gd[u]nit run' })
      vim.keymap.set('n', '<leader>uc', '<cmd>GdUnit create<CR>', { desc = 'gd[u]nit create' })
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
