return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-treesitter/nvim-treesitter',
    {
      'stevearc/overseer.nvim',
      opts = {
        dap = false,
      },
    },
    {
      'Joakker/lua-json5',
      -- if you're on windows
      -- run = 'powershell ./install.ps1'
      build = './install.sh',
    },
  },
  lazy = false,
  keys = {
    {
      '<leader>dc',
      mode = { 'n' },
      function()
        require('dap').continue()
      end,
      desc = '[c]ontinue',
    },
    {
      '<leader>do',
      mode = { 'n' },
      function()
        require('dap').step_over()
      end,
      desc = 'step [o]ver',
    },
    {
      '<leader>di',
      mode = { 'n' },
      function()
        require('dap').step_into()
      end,
      desc = 'step [i]nto',
    },
    {
      '<leader>dO',
      mode = { 'n' },
      function()
        require('dap').step_out()
      end,
      desc = 'Step [O]ut',
    },
    {
      '<Leader>db',
      mode = { 'n' },
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'toggle [b]reakpoint',
    },
    {
      '<Leader>dB',
      mode = { 'n' },
      function()
        require('dap').set_breakpoint()
      end,
      desc = 'Set [B]reakpoint',
    },
    {
      '<Leader>dl',
      mode = { 'n' },
      function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end,
      desc = '[l]og point',
    },
    {
      '<Leader>dr',
      mode = { 'n' },
      function()
        require('dap').repl.open()
      end,
      desc = 'open repl',
    },
    {
      '<Leader>dl',
      mode = { 'n' },
      function()
        require('dap').run_last()
      end,
      desc = 'run [l]ast',
    },
    {
      '<Leader>dh',
      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = '[h]over',
    },
    {
      '<Leader>dp',
      mode = { 'n', 'v' },
      function()
        require('dap.ui.widgets').preview()
      end,
      desc = '[p]review',
    },
    {
      '<Leader>df',
      mode = { 'n' },
      function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.frames)
      end,
      desc = '[f]loat preview',
    },
    {
      '<Leader>ds',
      mode = { 'n' },
      function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes)
      end,
    },
    desc = 'float [s]copes',
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
      port = 6006,
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
    dap.set_log_level 'DEBUG'
    dap.adapters.coreclr = {
      type = 'executable',
      command = '/home/jamie/.local/share/nvim/mason/bin/netcoredbg',
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
      {
        name = 'Attach to Process',
        type = 'coreclr',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }
    dap.configurations.java = {
      {
        name = 'Debug Launch (1GB)',
        type = 'java',
        request = 'launch',
        vmArgs = '-Xmx1G',
      },
      {
        name = 'Debug Launch (2GB)',
        type = 'java',
        request = 'launch',
        vmArgs = '-Xmx2G',
      },
      {
        name = 'Debug Launch (3GB)',
        type = 'java',
        request = 'launch',
        vmArgs = '-Xmx3G',
      },

      {
        name = 'Debug Attach (8000)',
        type = 'java',
        request = 'attach',
        hostName = '127.0.0.1',
        port = 8000,
      },
      {
        name = 'Debug Attach (5005)',
        type = 'java',
        request = 'attach',
        hostName = '127.0.0.1',
        port = 5005,
      },
    }
    json5 = require 'json5'
    require('dap.ext.vscode').json_decode = json5.parse
    dapui.setup()
  end,
}
