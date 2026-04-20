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
        preset = 'super-tab',
        ['<CR>'] = { 'accept', 'fallback' },
      },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    -- LSPConfig: The standard Neovim interface for communicating with LSPs.
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
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

      -- Standard Servers
      vim.lsp.config('lua_language_server', {})
      vim.lsp.enable 'lua_language_server'
      vim.lsp.config('bash_language_server', {})
      vim.lsp.enable 'bash_language_server'
      vim.lsp.config('basedpyright', {})
      vim.lsp.enable 'basedpyright'
      -- Godot Server: Connects via localhost TCP to the Godot Editor instance
      vim.lsp.config('gdscript', {
        name = 'godot',
        cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
      })
      vim.lsp.enable 'gdscript'
      vim.lsp.enable 'gdshader_lsp'
    end,
  },
  {
    -- LazyDev: Injects Neovim API types into the Lua LSP.
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },
  { 'justinsgithub/wezterm-types', lazy = true },
}
