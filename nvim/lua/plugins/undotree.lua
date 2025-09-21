return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<C-u>", "<cmd>UndotreeToggle<CR>", desc = "Toggle [U]ndotree" },
  },
  init = function()
    vim.g.undotree_WindowLayout = 4
  end
}
