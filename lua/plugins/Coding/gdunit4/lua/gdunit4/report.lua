-- report.lua - Test report handling for GdUnit4
-- Handles parsing XML reports and displaying results

local M = {}

-- Find the most recent report folder
local function find_latest_report(project_root, report_dir)
  local reports_path = project_root .. '/' .. report_dir
  local report_folders = {}
  
  -- Read the reports directory
  local handle = vim.uv.fs_scandir(reports_path)
  if not handle then
    vim.notify('Failed to read reports directory', vim.log.levels.ERROR)
    return nil
  end
  
  -- Collect report folders
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    
    if type == 'directory' and name:match('^report_%d+$') then
      local num = tonumber(name:match('report_(%d+)'))
      if num then
        table.insert(report_folders, { folder = name, num = num })
      end
    end
  end
  
  -- Sort and return the latest
  if #report_folders > 0 then
    table.sort(report_folders, function(a, b) return a.num > b.num end)
    return reports_path .. '/' .. report_folders[1].folder .. '/results.xml'
  end
  
  -- Fallback to direct results.xml
  local fallback = reports_path .. '/results.xml'
  if vim.uv.fs_stat(fallback) then
    return fallback
  end
  
  return nil
end

-- Parse XML attributes from node
local function get_node_attr(node, attr_name, buf)
  -- Helper function to extract attribute value from XML node
  -- Simplified version that uses pattern matching instead of complex traversal
  
  local node_text = vim.treesitter.get_node_text(node, buf)
  local pattern = attr_name .. '="([^"]*)"'
  return node_text:match(pattern)
end

-- Parse test results from XML report
function M.parse_report(project_root, report_dir)
  local report_path = find_latest_report(project_root, report_dir)
  if not report_path then
    vim.notify('No test report found', vim.log.levels.WARN)
    return nil
  end
  
  -- Read XML content
  local file = io.open(report_path, 'r')
  if not file then return nil end
  
  local xml_content = file:read('*all')
  file:close()
  
  -- Create buffer with XML content for TreeSitter
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(xml_content, '\n'))
  
  -- Check for XML parser
  if not vim.treesitter.language.require_language('xml', nil, true) then
    vim.notify('XML parser not available', vim.log.levels.ERROR)
    vim.api.nvim_buf_delete(buf, { force = true })
    return nil
  end
  
  -- Parse XML with TreeSitter
  local language_tree = vim.treesitter.get_parser(buf, 'xml')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()
  
  -- Query for test elements
  local query = vim.treesitter.query.parse('xml', [[
    (element) @element
  ]])
  
  -- Process results
  local test_results = {}
  for id, node in query:iter_captures(root, buf) do
    local node_text = vim.treesitter.get_node_text(node, buf)
    
    -- Check if this is a testsuite element
    if node_text:match('<testsuite') then
      local suite_name = get_node_attr(node, 'name', buf)
      local suite_time = get_node_attr(node, 'time', buf)
      
      if suite_name then
        local suite = {
          name = suite_name,
          tests = {},
          time = tonumber(suite_time) or 0
        }
        test_results[suite_name] = suite
        
        -- Extract testcase nodes (simplified approach)
        for testcase in node_text:gmatch('<testcase[^>]+>.-</testcase>') do
          local tc_name = testcase:match('name="([^"]*)"')
          local tc_time = testcase:match('time="([^"]*)"')
          local has_failure = testcase:match('<failure') or testcase:match('<error')
          
          if tc_name then
            table.insert(suite.tests, {
              name = tc_name,
              status = has_failure and 'FAILED' or 'PASSED',
              time = tonumber(tc_time) or 0
            })
          end
        end
      end
    end
  end
  
  vim.api.nvim_buf_delete(buf, { force = true })
  return test_results
end

