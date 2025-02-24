local Utils = {}

function Utils.get_node_text(node, content)
  if not node then
    return nil
  end
  return vim.treesitter.get_node_text(node, content)
end

function Utils.strip_parentheses(text)
  if not text then
    return ''
  end
  return text:gsub('^%(', ''):gsub('%)$', '')
end

function Utils.extract_type_and_name(param_text)
  return param_text:match '([%w_<>%.]+)%s+([%w_]+)'
end

return Utils
