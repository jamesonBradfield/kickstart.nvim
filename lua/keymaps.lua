-- keymaps.lua
local M = {}

-- Map a key in specific mode
function M.map(mode, lhs, rhs, opts)
  -- Ensure opts is a table
  opts = opts or {}
  
  -- Set default values if not specified
  if opts.silent == nil then opts.silent = true end
  if opts.noremap == nil then opts.noremap = true end
  
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Map a key in specific buffer
function M.buf_map(bufnr, mode, lhs, rhs, opts)
  -- Ensure opts is a table
  opts = opts or {}
  
  -- Set buffer
  opts.buffer = bufnr
  
  -- Set default values if not specified
  if opts.silent == nil then opts.silent = true end
  if opts.noremap == nil then opts.noremap = true end
  
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M
