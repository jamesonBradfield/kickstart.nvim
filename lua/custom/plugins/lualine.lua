local codecompanion_status = (function()
  -- State variables
  local processing = false
  local spinner_index = 1
  local last_update = 0
  local spinner_frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

  -- Set up autocmd
  local group = vim.api.nvim_create_augroup('CodeCompanionStatus', { clear = true })
  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = 'CodeCompanionRequest*',
    group = group,
    callback = function(args)
      if args.match == 'CodeCompanionRequestStarted' then
        processing = true
      elseif args.match == 'CodeCompanionRequestFinished' then
        processing = false
      end
      vim.cmd 'redrawstatus'
    end,
  })

  -- Return the function that updates the status
  return function()
    if processing then
      -- Update spinner animation
      local current_time = vim.loop.now()
      if current_time - last_update > 100 then
        spinner_index = (spinner_index % #spinner_frames) + 1
        last_update = current_time
      end
      return spinner_frames[spinner_index] .. ' AI'
    else
      return ''
    end
  end
end)()
return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    sections = {
      lualine_b = { 'grapple' },
      lualine_c = {
        'filename',
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          symbols = {
            error = '', -- You can use '✘' if not using Nerd Font
            warn = '', -- You can use '▲' if not using Nerd Font
            info = '', -- You can use 'ℹ' if not using Nerd Font
            hint = '', -- You can use '⚑' if not using Nerd Font
          },
          colored = true,
          update_in_insert = false,
          always_visible = false,
        },
      },
      lualine_x = {
        -- Your existing components...
        codecompanion_status,
        'filetype',
      },
    },
    options = { theme = 'tokyonight-storm' },
  },
}
