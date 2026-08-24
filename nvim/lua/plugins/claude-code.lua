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

--- Share of the screen the Claude terminal keeps as a split. Handed to the
--- plugin as well, so its idle width and the width put back after a diff agree.
local CLAUDE_WIDTH = 0.3

--- A diff stacks three inset floats: the original file and the proposed one
--- side by side, and the Claude terminal under both so the accept/reject prompt
--- is right there. The pair asks for as many rows as the longer side has lines,
--- Claude keeps between MIN and MAX of what is left, and whatever neither needs
--- becomes margin above and below the stack.
--- DIFF_MIN keeps a one-line change from rendering as a sliver between borders.
local INSET = 0.9
local CLAUDE_MIN, CLAUDE_MAX, DIFF_MIN = 12, 22, 5

--- A rounded border costs a cell on each side of the window it wraps.
local BORDER, GAP = 2, 1

local function claude(cmd)
    return function()
        vim.cmd(cmd)
    end
end

--- Turn a window into a float. Diff highlighting is window-local and survives
--- nvim_win_set_config, so the proposed pane keeps its colours on the way over.
local function to_float(win, box, title)
    vim.api.nvim_win_set_config(win, {
        relative = 'editor',
        row = box.row,
        col = box.col,
        width = box.width,
        height = box.height,
        border = 'rounded',
        title = title,
        title_pos = 'center',
    })
end

--- The original side gets a float of our own rather than the window the plugin
--- put it in: that window is usually the file being edited, and Neovim refuses
--- to float the last non-floating window in a tabpage anyway. Left where it is
--- it anchors the layout and needs no restoring afterwards -- only its diff mode
--- moves across, so the float pairs with the proposed pane and nothing else.
local function float_original(target, box, title)
    local win = vim.api.nvim_open_win(vim.api.nvim_win_get_buf(target), false, {
        relative = 'editor',
        row = box.row,
        col = box.col,
        width = box.width,
        height = box.height,
        border = 'rounded',
        title = title,
        title_pos = 'center',
    })
    vim.api.nvim_win_call(target, function()
        vim.cmd 'diffoff'
    end)
    vim.api.nvim_win_call(win, function()
        vim.cmd 'diffthis'
    end)
    return win
end

--- Whether the Claude terminal is on screen as a split. Hidden reads as nil,
--- and a terminal already floating is somebody else's arrangement.
local function terminal_split(win)
    return win ~= nil and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function pin_terminal(win)
    if terminal_split(win) then
        pcall(vim.api.nvim_win_set_width, win, math.floor(vim.o.columns * CLAUDE_WIDTH))
    end
end

--- Boxes for the stack, centred in the rows the command line leaves. `lines` is
--- how tall the two diff panes would like to be; without a terminal strip the
--- pair floats alone.
local function stack_boxes(lines, strip_wanted)
    local total = math.floor(vim.o.columns * INSET)
    local left = math.floor((vim.o.columns - total) / 2)
    local pane = math.floor((total - GAP) / 2)
    local usable = vim.o.lines - 1

    --- The pair splits the width down the middle, one gap between the borders.
    local function pair(row, height)
        return {
            original = { row = row, col = left + 1, width = pane - BORDER, height = height },
            proposed = { row = row, col = left + pane + GAP + 1, width = pane - BORDER, height = height },
        }
    end

    if not strip_wanted then
        local height = math.max(math.min(lines, usable - BORDER), DIFF_MIN)
        local top = math.floor((usable - height - BORDER) / 2)
        return pair(top + 1, height)
    end

    local budget = usable - 2 * BORDER - GAP
    local strip = math.min(math.max(budget - lines, CLAUDE_MIN), CLAUDE_MAX)
    local height = math.max(math.min(lines, budget - strip), DIFF_MIN)
    local top = math.floor((usable - (height + strip + 2 * BORDER + GAP)) / 2)

    local boxes = pair(top + 1, height)
    boxes.claude = {
        row = top + height + BORDER + GAP + 1,
        col = left + 1,
        width = total - BORDER,
        height = strip,
    }
    return boxes
