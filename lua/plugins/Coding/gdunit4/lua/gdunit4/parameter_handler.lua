-- parameter_handler.lua
-- Manages parameter parsing and generation
local ParameterHandler = {}
local Utils = require('gdunit4.utils')

function ParameterHandler.parse_parameters(params_text)
  if not params_text or params_text == '' then
    return {}
  end

  local params = {}
  for param in Utils.strip_parentheses(params_text):gmatch '[^,]+' do
    param = param:match '^%s*(.-)%s*$'
    if param ~= '' then
      table.insert(params, param)
    end
  end
  return params
end

function ParameterHandler.generate_parameter_values(params_text)
  local params = ParameterHandler.parse_parameters(params_text)
  local param_values = {}

  for _, param in ipairs(params) do
    local param_type = param:match '([%w_<>]+)%s+[%w_]+'
    if param_type then
      -- Use our type system to determine appropriate default values
      local default_value = ({
        string = '""',
        int = '0',
        float = '0.0f',
        double = '0.0',
        bool = 'false',
      })[param_type:lower()] or 'null'

      table.insert(param_values, default_value)
    end
  end

  return table.concat(param_values, ', ')
end


return ParameterHandler

