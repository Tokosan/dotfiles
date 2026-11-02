-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Always use spaces instead of tabs, no matter what
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
  desc = 'Always use spaces instead of tabs',
  group = vim.api.nvim_create_augroup('kickstart-no-tabs', { clear = true }),
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
  end,
})

-- Set python tabs to 4
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
  desc = 'Set python tabs to 4',
  group = vim.api.nvim_create_augroup('kickstart-python-tabs', { clear = true }),
  pattern = '*.py',
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- Markdown: wrap lines at word boundaries and enable spell check
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Markdown editing settings',
  group = vim.api.nvim_create_augroup('kickstart-markdown', { clear = true }),
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { 'es', 'en' }
  end,
})

-- Set QML tabs to 4 (matches qmlformat, which runs on save)
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
  desc = 'Set QML tabs to 4',
  group = vim.api.nvim_create_augroup('qml-tabs', { clear = true }),
  pattern = '*.qml',
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- GDScript/Godot files use tabs (Godot's convention; mixing breaks the parser)
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufEnter' }, {
  desc = 'Use tabs in Godot files',
  group = vim.api.nvim_create_augroup('godot-tabs', { clear = true }),
  pattern = { '*.gd', '*.gdshader', '*.tscn', '*.tres', 'project.godot' },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 0
  end,
})

-- qmlls resolves `qs.*` imports through Quickshell's VFS, whose files are symlinks
-- to the real config; jumps land there, so swap to the real file (keeping the cursor)
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open the real file instead of its Quickshell VFS symlink',
  group = vim.api.nvim_create_augroup('quickshell-vfs', { clear = true }),
  pattern = '/run/user/*/quickshell/vfs/*',
  callback = function(ev)
    local real = vim.uv.fs_realpath(ev.file)
    if not real or real == ev.file then
      return
    end
    vim.schedule(function()
      if vim.api.nvim_get_current_buf() ~= ev.buf then
        return
      end
      -- Both paths are the same file, so `:edit real` would reuse this buffer:
      -- wipe it first, then open the real path
      local cursor = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_buf_delete(ev.buf, { force = true })
      vim.cmd.edit(vim.fn.fnameescape(real))
      pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    end)
  end,
})

-- Inside a Godot project, listen on a per-project socket so the Godot editor
-- can open scripts here (see ~/.local/bin/godot-nvim)
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Start server for Godot external editor',
  group = vim.api.nvim_create_augroup('godot-server', { clear = true }),
  callback = function()
    local project_file = vim.fs.find('project.godot', { upward = true, path = vim.fn.getcwd() })[1]
    if not project_file then
      return
    end
    local root = vim.fs.dirname(project_file)
    local sock = (vim.env.XDG_RUNTIME_DIR or '/tmp') .. '/godot-nvim-' .. vim.fn.sha256(root):sub(1, 12)
    if vim.v.servername ~= sock and not vim.uv.fs_stat(sock) then
      pcall(vim.fn.serverstart, sock)
    end
  end,
})
