-- test_display.lua
local M = {}

-- Setup highlight groups
local function setup_highlights()
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

-- Find the most recent report folder
local function find_latest_report_folder(project_root)
  local reports_dir = project_root .. '/reports'
  local report_folders = {}

  vim.notify('Scanning reports directory: ' .. reports_dir, vim.log.levels.INFO)

  -- Read the reports directory
  local handle = vim.uv.fs_scandir(reports_dir)
  if not handle then
    vim.notify('Failed to read reports directory: ' .. reports_dir, vim.log.levels.ERROR)
    return nil
  end

  -- Collect all report folders
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    if type == 'directory' and name:match '^report_%d+$' then
      local num = tonumber(name:match 'report_(%d+)')
      if num then
        table.insert(report_folders, { folder = name, num = num })
      end
    end
  end

  -- Sort by number in descending order and return the latest
  if #report_folders > 0 then
    table.sort(report_folders, function(a, b)
      return a.num > b.num
    end)
    vim.notify('Latest report folder: ' .. report_folders[1].folder, vim.log.levels.INFO)
    return report_folders[1].folder
  end

  -- Fallback to look for results.xml directly in reports directory
  local fallback_path = reports_dir .. '/results.xml'
  local stat = vim.uv.fs_stat(fallback_path)
  if stat and stat.type == 'file' then
    vim.notify('Found fallback results.xml in reports directory', vim.log.levels.INFO)
    return '' -- Empty string to indicate using the root reports directory
  end

  vim.notify('No report folders or results.xml found', vim.log.levels.WARNING)
  return nil
end

-- Extract attribute value using treesitter nodes
local function get_attribute(node, attr_name, buf)
  if not node then
    return nil
  end

  -- Navigate to stag
  local stag = nil
  if node:type() == 'STag' then
    stag = node
  elseif node:type() == 'element' then
    for i = 0, node:named_child_count() - 1 do
      local child = node:named_child(i)
      if child and child:type() == 'STag' then
        stag = child
        break
      end
    end
  else
    for i = 0, node:named_child_count() - 1 do
      local child = node:named_child(i)
      if child and child:type() == 'STag' then
        stag = child
        break
      end
    end
  end

  if not stag then
    return nil
  end

  -- Find attributes in stag
  for i = 0, stag:named_child_count() - 1 do
    local attr = stag:named_child(i)
    if attr and attr:type() == 'Attribute' then
      local name_node = nil
      local value_node = nil

      -- Find name and value nodes
      for j = 0, attr:named_child_count() - 1 do
        local attr_child = attr:named_child(j)
        if attr_child then
          if attr_child:type() == 'Name' then
            name_node = attr_child
          elseif attr_child:type() == 'AttValue' then
            value_node = attr_child
          end
        end
      end

      -- Check if this is the attribute we're looking for
      if name_node and value_node then
        local name_text = vim.treesitter.get_node_text(name_node, buf)
        if name_text == attr_name then
          local value_text = vim.treesitter.get_node_text(value_node, buf)
          -- Remove quotes
          return value_text:match '"(.-)"' or value_text:match "'(.-)'" or value_text
        end
      end
    end
  end

  return nil
end

