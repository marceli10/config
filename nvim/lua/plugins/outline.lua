-- Auto-opening stops once you close the outline yourself, so navigating to
-- another file doesn't keep bringing it back.
local auto_open = true

--- Open the outline, stacking it above Claude when that pane is already up
--- rather than creating a second right-hand column.
local function open_outline(focus)
    local sidebar = require 'config.sidebar'
    local claude = sidebar.claude_win()
    local opts = { focus_outline = focus }

    if claude then
        -- outline records the current window as the code window *before*
        -- running split_command, so hopping to Claude here only decides where
        -- the split lands.
        opts.split_command = vim.api.nvim_win_get_number(claude) .. 'wincmd w | aboveleft split'
    end

    -- ...but that recorded window has to be real code. Toggling the outline
    -- while focus sits in the Claude pane would otherwise outline the terminal
    -- buffer and render 'No supported provider'.
    local code = sidebar.code_win()
    if code then
        vim.api.nvim_set_current_win(code)
    end

    require('outline').open(opts)
end

local function toggle_outline()
    local outline = require 'outline'
    if outline.is_open() then
        auto_open = false
        outline.close_outline()
    else
        auto_open = true
        open_outline(true)
    end
end

return {
    'hedyhli/outline.nvim',
    lazy = true,
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
        { '<leader>o', toggle_outline, desc = 'Toggle outline' },
    },
    init = function()
        -- LspAttach rather than BufWinEnter: it only fires for buffers that
        -- actually have a symbol provider, so the pane is never empty and
        -- plugin windows (neo-tree, Diffview, Neogit, help) never trigger it.
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('outline-auto-open', { clear = true }),
            callback = function(args)
                if not auto_open or vim.bo[args.buf].buftype ~= '' then
                    return
                end
                open_outline(false)
            end,
        })
    end,
    opts = {
        outline_window = { width = 30 },
    },
}
