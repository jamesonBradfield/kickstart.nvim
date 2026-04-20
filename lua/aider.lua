local M = {}
local pending_docs = {} -- State to accumulate your <cword> symbols

---Get or create the Aider terminal instance
local function get()
  ---@diagnostic disable-next-line: undefined-global
  return Snacks.terminal.get('aider --watch', {
    name = 'Aider Agent',
    win = { position = 'right', width = 0.4 },
  })
end

---Toggle the Aider terminal
local addon_cfg = require('plugins.addon_toggle')

function M.toggle()
  if addon_cfg.active == 'aider' then
    ---@diagnostic disable-next-line: undefined-global
    Snacks.terminal.toggle('aider --watch', {
      name = 'Aider Agent',
      win = { position = 'right', width = 0.4 },
    })
  elseif addon_cfg.active == 'opencode' then
    vim.cmd('Opencode toggle')
  end
  vim.cmd('stopinsert')
end

-- Toggle Opencode (uses the plugin's command)
local function opencode_toggle()
  vim.cmd('Opencode toggle')
end

-- Swap between Aider and Opencode terminals
function M.swap()
  local aid_buf = get().buf
  -- Check if Aider terminal buffer exists and is listed
  if vim.api.nvim_buf_is_valid(aid_buf) and vim.bo[aid_buf].buftype ~= '' then
    -- Aider is open: close it and open Opencode
    M.toggle()
    opencode_toggle()
  else
    -- Opencode is open or nothing: close Opencode and open Aider
    opencode_toggle()
    M.toggle()
  end
end

---Add a file to the Aider terminal
---@param path string
function M.add_file(path)
  local chan = vim.bo[get().buf].channel
  if chan > 0 then
    vim.api.nvim_chan_send(chan, '/add ' .. path .. '\r')
    vim.notify('Added to Aider: ' .. vim.fn.fnamemodify(path, ':t'))
  end
end

---Extract <cword> and build the progressive docs query in the Aider terminal
function M.append_doc_symbol()
  local word = vim.fn.expand('<cword>')
  if not word or word == "" then return end

  -- Prevent duplicate entries
  for _, v in ipairs(pending_docs) do
    if v == word then
      vim.notify("'" .. word .. "' is already in the query.", vim.log.levels.WARN)
      return
    end
  end

  table.insert(pending_docs, word)

  -- Format the grammatical list (e.g., "RenderingServer", "Vector3" and "Camera3D")
  local targets = ""
  for i, doc in ipairs(pending_docs) do
    if i == 1 then
      targets = '"' .. doc .. '"'
    elseif i == #pending_docs then
      targets = targets .. ' and "' .. doc .. '"'
    else
      targets = targets .. ', "' .. doc .. '"'
    end
  end

  -- Construct the final prompt exactly as you requested
  local prompt = "/ask let's find the docs of " .. targets .. " inside generated-docs@latest #use-tools"

  -- Send to Aider terminal
  local chan = vim.bo[get().buf].channel

  if chan > 0 then
    -- \x15 is Ctrl-U (clears the current prompt line in Aider)
    -- We send the prompt WITHOUT \r so it sits on the line waiting for you to hit Enter
    vim.api.nvim_chan_send(chan, "\x15" .. prompt)
    vim.notify("Appended '" .. word .. "' to docs query.", vim.log.levels.INFO)
  end
end

---Clear the query state (call this after you hit Enter in Aider)
function M.clear_doc_query()
  pending_docs = {}
  local chan = vim.bo[get().buf].channel
  if chan > 0 then
    vim.api.nvim_chan_send(chan, "\x15") -- Clear the terminal line
  end
  vim.notify("Aider docs query state cleared.", vim.log.levels.INFO)
end

return M
