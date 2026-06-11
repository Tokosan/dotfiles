return {
  'stevearc/aerial.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  keys = {
    { '<leader>ao', '<cmd>AerialToggle!<CR>', desc = '[A]erial [O]utline' },
    { '[a', '<cmd>AerialPrev<CR>', desc = 'Aerial prev symbol' },
    { ']a', '<cmd>AerialNext<CR>', desc = 'Aerial next symbol' },
  },
  opts = {
    layout = { default_direction = 'right', min_width = 30 },
    attach_mode = 'global',
    filter_kind = { 'Class', 'Constructor', 'Function', 'Method' },
  },
}
