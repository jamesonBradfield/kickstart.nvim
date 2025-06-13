return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim', -- Optional: For using slash commands
    { 'stevearc/dressing.nvim', opts = {} }, -- Optional: Improves the default Neovim interfaces
    'saghen/blink.cmp',
  },
  config = function()
    -- Configure your LM Studio server IP here
    -- To find your server IP: run 'ipconfig' (Windows) or 'ifconfig' (Linux/Mac)
    -- Make sure LM Studio is set to "Allow network connections" in settings
    local lm_studio_host = '192.168.1.84' -- Change this to your LM Studio server IP
    local lm_studio_port = '1234'

    require('codecompanion').setup {
      strategies = {
        chat = {
          adapter = 'lmstudio_chat',
        },
        inline = {
          adapter = 'lmstudio_inline',
        },
        agent = {
          adapter = 'lmstudio_chat',
        },
      },
      adapters = {
        lmstudio_chat = function()
          return require('codecompanion.adapters').extend('openai', {
            name = 'lmstudio_chat',
            url = 'http://' .. lm_studio_host .. ':' .. lm_studio_port .. '/v1/chat/completions',
            env = {
              api_key = 'lm-studio', -- LM Studio doesn't require a real API key
            },
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              model = 'qwen3-32b', -- Your preferred chat model
              temperature = 0.7,
              max_tokens = 4096,
              stream = true,
            },

            schema = {
              model = {
                default = 'qwen3-32b',
              },
            },
          })
        end,
        lmstudio_inline = function()
          return require('codecompanion.adapters').extend('openai', {
            name = 'lmstudio_inline',
            url = 'http://' .. lm_studio_host .. ':' .. lm_studio_port .. '/v1/completions',
            env = {
              api_key = 'lm-studio',
            },
            headers = {
              ['Content-Type'] = 'application/json',
            },
            parameters = {
              model = 'qwen3-0.6b', -- Your preferred inline completion model
              temperature = 0.3,
              max_tokens = 256,
              stream = false,
            },
            -- Override for completion-style requests
            handlers = {
              form_parameters = function(self, params, messages)
                return {
                  model = self.parameters.model,
                  prompt = messages[#messages].content,
                  temperature = self.parameters.temperature,
                  max_tokens = self.parameters.max_tokens,
                  stream = self.parameters.stream,
                  stop = { '\n\n', '```' },
                }
              end,
              form_messages = function(self, messages)
                return messages
              end,
            },
            schema = {
              model = {
                default = 'qwen3-0.6b',
              },
            },
          })
        end,
      },
      prompt_library = {
        ['Custom C# Review'] = {
          strategy = 'chat',
          description = 'Review C# code with your coding preferences',
          opts = {
            mapping = '<Leader>cr',
            modes = { 'v' },
            slash_cmd = 'review',
            auto_submit = true,
          },
          prompts = {
            {
              role = 'system',
              content = function()
                return 'You are an expert C# developer. When reviewing code, prefer early returns over nested if statements, avoid verbs in boolean names, and suggest using GodotLogger methods (Info, Debug, Warning) instead of GD.Print(). Focus on single source of truth and separation of concerns.'
              end,
            },
            {
              role = 'user',
              content = function(context)
                return 'Please review this C# code and suggest improvements based on clean coding practices:\n\n```csharp\n' .. context.selection .. '\n```'
              end,
            },
          },
        },
      },
      display = {
        action_palette = {
          width = 95,
          height = 10,
        },
        chat = {
          window = {
            layout = 'vertical', -- float|vertical|horizontal|buffer
            width = 0.45,
            height = 0.8,
          },
          show_settings = false,
        },
      },
      opts = {
        log_level = 'DEBUG',
        send_code = true,
        use_default_actions = true,
        use_default_prompt_library = true,
      },
    }

    -- Key mappings
    vim.api.nvim_set_keymap('n', '<C-a>', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<C-a>', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<LocalLeader>Ct', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<LocalLeader>Ca', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

    -- Inline completion
    vim.api.nvim_set_keymap('n', '<LocalLeader>C', '<cmd>CodeCompanion<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('v', '<LocalLeader>C', '<cmd>CodeCompanion<cr>', { noremap = true, silent = true })
  end,
}
