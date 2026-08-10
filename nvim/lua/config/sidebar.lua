--- Keeps the outline and Claude Code panes stacked in one right-hand column
--- instead of opening as two side-by-side splits. Whichever opens second
--- splits the one already showing.
local M = {}

--- @param predicate fun(buf: integer): boolean
--- @return integer? win
local function find_win(predicate)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if predicate(vim.api.nvim_win_get_buf(win)) then
            return win
        end
    end
end

--- @return integer? win
function M.outline_win()
    return find_win(function(buf)
        return vim.bo[buf].filetype == 'Outline'
    end)
end

--- @return integer? win
function M.claude_win()
    return find_win(function(buf)
        return vim.bo[buf].filetype == 'snacks_terminal'
            and vim.api.nvim_buf_get_name(buf):lower():match 'claude' ~= nil
    end)
end

--- A window holding an ordinary file, preferring the current one. Used to keep
--- the outline pointed at real code when it is opened from a sidebar pane.
--- @return integer? win
function M.code_win()
    local current = vim.api.nvim_get_current_win()
    local function is_code(buf)
        return vim.bo[buf].buftype == '' and vim.bo[buf].filetype ~= 'Outline'
    end

    if is_code(vim.api.nvim_win_get_buf(current)) then
        return current
    end
    return find_win(is_code)
end

return M
