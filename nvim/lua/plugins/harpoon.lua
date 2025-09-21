return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
	local harpoon = require("harpoon")

	harpoon:setup()

	vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "[H]arpoon [A]dd file"})
	vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[H]arpoon s[H]ow"})

	vim.keymap.set("n", "<leader>hq", function() harpoon:list():select(1) end, { desc = "[H]arpoon [Q] -> 1st file"})
	vim.keymap.set("n", "<leader>hw", function() harpoon:list():select(2) end, { desc = "[H]arpoon [W] -> 2nd file"})
	vim.keymap.set("n", "<leader>he", function() harpoon:list():select(3) end, { desc = "[H]arpoon [E] -> 3rd file"})
	vim.keymap.set("n", "<leader>hr", function() harpoon:list():select(4) end, { desc = "[H]arpoon [R] -> 4th file"})

	vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "[H]arpoon [N]ext -> next file"})
	vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "[H]arpoon [P]revious -> previous file"})
    end
}
