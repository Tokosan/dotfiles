return {
  'karb94/neoscroll.nvim',
  opts = {},
  config = function()
    require('neoscroll').setup {
      hide_cursor = false,
      duration_multiplier = 0.5,
    }
  end,
}
