return {
  'mistricky/codesnap.nvim',
  build = 'make build_generator',
  keys = {
    { '<leader>Cc', '<cmd>CodeSnap<cr>', mode = { 'n', 'x', 'o' }, desc = '[C]odeSnap [c]lipboard' },
    { '<leader>Cs', '<cmd>CodeSnapSave<cr>', mode = { 'n', 'x', 'o' }, desc = '[C]odeSnap [s]napshot in ~/Pictures' },
  },
  opts = {
    save_path = '~/Pictures',
    has_breadcrumbs = true,
    bg_theme = 'bamboo',
  },
}
