local km = require 'keymaps'

km.map({'n','i'},'<C-f>','<cmd>Oil --float<CR>')
----------------------------------
-- General Mappings
----------------------------------
-- Clear search highlighting
km.map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Custom paste behavior
km.map('n', 'p', 'P', { desc = 'Paste' })

-- Change directory to current file's parent directory
km.map('n', '<leader>cd', '<Cmd>cd %:p:h<CR>', { desc = 'Change directory to current file' })

-- Visual mode adjustments
km.map('x', 'C', '')
km.map('x', 'c', '')

----------------------------------
-- Diagnostic Mappings
----------------------------------
-- Navigation (keeping Vim-like navigation patterns)
km.map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
km.map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

-- Diagnostic operations (standardized with <leader>d prefix)
km.map('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic errors' })
km.map('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })

----------------------------------
-- LSP Mappings
-- TODO: look over these and double check how to better integrate lspsaga or if there is an easier way to add the features you like from it.
--
----------------------------------
-- Standardized with <leader>l prefix
km.map('n', '<leader>la', function()
  vim.lsp.buf.code_action()
end, { desc = 'LSP code actions' })

km.map('n', '<leader>lh', function()
  vim.lsp.buf.hover()
end, { desc = 'Show hover documentation' })

km.map('n', '<leader>ld', function()
  vim.lsp.buf.definition()
end, { desc = 'Go to definition' })

km.map('n', '<leader>lD', function()
  vim.lsp.buf.declaration()
end, { desc = 'Go to declaration' })

km.map('n', '<leader>li', function()
  vim.lsp.buf.implementation()
end, { desc = 'Go to implementation' })

km.map('n', '<leader>lr', function()
  vim.lsp.buf.references()
end, { desc = 'Find references' })

km.map('n', '<leader>lt', function()
  vim.lsp.buf.type_definition()
end, { desc = 'Go to type definition' })

km.map('n', '<leader>ln', function()
  vim.lsp.buf.rename()
end, { desc = 'Rename symbol' })
-- Format code (updated for consistency)
km.map('n', '<leader>lf', function()
  vim.lsp.buf.format {
    timeout_ms = 2000,
  }
end, { desc = 'Format code' })
----------------------------------
-- Tab Navigation
----------------------------------
km.map('n', '<S-k>', ':tabnext<CR>', { silent = true, desc = 'Next tab' })
km.map('n', '<S-j>', ':tabprevious<CR>', { silent = true, desc = 'Previous tab' })
km.map('n', '<A-c>', ':tabclose<CR>', { silent = true, desc = 'Close tab' })
km.map('n', '<C-S-k>', ':tabmove +1<CR>', { silent = true, desc = 'Move tab right' })
km.map('n', '<C-S-j>', ':tabmove -1<CR>', { silent = true, desc = 'Move tab left' })

----------------------------------
-- Window Navigation
----------------------------------
-- Keep standard Vim window navigation unchanged
km.map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
km.map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
km.map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
km.map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
km.map('n', '<C-s>', '<cmd>vsplit<CR>', { desc = 'vertical split' })
km.map('n', '<C-h>', '<cmd>split<CR>', { desc = 'horizontal split' })
----------------------------------
-- Terminal Mappings
----------------------------------
km.map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

----------------------------------
-- Command Input
----------------------------------
-- Simplified to just one command input mapping
km.map('n', ';', '<Cmd>lua vim.fn.input(":")<CR>', { silent = true, desc = 'Command input' })

----------------------------------
-- Code Execution
----------------------------------
-- Standardized with <leader>x prefix
km.map('n', '<leader>xl', '<cmd>.lua<CR>', { desc = 'Execute the current line' })
km.map('n', '<leader>xf', '<cmd>source %<CR>', { desc = 'Execute the current file' })

----------------------------------
-- Telekasten Notes
----------------------------------
km.map('n', '<leader>k<space>', '<cmd>Telekasten panel<CR>')
km.map('n', '<leader>kf', '<cmd> find_notes<CR>', { desc = 'Tele[k]asten [f]ind Notes' })
km.map('n', '<leader>kg', '<cmd>Telekasten search_notes<CR>', { desc = 'Tele[k]asten [g]rep Notes' })
km.map('n', '<leader>kD', '<cmd>Telekasten goto_today<CR>', { desc = 'Tele[k]asten To[D]ay' })
km.map('n', '<leader>kv', '<cmd>lua _G.open_telekasten_daily_split()<CR>', { desc = 'Tele[k]asten daily in [v]split' })
km.map('n', '<leader>kl', '<cmd>Telekasten follow_link<CR>', { desc = 'Tele[k]asten Follow [l]ink' })
km.map('n', '<leader>kn', '<cmd>Telekasten new_note<CR>', { desc = 'Tele[k]asten [n]ew note' })
km.map('n', '<leader>kt', '<cmd>Telekasten new_templated_note<CR>', { desc = 'Tele[k]asten new [t]emplated note' })
km.map('n', '<leader>kc', '<cmd>Telekasten show_calendar<CR>', { desc = 'Tele[k]asten Show [c]alendar' })
km.map('n', '<leader>kb', '<cmd>Telekasten show_backlinks<CR>', { desc = 'Tele[k]asten [b]acklinks' })
km.map('n', '<leader>ki', '<cmd>Telekasten insert_img_link<CR>', { desc = 'Tele[k]asten [i]nsert Image Link' })
km.map('n', '<leader>kd', '<cmd>Telekasten toggle_todo<CR>', { desc = 'Tele[k]asten toggle to[d]o' })

---------------------------------
-- GdUnit
---------------------------------
-- Using <leader>g prefix for GdUnit (g for Godot/GdUnit)
km.map('n', '<leader>uc', function()
  require('gdunit4').create_test()
end, { desc = 'Create GdUnit Test' })

km.map('n', '<leader>ur', function()
  require('gdunit4').run_test()
end, { desc = 'Run GdUnit Test' })

km.map('n', '<leader>ua', function()
  require('gdunit4').run_all_tests()
end, { desc = 'Run All GdUnit Tests' })

km.map('n', '<leader>ud', function()
  require('gdunit4').debug_test()
end, { desc = 'Debug GdUnit Test' })

-- Configuration Keymaps
km.map('n', '<leader>urc', function()
  vim.ui.input({ prompt = 'Config file (leave empty for default): ' }, function(input)
    require('gdunit4').run_with_config(input)
  end)
end, { desc = 'Run Tests with Config' })

km.map('n', '<leader>ui', function()
  vim.ui.input({ prompt = 'Test to ignore: ' }, function(input)
    if input then
      require('gdunit4').add_ignored_test(input)
    end
  end)
end, { desc = 'Ignore Test' })
----------------------------------
-- SnipRun
----------------------------------
km.map('v', '<leader>r', '<Plug>SnipRun', { silent = true })
km.map('n', '<leader>r', '<Plug>SnipRun', { silent = true })
km.map('n', '<leader>f', '<Plug>SnipRunOperator', { silent = true })
----------------------------------
-- Flash Navigation
----------------------------------
local M = {}

function M.flash()
  return {
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
end

function M.snacks()
  return {
    -- Top Pickers & Explorer
    {
      '<leader><space>',
      function()
        Snacks.picker.smart()
      end,
      desc = 'Smart Find Files',
    },
    {
      '<leader>,',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>:',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    {
      '<leader>n',
      function()
        Snacks.picker.notifications()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>fb',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Buffers',
    },
    {
      '<leader>fc',
      function()
        Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Find Config File',
    },
    {
      '<leader>ff',
      function()
        Snacks.picker.files()
      end,
      desc = 'Find Files',
    },
    {
      '<leader>fg',
      function()
        Snacks.picker.git_files()
      end,
      desc = 'Find Git Files',
    },
    {
      '<leader>fp',
      function()
        Snacks.picker.projects()
      end,
      desc = 'Projects',
    },
    {
      '<leader>fr',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Recent',
    },
    -- git
    {
      '<leader>gb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git Branches',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = 'Git Log',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = 'Git Log Line',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git Status',
    },
    {
      '<leader>gS',
      function()
        Snacks.picker.git_stash()
      end,
      desc = 'Git Stash',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = 'Git Diff (Hunks)',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = 'Git Log File',
    },
    -- Grep
    {
      '<leader>sb',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sB',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = 'Grep Open Buffers',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = 'Visual selection or word',
      mode = { 'n', 'x' },
    },
    -- search
    {
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      desc = 'Registers',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.search_history()
      end,
      desc = 'Search History',
    },
    {
      '<leader>sa',
      function()
        Snacks.picker.autocmds()
      end,
      desc = 'Autocmds',
    },
    {
      '<leader>sb',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    {
      '<leader>sC',
      function()
        Snacks.picker.commands()
      end,
      desc = 'Commands',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Diagnostics',
    },
    {
      '<leader>sD',
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = 'Buffer Diagnostics',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = 'Help Pages',
    },
    {
      '<leader>sH',
      function()
        Snacks.picker.highlights()
      end,
      desc = 'Highlights',
    },
    {
      '<leader>si',
      function()
        Snacks.picker.icons()
      end,
      desc = 'Icons',
    },
    {
      '<leader>sj',
      function()
        Snacks.picker.jumps()
      end,
      desc = 'Jumps',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = 'Keymaps',
    },
    {
      '<leader>sl',
      function()
        Snacks.picker.loclist()
      end,
      desc = 'Location List',
    },
    {
      '<leader>sm',
      function()
        Snacks.picker.marks()
      end,
      desc = 'Marks',
    },
    {
      '<leader>sM',
      function()
        Snacks.picker.man()
      end,
      desc = 'Man Pages',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.lazy()
      end,
      desc = 'Search for Plugin Spec',
    },
    {
      '<leader>sq',
      function()
        Snacks.picker.qflist()
      end,
      desc = 'Quickfix List',
    },
    {
      '<leader>sR',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.undo()
      end,
      desc = 'Undo History',
    },
    {
      '<leader>uC',
      function()
        Snacks.picker.colorschemes()
      end,
      desc = 'Colorschemes',
    },
    -- LSP
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = 'Goto Definition',
    },
    {
      'gD',
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = 'Goto Declaration',
    },
    {
      'gr',
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = 'References',
    },
    {
      'gI',
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = 'Goto Implementation',
    },
    {
      'gy',
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = 'Goto T[y]pe Definition',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = 'LSP Symbols',
    },
    {
      '<leader>sS',
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = 'LSP Workspace Symbols',
    },
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle Zen Mode',
    },
    {
      '<leader>Z',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Toggle Zoom',
    },
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
    {
      '<leader>n',
      function()
        Snacks.notifier.show_history()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>cR',
      function()
        Snacks.rename.rename_file()
      end,
      desc = 'Rename File',
    },
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      desc = 'Git Browse',
    },
    {
      '<leader>gb',
      function()
        Snacks.git.blame_line()
      end,
      desc = 'Git Blame Line',
    },
    {
      '<leader>gf',
      function()
        Snacks.lazygit.log_file()
      end,
      desc = 'Lazygit Current File History',
    },
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>gl',
      function()
        Snacks.lazygit.log()
      end,
      desc = 'Lazygit Log (cwd)',
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<c-/>',
      function()
        Snacks.terminal()
      end,
      desc = 'Toggle Terminal',
    },
    {
      '<c-_>',
      function()
        Snacks.terminal()
      end,
      desc = 'which_key_ignore',
    },
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = { 'n', 't' },
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = { 'n', 't' },
    },
    {
      '<leader>N',
      desc = 'Neovim News',
      function()
        Snacks.win {
          file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = 'yes',
            statuscolumn = ' ',
            conceallevel = 3,
          },
        }
      end,
    },
  }
