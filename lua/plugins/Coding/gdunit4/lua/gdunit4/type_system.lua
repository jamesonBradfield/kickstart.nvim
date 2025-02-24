-- type_system.lua
-- Handles C# type analysis and initialization
local TypeSystem = {}
local Utils = require 'gdunit4.utils'
local ParameterHandler = require 'gdunit4.parameter_handler'

TypeSystem.custom_type_cache = {}

TypeSystem.type_initializations = {
  -- Numeric types
  ['int'] = function(name)
    return string.format('        _%s = 1;', name)
  end,
  ['float'] = function(name)
    return string.format('        _%s = 1.0f;', name)
  end,
  ['double'] = function(name)
    return string.format('        _%s = 1.0;', name)
  end,
  ['decimal'] = function(name)
    return string.format('        _%s = 1.0m;', name)
  end,

  -- Boolean type
  ['bool'] = function(name)
    return string.format('        _%s = false;', name)
  end,

  -- String type
  ['string'] = function(name)
    return string.format('        _%s = "test";', name)
  end,

  -- Common collection types
  ['List<'] = function(name, param_type)
    local type_param = param_type:match 'List<(.+)>' or 'object'
    return string.format('        _%s = new List<%s>();', name, type_param)
  end,
  ['Dictionary<'] = function(name, param_type)
    local type_params = param_type:match 'Dictionary<(.+)>' or 'object, object'
    return string.format('        _%s = new Dictionary<%s>();', name, type_params)
  end,

  -- DateTime type
  ['DateTime'] = function(name)
    return string.format('        _%s = DateTime.Now;', name)
  end,

  -- Guid type
  ['Guid'] = function(name)
    return string.format('        _%s = Guid.NewGuid();', name)
  end,
}

-- Analyzes a custom type's constructor
function TypeSystem.analyze_custom_type(type_name, content, root)
  -- Return cached results if available
  if TypeSystem.custom_type_cache[type_name] then
    return TypeSystem.custom_type_cache[type_name]
  end

  local query = vim.treesitter.query.parse(
    'c_sharp',
    string.format(
      [[
        (class_declaration
            name: (identifier) @class.name
            (#eq? @class.name "%s")
            (constructor_declaration
                parameters: (parameter_list) @constructor.params
            )?
        )
    ]],
      type_name
    )
  )

  local constructor_info = {
    name = type_name,
    parameters = {},
  }

  for id, node in query:iter_captures(root, content) do
    if query.captures[id] == 'constructor.params' then
      local params_text = Utils.get_node_text(node, content)
      if params_text then
        for param in ParameterHandler.parse_parameters(Utils.strip_parentheses(params_text)) do
          local param_type, param_name = Utils.extract_type_and_name(param)
          if param_type and param_name then
            table.insert(constructor_info.parameters, {
              type = param_type,
              name = param_name,
            })
          end
        end
      end
    end
  end

  TypeSystem.custom_type_cache[type_name] = constructor_info
  return constructor_info
end

function TypeSystem.generate_type_initialization(param_type, param_name, content, root)
  -- Check for built-in type initializations
  if TypeSystem.type_initializations[param_type] then
    return TypeSystem.type_initializations[param_type](param_name)
  end

  -- Check for generic collection types
  for prefix, initializer in pairs(TypeSystem.type_initializations) do
    if param_type:find('^' .. prefix) then
      return initializer(param_name, param_type)
    end
  end

  -- Handle custom types
  local constructor_info = TypeSystem.analyze_custom_type(param_type, content, root)
  if constructor_info and #constructor_info.parameters > 0 then
    local initializations = {}
    local param_values = {}

    -- Generate initializations for constructor parameters
    for _, param in ipairs(constructor_info.parameters) do
      table.insert(initializations, TypeSystem.generate_type_initialization(param.type, param.name, content, root))
      table.insert(param_values, string.format('_%s', param.name))
    end

    -- Add the constructor call
    table.insert(initializations, string.format('        _%s = new %s(%s);', param_name, param_type, table.concat(param_values, ', ')))

    return table.concat(initializations, '\n')
  end

  -- Fallback for unknown types
  return string.format('        _%s = new %s();', param_name, param_type)
end

return TypeSystem
