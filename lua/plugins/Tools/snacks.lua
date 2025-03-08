-- Enhanced snacks.lua with tab-aware explorer focus handling
-- Open explorer in every tab and trouble when diagnostics are present

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    config = function(_, opts)
      local snacks = require 'snacks'

      -- Single source of truth for explorer width and state
      _G.pde_state = {
        explorer_active = false,
        trouble_active = false,
        explorer_width = 40, -- Default width
      }

      -- Helper functions for explorer management
      local function get_explorer_picker()
        -- Get explorer for current tab only
        local pickers = snacks.picker.get { source = 'explorer', tab = true }
        return pickers and pickers[1] or nil
      end

      local function open_explorer()
        -- Skip for special buffers
        local current_buf = vim.api.nvim_get_current_buf()
        if vim.bo[current_buf].filetype == 'dashboard' or vim.bo[current_buf].buftype == 'nofile' then
          return false
        end

        -- Check if explorer already exists in current tab
        if get_explorer_picker() then
          return true
        end

        -- Get directory from current file or fallback to cwd
        local file_path = vim.api.nvim_buf_get_name(current_buf)
        local dir_path = file_path ~= '' and vim.fn.fnamemodify(file_path, ':h') or vim.fn.getcwd()

        -- Open explorer in current tab
        local ok = pcall(function()
          snacks.picker.pick('explorer', { cwd = dir_path })
        end)

        -- Update state after opening
        vim.defer_fn(function()
          if _G.update_state then
            _G.update_state()
          end
        end, 50)
        return ok
      end

      local function focus_current_file()
        local explorer = get_explorer_picker()
        if not explorer then
          return
        end

        local file_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        if file_path ~= '' then
          snacks.explorer.reveal { file = file_path }
        end
      end

      local function toggle_explorer_focus()
        -- First, let's get a reference to the explorer picker
        local explorer = get_explorer_picker()

        if not explorer then
          -- No explorer - open it
          open_explorer()

          -- Focus after creation
          vim.defer_fn(function()
            -- Find snacks_picker_list window
            local wins = vim.api.nvim_list_wins()
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.api.nvim_buf_is_valid(buf) then
                local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
                if ft == 'snacks_picker_list' then
                  vim.api.nvim_set_current_win(win)
                  break
                end
              end
            end
          end, 100)
          return
        end

        -- Now we need to find the explorer window ID
        local explorer_win_id = nil

        -- Find window with picker filetype
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
            if ft == 'snacks_picker_list' then
              explorer_win_id = win
              break
            end
          end
        end

        if not explorer_win_id then
          -- Couldn't find the window, try to reopen
          open_explorer()
          return
        end

        -- Check if we're currently focused on the explorer
        local current_win = vim.api.nvim_get_current_win()

        if current_win == explorer_win_id then
          -- Currently in explorer, jump to a normal window
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= explorer_win_id and vim.api.nvim_win_is_valid(win) then
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == '' then
                vim.api.nvim_set_current_win(win)
                return
              end
            end
          end
        else
          -- Not in explorer, focus it
          if vim.api.nvim_win_is_valid(explorer_win_id) then
            vim.api.nvim_set_current_win(explorer_win_id)
          end
        end
      end

      -- Function to adjust Trouble's position based on explorer state
      local function update_trouble_position()
        local explorer_active = _G.pde_state.explorer_active
        local explorer_width = _G.pde_state.explorer_width or 40

        -- Find all Trouble windows in the current tab
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_is_valid(buf) then
              local is_trouble = vim.bo[buf].filetype == 'Trouble' or (vim.b[buf] and vim.b[buf].trouble)

              if is_trouble and explorer_active then
                -- Apply padding via signcolumn
                vim.api.nvim_win_call(win, function()
                  vim.opt_local.winhighlight = 'Normal:TroubleNormal'
                  vim.opt_local.signcolumn = 'yes:' .. math.floor(explorer_width / 4)
                end)
              end
            end
          end
        end
      end

      -- Update global state for tabline and Trouble
      local function update_state()
        -- Get explorer state
        local explorer = get_explorer_picker()
        _G.pde_state.explorer_active = explorer ~= nil

        -- Update explorer width if active
        if explorer and explorer.list then
          local win_id = nil
          pcall(function()
            if type(explorer.list.win) == 'number' then
              win_id = explorer.list.win
            end
          end)

          if win_id and vim.api.nvim_win_is_valid(win_id) then
            _G.pde_state.explorer_width = vim.api.nvim_win_get_width(win_id)
          end
        end

        -- Check if trouble is open
        _G.pde_state.trouble_active = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_is_valid(buf) and vim.b[buf] and vim.b[buf].trouble then
              _G.pde_state.trouble_active = true
              break
            end
          end
        end

        -- Update trouble position and tabline
        update_trouble_position()
        vim.cmd 'redrawtabline'
      end

      -- Make update_state available globally
      _G.update_state = update_state

      -- Make open_explorer available globally for Trouble integration
      _G.open_explorer = open_explorer

      -- Open trouble for diagnostics
      local function open_trouble_if_needed()
        local buffer = vim.api.nvim_get_current_buf()
        local diags = vim.diagnostic.get(buffer)
        if diags and #diags > 0 then
          -- Ensure explorer is open first
          if not get_explorer_picker() then
            open_explorer()
            vim.defer_fn(function()
              vim.cmd 'Trouble diagnostics'
              vim.defer_fn(_G.update_state, 10)
            end, 100)
          else
            vim.cmd 'Trouble diagnostics'
            vim.defer_fn(_G.update_state, 10)
          end
        end
      end

      -- Explorer keys - merge standard and custom actions
      local explorer_keys = {
        -- Open folders with l, go up with h
        ['l'] = function(_)
          local picker = get_explorer_picker()
          if not picker then
            return
          end

          local ok, item = pcall(function()
            return picker:current { resolve = true }
          end)

          if not ok or not item then
            return
          end

          if item.dir == true then
            pcall(function()
              picker:action 'explorer_focus'
              picker:action 'confirm'
            end)
          else
            -- Open file in new tab
            pcall(function()
              vim.cmd('tabedit ' .. vim.fn.fnameescape(item._path))
            end)
          end
        end,

        ['h'] = function()
          local picker = get_explorer_picker()
          if picker then
            pcall(function()
              picker:action 'explorer_close'
              picker:action 'explorer_up'
            end)
          end
        end,

        -- Standard explorer actions
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

        -- Custom actions
        ['<C-f>'] = toggle_explorer_focus,
        ['<leader>f'] = focus_current_file,
      }

      -- Update explorer configuration with our keys
      if opts.picker and opts.picker.sources and opts.picker.sources.explorer then
        opts.picker.sources.explorer.win = opts.picker.sources.explorer.win or {}
        opts.picker.sources.explorer.win.list = opts.picker.sources.explorer.win.list or {}
        opts.picker.sources.explorer.win.list.keys = vim.tbl_deep_extend('force', opts.picker.sources.explorer.win.list.keys or {}, explorer_keys)
      end

      -- Initialize snacks with updated configuration
      snacks.setup(opts)

      -- Set up global functionality after everything is loaded
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Set up debug helpers
          _G.dd = function(...)
            snacks.debug.inspect(...)
          end
          _G.bt = function()
            snacks.debug.backtrace()
          end
          vim.print = _G.dd

          -- Set up toggle mappings
          pcall(function()
            snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>sts'
            snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>stw'
            snacks.toggle.diagnostics():map '<leader>std'
            snacks.toggle.line_number():map '<leader>stl'
            snacks.toggle.treesitter():map '<leader>stT'
            snacks.toggle.dim():map '<leader>stD'
          end)

          -- Load custom tabline
          pcall(function()
            require('custom_tabline').setup()
          end)

          -- Map global keybindings
          vim.keymap.set('n', '<C-f>', toggle_explorer_focus, {
            desc = 'Toggle focus between Explorer and Editor',
            silent = true,
            noremap = true,
          })

          vim.keymap.set('n', '<leader>fc', focus_current_file, {
            desc = 'Focus current file in explorer',
            silent = true,
            noremap = true,
          })

          -- Create autocommand group
          local group = vim.api.nvim_create_augroup('PDEMinimal', { clear = true })

          -- Register all events in a cleaner way
          local events = {
            {
              'VimEnter',
              function()
                if vim.fn.argc() == 0 then
                  vim.defer_fn(open_explorer, 100)
                end
              end,
            },

            {
              'TabNew',
              function()
                vim.defer_fn(open_explorer, 100)
              end,
            },

            {
              'BufEnter',
              function()
                local bufnr = vim.api.nvim_get_current_buf()
                if vim.bo[bufnr].buftype ~= '' or vim.bo[bufnr].filetype == 'explorer' then
                  return
                end

                -- Ensure explorer is open and focus current file
                if not get_explorer_picker() then
                  vim.defer_fn(open_explorer, 50)
                end

                vim.defer_fn(function()
                  local explorer = get_explorer_picker()
                  if explorer then
                    -- Check if not focused
                    local is_focused = false
                    pcall(function()
                      is_focused = explorer.is_focused and explorer:is_focused()
                    end)

                    if not is_focused then
                      focus_current_file()
                    end
                  end

                  _G.update_state()
                end, 100)
              end,
            },

            {
              'LspAttach',
              function()
                vim.defer_fn(open_trouble_if_needed, 1000)
              end,
            },

            {
              'DiagnosticChanged',
              function()
                vim.defer_fn(open_trouble_if_needed, 500)
              end,
            },

            {
              { 'WinEnter', 'WinResized', 'TabEnter' },
              function()
                vim.defer_fn(_G.update_state, 10)
              end,
            },
          }

          -- Register all events
          for _, event in ipairs(events) do
            vim.api.nvim_create_autocmd(event[1], {
              callback = event[2],
              group = group,
            })
          end

          -- Initial state update
          _G.update_state()
        end,
      })
    end,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        sections = {
          { section = 'header' },
          { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
          { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
          { section = 'startup' },
        },
      },
      layout = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      explorer = { enabled = true, replace_netrw = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            finder = 'explorer',
            sort = { fields = { 'sort' } },
            supports_live = true,
            tree = true,
            watch = true,
            diagnostics = true,
            git_status = true,
            git_untracked = true,
            follow_file = true,
            focus = 'list',
            auto_close = false,
            jump = { close = false },
            layout = {
              preset = 'sidebar',
              preview = false,
              width = 40,
            },
          },
        },
      },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      dim = {
        scope = { min_size = 5, max_size = 20, siblings = true },
        animate = {
          enabled = vim.fn.has 'nvim-0.10' == 1,
          easing = 'outQuad',
          duration = { step = 20, total = 300 },
        },
        filter = function(buf)
          return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ''
        end,
      },
      zen = {
        toggles = { dim = true },
        win = {
          style = 'zen',
          backdrop = { transparent = true, blend = 30 },
          border = 'rounded',
          width = 0,
          resize = true,
        },
        show = { statusline = true, tabline = true },
      },
    },
    keys = function()
      local mappings = require 'mappings'
      return mappings.snacks()
    end,
  },
  {
    'folke/trouble.nvim',
    opts = {
      position = 'bottom',
      height = 10,
      icons = {
        error = '',
        warning = '',
        hint = '',
        information = '',
        other = '',
      },
      auto_preview = false,
      auto_close = false,
      auto_fold = false,
      use_diagnostic_signs = true,
    },
    config = function(_, opts)
      -- Load Trouble with default options
      require('trouble').setup(opts)

      -- Set up custom highlight for Trouble when used with explorer
      vim.cmd [[hi TroubleNormal guibg=#191919]]

      -- Define custom sign for padding
      vim.fn.sign_define('TroublePadding', { text = ' ', texthl = 'TroubleNormal' })

      -- Update trouble positioning when opened or closed
      for _, event in ipairs { 'TroubleOpen', 'TroubleClose' } do
        vim.api.nvim_create_autocmd('User', {
          pattern = event,
          callback = function()
            if _G.update_state then
              vim.defer_fn(_G.update_state, 10)
            end

            -- For close event, ensure explorer is still open
            if event == 'TroubleClose' then
              vim.defer_fn(function()
                -- Try to reopen explorer if it's not present
                if not require('snacks.picker').get({ source = 'explorer', tab = true })[1] then
                  _G.open_explorer()
                end
              end, 50)
            end
          end,
        })
      end
    end,
    cmd = 'Trouble',
    keys = function()
      local mappings = require 'mappings'
      return mappings.trouble()
    end,
  },
}
