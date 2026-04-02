local M = {}

-- ============================================================================
-- NAVIGATION & WINDOW MANAGEMENT
-- ============================================================================

---Smart navigation that handles floating windows and terminals
---@param direction 'h'|'j'|'k'|'l'
---@param method string smart-splits method name
local function smart_nav(direction, method)
  return function()
    -- Check for floating windows/filetypes that should use native wincmd
    local ft = vim.bo.filetype
    local is_floating = vim.api.nvim_win_get_config(0).relative ~= ''

    if vim.tbl_contains({ 'snacks_picker_list', 'snacks_picker_input', 'minifiles' }, ft) or is_floating then
      vim.cmd('wincmd ' .. direction)
    else
      -- Use smart-splits for regular windows and terminals
      require('smart-splits')[method]()
    end
  end
end

M.smart_splits = {
  { '<C-h>', smart_nav('h', 'move_cursor_left'), mode = { 'n', 't' }, desc = 'Move left' },
  { '<C-j>', smart_nav('j', 'move_cursor_down'), mode = { 'n', 't' }, desc = 'Move down' },
  { '<C-k>', smart_nav('k', 'move_cursor_up'), mode = { 'n', 't' }, desc = 'Move up' },
  { '<C-l>', smart_nav('l', 'move_cursor_right'), mode = { 'n', 't' }, desc = 'Move right' },
}

M.mini_files = {
  {
    '<C-f>',
    function()
      local mf = require 'mini.files'
      if not mf.close() then
        mf.open(vim.api.nvim_buf_get_name(0))
      end
    end,
    desc = 'Toggle mini.files',
  },
}

M.grapple = {
  { '<leader>ha', '<cmd>Grapple toggle<cr>', desc = 'Grapple: Add/Toggle Tag' },
  { '<leader>hm', '<cmd>Grapple toggle_tags<cr>', desc = 'Grapple: Menu' },
  { '<leader>h1', '<cmd>Grapple select index=1<cr>', desc = 'Grapple: Select 1' },
  { '<leader>h2', '<cmd>Grapple select index=2<cr>', desc = 'Grapple: Select 2' },
  { '<leader>h3', '<cmd>Grapple select index=3<cr>', desc = 'Grapple: Select 3' },
  { '<leader>h4', '<cmd>Grapple select index=4<cr>', desc = 'Grapple: Select 4' },
}

