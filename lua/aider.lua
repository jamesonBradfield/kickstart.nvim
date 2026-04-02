local M = {}

---@type table|nil
M.aider_term = nil

---Get the aider terminal instance
---@return table
function M.get_aider()
  -- Use Snacks.terminal.get to find an existing instance or create one
  local cmd = 'aider --no-auto-commits'
  
  ---@diagnostic disable-next-line: undefined-global
  M.aider_term = Snacks.terminal.get(cmd, {
    name = 'Aider Agent',
    win = { position = 'right', width = 0.4 },
  })
  
  return M.aider_term
end

---Toggle the aider terminal
function M.toggle()
  local cmd = 'aider --no-auto-commits'
  ---@diagnostic disable-next-line: undefined-global
  M.aider_term = Snacks.terminal.toggle(cmd, {
    name = 'Aider Agent',
    win = { position = 'right', width = 0.4 },
  })
  -- Ensure we don't stay in insert mode if we just closed it
  vim.cmd('stopinsert')
end

---Send text directly to the terminal channel
---@param text string
local function send_to_term(text)
  local aider = M.get_aider()
  local chan = vim.bo[aider.buf].channel
  if chan and chan > 0 then
    vim.api.nvim_chan_send(chan, text)
  else
    vim.notify('Aider terminal channel not found', vim.log.levels.ERROR)
  end
end

---Add a file to the aider terminal
function M.add_file(path)
  -- Send the /add command followed by a carriage return
  send_to_term('/add ' .. path .. '\r')
  vim.notify('Added to Aider: ' .. vim.fn.fnamemodify(path, ':t'))
end

---Clear the cumulative hover context
function M.clear_context()
  local context_file = vim.fn.getcwd() .. '/aider_hover_context.md'
  local f = io.open(context_file, 'w')
  if f then
    f:write('# Aider Investigation Context\n\nStarted: ' .. os.date('%Y-%m-%d %H:%M:%S') .. '\n')
    f:close()
    vim.notify('Aider hover context cleared')
  else
    vim.notify('Failed to clear aider context file', vim.log.levels.ERROR)
  end
end

---Send LSP hover information to aider via a cumulative context file
function M.send_hover()
  local params = vim.lsp.util.make_position_params(0, 'utf-16')
  vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, _ctx, _config)
    if err or not (result and result.contents) then
      vim.notify('No hover info found', vim.log.levels.WARN)
      return
    end

    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    local hover_text = table.concat(markdown_lines, '\n')
    local symbol = vim.fn.expand('<cword>')

    -- Use a stable file in the project root (Append mode 'a')
    local context_file = vim.fn.getcwd() .. '/aider_hover_context.md'
    local f = io.open(context_file, 'a')
    if f then
      local timestamp = os.date('%H:%M:%S')
      f:write(string.format('\n\n---\n## [%s] Symbol: %s\n\n%s', timestamp, symbol, hover_text))
      f:close()

      -- Tell Aider to add/refresh this file. 
      send_to_term('/add aider_hover_context.md\r')

      M.get_aider():show()
      vim.notify('LSP context for "' .. symbol .. '" appended to aider_hover_context.md')
    else
      vim.notify('Failed to write aider context file', vim.log.levels.ERROR)
    end
  end)
end

return M
