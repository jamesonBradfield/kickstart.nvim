return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    preset = 'helix',
  },
  keys = {
    {
      '<leader>s',
      function() end,
      desc = '[s]earch',
    },
    {
      '<leader>k',
      function() end,
      desc = 'tele[k]asten',
    },
    {
      '<leader>u',
      function() end,
      desc = '[u]nit test',
    },
    {
      '<leader>t',
      function() end,
      desc = '[t]ab',
    },
    {
      '<leader>g',
      function() end,
      desc = '[g]it',
    },
    {
      '<leader>l',
      function() end,
      desc = '[l]sp',
    },

    -- Main FZF group
    {
      '<leader>f',
      function() end,
      desc = '[f]ind',
    },
  },
}
