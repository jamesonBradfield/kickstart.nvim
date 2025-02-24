-- method_parser.lua
-- Handles parsing of method-related information
local MethodParser = {}
local Utils = require('gdunit4.utils')

-- Create a new method context for tracking current method being parsed
function MethodParser.create_method_context()
    return {
        current_method = nil,
        method_modifiers = {},
    }
end

-- Process a method node based on its capture type
function MethodParser.process_method_node(context, capture_name, node, content)
    if capture_name == 'method.declaration' then
        context.current_method = {}
        context.method_modifiers = {}
    elseif capture_name == 'method.modifier' then
        table.insert(context.method_modifiers, Utils.get_node_text(node, content))
    elseif capture_name == 'method.name' and context.current_method then
        context.current_method.name = Utils.get_node_text(node, content)
    elseif capture_name == 'method.return_type' and context.current_method then
        context.current_method.return_type = Utils.get_node_text(node, content)
    elseif capture_name == 'method.params' and context.current_method then
        context.current_method.parameters = Utils.get_node_text(node, content)
        return true -- Signal that method is complete
    end
    return false
end

return MethodParser
