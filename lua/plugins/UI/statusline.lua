local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'lewis6991/gitsigns.nvim' },
  opts = {
    options = {
      icons_enabled = true,
      theme = 'kanagawa',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        { 'b:gitsigns_head', icon = '' },
        {
          'diff',
          source = diff_source,
          colored = true, -- Displays a colored diff status if set to true
          -- diff_color = {
          --   -- Same color values as the general color option can be used here.
          --   added = 'LuaLineDiffAdd', -- Changes the diff's added color
          --   modified = 'LuaLineDiffChange', -- Changes the diff's modified color
          --   removed = 'LuaLineDiffDelete', -- Changes the diff's removed color you
          -- },
          symbols = { added = ' ', modified = ' ', removed = ' ' }, -- Changes the symbols used by the diff.
        },
        'diagnostics',
      },
      lualine_c = {
        -- 'filename',
      },
      lualine_x = {
        -- {
        --   require('noice').api.status.message.get_hl,
        --   cond = require('noice').api.status.message.has,
        -- },
        -- {
        --   require('noice').api.status.command.get,
        --   cond = require('noice').api.status.command.has,
        --   color = { fg = '#ff9e64' },
        -- },
        -- {
        --   require('noice').api.status.mode.get,
        --   cond = require('noice').api.status.mode.has,
        --   color = { fg = '#ff9e64' },
        -- },
        -- {
        --   require('noice').api.status.search.get,
        --   cond = require('noice').api.status.search.has,
        --   color = { fg = '#ff9e64' },
        -- },
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
}
