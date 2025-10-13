-- Cargo wrapper commands for Neovim
-- Add this to your init.lua

vim.api.nvim_create_user_command('CargoRun', function(opts)
  vim.cmd('split | terminal cargo run ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CargoBuild', function(opts)
  vim.cmd('split | terminal cargo build ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CargoTest', function(opts)
  vim.cmd('split | terminal cargo test ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CargoCheck', function(opts)
  vim.cmd('split | terminal cargo check ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CargoClippy', function(opts)
  vim.cmd('split | terminal cargo clippy ' .. opts.args)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CargoFmt', function()
  vim.cmd 'split | terminal cargo fmt'
end, {})

vim.api.nvim_create_user_command('CargoClean', function()
  vim.cmd 'split | terminal cargo clean'
end, {})

vim.api.nvim_create_user_command('CargoDoc', function(opts)
  vim.cmd('split | terminal cargo doc ' .. opts.args)
end, { nargs = '*' })

-- Optional: Add keybindings
vim.keymap.set('n', '<leader>cr', ':CargoRun<CR>', { desc = 'Cargo Run' })
vim.keymap.set('n', '<leader>cb', ':CargoBuild<CR>', { desc = 'Cargo Build' })
vim.keymap.set('n', '<leader>ct', ':CargoTest<CR>', { desc = 'Cargo Test' })
vim.keymap.set('n', '<leader>cc', ':CargoCheck<CR>', { desc = 'Cargo Check' })
vim.keymap.set('n', '<leader>cl', ':CargoClippy<CR>', { desc = 'Cargo Clippy' })
vim.keymap.set('n', '<leader>cf', ':CargoFmt<CR>', { desc = 'Cargo Format' })
return {}
