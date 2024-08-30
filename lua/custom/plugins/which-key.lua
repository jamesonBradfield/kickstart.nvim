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
      '<leader>c',
      function() end,
      desc = '[c]ode',
    },
    {
      '<leader>d',
      function() end,

      desc = '[d]ocument',
    },
    {
      '<leader>r',
      function() end,
      desc = '[r]ename',
    },
    {
      '<leader>s',
      function() end,
      desc = '[s]earch',
    },
    {
      '<leader>w',
      function() end,
      desc = '[w]orkspace',
    },
    {
      '<leader>k',
      function() end,
      desc = 'tele[k]asten',
    },
    {
      '<leader>t',
      function() end,
      desc = '[t]rouble',
    },
    {
      '<leader>C',
      function() end,
      desc = '[C]odeSnap',
    },
    {
      '<leader>T',
      function() end,
      desc = '[T]asks',
    },
    {
      '<leader>B',
      function() end,
      desc = '[B]uild',
    },
    -- {
    --   '<leader>b',
    --   function()
    --     require('which-key').show { loop = true, keys = '<leader>b' }
    --   end,
    --   desc = '󰬉󰯫󰰞󰯮󰯫󰰞',
    -- },
  },
}
