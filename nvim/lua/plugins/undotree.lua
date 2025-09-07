return {
  "mbbill/undotree",
  config = function()
	  vim.keymap.set("n", "<leader>u", function()
		  vim.cmd.UndotreeToggle()
		  vim.cmd("wincmd p")
	  end, { desc = "Toggle Undotree" })
  end,
}
