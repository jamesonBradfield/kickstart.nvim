-- GdUnit4 Neovim Integration (Rewrite)
-- A streamlined Neovim plugin for the GdUnit4 testing framework

local M = {}
local config = {}

-- Import modules
local parser = require 'gdunit4.parser'
local generator = require 'gdunit4.generator'
local report = require 'gdunit4.report'

-- Default configuration
local DEFAULT_CONFIG = {
  runner_script = 'addons/gdUnit4/runtest.sh',
  test_config_file = 'GdUnitRunner.cfg',
  report_directory = 'reports',
  report_count = 20,
  report_format = 'html',
}

---Setup GdUnit4 with optional configuration
---@param opts table|nil Configuration options
function M.setup(opts)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend('force', DEFAULT_CONFIG, opts or {})

  -- Register commands
  vim.api.nvim_create_user_command('GdUnitCreateTest', function()
    M.create_test()
  end, {})
  vim.api.nvim_create_user_command('GdUnitRunTest', function()
    M.run_test()
  end, {})
  vim.api.nvim_create_user_command('GdUnitRunAllTests', function()
    M.run_all_tests()
  end, {})
  vim.api.nvim_create_user_command('GdUnitDebugTest', function()
    M.run_test { debug = true }
  end, {})
  vim.api.nvim_create_user_command('GdUnitRunWithConfig', function(args)
    M.run_with_config(args.args)
  end, {
    nargs = '?',
    complete = function()
      return vim.fn.glob('*.cfg', false, true)
    end,
  })

  -- Initialize display highlights
  M._init_highlights()
end

-- Core functionality
local function find_project_root()
  local project_file = vim.fn.findfile('project.godot', vim.fn.expand '%:p:h' .. ';')
  if project_file == '' then
    vim.notify('Could not find project.godot file', vim.log.levels.ERROR)
    return nil
  end
  return vim.fn.fnamemodify(project_file, ':p:h')
end

local function check_environment()
  -- Check GODOT_BIN environment
  local godot_bin = os.getenv 'GODOT_BIN'
  if not godot_bin or godot_bin == '' then
    vim.notify('GODOT_BIN environment variable not set', vim.log.levels.WARN)
    vim.ui.input({
      prompt = 'Path to godot executable: ',
      default = '/usr/bin/godot-mono',
    }, function(input)
      if input and input ~= '' then
        vim.fn.setenv('GODOT_BIN', input)
        godot_bin = input
      else
        vim.notify('No path provided. GdUnit4 will not function correctly.', vim.log.levels.ERROR)
        return false
      end
    end)
  end

  -- Verify the executable exists
  if not godot_bin or godot_bin == '' then
    return false
  end
  local stat = vim.uv.fs_stat(godot_bin)
  if not stat then
    vim.notify('Godot executable not found at: ' .. godot_bin, vim.log.levels.ERROR)
    return false
  end

  return true
end

local function check_runner_script(project_root)
  if vim.fn.has 'unix' ~= 1 then
    return true
  end

  local runner_script = config.runner_script:gsub('^/', '')
  local script_path = project_root .. '/' .. runner_script

  -- Check if file exists
  local stat = vim.uv.fs_stat(script_path)
  if not stat then
    vim.notify('Runner script not found at: ' .. script_path, vim.log.levels.ERROR)
    return false
  end

  -- Check if script is executable
  local executable_bit = 64 -- equivalent to 0x40
  if bit.band(stat.mode, executable_bit) == 0 then
    vim.notify('Setting executable permissions on runner script', vim.log.levels.INFO)
    local ok, err = pcall(vim.uv.fs_chmod, script_path, 493) -- 0755
    if not ok then
      vim.notify('Failed to set permissions: ' .. (err or ''), vim.log.levels.ERROR)
      return false
    end
  end

  return true
end

-- Directory handling with automatic restoration
local function with_project_dir(callback)
  local project_root = find_project_root()
  if not project_root then
    return nil
  end

  if not check_environment() then
    return nil
  end

  local original_dir = vim.uv.cwd()
  local success, result

  -- Change to project directory
  local ok, err = pcall(vim.uv.chdir, project_root)
  if not ok then
    vim.notify('Failed to change directory: ' .. (err or ''), vim.log.levels.ERROR)
    return nil
  end

  -- Check runner script
  if not check_runner_script(project_root) then
    vim.uv.chdir(original_dir)
    return nil
  end

  -- Ensure report directory exists
  local report_dir = project_root .. '/' .. config.report_directory
  vim.fn.mkdir(report_dir, 'p')

  -- Run callback in project context
  success, result = pcall(callback, project_root)

  -- Clean old reports if needed
  if config.report_count and config.report_count > 0 then
    M._clean_old_reports(project_root)
  end

  -- Restore original directory
  pcall(vim.uv.chdir, original_dir)

  if not success then
    vim.notify('Error: ' .. tostring(result), vim.log.levels.ERROR)
    return nil
  end

  return result
end

