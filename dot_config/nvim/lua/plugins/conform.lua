return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
        {
            '<leader>f',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = '',
            desc = '[F]ormat buffer',
        },
    },
    opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
            if vim.bo[bufnr].filetype == 'c' then
                return false
            end
            return {
                timeout_ms = 500,
                lsp_format = 'fallback',
            }
        end,
        formatters_by_ft = {
            lua = { 'stylua' },
            javascript = { 'prettierd', 'prettier', stop_after_first = true },
            typescript = { 'prettierd', 'prettier', stop_after_first = true },
            javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
            typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
            css = { 'prettierd', 'prettier', stop_after_first = true },
            html = { 'prettierd', 'prettier', stop_after_first = true },
            json = { 'prettierd', 'prettier', stop_after_first = true },
            yaml = { 'prettierd', 'prettier', stop_after_first = true },
            markdown = { 'prettierd', 'prettier', stop_after_first = true },
            python = { 'ruff_uv_fix', 'ruff_uv' },
            qml = { 'qmlformat' },
            qmljs = { 'qmlformat' },
        },
        formatters = {
            ruff_uv_fix = {
                command = 'uv',
                args = { 'run', 'ruff', 'check', '--fix', '--exit-zero', '--stdin-filename', '$FILENAME', '-' },
                stdin = true,
            },
            ruff_uv = {
                command = 'uv',
                args = { 'run', 'ruff', 'format', '--stdin-filename', '$FILENAME', '-' },
                stdin = true,
            },
        },
    },
}
