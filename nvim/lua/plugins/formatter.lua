return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.google_java_format,
                null_ls.builtins.formatting.prettier,
				-- require("none-ls.diagnostics.eslint_d"),
			},
		})

	 vim.keymap.set("n", "<C-f>", vim.lsp.buf.format, { desc = "[C-f] code format" })
	end,
}
