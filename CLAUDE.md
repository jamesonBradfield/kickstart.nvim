# Neovim Configuration Guidelines

## Testing and Lint Commands
- Run Lua tests: `lua -e "require('plenary.test_harness').test_directory('{test_file}')"` 
- Run busted tests: `nvim -l lua/custom/godot-debug/tests/busted.lua`
- Lint Lua: `stylua ./lua/**/*.lua`
- Debug Godot: Use `:GdUnitDebugTest` for GDUnit4 tests
- Run GDUnit4 test: `:GdUnitRunTest` (current file) or `:GdUnitRunAllTests` (all tests)

## Code Style Guidelines
- **Formatting**: Use stylua for Lua files (available via Mason)
- **Indentation**: 2-space indentation for Lua, 4-space for GDScript and C#
- **Variable naming**: Use snake_case for variables and functions in Lua
- **Error Handling**: Use pcall for error handling and check return status
- **Functions**: Document functions with ---@param and ---@return annotations
- **Module Structure**: Return a single table for plugin modules
- **Config Options**: Use vim.tbl_deep_extend('force', defaults, user_config) for merging configs
- **Imports**: Use local X = require 'Y' pattern for imports
- **UI Notifications**: Use vim.notify with appropriate log levels (INFO, WARN, ERROR)
- **Directory Handling**: Save and restore working directories when changing them
- **Platform Support**: Check for platform with vim.fn.has and handle different behaviors