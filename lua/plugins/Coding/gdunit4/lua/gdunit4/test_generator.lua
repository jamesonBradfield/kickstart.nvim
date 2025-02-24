local TestGenerator = {}
local Utils = require 'gdunit4.utils'
local ParameterHandler = require 'gdunit4.parameter_handler'
local TypeSystem = require 'gdunit4.type_system'

-- Generates a test method for a given method info
function TestGenerator.generate_test_method(method_info)
  -- Create a descriptive test method name
  local test_name = 'Test_' .. method_info.name

  -- Generate the method call with appropriate parameters
  local method_call = string.format('_sut.%s(%s)', method_info.name, ParameterHandler.generate_parameter_values(method_info.parameters))

  -- Add result capture for non-void methods
  if method_info.return_type and method_info.return_type ~= 'void' then
    method_call = string.format('var result = %s', method_call)
  end

  -- Create the complete test method
  return string.format(
    [[
    [TestCase]
    public void %s()
    {
        // Arrange
        AssertThat(_sut).IsNotNull();

        // Act
        %s;

        // Assert
        // TODO: Add specific assertions for %s
    }]],
    test_name,
    method_call,
    method_info.name
  )
end

-- Generates constructor field declarations and initialization
function TestGenerator.generate_constructor_setup(file_data, content, root)
  if not file_data.constructor_params then
    return '', '', '' -- No constructor parameters needed
  end

  local field_declarations = {}
  local initializations = {}
  local constructor_args = {}

  -- Parse and process each constructor parameter
  local params = ParameterHandler.parse_parameters(file_data.constructor_params)
  for param in ipairs(params) do
    local param_type, param_name = Utils.extract_type_and_name(param)
    if param_type and param_name then
      -- Add field declaration
      table.insert(field_declarations, string.format('    private %s _%s;', param_type, param_name))

      -- Generate initialization code using our type system
      table.insert(initializations, TypeSystem.generate_type_initialization(param_type, param_name, content, root))

      -- Add to constructor arguments
      table.insert(constructor_args, '_' .. param_name)
    end
  end

  return table.concat(field_declarations, '\n'), table.concat(initializations, '\n'), table.concat(constructor_args, ', ')
end


function TestGenerator.generate_test_class(file_data)
  -- Generate constructor-related code
  local field_declarations, initializations, constructor_args = TestGenerator.generate_constructor_setup(file_data, file_data.content, file_data.root)

  -- Generate the complete test class
  return string.format(
    [[
namespace %s;

using GdUnit4;
using static GdUnit4.Assertions;

[TestSuite]
public class %sTest
{
    private %s? _sut;
%s

    [Before]
    public void Setup()
    {
%s
        _sut = AutoFree(new %s(%s));
        AssertThat(_sut).IsNotNull();
    }

    [After]
    public void TearDownSuite()
    {
        // Clean up suite-wide resources if needed
    }

    [BeforeTest]
    public void SetupTest()
    {
        // Set up resources needed for each individual test
    }

    [AfterTest]
    public void TearDownTest()
    {
        // Clean up after each individual test
    }

%s
}]],
    file_data.namespace or 'DefaultNamespace',
    file_data.class_name,
    file_data.class_name,
    field_declarations,
    initializations,
    file_data.class_name,
    constructor_args,
    table.concat(vim.tbl_map(TestGenerator.generate_test_method, file_data.methods), '\n\n')
  )
end

return TestGenerator
