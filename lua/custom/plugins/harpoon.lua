return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = '󰛢 ~ [a]dd to list' })
    vim.keymap.set('n', '<C-q>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = '󰛢 ~ [q]uickmenu' })
    vim.keymap.set('n', '<A-h>', function()
      harpoon:list():select(1)
    end, { desc = '󰛢 ~ Select h' })
    vim.keymap.set('n', '<A-j>', function()
      harpoon:list():select(2)
    end, { desc = '󰛢 ~ Select j' })
    vim.keymap.set('n', '<A-k>', function()
      harpoon:list():select(3)
    end, { desc = '󰛢 ~ Select k' })
    vim.keymap.set('n', '<A-l>', function()
      harpoon:list():select(4)
    end, { desc = '󰛢 ~ Select l' })
  end,
}
