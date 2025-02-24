require('render-markdown').toggle()
vim.keymap.set('i', '[[', '<cmd>Telekasten insert_link<CR>')
vim.keymap.set('n', '<leader>cc', function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local checkbox_text = vim.api.nvim_buf_get_text(0, row - 1, 0, row - 1, 7, {})
  vim.print(checkbox_text[1])
  require('fidget').notify(checkbox_text[1], 1, {})
  if checkbox_text[1] == ' - [ ] ' then
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 7, { '' })
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { ' - [x] ' })
  elseif checkbox_text[1] == ' - [x] ' then
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 6, { '' })
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { ' - [ ] ' })
  else
    vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { ' - [ ] ' })
  end
end, { desc = 'add checkbox to line' })
