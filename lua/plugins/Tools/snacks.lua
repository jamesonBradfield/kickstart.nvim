-- Enhanced snacks.lua with offset tabline and improved explorer focus
-- Fixes explorer key bindings and adds automatic file focusing

return {
	{
		'folke/snacks.nvim',
		priority = 1000,
		lazy = false,
		config = function(_, opts)
			-- Load snacks with properly configured keys first
			local snacks = require 'snacks'

			-- Expose toggle_explorer_focus so it can be called from key mappings
			local toggle_explorer_focus

			-- Track explorer width for tabline offset
			_G.explorer_width = 40 -- Default width, will be updated dynamically

			-- Get explorer picker by source
			local function get_explorer_picker()
				local pickers = snacks.picker.get { source = 'explorer' }
				return pickers and pickers[1] or nil
			end

			-- Focus current file in explorer
			local function focus_current_file()
				local explorer = get_explorer_picker()
				if not explorer then
					return
				end

				local current_buf = vim.api.nvim_get_current_buf()
				local file_path = vim.api.nvim_buf_get_name(current_buf)

				if file_path and file_path ~= '' then
					-- Use reveal functionality from snacks.explorer
					pcall(function()
						snacks.explorer.reveal { file = file_path }
					end)
				end
			end

			-- Function to toggle focus between explorer and editor
			toggle_explorer_focus = function()
				local explorer = get_explorer_picker()

				if explorer then
					-- Explorer exists, check if it's focused
					local is_focused = false
					pcall(function()
						is_focused = explorer.is_focused and explorer:is_focused()
					end)

					if is_focused then
						-- Find and focus a normal window
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_is_valid(win) then
								local buf = vim.api.nvim_win_get_buf(win)
								if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == '' then
									vim.api.nvim_set_current_win(win)
									break
								end
							end
						end
					else
						-- Focus explorer
						pcall(function()
							if explorer.focus then
								explorer:focus 'list'
							end
						end)
					end
				else
					-- Open explorer
					pcall(function()
						snacks.picker.pick 'explorer'
					end)

					-- Focus after creation
					vim.defer_fn(function()
						local picker = get_explorer_picker()
						if picker then
							pcall(function()
								if picker.focus then
									picker:focus 'list'
								end

								-- Get and store the explorer width for tabline offset
								if picker.list then
									local win_id = nil
									pcall(function()
										win_id = picker.list.win
									end)

									if type(win_id) == 'number' and vim.api.nvim_win_is_valid(win_id) then
										_G.explorer_width = vim.api.nvim_win_get_width(win_id)
									end
								end
							end)
						end
					end, 100)
				end
			end

			-- Define custom key functions for explorer
			local explorer_keys = {
				['l'] = function(_)
					-- Get all pickers first
					local pickers = require('snacks.picker').get { source = 'explorer' }
					if not pickers or #pickers == 0 then
						vim.notify('No explorer picker found', vim.log.levels.ERROR)
						return
					end

					-- Get the first (and should be only) explorer picker
					local picker = pickers[1]
					if not picker then
						vim.notify('Could not get picker instance', vim.log.levels.ERROR)
						return
					end

					-- Try to get current item safely
					local ok, item = pcall(function()
						return picker:current { resolve = true }
					end)
					if not ok or not item then
						vim.notify('No item selected', vim.log.levels.WARN)
						return
					end

					-- Handle directory vs file
					if item.dir == true then
						pcall(function()
							picker:action 'explorer_focus'
							picker:action 'confirm'
						end)
						return
					end

					-- Handle file
					pcall(function()
						picker:close()
						vim.cmd('tabedit ' .. vim.fn.fnameescape(item._path))
					end)
				end,
				['h'] = function()
					-- Get all pickers first
					local pickers = require('snacks.picker').get { source = 'explorer' }
					if not pickers or #pickers == 0 then
						vim.notify('No explorer picker found', vim.log.levels.ERROR)
						return
					end

					-- Get the first (and should be only) explorer picker
					local picker = pickers[1]
					if not picker then
						vim.notify('Could not get picker instance', vim.log.levels.ERROR)
						return
					end

					-- Try to get current item safely
					local ok, item = pcall(function()
						return picker:current { resolve = true }
					end)
					if not ok or not item then
						vim.notify('No item selected', vim.log.levels.WARN)
						return
					end

					pcall(function()
						picker:action 'explorer_close'
						picker:action 'explorer_up'
						picker:action 'explorer_update'
					end)
				end,
				['a'] = 'explorer_add',
				['d'] = 'explorer_del',
				['r'] = 'explorer_rename',
				['c'] = 'explorer_copy',
				['m'] = 'explorer_move',
				['o'] = 'explorer_open',
				['P'] = 'toggle_preview',
				['y'] = { 'explorer_yank', mode = { 'n', 'x' } },
				['p'] = 'explorer_paste',
				['u'] = 'explorer_update',
				['<c-c>'] = 'tcd',
				['<leader>/'] = 'picker_grep',
				['<c-t>'] = 'terminal',
				['.'] = 'explorer_focus',
				['I'] = 'toggle_ignored',
				['H'] = 'toggle_hidden',
				['Z'] = 'explorer_close_all',
				[']g'] = 'explorer_git_next',
				['[g'] = 'explorer_git_prev',
				[']d'] = 'explorer_diagnostic_next',
				['[d'] = 'explorer_diagnostic_prev',
				[']w'] = 'explorer_warn_next',
				['[w'] = 'explorer_warn_prev',
				[']e'] = 'explorer_error_next',
				['[e'] = 'explorer_error_prev',

				-- New keys
				['<C-f>'] = function()
					toggle_explorer_focus()
				end,

				-- Focus current file
				['<leader>f'] = function()
					focus_current_file()
				end,
			}

			-- Update explorer configuration with our keys
			if opts.picker and opts.picker.sources and opts.picker.sources.explorer then
				opts.picker.sources.explorer.win = opts.picker.sources.explorer.win or {}
				opts.picker.sources.explorer.win.list = opts.picker.sources.explorer.win.list or {}
				opts.picker.sources.explorer.win.list.keys = vim.tbl_deep_extend('force',
					opts.picker.sources.explorer.win.list.keys or {}, explorer_keys)
			end

			-- Initialize snacks with our updated configuration
			snacks.setup(opts)

			-- Open explorer on startup (after a small delay)
			vim.defer_fn(function()
				if vim.fn.argc() == 0 then
					pcall(function()
						snacks.picker.pick 'explorer'
					end)
				end
			end, 200)

			-- Set up minimal PDE functionality
			vim.api.nvim_create_autocmd('User', {
				pattern = 'VeryLazy',
				callback = function()
					-- Global state for tabline
					_G.pde_state = {
						explorer_active = false,
						trouble_active = false,
						explorer_width = 40, -- Default width
					}

					-- Set up debug helpers
					_G.dd = function(...)
						snacks.debug.inspect(...)
					end
					_G.bt = function()
						snacks.debug.backtrace()
					end
					vim.print = _G.dd

					-- Set up toggle mappings
					pcall(function()
						snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>sts'
						snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>stw'
						snacks.toggle.diagnostics():map '<leader>std'
						snacks.toggle.line_number():map '<leader>stl'
						snacks.toggle.treesitter():map '<leader>stT'
						snacks.toggle.dim():map '<leader>stD'
					end)

					-- Load custom tabline
					pcall(function()
						require('custom_tabline').setup()
					end)

					-- Update global state for tabline and monitor explorer width
					local function update_state()
						local explorer = get_explorer_picker()
						_G.pde_state.explorer_active = explorer ~= nil

						-- Update explorer width if active
						if explorer and explorer.list then
							local win_id = nil
							pcall(function()
								win_id = explorer.list.win
							end)

							if type(win_id) == 'number' and vim.api.nvim_win_is_valid(win_id) then
								local width = vim.api.nvim_win_get_width(win_id)
								_G.pde_state.explorer_width = width
								_G.explorer_width = width
							end
						end

						-- Check if trouble is open
						_G.pde_state.trouble_active = false
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_is_valid(win) then
								local buf = vim.api.nvim_win_get_buf(win)
								if vim.api.nvim_buf_is_valid(buf) and vim.b[buf] and vim.b[buf].trouble then
									_G.pde_state.trouble_active = true
									break
								end
							end
						end

						-- Update tabline
						vim.cmd 'redrawtabline'
					end

					-- Map C-f globally
					vim.keymap.set('n', '<C-f>', toggle_explorer_focus, {
						desc = 'Toggle focus between Explorer and Editor',
						silent = true,
						noremap = true,
					})

					-- Map Focus current file globally
					vim.keymap.set('n', '<leader>fc', focus_current_file, {
						desc = 'Focus current file in explorer',
						silent = true,
						noremap = true,
					})

					-- Create autocommand group
					local pde_group = vim.api.nvim_create_augroup('PDEMinimal', { clear = true })

					-- Open explorer on startup
					vim.api.nvim_create_autocmd('VimEnter', {
						callback = function()
							if vim.fn.argc() == 0 then
								vim.defer_fn(function()
									pcall(function()
										snacks.picker.pick 'explorer'
										vim.defer_fn(update_state, 10)
									end)
								end, 100)
							end
						end,
						group = pde_group,
					})

					-- Focus current file in the explorer when opening a new buffer
					vim.api.nvim_create_autocmd('BufEnter', {
						callback = function()
							-- Only for real files
							local bufnr = vim.api.nvim_get_current_buf()
							if vim.bo[bufnr].buftype == '' and vim.bo[bufnr].filetype ~= 'explorer' then
								-- Don't focus immediately to avoid interruptions
								vim.defer_fn(function()
									-- Only focus if explorer is open but not focused
									local explorer = get_explorer_picker()
									if explorer then
										local is_focused = false
										pcall(function()
											is_focused = explorer.is_focused and explorer:is_focused()
										end)

										if not is_focused then
											focus_current_file()
										end
									end
								end, 300)
							end

							-- Always update state for tabline
							vim.defer_fn(function()
								pcall(update_state)
							end, 10)
						end,
						group = pde_group,
					})

					-- Show trouble when diagnostics are available
					vim.api.nvim_create_autocmd('LspAttach', {
						callback = function()
							vim.defer_fn(function()
								local buffer = vim.api.nvim_get_current_buf()
								local diags = vim.diagnostic.get(buffer)
								if diags and #diags > 0 then
									pcall(function()
										vim.cmd 'Trouble diagnostics'
										vim.defer_fn(update_state, 10)
									end)
								end
							end, 1000)
						end,
						group = pde_group,
					})

					-- Update state whenever a window changes
					vim.api.nvim_create_autocmd({ 'WinEnter', 'WinResized' }, {
						callback = function()
							vim.defer_fn(function()
								pcall(update_state)
							end, 10)
						end,
						group = pde_group,
					})

					-- Initial state update
					pcall(update_state)
				end,
			})
		end,
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				sections = {
					{ section = 'header' },
					{ icon = ' ',         title = 'Keymaps',      section = 'keys',         indent = 2, padding = 1 },
					{ icon = ' ',         title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
					{ icon = ' ',         title = 'Projects',     section = 'projects',     indent = 2, padding = 1 },
					{ section = 'startup' },
				},
			},
			layout = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true, timeout = 3000 },
			explorer = { enabled = true, replace_netrw = true },
			picker = {
				enabled = true,
				sources = {
					explorer = {
						finder = 'explorer',
						sort = { fields = { 'sort' } },
						supports_live = true,
						tree = true,
						watch = true,
						diagnostics = true,
						git_status = true,
						git_untracked = true,
						follow_file = true,
						focus = 'list',
						auto_close = false,
						jump = { close = false },
						layout = {
							preset = 'sidebar',
							preview = false,
							width = 40, -- Initial width
						},
					},
				},
			},
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			dim = {
				scope = { min_size = 5, max_size = 20, siblings = true },
				animate = {
					enabled = vim.fn.has 'nvim-0.10' == 1,
					easing = 'outQuad',
					duration = { step = 20, total = 300 },
				},
				filter = function(buf)
					return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ''
				end,
			},
			zen = {
				toggles = { dim = true },
				win = {
					style = 'zen',
					backdrop = { transparent = true, blend = 30 },
					border = 'rounded',
					width = 0,
					resize = true,
				},
				show = { statusline = true, tabline = true },
			},
		},
		keys = function()
			local mappings = require 'mappings'
			return mappings.snacks()
		end,
	},
	{
		'folke/trouble.nvim',
		opts = {
			position = 'bottom',
			height = 10,
			padding = true,
			icons = {
				error = '',
				warning = '',
				hint = '',
				information = '',
				other = '',
			},
			auto_preview = false,
			auto_close = false,
			auto_fold = false,
			action_keys = {
				close = 'q',
				cancel = '<esc>',
				refresh = 'r',
				jump = '<cr>',
				toggle_mode = 'm',
				toggle_preview = 'P',
				preview = 'p',
				close_folds = 'zM',
				open_folds = 'zR',
				toggle_fold = 'za',
				previous = 'k',
				next = 'j',
			},
		},
		cmd = 'Trouble',
		keys = function()
			local mappings = require 'mappings'
			return mappings.trouble()
		end,
	},
}
