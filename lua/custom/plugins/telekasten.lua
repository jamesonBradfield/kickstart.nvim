return {
  'renerocksai/telekasten.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'renerocksai/calendar-vim',
    'nvim-telescope/telescope-symbols.nvim',
    'mzlogin/vim-markdown-toc',
    'toppair/peek.nvim',
  },
  config = function()
    require('telekasten').setup {
      home = vim.fn.expand '~/zettelkasten', -- Put the name of your notes directory here
      dailies = vim.fn.expand '~/zettelkasten' .. '/' .. 'daily',
      weeklies = vim.fn.expand '~/zettelkasten' .. '/' .. 'weekly',
      templates = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates',

      template_new_note = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates/new_note.md',
      template_new_daily = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates/daily_tk.md',
      template_new_weekly = vim.fn.expand '~/zettelkasten' .. '/' .. 'templates/weekly_tk.md',
    }
    -- Launch panel if nothing is typed after <leader>z
    vim.keymap.set('n', '<leader>z', '<cmd>Telekasten panel<CR>')

    -- Most used functions
    vim.keymap.set('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>', { desc = 'Telekasten Find Notes' })
    vim.keymap.set('n', '<leader>zg', '<cmd>Telekasten search_notes<CR>', { desc = 'Telekasten Search Notes' })
    vim.keymap.set('n', '<leader>zd', '<cmd>Telekasten goto_today<CR>', { desc = 'Telekasten Open Today' })
    vim.keymap.set('n', '<leader>zz', '<cmd>Telekasten follow_link<CR>', { desc = 'Telekasten Follow Link' })
    vim.keymap.set('n', '<ctrl>n', '<cmd>Telekasten new_note<CR>', { desc = 'Telekasten New Note' })
    vim.keymap.set('n', '<leader>zc', '<cmd>Telekasten show_calendar<CR>', { desc = 'Telekasten Show Calendar' })
    vim.keymap.set('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>', { desc = 'Telekasten Backlinks' })
    vim.keymap.set('n', '<leader>zI', '<cmd>Telekasten insert_img_link<CR>', { desc = 'Telekasten Insert Image Link' })

    -- Call insert link automatically when we start typing a link
  end,
}
