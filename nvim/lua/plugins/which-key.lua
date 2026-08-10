return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
        spec = {
            { '<leader>f', group = 'find' },
            { '<leader>fg', group = 'git' },
            { '<leader>g', group = 'git' },
            { '<leader>t', group = 'test' },
            { '<leader>d', group = 'debug' },
            { '<leader>r', group = 'run' },
        },
    },
    keys = {
        {
            '<leader>?',
            function()
                require('which-key').show { global = false }
            end,
            desc = 'Buffer Local Keymaps (which-key)',
        },
    },
}
