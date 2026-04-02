local keys = require 'keys'

return {
  {
    -- Dracula Colorscheme
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'dracula'
    end,
  },
  {
    -- Lualine
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local function is_godot_active()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        for _, client in pairs(clients) do
          if client.name == 'gdscript' or client.name == 'godot' then
            return true
          end
        end
        return false
      end

      local function godot_status()
        if vim.bo.filetype ~= 'gdscript' and vim.bo.filetype ~= 'gd' then
          return ''
        end
        return is_godot_active() and '󰣖 Godot LSP' or '󰣖 Disconnected'
      end

      local function godot_color()
        if is_godot_active() then
          return { fg = '#50fa7b' }
        else
          return { fg = '#ff5555', gui = 'bold' }
        end
      end

      local function grapple_status()
        local ok, grapple = pcall(require, 'grapple')
        if ok and grapple.exists() then
          return '󰛢 ' .. grapple.name_or_index()
        end
        return ''
      end

      require('lualine').setup {
        options = { theme = 'dracula-nvim' },
        sections = {
          lualine_b = {
            'branch',
            'diff',
            'diagnostics',
            { grapple_status, color = { fg = '#8be9fd', gui = 'bold' } },
          },
          lualine_x = { { godot_status, color = godot_color }, 'encoding', 'fileformat', 'filetype' },
        },
      }
    end,
  },
  { 'OXY2DEV/helpview.nvim', lazy = false },
  {
    -- Trouble
    'folke/trouble.nvim',
    keys = keys.trouble,
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd('DiagnosticChanged', {
        group = vim.api.nvim_create_augroup('AutoTrouble', { clear = true }),
        callback = function()
          local diags = vim.diagnostic.get(nil, { severity = { min = vim.diagnostic.severity.WARN } })
          local trouble = require 'trouble'
          if #diags > 0 then
            trouble.open { mode = 'diagnostics', focus = false }
          else
            if trouble.is_open 'diagnostics' then
              trouble.close 'diagnostics'
            end
          end
        end,
      })
    end,
  },
  {
    -- UFO
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufRead',
    keys = keys.ufo,
    init = function()
      vim.o.foldcolumn = '1'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    end,
    config = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end

      local view_group = vim.api.nvim_create_augroup('AutoView', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWinLeave' }, { pattern = '?*', group = view_group, command = 'mkview' })
      vim.api.nvim_create_autocmd({ 'BufWinEnter' }, { pattern = '?*', group = view_group, command = 'silent! loadview' })

      require('ufo').setup {
        fold_virt_text_handler = handler,
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },
  {
    -- Render Markdown
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { latex = { enabled = false }, win_options = { conceallevel = { rendered = 2 } } },
  },
}
