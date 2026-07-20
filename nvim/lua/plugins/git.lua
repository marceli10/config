return {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    opts = {
        signs = { add = { text = '+' } },
    },
    keys = {
        { '<leader>gbh', '<cmd>Gitsigns blame<cr>', desc = 'Git history blame' },
        { '<leader>gbb', '<cmd>Gitsigns toggle_current_line_blame<cr>', desc = 'Git toggle line blame' },
        { '<leader>gbl', '<cmd>Gitsigns blame_line<cr>', desc = 'Git blame line' },
    },
}
