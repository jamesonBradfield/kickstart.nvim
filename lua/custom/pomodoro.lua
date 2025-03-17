  return {
	'pomo',
  	dir = vim.fn.stdpath 'config' .. '/lua/custom/pomo',
	config = function ()
		require('pomo').setup()
	end
  }

