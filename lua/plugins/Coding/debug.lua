-- ~/.config/nvim/lua/plugins/debug.lua
return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'rcarriga/nvim-dap-ui',
		'nvim-neotest/nvim-nio',
		'theHamsta/nvim-dap-virtual-text',
		'nvim-treesitter/nvim-treesitter',
		'folke/snacks.nvim',
	},
	lazy = true, -- Enable lazy loading for better startup performance
	keys = {
		-- Standard DAP keybindings
		{
			'<F5>',
			mode = { 'n' },
			function()
				require('dap').continue()
			end,
			desc = 'F5 dap ~ [c]ontinue',
		},
		{
			'<F10>',
			mode = { 'n' },
			function()
				require('dap').step_over()
			end,
			desc = 'dap ~ step [o]ver',
		},
		{
			'<F11>',
			mode = { 'n' },
			function()
				require('dap').step_into()
			end,
			desc = 'F11 dap ~ step into',
		},
		{
			'<S-F11>',
			mode = { 'n' },
			function()
				require('dap').step_out()
			end,
			desc = 'Shift F11 dap ~ Step [O]ut',
		},
		{
			'<Leader>b',
			mode = { 'n' },
			function()
				require('dap').toggle_breakpoint()
			end,
			desc = 'dap ~ toggle [b]reakpoint',
		},
		
		-- Godot-specific keybindings
		{
			'<Leader>dg',
			mode = { 'n' },
			function()
				require('godot-debug').launch()
			end,
			desc = 'Launch Godot debugger',
		},
		{
			'<Leader>dG',
			mode = { 'n' },
			function()
				require('godot-debug').launch({ skip_build = true })
			end,
			desc = 'Launch Godot debugger (skip build)',
		},
		{
			'<Leader>dk',
			mode = { 'n' },
			function()
				require('godot-debug').kill_godot_processes()
			end,
			desc = 'Kill Godot processes',
		},
	},
	config = function()
		local dap = require('dap')
		local dapui = require('dapui')
		
		-- Enable trace level logging for DAP
		dap.set_log_level('TRACE')
		
		-- Configure dapui
		dapui.setup {
			layouts = {
				{
					elements = {
						{ id = 'scopes', size = 0.25 },
						'breakpoints',
						'stacks',
						'watches',
					},
					size = 40,
					position = 'left',
				},
				{
					elements = {
						'repl',
						'console',
					},
					size = 0.25,
					position = 'bottom',
				},
			},
		}

		-- Automatically open/close dapui
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
}
