-- ~/.config/nvim/lua/plugins/debug.lua
local mappings = require 'mappings'
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-treesitter/nvim-treesitter',
    'folke/snacks.nvim',
  },
  lazy = true, -- Enable lazy loading for better startup performance
  keys = mappings.debug,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Enable trace level logging for DAP
    dap.set_log_level 'TRACE'

    -- Configure dapui
    dapui.setup {
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            'breakpoints',
            'stacks',
            'watches',
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            'repl',
            'console',
          },
          size = 0.25,
          position = 'bottom',
        },
      },
    }

    -- Automatically open/close dapui
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