-- Parse test results from XML report using TreeSitter
function M.parse_xml_report(project_root)
  vim.notify('Starting parse_xml_report with project_root: ' .. project_root, vim.log.levels.INFO)

  local latest_folder = find_latest_report_folder(project_root)
  local report_path

  if latest_folder == nil then
    vim.notify('No report folders or results.xml found in: ' .. project_root .. '/reports', vim.log.levels.ERROR)
    return nil
  elseif latest_folder == '' then
    -- Use direct path if no report_X folders exist but results.xml exists in reports/
    report_path = project_root .. '/reports/results.xml'
  else
    report_path = project_root .. '/reports/' .. latest_folder .. '/results.xml'
  end

  vim.notify('Reading test report from: ' .. report_path, vim.log.levels.INFO)

  local file = io.open(report_path, 'r')
  if not file then
    vim.notify('No test report found at: ' .. report_path, vim.log.levels.ERROR)
    return nil
  end

  local xml_content = file:read '*all'
  file:close()

  vim.notify('Read XML content, length: ' .. #xml_content .. ' bytes', vim.log.levels.INFO)

  -- Create a buffer and populate it with XML content
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(xml_content, '\n'))

  vim.notify('Created buffer with XML content', vim.log.levels.INFO)

  -- Setup XML parser and verify language is available
  if not vim.treesitter.language.require_language('xml', nil, true) then
    vim.notify('XML parser not available. Trying to install...', vim.log.levels.WARNING)
    pcall(function()
      vim.cmd 'TSInstall xml'
    end)
    if not vim.treesitter.language.require_language('xml', nil, true) then
      vim.notify('Failed to load XML parser. Please install treesitter XML parser.', vim.log.levels.ERROR)
      vim.api.nvim_buf_delete(buf, { force = true })
      return nil
    end
  end

  local language_tree = vim.treesitter.get_parser(buf, 'xml')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  vim.notify('Successfully parsed XML with treesitter', vim.log.levels.INFO)

  -- Query for elements
  local query = vim.treesitter.query.parse(
    'xml',
    [[
    (element) @element
    ]]
  )

  vim.notify('Created treesitter query', vim.log.levels.INFO)

  local test_results = {}
  local ts_test_count = 0
  local found_testsuites = false

  -- Find all element nodes
  for id, node in query:iter_captures(root, buf) do
    local node_text = vim.treesitter.get_node_text(node, buf)
    local element_type = nil

    -- Find the name node within this element
    for i = 0, node:named_child_count() - 1 do
      local child = node:named_child(i)
      if child and child:type() == 'STag' then
        for j = 0, child:named_child_count() - 1 do
          local tag_child = child:named_child(j)
          if tag_child and tag_child:type() == 'Name' then
            element_type = vim.treesitter.get_node_text(tag_child, buf)
            break
          end
        end
        break
      end
    end

    if element_type == 'testsuite' then
      -- Process testsuite
      local name = get_attribute(node, 'name', buf)
      local time = get_attribute(node, 'time', buf)

      if name then
        vim.notify('Found testsuite: ' .. name, vim.log.levels.INFO)
        local suite = {
          name = name,
          tests = {},
          time = tonumber(time) or 0,
        }
        test_results[name] = suite

        -- Find testcase elements within this testsuite
        for i = 0, node:named_child_count() - 1 do
          local child = node:named_child(i)
          if child and child:type() == 'content' then
            -- Look for testcase elements in the content
            local testcase_query = vim.treesitter.query.parse(
              'xml',
              [[
              (element) @testcase_elem
              ]]
            )

            for tc_id, tc_node in testcase_query:iter_captures(child, buf) do
              -- Check if this element is a testcase
              local is_testcase = false
              for j = 0, tc_node:named_child_count() - 1 do
                local tc_child = tc_node:named_child(j)
                if tc_child and tc_child:type() == 'STag' then
                  for k = 0, tc_child:named_child_count() - 1 do
                    local tag_child = tc_child:named_child(k)
                    if tag_child and tag_child:type() == 'Name' then
                      local tag_name = vim.treesitter.get_node_text(tag_child, buf)
                      if tag_name == 'testcase' then
                        is_testcase = true
                        break
                      end
                    end
                  end
                  break
                end
              end

              if is_testcase then
                local tc_name = get_attribute(tc_node, 'name', buf)
                local tc_time = get_attribute(tc_node, 'time', buf)

                if tc_name then
                  ts_test_count = ts_test_count + 1
                  -- Check for failure elements
                  local has_failure = false
                  local tc_content = nil

                  for j = 0, tc_node:named_child_count() - 1 do
                    local tc_child = tc_node:named_child(j)
                    if tc_child and tc_child:type() == 'content' then
                      tc_content = tc_child
                      break
                    end
                  end

                  if tc_content then
                    local content_text = vim.treesitter.get_node_text(tc_content, buf)
                    has_failure = content_text:match '<failure' or content_text:match '<error'
                  end

                  table.insert(suite.tests, {
                    name = tc_name,
                    status = has_failure and 'FAILED' or 'PASSED',
                    time = tonumber(tc_time) or 0,
                  })
                end
              end
            end
          end
        end
      end
    elseif element_type == 'testsuites' then
      found_testsuites = true
    end
  end

  vim.notify('TreeSitter parsing found ' .. ts_test_count .. ' tests in ' .. vim.tbl_count(test_results) .. ' suites', vim.log.levels.INFO)

  vim.api.nvim_buf_delete(buf, { force = true })

  -- If we found no test suites but did find a testsuites element, the XML structure might be different
  if vim.tbl_isempty(test_results) and found_testsuites then
    vim.notify('Found testsuites but no tests. XML structure might be different than expected.', vim.log.levels.WARNING)
  end

  return test_results
