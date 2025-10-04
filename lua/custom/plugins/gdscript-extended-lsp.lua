-- lua/custom/plugins/gdscript-extended-lsp.lua
-- Replace your existing file with this version
return {
  'Teatek/gdscript-extended-lsp.nvim',
  ft = { 'gdscript', 'gd', 'gdscript3' },
  dependencies = {},
  opts = {
    doc_file_extension = '.txt',
    view_type = 'floating', -- Changed from vsplit to floating
    split_side = false,
    keymaps = {
      declaration = 'gd', -- This should set the gd keymap
      close = { 'q', '<Esc>' },
    },
    floating_win_size = 0.8,
    picker = 'snacks', -- Changed from telescope to snacks
  },
}
