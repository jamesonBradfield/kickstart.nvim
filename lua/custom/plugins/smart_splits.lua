return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<c-h>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').move_cursor_left()
      end,
      desc = 'Navigate Left',
    },
    {
      '<c-j>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').move_cursor_down()
      end,
      desc = 'Navigate Down',
    },
    {
      '<c-k>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').move_cursor_up()
      end,
      desc = 'Navigate Up',
    },
    {
      '<c-l>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').move_cursor_right()
      end,
      desc = 'Navigate Right',
    },
    {
      '<c-a-h>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').resize_left()
      end,
      desc = 'Resize Left',
    },
    {
      '<c-a-j>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').resize_down()
      end,
      desc = 'Resize Down',
    },
    {
      '<c-a-k>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').resize_up()
      end,
      desc = 'Resize Up',
    },
    {
      '<c-a-l>',
      mode = { 'n', 'x', 'o' },
      function()
        require('smart-splits').resize_right()
      end,
      desc = 'Resize Right',
    },
  },
}
