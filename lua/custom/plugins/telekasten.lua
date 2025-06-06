return {
  'renerocksai/telekasten.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  opts = {
    home = vim.fn.expand '~/zettelkasten', -- Put the name of your notes directory here
    auto_set_filetype = false,
  },
  config = function(_, opts)
    require('telekasten').setup(opts)
    -- Launch panel if nothing is typed after <leader>z
    vim.keymap.set('n', '<leader>k', '<cmd>Telekasten panel<CR>')

    -- Most used functions
    vim.keymap.set('n', '<leader>kf', '<cmd>Telekasten find_notes<CR>')
    vim.keymap.set('n', '<leader>kg', '<cmd>Telekasten search_notes<CR>')
    vim.keymap.set('n', '<leader>kd', '<cmd>Telekasten toggle_todo<CR>')
    vim.keymap.set('n', '<leader>kD', '<cmd>Telekasten goto_today<CR>')
    vim.keymap.set('n', '<leader>kz', '<cmd>Telekasten follow_link<CR>')
    vim.keymap.set('n', '<leader>kn', '<cmd>Telekasten new_note<CR>')
    vim.keymap.set('n', '<leader>kc', '<cmd>Telekasten show_calendar<CR>')
    vim.keymap.set('n', '<leader>kb', '<cmd>Telekasten show_backlinks<CR>')
    vim.keymap.set('n', '<leader>kI', '<cmd>Telekasten insert_img_link<CR>')

    -- Call insert link automatically when we start typing a link
    vim.keymap.set('i', '[[', '<cmd>Telekasten insert_link<CR>')
  end,
}
