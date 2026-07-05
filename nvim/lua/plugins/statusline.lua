return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = 'onelight',
            section_separators = '',
            component_separator = '',
            disabled_filetypes = { statusline = { 'neo-tree' } },
        },
        sections = {
            lualine_b = {
                'branch',
                'diff',
                'diagnostics',
            },
            lualine_c = {
                { 'filename', path = 1 },
            },
            lualine_x = {
                'lsp_status',
                'filetype',
                'encoding',
            },
        },
    },
}
