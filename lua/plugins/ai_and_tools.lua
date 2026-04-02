local keys = require 'keys'

return {
  {
    -- Gitsigns
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 500 },
    },
    keys = {
      {
        '<leader>gh',
        function()
          require('gitsigns').preview_hunk()
        end,
        desc = 'Git: Preview Hunk',
      },
      {
        '<leader>gs',
        function()
          require('gitsigns').stage_hunk()
        end,
        desc = 'Git: Stage Hunk',
      },
      {
        '<leader>gr',
        function()
          require('gitsigns').reset_hunk()
        end,
        desc = 'Git: Reset Hunk',
      },
    },
  },
  {
    -- Neogit
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Open Neogit (Status)' },
      { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Neogit: Commit' },
    },
    config = function()
      require('neogit').setup { integrations = { diffview = true }, disable_commit_confirmation = true }
    end,
  },
  {
    -- Telekasten
    'jamesonBradfield/telekasten.nvim',
    enabled = false,
    lazy = false,
    dir = os.getenv 'USERPROFILE' .. '/projects/nvim/telekasten.nvim',
    opts = { home = vim.fn.expand '~/zettelkasten', backend = 'snacks' },
    keys = keys.telekasten,
  },
}
