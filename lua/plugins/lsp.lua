local keys = require 'keys'

return {
  {
    -- Blink.cmp: A lightning-fast, Rust-based completion engine.
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'none',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Space>'] = { 'accept', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      completion = {
        menu = { border = 'rounded' },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = 'rounded',
            max_width = 80,
            max_height = 20,
          },
        },
        ghost_text = { enabled = true },
      },
      signature = {
        enabled = true,
        window = {
          border = 'rounded',
          max_width = 80,
          max_height = 10,
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    -- LSPConfig: The standard Neovim interface for communicating with LSPs.
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      -- Standard Servers using native Neovim 0.11+ APIs
      -- blink.cmp automatically injects capabilities into these global configs

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
            diagnostics = { globals = { 'vim' } },
          },
        },
      })
      vim.lsp.enable 'lua_ls'

      vim.lsp.config('bashls', {})
      vim.lsp.enable 'bashls'

      vim.lsp.config('pyright', {})
      vim.lsp.enable 'pyright'

      -- Godot Server: Connects via localhost TCP to the Godot Editor instance
      vim.lsp.config('gdscript', {
        name = 'godot',
        cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      })
      vim.lsp.enable 'gdscript'

      vim.lsp.enable 'gdshader_lsp'

      -- Global diagnostic configuration
      local hover_border = {
        { '╭', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╮', 'FloatBorder' },
        { '│', 'FloatBorder' },
        { '╯', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╰', 'FloatBorder' },
        { '│', 'FloatBorder' },
      }

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = hover_border,
        max_height = 15,
      })

      -- Attach our global LSP mappings from keys.lua to any active LSP buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          for _, map in ipairs(keys.lsp_attach) do
            vim.keymap.set(map.mode or 'n', map[1], map[2], vim.tbl_extend('force', opts, { desc = map[3] }))
          end
        end,
      })
    end,
  },
  {
    -- LazyDev: Injects Neovim API types into the Lua LSP.
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
  { 'justinsgithub/wezterm-types', lazy = true },
}
