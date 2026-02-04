return {
    {
        'mason-org/mason.nvim',
        opts = {},
    },
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            ensure_installed = {
                'lua_ls',
                'ts_ls',
                'html',
                'postgres_lsp',
                'jdtls',
                'vimls',
                'cssls',
                'jdtls',
                'gradle_ls',
                'basedpyright',
                'ruff',
            },
            automatic_enable = {
                exclude = { 'jdtls' },
            },
        },
        dependencies = {
            'neovim/nvim-lspconfig',
            'saghen/blink.cmp',
        },
    },
    { 'mfussenegger/nvim-jdtls', dependencies = 'saghen/blink.cmp' },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        opts = {
            file_types = { 'markdown' },
        },
    },
}
