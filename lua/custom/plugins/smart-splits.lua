return {
  'mrjones2014/smart-splits.nvim',
  config = function()
    require('smart-splits').setup {
      ignored_filetypes = { 'nofile', 'quickfix', 'qf', 'prompt' },
      ignored_buftypes = { 'nofile' },
    }

    -- Navigation keymaps (correct function names and wrapped in functions)
    vim.keymap.set('n', '<C-h>', function()
      require('smart-splits').move_cursor_left()
    end)
    vim.keymap.set('n', '<C-j>', function()
      require('smart-splits').move_cursor_down()
    end)
    vim.keymap.set('n', '<C-k>', function()
      require('smart-splits').move_cursor_up()
    end)
    vim.keymap.set('n', '<C-l>', function()
      require('smart-splits').move_cursor_right()
    end)
  end,
}
