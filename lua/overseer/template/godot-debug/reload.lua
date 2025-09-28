return {
  -- Required fields
  name = 'Reload',
  builder = function(params)
    -- This must return an overseer.TaskDefinition
    return {
      -- cmd is the only required field
      cmd = { 'Lazy' },
      -- additional arguments for the cmd
      args = { 'reload', 'godot-debug' },
      -- the name of the task (defaults to the cmd of the task)
      name = 'Reload',
    }
  end,
  -- Optional fields
  desc = 'Reload godot-debug',
  -- Tags can be used in overseer.run_template()
  -- tags = { require('oveseer').TAG.BUILD },
  params = {
    -- See :help overseer-params
  },
  -- Determines sort order when choosing tasks. Lower comes first.
  priority = 50,
  -- Add requirements for this template. If they are not met, the template will not be visible.
  -- All fields are optional.
  condition = {
    -- A string or list of strings
    -- Only matches when current buffer is one of the listed filetypes
    filetype = { 'lua' },
    -- A string or list of strings
    -- Only matches when cwd is inside one of the listed dirs
    -- dir = "/home/user/my_project",
    -- Arbitrary logic for determining if task is available
    -- callback = function(search)
    --   print(vim.inspect(search))
    --   return true
    -- end,
  },
}
