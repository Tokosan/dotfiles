return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      find_files = {
        hidden = true,
      },
      vimgrep_arguments = {
        'rg',
        '--hidden',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
      },
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      -- defaults = {
      --   mappings = {
      --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
      --   },
      -- },
      -- pickers = {}
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--hidden',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    local utils = require 'telescope.utils'
    vim.keymap.set('n', '<leader>sb', function()
      builtin.find_files { cwd = utils.buffer_dir() }
    end, { desc = '[S]earch files in current [B]uffer directory' })
    vim.keymap.set(
      'n',
      '<leader>sh',
      builtin.help_tags,
      { desc = '[S]earch [H]elp' }
    )
    vim.keymap.set(
      'n',
      '<leader>sk',
      builtin.keymaps,
      { desc = '[S]earch [K]eymaps' }
    )
    vim.keymap.set(
      'n',
      '<leader>sf',
      "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
      { desc = '[S]earch [F]iles' }
    )
    vim.keymap.set(
      'n',
      '<leader>ss',
      builtin.builtin,
      { desc = '[S]earch [S]elect Telescope' }
    )
    vim.keymap.set(
      'n',
      '<leader>sw',
      builtin.grep_string,
      { desc = '[S]earch current [W]ord' }
    )
    vim.keymap.set(
      'n',
      '<leader>sg',
      "<cmd>lua require'telescope.builtin'.live_grep({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
      { desc = '[S]earch by [G]rep' }
    )
    vim.keymap.set(
      'n',
      '<leader>sd',
      builtin.diagnostics,
      { desc = '[S]earch [D]iagnostics' }
    )
    vim.keymap.set(
      'n',
      '<leader>sr',
      builtin.resume,
      { desc = '[S]earch [R]esume' }
    )
    vim.keymap.set(
      'n',
      '<leader>s.',
      builtin.oldfiles,
      { desc = '[S]earch Recent Files ("." for repeat)' }
    )
    vim.keymap.set('n', '<leader>s<leader>', function()
      builtin.current_buffer_fuzzy_find(
        require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = true,
        }
      )
    end, { desc = '[S]earch [ ] current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
    -- Shortcut for searching my config files
    vim.keymap.set('n', '<leader>sc', function()
      builtin.find_files { cwd = '~/dotfiles/' }
    end, { desc = '[S]earch [C]onfig files' })
  end,
}
