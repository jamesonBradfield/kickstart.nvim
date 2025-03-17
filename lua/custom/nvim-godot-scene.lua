return {
	'nvim-godot-scene',
	dir = vim.fn.stdpath 'config' .. '/lua/custom/nvim-godot-scene',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		require('nvim-godot-scene').setup {
		}
	end,
}
