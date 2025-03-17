local M = {}
local config = {}
-- Default configuration
local DEFAULT_CONFIG = {
	break_time = 5,
	work_time = 6000,
}

M.setup = function (opts)
  	config = vim.tbl_deep_extend('force', DEFAULT_CONFIG, opts or {})

	vim.notify("pomo setup has been called with config \n" .. vim.inspect(config))
end

M.start_pomo = function ()
	vim.fn.timer_start(config.work_time, function ()
		vim.notify("timer ended")
	end)
end

return M
