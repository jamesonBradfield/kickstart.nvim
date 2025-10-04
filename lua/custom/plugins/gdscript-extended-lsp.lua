-- lua/custom/plugins/gdscript-extended-lsp.lua
return {
  'Teatek/gdscript-extended-lsp.nvim',
  ft = 'gdscript',
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  opts = {
    doc_file_extension = '.txt',
    view_type = 'floating', -- Options: "current", "split", "vsplit", "tab", "floating"
    split_side = false,
    keymaps = {
      declaration = 'gd', -- Go to definition (enhanced with documentation)
      close = { 'q', '<Esc>' },
    },
    floating_win_size = 0.8,
    picker = 'snacks', -- Since you're using snacks.nvim
  },
  config = function(_, opts)
    require('gdscript-extended-lsp').setup(opts)

    -- Load telescope extension if using telescope picker
    -- if opts.picker == 'telescope' then
    --   require('telescope').load_extension('gdscript-extended-lsp')
    -- end
  end,
}
