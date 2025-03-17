-- nvim-godot-scene/lua/init.lua
local scene_tree = require 'godot-scene'
local inspector = require 'godot-inspector'

local M = {}

-- Expose the setup function
function M.setup(opts)
	opts = opts or {}

	-- Setup the scene tree component
	scene_tree.setup(opts)

	-- Add a command to toggle both the scene tree and inspector
	vim.api.nvim_create_user_command('GodotSceneView', function()
		local buf, win = scene_tree.show_scene_tree()

		-- If there's a root node, automatically inspect it
		local current_buf = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
		local content = table.concat(lines, '\n')

		local scene = require('tscn_parser').parse(content)
		if scene and scene.root then
			inspector.inspect_node(scene.root, current_buf)
		end
	end, {})

	-- Set up a mini API for other plugins to interact with
	M.inspect_node = inspector.inspect_node
	M.show_scene_tree = scene_tree.show_scene_tree

	-- If there are specific filetype settings
	if opts.filetypes then
		vim.api.nvim_create_autocmd('FileType', {
			pattern = opts.filetypes,
			callback = function()
				-- Set up any filetype-specific behavior
			end,
		})
	end

	return M
end

return M
