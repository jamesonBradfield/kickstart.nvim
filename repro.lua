local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup {
  {
    {
      'Zeioth/compiler.nvim',
      cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
      dependencies = {
        {
          'stevearc/overseer.nvim',
          commit = '6271cab7ccc4ca840faa93f54440ffae3a3918bd',
          cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
          opts = {
            task_list = {
              direction = 'bottom',
              min_height = 25,
              max_height = 25,
              default_detail = 1,
            },
          },
        },
        'nvim-telescope/telescope.nvim',
      },
      opts = {},
    },
    {
      -- Fuzzy Finder (files, lsp, etc)
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      branch = '0.1.x',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'debugloop/telescope-undo.nvim',
      },
    },
  },
}
