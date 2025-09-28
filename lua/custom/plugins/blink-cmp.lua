return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- Custom keymap to match your old nvim-cmp mappings
    keymap = {
      preset = 'none', -- Start with no preset so we can define our own
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      nerd_font_variant = 'mono',
    },
    signature = {
      enabled = true,
      window = {
        show_documentation = false,
      },
    },
    -- Enable ghost text (equivalent to your old experimental.ghost_text = true)
    completion = {
      documentation = { auto_show = true },
      -- ghost_text = { enabled = true },
    },

    -- Configure sources (LSP gets priority by being first)
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- Snippets configuration
    snippets = {
      expand = function(snippet)
        -- Custom snippet expansion for Godot Mono
        -- This replaces your old cmp snippet.expand function
        require('luasnip').lsp_expand(snippet)
      end,
      active = function(filter)
        -- Check if snippets should be active
        if filter and filter.direction then
          return require('luasnip').jumpable(filter.direction)
        end
        return require('luasnip').in_snippet()
      end,
      jump = function(direction)
        require('luasnip').jump(direction)
      end,
    },

    -- Fuzzy matching configuration
    fuzzy = {
      implementation = 'prefer_rust_with_warning',
      -- Enable better matching for C# and Godot code
      -- use_typo_resistance = true,
    },
  },
  opts_extend = { 'sources.default' },
}
