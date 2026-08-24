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
            -- Not used as a server: typescript-tools.nvim spawns tsserver itself and
            -- falls back to this package's bundled typescript when a project has no
            -- local node_modules/typescript.
            'ts_ls',
            'eslint',
            'jdtls',
        },
        automatic_enable = {
            exclude = { 'jdtls', 'ts_ls', 'pyright', 'basedpyright', 'stylua' },
        },
    },
}
