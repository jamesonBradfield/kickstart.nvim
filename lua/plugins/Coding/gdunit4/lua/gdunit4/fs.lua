-- fs.lua
local M = {}
local original_cwd = nil

function M.ensure_project_root()
	local project_file = vim.fn.findfile('project.godot', vim.fn.expand '%:p:h' .. ';')
	if project_file == '' then
		vim.notify('Could not find project.godot file', vim.log.levels.ERROR)
		return nil
	end
	return vim.fn.fnamemodify(project_file, ':p:h')
end

function M.change_to_directory(dir)
	if not dir then
		return false
	end

	-- Store original directory if not already stored
	if not original_cwd then
		original_cwd = vim.uv.cwd()
	end

	-- Check if directory exists and is accessible
	local stat = vim.uv.fs_stat(dir)
	if not stat or stat.type ~= 'directory' then
		vim.notify('Directory does not exist or is not accessible: ' .. dir, vim.log.levels.ERROR)
		return false
	end

	-- Change directory if needed
	if original_cwd ~= dir then
		vim.notify('Attempting to change working directory to: ' .. dir, vim.log.levels.INFO)
		local ok, err = pcall(vim.uv.chdir, dir)

		if not ok then
			vim.notify('Failed to change working directory: ' .. (err or ''), vim.log.levels.ERROR)
			return false
		end

		-- Double check the change worked
		local new_cwd = vim.uv.cwd()
		if new_cwd ~= dir then
			vim.notify('Directory change verification failed. Expected: ' .. dir .. ', Got: ' .. new_cwd,
				vim.log.levels.ERROR)
			return false
		end

		vim.notify('Successfully changed directory to: ' .. new_cwd, vim.log.levels.INFO)
	end

	return true
end

function M.restore_directory()
	if original_cwd then
		local ok, err = pcall(vim.uv.chdir, original_cwd)

		if not ok then
			vim.notify('Failed to restore directory: ' .. (err or ''), vim.log.levels.ERROR)
		else
			vim.notify('Successfully restored directory to: ' .. original_cwd, vim.log.levels.INFO)
		end
		original_cwd = nil
	end
end

function M.create_test_directory(project_root)
	local test_dir = project_root .. '/test'

	-- Check if directory exists first
	local stat = vim.uv.fs_stat(test_dir)
	if not stat then
		-- Directory doesn't exist, create it
		local ok, err = pcall(function()
			vim.uv.fs_mkdir(test_dir, 493) -- 493 = 0755 in octal
		end)

		if not ok then
			vim.notify('Failed to create test directory: ' .. (err or ''), vim.log.levels.ERROR)
			return nil
		end
	end

	return test_dir .. '/'
end

return M
