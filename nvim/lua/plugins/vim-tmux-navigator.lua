return {
    'christoomey/vim-tmux-navigator',
    cmd = {
        'TmuxNavigateLeft',
        'TmuxNavigateDown',
        'TmuxNavigateUp',
        'TmuxNavigateRight',
        'TmuxNavigatePrevious',
        'TmuxNavigatorProcessList',
    },
    keys = {
        { '<c-h>', ':TmuxNavigateLeft<cr>' },
        { '<c-j>', ':TmuxNavigateDown<cr>' },
        { '<c-k>', ':TmuxNavigateUp<cr>' },
        { '<c-l>', ':TmuxNavigateRight<cr>' },
        { '<c-Tab>', ':TmuxNavigatePrevious<cr>' },
    },
}
