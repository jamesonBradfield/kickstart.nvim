local M = {}
M.mini_files = {
  {
    '<C-f>',
    function()
      local mf = require 'mini.files'
      -- Toggle logic: if it's open, close it. If closed, open to current buffer's directory.
      if not mf.close() then
        mf.open(vim.api.nvim_buf_get_name(0))
      end
    end,
    desc = 'Toggle mini.files',
  },
}
-- Session management
M.persistence = {
  {
    '<leader>qs',
    function()
      require('persistence').load()
    end,
    desc = 'Restore Session for current dir',
  },
  {
    '<leader>ql',
    function()
      require('persistence').load { last = true }
    end,
    desc = 'Restore Last Session',
  },
  {
    '<leader>qd',
    function()
      require('persistence').stop()
    end,
    desc = "Don't Save Current Session",
  },
}

-- File bookmarking/tagging
M.grapple = {
  { '<leader>m', '<cmd>Grapple toggle<cr>', desc = 'Grapple toggle tag' },
  { '<leader>M', '<cmd>Grapple toggle_tags<cr>', desc = 'Grapple open tags window' },
  { '<leader>1', '<cmd>Grapple select index=1<cr>', desc = 'Grapple select 1' },
  { '<leader>2', '<cmd>Grapple select index=2<cr>', desc = 'Grapple select 2' },
  { '<leader>3', '<cmd>Grapple select index=3<cr>', desc = 'Grapple select 3' },
  { '<leader>4', '<cmd>Grapple select index=4<cr>', desc = 'Grapple select 4' },
}
M.todo_comments = {
  {
    ']t',
    function()
      require('todo-comments').jump_next()
    end,
    desc = 'Next TODO comment',
  },
  {
    '[t',
    function()
      require('todo-comments').jump_prev()
    end,
    desc = 'Previous TODO comment',
  },
  { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
  { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
}
M.dap = {
  {
    '<F5>',
    function()
      require('dap').continue()
    end,
    desc = 'DAP: Launch/Continue',
  },
  {
    '<F6>',
    function()
      require('dap').run(require('dap').configurations.gdscript[2])
    end,
    desc = 'DAP: Run Current Scene',
  },
  {
    '<F10>',
    function()
      require('dap').step_over()
    end,
    desc = 'DAP: Step Over',
  },
  {
    '<F11>',
    function()
      require('dap').step_into()
    end,
    desc = 'DAP: Step Into',
  },
  {
    '<F12>',
    function()
      require('dap').step_out()
    end,
    desc = 'DAP: Step Out',
  },
  {
    '<leader>b',
    function()
      require('dap').toggle_breakpoint()
    end,
    desc = 'DAP: Toggle Breakpoint',
  },
}

-- Add this for UFO folds
M.ufo = {
  {
    'zR',
    function()
      require('ufo').openAllFolds()
    end,
    desc = 'Open all folds',
  },
  {
    'zM',
    function()
      require('ufo').closeAllFolds()
    end,
    desc = 'Close all folds',
  },
  {
    'zr',
    function()
      require('ufo').openFoldsExceptKinds()
    end,
    desc = 'Open folds except kinds',
  },
  {
    'zm',
    function()
      require('ufo').closeFoldsWith()
    end,
    desc = 'Close folds with',
  },
  {
    'zp',
    function()
      require('ufo').peekFoldedLinesUnderCursor()
    end,
    desc = 'Peek fold',
  },
}

-- Add this as a data table for LSP (Notice there is no `mode` specified here, we handle that in plugins.lua)
M.lsp_attach = {
  { 'gd', vim.lsp.buf.definition, 'LSP: Go to Definition' },
  { 'gD', vim.lsp.buf.declaration, 'LSP: Go to Declaration' },
  { 'gr', vim.lsp.buf.references, 'LSP: References' },
  { 'gi', vim.lsp.buf.implementation, 'LSP: Implementation' },
  { 'K', vim.lsp.buf.hover, 'LSP: Hover Documentation' },
  { '<C-k>', vim.lsp.buf.signature_help, 'LSP: Signature Help' },
  { '<leader>rn', vim.lsp.buf.rename, 'LSP: Rename' },
  { '<leader>ca', vim.lsp.buf.code_action, 'LSP: Code Action', mode = { 'n', 'v' } },
  { '<leader>D', vim.lsp.buf.type_definition, 'LSP: Type Definition' },
}
M.telekasten = {
  { '<leader>k', mode = 'n', '<cmd>Telekasten panel<CR>', desc = 'Open Telekasten panel' },

  -- Most used functions
  { '<leader>kf', mode = 'n', '<cmd>Telekasten find_notes<CR>', desc = 'Find notes' },
  { '<leader>kg', mode = 'n', '<cmd>Telekasten search_notes<CR>', desc = 'Search notes' },
  { '<leader>kd', mode = 'n', '<cmd>Telekasten goto_today<CR>', desc = "Go to today's daily note" },
  { '<leader>kz', mode = 'n', '<cmd>Telekasten follow_link<CR>', desc = 'Follow link under cursor' },
  { '<leader>kn', mode = 'n', '<cmd>Telekasten new_note<CR>', desc = 'Create new note' },
  { '<leader>kt', mode = 'n', '<cmd>Telekasten new_templated_note<CR>', desc = 'Create new templated note' },
  { '<leader>kc', mode = 'n', '<cmd>Telekasten show_calendar<CR>', desc = 'Show calendar' },
  { '<leader>kb', mode = 'n', '<cmd>Telekasten show_backlinks<CR>', desc = 'Show backlinks for current note' },
  { '<leader>kI', mode = 'n', '<cmd>Telekasten insert_img_link<CR>', desc = 'Insert image link' },

  -- Call insert link automatically when we start typing a link
  { '[[', mode = 'i', '<cmd>Telekasten insert_link<CR>', desc = 'Insert note link' },
}

M.opencode = {
  { "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Opencode: Ask (@this)" },
  { "<C-x>", function() require("opencode").select() end, mode = { "n", "x" }, desc = "Opencode: Execute Action" },
  { "<C-.>", function() require("opencode").toggle() end, mode = { "n", "t" }, desc = "Opencode: Toggle Terminal" },
  { "go", function() return require("opencode").operator("@this ") end, mode = { "n", "x" }, desc = "Opencode: Add Range", expr = true },
  { "goo", function() return require("opencode").operator("@this ") .. "_" end, mode = "n", desc = "Opencode: Add Line", expr = true },
  { "<S-C-u>", function() require("opencode").command("session.half.page.up") end, mode = "n", desc = "Opencode: Scroll Up" },
  { "<S-C-d>", function() require("opencode").command("session.half.page.down") end, mode = "n", desc = "Opencode: Scroll Down" },
  -- Restore default increment/decrement shadowed by <C-a>/<C-x>
  { "+", "<C-a>", mode = { "n", "x" }, desc = "Increment", remap = false },
  { "-", "<C-x>", mode = { "n", "x" }, desc = "Decrement", remap = false },
}

M.trouble = {
  {
    '<leader>xx',
    '<cmd>Trouble diagnostics toggle<cr>',
    desc = 'Diagnostics (Trouble)',
  },
  {
    '<leader>xX',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    desc = 'Buffer Diagnostics (Trouble)',
  },
  {
    '<leader>cs',
    '<cmd>Trouble symbols toggle focus=false<cr>',
    desc = 'Symbols (Trouble)',
  },
  {
    '<leader>cl',
    '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
    desc = 'LSP Definitions / references / ... (Trouble)',
  },
  {
    '<leader>xL',
    '<cmd>Trouble loclist toggle<cr>',
    desc = 'Location List (Trouble)',
  },
  {
    '<leader>xQ',
    '<cmd>Trouble qflist toggle<cr>',
    desc = 'Quickfix List (Trouble)',
  },
}

M.flash = {
  {
    's',
    mode = { 'n', 'x', 'o' },
    function()
      require('flash').jump()
    end,
    desc = 'Flash',
  },
  {
    'S',
    mode = { 'n', 'x', 'o' },
    function()
      require('flash').treesitter()
    end,
    desc = 'Flash Treesitter',
  },
  {
    'r',
    mode = 'o',
    function()
      require('flash').remote()
    end,
    desc = 'Remote Flash',
  },
  {
    'R',
    mode = { 'o', 'x' },
    function()
      require('flash').treesitter_search()
    end,
    desc = 'Treesitter Search',
  },
  {
    '<c-s>',
    mode = { 'c' },
    function()
      require('flash').toggle()
    end,
    desc = 'Toggle Flash Search',
  },
}

M.codecompanion = {
  {
    '<leader>cc',
    mode = { 'n', 'v' },
    '<cmd>CodeCompanionChat<CR>',
    desc = 'AI chat',
  },
  {
    '<leader>ca',
    mode = { 'n', 'v' },
    '<cmd>CodeCompanionActions<CR>',
    desc = 'AI Actions',
  },
}
M.which_key = {
  {
    '<leader>?',
    function()
      require('which-key').show { global = false }
    end,
    desc = 'Buffer Local Keymaps (which-key)',
  },
}
M.gitsigns = {
  {
    '<leader>gh',
    function()
      require('gitsigns').preview_hunk()
    end,
    desc = 'Git: Preview Hunk',
  },
  {
    '<leader>gs',
    function()
      require('gitsigns').stage_hunk()
    end,
    desc = 'Git: Stage Hunk',
  },
  {
    '<leader>gr',
    function()
      require('gitsigns').reset_hunk()
    end,
    desc = 'Git: Reset Hunk',
  },
}

M.neogit = {
  { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Open Neogit (Status)' },
  { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Neogit: Commit' },
}

M.snacks = {
  {
    '<leader>tb',
    function()
      Snacks.terminal.toggle 'Bacon Builder'
    end,
    desc = 'Toggle Bacon Build Terminal',
  },
  {
    '<leader>sr',
    function()
      Snacks.picker.recent()
    end,
    desc = 'Search Recent',
  },
  {
    '<leader>n',
    function()
      ---@param opts? snacks.notifier.history
      Snacks.notifier.show_history(opts)
    end,
    desc = 'Notification History',
  },
  {
    '<leader>sc',
    function()
      Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
    end,
    desc = 'Search Config File',
  },
  {
    '<leader>sh',
    mode = { 'n' },
    function()
      Snacks.picker.help()
    end,
    desc = 'Search Help',
  },
  {
    '<leader>sf',
    mode = { 'n' },
    function()
      Snacks.picker.files()
    end,
    desc = 'Search Files',
  },
  {
    '<leader>sg',
    mode = { 'n' },
    function()
      Snacks.picker.grep()
    end,
    desc = 'Search Grep',
  },
  {
    '<leader>z',
    mode = 'n',
    function()
      Snacks.zen()
    end,
    desc = 'zen',
  },
}

local function snacks_smart_move(direction, method)
  return function()
    -- Check for snacks filetypes AND minifiles
    if vim.tbl_contains({ 'snacks_picker_list', 'snacks_picker_input', 'minifiles' }, vim.bo.filetype) then
      -- Try native vim window movement for these floating/split windows
      vim.cmd('wincmd ' .. direction)
    else
      -- Use smart-splits for everything else
      require('smart-splits')[method]()
    end
  end
end

M.smart_splits = {
  { '<C-h>', snacks_smart_move('h', 'move_cursor_left'), mode = { 'n', 't' }, desc = 'Move cursor left' },
  { '<C-j>', snacks_smart_move('j', 'move_cursor_down'), mode = { 'n', 't' }, desc = 'Move cursor down' },
  { '<C-k>', snacks_smart_move('k', 'move_cursor_up'), mode = { 'n', 't' }, desc = 'Move cursor up' },
  { '<C-l>', snacks_smart_move('l', 'move_cursor_right'), mode = { 'n', 't' }, desc = 'Move cursor right' },
}

return M