-- Format test results for display
function M.format_results(test_results)
  local lines = {}
  local highlights = {}
  local line_idx = 0
  local total_passed = 0
  local total_failed = 0
  local total_time = 0
  
  -- Add line with highlight
  local function add_line(text, hl_group)
    table.insert(lines, text)
    if hl_group then
      table.insert(highlights, { line_idx, 0, -1, 'GdUnit4' .. hl_group })
    end
    line_idx = line_idx + 1
  end
  
  add_line('Test Results', 'Header')
  add_line(string.rep('═', 50))
  
  for suite_name, suite_data in pairs(test_results) do
    add_line(suite_name, 'File')
    
    -- Group tests by base function name
    local test_groups = {}
    for _, test in ipairs(suite_data.tests) do
      local base_func = test.name:match('^Test_[%w_]+') or test.name
      test_groups[base_func] = test_groups[base_func] or { tests = {}, time = 0 }
      table.insert(test_groups[base_func].tests, test)
      test_groups[base_func].time = test_groups[base_func].time + test.time
    end
    
    -- Display grouped tests
    for base_func, group in pairs(test_groups) do
      add_line('  ' .. base_func .. string.format(' (%dms)', math.floor(group.time * 1000)), 'FuncName')
      
      local group_passed = 0
      local group_failed = 0
      
      for _, test in ipairs(group.tests) do
        local symbol = test.status == 'PASSED' and '✓' or '✗'
        local hl = test.status == 'PASSED' and 'TestPassed' or 'TestFailed'
        local display = test.name:gsub('^' .. base_func, '')
        if display == '' then
          display = test.name
        else
          display = display:match('%(.*%)$') or display
        end
        
        add_line(string.format('    %s %s (%dms)', symbol, display, math.floor(test.time * 1000)), hl)
        
        if test.status == 'PASSED' then
          group_passed = group_passed + 1
          total_passed = total_passed + 1
        else
          group_failed = group_failed + 1
          total_failed = total_failed + 1
        end
        total_time = total_time + test.time
      end
      
      add_line(string.format('    %d passed, %d failed', group_passed, group_failed), 'Summary')
    end
    add_line('')
  end
  
  add_line(string.rep('─', 50))
  add_line(string.format('Total: %d passed, %d failed', total_passed, total_failed), 'Summary')
  add_line(string.format('Time: %dms', math.floor(total_time * 1000)), 'Time')
  
  return lines, highlights
end

-- Display test results in a floating window
function M.display_results(project_root, report_dir)
  -- Parse the report
  local test_results = M.parse_report(project_root, report_dir)
  if not test_results or vim.tbl_isempty(test_results) then
    vim.notify('No test results to display', vim.log.levels.WARN)
    return
  end
  
  -- Format the results
  local lines, highlights = M.format_results(test_results)
  
  -- Create buffer and set content
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Apply highlights
  local ns_id = vim.api.nvim_create_namespace('gdunit4_results')
  for _, hl in ipairs(highlights) do
    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, hl[4], hl[1], hl[2], hl[3])
  end
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'gdunit4_results')
  
  -- Display in floating window
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 2, vim.o.lines - 4)
  
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = 'minimal',
    border = 'rounded',
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(win, 'winblend', 0)
  
  -- Set keymaps for closing
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', ':close<CR>', { noremap = true, silent = true })
end

-- Clean old reports
function M.clean_old_reports(project_root, report_dir, max_reports)
  if not max_reports or max_reports <= 0 then return end
  
  local full_report_path = project_root .. '/' .. report_dir
  local handle = vim.uv.fs_scandir(full_report_path)
  if not handle then return end
  
  local reports = {}
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    
    if type == 'directory' and name:match('^report_%d+$') then
      local num = tonumber(name:match('report_(%d+)'))
      if num then table.insert(reports, { name = name, num = num }) end
    end
  end
  
  -- Sort reports by number (latest first)
  table.sort(reports, function(a, b) return a.num > b.num end)
  
  -- Remove excess reports
  if #reports > max_reports then
    for i = max_reports + 1, #reports do
      local path = full_report_path .. '/' .. reports[i].name
      vim.fn.delete(path, 'rf')
    end
  end
end

return M
