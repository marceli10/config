return {
    {
        'NeogitOrg/neogit',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
            'nvim-telescope/telescope.nvim',
        },
        keys = {
            { '<leader>gg', ':Neogit<CR>', desc = 'Open neo[GG]it split' },
            {
                '<leader>gl',
                function()
                    require('neogit').action('log', 'log_current')()
                end,
                desc = 'Open neo[G]it [l]og',
            },
            {
                '<leader>gL',
                function()
                    require('neogit').action('log', 'log_head')()
                end,
                desc = 'Open neo[G]it [L]og',
            },
            { '<leader>gh', ':DiffviewFileHistory %<CR>', desc = 'Open [g]it [h]istory - current file' },
            { '<leader>gH', ':DiffviewFileHistory<CR>', desc = 'Open [g]it [H]istory - branch' },
            { '<leader>gD', ':DiffviewOpen<CR>', desc = 'Open [g]it [D]iff view - branch' },
            { '<leader>gB', ':Telescope git_branches<CR>', desc = 'Open [g]it [B]ranches view' },
        },
        opts = {
            kind = 'split',
            integrations = {
                diffview = true,
                telescope = true,
            },
        },
    },
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = { add = { text = '+' } },
        },
        keys = {
            { '<leader>gd', ':Gitsigns diffthis<CR>', desc = '[g]it [d]iff current file' },
            { '<leader>gbb', ':Gitsigns blame<CR>', desc = '[g]it [bb]lame history' },
            { '<leader>gbl', ':Gitsigns blame_line<CR>', desc = '[g]it [b]lame [l]ine' },
            { '<leader>gbt', ':Gitsigns toggle_current_line_blame<CR>', desc = '[g]it [b]lame [t]oggle' },
            { '<leader>gc', ':Gitsigns preview_hunk<CR>', desc = '[g]it preview hunk [cc]' },
            { 'g]', ':Gitsigns nav_hunk next<CR>', desc = '[g]it ] next hunk' },
            { 'g[', ':Gitsigns nav_hunk prev<CR>', desc = '[g]it [ previous hunk' },
            { '<leader>gf', ':Gitsign setloclist<CR>', desc = '[g]it [f]ile changes' },
        },
    },
}
