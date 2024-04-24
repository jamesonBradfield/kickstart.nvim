return {
  'cbochs/grapple.nvim',
  -- dependencies = {
  --   'nvim-tree/nvim-web-devicons',
  -- },
  opts = {
    scope = 'git', -- also try out "git_branch"
    icons = false,
  },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = 'Grapple',
  keys = {
    { '<leader>m', '<cmd>Grapple toggle<cr>', desc = 'Grapple toggle tag' },
    { '<leader>M', '<cmd>Grapple toggle_tags<cr>', desc = 'Grapple open tags window' },
  },
}
