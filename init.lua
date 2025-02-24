-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require 'options'
require('lazy').setup {
  {
    import = 'plugins',
      rocks = {
        hererocks = true, -- recommended if you do not have global installation of Lua 5.1.
      },
  },
}
-- vim.opt.errorformat = table.concat({
--   -- Match C# compiler errors/warnings with project context
--   '%f(%l\\,%c): %trror %[%m%\\]',  -- Error with project path
--   '%f(%l\\,%c): %tarning %[%m%\\]', -- Warning with project path
--   '%f(%l\\,%c): %trror %m',        -- Error without project path
--   '%f(%l\\,%c): %tarning %m',      -- Warning without project path
--   '%-G%.%#'                         -- Ignore all other lines
-- }, ',')
-- --
-- vim.api.nvim_create_autocmd('BufWritePost', {
--   pattern = '*.cs',
--   callback = function()
--     vim.fn.jobstart('/home/jamie/.local/bin/godot-build.sh', {
--       on_exit = function(_, code)
--         -- Clear previous results and load new ones
--         vim.fn.setqflist({}, 'r')
--         vim.fn.setqflist({}, ' ', {
--           title = 'Godot Build Results',
--           lines = vim.fn.systemlist('/home/jamie/.local/bin/godot-build.sh'),
--           efm = vim.opt.errorformat:get()
--         })
--
--         if code ~= 0 then
--           vim.cmd('copen')
--           vim.notify('Build failed', vim.log.levels.ERROR)
--         else
--           vim.notify('Build succeeded', vim.log.levels.INFO)
--         end
--       end
--     })
--   end
-- })
require 'mappings'
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=0 sw=2 et
