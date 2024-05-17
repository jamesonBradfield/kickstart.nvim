return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-treesitter/nvim-treesitter',
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

    dap.adapters.lldb = {
      type = 'executable',
      command = '/home/linuxbrew/.linuxbrew/bin/lldb-dap', -- adjust as needed, must be absolute path
      name = 'lldb',
    }

    dap.configurations.cs = {
      {
        name = 'Launch Project',
        type = 'lldb',
        request = 'launch',
        program = '/home/jamie/Path/Godot_v4.2.1-stable_mono_linux_x86_64/Godot_v4.2.1-stable_mono_linux.x86_64',
        -- or
        -- ${workspaceFolder}/bin/godot.linuxbsd.editor.dev.x86_64.llvm
        cwd = '${workspaceFolder}',
        --  Change the arguments below for the project you want to test with.
        --  To run the project instead of editing it, remove the "--editor" argument.
        args = { '--path', '/home/jamie/GodotProjects/LambastAddon/' },
        environment = {},
        preLaunchTask = 'build',
        stopOnEntry = false,
        externalConsole = false,
        -- 💀
        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        -- runInTerminal = false,
      },
    }

    dapui.setup()
  end,
}
