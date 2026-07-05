return {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    opts = {
        ensure_installed = {
            'zls',
            'codelldb',
            'pyrefly',
            'ruff',
            'vtsls',
            'eslint',
            'jdtls',
        },
        -- jdtls is started manually by nvim-jdtls (see lua/plugins/jdtls.lua),
        -- so it must not be auto-enabled by mason-lspconfig.
        automatic_enable = {
            exclude = { 'jdtls' },
        },
    },
}
