return {
	'nvimtools/none-ls.nvim',
	dependencies = 'nvim-lua/plenary.nvim',
	config = function()
		-- Update your none-ls.lua sources:
		local null_ls = require 'null-ls'
		local cspell = null_ls.builtins.diagnostics.codespell
		null_ls.setup {
			sources = {
				-- Existing sources
				null_ls.builtins.formatting.gdformat,
				null_ls.builtins.diagnostics.gdlint,
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.lua_ls,

				-- C# formatting
				null_ls.builtins.formatting.omnisharp,

				-- Documentation and spelling
				cspell.with {
					filetypes = { 'cs', 'gdscript' },
				},
				null_ls.builtins.code_actions.gitsigns,
			},
			debug = true,

			on_attach = function(client, bufnr)
				if client.server_capabilities.documentFormattingProvider then
					vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr()'
				end

				if client.server_capabilities.documentRangeFormattingProvider then
					vim.bo[bufnr].formatexpr = 'v:lua.vim.lsp.formatexpr()'
				end
			end,
		}

		local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
		require('null-ls').setup {
			-- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client.supports_method 'textDocument/formatting' then
					vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
					vim.api.nvim_create_autocmd('BufWritePre', {
						group = augroup,
						buffer = bufnr,
						callback = function()
							-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
							-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
							vim.lsp.buf.format { async = false }
						end,
					})
				end
			end,
		}
	end,
}
