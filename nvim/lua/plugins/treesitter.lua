return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
        'windwp/nvim-ts-autotag', -- auto-closing the jsx tags
    },
    build = ':TSUpdate',
    config = function()
        local ts_config = require 'nvim-treesitter.configs'
        ts_config.setup {
            ensure_installed = {
                'c',
                'csv',
                'dockerfile',
                'groovy',
                'javadoc',
                'json',
                'hcl',
                'toml',
                'yaml',
                'xml',
                'lua',
                'vim',
                'vimdoc',
                'query',
                'markdown',
                'markdown_inline',
                'java',
                'kotlin',
                'python',
                'html',
                'css',
                'javascript',
                'typescript',
            },
            highlight = { enable = true },
            auto_install = true,
            additional_vim_regex_highlighting = false,
            autotag = {
                enable = true,
            },
        }
    end,
}
