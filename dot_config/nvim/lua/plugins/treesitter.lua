return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'diff',
      'graphql',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'typescript',
      'python',
      'qmljs',
      'gdscript',
      'gdshader',
      'godot_resource',
    },
    auto_install = false,
    highlight = {
      enable = true,
    },
  },
  config = function(_, opts)
    local ok_configs, configs = pcall(require, 'nvim-treesitter.configs')
    if ok_configs then
      configs.setup(opts)
    else
      local ok_ts, ts = pcall(require, 'nvim-treesitter')
      if ok_ts and type(ts.setup) == 'function' then
        ts.setup(opts)
        -- En la rama main, ensure_installed no existe como opción: hay que
        -- pedir la instalación explícitamente (no-op si ya están instalados).
        ts.install(opts.ensure_installed)
      end
    end

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
