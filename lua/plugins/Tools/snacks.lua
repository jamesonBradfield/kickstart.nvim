local mappings = require 'mappings'
return {
	{
		'folke/snacks.nvim',
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				sections = {
					{ section = 'header' },
					{ icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
					{ icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
					{ icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
					{ section = 'startup' },
				},
			},
			layout = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			picker = {
				enabled = true,
				sources = {
					explorer = {
						-- Your explorer config goes here
						finder = 'explorer',
						sort = { fields = { 'sort' } },
						supports_live = true,
						tree = true,
						watch = true,
						diagnostics = true,
						diagnostics_open = false,
						git_status = true,
						git_status_open = false,
						git_untracked = true,
						follow_file = true,
						focus = 'list',
						auto_close = false,
						jump = { close = false },
						layout = { preset = 'sidebar', preview = false },
						formatters = {
							file = { filename_only = true },
							severity = { pos = 'right' },
						},
						matcher = { sort_empty = false, fuzzy = false },
						config = function(opts)
							return require('snacks.picker.source.explorer').setup(opts)
						end,
						win = {
							list = {
								keys = mappings.snacks_picker(),
							},
						},
					},
				},
			},
			explorer = { enabled = true },
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			styles = {
				notification = {
					-- wo = { wrap = true } -- Wrap notifications
				},
			},
			dim = {
				scope = {
					min_size = 5,
					max_size = 20,
					siblings = true,
				},
				-- animate scopes. Enabled by default for Neovim >= 0.10
				-- Works on older versions but has to trigger redraws during animation.
				animate = {
					enabled = vim.fn.has 'nvim-0.10' == 1,
					easing = 'outQuad',
					duration = {
						step = 20, -- ms per step
						total = 300, -- maximum duration
					},
				},
				-- what buffers to dim
				filter = function(buf)
					return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ''
				end,
			},
			zen = {
				toggles = {
					dim = true,
				},
				win = { style = "zen", backdrop = 0, border = "rounded", resize = true},
				on_open = function()
					vim.cmd [[highlight SnacksBackdrop_000000 guibg=#0d0c0c]]
				end,
				show = { statusline = true, tabline = true },
				zoom = {
					toggles = {},
					show = { statusline = true, tabline = true },
					win = {
						backdrop = true,
						width = 0, -- full width
					},
				},
			},
		},
		keys = mappings.snacks(),
		init = function()
			vim.api.nvim_create_autocmd('User', {
				pattern = 'VeryLazy',
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd -- Override print to use snacks for `:=` command

					-- Create some toggle mappings
					Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>sts'
					Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>stw'
					Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>stL'
					Snacks.toggle.diagnostics():map '<leader>std'
					Snacks.toggle.line_number():map '<leader>stl'
					Snacks.toggle.option('conceallevel',
						{ off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>stc'
					Snacks.toggle.treesitter():map '<leader>stT'
					Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>stb'
					Snacks.toggle.inlay_hints():map '<leader>sth'
					Snacks.toggle.indent():map '<leader>stg'
					Snacks.toggle.dim():map '<leader>stD'
				end,
			})
		end,
	},
	{
		'folke/trouble.nvim',
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = 'Trouble',
		keys = mappings.trouble(),
	},
}
