-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
-- { "K", function() vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 } end, desc = "Hover documentation" }
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover { border = 'single', max_height = 25, max_width = 120 }
end, { desc = 'Hover documentation' })
vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })
vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open file explorer' })
vim.keymap.set('n', '<leader>/', 'gcc', { desc = 'Comment line', remap = true })
vim.keymap.set('v', '<leader>/', 'gc', { desc = 'Comment selection', remap = true })
vim.keymap.set('n', '<leader>cs', '<cmd>w<CR>', { desc = '[C]ommand [S]ave buffer' })
vim.keymap.set('n', '<leader>nt', '<cmd>Neotree right toggle<CR>', { desc = '[N]eotree [T]oggle' })
vim.keymap.set('n', '<leader>nf', '<cmd>Neotree right focus<CR>', { desc = '[N]eotree [F]ocus' })
vim.keymap.set('n', 'dsi', function()
  -- select outer indentation
  require('various-textobjs').indentation('outer', 'outer')

  -- plugin only switches to visual mode when a textobj has been found
  local indentationFound = vim.fn.mode():find 'V'
  if not indentationFound then
    return
  end

  -- dedent indentation
  vim.cmd.normal { '<', bang = true }

  -- delete surrounding lines
  local endBorderLn = vim.api.nvim_buf_get_mark(0, '>')[1]
  local startBorderLn = vim.api.nvim_buf_get_mark(0, '<')[1]
  vim.cmd(tostring(endBorderLn) .. ' delete') -- delete end first so line index is not shifted
  vim.cmd(tostring(startBorderLn) .. ' delete')
end, { desc = '[D]elete [S]urrounding [I]ndentation' })

vim.keymap.set('n', '<leader>za', 'za', { desc = 'Toggle fold' })
vim.keymap.set('n', '<leader>zA', 'zA', { desc = 'Toggle fold recursively' })
vim.keymap.set('n', '<leader>zR', 'zR', { desc = 'Open all folds' })
vim.keymap.set('n', '<leader>zM', 'zM', { desc = 'Close all folds' })

for i = 1, 9 do
  vim.keymap.set('n', '<leader>z' .. i, function()
    vim.opt.foldlevel = i - 1
  end, { desc = 'Fold level ' .. i })
end
