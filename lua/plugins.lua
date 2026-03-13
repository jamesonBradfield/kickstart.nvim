-- Load other configurations
local keys = require 'keys'
local M = {}

M.plugins = {

  -- ===================================================================== --
  -- 1. CORE & FOUNDATION                                                  --
  -- The essential building blocks of the editor.                          --
  -- ===================================================================== --
  {
    -- Mini.files: File explorer that acts like a text buffer.
    'nvim-mini/mini.nvim',
    version = false,
    keys = keys.mini_files,
    config = function()
      -- Custom filter to hide Godot sidecar files
      local filter_hide_godot = function(fs_entry)
        return not vim.endswith(fs_entry.name, '.uid') and not vim.endswith(fs_entry.name, '.import')
      end

      require('mini.files').setup {
        content = {
          filter = filter_hide_godot,
        },
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 50,
        },
        options = {
          use_as_default_explorer = true,
        },
      }

      -- Automatically attach Grapple keymap when mini.files opens
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id

          -- Use <leader>m to match your global Grapple toggle key
          vim.keymap.set('n', '<leader>m', function()
            local entry = MiniFiles.get_fs_entry()

            -- Only toggle tags for actual files, not directories
            if entry and entry.fs_type == 'file' then
              require('grapple').toggle { path = entry.path }
              vim.notify('Toggled Grapple tag: ' .. entry.name)
            end
          end, { buffer = buf_id, desc = 'Grapple toggle tag (mini.files)' })
        end,
      })
    end,
  },
  {
    -- Mason: Package manager for external tools (LSPs, formatters, linters).
    -- We keep this minimal since we rely on system-level GCC/Cargo for Rust.
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    -- Treesitter: Advanced syntax highlighting and code parsing.
    -- Builds an Abstract Syntax Tree (AST) for better folding and highlighting.
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'gdscript', 'godot_resource', 'gdshader', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'latex', 'python' },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      }
    end,
  },
  {
    -- Snacks: A massive collection of high-performance utility plugins.
    -- We use it for the terminal, file explorer, dashboard, and picker.
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    keys = keys.snacks,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true },
      statuscolumn = { enabled = true },
      zen = { enabled = true },
      terminal = { enabled = true },
      explorer = { enabled = false },
      picker = {
        enabled = true,
        layout = 'vscode',
        sources = {
          explorer = {
            -- Hide Godot sidecar files from the visual tree to reduce clutter
            exclude = { '**/*.uid', '**/*.import' },
          },
        },
      },
      image = {
        enabled = true,
        doc = { inline = false, float = true },
        math = { enabled = true, latex = { packages = { 'amsmath', 'amssymb', 'amsfonts', 'amscd', 'mathtools' } } },
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      -- Bacon Terminal: Automatically spin up a hidden terminal running `cargo check` via Bacon
      -- whenever a Rust file is opened. Keeps the LSP fast by offloading compilation checks.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          if _G.bacon_terminal == nil then
            _G.bacon_terminal = Snacks.terminal.get('bacon clippy', {
              interactive = false,
              name = 'Bacon Builder',
              env = { RUST_BACKTRACE = '1' },
              start_insert = false,
            })
          end
        end,
      })

      -- Godot-Specific Logic: Intercept rename hooks to move .uid and .import files.
      -- Prevents Godot from losing track of files when renamed inside Neovim.
      local orig_on_rename = Snacks.rename.on_rename_file
      Snacks.rename.on_rename_file = function(from, to, rename)
        for _, ext in ipairs { '.uid', '.import' } do
          local from_sidecar = from .. ext
          if vim.fn.filereadable(from_sidecar) == 1 then
            local to_sidecar = to .. ext
            vim.uv.fs_rename(from_sidecar, to_sidecar)
          end
        end
        orig_on_rename(from, to, rename)
      end
    end,
  },

  -- ===================================================================== --
  -- 2. LSP & COMPLETION                                                   --
  -- The "Brains". Handles autocomplete, diagnostics, and server configs.  --
  -- ===================================================================== --

  {
    -- Blink.cmp: A lightning-fast, Rust-based completion engine.
    -- Replaces nvim-cmp and provides out-of-the-box snippet support.
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<CR>'] = { 'accept', 'fallback' },
      },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    -- LSPConfig: The standard Neovim interface for communicating with LSPs.
    -- We use this for basic servers; Rust is handled separately by rustaceanvim.
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      local hover_border = {
        { '╭', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╮', 'FloatBorder' },
        { '│', 'FloatBorder' },
        { '╯', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╰', 'FloatBorder' },
        { '│', 'FloatBorder' },
      }

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = hover_border,
        max_height = 15,
      })

      -- Attach our global LSP mappings from keys.lua to any active LSP buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          for _, map in ipairs(keys.lsp_attach) do
            vim.keymap.set(map.mode or 'n', map[1], map[2], vim.tbl_extend('force', opts, { desc = map[3] }))
          end
        end,
      })

      -- Standard Servers
      vim.lsp.config('lua_language_server', {})
      vim.lsp.enable 'lua_language_server'
      vim.lsp.config('bash_language_server', {})
      vim.lsp.enable 'bash_language_server'
      vim.lsp.config('basedpyright', {})
      vim.lsp.enable 'basedpyright'
      -- Godot Server: Connects via localhost TCP to the Godot Editor instance
      vim.lsp.config('gdscript', {
        name = 'godot',
        cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      })
      vim.lsp.enable 'gdscript'
      vim.lsp.enable 'gdshader_lsp'
    end,
  },
  {
    -- LazyDev: Injects Neovim API types into the Lua LSP.
    -- Makes configuring Neovim much easier with proper autocomplete.
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
  { 'justinsgithub/wezterm-types', lazy = true },

  -- ===================================================================== --
  -- 3. LANGUAGE SPECIFICS (GODOT / RUST STACK)                            --
  -- Specialized plugins and formatters for our specific tech stack.       --
  -- ===================================================================== --

  {
    -- Rustaceanvim: A heavily optimized wrapper around rust-analyzer.
    -- Manages the LSP, debugging setup, and specific Rust code actions automatically.
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        server = {
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern 'Cargo.toml'(fname)
          end,
          on_attach = function(client, bufnr)
            -- Global keys.lsp_attach mappings are already handled by the global LspAttach autocmd!

            -- Override standard Hover/Action keys with Rustacean's specialized UI
            vim.keymap.set('n', 'K', function()
              vim.cmd.RustLsp { 'hover', 'actions' }
            end, { silent = true, buffer = bufnr, desc = 'Rustacean: Hover Actions' })

            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, { silent = true, buffer = bufnr, desc = 'Rustacean: Code Action' })
          end,
          default_settings = {
            ['rust-analyzer'] = {
              procMacro = {
                enable = true,
                -- CRUCIAL FIX: Ignores the godot_api macro while typing.
                -- Prevents RA from panicking on incomplete syntax and killing autocomplete.
                ignored = {
                  ['godot'] = { 'godot_api' },
                  ['godot_macros'] = { 'godot_api' },
                },
              },
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              check = { command = 'clippy' },
              diagnostics = { disabled = { 'unresolved-proc-macro', 'proc-macro-disabled' } },
            },
          },
        },
      }
    end,
  },
  {
    -- GDScript Extended LSP: Enhances the base Godot LSP connection.
    -- Provides better UI for Godot documentation and symbol navigation.
    'Teatek/gdscript-extended-lsp.nvim',
    lazy = false,
    opts = {
      view_type = 'floating',
      floating_win_size = 0.6,
      picker = 'snacks',
    },
  },
  {
    -- Conform: Formatter manager.
    -- Formats code on save using standard tooling (stylua for lua, gdformat for GDScript).
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        gdscript = { 'gdformat' },
        python = { 'ruff_format', 'ruff_organize_imports' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
    },
  },
  {
    -- Nvim-Lint: Linter manager.
    -- Runs background checks that aren't handled by the primary LSPs.
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = { gd = 'gdlint', python = { 'ruff' } }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require('lint').try_lint()
          require('lint').try_lint 'cspell'
        end,
      })
    end,
  },

  -- ===================================================================== --
  -- 4. DEBUGGING                                                          --
  -- DAP (Debug Adapter Protocol) setup for stepping through code.         --
  -- ===================================================================== --

  {
    -- Nvim-DAP: The core debugging engine.
    -- Allows setting breakpoints and interacting with external debuggers.
    'mfussenegger/nvim-dap',
    dependencies = { 'jbyuki/one-small-step-for-vimkind' },
    lazy = false,
    keys = keys.dap,
    config = function()
      local dap = require 'dap'
      -- Add the CodeLLDB adapter
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          -- Make sure 'codelldb' is in your PATH or installed via Mason
          command = 'codelldb',
          args = { '--port', '${port}' },
        },
      }
      -- Add this to your dap config function
      dap.adapters.python = function(cb, config)
        if config.request == 'attach' then
          ---@diagnostic disable-next-line: undefined-field
          local port = (config.connect or config).port
          ---@diagnostic disable-next-line: undefined-field
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
            command = 'python', -- or the path to your venv python
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
      -- Add a Rust launch config for Godot
      dap.configurations.rust = {
        {
          name = 'Launch Godot with Rust (LLDB)',
          type = 'codelldb',
          request = 'launch',
          -- This prompts you for the path to your Godot executable the first time you run it
          program = function()
            return vim.fn.input('Path to Godot executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          args = { '--path', '${workspaceFolder}' },
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }

      dap.adapters.nlua = function(callback, config)
        callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
      end

      -- Godot Debug Adapter: Connects to the Godot Editor's debugging port (6006)
      dap.adapters.godot = {
        type = 'server',
        host = '127.0.0.1',
        port = 6006,
      }

      dap.configurations.lua = {
        { type = 'nlua', request = 'attach', name = 'Attach to running Neovim instance' },
      }

      dap.configurations.gdscript = {
        { type = 'godot', request = 'launch', name = 'Launch Project (F5)', project = '${workspaceFolder}', launch_scene = false },
        { type = 'godot', request = 'launch', name = 'Launch Current Scene (F6)', project = '${workspaceFolder}', launch_scene = true },
      }
    end,
  },
  {
    -- DAP UI: A visual interface for nvim-dap.
    -- Automatically opens a side panel with scopes, watches, and console when debugging starts.
    'rcarriga/nvim-dap-ui',
    lazy = false,
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap, dapui = require 'dap', require 'dapui'

      dapui.setup() -- Initialize UI elements

      -- Auto-open/close the UI based on debugger events
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

  -- ===================================================================== --
  -- 5. UI & UX                                                            --
  -- Making the editor look good and present information clearly.          --
  -- ===================================================================== --

  {
    -- Dracula Colorscheme
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'dracula'
    end,
  },
  {
    -- Lualine: The bottom status bar.
    -- Customized to show a Dracula theme, Grapple tags, and live Godot connection status.
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function is_godot_active()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        for _, client in pairs(clients) do
          if client.name == 'gdscript' or client.name == 'godot' then
            return true
          end
        end
        return false
      end

      local function godot_status()
        if vim.bo.filetype ~= 'gdscript' and vim.bo.filetype ~= 'gd' then
          return ''
        end
        return is_godot_active() and '󰣖 Godot LSP' or '󰣖 Disconnected'
      end

      local function godot_color()
        if is_godot_active() then
          return { fg = '#50fa7b' } -- Dracula Green
        else
          return { fg = '#ff5555', gui = 'bold' } -- Dracula Red
        end
      end

      -- NEW: Grapple status function
      local function grapple_status()
        local ok, grapple = pcall(require, 'grapple')
        if ok and grapple.exists() then
          return '󰛢 ' .. grapple.name_or_index()
        end
        return ''
      end

      require('lualine').setup {
        options = { theme = 'dracula-nvim' },
        sections = {
          -- Adding Grapple right next to your git branch and diagnostics
          lualine_b = {
            'branch',
            'diff',
            'diagnostics',
            { grapple_status, color = { fg = '#8be9fd', gui = 'bold' } }, -- Dracula Cyan
          },
          lualine_x = {
            { godot_status, color = godot_color },
            'encoding',
            'fileformat',
            'filetype',
          },
        },
      }
    end,
  },
  { 'OXY2DEV/helpview.nvim', lazy = false },
  {
    -- Trouble: A prettier list view for diagnostics, quickfixes, and LSP references.
    -- We have it set to auto-open globally when errors/warnings appear.
    'folke/trouble.nvim',
    keys = keys.trouble,
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd('DiagnosticChanged', {
        group = vim.api.nvim_create_augroup('AutoTrouble', { clear = true }),
        callback = function()
          local diags = vim.diagnostic.get(nil, { severity = { min = vim.diagnostic.severity.WARN } })
          local trouble = require 'trouble'
          if #diags > 0 then
            trouble.open { mode = 'diagnostics', focus = false }
          else
            if trouble.is_open 'diagnostics' then
              trouble.close 'diagnostics'
            end
          end
        end,
      })
    end,
  },
  {
    -- UFO (Ultra Fold in Neovim): Advanced code folding.
    -- Uses Treesitter and LSP to create reliable, modern folding rules and persists folds between sessions.
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufRead',
    keys = keys.ufo,
    init = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    end,
    config = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      -- Persist folds
      local view_group = vim.api.nvim_create_augroup('AutoView', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWinLeave' }, { pattern = '?*', group = view_group, command = 'mkview' })
      vim.api.nvim_create_autocmd({ 'BufWinEnter' }, { pattern = '?*', group = view_group, command = 'silent! loadview' })

      require('ufo').setup {
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },
  {
    -- Render Markdown: Makes Markdown files look like fully formatted documents natively in Neovim.
    'MeanderingProgrammer/render-markdown.nvim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      latex = { enabled = false },
      win_options = { conceallevel = { rendered = 2 } },
    },
  },

  -- ===================================================================== --
  -- 6. NAVIGATION & WORKFLOW                                              --
  -- Tools for moving around the editor quickly.                           --
  -- ===================================================================== --
  {
    -- Persistence: Automated session management.
    -- Saves your open buffers, window splits, and layout automatically.
    'folke/persistence.nvim',
    event = 'BufReadPre', -- Only start saving when an actual file is opened
    opts = {},
    keys = keys.persistence,
  },
  {
    -- Grapple: Project-specific file tagging and navigation.
    -- Instantly jump between your most important files without searching.
    'cbochs/grapple.nvim',
    opts = {
      scope = 'git', -- Keeps your tagged files specific to the current git branch/repo
    },
    cmd = 'Grapple',
    keys = keys.grapple,
  },
  {
    -- Flash: Fast text navigation.
    -- Allows jumping anywhere on the screen with a few keystrokes (like leap/sneak).
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = keys.flash,
  },
  {
    -- Smart Splits: Seamless navigation between Neovim splits and terminal multiplexers (Wezterm).
    'mrjones2014/smart-splits.nvim',
    lazy = false,
    keys = keys.smart_splits,
    opts = { multiplexer_integration = 'wezterm' },
  },
  {
    -- Which-Key: Keybinding popup.
    -- Shows a menu of available keybindings when you press a prefix key (like <leader>).
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = { preset = 'helix' },
    keys = keys.which_key,
  },
  {
    -- Todo-Comments: Highlights and searches for TODO, HACK, FIXME, etc.
    'folke/todo-comments.nvim',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = keys.todo_comments,
    opts = {},
  },

  -- ===================================================================== --
  -- 7. CUSTOM & EXTERNAL TOOLS                                            --
  -- Notes, AI assistants, and bespoke plugins.                            --
  -- ===================================================================== --
  {
    -- Gitsigns: Neat inline Git indicators and hunk management.
    -- Shows added/removed lines in the gutter and provides inline blame.
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      current_line_blame = true, -- Faintly shows who wrote the current line
      current_line_blame_opts = { delay = 500 },
    },
    keys = {
      {
        '<leader>gh',
        function()
          require('gitsigns').preview_hunk()
        end,
        desc = 'Git: Preview Hunk',
      },
      {
        '<leader>gs',
        function()
          require('gitsigns').stage_hunk()
        end,
        desc = 'Git: Stage Hunk',
      },
      {
        '<leader>gr',
        function()
          require('gitsigns').reset_hunk()
        end,
        desc = 'Git: Reset Hunk',
      },
    },
  },
  {
    -- Neogit: The "Goldilocks" Git UI.
    -- Not too manual (Fugitive), not too overwhelming (Lazygit). Native and clean.
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Diffview is highly recommended by Neogit for beautiful merge conflict resolution
      'sindrets/diffview.nvim',
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Open Neogit (Status)' },
      { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Neogit: Commit' },
    },
    config = function()
      require('neogit').setup {
        integrations = { diffview = true },
        disable_commit_confirmation = true,
      }
    end,
  },
  {
    -- Telekasten: Personal knowledge management (Zettelkasten).
    -- Loads from a local directory (your own fork/project).
    'jamesonBradfield/telekasten.nvim',
    enabled = false,
    lazy = false,
    dir = os.getenv 'USERPROFILE' .. '/projects/nvim/telekasten.nvim',
    opts = {
      home = vim.fn.expand '~/zettelkasten',
      backend = 'snacks',
    },
    keys = keys.telekasten,
  },
  {
    -- OpenCode: AI Coding Assistant.
    'nickjvandyke/opencode.nvim',
    keys = keys.opencode,
    dependencies = { 'folke/snacks.nvim' },
    config = function()
      vim.g.opencode_opts = {}
    end,
  },
}

return M
