return {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'neovim/nvim-lspconfig',
    },
    opts = {
        ensure_installed = {
            'zls',
            'pyrefly',
            'ruff',
            'clangd',
            'lua_ls',
            'ts_ls',
            'eslint',
            'jdtls',
        },
        automatic_enable = false,
    },
}
