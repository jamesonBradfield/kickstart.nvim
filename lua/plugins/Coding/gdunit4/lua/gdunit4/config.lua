-- config.lua
local M = {}

M.default_config = {
  runner_script = 'addons/gdUnit4/runtest.sh',
  test_config_file = 'GdUnitRunner.cfg',
  -- Report configuration
  report_directory = 'reports',  -- Will be relative to project root
  report_count = 20,            -- Default number of reports to keep
  report_format = 'html',       -- Default report format
}

function M.setup(opts)
  if opts then
    M.config = vim.tbl_deep_extend('force', M.default_config, opts)
  else
    M.config = M.default_config
  end
end

function M.get()
  return M.config or M.default_config
end

return M
