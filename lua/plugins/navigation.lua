local keys = require 'keys'

return {
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
        { '<leader>c', group = '[c]ode/symbols' },
        { '<leader>d', group = '[d]ebug' },
        { '<leader>e', group = '[e]rrors/trouble' },
        { '<leader>g', group = '[g]it' },
        { '<leader>h', group = '[h]arpoon/grapple' },
        { '<leader>k', group = '[k]telekasten' },
        { '<leader>q', group = '[q]sessions/quit' },
        { '<leader>s', group = '[s]earch/pickers' },
        { '<leader>t', group = '[t]erminals/aider' },
        { '<leader>u', group = '[u]tils' },
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
