local function set_transparent_highlights()
  local groups = {
    'Normal', 'NormalFloat', 'FloatBorder', 'Pmenu', 'Terminal',
    'EndOfBuffer', 'FoldColumn', 'Folded', 'SignColumn', 'NormalNC',
    'WhichKeyFloat',
    'TelescopeBorder', 'TelescopeNormal', 'TelescopePromptBorder', 'TelescopePromptTitle',
    'NeoTreeNormal', 'NeoTreeNormalNC', 'NeoTreeVertSplit', 'NeoTreeWinSeparator', 'NeoTreeEndOfBuffer',
    'NvimTreeNormal', 'NvimTreeVertSplit', 'NvimTreeEndOfBuffer',
    'NotifyINFOBody', 'NotifyERRORBody', 'NotifyWARNBody', 'NotifyTRACEBody', 'NotifyDEBUGBody',
    'NotifyINFOTitle', 'NotifyERRORTitle', 'NotifyWARNTitle', 'NotifyTRACETitle', 'NotifyDEBUGTitle',
    'NotifyINFOBorder', 'NotifyERRORBorder', 'NotifyWARNBorder', 'NotifyTRACEBorder', 'NotifyDEBUGBorder',
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = 'none' })
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = set_transparent_highlights,
})
