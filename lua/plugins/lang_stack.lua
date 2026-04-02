return {
  {
    -- Rustaceanvim: A heavily optimized wrapper around rust-analyzer.
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        -- LSP configuration
        server = {
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern('Cargo.toml')(fname)
          end,
          on_attach = function(client, bufnr)
            -- Override standard Hover/Action keys with Rustacean's specialized UI
            vim.keymap.set('n', '<leader>ch', function()
              vim.cmd.RustLsp { 'hover', 'actions' }
            end, { silent = true, buffer = bufnr, desc = 'Rustacean: Hover Actions' })

            vim.keymap.set('n', '<leader>ca', function()
              vim.cmd.RustLsp 'codeAction'
            end, { silent = true, buffer = bufnr, desc = 'Rustacean: Code Action' })

            -- Expand macro under cursor - extremely useful for GodotClass macros
            vim.keymap.set('n', '<leader>em', function()
              vim.cmd.RustLsp 'expandMacro'
            end, { silent = true, buffer = bufnr, desc = 'Rustacean: Expand Macro' })
          end,
          default_settings = {
            ['rust-analyzer'] = {
              procMacro = {
                enable = true,
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
              diagnostics = {
                disabled = { 'unresolved-proc-macro', 'proc-macro-disabled' },
              },
              files = {
                excludeDirs = { '.godot', '.git', 'target' },
              },
            },
          },
        },
        -- DAP configuration (rustaceanvim can manage this for us)
        dap = {
          adapter = require('rustaceanvim.config').get_codelldb_adapter('codelldb', 'lldb-community'),
        },
      }
    end,
  },
  {
    -- GDScript Extended LSP
    'Teatek/gdscript-extended-lsp.nvim',
    lazy = false,
    opts = { view_type = 'floating', floating_win_size = 0.6, picker = 'snacks' },
  },
  {
    -- Conform: Formatter manager.
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        gdscript = { 'gdformat' },
        python = { 'ruff_format', 'ruff_organize_imports' },
      },
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
    },
  },
  {
    -- Nvim-Lint: Linter manager.
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = { gd = 'gdlint', python = { 'ruff' }, yaml = { 'yamlfmt' } }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require('lint').try_lint()
          require('lint').try_lint 'cspell'
        end,
      })
    end,
  },
}
