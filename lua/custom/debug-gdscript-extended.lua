-- Save this as lua/custom/debug-gdscript-extended.lua
-- Then run :lua require('custom.debug-gdscript-extended').check()

local M = {}

function M.check()
  print '\n=== GDScript Extended LSP Debug ===\n'

  -- Check filetype
  local ft = vim.bo.filetype
  print '1. Filetype Check:'
  print('   Current filetype: ' .. (ft ~= '' and ft or 'NONE'))
  print '   Expected: gdscript, gd, or gdscript3'
  local ft_match = (ft == 'gdscript' or ft == 'gd' or ft == 'gdscript3')
  print('   Match: ' .. (ft_match and 'YES ✓' or 'NO ✗'))

  -- Check if plugin is loaded
  print '\n2. Plugin Status:'
  local has_plugin, gdscript_extended = pcall(require, 'gdscript-extended-lsp')
  print('   Plugin loaded: ' .. (has_plugin and 'YES ✓' or 'NO ✗'))

  if has_plugin then
    -- Check if we can call functions
    local has_goto = type(gdscript_extended.goto_definition) == 'function'
    print('   goto_definition function: ' .. (has_goto and 'YES ✓' or 'NO ✗'))
  end

  -- Check 'gd' keymap
  print '\n3. Keymap Check:'
  local gd_map = vim.fn.maparg('gd', 'n', false, true)

  if vim.tbl_isempty(gd_map) then
    print '   gd keymap: NOT SET ✗'
  else
    print '   gd keymap: SET ✓'
    print('   Buffer local: ' .. (gd_map.buffer == 1 and 'YES' or 'NO'))
    if gd_map.desc then
      print('   Description: ' .. gd_map.desc)
    end
    if gd_map.callback then
      print '   Has callback: YES'
    elseif gd_map.rhs then
      print('   RHS: ' .. gd_map.rhs)
    end
  end

  -- Check all gdscript-related keymaps
  print '\n4. All GDScript Keymaps:'
  local all_maps = vim.api.nvim_buf_get_keymap(0, 'n')
  local found_any = false
  for _, map in ipairs(all_maps) do
    if map.desc and (map.desc:lower():find 'gdscript' or map.desc:lower():find 'godot') then
      print('   - ' .. map.lhs .. ': ' .. (map.desc or 'no description'))
      found_any = true
    end
  end
  if not found_any then
    print '   No gdscript-specific keymaps found'
  end

  -- Check LSP client
  print '\n5. LSP Client:'
  local clients = vim.lsp.get_clients { bufnr = 0 }
  local has_gdscript = false
  for _, client in ipairs(clients) do
    if client.name == 'gdscript' then
      print '   gdscript LSP: ACTIVE ✓'
      has_gdscript = true
    end
  end
  if not has_gdscript then
    print '   gdscript LSP: NOT ACTIVE ✗'
  end

  print '\n=== End Debug ===\n'

  -- Suggestions
  print 'Troubleshooting:'
  if not has_plugin then
    print '  1. Plugin not loaded. Try:'
    print '     :Lazy reload gdscript-extended-lsp.nvim'
  end

  if vim.tbl_isempty(gd_map) then
    print '  2. gd keymap not set. Manually set with:'
    print '     :lua vim.keymap.set("n", "gd", function() require("gdscript-extended-lsp").goto_definition() end, {buffer=true})'
  end

  if ft ~= 'gdscript' and ft ~= 'gd' and ft ~= 'gdscript3' then
    print '  3. Wrong filetype. Set with:'
    print '     :set filetype=gdscript'
  end

  print '\nTo test gd manually:'
  print '  :lua require("gdscript-extended-lsp").goto_definition()'
end

function M.manually_setup_keymap()
  local has_plugin, gdscript_extended = pcall(require, 'gdscript-extended-lsp')
  if not has_plugin then
    print 'Error: gdscript-extended-lsp not loaded'
    return
  end

  vim.keymap.set('n', 'gd', function()
    gdscript_extended.goto_definition()
  end, { buffer = true, desc = 'Go to GDScript definition with docs' })

  print 'Manually set gd keymap for current buffer'
end

return M
