return {
	'nvimdev/lspsaga.nvim',
	enabled = false,
	dependencies = {
		'nvim-treesitter/nvim-treesitter',
		'nvim-tree/nvim-web-devicons',
	},
	event = 'LspAttach',
	config = function()
		local saga = require 'lspsaga'

		saga.setup {
			-- UI customization
			ui = {
				border = 'rounded',
				code_action = '💡',
				actionfix = ' ',
				imp_sign = '󰳛 ',
				lines = { '┗', '┣', '┃', '━', '┏' },
				kind = {}, -- Use default kind icons
			},

			-- Enable beacon for jump locations
			beacon = {
				enable = true,
				frequency = 7,
			},

			-- Scrolling in preview windows
			scroll_preview = {
				scroll_down = '<C-f>',
				scroll_up = '<C-b>',
			},

			-- Hover window configuration
			hover = {
				max_width = 0.7,
				max_height = 0.6,
				open_link = 'gx',
				open_cmd = '!chrome',
			},

			-- Signature help settings
			signature = {
				max_height = 15,
				max_width = 80,
				handler_opts = {
					border = 'rounded',
				},
				auto_close = true,
			},

			-- Lightbulb for code actions
			lightbulb = {
				enable = true,
				enable_in_insert = true,
				sign = true,
				sign_priority = 40,
				virtual_text = true,
				debounce = 10,
			},

			-- Implementation indicators
			implement = {
				enable = true,
				sign = true,
				virtual_text = true,
				priority = 100,
			},

			-- Symbol finder
			finder = {
				max_height = 0.7,
				keys = {
					expand_or_jump = '<CR>',
					vsplit = 'v',
					split = 's',
					tabe = 't',
					quit = { 'q', '<ESC>' },
					close_in_preview = '<ESC>',
				},
			},

			-- Symbol in winbar (breadcrumbs)
			symbol_in_winbar = {
				enable = true,
				separator = ' › ',
				hide_keyword = false,
				show_file = true,
				folder_level = 2,
				respect_root = false,
				color_mode = true,
				delay = 300,
			},

			-- Outline window
			outline = {
				win_position = 'right',
				win_width = 30,
				auto_preview = true,
				detail = true,
				auto_close = true,
				close_after_jump = false,
				layout = 'normal',
				max_height = 0.5,
				left_width = 0.3,
			},
		}
	end,
}
