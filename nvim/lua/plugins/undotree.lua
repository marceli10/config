return {
    dir = vim.env.VIMRUNTIME .. '/pack/dist/opt/nvim.undotree',
    name = 'undotree',
    lazy = true,
    cmd = 'Undotree',
    keys = {
        {
            '<leader>u',
            function()
                local source = vim.api.nvim_get_current_buf()

                if require('undotree').open() then
                    return
                end

                local width = math.floor(vim.o.columns * 0.4)
                local tree = vim.api.nvim_get_current_win()
                vim.api.nvim_win_set_config(tree, {
                    relative = 'editor',
                    width = width,
                    height = vim.o.lines - 6,
                    row = 1,
                    col = vim.o.columns - width - 2,
                    border = 'rounded',
                    title = ' Undotree ',
                    title_pos = 'center',
                })

                vim.keymap.set('n', '<C-l>', function()
                    vim.api.nvim_set_current_win(tree)
                end, { buffer = source, desc = 'Focus undotree' })

                vim.api.nvim_create_autocmd('WinClosed', {
                    pattern = tostring(tree),
                    once = true,
                    callback = function()
                        pcall(vim.keymap.del, 'n', '<C-l>', { buffer = source })
                    end,
                })
            end,
            desc = 'Toggle undotree',
        },
    },
}