-- Command building and execution
local function get_relative_path(full_path)
  -- Ensure consistent forward slashes
  full_path = full_path:gsub('\\', '/')
  -- Get relative path by removing current directory
  return full_path:gsub('^' .. vim.fn.getcwd() .. '/?', '')
end

local function build_command(test_path, options)
  options = options or {}
  local runner_script = config.runner_script:gsub('^/', '')
  local cmd_parts = { runner_script }

  -- Add test path or config
  if test_path then
    table.insert(cmd_parts, '-a')
    table.insert(cmd_parts, get_relative_path(test_path))
  elseif options.config then
    table.insert(cmd_parts, '-conf')
    table.insert(cmd_parts, options.config)
  end

  -- Add report arguments
  if config.report_directory then
    table.insert(cmd_parts, '-rd')
    table.insert(cmd_parts, config.report_directory:gsub('^/', ''))
  end

  if config.report_count then
    table.insert(cmd_parts, '-rc')
    table.insert(cmd_parts, tostring(config.report_count))
  end

  -- Add debug if needed
  if options.debug then
    table.insert(cmd_parts, '--debug')
  end

  return table.concat(cmd_parts, ' ')
end

local function execute_command(cmd)
  vim.notify('Executing: ' .. cmd, vim.log.levels.INFO)
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  -- Display formatted results
  M._display_test_results()

  -- Check for specific test results
  if output:match 'Run tests ends with 0' then
    return 0
  elseif output:match 'Run tests ends with 1' then
    return 1
  end

  return exit_code
end

-- Public API
---Run a single test file
---@param opts table|nil Options including debug mode
function M.run_test(opts)
  return with_project_dir(function()
    local current_file = vim.fn.expand '%:p'
    if not current_file or current_file == '' then
      vim.notify('No file selected', vim.log.levels.ERROR)
      return false
    end

    local cmd = build_command(current_file, opts)
    return execute_command(cmd) == 0
  end)
end

---Run all tests in the project
function M.run_all_tests()
  return with_project_dir(function(project_root)
    local test_path = project_root .. '/test'
    local cmd = build_command(test_path)
    return execute_command(cmd) == 0
  end)
end

---Run tests using a configuration file
---@param config_file string|nil Path to config file
function M.run_with_config(config_file)
  return with_project_dir(function()
    local cmd = build_command(nil, {
      config = config_file or config.test_config_file,
    })
    return execute_command(cmd) == 0
  end)
end

---Create a test file for the current file
function M.create_test()
  local project_root = find_project_root()
  if not project_root then
    return
  end

  local current_file = vim.fn.expand '%:p'
  local file_data = M._parse_file(current_file)

  if file_data then
    -- Generate test content
    local test_content = M._generate_test(file_data)

    -- Create test file path
    local test_file_name = vim.fn.expand '%:t:r' .. '_test.cs'
    local test_dir = project_root .. '/test'
    vim.fn.mkdir(test_dir, 'p')
    local test_file_path = test_dir .. '/' .. test_file_name

    -- Write the test content to file
    vim.fn.writefile(vim.split(test_content, '\n'), test_file_path)
    vim.notify('Test written to: ' .. test_file_name)

    -- Open the file
    vim.cmd('edit ' .. test_file_path)
  end
end

---Open the latest test report in the default browser
function M.open_latest_report()
  local project_root = find_project_root()
  if not project_root then
    return false
  end

  local report_path = project_root .. '/' .. config.report_directory .. '/index.html'
  local alt_path = project_root .. '/' .. config.report_directory .. '/index.htm'

  -- Check if report exists
  local stat = vim.uv.fs_stat(report_path)
  if not stat then
    stat = vim.uv.fs_stat(alt_path)
    if stat then
      report_path = alt_path
    else
      vim.notify('No report found', vim.log.levels.WARN)
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

-- Internal functions for test parsing and generation
-- These would be implemented similarly to the original but with simplified logic
-- For brevity, I've marked them as placeholders

function M._parse_file(file_path)
  return parser.parse_file(file_path)
end

function M._generate_test(file_data)
  return generator.generate_test_class(file_data)
end

function M._display_test_results()
  local project_root = vim.uv.cwd() -- We're already in the project root when this is called
  report.display_results(project_root, config.report_directory)
end

function M._clean_old_reports(project_root)
  report.clean_old_reports(project_root, config.report_directory, config.report_count)
end

function M._init_highlights()
  -- Setup highlight groups for test results
  local highlights = {
    TestPassed = { fg = '#00ff00', bold = true },
    TestFailed = { fg = '#ff0000', bold = true },
    Header = { fg = '#7aa2f7', bold = true },
    File = { fg = '#bb9af7', bold = true },
    FuncName = { fg = '#e0af68' },
    Time = { fg = '#565f89', italic = true },
    Summary = { fg = '#9ece6a' },
  }

  for name, settings in pairs(highlights) do
    vim.api.nvim_set_hl(0, 'GdUnit4' .. name, settings)
  end
end

return M
