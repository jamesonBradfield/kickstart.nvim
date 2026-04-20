local keys = require 'keys'

return {
  {
    -- Telescope
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live Grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help Tags' },
    },
  },
  {
    -- Fzf-lua
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find Files' },
      { '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Live Grep' },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
      { '<leader>fh', '<cmd>FzfLua help_tags<cr>', desc = 'Help Tags' },
    },
  },
  {
    -- Persistence
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = keys.persistence,
  },
  {
    -- Grapple
    'cbochs/grapple.nvim',
    opts = { scope = 'git' },
    cmd = 'Grapple',
    keys = keys.grapple,
  },
  {
    -- Flash
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = keys.flash,
  },
  {
    -- Smart Splits
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    keys = keys.smart_splits,
    opts = { multiplexer_integration = 'wezterm' },
  },
  {
    -- Which-Key
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      spec = {
        { '<leader>c', group = 'Code', mode = { 'n', 'x' } },
        { '<leader>d', group = 'Document' },
        { '<leader>g', group = 'Git' },
        { '<leader>q', group = 'Session/Quit' },
        { '<leader>s', group = 'Search' },
        { '<leader>x', group = 'Trouble/Diagnostics' },
        { '<leader>k', group = 'Telekasten' },
        { '<leader>t', group = 'Toggle/Terminal' },
      },
    },
    keys = keys.which_key,
  },
  {
    -- Todo-Comments
    'folke/todo-comments.nvim',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = keys.todo_comments,
    opts = {},
  },
}
