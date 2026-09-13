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

local function merge_main_win()
    return require('diffview.lib').get_current_view().cur_layout:get_main_win()
end

--- jumpto_conflict only moves the cursor; centre it like the other change
--- navigation in this config.
local function goto_conflict(num, use_delta)
    return function()
        if require('diffview.actions').jumpto_conflict(num, use_delta) then
            vim.api.nvim_win_call(merge_main_win().id, function()
                vim.cmd 'normal! zz'
            end)
        end
    end
end

--- diffview's 'all' also pastes the base section, which zdiff3 fills in.
--- "Both" here is ours then theirs, as IntelliJ does it. Whole-file goes
--- bottom-up so earlier replacements don't shift later line numbers.
local function take_both(whole_file)
    return function()
        local main = merge_main_win()
        local buf = main.file.bufnr
        local conflicts, cur =
            require('diffview.vcs.utils').parse_conflicts(vim.api.nvim_buf_get_lines(buf, 0, -1, false), main.id)
        for _, c in ipairs(whole_file and vim.iter(conflicts):rev():totable() or { cur }) do
            local both = vim.list_extend(vim.list_slice(c.ours.content or {}), c.theirs.content or {})
            vim.api.nvim_buf_set_lines(buf, c.first - 1, c.last, false, both)
        end
    end
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
                { 'n', 'cB', take_both(true), { desc = 'Conflict: take both (file)' } },
            }

            local conflict_keys = vim.list_extend({
                { 'n', '<leader>co', false },
                { 'n', '<leader>ct', false },
                { 'n', '<leader>cb', false },
                { 'n', '<leader>ca', false },
                { 'n', 'co', actions.conflict_choose 'ours', { desc = 'Conflict: take ours' } },
                { 'n', 'ct', actions.conflict_choose 'theirs', { desc = 'Conflict: take theirs' } },
                { 'n', 'cb', take_both(false), { desc = 'Conflict: take both' } },
                { 'n', 'c0', actions.conflict_choose 'none', { desc = 'Conflict: take neither' } },
                { 'n', '<C-n>', goto_conflict(1, true), { desc = 'Next conflict' } },
                { 'n', '<C-p>', goto_conflict(-1, true), { desc = 'Previous conflict' } },
            }, whole_file_keys)

            return {
                view = {
                    default = { layout = 'diff2_horizontal', winbar_info = true },
                    -- IntelliJ's arrangement: ours | result | theirs.
                    merge_tool = { layout = 'diff3_horizontal', disable_diagnostics = true, winbar_info = true },
                    file_history = { layout = 'diff2_horizontal', winbar_info = true },
                },
                hooks = {
                    -- Open each file on its first conflict. The hook re-fires on
                    -- every refresh, so only jump when the window gets a new buffer.
                    diff_buf_win_enter = function(bufnr, winid, ctx)
                        if ctx.layout_name ~= 'diff3_horizontal' or ctx.symbol ~= 'b' then
                            return
                        end
                        if vim.w[winid].conflict_buf ~= bufnr then
                            vim.w[winid].conflict_buf = bufnr
                            vim.schedule(goto_conflict(1))
                        end
                    end,
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
