return {
	"numToStr/Comment.nvim",
	config = function()
		require("Comment").setup()

		vim.keymap.set("n", "<leader>c", function()
			require("Comment.api").toggle.linewise.current()
		end, { desc = "Toggle comment line" })

		vim.keymap.set("v", "<leader>c",
			"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", {
				desc = "Toggle comment selection"
			})
	end
}
