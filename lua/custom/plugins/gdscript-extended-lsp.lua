return {
  'Teatek/gdscript-extended-lsp.nvim',
  ft = { 'gdscript', 'gd', 'gdscript3' },
  dependencies = {},
  opts = {
    doc_file_extension = '.txt',
    view_type = 'floating',
    split_side = false,
    -- Disable the automatic 'gd' keymap but keep the close keymaps
    keymaps = {
      declaration = 'gd', -- We're setting this up manually in lspconfig
      close = { 'q', '<Esc>' },
    },
    floating_win_size = 0.8,
    picker = 'snacks',
  },
}
