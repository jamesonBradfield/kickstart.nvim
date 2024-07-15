return {
  'renerocksai/telekasten.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'renerocksai/calendar-vim',
    'nvim-telescope/telescope-symbols.nvim',
    'mzlogin/vim-markdown-toc',
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

      home = vim.fn.expand '~/zettelkasten', -- Put the name of your notes directory here
      dailies = vim.fn.expand '~/zettelkasten' .. '/' .. 'daily',
      weeklies = vim.fn.expand '~/zettelkasten' .. '/' .. 'weekly',
      templates = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates',
      vaults = {
        personal = {
          auto_set_filetype = false,
          -- auto-set telekasten syntax: if false, the telekasten syntax will not be set
          -- this syntax setting is independent from auto-set filetype
          auto_set_syntax = false,
          home = vim.fn.expand '~/zettelkasten/personal/', -- Put the name of your notes directory here
          dailies = vim.fn.expand '~/zettelkasten/personal/' .. '/' .. 'daily',
          weeklies = vim.fn.expand '~/zettelkasten/personal/' .. '/' .. 'weekly',
          templates = vim.fn.expand '~/zettelkasten/personal/' .. '/' .. 'templates',
        },
        coding = {
          auto_set_filetype = false,
          -- auto-set telekasten syntax: if false, the telekasten syntax will not be set
          -- this syntax setting is independent from auto-set filetype
          auto_set_syntax = false,

          home = vim.fn.expand '~/zettelkasten/coding/', -- Put the name of your notes directory here
          dailies = vim.fn.expand '~/zettelkasten/coding/' .. '/' .. 'daily',
          weeklies = vim.fn.expand '~/zettelkasten/coding/' .. '/' .. 'weekly',
          templates = vim.fn.expand '~/zettelkasten/coding/' .. '/' .. 'templates',
        },
        flashcards = {
          auto_set_filetype = false,
          -- auto-set telekasten syntax: if false, the telekasten syntax will not be set
          -- this syntax setting is independent from auto-set filetype
          auto_set_syntax = false,

          home = vim.fn.expand '~/zettelkasten/flashcards/', -- Put the name of your notes directory here
          dailies = vim.fn.expand '~/zettelkasten/flashcards/' .. '/' .. 'daily',
          weeklies = vim.fn.expand '~/zettelkasten/flashcards/' .. '/' .. 'weekly',
          templates = vim.fn.expand '~/zettelkasten/flashcards/' .. '/' .. 'templates',
        },
      },
      template_new_note = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates/new_note.md',
      template_new_daily = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates/daily_tk.md',
      template_new_weekly = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates/weekly_tk.md',
    }
    -- Launch panel if nothing is typed after <leader>k
    vim.keymap.set('n', '<leader>k<space>', '<cmd>Telekasten panel<CR>')

    -- Most used functions
    vim.keymap.set('n', '<leader>kf', '<cmd> find_notes<CR>', { desc = 'Tele[k]asten [f]ind Notes' })
    vim.keymap.set('n', '<leader>kg', '<cmd>Telekasten search_notes<CR>', { desc = 'Tele[k]asten [g]rep Notes' })
    vim.keymap.set('n', '<leader>kd', '<cmd>Telekasten goto_today<CR>', { desc = 'Tele[k]asten To[d]ay' })
    vim.keymap.set('n', '<leader>kl', '<cmd>Telekasten follow_link<CR>', { desc = 'Tele[k]asten Follow [l]ink' })
    vim.keymap.set('n', '<leader>kn', '<cmd>Telekasten new_note<CR>', { desc = 'Tele[k]asten [n]ew note' })
    vim.keymap.set('n', '<leader>kt', '<cmd>Telekasten new_templated_note<CR>', { desc = 'Tele[k]asten new [t]emplated note' })

    vim.keymap.set('n', '<leader>kc', '<cmd>Telekasten show_calendar<CR>', { desc = 'Tele[k]asten Show [c]alendar' })
    vim.keymap.set('n', '<leader>kb', '<cmd>Telekasten show_backlinks<CR>', { desc = 'Tele[k]asten [b]acklinks' })
    vim.keymap.set('n', '<leader>ki', '<cmd>Telekasten insert_img_link<CR>', { desc = 'Tele[k]asten [i]nsert Image Link' })

    -- Call insert link automatically when we start typing a link
  end,
}
