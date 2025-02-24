-- parser.lua
local Parser = {}
local Utils = require('gdunit4.utils')
local TreeSitterQuery = require('gdunit4.treesitter_query')
local FileData = require('gdunit4.file_data')
local MethodParser = require('gdunit4.method_parser')

function Parser.parse_file(file_path)
  -- Read the file content
  local content = table.concat(vim.fn.readfile(file_path), '\n')

  -- Initialize TreeSitter parser
  local ts_parser = vim.treesitter.get_parser(0, 'c_sharp')
  if not ts_parser then
    error 'Failed to create TreeSitter parser for C#'
  end
  local tree = ts_parser:parse()[1]
  local root = tree:root()

  -- Create the query
  local query = TreeSitterQuery.create_query('c_sharp', TreeSitterQuery.MAIN_QUERY)

  -- Initialize our data structure
  local file_data = FileData.new()
  file_data.root = root
  file_data.content = content

  -- Initialize method parsing context
  local method_context = MethodParser.create_method_context()

  -- Process query captures
  for id, node in query:iter_captures(root, content) do
    local capture_name = query.captures[id]

    if capture_name == 'file.namespace' then
      file_data.namespace = Utils.get_node_text(node, content)
    elseif capture_name == 'constructor.params' then
      file_data.constructor_params = Utils.get_node_text(node, content)
    elseif capture_name == 'file.class_name' then
      file_data.class_name = Utils.get_node_text(node, content)
    else
      -- Handle method-related captures
      local method_complete = MethodParser.process_method_node(method_context, capture_name, node, content)

      -- If method parsing is complete, add it to file_data
      if method_complete then
        FileData.add_method(file_data, method_context.current_method, method_context.method_modifiers)
        method_context = MethodParser.create_method_context()
      end
    end
  end

  return file_data
end

return Parser
