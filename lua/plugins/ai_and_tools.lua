local keys = require 'keys'

return {
  {
    -- Gitsigns
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      current_line_blame = true,
      current_line_blame_opts = { delay = 500 },
    },
    keys = keys.gitsigns,
  },
  {
    -- Neogit
    'NeogitOrg/neogit',
    dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    cmd = 'Neogit',
    keys = keys.neogit,
    config = function()
      require('neogit').setup { integrations = { diffview = true }, disable_commit_confirmation = true }
    end,
    },
    {
    -- Opencode.nvim: AI coding agent integration
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = {
      {
        'folke/snacks.nvim',
        optional = true,
        opts = {
          picker = {
            actions = {
              opencode_send = function(...)
                return require('opencode').snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
                },
              },
            },
          },
        },
      },
    },
    keys = keys.opencode,
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function(port)
            -- We override the start to use our custom zsh 'oc' function which
            -- handles litellm proxy and opencode startup/cleanup.
            -- Note: 'oc' is a shell function, so we need interactive login shell (-ic)
            require('snacks').terminal.toggle('zsh -ic "oc"', {
              name = 'OpenCode',
            })
          end,
        },
      }
      vim.o.autoread = true
    end,
    },
    {

     -- Telekasten
     'jamesonBradfield/telekasten.nvim',
     enabled = true,
     lazy = false,
     dir = os.getenv 'USERPROFILE' .. '/projects/telekasten.nvim',
     opts = { 
       home = vim.fn.expand '~/zettelkasten', 
       backend = 'snacks',
       template_new_note = vim.fn.expand '~/zettelkasten/templates/new_note.md',
       template_new_daily = vim.fn.expand '~/zettelkasten/templates/daily_tk.md',
       template_new_weekly = vim.fn.expand '~/zettelkasten/templates/weekly_tk.md',
       template_new_monthly = vim.fn.expand '~/zettelkasten/templates/monthly_tk.md',
       template_new_quarterly = vim.fn.expand '~/zettelkasten/templates/quarterly_tk.md',
       template_new_yearly = vim.fn.expand '~/zettelkasten/templates/yearly_tk.md',
       template_handling = "always_use_default"
     },
     keys = keys.telekasten,
   },
  {
    -- CodeCompanion
    'olimorris/codecompanion.nvim',
    enabled = false,
    lazy = false,
    branch = 'has-xml-tools',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    keys = keys.codecompanion,
    init = function()
      if vim.fn.has 'win32' == 1 then
        vim.env.PATH = 'C:\\Windows\\System32;' .. vim.env.PATH
      end
    end,
    opts = {
      log_level = 'DEBUG',
      mcp = {
        servers = {
          ['sequential-thinking'] = { cmd = { 'npx.cmd', '-y', '@modelcontextprotocol/server-sequential-thinking' } },
          ['context7'] = { cmd = { 'npx.cmd', '-y', '@upstash/context7-mcp' }, env = { DEFAULT_MINIMUM_TOKENS = vim.env.DEFAULT_MINIMUM_TOKENS } },
          ['git-mcp-server'] = {
            cmd = { 'python', 'C:/Users/jamie/local-git-mcp-server/git_server.py', '--repositories-dir', 'C:/Users/jamie/projects/Godot/' },
          },
          ['memory'] = { cmd = { 'npx.cmd', '-y', '@modelcontextprotocol/server-memory' } },
        },
      },
      rules = {
        default = { description = 'Godot-Rust system rules', files = { '.cursorrules', { path = 'CLAUDE.md', parser = 'claude' } } },
      },
      prompt_library = {
        ['Godot Rust Class'] = {
          interaction = 'chat',
          description = 'Scaffold a new Godot Rust class (gdext)',
          opts = { alias = 'gdclass', is_slash_cmd = true },
          prompts = {
            {
              role = 'system',
              content = 'You are an expert in Godot 4 and Rust using the gdext crate. Always use #[derive(GodotClass)] and register classes in the ExtensionLibrary. Do not write GDScript.',
            },
            { role = 'user', content = 'Please generate the Rust boilerplate for a new Godot class based on this request or visual selection: #{selection}' },
          },
        },
        ['Godot Edit and Build'] = {
          interaction = 'chat',
          description = 'Use an agentic workflow to edit Rust code and compile it',
          opts = { alias = 'build_loop', is_workflow = true },
          prompts = {
            {
              {
                name = 'Edit and Build',
                role = 'user',
                opts = { auto_submit = false },
                content = function()
                  local approvals = require 'codecompanion.interactions.chat.tools.approvals'
                  approvals:toggle_yolo_mode()
                  return [[### Instructions

Please implement the requested changes in my Godot-Rust code.

### Steps to Follow

You are required to write code following the instructions provided above and verify it compiles. Follow these steps exactly:

1. Update the code in #{buffer}{diff} using the @{insert_edit_into_file} tool.
2. Then use the @{run_command} tool to compile the project using `cargo build`.
3. Make sure you trigger both tools in the same response.

We'll repeat this cycle until the build passes. Ensure no deviations from these steps.]]
                end,
              },
            },
            {
              {
                name = 'Repeat On Build Failure',
                role = 'user',
                opts = { auto_submit = true },
                condition = function(chat)
                  return chat.tools.tool and chat.tools.tool.name == 'run_command'
                end,
                repeat_until = function(chat)
                  return chat.tool_registry.flags.testing == true
                end,
                content = 'The build command failed. Can you analyze the compiler errors, edit the buffer, and run `cargo build` again?',
              },
            },
          },
        },
      },
      adapters = {
        http = {
          llama_server = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              name = 'llama_server',
              request = { timeout = 120000 },
              env = { url = 'http://127.0.0.1:8080', api_key = 'sk-dummy', chat_url = '/v1/chat/completions' },
              schema = { model = { default = 'codestral' } },
            })
          end,
        },
      },
      interactions = {
        chat = { adapter = 'llama_server', slash_commands = { file = { opts = { provider = 'snacks', hidden = true } } } },
        inline = { adapter = 'llama_server' },
      },
      display = { action_palette = { provider = 'snacks' } },
    },
  },
}
