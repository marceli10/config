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
                'pyright',
                'vimls',
                'cssls',
                'jdtls',
                'gradle-ls',
                'pyright'
            },
            automatic_enable = {
                exclude = { 'jdtls' },
            },
        },
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
        },
    },
    { 'mfussenegger/nvim-jdtls', dependencies = 'hrsh7th/cmp-nvim-lsp' },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        opts = {
            file_types = { 'markdown' },
        },
    },
}
