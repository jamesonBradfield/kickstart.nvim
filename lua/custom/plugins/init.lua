vim.keymap.set({ 'n', 'x', 'o' }, '<C-s>', function()
  vim.cmd 'sb'
end, { desc = '[s]plit' })

vim.keymap.set({ 'n', 'x', 'o' }, '<C-S-s>', function()
  vim.cmd 'vsplit'
end, { desc = 'V[S]plit' })

vim.keymap.set({ 'n', 'x', 'o' }, '<leader>x', function()
  require('lazy-plugin-reloader').ReloadCurrentFile()
end, { desc = '[x] reload lua' })

-- vim.cmd 'autocmd VimEnter , :ZenMode'

--vim.api.nvim_create_autocmd({ 'VimEnter', 'BufReadPost' }, {
--  pattern = {},
--  callback = function()
--    local zen_mode = require 'zen-mode'
--
--    zen_mode.open()
--  end,
--})

return {}
