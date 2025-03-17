return {
	-- Mason for package management
	{
		'williamboman/mason.nvim',
		priority = 100,
		config = function()
			local mason_ok, mason = pcall(require, 'mason')
			if not mason_ok then
				print 'Failed to load mason'
				return
			end
			mason.setup {
				check_outdated_packages_on_open = true,
				border = 'none',
				log_level = vim.log.levels.DEBUG,
				ui = {
					icons = {
						package_installed = '✓',
						package_pending = '➜',
						package_uninstalled = '✗',
					},
				},
				registries = {
					'github:nvim-java/mason-registry',
					'github:mason-org/mason-registry',
				},
				install = {
					connection_timeout = 3600,
				},
				max_concurrent_installers = 2,
			}
		end,
	},

	-- Mason-lspconfig to connect Mason with LSP configuration
	{
		'williamboman/mason-lspconfig.nvim',
		dependencies = { 'williamboman/mason.nvim' },
		config = function()
			require('mason-lspconfig').setup {
				-- List servers that should be installed and set up automatically
				ensure_installed = {
					'omnisharp@v1.39.8',
				},
			}
		end,
	},

	-- Mason-tool-installer for additional tools
	{
		'WhoIsSethDaniel/mason-tool-installer.nvim',
		dependencies = { 'williamboman/mason.nvim' },
		config = function()
			require('mason-tool-installer').setup {
				ensure_installed = {
					-- Language servers
					'lua-language-server',
					'csharp-language-server',
					-- Java tools
					'jdtls',
					'java-debug-adapter',
					'java-test',
					'gradle-language-server',
					-- Formatters
					'stylua', -- Lua formatter
					'csharpier', -- C# formatter
					-- Linters
					'codespell', -- Spell checker for code
					-- Debuggers
					'netcoredbg', -- .NET Core debugger
				},
				auto_update = true,
				run_on_start = false,
			}

			-- For specific OmniSharp version
			vim.api.nvim_create_autocmd('User', {
				pattern = 'MasonToolsUpdateCompleted',
				callback = function()
					-- Check if OmniSharp is installed with the right version
					local registry = require 'mason-registry'
					local omnisharp_pkg = registry.get_package 'omnisharp'

					-- Uninstall current version if it exists
					if omnisharp_pkg:is_installed() then
						vim.notify('Uninstalling current OmniSharp version...', vim.log.levels.INFO)
						omnisharp_pkg:uninstall()
					end

					-- Install specific version
					vim.notify('Installing OmniSharp v1.39.8...', vim.log.levels.INFO)

					-- Use jobstart for async installation
					vim.fn.jobstart('cd ' .. vim.fn.stdpath 'data' .. '/mason && mason install omnisharp@1.39.8', {
						on_exit = function(_, code)
							if code == 0 then
								vim.notify('OmniSharp v1.39.8 installed successfully!', vim.log.levels.INFO)
							else
								vim.notify('Failed to install OmniSharp v1.39.8', vim.log.levels.ERROR)
							end
						end,
					})
				end,
				once = true,
			})
		end,
	},

	-- LSP Configuration
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'Hoffs/omnisharp-extended-lsp.nvim',
			'kevinhwang91/nvim-ufo',
			'kevinhwang91/promise-async',
			'hrsh7th/nvim-cmp',
		},
		config = function()
			local keymap = require 'keymaps'
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

			-- Set up enhanced hover UI
			local hover_config = {
				border = 'rounded',
				max_width = 80,
				max_height = 30,
			}

			-- Configure the LSP handlers for better UI
			vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, hover_config)
			vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, hover_config)

			-- Common on_attach function
			local on_attach = function(client, bufnr)
				-- Your existing on_attach logic here...
				vim.opt.updatetime = 300
				local has_saga, _ = pcall(require, 'lspsaga')
				if not has_saga then
					-- Your existing keymaps here
					keymap.buf_map(bufnr, 'n', '<leader>la', vim.lsp.buf.code_action, { desc = 'LSP code actions' })
					keymap.buf_map(bufnr, 'n', '<leader>lh', vim.lsp.buf.hover, { desc = 'Show hover documentation' })
					keymap.buf_map(bufnr, 'n', '<leader>ln', vim.lsp.buf.rename, { desc = 'Rename symbol' })
					keymap.buf_map(bufnr, 'n', '<leader>ld', vim.lsp.buf.definition, { desc = 'Go to definition' })
					keymap.buf_map(bufnr, 'n', '<leader>lD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
					keymap.buf_map(bufnr, 'n', '<leader>li', vim.lsp.buf.implementation,
						{ desc = 'Go to implementation' })
					keymap.buf_map(bufnr, 'n', '<leader>lr', vim.lsp.buf.references, { desc = 'Find references' })
					keymap.buf_map(bufnr, 'n', '<leader>lt', vim.lsp.buf.type_definition,
						{ desc = 'Go to type definition' })
					keymap.buf_map(bufnr, 'i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Show signature help' })
					keymap.buf_map(bufnr, 'n', '<leader>lf', function()
						vim.lsp.buf.format { timeout_ms = 2000 }
					end, { desc = 'Format code' })
				else
					keymap.buf_map(bufnr, 'n', '<leader>lf', function()
						vim.lsp.buf.format { timeout_ms = 2000 }
					end, { desc = 'Format code' })
				end
			end

			-- Set up GDScript manually (not available through mason-lspconfig)
			require('lspconfig').gdscript.setup {
				cmd = { 'nc', 'localhost', '6005' },
				filetypes = { 'gdscript', 'gd' },
				root_dir = require('lspconfig').util.root_pattern('project.godot', '.git'),
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					vim.bo[bufnr].expandtab = true
					vim.bo[bufnr].shiftwidth = 4
					vim.bo[bufnr].tabstop = 4
					vim.bo[bufnr].softtabstop = 4

					on_attach(client, bufnr)
				end,
			}

			-- Use mason-lspconfig to set up servers (excluding gdscript)
			require('mason-lspconfig').setup_handlers {
				-- Default handler
				function(server_name)
					require('lspconfig')[server_name].setup {
						capabilities = capabilities,
						on_attach = on_attach,
					}
				end,

				-- Custom handlers for specific servers
				['lua_ls'] = function()
					require('lspconfig').lua_ls.setup {
						settings = {
							Lua = {
								completion = { callSnippet = 'Replace' },
							},
						},
						capabilities = capabilities,
						on_attach = on_attach,
					}
				end,

				['omnisharp'] = function()
					local pid = vim.fn.getpid()
					require('lspconfig').omnisharp.setup {
						cmd = {
							'/home/jamie/.local/share/nvim/mason/bin/omnisharp',
							'--languageserver',
							'--hostPID',
							tostring(pid),
						},
						handlers = {
							['textDocument/definition'] = require('omnisharp_extended').handler,
							['textDocument/implementation'] = require('omnisharp_extended').handler,
						},
						capabilities = capabilities,
						on_attach = function(client, bufnr)
							on_attach(client, bufnr)

							client.server_capabilities.documentFormattingProvider = true
							client.server_capabilities.hoverProvider = true
							client.server_capabilities.documentHighlightProvider = true

							keymap.buf_map(bufnr, 'n', 'gd',
								"<cmd>lua require('omnisharp_extended').lsp_definition()<cr>")
							keymap.buf_map(bufnr, 'n', '<leader>D',
								"<cmd>lua require('omnisharp_extended').lsp_type_definition()<cr>")
							keymap.buf_map(bufnr, 'n', 'gr',
								"<cmd>lua require('omnisharp_extended').lsp_references()<cr>")
							keymap.buf_map(bufnr, 'n', 'gi',
								"<cmd>lua require('omnisharp_extended').lsp_implementation()<cr>")

							vim.bo[bufnr].expandtab = true
							vim.bo[bufnr].shiftwidth = 4
							vim.bo[bufnr].tabstop = 4
						end,
					}
				end,
			}
		end,
	},
}
