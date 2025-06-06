return {
  'cbochs/grapple.nvim',
  dependencies = {
    'nvim-lualine/lualine.nvim',
    'nvim-telescope/telescope.nvim', -- Will use this for better selection UI
  },
  opts = {
    icons = false,
    scope = 'git', -- Default scope when none is specified
  },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = 'Grapple',
  keys = {
    -- Keep your existing keybindings
    { '<leader>a', '<cmd>Grapple toggle<cr>', desc = 'Grapple toggle tag' },
    { '<leader><S-a>', '<cmd>Grapple toggle_tags<cr>', desc = 'Grapple open tags window' },
    { '<S-k>', '<cmd>Grapple cycle_tags next<cr>', desc = 'Grapple cycle next tag' },
    { '<S-j>', '<cmd>Grapple cycle_tags prev<cr>', desc = 'Grapple cycle previous tag' },
    { '<A-a>', '<cmd>Grapple select index=1<cr>', desc = 'Grapple Select index 1' },
    { '<A-s>', '<cmd>Grapple select index=2<cr>', desc = 'Grapple Select index 2' },
    { '<A-d>', '<cmd>Grapple select index=3<cr>', desc = 'Grapple Select index 3' },
    { '<A-f>', '<cmd>Grapple select index=4<cr>', desc = 'Grapple Select index 4' },
    { '<A-g>', '<cmd>Grapple select index=5<cr>', desc = 'Grapple Select index 5' },
    { '<A-h>', '<cmd>Grapple select index=6<cr>', desc = 'Grapple Select index 6' },
    { '<A-j>', '<cmd>Grapple select index=7<cr>', desc = 'Grapple Select index 7' },
    { '<A-k>', '<cmd>Grapple select index=8<cr>', desc = 'Grapple Select index 8' },
    { '<A-l>', '<cmd>Grapple select index=9<cr>', desc = 'Grapple Select index 9' },
    { '<A-;>', '<cmd>Grapple select index=10<cr>', desc = 'Grapple Select index 10' },

    -- Dynamic scope management
    { '<leader>gs', '<cmd>Grapple open_scopes<cr>', desc = 'Grapple show all scopes' },
    { '<leader>gl', '<cmd>Grapple open_loaded<cr>', desc = 'Grapple show loaded scopes' },

    -- Create and tag in a dynamic scope with autocompletion
    {
      '<leader>gt',
      function()
        -- Use telescope for scope selection with autocompletion
        local has_telescope, telescope = pcall(require, 'telescope.builtin')

        if has_telescope then
          -- Get list of existing scopes
          local scope_ids = require('grapple').scope_ids()
          local scopes = {}

          -- Add existing scopes to the list
          for _, scope_id in ipairs(scope_ids) do
            table.insert(scopes, scope_id)
          end

          -- If there are existing scopes, show telescope picker
          if #scopes > 0 then
            vim.ui.select(scopes, {
              prompt = 'Select or create scope:',
              telescope = { initial_mode = 'insert' }, -- Start in insert mode for typing new scopes
              format_item = function(item)
                return item
              end,
            }, function(scope_name)
              if scope_name and scope_name ~= '' then
                vim.cmd('Grapple tag scope=' .. scope_name)
                print('Tagged in scope: ' .. scope_name)
              end
            end)
          else
            -- If no existing scopes, use input prompt
            vim.ui.input({ prompt = 'Enter scope name: ' }, function(scope_name)
              if scope_name and scope_name ~= '' then
                vim.cmd('Grapple tag scope=' .. scope_name)
                print('Tagged in scope: ' .. scope_name)
              end
            end)
          end
        else
          -- Fallback to regular input if telescope not available
          vim.ui.input({ prompt = 'Enter scope name: ' }, function(scope_name)
            if scope_name and scope_name ~= '' then
              vim.cmd('Grapple tag scope=' .. scope_name)
              print('Tagged in scope: ' .. scope_name)
            end
          end)
        end
      end,
      desc = 'Tag in custom scope with prediction',
    },

    -- Open tags for a dynamic scope with autocompletion
    {
      '<leader>go',
      function()
        local scope_ids = require('grapple').scope_ids()
        if #scope_ids > 0 then
          vim.ui.select(scope_ids, {
            prompt = 'Select scope to open:',
          }, function(scope_name)
            if scope_name and scope_name ~= '' then
              vim.cmd('Grapple open_tags scope=' .. scope_name)
            end
          end)
        else
          print 'No scopes available'
        end
      end,
      desc = 'Open custom scope tags',
    },

    -- Change to a dynamic scope with autocompletion
    {
      '<leader>gc',
      function()
        local scope_ids = require('grapple').scope_ids()
        if #scope_ids > 0 then
          vim.ui.select(scope_ids, {
            prompt = 'Change to scope:',
          }, function(scope_name)
            if scope_name and scope_name ~= '' then
              vim.cmd('Grapple change_scope ' .. scope_name)
              print('Changed to scope: ' .. scope_name)
            end
          end)
        else
          print 'No scopes available'
        end
      end,
      desc = 'Change to custom scope',
    },

    -- Quick delete/reset a scope with autocompletion
    {
      '<leader>gd',
      function()
        local scope_ids = require('grapple').scope_ids()
        if #scope_ids > 0 then
          vim.ui.select(scope_ids, {
            prompt = 'Delete scope:',
          }, function(scope_name)
            if scope_name and scope_name ~= '' then
              vim.cmd('Grapple reset_tags scope=' .. scope_name)
              print('Deleted scope: ' .. scope_name)
            end
          end)
        else
          print 'No scopes available'
        end
      end,
      desc = 'Delete custom scope',
    },

    -- Quick scope cycling (if you work with multiple scopes)
    {
      '<leader>gn',
      function()
        vim.cmd 'Grapple cycle_scopes next'
      end,
      desc = 'Cycle to next scope',
    },

    {
      '<leader>gp',
      function()
        vim.cmd 'Grapple cycle_scopes prev'
      end,
      desc = 'Cycle to previous scope',
    },
  },
  config = function(_, opts)
    require('grapple').setup(opts)

    -- Add telescope integration if available
    if pcall(require, 'telescope') then
      require('telescope').load_extension 'grapple'
    end
  end,
}
