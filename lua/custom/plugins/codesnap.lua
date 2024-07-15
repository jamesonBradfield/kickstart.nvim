return {
  'mistricky/codesnap.nvim',
  lazy = false,
  build = 'make build_generator',
  keys = {
    { '<leader>Cc', 'ggvG$<cmd>CodeSnapHighlight<cr>', mode = { 'o', 'n', 'x' }, desc = '[C]odeSnap [c]lipboard' },
    { '<leader>Cs', 'ggvG$<cmd>CodeSnapSaveHighlight<cr>', mode = { 'o', 'n', 'x' }, desc = '[C]odeSnap [s]napshot in ~/Pictures' },
  },
  opts = {
    save_path = '~/Pictures',
    has_breadcrumbs = true,
    bg_theme = 'bamboo',
  },
}
