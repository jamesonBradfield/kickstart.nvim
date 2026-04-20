return {
  {
    dir = vim.fn.expand("~/projects/barebones-chat.nvim"),
    name = "barebones-chat",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local barebones = require("barebones-chat")
      local network = require("barebones-chat.network")
      
      -- Monkey-patch the network request to hijack the URL and headers for Gemini
      -- This allows us to use Gemini's OpenAI-compatible endpoint without modifying the plugin source!
      local original_stream_request = network.stream_request
      network.stream_request = function(payload, opts)
        -- Reroute to Gemini's OpenAI-compatible endpoint
        opts.url = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
        -- Inject the GOOGLE_API_KEY
        opts.headers["Authorization"] = "Bearer " .. (os.getenv("GOOGLE_API_KEY") or "")
        
        return original_stream_request(payload, opts)
      end
      
barebones.setup({
        provider = 'openai', -- We use 'openai' here so the plugin formats the payload correctly for the compatible endpoint
        model = 'gemini-2.5-flash',
        
        -- Hook to inject dynamic context into the system prompt
        on_submit = function(prompt, chat_buffer)
          local selection, _ = barebones.utils.get_visual_selection()
          if selection and selection ~= '' then
            return prompt .. '\n\n<visual_selection>\n' .. selection .. '\n</visual_selection>'
          end
          return prompt
        end,

        -- Optional: Transform/filter each chunk before display.
        -- For Gemini extended thinking, strip <thinking> tags
        chunk_processor = function(text)
          -- Strip Gemini's thinking block tags
          text = text:gsub('<thinking>.-</thinking>', '')
          -- Trim any leading whitespace caused by stripping
          text = text:gsub('^%s+', '')
          -- Return nil to skip empty chunks after filtering
          if text == '' then return nil end
          return text
        end,

        -- Define tools natively in Lua for the LLM to call
        tools = {
          replace_visual_selection = barebones.default_tools.replace_visual_selection
        }
      })
    end,
    keys = {
      { "<leader>ac", "<cmd>BarebonesChat<cr>", desc = "Barebones Chat" },
    },
  }
}
