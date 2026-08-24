local function nav_hunk_in_preview(direction, fallback)
    return function()
        if require('gitsigns.popup').is_open 'hunk' then
            return '<Cmd>Gitsigns nav_hunk ' .. direction .. ' preview=true<CR>'
        end
        return fallback
    end
end

local function toggle_blame_window()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'gitsigns-blame' then
            vim.api.nvim_win_close(win, true)
            return
        end
    end
    vim.cmd.Gitsigns 'blame'
end

local function toggle_diffview()
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
            if ft == 'DiffviewFiles' or ft == 'DiffviewFileHistory' then
                vim.api.nvim_set_current_tabpage(tab)
                vim.cmd.DiffviewClose()
                return
            end
        end
    end
    vim.cmd.DiffviewOpen()
end

local function conflict_qflist()
    local git = vim.system({ 'git', 'diff', '--name-only', '--diff-filter=U', '--relative' }, { text = true }):wait()
    if git.code ~= 0 then
        vim.notify('Not a git repository', vim.log.levels.WARN)
        return
    end

    local items = {}
    for _, path in ipairs(vim.split(vim.trim(git.stdout), '\n', { trimempty = true })) do
        local lnum = 1
        for i, line in ipairs(vim.fn.readfile(path)) do
            if line:match '^<<<<<<< ' then
                lnum = i
                break
            end
        end
        items[#items + 1] = { filename = path, lnum = lnum, text = 'unresolved conflict' }
    end

    if #items == 0 then
        vim.notify('No unresolved conflicts', vim.log.levels.INFO)
        return
    end

    vim.fn.setqflist(items, ' ')
    vim.cmd.copen()
end

return {
    {
        'lewis6991/gitsigns.nvim',
        lazy = false,
        opts = {
            signs = { add = { text = '+' } },
            preview_config = { border = 'rounded' },
        },
        keys = {
            { '<leader>gB', toggle_blame_window, desc = 'Git history blame (toggle)' },
            { '<leader>gb', '<cmd>Gitsigns blame_line<cr>', desc = 'Git blame line' },
            { '<leader>gh', '<cmd>Gitsigns preview_hunk<cr>', desc = 'Git preview hunk' },
            {
                '<C-n>',
                nav_hunk_in_preview('next', '<C-n>'),
                expr = true,
                desc = 'Git next hunk (in preview)',
            },
            {
                '<C-p>',
                nav_hunk_in_preview('prev', '<C-p>'),
                expr = true,
                desc = 'Git previous hunk (in preview)',
            },
            { '<leader>gu', '<cmd>Gitsigns reset_hunk<cr>', desc = 'Git undo hunk' },
            { '<leader>gU', '<cmd>Gitsigns reset_buffer<cr>', desc = 'Git undo buffer' },
        },
    },

    {
        'sindrets/diffview.nvim',
        cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
        opts = function()
            local actions = require 'diffview.actions'

            local whole_file_keys = {
                { 'n', '<leader>cO', false },
                { 'n', '<leader>cT', false },
                { 'n', '<leader>cB', false },
                { 'n', '<leader>cA', false },
                { 'n', 'cO', actions.conflict_choose_all 'ours', { desc = 'Conflict: take ours (file)' } },
                { 'n', 'cT', actions.conflict_choose_all 'theirs', { desc = 'Conflict: take theirs (file)' } },
                { 'n', 'cB', actions.conflict_choose_all 'all', { desc = 'Conflict: take both (file)' } },
            }

            local conflict_keys = vim.list_extend({
                { 'n', '<leader>co', false },
                { 'n', '<leader>ct', false },
                { 'n', '<leader>cb', false },
                { 'n', '<leader>ca', false },
                { 'n', 'co', actions.conflict_choose 'ours', { desc = 'Conflict: take ours' } },
                { 'n', 'ct', actions.conflict_choose 'theirs', { desc = 'Conflict: take theirs' } },
                { 'n', 'cb', actions.conflict_choose 'all', { desc = 'Conflict: take both' } },
                { 'n', 'c0', actions.conflict_choose 'none', { desc = 'Conflict: take neither' } },
            }, whole_file_keys)

            return {
                view = {
                    default = { layout = 'diff2_horizontal', winbar_info = true },
                    merge_tool = { layout = 'diff3_mixed', disable_diagnostics = true, winbar_info = true },
                    file_history = { layout = 'diff2_horizontal', winbar_info = true },
                },
                keymaps = {
                    view = conflict_keys,
                    file_panel = whole_file_keys,
                },
            }
        end,
        keys = {
            { '<leader>gd', toggle_diffview, desc = 'Git diff worktree (toggle)' },
            { '<leader>gf', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git file history' },
            {
                '<leader>gf',
                ':DiffviewFileHistory<cr>',
                mode = 'x',
                desc = 'Git history for selection',
            },
            { '<leader>gl', '<cmd>DiffviewFileHistory<cr>', desc = 'Git commit log' },
            { '<leader>gx', conflict_qflist, desc = 'Git conflicts (quickfix)' },
        },
    },

    {
        'NeogitOrg/neogit',
        cmd = 'Neogit',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim',
        },
        opts = {
            integrations = { diffview = true, fzf_lua = true },
            kind = 'floating',
        },
        keys = {
            { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Git status (Neogit)' },
            { '<leader>gc', '<cmd>Neogit commit<cr>', desc = 'Git commit' },
        },
    },
}
