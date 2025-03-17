return {
  'renerocksai/telekasten.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'renerocksai/calendar-vim',
    'nvim-telescope/telescope-symbols.nvim',
    'mzlogin/vim-markdown-toc',
    {
      'nvim-telekasten/calendar-vim',
      config = function()
        vim.keymap.del('n', '<leader>cal')
      end,
    },
    {
      'MeanderingProgrammer/markdown.nvim',
      name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
      dependencies = {
        'nvim-treesitter/nvim-treesitter', -- Mandatory
        'nvim-tree/nvim-web-devicons', -- Optional but recommended
      },
      config = function()
        require('render-markdown').setup {}
      end,
    },
  },
  config = function()
    require('telekasten').setup {
      auto_set_filetype = false,
      -- auto-set telekasten syntax: if false, the telekasten syntax will not be set
      -- this syntax setting is independent from auto-set filetype
      auto_set_syntax = false,
      journal_auto_open = true,

      home = vim.fn.expand '~/zettelkasten', -- Put the name of your notes directory here
      dailies = vim.fn.expand '~/zettelkasten' .. '/' .. 'daily',
      weeklies = vim.fn.expand '~/zettelkasten' .. '/' .. 'weekly',
      templates = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates',
      -- Daily note template
      template_new_daily = vim.fn.expand '~/zettelkasten/' .. 'templates/daily_note.md',

      -- Weekly note template
      template_new_weekly = vim.fn.expand '~/zettelkasten/' .. 'templates/weekly_note.md',

      -- Default new note template
      template_new_note = vim.fn.expand '~/zettelkasten/' .. 'templates/basic_note.md',
    }
  end,
}
