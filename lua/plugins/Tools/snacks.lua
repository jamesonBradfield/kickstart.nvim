-- Enhanced snacks.lua with tab-aware explorer focus handling
-- Open explorer in every tab and trouble when diagnostics are present

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    dependencies = 'folke/trouble.nvim',
    config = function(_, opts)
      local snacks = require 'snacks'
      -- Initialize snacks with updated configuration
      snacks.setup(opts)

      -- Set up global functionality after everything is loaded
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Set up debug helpers
          _G.dd = function(...)
            snacks.debug.inspect(...)
          end
          _G.bt = function()
            snacks.debug.backtrace()
          end
          vim.print = _G.dd

          -- Set up toggle mappings
          pcall(function()
            snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>sts'
            snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>stw'
            snacks.toggle.diagnostics():map '<leader>std'
            snacks.toggle.line_number():map '<leader>stl'
            snacks.toggle.treesitter():map '<leader>stT'
            snacks.toggle.dim():map '<leader>stD'
          end)

          -- Load custom tabline
          pcall(function()
            require('custom.custom_tabline').setup()
          end)
        end,
      })
    end,
    opts = {
      bigfile = { enabled = true },
      terminal = { enabled = true },
      dashboard = {
        sections = {
          { section = 'header' },
          { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          { section = 'startup' },
        },
      },
      layout = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      picker = {
        enabled = true,
      },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      dim = {
        scope = { min_size = 5, max_size = 20, siblings = true },
        animate = {
          enabled = vim.fn.has 'nvim-0.10' == 1,
          easing = 'outQuad',
          duration = { step = 20, total = 300 },
        },
        filter = function(buf)
          return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ''
        end,
      },
      -- Add this to your snacks.nvim config
      zen = {
        toggles = { dim = true },
        win = {
          style = 'zen',
          backdrop = { transparent = true, blend = 30 },
          border = 'rounded',
          width = 0.8, -- Set width to 80% for centering content
          height = 0.9, -- Set height to 90% for better vertical spacing
          padding = { -- Add padding for centered look
            top = 2,
            bottom = 2,
            left = 2,
            right = 2,
          },
          resize = true,
        },
        show = {
          statusline = true,
          tabline = true, -- This already shows the tabline
        },
      },
    },
    keys = function()
      local mappings = require 'mappings'
      return mappings.snacks()
    end,
  },
}