end

--- Windows left in the split layout absorb the columns the floats vacate, and
--- 'winfixwidth' does not survive that -- a file tree comes back several times
--- its width. Only fixed-width windows need handing back; everything else is
--- meant to flow. The terminal is left out, pin_terminal owns that one.
local function record_fixed_widths(term)
    local widths = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if win ~= term and vim.api.nvim_win_get_config(win).relative == '' and vim.wo[win].winfixwidth then
            widths[win] = vim.api.nvim_win_get_width(win)
        end
    end
    return widths
end

local function restore_widths(widths)
    for win, width in pairs(widths) do
        if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_set_width, win, width)
        end
    end
end

--- ClaudeCodeDiffClosed carries only { tab_name, file_path, reason } -- no
--- window ids -- and fires after the plugin has already closed the diff windows,
--- so what to clean up has to be remembered from the matching open. Keyed by
--- tab_name: replacing a diff cleans the old one up before opening the new.
local floated = {}

--- The vertical layout puts the proposed file in a vsplit next to the original.
--- Lift the proposed pane out as a float, mirror the original into a float
--- beside it, and bring the Claude terminal under the pair.
local function float_diff(data)
    local proposed, target, term = data.diff_window, data.target_window, data.terminal_window
    if not (proposed and vim.api.nvim_win_is_valid(proposed)) then
        return
    end
    if not (target and vim.api.nvim_win_is_valid(target)) then
        return
    end

    local widths = record_fixed_widths(term)
    local lines = math.max(
        vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(proposed)),
        vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(target))
    )
    local boxes = stack_boxes(lines, terminal_split(term))
    local name = vim.fn.fnamemodify(data.file_path or '', ':t')

    local original = float_original(target, boxes.original, ' ' .. name .. ' (original) ')
    to_float(proposed, boxes.proposed, ' ' .. name .. ' (proposed) ')
    if boxes.claude then
        to_float(term, boxes.claude, ' Claude ')
    end

    floated[data.tab_name] = { original = original, term = term, widths = widths }
end

--- Drop the float that mirrored the original and put the Claude terminal back
--- on the right of the layout. The plugin closes the proposed pane itself.
local function unfloat_diff(data)
    local state = floated[data.tab_name]
    if not state then
        return
    end
    floated[data.tab_name] = nil

    if state.original and vim.api.nvim_win_is_valid(state.original) then
        pcall(vim.api.nvim_win_close, state.original, true)
    end

    local term = state.term
    if term and vim.api.nvim_win_is_valid(term) and vim.api.nvim_win_get_config(term).relative ~= '' then
        vim.api.nvim_win_set_config(term, { relative = '', split = 'right', win = -1 })
    end
    restore_widths(state.widths)
    pin_terminal(term)
end

return {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    init = function()
        vim.api.nvim_create_autocmd('User', {
            pattern = 'ClaudeCodeDiffOpened',
            callback = function(args)
                float_diff(args.data)
            end,
        })
        vim.api.nvim_create_autocmd('User', {
            pattern = 'ClaudeCodeDiffClosed',
            callback = function(args)
                unfloat_diff(args.data)
            end,
        })
    end,
    opts = {
        diff_opts = {
            -- Two panes side by side -- the file as it is and as Claude proposes
            -- it -- with the terminal underneath: three windows, one per job.
            layout = 'vertical',
            -- The floats own the layout while a diff is up, so the plugin's
            -- split width juggling has nothing left to act on.
            auto_resize_terminal = false,
            -- Land in the Claude terminal, where the accept/reject prompt is,
            -- instead of in a diff pane.
            keep_terminal_focus = true,
        },
        terminal = {
            -- Same number the diff teardown restores, so the terminal is the
            -- same width whether or not a diff has just been up.
            split_width_percentage = CLAUDE_WIDTH,
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
