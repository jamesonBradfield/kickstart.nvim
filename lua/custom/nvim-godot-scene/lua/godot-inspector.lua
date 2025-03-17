-- nvim-godot-scene/lua/godot-inspector.lua
local api = vim.api
local fn = vim.fn

local M = {}

-- Current node being inspected
M.current_node = nil
M.inspector_buf = nil
M.inspector_win = nil
M.scene_buffer = nil -- Original TSCN buffer

-- Create a buffer for the property inspector
function M.create_inspector_buffer()
	local buf = api.nvim_create_buf(false, true)
	vim.bo(buf, 'buftype', 'nofile')
	vim.bo(buf, 'swapfile', false)
	vim.bo(buf, 'bufhidden', 'wipe')
	vim.bo(buf, 'filetype', 'godot-scene-inspector')
	return buf
end

-- Create a window for the property inspector
function M.open_inspector_window()
	local width = math.floor(vim.o.columns * 0.3)
	local height = vim.o.lines - 4
	local buf = M.create_inspector_buffer()

	local opts = {
		relative = 'editor',
		width = width,
		height = height,
		col = vim.o.columns - width,
		row = 2,
		style = 'minimal',
		border = 'rounded',
	}

	local win = api.nvim_open_win(buf, true, opts)
	vim.wo(win, 'winhl', 'Normal:NormalFloat')

	M.inspector_buf = buf
	M.inspector_win = win

	return buf, win
end

-- Render node properties in the inspector
function M.render_inspector(node)
	if not node then
		if M.inspector_buf and api.nvim_buf_is_valid(M.inspector_buf) then
			api.nvim_buf_set_lines(M.inspector_buf, 0, -1, false, { 'No node selected' })
		end
		return
	end

	M.current_node = node

	local lines = {}

	-- Add header
	table.insert(lines, 'Node Inspector: ' .. node.name)
	table.insert(lines, string.rep('=', 30))

	-- Add node type
	table.insert(lines, 'Type: ' .. (node.type or ''))
	table.insert(lines, '')

	-- Add properties section
	table.insert(lines, 'Properties:')
	table.insert(lines, string.rep('-', 30))

	-- Sort properties for consistent display
	local sorted_props = {}
	for prop, _ in pairs(node.properties) do
		table.insert(sorted_props, prop)
	end
	table.sort(sorted_props)

	-- Add each property
	for _, prop in ipairs(sorted_props) do
		local value = node.properties[prop]
		-- Format the property for display
		local prop_line = prop .. ' = ' .. tostring(value)
		table.insert(lines, prop_line)
	end

	-- Add groups section if any
	if #node.groups > 0 then
		table.insert(lines, '')
		table.insert(lines, 'Groups:')
		table.insert(lines, string.rep('-', 30))

		for _, group in ipairs(node.groups) do
			table.insert(lines, '• ' .. group)
		end
	end

	-- Set the lines in the buffer
	if M.inspector_buf and api.nvim_buf_is_valid(M.inspector_buf) then
		api.nvim_buf_set_lines(M.inspector_buf, 0, -1, false, lines)

		-- Add syntax highlighting
		vim.cmd [[
      syntax match GodotInspectorHeader /^.*=\+$/
      syntax match GodotInspectorSection /^.*-\+$/
      syntax match GodotInspectorType /^Type: .\+$/
      syntax match GodotInspectorProperty /^[^=]\+ = .\+$/
      syntax match GodotInspectorGroup /^• .\+$/

      highlight GodotInspectorHeader guifg=#7DAEA3 gui=bold
      highlight GodotInspectorSection guifg=#7DAEA3 gui=bold
      highlight GodotInspectorType guifg=#D8A657 gui=italic
      highlight GodotInspectorProperty guifg=#89B482
      highlight GodotInspectorGroup guifg=#A9B665
    ]]
	end
end

-- Function to open the editor for a property
function M.edit_property(prop_name)
	if not M.current_node or not M.current_node.properties[prop_name] then
		print('Property not found: ' .. prop_name)
		return
	end

	local current_value = M.current_node.properties[prop_name]

	-- Create a temporary buffer for editing
	local edit_buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(edit_buf, 0, -1, false, { tostring(current_value) })

	-- Create a small floating window
	local width = math.min(60, vim.o.columns - 4)
	local height = 5

	local opts = {
		relative = 'editor',
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = 'minimal',
		border = 'rounded',
		title = 'Edit Property: ' .. prop_name,
		title_pos = 'center',
	}

	local win = api.nvim_open_win(edit_buf, true, opts)

	-- Set up auto-commands for saving the edit
	local augroup = api.nvim_create_augroup('GodotPropertyEdit', { clear = true })

	api.nvim_create_autocmd('BufLeave', {
		buffer = edit_buf,
		group = augroup,
		callback = function()
			local new_value = api.nvim_buf_get_lines(edit_buf, 0, -1, false)[1] or ''

			-- Update the property value - in a real plugin you'd need to parse the value properly
			M.current_node.properties[prop_name] = new_value

			-- Update the inspector display
			M.render_inspector(M.current_node)

			-- Close the edit window
			if api.nvim_win_is_valid(win) then
				api.nvim_win_close(win, true)
			end

			-- In a real plugin, you'd also need to update the actual TSCN file
			-- This would require finding the node in the file and updating its property
		end,
	})
end

-- Setup keymaps for interacting with the inspector
function M.setup_inspector_keymaps()
	if M.inspector_buf and api.nvim_buf_is_valid(M.inspector_buf) then
		-- Map 'e' to edit the property under cursor
		api.nvim_buf_set_keymap(M.inspector_buf, 'n', 'e', '', {
			noremap = true,
			callback = function()
				local line = api.nvim_get_current_line()
				local prop_name = line:match '^([^=]+) ='
				if prop_name then
					M.edit_property(prop_name:gsub('%s+$', '')) -- Trim trailing spaces
				end
			end,
		})

		-- Map 'q' to close the inspector
		api.nvim_buf_set_keymap(M.inspector_buf, 'n', 'q', '', {
			noremap = true,
			callback = function()
				if M.inspector_win and api.nvim_win_is_valid(M.inspector_win) then
					api.nvim_win_close(M.inspector_win, true)
				end
			end,
		})
	end
end

-- Show the inspector for a node
function M.inspect_node(node, scene_buf)
	M.scene_buffer = scene_buf

	-- Create or focus the inspector window
	if not M.inspector_buf or not api.nvim_buf_is_valid(M.inspector_buf) or not M.inspector_win or not api.nvim_win_is_valid(M.inspector_win) then
		M.open_inspector_window()
	else
		api.nvim_set_current_win(M.inspector_win)
	end

	-- Render the node properties
	M.render_inspector(node)

	-- Setup keymaps
	M.setup_inspector_keymaps()
end

return M
