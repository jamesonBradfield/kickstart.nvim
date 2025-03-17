-- nvim-godot-scene/lua/godot-scene.lua
local api = vim.api
local fn = vim.fn
local tscn_parser = require 'tscn_parser'

local M = {}

-- Create a buffer for the scene tree
function M.create_scene_tree_buffer()
	local buf = api.nvim_create_buf(false, true)
	api.bo(buf, 'buftype', 'nofile')
	api.bo(buf, 'swapfile', false)
	api.bo(buf, 'bufhidden', 'wipe')
	api.bo(buf, 'filetype', 'godot-scene-tree')
	return buf
end

-- Create a window for the scene tree
function M.open_scene_tree_window()
	local width = math.floor(vim.o.columns * 0.3)
	local height = vim.o.lines - 4
	local buf = M.create_scene_tree_buffer()

	local opts = {
		relative = 'editor',
		width = width,
		height = height,
		col = 0,
		row = 2,
		style = 'minimal',
		border = 'rounded',
	}

	local win = api.nvim_open_win(buf, true, opts)
	api.bo(win, 'winhl', 'Normal:NormalFloat')

	return buf, win
end

-- Render the scene tree to a buffer
function M.render_scene_tree(buf, scene)
	if not scene or not scene.root then
		api.nvim_buf_set_lines(buf, 0, -1, false, { 'No valid scene found' })
		return
	end

	local lines = {}

	-- Add header
	table.insert(lines, 'Godot Scene Tree')
	table.insert(lines, string.rep('=', 30))

	-- Define recursive function to print nodes
	local function add_node_to_lines(node, depth)
		local indent = string.rep('  ', depth)
		local icon = '+'
		local line = indent .. icon .. ' ' .. node.name
		if node.type and node.type ~= '' then
			line = line .. ' [' .. node.type .. ']'
		end
		table.insert(lines, line)

		-- Add properties (limited for clarity)
		local prop_count = 0
		for prop, value in pairs(node.properties) do
			prop_count = prop_count + 1
			if prop_count <= 3 then -- Limit to 3 properties for better readability
				local prop_line = indent .. '  • ' .. prop .. ' = ' .. tostring(value)
				table.insert(lines, prop_line)
			end
		end
		if prop_count > 3 then
			table.insert(lines, indent .. '  • (' .. (prop_count - 3) .. ' more properties...)')
		end

		-- Recursively add children
		for _, child in ipairs(node.children) do
			add_node_to_lines(child, depth + 1)
		end
	end

	-- Print the root node and its children
	add_node_to_lines(scene.root, 0)

	-- Add resources section
	table.insert(lines, '')
	table.insert(lines, 'External Resources')
	table.insert(lines, string.rep('-', 30))

	local res_count = 0
	for id, res in pairs(scene.ext_resources) do
		res_count = res_count + 1
		if res_count <= 5 then -- Limit to 5 resources for better readability
			local res_line = '• ' .. id .. ': ' .. res.type
			if res.path then
				res_line = res_line .. ' (' .. res.path .. ')'
			end
			table.insert(lines, res_line)
		end
	end

	if res_count > 5 then
		table.insert(lines, '• (' .. (res_count - 5) .. ' more resources...)')
	end

	-- Set the lines in the buffer
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Add syntax highlighting
	if api.nvim_buf_is_valid(buf) then
		vim.cmd [[
      syntax match GodotSceneHeader /^.*=\+$/
      syntax match GodotSceneResourceHeader /^.*-\+$/
      syntax match GodotSceneNodeName /^\s*[+] \S\+/
      syntax match GodotSceneNodeType /\[.\+\]/
      syntax match GodotSceneProperty /^\s*• .\+/

      highlight GodotSceneHeader guifg=#7DAEA3 gui=bold
      highlight GodotSceneResourceHeader guifg=#7DAEA3 gui=bold
      highlight GodotSceneNodeName guifg=#A9B665 gui=bold
      highlight GodotSceneNodeType guifg=#D8A657
      highlight GodotSceneProperty guifg=#89B482
    ]]
	end
end

-- Parse the current buffer as a TSCN file and show the scene tree
function M.show_scene_tree()
	local current_buf = api.nvim_get_current_buf()
	local filetype = api.bo(current_buf, 'filetype')

	if filetype ~= 'gdscript' and not api.nvim_buf_get_name(current_buf):match '%.tscn$' then
		print 'Not a Godot TSCN file'
		return
	end

	-- Get the content of the current buffer
	local lines = api.nvim_buf_get_lines(current_buf, 0, -1, false)
	local content = table.concat(lines, '\n')

	-- Parse the TSCN file
	local scene, err = tscn_parser.parse(content)

	if err then
		print('Error parsing TSCN file: ' .. err)
		return
	end

	-- Create and show the scene tree window
	local buf, win = M.open_scene_tree_window()
	M.render_scene_tree(buf, scene)

	-- Return to the original window
	api.nvim_set_current_win(api.nvim_get_current_win())

	return buf, win
end

-- Setup function for the plugin
function M.setup(opts)
	opts = opts or {}

	-- Create user commands
	api.nvim_create_user_command('GodotSceneTree', function()
		M.show_scene_tree()
	end, {})

	-- Set up auto-commands if needed
	if opts.auto_open then
		vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
			pattern = { '*.tscn' },
			callback = function()
				M.show_scene_tree()
			end,
		})
	end
end

return M
