-- command.lua
local M = {}

-- Handle test execution results
function M.handle_test_result(output, exit_code)
  -- Print full output for debugging

  -- Display formatted results
  require('gdunit4.test_display').display_test_results(vim.uv.cwd())

  -- Check if the output contains success indicators
  if output:match("Run tests ends with 0") then
    return 0
  elseif output:match("Run tests ends with 1") then
    return 1
  end

  -- If no specific test result found, check exit code
  if exit_code == 0 then
    vim.notify('Command completed successfully', vim.log.levels.INFO)
  else
    vim.notify('Command failed with exit code: ' .. exit_code, vim.log.levels.ERROR)
  end
  return exit_code
end

function M.execute_test_command(cmd)
  vim.notify('Executing command: ' .. cmd)
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error
  return M.handle_test_result(output, exit_code)
end

---Get the relative path from project root
---@param full_path string The full filesystem path
---@return string The relative path from project root
local function get_relative_path(full_path)
  -- Ensure consistent forward slashes
  full_path = full_path:gsub('\\', '/')
  -- Get relative path by removing current directory (project root)
  return full_path:gsub('^' .. vim.fn.getcwd() .. '/?', '')
end

-- Fixed version:
-- In command.lua
function M.build_test_command(_, runner_script, test_path, options)
  options = options or {}
  -- Remove leading slash if present
  runner_script = runner_script:gsub('^/', '')

  -- Start building command
  local cmd_parts = { runner_script } -- Remove the 'sh -c' wrapper

  -- Add test path or config
  if test_path then
    table.insert(cmd_parts, '-a')
    -- Get path relative to project root
    local relative_path = get_relative_path(test_path)
    table.insert(cmd_parts, relative_path)
  elseif options.config then
    table.insert(cmd_parts, '-conf')
    table.insert(cmd_parts, options.config)
  end

  -- Add report arguments if provided
  if options.report_args and options.report_args ~= '' then
    for arg in options.report_args:gmatch '%S+' do
      table.insert(cmd_parts, arg)
    end
  end

  -- Add debug if needed
  if options.debug then
    table.insert(cmd_parts, '--debug')
  end

  -- Join command parts
  local final_cmd = table.concat(cmd_parts, ' ')
  return final_cmd
end

return M
