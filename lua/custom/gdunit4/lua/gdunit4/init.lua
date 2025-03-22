-- GdUnit4 plugin for Neovim
-- A streamlined version with improved project root detection

local M = {}
local cmd_utils = require 'gdunit4.cmd_utils'
local parser = require 'gdunit4.parser'
local generator = require 'gdunit4.generator'

-- Default configuration
local DEFAULT_CONFIG = {
	godot_bin = os.getenv 'GODOT_BIN' or 'godot-mono',
	runner_script = vim.fn.has 'win32' == 1 and 'addons/gdUnit4/runtest.cmd' or 'addons/gdUnit4/runtest.sh',
	report_directory = 'reports',
	report_count = 20,
	continue_on_failure = false,
	test_config_file = 'GdUnitRunner.cfg',
	ignored_tests = {},
	path_separator = vim.fn.has 'win32' == 1 and '\\' or '/',
	use_absolute_paths = true,
	debug_mode = false,
}

-- Current configuration
local config = vim.deepcopy(DEFAULT_CONFIG)

---Setup GdUnit4 with optional configuration
---@param opts table|nil Configuration options
function M.setup(opts)
	-- Merge user config with defaults
	if opts then
		for k, v in pairs(opts) do
			config[k] = v
		end
	end

	-- Set up cmd_utils
	cmd_utils.setup {
		notify_commands = true,
		notify_level = config.debug_mode and vim.log.levels.DEBUG or vim.log.levels.INFO,
	}

	-- Register commands
	vim.api.nvim_create_user_command('GdUnitRunTest', function()
		M.run_test()
	end, {})

	vim.api.nvim_create_user_command('GdUnitRunAllTests', function()
		M.run_all_tests()
	end, {})

	vim.api.nvim_create_user_command('GdUnitRunWithConfig', function(args)
		M.run_with_config(args.args)
	end, {
		nargs = '?',
		complete = function()
			return vim.fn.glob('*.cfg', false, true)
		end,
	})

	vim.api.nvim_create_user_command('GdUnitCreateTest', function()
		M.create_test()
	end, {})

	vim.api.nvim_create_user_command('GdUnitOpenReport', function()
		M.open_latest_report()
	end, {})

	-- Initialize highlights
	M._init_highlights()
end

---Improved function to find the Godot project root
---First checks current file's directory, then the current working directory
---@param start_dir string|nil Optional directory to start searching from
---@return string|nil Path to project root or nil if not found
function M.find_project_root(start_dir)
	-- Try current file's directory first
	if not start_dir or start_dir == '' then
		local current_file = vim.fn.expand '%:p:h'
		if current_file and current_file ~= '' then
			start_dir = current_file
		else
			-- Fall back to current working directory
			start_dir = vim.fn.getcwd()
		end
	end

	-- Navigate up through directories looking for project.godot
	local current_dir = start_dir
	local last_dir = nil

	while current_dir and current_dir ~= '' and current_dir ~= last_dir do
		local project_file = current_dir .. config.path_separator .. 'project.godot'
		if vim.fn.filereadable(project_file) == 1 then
			if config.debug_mode then
				cmd_utils.log('Found project root: ' .. current_dir, vim.log.levels.DEBUG)
			end
			return current_dir
		end

		-- Save current directory before going up
		last_dir = current_dir
		-- Move up one directory
		current_dir = vim.fn.fnamemodify(current_dir, ':h')
	end

	-- Not found in file hierarchy, check current working directory
	local cwd = vim.fn.getcwd()
	local cwd_project_file = cwd .. config.path_separator .. 'project.godot'

	if vim.fn.filereadable(cwd_project_file) == 1 then
		if config.debug_mode then
			cmd_utils.log('Found project root in cwd: ' .. cwd, vim.log.levels.DEBUG)
		end
		return cwd
	end

	-- Not found
	cmd_utils.log('Could not find project.godot file', vim.log.levels.ERROR)
	return nil
end

-- Safe function access using pcall to avoid undefined field warnings
local function safe_get_fn(obj, fn_name)
	local success, result = pcall(function()
		return obj[fn_name]
	end)
	if success and type(result) == 'function' then
		return result
	end
	return nil
end

