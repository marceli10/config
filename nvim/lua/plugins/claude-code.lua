-- Passed to claudecode by reference, so mutating it here steers where the next
-- terminal window lands.
local win_opts = {
    -- Unlisted so the outline skips it -- outline refreshes on WinEnter and
    -- would otherwise blank to 'No supported provider' the moment you focus
    -- Claude. A tool pane has no business in the buffer list either.
    bo = { buflisted = false },
    -- Snacks renders the terminal with filetype 'snacks_terminal', so a
    -- FileType autocmd never matched. Register the key on the Snacks
    -- window itself; this scopes <C-q> to the Claude terminal only.
    keys = {
        claude_close = {
            '<C-q>',
            function(self)
                self:hide()
            end,
            mode = { 'n', 't' },
            desc = 'Close Claude window',
        },
    },
}

--- Stack Claude under the outline when that pane is up, otherwise fall back to
--- a full-height split on the right.
local function place_claude()
    local outline = require('config.sidebar').outline_win()

    if outline then
        win_opts.relative, win_opts.win, win_opts.position = 'win', outline, 'bottom'
        win_opts.height, win_opts.width = 0.5, 0
    else
        win_opts.relative, win_opts.win, win_opts.position = 'editor', nil, 'right'
        win_opts.height, win_opts.width = 0, 0.3
    end
end

--- Every command that can open the terminal has to place it first.
local function claude(cmd)
    return function()
        place_claude()
        vim.cmd(cmd)
    end
end

return {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
        terminal = {
            snacks_win_opts = win_opts,
        },
    },
    keys = {
        { '<leader>a', nil, desc = 'AI/Claude Code' },
        { '<leader>ac', claude 'ClaudeCode', desc = 'Toggle Claude' },
        { '<leader>af', claude 'ClaudeCodeFocus', desc = 'Focus Claude' },
        { '<leader>ar', claude 'ClaudeCode --resume', desc = 'Resume Claude' },
        { '<leader>aC', claude 'ClaudeCode --continue', desc = 'Continue Claude' },
        { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
        { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
        { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
        {
            '<leader>as',
            '<cmd>ClaudeCodeTreeAdd<cr>',
            desc = 'Add file',
            ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
        },
        -- Diff management
        { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
        { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
}
