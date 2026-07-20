return {
    'petertriho/nvim-scrollbar',
    event = 'VeryLazy',
    dependencies = {
        'lewis6991/gitsigns.nvim', -- for git hunk marks; own spec in git.lua, listed here for load order
        'kevinhwang91/nvim-hlslens', -- for search marks + floating match counter
    },
    config = function()
        -- Pull the foreground color from a highlight group so scrollbar git marks
        -- match the gitsigns palette (and update if the theme sets them distinctly).
        local function hl_fg(name)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            if ok and hl.fg then
                return string.format('#%06x', hl.fg)
            end
        end

        require('scrollbar').setup {
            handlers = {
                cursor = true,
                diagnostic = true,
                gitsigns = true,
                search = true,
                handle = true,
            },
            show_in_active_only = true,
            hide_if_all_visible = true,
            marks = {
                -- Distinguish added vs modified lines: solid bar vs dashed bar, distinct colors.
                GitAdd = { text = '┃', color = hl_fg 'GitSignsAdd' },
                GitChange = { text = '┆', color = hl_fg 'GitSignsChange' },
                GitDelete = { text = '▁', color = hl_fg 'GitSignsDelete' },
            },
        }
        require('scrollbar.handlers.gitsigns').setup()
        require('scrollbar.handlers.search').setup()

        -- Keep the hlslens match counter in sync when cycling matches
        local opts = { silent = true }
        local function lens(key)
            return string.format(
                [[<Cmd>execute('normal! ' . v:count1 . '%s')<CR><Cmd>lua require('hlslens').start()<CR>]],
                key
            )
        end
        vim.keymap.set('n', 'n', lens 'n', opts)
        vim.keymap.set('n', 'N', lens 'N', opts)
        vim.keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], opts)
        vim.keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], opts)
        vim.keymap.set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], opts)
        vim.keymap.set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], opts)
    end,
}
