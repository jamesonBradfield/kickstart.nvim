-- tests/unit/test_display_spec.lua
-- Add the plugin's lua directory to package.path
package.path = package.path .. ';../lua/?.lua'

describe('test display', function()
  local test_display

  -- Setup to load our module
  before_each(function()
    -- Force reload the module for each test
    package.loaded['gdunit4.test_display'] = nil
    test_display = require 'gdunit4.test_display'
  end)

  -- Sample test output for our tests
  local sample_output = [[
Godot Engine v4.3.stable.mono.arch_linux - https://godotengine.org
[38;2;250;235;215m	Run Test: /home/jamie/quadtreecSharp/test/Boid_test.cs > Test_RandomInitialization :[0m[38;2;34;139;34mSTARTED[0m
[s[38;2;250;235;215m	Run Test: /home/jamie/quadtreecSharp/test/Boid_test.cs > Test_RandomInitialization :[0m[38;2;34;139;34m[1mPASSED[0m[38;2;100;149;237m 28ms[0m

[38;2;250;235;215m	Run Test: /home/jamie/quadtreecSharp/test/Boid_test.cs > Test_Alignment_WithNoNearbyBoids_ReturnsZero :[0m[38;2;34;139;34mSTARTED[0m
[s[38;2;250;235;215m	Run Test: /home/jamie/quadtreecSharp/test/Boid_test.cs > Test_Alignment_WithNoNearbyBoids_ReturnsZero :[0m[38;2;34;139;34m[1mPASSED[0m[38;2;100;149;237m 6ms[0m]]

  describe('parse_test_output', function()
    it('should extract test names and results', function()
      local result = test_display.parse_test_output(sample_output)

      -- Print the result for debugging
      print('Parsed result:', vim.inspect(result))

      -- We expect to see tests organized by file
      assert.is_not_nil(result['Boid_test.cs'])
      local tests = result['Boid_test.cs']

      -- Check first test
      assert.equal('Test_RandomInitialization', tests[1].name)
      assert.equal('PASSED', tests[1].status)
      assert.equal(28, tests[1].time)

      -- Check second test
      assert.equal('Test_Alignment_WithNoNearbyBoids_ReturnsZero', tests[2].name)
      assert.equal('PASSED', tests[2].status)
      assert.equal(6, tests[2].time)
    end)

    it('should handle empty input', function()
      local result = test_display.parse_test_output ''
      assert.are.same({}, result)
    end)
  end)

  describe('format_test_results', function()
    it('should format test results with folds', function()
      local input = {
        ['Boid_test.cs'] = {
          {
            name = 'Test_RandomInitialization',
            status = 'PASSED',
            time = 28,
          },
          {
            name = 'Test_Alignment_WithNoNearbyBoids_ReturnsZero',
            status = 'PASSED',
            time = 6,
          },
        },
      }

      local formatted = test_display.format_test_results(input)

      -- Print formatted output for debugging
      print('\nFormatted output:\n', formatted)

      -- Split into lines for easier assertion
      local lines = {}
      for line in formatted:gmatch '[^\r\n]+' do
        table.insert(lines, line)
      end

      -- Check the header
      assert.equal('Test Results', lines[1])

      -- Check file section
      assert.equal('Boid_test.cs {{{', lines[3])

      -- Check test entries (using patterns to match)
      assert.matches('Test_RandomInitialization > 28ms %(PASSED%)', lines[4])
      assert.matches('Test_Alignment_WithNoNearbyBoids_ReturnsZero > 6ms %(PASSED%)', lines[5])

      -- Check summary
      assert.matches('Total: 2 passed, 0 failed', lines[#lines - 1])
    end)
  end)
end)
