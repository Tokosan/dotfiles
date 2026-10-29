return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  ft = { 'markdown' },
  keys = {
    { '<leader>mdt', '<cmd>RenderMarkdown toggle<cr>', ft = 'markdown', desc = 'Markdown: toggle render' },
  },
  opts = {},
}
