return {
  'zbirenbaum/copilot.lua',
  dependencies = {
    { 'copilotlsp-nvim/copilot-lsp' },
  },
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      -- Your Copilot configuration options here
      -- For example:
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<C-y>',
          next = '<C-n>',
          prev = '<C-p>',
          dismiss = '<C-x>',
        },
      },
      panel = {
        enabled = true,
        auto_refresh = true,
      },
      -- ... other options as per copilot.lua documentation
    }
  end,
}
