return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
    { 'stevearc/dressing.nvim', opts = {} },
    'saghen/blink.cmp',
    'folke/snacks.nvim', -- for floating windows
  },
  lazy = false,

  keys = {
    { '<leader>cc', '<cmd>CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'CodeCompanion Actions' },
    {
      '<leader>sq',
      function()
        require('search-assistant').search_from_selection()
      end,
      mode = 'v',
      desc = 'Search Assistant',
    },
  },

  config = function()
    local lm_studio = {
      host = '192.168.1.84',
      port = '1234',
    }

    require('codecompanion').setup {
      strategies = {
        chat = { adapter = 'lmstudio' },
        inline = { adapter = 'lmstudio_small' },
      },

      adapters = {
        lmstudio = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            name = 'lmstudio',
            env = {
              url = string.format('http://%s:%s', lm_studio.host, lm_studio.port),
              chat_url = '/v1/chat/completions',
            },
            schema = {
              model = { default = 'qwen/qwen3-4b-2507' },
              temperature = { default = 0.3 },
              max_completion_tokens = { default = 32768 },
            },
            features = {
              text = true,
              tools = true,
              vision = false,
            },
          })
        end,

        lmstudio_small = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            name = 'lmstudio_small',
            env = {
              url = string.format('http://%s:%s', lm_studio.host, lm_studio.port),
              chat_url = '/v1/completions',
            },
            schema = {
              model = { default = 'qwen/qwen3-4b-2507' },
              temperature = { default = 0.3 },
              max_completion_tokens = { default = 256 },
            },
          })
        end,

        -- New adapter for search query generation
        search_query_gen = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            name = 'search_query_gen',
            env = {
              url = string.format('http://%s:%s', lm_studio.host, lm_studio.port),
              chat_url = '/v1/chat/completions',
            },
            schema = {
              model = { default = 'qwen/qwen3-4b-2507' },
              temperature = { default = 0.1 }, -- Lower for more focused queries
              max_completion_tokens = { default = 128 },
            },
          })
        end,
      },
    }
  end,
}
