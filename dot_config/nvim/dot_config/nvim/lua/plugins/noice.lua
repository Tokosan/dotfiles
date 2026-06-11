return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('noice').setup {
      lsp = {
        progress = { enabled = false },
        signature = { enabled = false },
      },
      cmdline = {
        format = {
          search_down = {
            view = 'cmdline',
          },
          search_up = {
            view = 'cmdline',
          },
        },
      },
      presets = {
        lsp_doc_border = true,
      },
    }
  end,
}
