-- tscn_parser.lua
-- A parser for Godot's TSCN (text scene) file format

local M = {}

-- Node class to represent a node in the scene tree
local Node = {}
Node.__index = Node

function Node.new(name, type, parent)
	local self = setmetatable({}, Node)
	self.name = name
	self.type = type
	self.parent = parent
	self.children = {}
	self.properties = {}
	self.groups = {}
	return self
end

function Node:add_child(child)
	table.insert(self.children, child)
end

function Node:set_property(name, value)
	self.properties[name] = value
end

-- Resource class to represent internal and external resources
local Resource = {}
Resource.__index = Resource

function Resource.new(id, type, path)
	local self = setmetatable({}, Resource)
	self.id = id
	self.type = type
	self.path = path
	self.properties = {}
	return self
end

function Resource:set_property(name, value)
	self.properties[name] = value
end

-- Scene class to represent the entire scene
local Scene = {}
Scene.__index = Scene

function Scene.new()
	local self = setmetatable({}, Scene)
	self.root = nil
	self.format_version = 0
	self.load_steps = 0
	self.uid = ''
	self.ext_resources = {} -- External resources
	self.sub_resources = {} -- Internal resources
	self.nodes = {}       -- All nodes by name
	self.connections = {} -- Signal connections
	return self
end

-- Main parser function
function M.parse(content)
	local lines = {}
	for line in content:gmatch '([^\n]*)\n?' do
		table.insert(lines, line)
	end

	local scene = Scene.new()
	local current_section = nil
	local current_node = nil
	local current_resource = nil
	local line_idx = 1

	-- Parse file descriptor
	local header = lines[line_idx]
	line_idx = line_idx + 1

	if header:match '%[gd_scene' then
		-- Parse scene header
		scene.format_version = tonumber(header:match 'format=(%d+)') or 3
		scene.load_steps = tonumber(header:match 'load_steps=(%d+)') or 0
		scene.uid = header:match 'uid="([^"]+)"' or ''
	elseif header:match '%[gd_resource' then
		-- Handle resource files - for simplicity we'll skip this for now
		return nil, 'Resource files not supported yet'
	else
		return nil, 'Invalid file format'
	end

	-- Main parsing loop
	while line_idx <= #lines do
		local line = lines[line_idx]:gsub('^%s*(.-)%s*$', '%1') -- Trim
		line_idx = line_idx + 1

		if line == '' or line:match '^;' then
			-- Skip empty lines and comments
		elseif line:match '^%[ext_resource' then
			-- Parse external resource
			local id = line:match 'id="([^"]+)"'
			local type = line:match 'type="([^"]+)"'
			local path = line:match 'path="([^"]+)"'

			if id and type then
				scene.ext_resources[id] = Resource.new(id, type, path)
			end
		elseif line:match '^%[sub_resource' then
			-- Parse internal resource
			local id = line:match 'id="([^"]+)"'
			local type = line:match 'type="([^"]+)"'

			if id and type then
				current_resource = Resource.new(id, type)
				scene.sub_resources[id] = current_resource
				current_section = 'sub_resource'
			end
		elseif line:match '^%[node' then
			-- Parse node
			local name = line:match 'name="([^"]+)"'
			local type = line:match 'type="([^"]+)"'
			local parent_path = line:match 'parent="([^"]+)"'

			if name then
				current_node = Node.new(name, type or '')

				-- Parse groups if present
				local groups_str = line:match 'groups=%[([^%]]+)%]'
				if groups_str then
					for group in groups_str:gmatch '"([^"]+)"' do
						table.insert(current_node.groups, group)
					end
				end

				-- Handle parent relationship
				if parent_path then
					if parent_path == '.' then
						-- Child of root
						if scene.root then
							scene.root:add_child(current_node)
							current_node.parent = scene.root
						end
					else
						-- Find parent using path
						-- For simplicity, we'll just store the path and resolve later
						current_node.parent_path = parent_path
					end
				else
					-- This is the root node
					scene.root = current_node
				end

				scene.nodes[name] = current_node
				current_section = 'node'
			end
		elseif line:match '^%[connection' then
			-- Parse connection
			local signal = line:match 'signal="([^"]+)"'
			local from = line:match 'from="([^"]+)"'
			local to = line:match 'to="([^"]+)"'
			local method = line:match 'method="([^"]+)"'

			if signal and from and to and method then
				table.insert(scene.connections, {
					signal = signal,
					from = from,
					to = to,
					method = method,
				})
			end
		elseif current_section == 'node' and line:match '=' then
			-- Parse node property
			local prop_name, value = line:match '([^=]+)%s*=%s*(.+)'
			if prop_name and value and current_node then
				current_node:set_property(prop_name, value)
			end
		elseif current_section == 'sub_resource' and line:match '=' then
			-- Parse resource property
			local prop_name, value = line:match '([^=]+)%s*=%s*(.+)'
			if prop_name and value and current_resource then
				current_resource:set_property(prop_name, value)
			end
		end
	end

	-- Resolve parent paths for nodes
	for _, node in pairs(scene.nodes) do
		if node.parent_path then
			-- This would require traversing the path to find the actual parent
			-- For simplicity, this is left as an exercise
		end
	end

	return scene
end

-- Helper function to print a scene tree (for debugging)
function M.print_scene_tree(scene)
	if not scene or not scene.root then
		print 'Empty or invalid scene'
		return
	end

	local function print_node(node, indent)
		indent = indent or 0
		local indent_str = string.rep('  ', indent)
		print(indent_str .. node.name .. ' (' .. node.type .. ')')

		-- Print properties
		for prop, value in pairs(node.properties) do
			print(indent_str .. '  - ' .. prop .. ' = ' .. value)
		end

		-- Print children
		for _, child in ipairs(node.children) do
			print_node(child, indent + 1)
		end
	end

	print 'Scene Tree:'
	print_node(scene.root)

	print '\nExternal Resources:'
	for id, res in pairs(scene.ext_resources) do
		print('  ' .. id .. ': ' .. res.type .. ' (' .. (res.path or '') .. ')')
	end

	print '\nInternal Resources:'
	for id, res in pairs(scene.sub_resources) do
		print('  ' .. id .. ': ' .. res.type)
	end
end

-- Helper function to convert a scene to a Neovim-friendly tree representation
function M.to_nvim_tree(scene)
	if not scene or not scene.root then
		return nil
	end

	local function node_to_tree(node)
		local result = {
			name = node.name,
			type = node.type,
			properties = node.properties,
			children = {},
		}

		for _, child in ipairs(node.children) do
			table.insert(result.children, node_to_tree(child))
		end

		return result
	end

	return node_to_tree(scene.root)
end

return M
