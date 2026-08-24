return {
    'stevearc/conform.nvim',
    keys = {
        {
            '<C-f>',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = { 'n', 'x' },
            desc = 'Format Buffer',
        },
    },
    opts = {
        formatters_by_ft = {
            lua = { 'stylua' },
            python = { 'ruff_organize_imports', 'ruff_format' },
            java = { 'google-java-format' },
            javascript = { 'prettier' },
            javascriptreact = { 'prettier' },
            typescript = { 'prettier' },
            typescriptreact = { 'prettier' },
            json = { 'prettier' },
            jsonc = { 'prettier' },
            css = { 'prettier' },
            scss = { 'prettier' },
            html = { 'prettier' },
            yaml = { 'prettier' },
            markdown = { 'prettier' },
            graphql = { 'prettier' },
            sh = { 'shfmt' },
        },
    },
}
