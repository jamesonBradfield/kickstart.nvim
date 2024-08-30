return {
  -- using lazy.nvim
  {
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      bufferline = require 'bufferline'
      bufferline.setup {
        options = {
          mode = 'buffers',
          style_preset = bufferline.style_preset.minimal,
          separator_style = 'slant',
          themable = true,
        },
      }
    end,
  },
}
