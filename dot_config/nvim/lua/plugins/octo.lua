return { -- Review and manage GitHub PRs/issues without leaving nvim
  'pwntester/octo.nvim',
  cmd = 'Octo',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>op', '<cmd>Octo pr list<CR>', desc = '[O]cto [P]R list' },
    { '<leader>os', '<cmd>Octo pr search<CR>', desc = '[O]cto [S]earch PRs' },
    { '<leader>oc', '<cmd>Octo pr checkout<CR>', desc = '[O]cto [C]heckout PR' },
    { '<leader>od', '<cmd>Octo pr diff<CR>', desc = '[O]cto [D]iff PR' },
    { '<leader>or', '<cmd>Octo review start<CR>', desc = '[O]cto [R]eview start' },
  },
  opts = {
    picker = 'telescope',
  },
}