---Execute a function in the context of the project directory
---@param callback function Function to execute
---@return any Result of callback or nil on error
function M.with_project_dir(callback)
	local project_root = M.find_project_root()
	if not project_root then
		return nil
	end

	-- Check for godot binary
	local godot_bin = config.godot_bin
	if godot_bin == '' then
		cmd_utils.log('Godot binary not set', vim.log.levels.ERROR)
		return nil
	end

	-- Verify the godot binary exists
	if vim.fn.executable(godot_bin) ~= 1 then
		cmd_utils.log('Godot executable not found: ' .. godot_bin, vim.log.levels.ERROR)
		return nil
	end

	-- Store current directory
	local original_dir = vim.fn.getcwd()
	local success, result = nil, nil

	-- Change to project directory
	local ok = pcall(vim.fn.chdir, project_root)
	if not ok then
		cmd_utils.log('Failed to change directory to: ' .. project_root, vim.log.levels.ERROR)
		return nil
	end

	-- Check runner script
	local runner_script = project_root .. config.path_separator .. config.runner_script
	if vim.fn.has 'unix' == 1 then
		-- Use vim.loop or vim.uv based on Neovim version
		local fs = vim.uv or vim.loop

		if not fs then
			cmd_utils.log('Filesystem API not available', vim.log.levels.ERROR)
			vim.fn.chdir(original_dir)
			return nil
		end

		-- Check if the required functions exist using pcall to avoid undefined field warnings
		local stat_fn = safe_get_fn(fs, 'fs_stat') or safe_get_fn(fs, 'stat')

		if not stat_fn then
			cmd_utils.log('Filesystem stat API not available', vim.log.levels.ERROR)
			vim.fn.chdir(original_dir)
			return nil
		end

		local script_stat = stat_fn(runner_script)

		if not script_stat then
			cmd_utils.log('Runner script not found at: ' .. runner_script, vim.log.levels.ERROR)
			vim.fn.chdir(original_dir)
			return nil
		end

		-- Check if script is executable
		local executable_bit = 64 -- equivalent to 0x40
		if bit.band(script_stat.mode, executable_bit) == 0 then
			cmd_utils.log('Setting executable permissions on runner script', vim.log.levels.INFO)

			-- Use the appropriate chmod function based on what's available
			local chmod_fn = safe_get_fn(fs, 'fs_chmod') or safe_get_fn(fs, 'chmod')

			if not chmod_fn then
				cmd_utils.log('Filesystem chmod API not available', vim.log.levels.ERROR)
				vim.fn.chdir(original_dir)
				return nil
			end

			local chmod_ok = pcall(chmod_fn, runner_script, 493) -- 0755
			if not chmod_ok then
				cmd_utils.log('Failed to set permissions on runner script', vim.log.levels.ERROR)
				vim.fn.chdir(original_dir)
				return nil
			end
		end
	end

	-- Create reports directory if it doesn't exist
	local report_dir = project_root .. config.path_separator .. config.report_directory
	vim.fn.mkdir(report_dir, 'p')

	-- Execute callback in project context
	success, result = pcall(callback, project_root)

	-- Clean old reports if needed
	if success and config.report_count and config.report_count > 0 then
		M._clean_old_reports(project_root)
	end

	-- Restore original directory
	vim.fn.chdir(original_dir)

	if not success then
		cmd_utils.log('Error in callback: ' .. tostring(result), vim.log.levels.ERROR)
		return nil
	end

	return result
end

