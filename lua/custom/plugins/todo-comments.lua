-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/trouble.nvim', 'nvim-telescope/telescope.nvim' },
  opts = {},
}
