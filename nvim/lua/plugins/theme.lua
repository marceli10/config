-- return {
--	{ 'folke/tokyonight.nvim', version = '*',
--	config = function()
--		vim.cmd.colorscheme("tokyonight-night")
--	end
--	}
--}
-- return {
-- 	"savq/melange-nvim",
-- 	enabled = false,
-- 	config = function()
-- 		vim.opt.termguicolors = true
-- 		vim.cmd.colorscheme 'melange'
-- 	end
-- }

return {
	"catppuccin/nvim",
	name = "catppuccin",
	opts = {
		flavour = "frappe",
	},
	priority = 1000,
}