end

function M.trouble()
  return {
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
end

function M.snacks_picker()
  return {
    ['l'] = function(_)
      -- Get all pickers first
      local pickers = require('snacks.picker').get { source = 'explorer' }
      if not pickers or #pickers == 0 then
        vim.notify('No explorer picker found', vim.log.levels.ERROR)
        return
      end

      -- Get the first (and should be only) explorer picker
      local picker = pickers[1]
      if not picker then
        vim.notify('Could not get picker instance', vim.log.levels.ERROR)
        return
      end

      -- Try to get current item safely
      local ok, item = pcall(function()
        return picker:current { resolve = true }
      end)
      if not ok or not item then
        vim.notify('No item selected', vim.log.levels.WARN)
        return
      end

      -- Handle directory vs file
      if item.dir == true then
        pcall(function()
		  picker:action 'explorer_focus'
          picker:action 'confirm'
        end)
        return
      end

      -- Handle file
      pcall(function()
        picker:close()
        vim.cmd('tabedit' .. vim.fn.fnameescape(item._path))
      end)
    end,
    ['h'] = function()
      -- Get all pickers first
      local pickers = require('snacks.picker').get { source = 'explorer' }
      if not pickers or #pickers == 0 then
        vim.notify('No explorer picker found', vim.log.levels.ERROR)
        return
      end

      -- Get the first (and should be only) explorer picker
      local picker = pickers[1]
      if not picker then
        vim.notify('Could not get picker instance', vim.log.levels.ERROR)
        return
      end

      -- Try to get current item safely
      local ok, item = pcall(function()
        return picker:current { resolve = true }
      end)
      if not ok or not item then
        vim.notify('No item selected', vim.log.levels.WARN)
        return
      end

      pcall(function()
        picker:action 'explorer_close'
        picker:action 'explorer_up'
		picker:action 'explorer_update'
      end)
    end,
    ['a'] = 'explorer_add',
    ['d'] = 'explorer_del',
    ['r'] = 'explorer_rename',
    ['c'] = 'explorer_copy',
    ['m'] = 'explorer_move',
    ['o'] = 'explorer_open',
    ['P'] = 'toggle_preview',
    ['y'] = { 'explorer_yank', mode = { 'n', 'x' } },
    ['p'] = 'explorer_paste',
    ['u'] = 'explorer_update',
    ['<c-c>'] = 'tcd',
    ['<leader>/'] = 'picker_grep',
    ['<c-t>'] = 'terminal',
    ['.'] = 'explorer_focus',
    ['I'] = 'toggle_ignored',
    ['H'] = 'toggle_hidden',
    ['Z'] = 'explorer_close_all',
    [']g'] = 'explorer_git_next',
    ['[g'] = 'explorer_git_prev',
    [']d'] = 'explorer_diagnostic_next',
    ['[d'] = 'explorer_diagnostic_prev',
    [']w'] = 'explorer_warn_next',
    ['[w'] = 'explorer_warn_prev',
    [']e'] = 'explorer_error_next',
    ['[e'] = 'explorer_error_prev',
  }
end

return M
