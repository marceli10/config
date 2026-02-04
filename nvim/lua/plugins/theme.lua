-- return {
--     'nickkadutskyi/jb.nvim',
--     lazy = false,
--     priority = 1000,
--     opts = {},
--     config = function()
--         vim.o.termguicolors = true
--         vim.o.background = 'light'
--         vim.cmd 'colorscheme jb'
--
--         vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i:ver25-Cursor,r-cr-o:hor20-Cursor'
--         vim.api.nvim_set_hl(0, 'Cursor', { bg = '#000000'})
--     end,
-- }

-- return {
--     'folke/tokyonight.nvim',
--     lazy = false,
--     priority = 1000,
--     opts = {
--         style = 'day',
--     },
-- }

-- return {
--     "yorik1984/newpaper.nvim",
--     priority = 1000,
--     config = true,
--     opts={
--         style="light"
--     }
-- }

return { 'projekt0n/github-nvim-theme', name = 'github-theme' }
