return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',

    { 'Hoffs/omnisharp-extended-lsp.nvim', ft = 'cs' },
    'saghen/blink.cmp',
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    -- Configure diagnostics
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    }

    local function client_supports_method(client, method, bufnr)
      if vim.fn.has 'nvim-0.11' == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        -- Common LSP keymaps for all languages using Snacks
        map('gr', function()
          Snacks.picker.lsp_references()
        end, '[G]oto [R]eferences')
        map('gI', function()
          Snacks.picker.lsp_implementations()
        end, '[G]oto [I]mplementation')
        map('<leader>D', function()
          Snacks.picker.lsp_type_definitions()
        end, 'Type [D]efinition')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Document highlighting
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
      end,
    })

    -- Setup mason-lspconfig for Mason-managed servers
    require('mason-lspconfig').setup {
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        -- Default handler for Mason-managed servers
        function(server_name)
          local capabilities = require('blink.cmp').get_lsp_capabilities()

          -- Special handling for omnisharp
          if server_name == 'omnisharp' then
            local ok, omnisharp_extended = pcall(require, 'omnisharp_extended')
            local handlers = {}
            if ok then
              handlers = {
                ['textDocument/definition'] = omnisharp_extended.definition_handler,
                ['textDocument/typeDefinition'] = omnisharp_extended.type_definition_handler,
                ['textDocument/references'] = omnisharp_extended.references_handler,
                ['textDocument/implementation'] = omnisharp_extended.implementation_handler,
              }
            end

            require('lspconfig').omnisharp.setup {
              capabilities = capabilities,
              handlers = handlers,
              cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
              settings = {
                FormattingOptions = {
                  EnableEditorConfigSupport = true,
                },
                RoslynExtensionsOptions = {
                  EnableImportCompletion = true,
                  EnableAnalyzersSupport = false,
                  AnalyzeOpenDocumentsOnly = true,
                },
                Sdk = {
                  IncludePrereleases = false,
                },
              },
              root_dir = function(filename)
                return require('lspconfig.util').root_pattern('*.sln', '*.csproj', 'project.godot')(filename)
              end,
              init_options = {
                AutomaticWorkspaceInit = true,
              },
            }
          elseif server_name == 'lua_ls' then
            require('lspconfig').lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  completion = {
                    callSnippet = 'Replace',
                  },
                },
              },
            }
          else
            -- Default setup for other servers
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
            }
          end
        end,
      },
    }

    -- CRITICAL: Setup gdscript manually (not managed by Mason)
    local lspconfig = require 'lspconfig'
    lspconfig.gdscript.setup {
      capabilities = require('blink.cmp').get_lsp_capabilities(),
      cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      root_dir = require('lspconfig.util').root_pattern('project.godot', '.git'),
      filetypes = { 'gd', 'gdscript', 'gdscript3' },
    }
  end,
}