end

-- Format test results for display
function M.format_results(test_results)
  vim.notify('Starting format_results with ' .. vim.inspect(vim.tbl_count(test_results)) .. ' test suites', vim.log.levels.INFO)
  local lines = {}
  local highlights = {}
  local line_idx = 0
  local total_passed = 0
  local total_failed = 0
  local total_time = 0
  local total_tests = 0

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
    vim.notify('Formatting suite: ' .. suite_name .. ' with ' .. #suite_data.tests .. ' tests', vim.log.levels.DEBUG)
    total_tests = total_tests + #suite_data.tests

    -- Group tests by base function name
    local test_groups = {}
    for _, test in ipairs(suite_data.tests) do
      local base_func = test.name:match '^Test_[%w_]+' or test.name
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
          display = display:match '%(.*%)$' or display
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

      if #group.tests > 0 then
        add_line(string.format('    %d passed, %d failed', group_passed, group_failed), 'Summary')
      end
    end
    add_line ''
  end

  add_line(string.rep('─', 50))
  add_line(string.format('Total: %d passed, %d failed', total_passed, total_failed), 'Summary')
  add_line(string.format('Time: %dms', math.floor(total_time * 1000)), 'Time')

  vim.notify('Formatted results: ' .. #lines .. ' lines, total tests: ' .. total_tests, vim.log.levels.INFO)

  return lines, highlights
end

-- Display test results in buffer
function M.display_test_results(project_root)
  vim.notify('Starting display_test_results with project_root: ' .. project_root, vim.log.levels.INFO)
  setup_highlights()

  local test_results = M.parse_xml_report(project_root)
  if not test_results or vim.tbl_isempty(test_results) then
    vim.notify('No test results to display!', vim.log.levels.ERROR)
    return
  end

  local lines, highlights = M.format_results(test_results)
  if #lines == 0 then
    vim.notify('No content to display!', vim.log.levels.ERROR)
    return
  end

  vim.notify('Created ' .. #lines .. ' lines with ' .. #highlights .. ' highlights', vim.log.levels.INFO)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local ns_id = vim.api.nvim_create_namespace 'gdunit4_results'
  for _, hl in ipairs(highlights) do
    pcall(vim.api.nvim_buf_add_highlight, buf, ns_id, hl[4], hl[1], hl[2], hl[3])
  end

  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'gdunit4_results')

  vim.notify('Buffer prepared, attempting to display', vim.log.levels.INFO)

  -- Try to display with Snacks first
  local success = pcall(function()
    require('snacks').win {
      buf = buf,
      width = 0.6,
      height = 0.6,
      style = 'minimal',
      position = 'float',
      relative = 'editor',
      enter = true,
      wo = {
        spell = false,
        wrap = false,
        signcolumn = 'yes',
        foldmethod = 'indent',
        foldlevel = 0,
      },
      keys = { q = 'close', ['<Esc>'] = 'close' },
    }
  end)

  -- Fall back to split if Snacks fails
  if not success then
    vim.notify('Snacks display failed, falling back to split', vim.log.levels.WARNING)
    vim.cmd('vsplit | buffer ' .. buf)
  end

  vim.notify('Test results display complete', vim.log.levels.INFO)
end

return M
