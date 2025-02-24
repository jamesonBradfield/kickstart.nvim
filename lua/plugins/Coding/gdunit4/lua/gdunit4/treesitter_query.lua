-- treesitter_query.lua
-- This module handles all TreeSitter query-related operations
local TreeSitterQuery = {}

-- Store our queries as constants to make them easily maintainable
TreeSitterQuery.MAIN_QUERY = [[
    ; Get the namespace definition
    (namespace_declaration
        name: (identifier) @file.namespace
    )

    ; Get the class name and constructor
    (class_declaration
        name: (identifier) @file.class_name
        (constructor_declaration
            parameters: (parameter_list) @constructor.params
        )?
    )

    ; Get all method declarations and their components
    (method_declaration
        (modifier)* @method.modifier
        returns: [
            (predefined_type) @method.return_type
            (identifier) @method.return_type
            (type_argument_list) @method.return_type
            (generic_name) @method.return_type
        ]
        name: (identifier) @method.name
        parameters: (parameter_list) @method.params
    ) @method.declaration
]]

-- Create and return a parser query
function TreeSitterQuery.create_query(language, query_string)
    return vim.treesitter.query.parse(language, query_string)
end

return TreeSitterQuery
