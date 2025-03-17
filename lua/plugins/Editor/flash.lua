return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    modes = { char = { enabled = false } },
  },
  keys = require'mappings'.flash()
}
