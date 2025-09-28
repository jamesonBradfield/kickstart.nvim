return {
  'renerocksai/telekasten.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  lazy = false,
  keys = {
    -- Launch panel if nothing is typed after <leader>z
    { '<leader>k', mode = 'n', '<cmd>Telekasten panel<cr>', desc = 'Tele[k]asten panel' },

    -- Most used functions
    { '<leader>kf', mode = 'n', '<cmd>Telekasten find_notes<cr>', desc = 'Tele[k]asten find notes' },
    { '<leader>kg', mode = 'n', '<cmd>Telekasten search_notes<cr>', desc = 'Tele[k]asten search notes' },
    { '<leader>kd', mode = 'n', '<cmd>Telekasten toggle_todo<cr>', desc = 'Tele[k]asten toggle checkbox' },
    { '<leader>kD', mode = 'n', '<cmd>Telekasten goto_today<cr>', desc = 'Tele[k]asten goto today' },
    { '<leader>kz', mode = 'n', '<cmd>Telekasten follow_link<cr>', desc = 'Tele[k]asten follow link' },
    { '<leader>kn', mode = 'n', '<cmd>Telekasten new_note<cr>', desc = 'Tele[k]asten new note' },
    { '<leader>kc', mode = 'n', '<cmd>Telekasten show_calendar<cr>', desc = 'Tele[k]asten show calendar' },
    { '<leader>kb', mode = 'n', '<cmd>Telekasten show_backlinks<cr>', desc = 'Tele[k]asten show backlinks' },
    { '<leader>kI', mode = 'n', '<cmd>Telekasten insert_img_link<cr>', desc = 'Tele[k]asten insert image link' },

    -- Call insert link automatically when we start typing a link
    { '[[', mode = 'i', '<cmd>Telekasten insert_link<cr>', desc = 'Tele[k]asten insert link' },
  },
  opts = {
    home = 'C:/Users/mcraf/zettelkasten', -- Put the name of your notes directory here
    templates = 'templates',
    dailies = 'dailies',
    weeklies = 'weeklies',
    template_new_note = 'C:/Users/mcraf/zettelkasten/templates/template_new_note.md',
    template_new_daily = 'C:/Users/mcraf/zettelkasten/templates/template_new_daily.md',
    template_new_weekly = 'C:/Users/mcraf/zettelkasten/templates/template_new_weekly.md',
    auto_set_filetype = false,
  },
}
