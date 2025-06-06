return {
  'natecraddock/workspaces.nvim',
  config = function()
    require('workspaces').setup {
      hooks = {
        open_pre = {
          -- Clear grapple tags when switching workspaces
          function()
            require('grapple').reset()
          end,
        },
        open = {
          -- Auto-load system-specific grapple tags
          function()
            vim.cmd 'Grapple load'
          end,
        },
      },
    }
  end,
  keys = {
    { '<leader>wa', '<cmd>WorkspacesAdd<cr>', desc = 'Add workspace' },
    { '<leader>wr', '<cmd>WorkspacesRemove<cr>', desc = 'Remove workspace' },
    { '<leader>wo', '<cmd>WorkspacesOpen<cr>', desc = 'Open workspace' },
    { '<leader>wl', '<cmd>WorkspacesList<cr>', desc = 'List workspaces' },
  },
}
