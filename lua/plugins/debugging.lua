local keys = require 'keys'

return {
  {
    -- Nvim-DAP: The core debugging engine.
    'mfussenegger/nvim-dap',
    dependencies = { 'jbyuki/one-small-step-for-vimkind' },
    lazy = false,
    keys = keys.dap,
    config = function()
      local dap = require 'dap'

      -- 1. Helper to find Godot executable
      local function get_godot_exec()
        -- Priority list for Godot executable names/paths
        local potential_execs = {
          'godot',
          'godot4',
          'Godot_v4.2.1-stable_win64.exe', -- Example specific version
          'Godot.exe',
        }
        for _, exec in ipairs(potential_execs) do
          if vim.fn.executable(exec) == 1 then
            return exec
          end
        end
        return vim.fn.input('Path to Godot executable: ', vim.fn.getcwd() .. '/', 'file')
      end

      -- 2. Python adapter
      dap.adapters.python = function(cb, config)
        if config.request == 'attach' then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or '127.0.0.1'
          cb {
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = { source_filetype = 'python' },
          }
        else
          cb {
            type = 'executable',
            command = 'python',
            args = { '-m', 'debugpy.adapter' },
            options = { source_filetype = 'python' },
          }
        end
      end

      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            return 'python'
          end,
        },
      }

      -- 3. Rust / Godot GDExtension configurations
      -- Note: rustaceanvim handles the codelldb adapter setup globally
      dap.configurations.rust = {
        {
          name = 'Godot: Launch Game (Debug)',
          type = 'codelldb',
          request = 'launch',
          program = get_godot_exec,
          args = { '--path', '${workspaceFolder}' },
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
        {
          name = 'Godot: Attach to Process',
          type = 'codelldb',
          request = 'attach',
          pid = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
      }

      -- 4. Lua / Neovim adapter
      dap.adapters.nlua = function(callback, config)
        callback { type = 'server', host = config.host or '127.0.0.1', port = 8086 }
      end
      dap.configurations.lua = {
        { type = 'nlua', request = 'attach', name = 'Attach to running Neovim instance' },
      }

      -- 5. Godot GDScript Debug Adapter
      dap.adapters.godot = { type = 'server', host = '127.0.0.1', port = 6006 }
      dap.configurations.gdscript = {
        { type = 'godot', request = 'launch', name = 'Launch Project (F5)', project = '${workspaceFolder}', launch_scene = false },
        { type = 'godot', request = 'launch', name = 'Launch Current Scene (F6)', project = '${workspaceFolder}', launch_scene = true },
      }
    end,
  },
  {
    -- DAP UI: A visual interface for nvim-dap.
    'rcarriga/nvim-dap-ui',
    lazy = false,
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap, dapui = require 'dap', require 'dapui'
      dapui.setup()
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
  },
}
