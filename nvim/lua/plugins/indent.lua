return {
    'nvim-mini/mini.indentscope',
    version = '*',
    opts = {
        symbol = '│',
        options = { try_as_border = true },
    },
    init = function()
        vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'neo-tree', 'claude-code' },
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
        })
    end,
}
