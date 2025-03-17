return {
  {
    'tpope/vim-fugitive',
    lazy = false,
    keys = {
      {
        '<leader>gp',
        mode = { 'n', 'x', 'o' },
        function()
          vim.cmd 'G push'
        end,
        desc = '[g]it [p]ush',
      },
      {
        '<leader>ga',
        mode = { 'n', 'x', 'o' },
        function()
          vim.cmd 'G add .'
        end,
        desc = '[g]it [a]dd',
      },
      {
        '<leader>gc',
        mode = { 'n', 'x', 'o' },
        function()
          local message = vim.fn.input 'message'
          vim.cmd('G commit -m' .. message)
        end,
        desc = '[g]it [c]ommit',
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
      }
      vim.cmd [[highlight GitSignsAdd guifg=#76946a guibg=none]]
      vim.cmd [[highlight GitSignsChange guifg=#dca561 guibg=none]]
      vim.cmd [[highlight GitSignsDelete guifg=#c34043 guibg=none]]
      vim.cmd [[highlight GitSignsAddNr guifg=#76946a guibg=none]]
      vim.cmd [[highlight GitSignsChangeNr guifg=#dca561 guibg=none]]
      vim.cmd [[highlight GitSignsDeleteNr guifg=#c34043 guibg=none]]
      vim.cmd [[highlight GitSignsAddLn guifg=#77787c guibg=none]]
      vim.cmd [[highlight GitSignsChangeLn guifg=#77787c guibg=none]]
      vim.cmd [[highlight GitSignsChangeDeleteLn guifg=#77787c guibg=none]]
      vim.cmd [[highlight GitSignsUntracked guifg=#76946a guibg=none]]
      vim.cmd [[highlight GitSignsUntrackedNr guifg=#76946a guibg=none]]
      vim.cmd [[highlight GitSignsStagedAdd guifg=#597b60 guibg=none]]
      vim.cmd [[highlight GitSignsStagedChange guifg=#467c7b guibg=none]]
      vim.cmd [[highlight GitSignsStagedDelete guifg=#7f605c guibg=none]]
      vim.cmd [[highlight GitSignsStagedAddNr guifg=#597b60 guibg=none]]
      vim.cmd [[highlight GitSignsStagedChangeNr guifg=#467c7b guibg=none]]
      vim.cmd [[highlight GitSignsStagedDeleteNr guifg=#7f605c guibg=none]]
      vim.cmd [[highlight GitSignsStagedAddLn guifg=#77787c guibg=none]]
      vim.cmd [[highlight GitSignsStagedChangeLn guifg=#77787c guibg=none]]
      vim.cmd [[highlight GitSignsStagedChangeDeleteLn guifg=#77787c guibg=none]]
      vim.cmd [[highlight GitSignsAddPreview guifg=#00ff00 guibg=none]]
      vim.cmd [[highlight GitSignsDeletePreview guifg=#ff0000 guibg=none]]
      vim.cmd [[highlight GitSignsCurrentLineBlame guifg=none guibg=none]]
      vim.cmd [[highlight GitSignsAddInline guifg=#00ff00 guibg=none]]
      vim.cmd [[highlight GitSignsChangeInline guifg=#ffff00 guibg=none]]
      vim.cmd [[highlight GitSignsDeleteInline guifg=#ff0000 guibg=none]]
      vim.cmd [[highlight GitSignsDeleteVirtLn guifg=#ff0000 guibg=none]]
      vim.cmd [[highlight GitSignsDeleteVirtLnInLine guifg=#ff0000 guibg=none]]
      vim.cmd [[highlight GitSignsVirtLnum guifg=#ff0000 guibg=none]]
    end,
  },
}
