return {
    'christoomey/vim-tmux-navigator',
    event = 'VeryLazy',
    init = function()
        vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
        local function nav(dir)
            return function()
                vim.cmd('TmuxNavigate' .. dir)
            end
        end
        local modes = { 'n', 't' }
        vim.keymap.set(modes, '<C-h>', nav 'Left', { desc = 'Navigate left' })
        vim.keymap.set(modes, '<C-j>', nav 'Down', { desc = 'Navigate down' })
        vim.keymap.set(modes, '<C-k>', nav 'Up', { desc = 'Navigate up' })
        vim.keymap.set(modes, '<C-l>', nav 'Right', { desc = 'Navigate right' })
        vim.keymap.set(modes, '<C-Tab>', nav 'Previous', { desc = 'Navigate previous' })
    end,
}
