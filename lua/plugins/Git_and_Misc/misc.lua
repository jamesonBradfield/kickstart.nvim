return {
  { 'tpope/vim-eunuch' },
  {'nmac427/guess-indent.nvim',},
  {
    'norcalli/nvim-colorizer.lua',
    lazy = false,
    config = function()
      require('colorizer').setup()
    end,
  },
  {
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup()
    end,
  },
  {
    'svermeulen/vim-cutlass',
    lazy = false,
    config = function()
      vim.keymap.set({ 'n', 'x' }, 'x', 'd', { silent = true })
      vim.keymap.set({ 'n' }, 'xx', 'dd', { silent = true })
      vim.keymap.set({ 'n' }, 'X', 'D', { silent = true })
    end,
  },
  { 'elkowar/yuck.vim' },
  { 'gpanders/nvim-parinfer' },
}
