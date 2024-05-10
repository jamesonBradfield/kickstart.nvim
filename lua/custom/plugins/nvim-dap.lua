return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'nGim-treesitter/nvim-treesitter',
  },
  lazy = false,
  keys = {
    {
      'F5',
      mode = { 'n' },
      function()
        require('dap').continue()
      end,
      desc = 'Continue',
    },
    {
      'F10',
      mode = { 'n' },
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over',
    },
    {
      'F11',
      mode = { 'n' },
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into',
    },
    {
      'F12',
      mode = { 'n' },
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out',
    },
    {
      '<Leader>b',
      mode = { 'n' },
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint',
    },
    {
      '<Leader>B',
      mode = { 'n' },
      function()
        require('dap').set_breakpoint()
      end,
      desc = 'Set Breakpoint',
    },
    {
      '<Leader>lp',
      mode = { 'n' },
      function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end,
      desc = 'Log Point',
    },
    {
      '<Leader>dr',
      mode = { 'n' },
      function()
        require('dap').repl.open()
      end,
      desc = 'Open Repl',
    },
    {
      '<Leader>dl',
      mode = { 'n' },
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<Leader>dh',
      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Hover',
    },
    {
      '<Leader>dp',
      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').preview()
      end,
      desc = 'Preview',
    },
    {
      '<Leader>df',
      mode = { 'n' },
      function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.frames)
      end,
      desc = 'Float Preview',
    },
    {
      '<Leader>ds',
      mode = { 'n' },
      function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes)
      end,
    },
    desc = 'Float Scopes',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
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
    dap.adapters.godot = {
      type = 'server',
      host = '127.0.0.1',
      port = 6007,
    }
    dap.configurations.gdscript = {
      {
        type = 'godot',
        request = 'launch',
        name = 'Launch scene',
        project = '${workspaceFolder}',
        launch_scene = true,
      },
    }
    dap.adapters.coreclr = {
      type = 'executable',
      command = '/path/to/dotnet/netcoredbg/netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/.godot/mono/temp/bin/Debug/', 'file')
        end,
      },
    }
    dapui.setup()
  end,
}
