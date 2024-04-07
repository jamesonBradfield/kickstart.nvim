return {
  'svermeulen/vim-cutlass',
  lazy = false,
  config = function()
    vim.keymap.set({ 'n', 'x' }, 'x', 'd', { silent = true })
    vim.keymap.set({ 'n' }, 'xx', 'dd', { silent = true })
    vim.keymap.set({ 'n' }, 'X', 'D', { silent = true })
  end,
}
