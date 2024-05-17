return {
  'jamesonBradfield/vs-tasks.nvim',
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },

  keys = {
    {
      'ta',
      mode = { 'n', 'x', 'o' },
      function()
        require('telescope').extensions.vstask.tasks()
      end,
      desc = 'Tasks',
    },
    {
      'ti',
      mode = { 'n', 'x', 'o' },
      function()
        require('telescope').extensions.vstask.inputs()
      end,
      desc = 'Inputs',
    },
    {
      'th',
      mode = { 'n', 'x', 'o' },
      function()
        require('telescope').extensions.vstask.history()
      end,
      desc = 'Inputs',
    },
    {
      'tl',
      mode = { 'n', 'x', 'o' },
      function()
        require('telescope').extensions.vstask.launch()
      end,
      desc = 'Launch',
    },
  },

  opts = {
    cache_json_conf = true, -- don't read the json conf every time a task is ran
    cache_strategy = 'last', -- can be "most" or "last" (most used / last used)
    config_dir = '.vscode', -- directory to look for tasks.json and launch.json
    use_harpoon = true, -- use harpoon to auto cache terminals
    telescope_keys = { -- change the telescope bindings used to launch tasks
      vertical = '<C-v>',
      split = '<C-p>',
      tab = '<C-t>',
      current = '<CR>',
    },
    autodetect = { -- auto load scripts
      npm = 'on',
    },
    terminal = 'toggleterm',
    term_opts = {
      vertical = {
        direction = 'vertical',
        size = '80',
      },
      horizontal = {
        direction = 'horizontal',
        size = '10',
      },
      current = {
        direction = 'float',
      },
      tab = {
        direction = 'tab',
      },
    },
    json_parser = 'vim.fn.json.decode',
  },
}
