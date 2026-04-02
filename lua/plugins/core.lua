local keys = require 'keys'

return {
  {
    -- Mini.files: File explorer that acts like a text buffer.
    'nvim-mini/mini.nvim',
    version = false,
    init = function()
      if vim.fn.argc() > 0 then
        local arg = vim.fn.argv(0)
        if vim.fn.isdirectory(arg) == 1 then
          require('lazy').load { plugins = { 'mini.nvim' } }
        end
      end
    end,
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

          -- Use <leader>ha to match your global Grapple toggle key
          vim.keymap.set('n', '<leader>ha', function()
            local entry = MiniFiles.get_fs_entry()

            -- Only toggle tags for actual files, not directories
            if entry and (entry.fs_type == 'file' or entry.type == 'file') then
              require('grapple').toggle { path = entry.path }
              vim.notify('Toggled Grapple tag: ' .. entry.name)
            end
          end, { buffer = buf_id, desc = 'Grapple toggle tag (mini.files)' })

          -- Add file to Aider
          vim.keymap.set('n', '<leader>t+', function()
            local entry = MiniFiles.get_fs_entry()
            if entry and (entry.fs_type == 'file' or entry.type == 'file') then
              require('aider').add_file(entry.path)
            end
          end, { buffer = buf_id, desc = 'Aider: Add file' })
        end,
      })
    end,
  },
  {
    -- Mason
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    -- Treesitter: Advanced syntax highlighting and code parsing.
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
      terminal = {
        enabled = true,
        win = {
          position = 'right',
          width = 0.4,
        },
      },
      explorer = { enabled = false },
      picker = {
        enabled = true,
        layout = { preset = 'vscode' },
        sources = {
          explorer = {
            hidden = true,
            exclude = { '**/*.uid', '**/*.import' },
          },
          files = {
            hidden = true,
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

      -- Ensure shell uses MSYS2 Zsh directly
      if vim.fn.has 'win32' == 1 then
        -- Direct path to the zsh binary inside the MSYS2 folder
        -- Scoop usually installs MSYS2 to this location:
        local msys2_zsh = 'C:/Users/jamie/scoop/apps/msys2/current/usr/bin/zsh.exe'

        if vim.fn.executable(msys2_zsh) == 1 then
          vim.o.shell = msys2_zsh
          -- These flags ensure zsh starts correctly without looking for cmd.exe syntax
          vim.o.shellcmdflag = '-c'
          vim.o.shellquote = ''
          vim.o.shellxquote = ''
        else
          -- Fallback if the path above is wrong
          vim.notify('MSYS2 Zsh not found at: ' .. msys2_zsh, vim.log.levels.WARN)
        end
      end

      -- Bacon Terminal: Automatically spin up a hidden terminal
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
          -- Use Snacks.terminal.get to initialize without forcing focus
          Snacks.terminal.get('bacon clippy', {
            interactive = false,
            name = 'Bacon Builder',
            env = {
              RUST_BACKTRACE = '1',
              CARGO_BUILD_JOBS = '12',
              CARGO_TARGET_DIR = 'target-bacon', -- Isolates the build lock
            },
            win = { position = 'bottom', height = 0.3 },
            start_insert = false,
          })
        end,
      })

      -- Godot-Specific Logic: Intercept rename hooks
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
}
