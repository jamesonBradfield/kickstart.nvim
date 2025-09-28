return {
  'cbochs/grapple.nvim',
  dependencies = {
    'nvim-lualine/lualine.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    icons = false,
    scope = 'git',
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

    -- Labeled buffer group management
    {
      '<leader>gb',
      function()
        -- Create a new labeled buffer group
        vim.ui.input({ prompt = 'Enter group name: ' }, function(group_name)
          if group_name and group_name ~= '' then
            -- Create the scope with a custom resolver that returns the group name
            local grapple = require 'grapple'
            local success, err = pcall(function()
              grapple.define_scope {
                name = group_name,
                desc = 'Buffer group: ' .. group_name,
                fallback = 'cwd',
                cache = { event = 'BufEnter' },
                resolver = function()
                  -- Return the group name as both id and path
                  local id = group_name
                  local path = group_name
                  return id, path
                end,
              }

              -- Use this scope immediately
              grapple.use_scope(group_name)
              print('Created and switched to buffer group: ' .. group_name)
            end)

            if not success then
              print('Error creating group: ' .. (err or 'Unknown error'))
            end
          end
        end)
      end,
      desc = 'Create a new labeled buffer group',
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
