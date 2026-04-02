-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\\\'

vim.env.PYTHONIOENCODING = 'utf-8'

local msys2_path = vim.fn.expand '~/scoop/apps/msys2/current/usr/bin/zsh.exe'

vim.o.shell = msys2_path
vim.o.shellcmdflag = '-c'
vim.o.shellquote = ''
vim.o.shellxquote = '' -- Crucial for MSYS2: keep this empty to avoid double-quoting
vim.o.relativenumber = true
vim.o.number = true -- Show line numbers
vim.o.clipboard = 'unnamedplus' -- Use system clipboard
vim.o.mouse = 'a' -- Enable mouse support
vim.o.backup = false -- No backup files
vim.o.swapfile = false -- No swap files
vim.o.undofile = true -- Enable persistent undo
vim.o.autoread = true -- Auto-reload files changed outside of Neovim (Required for OpenCode)
vim.o.incsearch = true -- Incremental search
vim.o.ignorecase = true -- Ignore case in searches
vim.o.smartcase = true -- Smart case for searches
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.tabstop = 2 -- Number of spaces for tab
vim.o.shiftwidth = 2 -- Number of spaces for indent
vim.o.softtabstop = 2 -- Number of spaces for tab in insert mode
vim.o.autoindent = true -- Auto indent new lines
vim.o.smartindent = true -- Smart indent
vim.o.wrap = false -- Don't wrap lines
vim.o.signcolumn = 'yes' -- Always show sign column
vim.o.updatetime = 250 -- Faster update time for cursorhold
vim.o.timeoutlen = 500 -- Timeout for key codes
vim.o.ttimeoutlen = 0 -- No timeout for key codes
vim.o.termguicolors = true -- Enable 24-bit RGB colors
vim.o.list = true -- Show invisible characters
vim.o.listchars = 'tab:>·,trail:·,nbsp:·' -- Show invisible characters
vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldclose:' -- Better fold characters
vim.o.shortmess = 'atI' -- Shorten messages
vim.o.lazyredraw = true -- Don't redraw while executing macros
vim.o.scrolloff = 3 -- Minimum lines to keep above/below cursor
vim.o.splitright = true -- Split to the right
vim.o.splitbelow = true -- Split to the bottom
vim.o.cursorline = true -- Highlight current line
vim.o.showmode = false -- Don't show mode in command line
vim.o.showcmd = false -- Don't show command in command line
vim.o.laststatus = 2 -- Always show status line
vim.o.cmdheight = 1 -- Command line height
vim.o.pumheight = 10 -- Popup menu height
vim.o.wildmenu = true -- Enhanced command line completion
vim.o.wildmode = 'list:longest' -- Wild menu mode
vim.o.history = 1000 -- Command history size
vim.o.maxmempattern = 1000000 -- Maximum memory for pattern matching
vim.o.diffopt = 'filler,context:0' -- Diff options
vim.o.conceallevel = 2 -- Enable conceal for render-markdown.nvim (LaTeX, etc.)
vim.o.concealcursor = 'n' -- Conceal cursor in normal mode
vim.o.guicursor = '' -- Use default cursor shape
-- Clear search highlights with <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- 1. Configure how the diagnostics look natively
vim.diagnostic.config {
  virtual_text = false, -- DISABLED: Use Trouble instead
  signs = true, -- Shows the icon in the gutter
  underline = true, -- Underlines the broken code
  update_in_insert = false, -- Wait until you exit insert mode to yell at you
  severity_sort = true, -- Puts the worst errors at the top
  float = {
    border = 'rounded',
    source = true, -- Shows whether the error came from the Godot LSP or gdlint
    header = '',
    prefix = '',
  },
}

-- 2. Sign icons
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ===================================================================== --
-- WEZTERM INTEGRATION
-- Emits OSC sequences to tell Wezterm when Neovim is active.
-- Useful for dynamically rebinding keys in Wezterm based on context.
-- ===================================================================== --

local function set_wezterm_user_var(key, value)
  -- WezTerm expects the value to be base64 encoded
  local b64_value = vim.base64.encode(tostring(value))
  -- Emit the OSC 1337 escape sequence
  io.stdout:write(string.format('\x1b]1337;SetUserVar=%s=%s\x07', key, b64_value))
  io.stdout:flush() -- Force Neovim to send the signal immediately
end

local wezterm_group = vim.api.nvim_create_augroup('WeztermIntegration', { clear = true })

-- Tell WezTerm when Neovim starts
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = wezterm_group,
  callback = function()
    set_wezterm_user_var('IS_NVIM', 'true')
  end,
})

-- Tell WezTerm when Neovim exits
vim.api.nvim_create_autocmd({ 'VimLeave' }, {
  group = wezterm_group,
  callback = function()
    set_wezterm_user_var('IS_NVIM', 'false')
  end,
})

-- ===================================================================== --
-- GODOT-RUST AUTO-BUILD
-- Compiles the GDExtension library in the background when saving Rust files.
-- ===================================================================== --
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('RustGodotBuild', { clear = true }),
  pattern = '*.rs',
  callback = function()
    vim.system({ 'cargo', 'build' }, { text = true }, function(out)
      if out.code == 0 then
        -- Schedule the notification so it doesn't crash from being off the main thread
        vim.schedule(function()
          vim.notify('󰣖 GDExtension compiled!', vim.log.levels.INFO, { title = 'Cargo' })
        end)
      else
        vim.schedule(function()
          vim.notify('GDExtension build failed. Check Bacon/Trouble.', vim.log.levels.ERROR, { title = 'Cargo' })
        end)
      end
    end)
  end,
  desc = 'Auto-build Rust GDExtension on save',
})
