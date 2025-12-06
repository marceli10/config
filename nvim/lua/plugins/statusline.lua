return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    opts = {
        options = {
            theme = '16color',
            section_separators = '',
            component_separators = '',
            globalstatus = true,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { 'filename' },
            lualine_x = { 'searchcount', 'lsp_status' },
            lualine_y = { 'encoding', 'filetype' },
            lualine_z = { 'location', 'searchcount' },
        },
    },
}