---Get path relative to project root
---@param full_path string Absolute path
---@param add_leading_slash boolean|nil Whether to add leading slash
---@return string Relative path
function M.get_relative_path(full_path, add_leading_slash)
	-- Ensure consistent forward slashes
	full_path = full_path:gsub('\\', '/')

	-- Get project root
	local project_root = M.find_project_root()
	if not project_root then
		return full_path
	end

	-- Replace backslashes with forward slashes for consistency
	project_root = project_root:gsub('\\', '/')

	-- For GdUnit4, we need to consider two path formats:
	-- 1. Absolute path format: /project_name/path/to/file
	-- 2. Relative path format: path/to/file (relative to project root)

	-- Check if the path is already within the project root
	if full_path:find(project_root, 1, true) == 1 then
		-- Path is within project root, so make it relative to project root
		local rel_path = full_path:sub(#project_root + 2) -- +2 to remove the trailing slash

		if add_leading_slash then
			-- For GdUnit4, this should be: /project_name/rel_path
			local project_name = vim.fn.fnamemodify(project_root, ':t')
			return '/' .. project_name .. '/' .. rel_path
		else
			-- Just return the relative path
			return rel_path
		end
	else
		-- Path is not within project root
		cmd_utils.log('Warning: Path not within project root: ' .. full_path, vim.log.levels.WARN)

		-- If add_leading_slash is true, we should still try to format as GdUnit4 expects
		if add_leading_slash then
			local project_name = vim.fn.fnamemodify(project_root, ':t')
			return '/' .. project_name .. '/' .. vim.fn.fnamemodify(full_path, ':t')
		else
			return full_path
		end
	end
end

---Get path relative to project root with proper formatting for GdUnit4
---@param test_path string Path to test file or directory
---@param use_absolute_paths boolean Whether to use absolute paths with project name
---@return string Formatted path for GdUnit4
function M.format_test_path(test_path, use_absolute_paths)
	-- Ensure consistent forward slashes
	test_path = test_path:gsub('\\', '/')

	-- Get project root
	local project_root = M.find_project_root()
	if not project_root then
		return test_path
	end

	-- Format the project root with consistent slashes
	project_root = project_root:gsub('\\', '/')

	-- Extract project name
	local project_name = vim.fn.fnamemodify(project_root, ':t')

	-- Make the path relative to project root (remove project root prefix)
	local rel_path = test_path
	if test_path:find(project_root, 1, true) == 1 then
		rel_path = test_path:sub(#project_root + 2) -- +2 to remove the trailing slash
	end

	-- Remove any leading slashes from rel_path
	rel_path = rel_path:gsub('^/', '')

	-- Format according to desired style
	if use_absolute_paths then
		-- For versions of GdUnit4 that expect the format: /project_name/path
		-- return '/' .. project_name .. '/' .. rel_path

		-- BUT, it seems this is causing issues, so let's try just the relative path instead
		return rel_path
	else
		-- Just the path relative to project root without leading slash
		return rel_path
	end
end

--- Replace the build_command function with this simplified version
function M.build_command(test_path, options)
	options = options or {}
	local runner_script = config.runner_script:gsub('^/', '')

	-- Build command
	local cmd = runner_script

	-- Add test path or config
	if test_path then
		-- SIMPLE PATH HANDLING - just extract the 'test' directory name
		local simple_path = 'test'

		-- If it's a specific test file, extract that as well
		if test_path:match 'test/.+' then
			simple_path = test_path:match 'test/(.+)'
			if simple_path then
				simple_path = 'test/' .. simple_path
			else
				simple_path = 'test'
			end
		end

		-- Log all path information for debugging
		if config.debug_mode then
			cmd_utils.log('Original test path: ' .. test_path, vim.log.levels.DEBUG)
			cmd_utils.log('Simplified path: ' .. simple_path, vim.log.levels.DEBUG)
		end

		cmd_utils.log('Running tests on: ' .. simple_path, vim.log.levels.INFO)
		cmd = cmd .. ' -a ' .. cmd_utils.escape_path(simple_path)
	elseif options.config then
		cmd = cmd .. ' -conf ' .. cmd_utils.escape_path(options.config)
	end

	-- Add report arguments
	if config.report_directory then
		cmd = cmd .. ' -rd ' .. cmd_utils.escape_path(config.report_directory:gsub('^/', ''))
	end

	if config.report_count then
		cmd = cmd .. ' -rc ' .. tostring(config.report_count)
	end

	-- Add debug if needed
	if options.debug then
		cmd = cmd .. ' --debug'
	end

	-- Log the complete command for debugging
	if config.debug_mode then
		cmd_utils.log('Final command: ' .. cmd, vim.log.levels.DEBUG)
	end

	return cmd
end

---Execute a test command
---@param cmd string Command to execute
---@return number Exit code
function M.execute_command(cmd)
	cmd_utils.log('Executing: ' .. cmd, vim.log.levels.INFO)

	-- Add more debugging output
	if config.debug_mode then
		cmd_utils.log('Current directory: ' .. vim.fn.getcwd(), vim.log.levels.DEBUG)
		cmd_utils.log('Command details: ' .. vim.inspect(cmd), vim.log.levels.DEBUG)
	end

	-- Execute the command with better error handling
	local success, output = pcall(vim.fn.system, cmd)
	local exit_code = vim.v.shell_error

	if not success then
		cmd_utils.log('Error executing command: ' .. tostring(output), vim.log.levels.ERROR)
		return 1 -- Return error code
	end

	if exit_code ~= 0 then
		cmd_utils.log('Command exited with error code: ' .. exit_code, vim.log.levels.WARN)
		cmd_utils.log('Command output: ' .. output, vim.log.levels.WARN)
	end

	-- Display results using the simplified approach
	M._display_test_results()

	return exit_code
end

---Run a single test file
---@param opts table|nil Options for test run
---@return boolean Success status
function M.run_test(opts)
	return M.with_project_dir(function()
		local current_file = vim.fn.expand '%:p'
		if not current_file or current_file == '' then
			cmd_utils.log('No file selected', vim.log.levels.ERROR)
			return false
		end

		local cmd = M.build_command(current_file, opts)
		return M.execute_command(cmd) == 0
	end) or false
end

---Run all tests in the project
---@return boolean Success status
function M.run_all_tests()
	return M.with_project_dir(function(project_root)
		local test_path = project_root .. '/test'

		-- For running all tests, use a configuration option
		local use_leading_slash = config.use_absolute_paths
		local cmd = M.build_command(test_path, { use_absolute_paths = use_leading_slash })

		cmd_utils.log('Executing all tests command: ' .. cmd, vim.log.levels.INFO)
		return M.execute_command(cmd) == 0
	end) or false
end

---Run tests using a configuration file
---@param config_file string|nil Path to config file
---@return boolean Success status
function M.run_with_config(config_file)
	return M.with_project_dir(function()
		local cmd = M.build_command(nil, {
			config = config_file or config.test_config_file,
		})
		return M.execute_command(cmd) == 0
	end) or false
end

---Open the latest test report in the default browser
---@return boolean Success status
function M.open_latest_report()
	local project_root = M.find_project_root()
	if not project_root then
		return false
	end

	local report_path = project_root .. '/' .. config.report_directory .. '/index.html'
	local alt_path = project_root .. '/' .. config.report_directory .. '/index.htm'

	-- Check if report exists
	local report_exists = vim.fn.filereadable(report_path) == 1
	if not report_exists then
		report_exists = vim.fn.filereadable(alt_path) == 1
		if report_exists then
			report_path = alt_path
		else
			cmd_utils.log('No report found', vim.log.levels.WARN)
			return false
		end
	end

	-- Open report in default browser
	local cmd
	if vim.fn.has 'win32' == 1 then
		cmd = string.format('start "" "%s"', report_path)
	elseif vim.fn.has 'macunix' == 1 then
		cmd = string.format('open "%s"', report_path)
	else
		cmd = string.format('xdg-open "%s"', report_path)
	end

	pcall(vim.fn.system, cmd)
	return true
end

-- Internal functions
function M._clean_old_reports(project_root)
	local full_report_path = project_root .. '/' .. config.report_directory
	local max_reports = config.report_count

	if not max_reports or max_reports <= 0 then
		return
	end

	-- Use vim.loop or vim.uv based on Neovim version
	local fs = vim.uv or vim.loop

	if not fs then
		cmd_utils.log('Filesystem API not available', vim.log.levels.ERROR)
		return
	end

	-- Check if the required functions exist using pcall to avoid undefined field warnings
	local scan_dir_fn = safe_get_fn(fs, 'fs_scandir') or safe_get_fn(fs, 'scandir')
	local scan_next_fn = safe_get_fn(fs, 'fs_scandir_next') or safe_get_fn(fs, 'scandir_next')

	if not scan_dir_fn or not scan_next_fn then
		cmd_utils.log('Directory scanning API not available', vim.log.levels.ERROR)
		return
	end

	local reports = {}
	local handle = scan_dir_fn(full_report_path)
	if not handle then
		return
	end

	while true do
		local name, type = scan_next_fn(handle)
		if not name then
			break
		end

		if type == 'directory' and name:match '^report_%d+$' then
			local num = tonumber(name:match 'report_(%d+)')
			if num then
				table.insert(reports, { name = name, num = num })
			end
		end
	end

	-- Sort reports by number (latest first)
	table.sort(reports, function(a, b)
		return a.num > b.num
	end)

	-- Remove excess reports
	if #reports > max_reports then
		for i = max_reports + 1, #reports do
			local path = full_report_path .. '/' .. reports[i].name
			vim.fn.delete(path, 'rf')
		end
	end
end

-- Simple report display (simplified version)
function M._display_test_results()
	local project_root = M.find_project_root()
	if not project_root then
		return
	end

	local report_path = project_root .. '/' .. config.report_directory .. '/results.xml'

	-- Check if report exists
	if vim.fn.filereadable(report_path) ~= 1 then
		-- Try to find in report_X directories
		local latest_report = nil

		-- Use vim.loop or vim.uv based on Neovim version
		local fs = vim.uv or vim.loop

		if not fs then
			cmd_utils.log('Filesystem API not available', vim.log.levels.ERROR)
			return
		end

		-- Check if the required functions exist using pcall to avoid undefined field warnings
		local scan_dir_fn = safe_get_fn(fs, 'fs_scandir') or safe_get_fn(fs, 'scandir')
		local scan_next_fn = safe_get_fn(fs, 'fs_scandir_next') or safe_get_fn(fs, 'scandir_next')

		if not scan_dir_fn or not scan_next_fn then
			cmd_utils.log('Directory scanning API not available', vim.log.levels.ERROR)
			return
		end

		local handle = scan_dir_fn(project_root .. '/' .. config.report_directory)

		if handle then
			local latest_num = 0
			while true do
				local name, type = scan_next_fn(handle)
				if not name then
					break
				end

				if type == 'directory' and name:match '^report_%d+$' then
					local num = tonumber(name:match 'report_(%d+)')
					if num and num > latest_num then
						latest_num = num
						latest_report = project_root .. '/' .. config.report_directory .. '/' .. name .. '/results.xml'
					end
				end
			end
		end

		if latest_report and vim.fn.filereadable(latest_report) == 1 then
			report_path = latest_report
		else
			cmd_utils.log('No test report found', vim.log.levels.WARN)
			return
		end
	end

	-- Read XML content (simple parsing)
	local content = table.concat(vim.fn.readfile(report_path), '\n')

	-- Simple summary extraction
	local total_tests = content:match 'tests="(%d+)"' or '0'
	local failures = content:match 'failures="(%d+)"' or '0'
	local errors = content:match 'errors="(%d+)"' or '0'
	local skipped = content:match 'skipped="(%d+)"' or '0'
	local time = content:match 'time="([%d%.]+)"' or '0'

	-- Calculate passed tests
	local passed = tonumber(total_tests) - tonumber(failures) - tonumber(errors) - tonumber(skipped)

	-- Display summary
	local summary = string.format('Test Results: %s passed, %s failed, %s errors, %s skipped (in %s seconds)', passed,
		failures, errors, skipped, time)

	local level
	if tonumber(failures) > 0 or tonumber(errors) > 0 then
		level = vim.log.levels.ERROR
	else
		level = vim.log.levels.INFO
	end

	cmd_utils.log(summary, level)

	-- Offer to open full report
	if vim.fn.confirm('Open full test report?', '&Yes\n&No', 2) == 1 then
		M.open_latest_report()
	end
end

---Create a test file for the current file
---@return boolean Success status
function M.create_test()
	-- Get current file
	local current_file_path = vim.fn.expand '%:p'
	if not current_file_path or current_file_path == '' then
		cmd_utils.log('No file selected', vim.log.levels.ERROR)
		return false
	end

	-- Check if it's a C# file
	if not current_file_path:match '%.cs$' then
		cmd_utils.log('Current file is not a C# file', vim.log.levels.ERROR)
		return false
	end

	-- Find project root
	local project_root = M.find_project_root()
	if not project_root then
		cmd_utils.log('Could not find project root', vim.log.levels.ERROR)
		return false
	end

	-- Parse the file
	local file_data = parser.parse_file(current_file_path)
	if not file_data then
		cmd_utils.log('Failed to parse C# file', vim.log.levels.ERROR)
		return false
	end

	-- Generate test content
	local test_content = generator.generate_test_class(file_data)

	-- Create test file path
	local test_file_name = vim.fn.fnamemodify(current_file_path, ':t:r') .. '_test.cs'
	local test_dir = project_root .. '/test'

	-- Create test directory if it doesn't exist
	vim.fn.mkdir(test_dir, 'p')
	local test_file_path = test_dir .. '/' .. test_file_name

	-- Write the test content to file
	local success = vim.fn.writefile(vim.split(test_content, '\n'), test_file_path) == 0

	if success then
		cmd_utils.log('Test written to: ' .. test_file_path, vim.log.levels.INFO)

		-- Ask if the user wants to open the test file
		if vim.fn.confirm('Open the test file?', '&Yes\n&No', 1) == 1 then
			vim.cmd('edit ' .. vim.fn.fnameescape(test_file_path))
		end

		return true
	else
		cmd_utils.log('Failed to write test file', vim.log.levels.ERROR)
		return false
	end
end

function M._init_highlights()
	-- Setup highlight groups for test results
	local highlights = {
		TestPassed = { fg = '#00ff00', bold = true },
		TestFailed = { fg = '#ff0000', bold = true },
		Header = { fg = '#7aa2f7', bold = true },
		Summary = { fg = '#9ece6a' },
	}

	for name, settings in pairs(highlights) do
		vim.api.nvim_set_hl(0, 'GdUnit4' .. name, settings)
	end
end

return M