M.flash = {
  { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
  { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
  { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote Flash' },
  { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter Search' },
  { '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash Search' },
}

-- ============================================================================
-- TERMINALS & AIDER [t]
-- ============================================================================

M.snacks = {
  -- Aider Integration
  { '<leader>ta', function() require('aider').toggle() end, desc = 'Aider: Toggle' },
  { '<leader>th', function() require('aider').send_hover() end, desc = 'Aider: Send Hover' },
  { '<leader>t+', function() require('aider').add_file(vim.api.nvim_buf_get_name(0)) end, desc = 'Aider: Add Current File' },

  -- Terminal Management
  { '<leader>tt', function() Snacks.terminal.toggle() end, desc = 'Toggle Terminal' },
  { '<leader>tp', function() Snacks.picker.terminal() end, desc = 'Terminal Picker' },
  { '<leader>tc', function() require('aider').clear_context() end, desc = 'Aider: Clear Hover Context' },
  { '<leader>tb', function() Snacks.terminal.toggle 'Bacon Builder' end, desc = 'Toggle Bacon' },
  
  -- Pickers (Search Group) [s]
  { '<leader>sf', function() Snacks.picker.files() end, desc = 'Find Files' },
  { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep' },
  { '<leader>sr', function() Snacks.picker.recent() end, desc = 'Recent' },
  { '<leader>sc', function() Snacks.picker.files { cwd = vim.fn.stdpath 'config' } end, desc = 'Config' },
  { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help' },
  { '<leader>sb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
  { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual Selection or Word', mode = { 'n', 'x' } },
  
  -- Utils [u]
  { '<leader>un', function() Snacks.notifier.show_history() end, desc = 'Notifications' },
  { '<leader>uz', function() Snacks.zen() end, desc = 'Zen' },
}

-- ============================================================================
-- LSP, SYMBOLS & TROUBLE [c] [e]
-- ============================================================================

M.lsp_attach = {
  { 'gd', vim.lsp.buf.definition, 'LSP: Go to Definition' },
  { 'gD', vim.lsp.buf.declaration, 'LSP: Go to Declaration' },
  { 'gr', vim.lsp.buf.references, 'LSP: References' },
  { 'gi', vim.lsp.buf.implementation, 'LSP: Implementation' },
  { '<leader>ch', vim.lsp.buf.hover, 'LSP: Hover Documentation' },
  { '<C-k>', vim.lsp.buf.signature_help, 'LSP: Signature Help' },
  { '<leader>cr', vim.lsp.buf.rename, 'LSP: Rename' },
  { '<leader>ca', vim.lsp.buf.code_action, 'LSP: Code Action', mode = { 'n', 'v' } },
  { '<leader>cD', vim.lsp.buf.type_definition, 'LSP: Type Definition' },
}


M.trouble = {
  { '<leader>ee', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
  { '<leader>eE', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
  { '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
  { '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', desc = 'LSP Definitions / references / ... (Trouble)' },
  { '<leader>el', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
  { '<leader>eq', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
}

M.ufo = {
  { 'zR', function() require('ufo').openAllFolds() end, desc = 'Open all folds' },
  { 'zM', function() require('ufo').closeAllFolds() end, desc = 'Close all folds' },
  { 'zr', function() require('ufo').openFoldsExceptKinds() end, desc = 'Open folds except kinds' },
  { 'zm', function() require('ufo').closeFoldsWith() end, desc = 'Close folds with' },
  { 'zp', function() require('ufo').peekFoldedLinesUnderCursor() end, desc = 'Peek fold' },
}

M.todo_comments = {
  { ']]', function() require('todo-comments').jump_next() end, desc = 'Next TODO' },
  { '[[', function() require('todo-comments').jump_prev() end, desc = 'Prev TODO' },
  { '<leader>et', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
}

-- ============================================================================
-- DEBUGGING (DAP) [d]
-- ============================================================================

M.dap = {
  { '<F5>', function() require('dap').continue() end, desc = 'DAP: Continue' },
  { '<F10>', function() require('dap').step_over() end, desc = 'DAP: Step Over' },
  { '<F11>', function() require('dap').step_into() end, desc = 'DAP: Step Into' },
  { '<F12>', function() require('dap').step_out() end, desc = 'DAP: Step Out' },
  { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
  { '<leader>du', function() require('dapui').toggle() end, desc = 'DAP UI' },
}

-- ============================================================================
-- SESSIONS & QUIT [q]
-- ============================================================================

M.persistence = {
  { '<leader>qs', function() require('persistence').load() end, desc = 'Restore Session' },
  { '<leader>ql', function() require('persistence').load { last = true } end, desc = 'Restore Last' },
  { '<leader>qd', function() require('persistence').stop() end, desc = "Don't Save Session" },
  { '<leader>qq', '<cmd>qa<cr>', desc = 'Quit All' },
}

M.which_key = {
  {
    '<leader>?',
    function()
      require('which-key').show { global = false }
    end,
    desc = 'Buffer Keymaps',
  },
}

M.telekasten = {
  { '<leader>kk', mode = 'n', '<cmd>Telekasten panel<CR>', desc = 'Telekasten' },
  { '<leader>kf', mode = 'n', '<cmd>Telekasten find_notes<CR>', desc = 'Find Notes' },
  { '<leader>kn', mode = 'n', '<cmd>Telekasten new_note<CR>', desc = 'New Note' },
}

return M
