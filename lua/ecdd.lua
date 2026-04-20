local M = {}

---Get the language-specific comment string for the current buffer
---@return string
local function get_comment_string()
  local cs = vim.bo.commentstring
  if cs == nil or cs == "" then
    return "// %s"
  end
  return cs
end

---Format a message as an AI instruction comment
---@param message string
---@return string
local function format_ai_instruction(message)
  local cs = get_comment_string()
  local instruction = "AI! " .. message
  if cs:find("%%s") then
    return cs:format(instruction)
  else
    local cleaned_cs = cs:gsub("%%s*$", "")
    return cleaned_cs .. " " .. instruction
  end
end

---Inject LSP errors as comments (No auto-save)
function M.auto_heal_lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })

  if #diagnostics == 0 then
    vim.notify("ECDD: No LSP errors found.", vim.log.levels.INFO)
    return
  end

  table.sort(diagnostics, function(a, b)
    return a.lnum > b.lnum
  end)

  for _, diag in ipairs(diagnostics) do
    local comment = format_ai_instruction("Fix this LSP Error: " .. diag.message)
    vim.api.nvim_buf_set_lines(bufnr, diag.lnum, diag.lnum, false, { comment })
  end

  vim.notify("ECDD: Injected " .. #diagnostics .. " LSP error fixes. Manual save required to trigger Aider.", vim.log.levels.INFO)
end

---Trigger Whisper STT and inject as AI comment (No auto-save)
function M.stt_thought_to_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_idx = cursor[1] - 1
  local col_idx = cursor[2]

  local script_path = vim.fn.stdpath("config") .. "/scripts/whisper_capture.sh"

  vim.notify("ECDD: Listening...", vim.log.levels.INFO)

  vim.fn.jobstart({ "bash", script_path }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data, _)
      if not data or #data == 0 then return end
      local text = table.concat(data, " "):gsub("^%s*(.-)%s*$", "%1")
      if text == "" then 
        vim.notify("ECDD: STT Output was empty.", vim.log.levels.WARN)
        return 
      end

      local comment = format_ai_instruction(text)
      local line = vim.api.nvim_buf_get_lines(bufnr, line_idx, line_idx + 1, false)[1]
      local new_line = line:sub(1, col_idx) .. comment .. line:sub(col_idx + 1)
      vim.api.nvim_buf_set_lines(bufnr, line_idx, line_idx + 1, false, { new_line })

      vim.notify("ECDD: Transcribed. Review then save to trigger Aider.", vim.log.levels.INFO)
    end,
    on_stderr = function(_, data, _)
      local err = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
      if err ~= "" then
        vim.notify("ECDD DEBUG: " .. err, vim.log.levels.DEBUG)
      end
    end,
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        vim.notify("ECDD: STT Job failed with code " .. exit_code, vim.log.levels.ERROR)
      end
    end,
  })
end

return M
