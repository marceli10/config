-- return {
--     'folke/tokyonight.nvim',
--     version = '*',
--     priority = 1000,
--     opts = {
--         style = 'day',
--     },
-- }

-- return {
-- 	"savq/melange-nvim",
-- 	enabled = false,
-- 	config = function()
-- 		vim.opt.termguicolors = true
-- 		vim.cmd.colorscheme 'melange'
-- 	end
-- }

-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	opts = {
-- 		flavour = "frappe",
-- 	},
-- 	priority = 1000,
-- }
--
-- return {
--     'ricardoraposo/nightwolf.nvim',
--     lazy = false,
--     priority = 1000,
--     opts = {
--         theme = 'light',
--     },
-- }

return {
    'nickkadutskyi/jb.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
        vim.cmd 'colorscheme jb'
        vim.o.background = 'light'

        -- Set Cursor background to Black, text inside to White
        vim.api.nvim_set_hl(0, 'Cursor', { bg = '#000000', fg = '#ffffff' })
        vim.api.nvim_set_hl(0, 'CursorInsert', { bg = '#000000', fg = '#ffffff' })
        vim.opt.guicursor = 'n-v-c:block-Cursor,i:ver25-CursorInsert'
    end,
}
