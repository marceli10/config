return {
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				hijack_netrw = true,
				auto_reload_on_write = true,
				view = {
					width = 35,
					side = "left",
				},
				git = {
					enable = true,
				},
				filters = {
					dotfiles = false,
				},
				renderer = {
					icons = {
						webdev_colors = true, -- enable filetype icon colors
						git_placement = "after", -- or "before"
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
						glyphs = {
							default = "", -- fallback icon
							symlink = "",
							bookmark = "",
							folder = {
								arrow_closed = "",
								arrow_open = "",
								default = "",
								open = "",
								empty = "",
								empty_open = "",
								symlink = "",
							},
							git = {
								unstaged = "✗",
								staged = "✓",
								unmerged = "",
								renamed = "➜",
								deleted = "",
								untracked = "★",
								ignored = "◌",
							},
						},
					},
				},
			})
			vim.keymap.set("n", "<C-1>", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		end,
}
