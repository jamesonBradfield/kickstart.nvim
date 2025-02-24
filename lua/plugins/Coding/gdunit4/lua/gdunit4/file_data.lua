-- file_data.lua
-- Represents the structure of parsed C# file data
local FileData = {}

-- Create a new FileData instance
function FileData.new()
    return {
        namespace = nil,
        class_name = nil,
        constructor_params = nil,
        methods = {},
        root = nil,    -- Store root for later custom type analysis
        content = nil, -- Store content for later analysis
    }
end

-- Add a method to the file data
function FileData.add_method(file_data, method_info, modifiers)
    if vim.tbl_contains(modifiers, 'public') then
        table.insert(file_data.methods, method_info)
    end
end

return FileData
