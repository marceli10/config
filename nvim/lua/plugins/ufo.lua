return {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufReadPost',
    init = function()
        vim.o.foldcolumn = '0'
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
    end,
    config = function()
        local ufo = require 'ufo'
        ufo.setup {
            provider_selector = function()
                return { 'treesitter', 'indent' }
            end,
        }

        vim.keymap.set('n', '<M-->', 'zc', { desc = 'Collapse fold' })
        vim.keymap.set('n', '<M-=>', 'zo', { desc = 'Expand fold' })
        vim.keymap.set('n', '<M-_>', ufo.closeAllFolds, { desc = 'Collapse all folds' })
        vim.keymap.set('n', '<M-+>', ufo.openAllFolds, { desc = 'Expand all folds' })
    end,
}
