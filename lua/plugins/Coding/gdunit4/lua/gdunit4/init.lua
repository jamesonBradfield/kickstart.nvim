--[[
GdUnit4 Neovim Integration
A Neovim plugin for integrating GdUnit4 testing framework with Neovim.

This module provides the main interface for:
- Creating C# test files
- Running tests (single, all, or with config)
- Generating and viewing test reports
- Managing test environment and configuration
--]]

-- Import required modules
local Parser = require 'gdunit4.parser'
local TestGenerator = require 'gdunit4.test_generator'
local env = require 'gdunit4.env'
local fs = require 'gdunit4.fs'
local command = require 'gdunit4.command'
local config = require 'gdunit4.config'
local report = require 'gdunit4.report'

local M = {}

---Setup GdUnit4 with optional configuration
---@param opts table|nil Configuration options table
---@field runner_script string Path to GdUnit4 runner script
---@field report_directory string Directory for test reports
---@field report_count number Maximum number of reports to keep
---@field test_config_file string Default test configuration file
function M.setup(opts)
  config.setup(opts)
end

---Ensure the report directory exists in the project
---@param project_root string Absolute path to project root
---@return string report_dir Path to the report directory
local function ensure_report_directory(project_root)
  local report_dir = project_root .. '/' .. config.get().report_directory
  vim.fn.mkdir(report_dir, 'p')
  return report_dir
end

---Execute a callback function within the project context
---Handles environment checks, directory changes, and cleanup
---@param callback function Function to execute with project_root parameter
---@return any Result from the callback function
local function run_in_project_context(callback)
  -- Get project root
  local project_root = fs.ensure_project_root()
  if not project_root then
    return
  end

  -- Check environment
  if not env.check_godot_bin() then
    return
  end

  -- Change to project directory
  if not fs.change_to_directory(project_root) then
    return
  end

  -- Check runner script
  if not env.check_runner_script(project_root, config.get().runner_script) then
    fs.restore_directory()
    return
  end

  -- Ensure report directory exists
  ensure_report_directory(project_root)

  -- Run the callback with project context
  local result = callback(project_root)

  -- Clean old reports if configured
  local cfg = config.get()
  if cfg.report_count and cfg.report_count > 0 then
    report.clean_old_reports(project_root, cfg.report_directory, cfg.report_count)
  end

  -- Restore directory
  fs.restore_directory()

  return result
end

---Run a single test file
---@return boolean success Whether the test run was successful
function M.run_test()
  return run_in_project_context(function(project_root)
    -- Get current file and ensure it exists
    local current_file = vim.fn.expand '%:p'
    if not current_file or current_file == '' then
      vim.notify('No file selected', vim.log.levels.ERROR)
      return false
    end

    local cfg = config.get()

    -- Ensure report directory exists and build args
    if report.ensure_report_directory(project_root, cfg.report_directory) then
      local report_args = report.build_report_args(cfg)
      vim.notify('Running test with report args: ' .. report_args, vim.log.levels.INFO)

      -- Always use -a flag with the current file path
      local cmd = command.build_test_command(project_root, cfg.runner_script, current_file, {
        report_args = report_args,
      })

      -- Log the command for debugging
      vim.notify('Executing test command: ' .. cmd, vim.log.levels.INFO)

      return command.execute_test_command(cmd)
    end
    return false
  end)
end

---Run all tests in the project's test directory
---@return boolean success Whether the test run was successful
function M.run_all_tests()
  return run_in_project_context(function(project_root)
    local test_path = project_root .. '/test'
    local cfg = config.get()

    -- Ensure report directory exists and build args
    if report.ensure_report_directory(project_root, cfg.report_directory) then
      local report_args = report.build_report_args(cfg)
      vim.notify('Running all tests with report args: ' .. report_args, vim.log.levels.INFO)

      local cmd = command.build_test_command(project_root, cfg.runner_script, test_path, {
        report_args = report_args,
      })
      return command.execute_test_command(cmd)
    end
    return false
  end)
end

---Open the latest test report in the default browser
---@return boolean success Whether opening the report was successful
function M.open_latest_report()
  local project_root = fs.ensure_project_root()
  if not project_root then
    return
  end

  return report.open_latest_report(project_root, config.get().report_directory)
end

---Run a test in debug mode
---@return boolean success Whether the debug run was successful
function M.debug_test()
  return run_in_project_context(function(project_root)
    local current_file = vim.fn.expand '%:p'
    local cmd = command.build_test_command(project_root, config.get().runner_script, current_file, {
      debug = true,
    })
    return command.execute_test_command(cmd)
  end)
end

---Run tests using a configuration file
---@param config_file string|nil Path to configuration file (optional)
---@return boolean success Whether the test run was successful
function M.run_with_config(config_file)
  return run_in_project_context(function(project_root)
    local cmd = command.build_test_command(project_root, config.get().runner_script, nil, {
      config = config_file or config.get().test_config_file,
    })
    return command.execute_test_command(cmd)
  end)
end

---Create a new test file for the current file
---@return nil
function M.create_test()
  local project_root = fs.ensure_project_root()
  if not project_root then
    return
  end

  local current_file = vim.fn.expand '%:p'
  local file_data = Parser.parse_file(current_file)

  if file_data then
    -- Generate test content
    local test_content = TestGenerator.generate_test_class(file_data)

    -- Remove extension and add _test.cs suffix
    local test_file_name = vim.fn.expand '%:t:r' .. '_test.cs'

    -- Create test directory
    local test_dir = fs.create_test_directory(project_root)
    local test_file_path = test_dir .. test_file_name

    vim.notify('Test File Path: ' .. test_file_path)

    -- Write the test content to file
    vim.fn.writefile(vim.split(test_content, '\n'), test_file_path)
    vim.notify('Test written to: ' .. test_file_name)
  else
    vim.notify('Failed to parse file', vim.log.levels.ERROR)
  end
end

return M
