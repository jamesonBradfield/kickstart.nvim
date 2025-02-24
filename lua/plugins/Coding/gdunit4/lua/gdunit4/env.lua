-- env.lua
local M = {}

-- Check GODOT_BIN environment variable and prompt if not set
function M.check_godot_bin()
	local godot_bin = os.getenv 'GODOT_BIN'
	if not godot_bin or godot_bin == '' then
		vim.notify('GODOT_BIN environment variable not set. Please enter the path to your Godot executable:',
			vim.log.levels.WARN)
		vim.ui.input({
			prompt = 'Path to godot-mono executable: ',
			default = '/usr/bin/godot-mono',
		}, function(input)
			if input and input ~= '' then
				vim.fn.setenv('GODOT_BIN', input)
				vim.notify('GODOT_BIN set to: ' .. input, vim.log.levels.INFO)
				godot_bin = input
			else
				vim.notify('No path provided. GdUnit4 will not function correctly.', vim.log.levels.ERROR)
				return false
			end
		end)
	end

	-- Early return if we still don't have a valid path
	if not godot_bin or godot_bin == '' then
		return false
	end

	-- Verify the executable exists
	local stat = vim.uv.fs_stat(godot_bin)
	if not stat then
		vim.notify('Godot executable not found at: ' .. godot_bin, vim.log.levels.ERROR)
		return false
	end

	-- Check if it's executable
	if bit.band(stat.mode, 73) == 0 then -- 73 = executable bits for user and group
		vim.notify('Godot executable does not have execute permissions: ' .. godot_bin, vim.log.levels.ERROR)
		return false
	end

	return true
end

-- Check runner script permissions on Unix systems
function M.check_runner_script(project_root, runner_script)
	if vim.fn.has 'unix' == 1 then
		-- Create proper path by removing leading slash if present
		runner_script = runner_script:gsub('^/', '')
		local script_path = project_root .. '/' .. runner_script

		-- Debug info
		vim.notify('Checking script at: ' .. script_path, vim.log.levels.INFO)

		-- Check if file exists
		local stat = vim.uv.fs_stat(script_path)
		if not stat then
			vim.notify('Runner script not found at: ' .. script_path, vim.log.levels.ERROR)
			return false
		end

		-- Check if script is executable (octal 0100 in the mode)
		local executable_bit = 64 -- equivalent to 0x40
		if bit.band(stat.mode, executable_bit) == 0 then
			vim.notify('Runner script is not executable. Setting permissions...', vim.log.levels.WARN)

			-- Try to make it executable (0755)
			local ok, err = pcall(vim.uv.fs_chmod, script_path, 493)
			if not ok then
				vim.notify('Failed to set executable permissions on runner script: ' .. (err or ''), vim.log.levels
				.ERROR)
				return false
			end
			vim.notify('Successfully set executable permissions on runner script', vim.log.levels.INFO)
		end
	end
	return true
end

return M
