-- ~/.config/nvim/lua/plugins/init.lua
-- Automatically load all plugin modules from subdirectories

-- Define plugin categories
local plugin_categories = {
  "Coding",
  "Editor",
  "UI",
  "Tools",
  "Git_and_Misc",
}

-- Function to convert a filepath to a require path
local function path_to_require(path)
  -- Remove .lua extension
  path = path:gsub("%.lua$", "")
  -- Convert slashes to dots
  path = path:gsub("/", ".")
  return path
end

local plugins = {}

-- Loop through each category and gather all plugin files
for _, category in ipairs(plugin_categories) do
  -- Import the entire category folder
  table.insert(plugins, { import = "plugins." .. category })
end

return plugins
