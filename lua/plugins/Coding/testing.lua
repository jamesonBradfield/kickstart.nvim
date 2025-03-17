return {
  'nvim-neotest/neotest',
	enabled = false,
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'Issafalcon/neotest-dotnet',
  },
  config = function()
    require('neotest').setup {
      require 'neotest-dotnet',
    }
  end,
}
