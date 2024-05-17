return {
  'folke/trouble.nvim',
  lazy = false,
  branch = 'dev', -- IMPORTANT!
  dependencies = { 'folke/todo-comments.nvim' },
  keys = {
    {
      '<leader>tx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnosti[x] (Trouble)',
    },
    {
      '<leader>tX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnosti[X] (Trouble)',
    },
    {
      '<leader>ts',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = '[S]ymbols (Trouble)',
    },
    {
      '<leader>tl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = '[l]SP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>tL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = '[L]ocation List (Trouble)',
    },
    {
      '<leader>tQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = '[Q]uickfix List (Trouble)',
    },
  },
  opts = {},
}
