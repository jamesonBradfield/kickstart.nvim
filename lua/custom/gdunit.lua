return {
  'gdunit4',
  dir = vim.fn.stdpath 'config' .. '/lua/custom/gdunit4',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  lazy = false,
  config = function()
    local gdunit4 = require 'gdunit4'

    -- Setup with enhanced configuration
    gdunit4.setup {
      -- Use godot-mono as the default binary, fallback to environment variable
      godot_bin = os.getenv 'GODOT_BIN' or 'godot-mono',
      -- Project root will be automatically detected for each test run
      project_root = '',
      -- Use appropriate runner script based on platform
      runner_script = vim.fn.has 'win32' == 1 and 'addons/gdUnit4/runtest.cmd' or 'addons/gdUnit4/runtest.sh',
      -- Report configuration
      report_directory = 'reports',
      report_count = 20,
      -- Test execution configuration
      continue_on_failure = false,
      test_config_file = 'GdUnitRunner.cfg',
      ignored_tests = {},
    }
  end,
}
