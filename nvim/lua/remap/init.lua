vim.g.mapleader = ' '

-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- used for netrwPlugin
vim.keymap.set('n', '<C-q>', vim.cmd.q, { desc = 'Quit buffer' })

vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Escape insert mode' })

-- vim.keymap.set("n", "<C-s>", vim.cmd.w, { desc = "Save file" })
-- vim.keymap.set("i", "<C-s>", vim.cmd.wa, { desc = "Save file in insert mode" })

vim.keymap.set('n', '+', 'zO', { noremap = true, silent = true, desc = 'Open fold' })
vim.keymap.set('n', '-', 'zc', { noremap = true, silent = true, desc = 'Fold text'})

-- Use Tree-sitter for folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Optional: start with folds open
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Remove search highlights' })

vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = '[W]indow split [V]ertical' })
vim.keymap.set('n', '<leader>wh', ':split<CR>', { desc = '[W]indow split [H]orizontal' })

vim.opt.laststatus = 3
vim.opt.signcolumn = "yes:2"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim.
vim.opt.undofile = true
vim.opt.breakindent = true
vim.opt.scrolloff = 20
vim.g.have_nerd_font = true

vim.opt.swapfile = false
vim.opt.backup = false

-- 4 tabs
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

--  Closing the git diff view
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "DiffviewFiles", "DiffviewFileHistory" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>DiffviewClose<CR>", { buffer = true, desc = "Close Diffview" })
  end,
})

-- Stay in visual mode after indentetion
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left in visual mode' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right in visual mode' })
