return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    init = function()
        -- Inside tmux the outer terminal is invisible to snacks: TERM_PROGRAM
        -- is 'tmux', and its fallback probe only fires for `extended-keys on`
        -- while .tmux.conf sets `always`. Detection then reports the terminal
        -- as unsupported and nothing renders, so state it outright.
        if vim.env.TMUX then
            vim.env.SNACKS_GHOSTTY = 'true'
        end
    end,
    opts = {
        image = {
            enabled = true,
            -- Only render actual image buffers; no inline images/math inside
            -- markdown & friends.
            doc = { enabled = false },
        },
    },
}
