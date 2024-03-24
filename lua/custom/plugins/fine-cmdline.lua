return {
  'VonHeikemen/fine-cmdline.nvim',
  -- NOTE: FINECMDLINE IS ADDING THAT COOL SEARCH MENU FIGURE OUT HOW IT WORKS PARKER OR YOU ARE FIRED!!
  lazy = false,
  event = 'VeryLazy',
  keys = {
    {
      ':',
      mode = { 'n', 'x', 'o' },
      function()
        require('fine-cmdline').open {}
      end,
      desc = 'Open Command Line',
    },
    {
      ';',
      mode = { 'n', 'x', 'o' },
      function()
        require('fine-cmdline').open {}
      end,
      desc = 'Open Command Line',
    },
    {
      '<CR>',
      mode = { 'n', 'x', 'o' },
      function()
        require('fine-cmdline').open { default_value = '!' }
      end,
      desc = 'Open Bash',
    },
    -- ['<CR>'] = { '<cmd>FineCmdline ! <CR>', 'run bash' },
  },

  dependencies = { 'MunifTanjim/nui.nvim' },
  opts = {},
  config = function()
    require('fine-cmdline').setup()
  end,
}
