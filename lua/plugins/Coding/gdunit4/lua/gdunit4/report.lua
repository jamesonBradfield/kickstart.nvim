-- report.lua
local M = {}
-- Function to clean old reports
function M.clean_old_reports(project_root, report_dir, max_reports)
  if not max_reports or max_reports <= 0 then
    return
  end

  local full_report_path = project_root .. '/' .. report_dir
  vim.notify('Cleaning old reports in: ' .. full_report_path, vim.log.levels.INFO)

  -- List all report directories (they should be named report_1, report_2, etc.)
  local handle = vim.loop.fs_scandir(full_report_path)
  if not handle then
    vim.notify('Failed to scan report directory', vim.log.levels.WARN)
    return
  end

  local reports = {}
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    -- Only consider directories that match our naming pattern
    if type == 'directory' and name:match '^report_%d+$' then
      table.insert(reports, name)
    end
  end

  -- Sort reports by number (latest first)
  table.sort(reports, function(a, b)
    local num_a = tonumber(a:match 'report_(%d+)')
    local num_b = tonumber(b:match 'report_(%d+)')
    return num_a > num_b
  end)

  -- Remove excess reports
  if #reports > max_reports then
    for i = max_reports + 1, #reports do
      local report_to_remove = full_report_path .. '/' .. reports[i]
      vim.notify('Removing old report: ' .. reports[i], vim.log.levels.INFO)

      -- Recursively remove the report directory
      local function remove_dir(path)
        local dir_handle = vim.loop.fs_scandir(path)
        if dir_handle then
          while true do
            local entry = vim.loop.fs_scandir_next(dir_handle)
            if not entry then
              break
            end

            local full_path = path .. '/' .. entry
            local stat = vim.loop.fs_stat(full_path)

            if stat.type == 'directory' then
              remove_dir(full_path)
            else
              vim.loop.fs_unlink(full_path)
            end
          end
        end
        vim.loop.fs_rmdir(path)
      end

      remove_dir(report_to_remove)
    end
  end
end

-- Build report arguments based on configuration
function M.build_report_args(config)
  vim.notify('Building report args with config: ' .. vim.inspect(config), vim.log.levels.INFO)

  local args = {}

  -- Add report directory argument
  if config.report_directory then
    -- Always use res:// prefix for Godot paths
    local report_path = config.report_directory:gsub('^/', '')
    table.insert(args, '-rd')
    table.insert(args, report_path)
    vim.notify('Added report directory arg: ' .. report_path, vim.log.levels.INFO)
  end

  -- Add report count argument
  if config.report_count then
    table.insert(args, '-rc')
    table.insert(args, tostring(config.report_count))
    vim.notify('Added report count arg: ' .. config.report_count, vim.log.levels.INFO)
  end

  local report_args = table.concat(args, ' ')
  vim.notify('Final report args: ' .. report_args, vim.log.levels.INFO)
  return report_args
end

-- Function to open the latest report
function M.open_latest_report(project_root, report_dir)
  -- Godot reports are relative to project root
  local report_path = project_root .. '/' .. report_dir .. '/index.htm'
  vim.notify('Looking for report at: ' .. report_path, vim.log.levels.INFO)

  -- Check if report exists
  local stat = vim.uv.fs_stat(report_path)
  if not stat then
    -- Try alternative extension
    report_path = project_root .. '/' .. report_dir .. '/index.html'
    stat = vim.uv.fs_stat(report_path)
    if not stat then
      vim.notify('No report found at: ' .. report_path, vim.log.levels.WARN)
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

  local ok, err = pcall(function()
    vim.fn.system(cmd)
  end)

  if ok then
    vim.notify('Opened test report: ' .. report_path, vim.log.levels.INFO)
    return true
  else
    vim.notify('Failed to open test report: ' .. (err or ''), vim.log.levels.ERROR)
    return false
  end
end

-- Helper function to create report directory
function M.ensure_report_directory(project_root, report_dir)
  local full_path = project_root .. '/' .. report_dir
  vim.notify('Ensuring report directory exists: ' .. full_path, vim.log.levels.INFO)

  local stat = vim.uv.fs_stat(full_path)
  if not stat then
    -- Try to create directory
    local ok, err = pcall(function()
      vim.fn.mkdir(full_path, 'p')
    end)

    if not ok then
      vim.notify('Failed to create report directory: ' .. (err or ''), vim.log.levels.ERROR)
      return false
    end
    vim.notify('Created report directory: ' .. full_path, vim.log.levels.INFO)
  end

  return true
end

return M
