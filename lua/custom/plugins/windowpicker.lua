return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  event = 'VeryLazy',
  version = '2.*',
  config = function()
    require('window-picker').setup {}
    vim.keymap.set('n', '<leader>w', '', { desc = '[w]indow picker' })
    vim.keymap.set('n', '<leader>wm', function()
      local picked_window_id = require('window-picker').pick_window()
      if picked_window_id ~= nil then
        vim.api.nvim_set_current_win(picked_window_id)
      end
    end, { desc = '[w]indow [m]ove' })

    vim.keymap.set('n', '<leader>ws', function()
      local picked_window_id = require('window-picker').pick_window()
      if picked_window_id ~= nil then
        vim.api.nvim_set_current_win(picked_window_id)
        vim.cmd 'split'
      else
        vim.cmd 'split'
      end
    end, { desc = '[w]indow [s]plit' })

    vim.keymap.set('n', '<leader>wS', function()
      local picked_window_id = require('window-picker').pick_window()
      if picked_window_id ~= nil then
        vim.api.nvim_set_current_win(picked_window_id)
        vim.cmd 'vsplit'
      else
        vim.cmd 'vsplit'
      end
    end, { desc = '[w]indow [S]split' })
  end,
}
