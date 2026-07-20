vim.g.mapleader = ' '

-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- used for netrwPlugin
vim.keymap.set('n', '<C-q>', vim.cmd.q, { desc = 'Quit buffer' })

vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Escape insert mode' })

-- vim.keymap.set("n", "<C-s>", vim.cmd.w, { desc = "Save file" })
-- vim.keymap.set("i", "<C-s>", vim.cmd.wa, { desc = "Save file in insert mode" })

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Remove search highlights' })

vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = '[W]indow split [V]ertical' })
vim.keymap.set('n', '<leader>wh', ':split<CR>', { desc = '[W]indow split [H]orizontal' })

vim.opt.laststatus = 3
vim.opt.signcolumn = 'yes:2'
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
vim.opt.updatetime = 150 -- Trigger faster events
vim.g.loaded_matchparen = 1

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
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'DiffviewFiles', 'DiffviewFileHistory' },
    callback = function()
        vim.keymap.set('n', 'q', '<cmd>DiffviewClose<CR>', { buffer = true, desc = 'Close Diffview' })
    end,
})

-- Column at 120, toggleable via <leader>ct, persisted across windows/buffers.
-- colorcolumn is window-local, so a global flag drives every window.
vim.g.colorcolumn_enabled = false

local function colorcolumn_value()
    return vim.g.colorcolumn_enabled and '120' or ''
end

local function apply_colorcolumn(win)
    vim.api.nvim_set_option_value('colorcolumn', colorcolumn_value(), { scope = 'local', win = win })
end

-- Newly entered windows pick up the persisted state
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
    desc = 'Apply persisted colorcolumn state',
    group = vim.api.nvim_create_augroup('colorcolumn-toggle', { clear = true }),
    callback = function()
        apply_colorcolumn(0)
    end,
})

vim.keymap.set('n', '<leader>ct', function()
    vim.g.colorcolumn_enabled = not vim.g.colorcolumn_enabled
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        apply_colorcolumn(win)
    end
end, { desc = '[C]olorcolumn [T]oggle' })

-- Apply initial state to the current window
apply_colorcolumn(0)

-- Stay in visual mode after indentetion
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left in visual mode' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right in visual mode' })

-- Commenting (built-in gc/gcc)
vim.keymap.set('n', '<leader>c', 'gc', { remap = true, desc = '[C]omment (operator)' })
vim.keymap.set('n', '<leader>cc', 'gcc', { remap = true, desc = '[C]omment toggle line' })
vim.keymap.set('x', '<leader>c', 'gc', { remap = true, desc = '[C]omment selection' })

-- Jump between a source file and its test file (gT; gt is taken by LSP type-definition)
local goto_test = require 'config.goto_test'
vim.keymap.set('n', 'gT', goto_test.jump, { desc = 'Go to test/source file' })
