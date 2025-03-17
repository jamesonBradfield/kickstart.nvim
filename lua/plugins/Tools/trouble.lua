return {
	{
		'folke/trouble.nvim',
		lazy = false,
		opts = {
			position = 'bottom',
			modes = {
				diagnostics = {
					-- This is the built-in diagnostics mode
					preview = {
						type = 'split',
						relative = 'win',
						oposition = 'right',
						size = 0.3,
					},
				},
				test = {
					mode = 'diagnostics',
					auto_open = true, -- This will make it auto-open when diagnostics are available
					auto_close = true, -- Close when no diagnostics
					focus = false,
					preview = {
						type = 'split',
						relative = 'win',
						position = 'right',
						size = 0.5,
					},
				},
			},
		},
		config = function(_, opts)
			require('trouble').setup(opts)
		end,
		cmd = 'Trouble',
		keys = function()
			local mappings = require 'mappings'
			return mappings.trouble()
		end,
	},
}
