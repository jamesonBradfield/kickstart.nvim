return {
  'rebelot/kanagawa.nvim',
  config = function()
    require('kanagawa').setup()
    vim.cmd 'colorscheme kanagawa-dragon'
 --    local dragon_colors = require('kanagawa.colors').setup { theme = 'dragon' }
	-- vim.print(dragon_colors)
  end,
}
